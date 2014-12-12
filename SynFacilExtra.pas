{                               SynFacilRegex
Unidad con rutinas adicionales de SynFacilSyn.
Incluye la definición de "tFaTokContent" y el procesamiento de expresiones regulares
que son usadas por TSynFacilSyn.

                                 Por Tito Hinostroza  02/12/2014 - Lima Perú
}
unit SynFacilExtra;
{$mode objfpc}{$H+}
interface
uses
  SysUtils, SynEditHighlighter, strutils;

type
  //Tipo de expresión regular soportada. Las exp. regulares soportadas son
  //simples. Solo incluyen literales de cadena o listas.
  tFaRegExpType = (
    tregString,   //Literal de cadena: "casa"
    tregChars,    //Lista de caracteres: [A..Z]
    tregChars01,  //Lista de caracteres: [A..Z]?
    tregChars0_,  //Lista de caracteres: [A..Z]*
    tregChars1_   //Lista de caracteres: [A..Z]+
  );

  tFaActionOnMatch = (
    aomNext,    //pasa a la siguiente instrucción
    aomExit,    //termina la exploración
    aomMovePar, //Se mueve a una posición específica
    aomExitpar  //termina la exploración retomando una posición específica.
  );

  //Estructura para almacenar una instrucción de token por contenido
  tFaTokContentInst = record
    Chars    : array[#0..#255] of ByteBool; //caracteres
    Text     : string;             //cadena válida
    expTyp   : tFaRegExpType;      //tipo de expresión
    TokTyp   : TSynHighlighterAttributes;   //tipo de token al salir
    dMatch   : byte;   //desplazamiento en caso de coincidencia (0 = salir)
    dMiss    : byte;   //desplazamiento en caso de no coincidencia (0 = salir)
    //Campos para ejecutar instrucciones, cuando No cumple
    actionFail : tFaActionOnMatch;
    destOnFail : integer;  //posición destino
    //Campos para ejecutar instrucciones, cuando cumple
    actionMatch: tFaActionOnMatch;
    destOnMatch: integer;  //posición destino

    posFin     : integer;  //para guardar posición
  end;

  ESynFacilSyn = class(Exception);   //excepción del resaltador

  { tFaTokContent }
  //Estructura para almacenar la descripción de los token por contenido
  tFaTokContent = class
    TokTyp    : TSynHighlighterAttributes;   //categoría de token por contenido
//    CharsToken: array[#0..#255] of ByteBool; //caracteres válidos para token por contenido
    //elementos adicionales no usados en esta versión
    Instrucs : array of tFaTokContentInst;  //Instrucciones del token por contenido
    nInstruc : integer;      //Cantidad de instrucciones
    procedure Clear;
//    function ValidateInterval(var cars: string): boolean;
    procedure AddInstruct(exp: string; ifFalse: string='exit';
      TokTyp0: TSynHighlighterAttributes = nil);
    procedure AddRegEx(exp: string);
  private
    function AddItem(expTyp: tFaRegExpType; ifMatch, ifFail: string): integer;
    procedure AddOneInstruct(var exp: string; ifFalse: string='exit';
      TokTyp0: TSynHighlighterAttributes=nil);
  end;

function ExtractRegExp(var exp: string; var str: string; var listChars: string): tFaRegExpType;
procedure ValidateInterval(var cars: string);

implementation
const
//    ERR_EMPTY_INTERVAL = 'Error: Intervalo vacío.';
//    ERR_DEF_INTERVAL = 'Error en definición de intervalo: %s';
    ERR_EMPTY_INTERVAL = 'Error: Empty Interval.';
    ERR_DEF_INTERVAL = 'Interval definition error: %s';
    ERR_EMPTY_EXPRES = 'Empty expression.';
    ERR_EXPECTED_BRACK = 'Expected "]".';
    ERR_UNSUPPOR_EXP_ = 'Unsupported expression: ';
    ERR_INC_ESCAPE_SEQ = 'Incomplete Escape sequence';
    ERR_SYN_PAR_IFFAIL_ = 'Syntax error on Parameter "IfFail": ';
    ERR_SYN_PAR_IFMATCH_ = 'Syntax error on Parameter "IfMarch": ';

var
  bajos: string[128];
  altos: string[128];

function copyEx(txt: string; p: integer): string;
//Versión sobrecargada de copy con 2 parámetros
begin
  Result := copy(txt, p, length(txt));
end;
function ExtractChar(var txt: string; var escaped: boolean; convert: boolean): string;
//Extrae un caracter de una expresión regular. Si el caracter es escapado, devuelve
//TRUE en "escaped"
//Si covert = TRUE, reemplaza el caracter compuesto por uno solo.
var
  c: byte;
begin
  escaped := false;
  Result := '';   //valor por defecto
  if txt = '' then exit;
  if txt[1] = '\' then begin  //caracter escapado
    escaped := true;
    if length(txt) = 1 then  //verificación
      raise ESynFacilSyn.Create(ERR_INC_ESCAPE_SEQ);
    if txt[2] in ['x','X'] then begin
      //caracter en hexadecimal
      if length(txt) < 4 then  //verificación
        raise ESynFacilSyn.Create(ERR_INC_ESCAPE_SEQ);
      if convert then begin    //toma caracter hexdecimal
        c := StrToInt('$'+copy(txt,3,2));
        Result := Chr(c);
      end else begin  //no tranforma
        Result := copy(txt, 1,4);
      end;
      txt := copyEx(txt,5);
    end else begin
      if convert then begin    //toma caracter hexdecimal
        //secuencia normal de dos caracteres
        Result := txt[2];
      end else begin
        Result := copy(txt,1,2);
      end;
      txt := copyEx(txt,3);
    end;
  end else begin   //caracter normal
    Result := txt[1];
    txt := copyEx(txt,2);
  end;
end;
function ExtractChar(var txt: string): char;
//Versión simplificada de ExtractChar(). Extrae un caracter ya convertido. Si no hay
//más caracteres, devuelve #0
var
  escaped: boolean;
  tmp: String;
begin
  if txt = '' then Result := #0
  else begin
    tmp := ExtractChar(txt, escaped, true);
    Result := tmp[1];  //se supone que siempre será de un solo caracter
  end;
end;
function ExtractCharN(var txt: string): string;
//Versión simplificada de ExtractChar(). Extrae un caracter sin convertir.
var
  escaped: boolean;
begin
  Result := ExtractChar(txt, escaped, false);
end;
function ReplaceEscape(str: string): string;
{Reemplaza las secuencias de eescape por su caracter real. Las secuencias de
escape recnocidas son:
* Secuencia de 2 caracteres: "\#", donde # es un caracter cualquiera, excepto"x".
  Esta secuencia equivale al caracter "#".
* Secuencia de 4 caracteres: "\xHH" o "\XHH", donde "HH" es un número hexadecimnal.
  Esta secuencia representa a un caracter ASCII.

Dentro de las expresiones regulares de esta librería, los caracteres: "[", "*", "?",
"*", y "\", tienen significado especial, por eso deben "escaparse".

"\[" -> "["
"\*" -> "*"
"\?" -> "?"
"\+" -> "+"
"\\" -> "\"
}
begin
  Result := '';
  while str<>'' do
    Result += ExtractChar(str);
end;
function PosChar(ch: char; txt: string): integer;
//Similar a Pos(). Devuelve la posición de un caracter que no este "escapado"
var
  f: SizeInt;
begin
  f := Pos(ch,txt);
  if f=1 then exit(1);   //no hay ningún caracter antes.
  while (f>0) and (txt[f-1]='\') do begin
    f := PosEx(ch, txt, f+1);
  end;
  Result := f;
end;
procedure ValidateInterval(var cars: string);
{Valida un conjunto de caracteres, expandiendo los intervalos de tipo "A-Z", y
remplazando las secuencias de escape como: "\[", "\\", "\-", ...
El caracter "-", se considera como indicador de intervalo, a menos que se encuentre
en elprimer o ùltimocaracter de la cadena.
Si hay error genera una excepción.}
var
  c, car1, car2: char;
  car: string;
  tmp: String;
begin
  //reemplaza intervalos
  if cars = '' then
    raise ESynFacilSyn.Create(ERR_EMPTY_INTERVAL);
  car  := ExtractCharN(cars);  //Si el primer caracter es "-". lo toma literal.
  tmp := car;  //inicia cadena para acumular.
  car1 := ExtractChar(car);    //Se asume que es inicio de intervalo. Ademas car<>''. No importa qye se pierda 'car'
  car := ExtractCharN(cars);   //extrae siguiente
  while car<>'' do begin
    if car = '-' then begin
      //es intervalo
      car2 := ExtractChar(cars);   //caracter final
      if car2 = #0 then begin
        //Es intervalo incompleto, podría genera error, pero mejor asumimos que es el caracter "-"
        tmp += '-';
        break;  //sale por que se supone que ya no hay más caracteres
      end;
      //se tiene un intervalo que hay que reemplazar
      for c := Chr(Ord(car1)+1) to car2 do  //No se incluye "car1", porque ya se agregó
        tmp += c;
    end else begin  //simplemente acumula
      tmp += car;
      car1 := ExtractChar(car);    //Se asume que es inicio de intervalo. No importa qye se pierda 'car'
    end;
    car := ExtractCharN(cars);  //extrae siguiente
  end;
  cars := ReplaceEscape(tmp);
  cars := StringReplace(cars, '%HIGH%', altos,[rfReplaceAll]);
  cars := StringReplace(cars, '%ALL%', bajos+altos,[rfReplaceAll]);
end;
function ExtractRegExp(var exp: string; var str: string; var listChars: string): tFaRegExpType;
{Extrae parte de una expresión regular y devuelve el tipo.
En los casos de listas de caracteres, expande los intervalos de tipo: A..Z, reemplaza
las secuencias de escape y devuelve la lista en "listChars".
En el caso de que sea un literal de cadena, reemplaza las secuencias de escape y
devuelve la cadena en "str".
Soporta todas las formas definidas en "tFaRegExpType".
Si encuentra error, genera una excepción.}
var
  f: Integer;
  tmp: string;
  lastAd: String;

begin
  if exp= '' then
    raise ESynFacilSyn.Create(ERR_EMPTY_EXPRES);
  if (exp[1] = '[') and (length(exp)>1) then begin    //Es lista de caracteres
    f := PosChar(']', exp);  //Busca final, obviando "\]"
    if f=0 then
      raise ESynFacilSyn.Create(ERR_EXPECTED_BRACK);
    //El intervalo se cierra
    listChars := copy(exp,2,f-2); //toma interior de lista
    exp := copyEx(exp,f+1);       //extrae parte procesada
    ValidateInterval(listChars);  //puede simplificar "listChars". También puede generar excepción
    if exp = '' then begin   //Lista de tipo "[ ... ]"
      Result := tregChars;
    end else if exp[1] = '*' then begin  //Lista de tipo "[ ... ]* ... "
      exp := copyEx(exp,2);    //extrae parte procesada
      Result := tregChars0_
    end else if exp[1] = '?' then begin  //Lista de tipo "[ ... ]? ... "
      exp := copyEx(exp,2);    //extrae parte procesada
      Result := tregChars01
    end else if exp[1] = '+' then begin  //Lista de tipo "[ ... ]+ ... "
      exp := copyEx(exp,2);    //extrae parte procesada
      Result := tregChars1_
    end else begin
      //No sigue ningún cuantificador, podrías er algún literal
      Result := tregChars;  //Lista de tipo "[ ... ] ... "
    end;
  end else if (length(exp)=1) and (exp[1] in ['*','?','+','[']) then begin
    //Caso especial, no se usa escape, pero no es lista, ni cuantificador. Se asume
    //caracter único
    listChars := exp;  //'['+exp+']'
    exp := '';    //ya no quedan caracteres
    Result := tregChars;
    exit;
  end else begin
    //No inicia con lista. Se puede suponer que inicia con literal cadena.
    {Pueden ser los casos:
      Caso 0) "abc"    (solo literal cadena, se extraerá la cadena "abc")
      Caso 1) "abc[ ... "  (válido, se extraerá la cadena "abc")
      Caso 2) "a\[bc[ ... " (válido, se extraerá la cadena "a[bc")
      Caso 3) "abc* ... "  (válido, pero se debe procesar primero "ab")
      Caso 4) "ab\\+ ... " (válido, pero se debe procesar primero "ab")
      Caso 5) "a? ... "    (válido, pero debe transformarse en lista)
      Caso 6) "\[* ... "   (válido, pero debe transformarse en lista)
    }
    str := '';   //para acumular
    tmp := ExtractCharN(exp);
    lastAd := '';   //solo por seguridad
    while tmp<>'' do begin
      if tmp = '[' then begin
        //Empieza una lista. Caso 1 o 2
        exp:= '[' + exp;  //devuelve el caracter
        str := ReplaceEscape(str);
        if length(str) = 1 then begin  //verifica si tiene un caracter
          listChars := str;       //'['+str+']'
          Result := tregChars;   //devuelve como lista de un caracter
          exit;
        end;
        Result := tregString;   //es literal cadena
        exit;  //sale con lo acumulado en "str"
      end else if (tmp = '*') or (tmp = '?') or (tmp = '+') then begin
        str := copy(str, 1, length(str)-length(lastAd)); //no considera el último caracter
        if str <> '' then begin
          //Hay literal cadena, antes de caracter y cuantificador. Caso 3 o 4
          exp:= lastAd + tmp + exp;  //devuelve el último caracter agregado y el cuantificador
          str := ReplaceEscape(str);
          if length(str) = 1 then begin  //verifica si tiene un caracter
            listChars := str;       //'['+str+']'
            Result := tregChars;   //devuelve como lista de un caracter
            exit;
          end;
          Result := tregString;   //es literal cadena
          exit;
        end else begin
          //Hay caracter y cuantificador. . Caso 5 o 6
          listChars := ReplaceEscape(lastAd);  //'['+lastAd+']'
          //de "exp" ya se quitó: <caracter><cuantificador>
          if          tmp = '*' then begin  //Lista de tipo "[a]* ... "
            Result := tregChars0_
          end else if tmp = '?' then begin  //Lista de tipo "[a]? ... "
            Result := tregChars01
          end else if tmp = '+' then begin  //Lista de tipo "[a]+ ... "
            Result := tregChars1_
          end;   //no hay otra opción
          exit;
        end;
      end;
      str += tmp;   //agrega caracter
      lastAd := tmp;  //guarda el último caracter agregado
      tmp := ExtractCharN(exp);  //siguiente caracter
    end;
    //Si llega aquí es porque no encontró cuantificador ni lista (Caso 0)
    str := ReplaceEscape(str);
    if length(str) = 1 then begin  //verifica si tiene un caracter
      listChars := str;       //'['+str+']'
      Result := tregChars;   //devuelve como lista de un caracter
      exit;
    end;
    Result := tregString;
  end;
end;

{ tFaTokContent }
procedure tFaTokContent.Clear;
begin
  nInstruc := 0;
  setLength(Instrucs,0);
end;
function tFaTokContent.AddItem(expTyp: tFaRegExpType; ifMatch, ifFail: string): integer;
//Agrega un ítem a la lista Instrucs[]. Devuelve el número de ítems.
//Configura el comportamiento de la instrucciómn usando "ifMatch".
var
  ifMatch0, ifFail0: string;

  function extractIns(var txt: string): string;
  //Extrae una instrucción (identificador)
  var
    p: Integer;
  begin
    txt := trim(txt);
    if txt = '' then exit('');
    p := 1;
    while (p<=length(txt)) and (txt[p] in ['A'..'Z']) do inc(p);
    Result := copy(txt,1,p-1);
    txt := copyEx(txt, p);
//    Result := copy(txt,1,p);
//    txt := copyEx(txt, p+1);
  end;
  function extractPar(var txt: string; var hasSign: boolean; errMsg: string): integer;
  //Extrae un valor numérico
  var
    p, p0: Integer;
    sign: Integer;
  begin
    txt := trim(txt);
    if txt = '' then exit(0);
    if txt[1] = '(' then begin
      //caso esperado
      hasSign := false;
      p := 2;  //explora
      if not (txt[2] in ['+','-','0'..'9']) then  //validación
        raise ESynFacilSyn.Create(errMsg + ifFail0);
      if txt[2] = '+' then begin
        hasSign := true;
        p := 3;  //siguiente caracter
        sign := 1;
        if not (txt[3] in ['0'..'9']) then
          raise ESynFacilSyn.Create(errMsg + ifFail0);
      end;
      if txt[2] = '-' then begin
        hasSign := true;
        p := 3;  //siguiente caracter
        sign := -1;
        if not (txt[3] in ['0'..'9']) then
          raise ESynFacilSyn.Create(errMsg + ifFail0);
      end;
      //Aquí se sabe que en txt[p], viene un númaro
      p0 := p;   //guarda posición de inicio
      while (p<=length(txt)) and (txt[p] in ['0'..'9']) do inc(p);
      Result := StrToInt(copy(txt,p0,p-p0)) * Sign;  //lee como número
      if txt[p]<>')' then raise ESynFacilSyn.Create(errMsg + ifFail0);
      inc(p);
      txt := copyEx(txt, p+1);
    end else begin
      raise ESynFacilSyn.Create(errMsg + ifFail0);
    end;
  end;
  function HavePar(var txt: string): boolean;
  //Verifica si la cadena empieza con "("
  var
    p, p0: Integer;
    sign: Integer;
  begin
    Result := false;
    txt := trim(txt);
    if txt = '' then exit;
    if txt[1] = '(' then begin   //caso esperado
      Result := true;
    end;
  end;

var
  inst: String;
  hasSign: boolean;
  n: Integer;
begin
  ifFail0 := ifMatch;  //guarda valor original
  ifFail0 := ifFail;    //guarda valor original
  inc(nInstruc);
  n := nInstruc-1;  //último índice
  setlength(Instrucs, nInstruc);
  Instrucs[n].expTyp := expTyp;    //tipo
  Instrucs[n].actionMatch := aomNext;  //valor por defecto
  Instrucs[n].actionFail  := aomExit; //valor por defecto
  Instrucs[n].destOnMatch:=0;         //valor por defecto
  Instrucs[n].destOnFail:= 0;         //valor por defecto
  Result := nInstruc;
  //Configura comportamiento
  if ifMatch<>'' then begin
    ifMatch := UpCase(ifMatch);
    while ifMatch<>'' do begin
      inst := extractIns(ifMatch);
      if inst = 'NEXT' then begin  //se pide avanzar al siguiente
        Instrucs[n].actionMatch := aomNext;
      end else if inst = 'EXIT' then begin  //se pide salir
        if HavePar(ifMatch) then begin  //EXIT con parámetro
          Instrucs[n].actionMatch := aomExitpar;
          Instrucs[n].destOnMatch := n + extractPar(ifMatch, hasSign, ERR_SYN_PAR_IFMATCH_);
        end else begin   //EXIT sin parámetros
          Instrucs[n].actionMatch := aomExit;
        end;
      end else if inst = 'MOVE' then begin
        Instrucs[n].actionMatch := aomMovePar;  //Mover a una posición
        Instrucs[n].destOnMatch := n + extractPar(ifMatch, hasSign, ERR_SYN_PAR_IFMATCH_);
      end else begin
        raise ESynFacilSyn.Create(ERR_SYN_PAR_IFMATCH_ + ifMatch0);
      end;
      ifMatch := Trim(ifMatch);
      if (ifMatch<>'') and (ifMatch[1] = ';') then  //quita delimitador
        ifMatch := copyEx(ifMatch,2);
    end;
  end;
  if ifFail<>'' then begin
    ifFail := UpCase(ifFail);
    while ifFail<>'' do begin
      inst := extractIns(ifFail);
      if inst = 'NEXT' then begin  //se pide avanzar al siguiente
        Instrucs[n].actionFail := aomNext;
      end else if inst = 'EXIT' then begin  //se pide salir
        if HavePar(ifFail) then begin  //EXIT con parámetro
          Instrucs[n].actionFail := aomExitpar;
          Instrucs[n].destOnFail := n + extractPar(ifFail, hasSign, ERR_SYN_PAR_IFFAIL_);
        end else begin   //EXIT sin parámetros
          Instrucs[n].actionFail := aomExit;
        end;
      end else if inst = 'MOVE' then begin
        Instrucs[n].actionFail := aomMovePar;  //Mover a una posición
        Instrucs[n].destOnFail := n + extractPar(ifFail, hasSign, ERR_SYN_PAR_IFFAIL_);
      end else begin
        raise ESynFacilSyn.Create(ERR_SYN_PAR_IFFAIL_ + ifFail0);
      end;
      ifFail := Trim(ifFail);
      if (ifFail<>'') and (ifFail[1] = ';') then  //quita delimitador
        ifFail := copyEx(ifFail,2);
    end;
  end;
end;
procedure tFaTokContent.AddOneInstruct(var exp: string; ifFalse: string = 'exit';
  TokTyp0: TSynHighlighterAttributes=nil);
var
  list: String;
  str: string;
  n: Integer;
  c: Char;
  expr: string;
  t: tFaRegExpType;
begin
  if exp='' then exit;
  //analiza
  expr := exp;   //guarda, porque se va a trozar
  t := ExtractRegExp(exp, str, list);
  case t of
  tregChars,    //Es de tipo lista de caracteres [...]
  tregChars01,  //Es de tipo lista de caracteres [...]?
  tregChars0_,  //Es de tipo lista de caracteres [...]*
  tregChars1_:  //Es de tipo lista de caracteres [...]+
    begin
      n := AddItem(t, '', ifFalse)-1;  //agrega
      Instrucs[n].TokTyp := TokTyp0;
      //Configura caracteres de contenido
      for c := #0 to #255 do Instrucs[n].Chars[c] := False;
      for c in list do Instrucs[n].Chars[c] := True;
    end;
  tregString: begin      //Es de tipo texto literal
      n := AddItem(t, '', ifFalse)-1;  //agrega
      Instrucs[n].TokTyp := TokTyp0;
      Instrucs[n].Text := str;
    end;
  else
    raise ESynFacilSyn.Create(ERR_UNSUPPOR_EXP_ + expr);
  end;
end;
procedure tFaTokContent.AddInstruct(exp: string; ifFalse: string = 'exit';
  TokTyp0: TSynHighlighterAttributes=nil);
//Agrega una instrucción para el procesamiento del token pro contenido.
//Solo se dbe indicar una instrucción, de otra forma se generará un error.
var
  expr: String;
begin
  expr := exp;   //guarda, porque se va a trozar
  AddOneInstruct(exp);
  //Si llegó aquí es porque se leyó obtuvo una expresión válida, pero la
  //expresión continua.
  if exp<>'' then begin
    raise ESynFacilSyn.Create(ERR_UNSUPPOR_EXP_ + expr);
  end;
end;
procedure tFaTokContent.AddRegEx(exp: string);
{Agrega una expresión regular (un conjunto de instrucciones sin opciones de control), al
token por contenido. Las expresiones regulares deben ser solo las soportadas.
Ejemplos son:  "[0..9]*[\.][0..9]", "[A..Za..z]*"
Las expresiones se evalúan parte por parte. Si un token no coincide completamente con la
expresión regular, se considera al token, solamente hasta el punto en que coincide.
Si se produce algún error se generará una excepción.}
begin
  while exp<>'' do begin
    AddOneInstruct(exp);  //en principio, siempre debe coger una expresión
  end;
end;

var
  i: integer;
initialization
  //prepara definición de comodines
  bajos[0] := #127;
  for i:=1 to 127 do bajos[i] := chr(i);  //todo menos #0
  altos[0] := #128;
  for i:=1 to 128 do altos[i] := chr(i+127);

end.

