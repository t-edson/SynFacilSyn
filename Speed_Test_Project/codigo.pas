{
Código de prueba para probar el resaltador programable usando código Pascal.
Este código no es funcional.
Test code for testing the Scriptale Highlighter on a Pascal code.

                                      Por Tito Hinostroza  29/12/2013 - Lima Perú
}
unit SynHighlighterFile;
{$mode objfpc}{$H+}
interface
uses
  Classes, Graphics; 'cadena' 1234567789
  #32 $123
type
  TRangeState = (rsUnknown,
                 rsCommentSym,   //comentario terminado en delimitador Símbolo
                 rsStringIden);  //cadena terminada en delimitador identificador
  TProcTableProc = procedure of object;   {Tipo de procedimiento para procesar el token de
                                           acuerdo al caracter inicial.}
  //categoría de delimitador final;
  TCatEnd   =  (cEndIden,  //delimitador final es identificador
                cEndSym,   //delimitador final es símbolo
                cEndSym1); //delimitador final es símbolo de un caracter.

  //Descripción de identificador y/o delimitador
  TdelInfo = record
    cad      : string;         //palabra clave
    delBlock : TdelimBlock;    //indica si es delimitador
    dStart,dEnd: string;       //delimitador complementario(en caso de que sea delimitador)
    tTok     : TtkTokenKind;   //tipo de token
    tFol     : TdelFoldingKind; //indica si es delimitador para plegado.
    CatEnd   : TCatEnd;        //categoría de delimitador final;
  end;
  TArrayDelimInfo = array of TdelInfo;

  { TSynBlock }

  TSynBlock = class  //clase para manejar la definición de tokens o bloques de sintaxis
    dStart, dEnd: string;         //delimitadores
    tipBlock    : TBlockKind;
    havFolding  : boolean;        //indica si posee plegado de código
    tokKind     : TtkTokenKind;   //el tipo de token, en caso de que sea de un solo token.
    function IsString1   : boolean;  //Indica si es de tipo cadena de una sola línea
    function IsComment1  : boolean;  //Indica si es de tipo comentario de una sola línea
    function IsUniTok1   : boolean;  //Indica si es de tipo unitoken de una sola línea
    function SameDelims  : boolean;  //Indica si los delimitadores son iguales
    function SameDelims1 : boolean;  //Indica si los delimitadores son iguales y de un caracter
  end;
  TLisBlocks = specialize TFPGObjectList<TSynBlock>;   //lista de bloques

  { TSynFileSyn }

  TSynFileSyn = class(TSynCustomHighlighter)
  private
    fLine      : PChar;         //puntero a línea de trabajo
    tamLin     : integer;       //tamaño de línea actual
    fProcTable : array[#0..#255] of TProcTableProc;   //tabla de procedimientos
    posIni  : Integer;          //índice a inicio de token
    posFin     : LongInt;       //índice a siguiente token
    fStringLen : Integer;       //Tamaño del token actual
    fToIdent   : PChar;         //Puntero a identificador
    fTokenID   : TtkTokenKind;  //Id del token actual
    fRange     : TRangeState;   //para trabajar con comentarios y cadenas multilíneas
    //matrices para guardar las palabras claves
    mA, mB, mC, mD, mE, mF, mG, mH, mI, mJ, mK, mL, mM,  //para mayúsculas
    mN, mO, mP, mQ, mR, mS, mT, mU, mV, mW, mX, mY, mZ,
    mA_, mB_, mC_, mD_, mE_, mF_, mG_, mH_, mI_, mJ_, mK_, mL_, mM_, //para minúsculas
    mN_, mO_, mP_, mQ_, mR_, mS_, mT_, mU_, mV_, mW_, mX_, mY_, mZ_,
    m_, mDol, mArr, mPer, mAmp : TArrayDelimInfo;
    mSym        :  TArrayDelimInfo;   //matriz de símbolos (delimitadores)
    TabMayusc   : array[#0..#255] of Char;     //Tabla para conversiones rápidas a mayúscula
    CharsIdentif: array[#0..#255] of ByteBool;  //caracteres válidos para identificadores
    CharsNumber : array[#0..#255] of ByteBool;  //caracteres válidos para números
    catTokCon1  : TtkTokenKind;   //categoría de token por contenido 1
    CharsToken1 : array[#0..#255] of ByteBool;  //caracteres válidos para token por contenido 1
    catTokCon2  : TtkTokenKind;   //categoría de token por contenido 2
    CharsToken2 : array[#0..#255] of ByteBool;  //caracteres válidos para token por contenido 2
//    CharsToken1 : array[#0..#255] of ByteBool;  //caracteres válidos para tokens por contenido
    Err         : string;         //mensaje de error
    lisBlocks   : TLisBlocks;     //lista de bloques de sintaxis
    car_ini_iden: Set of char;   //caracteres iniciales de identificador
    delBlk      : string;        //delimitador del bloque actual
    //define los atributos para "tokens"
    fIdentifAttri  : TSynHighlighterAttributes;
    fKeywordAttri  : TSynHighlighterAttributes;
    fDirectiveAttri: TSynHighlighterAttributes;
    fVariableAttri : TSynHighlighterAttributes;
    fNumberAttri   : TSynHighlighterAttributes;
    fSpaceAttri    : TSynHighlighterAttributes;
    fStringAttri   : TSynHighlighterAttributes;
    fCommentAttri  : TSynHighlighterAttributes;
    function KeyComp(const aKey: String): Boolean;
    procedure ProcBlockEndSym(delim: string);
    procedure ProcBlockEndIdent(delim: string);
    procedure ProcComment1;
    procedure ProcSimbDel;
    procedure ProcIdent(var mat: TArrayDelimInfo);
    //Funciones de procesamiento de otros elementos
    procedure ProcNumber;
    procedure ProcNull;
    procedure ProcSpace;
    procedure ProcSymbol;
  public
    procedure SetLine(const NewValue: String; LineNumber: Integer); override;
    procedure Next; override;
    function  GetEol: Boolean; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer); override;
    function  GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetToken: String; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public
    CaseSensitive: boolean;
    procedure LoadFromFile(Arc: string);         //Para cargar sintaxis
  end;

implementation

{ TSynBlock }

function TSynBlock.IsString1: boolean; //indica si es bloque cadena de una sola línea
begin
  Result := (tipBlock = bkString1);
end;
function TSynBlock.IsComment1: boolean;
begin
  Result := (tipBlock = bkComment1);
end;
function TSynBlock.IsUniTok1: boolean;
begin
  Result := (tipBlock = bkUnitok1);
end;
function TSynBlock.SameDelims: boolean;     //Indica si los delimitadores son Iguales
begin
  Result := (dStart = dEnd);
end;
function TSynBlock.SameDelims1: boolean;
begin
  Result := (dStart = dEnd) and (length(dStart) = 1);
end;

{ TSynFileSyn }

//funciones de bajo nivel
procedure TSynFileSyn.ClearSpecials;
//Limpia la lista de identificadores especiales y de símbolos delimitadores.
begin
  //ídentificadores
  SetLength(mA,0); SetLength(mB,0); SetLength(mC,0); SetLength(mD,0);
  SetLength(mE,0); SetLength(mF,0); SetLength(mG,0); SetLength(mH,0);
  SetLength(mI,0); SetLength(mJ,0); SetLength(mK,0); SetLength(mL,0);
  SetLength(mM,0); SetLength(mN,0); SetLength(mO,0); SetLength(mP,0);
  SetLength(mQ,0); SetLength(mR,0); SetLength(mS,0); SetLength(mT,0);
  SetLength(mU,0); SetLength(mV,0); SetLength(mW,0); SetLength(mX,0);
  SetLength(mY,0); SetLength(mZ,0);
  SetLength(m_,0); SetLength(mDol,0); SetLength(mArr,0);
  SetLength(mPer,0); SetLength(mAmp,0);
  //símbolos
  SetLength(mSym,0);
end;
function TSynFileSyn.HayEnMatInfo(var mat: TArrayDelimInfo; cad: string; var n: integer): boolean;
//busca una cadena en una matriz TArrayDelimInfo. Si la ubica devuelve el índice en "n".
//Ignora el primer caracter, porque se supone que se está usando la matriz apropiada.
var i : integer;
//    tmp : string;
begin
  Result := false;
//  tmp := copy(cad,2, length(cad));
  for i := 0 to High(mat) do
    if mat[i].cad = cad then begin
      n:= i; exit(true);
    end
end;
procedure TSynFileSyn.ValidAsigDelim(delAct, delNue: TdelimBlock; delim: string);
//Verifica si la asignación de delimitadores es válida. Si no lo es devuelve error.
begin
  if delAct = dbNull then  exit;  //No estaba inicializado, es totalente factible
  //Ya tiene un valor, hay que verificar
  //valida asignación de delimitador de cadena
  if (delAct in  [dbStr1Start, dbStrNStart, dbStrNBoth, dbStr1Both]) and
     (delNue = dbStr1Start) then begin
    Err := 'Identificador "' + delim + '" ya es delimitador inicial de cadena.';
    exit;
  end;
  if (delAct in  [dbStr1End, dbStrNEnd, dbStrNBoth, dbStr1Both]) and
     (delNue = dbStr1End) then begin
    Err := 'Identificador "' + delim + '" ya es delimitador final de cadena.';
    exit;
  end;
  //valida asignación de delimitador de comentario
  if (delAct in  [dbCom1Start, dbComNStart, dbComNBoth, dbCom1Both]) and
     (delNue = dbCom1Start) then begin
    Err := 'Identificador "' + delim + '" ya es delimitador inicial de comentario.';
    exit;
  end;
  if (delAct in  [dbCom1End, dbComNEnd, dbComNBoth, dbCom1Both]) and
     (delNue = dbCom1End) then begin
    Err := 'Identificador "' + delim + '" ya es delimitador final de comentario.';
    exit;
  end;
end;
procedure TSynFileSyn.ActCatEndDelim(var r: TdelInfo);
//categoriza el tipo de delimitador final de un delimitador
begin
  if r.dEnd = '' then exit;
  if r.dEnd[1] in car_ini_iden then  //es identificador
    r.CatEnd:=cEndIden
  else begin  //es símbolo
    if length(r.dEnd) = 1 then
       r.CatEnd:=cEndSym1  //símbolo de un caracter de ancho
    else
       r.CatEnd:=cEndSym;
  end;
end;
procedure TSynFileSyn.AgregaIdenTab(var mat: TArrayDelimInfo; r: TdelInfo; actualizar: boolean);
{Agrega un o modifica un identificador a la matriz indicada.
 Si "actualizar" = false: Se agrega el elemento, si ya existe, devuelve error.
 Si "actualizar" = true: Se actualizan los atributos del identificador, si no existe, se crea.}
var n : integer;
    tmp: string;
begin
  //protección
  if r.cad='' then begin  //no debertía pasar
    Err := 'Identificador vacío.';  exit;
  end;
  tmp := copy(r.cad,2,length(r.cad));  //quita la primera letra
  if not CaseSensitive then tmp:= UpCase(tmp);  //cambia caja si es necesario
  if actualizar then begin    ///////actualiza
    if HayEnMatInfo(mat,tmp, n) then begin  //ya existe
      //actualiza solo las propiedades NO NULL
      if r.delBlock<> dbNull then begin  //cambia atributo de delimitador
        ValidAsigDelim(mat[n].delBlock, r.delBlock, mat[n].cad);
        if Err <> '' then  exit;     //No es posible la asignación.
        mat[n].delBlock:=r.delBlock;  //asigna
      end;
      if r.dStart<> ''      then mat[n].dStart:=r.dStart;
      if r.dEnd  <> ''      then mat[n].dEnd:=r.dEnd;
      if r.tTok  <> tkNull  then mat[n].tTok:=r.tTok;
      if r.tFol  <> fdNull  then mat[n].tFol:=r.tFol;
      ActCatEndDelim(mat[n]);
    end else begin     //no existe
      //agrega
      n := High(mat)+1;
      SetLength(mat,n+1); //hace espacio
      mat[n] := r;        //copia con todas sus propiedades
      mat[n].cad:= tmp;   //coloca sin el primer caracter
      ActCatEndDelim(mat[n]);
    end;
  end else begin          ///////agrega
    if HayEnMatInfo(mat,tmp, n) then begin  //ya existe
      Err := 'Identificador duplicado: ' + r.cad; exit;
    end else begin     //no existe
      //agrega
      n := High(mat)+1;
      SetLength(mat,n+1); //hace espacio
      mat[n] := r;        //copia todo el registro
      mat[n].cad:= tmp;   //coloca sin el primer caracter
      ActCatEndDelim(mat[n]);
    end;
  end;
end;
procedure TSynFileSyn.AgregaSimbDel(cad, dStart, dEnd: string; fijDelBlk: TdelimBlock;
                   fijTok: TtkTokenKind; fijFol: TdelFoldingKind);
{Agrega un o modifica un delimitador en "mSym".
 Se actualizan los atributos del símbolo, si no existe, se crea.}
var
  n : integer;
begin
  Err := '';
  if HayEnMatInfo(mSym, cad, n) then begin  //ya existe
    //actualiza solo las propiedades NO NULL
    if fijDelBlk <> dbNull then begin  //cambia atributo de delimitador
      ValidAsigDelim(mSym[n].delBlock, fijDelBlk, mSym[n].cad);
      if Err <> '' then  exit;     //No es posible la asignación.
      mSym[n].delBlock:=fijDelBlk;  //asigna
    end;
    if dStart<> ''       then mSym[n].dStart:=dStart;
    if dEnd  <> ''       then mSym[n].dEnd:= dEnd;
    if fijTok  <> tkNull then mSym[n].tTok:= fijTok;
    if fijFol  <> fdNull then mSym[n].tFol:= fijFol;
    ActCatEndDelim(mSym[n]);
  end else begin     //no existe
    //agrega
    n := High(mSym)+1;    //lee tamaño
    SetLength(mSym,n+1);  //hace espacio
    //asigna propiedades
    mSym[n].cad:= cad;         //fija contenido
    mSym[n].delBlock := fijDelBlk; //copia tipo de delimitador
    mSym[n].dStart := dStart;
    mSym[n].dEnd := dEnd;
    mSym[n].tTok := fijTok;     //marca tipo de token
    mSym[n].tFol := fdNull;     //Sin folding
    ActCatEndDelim(mSym[n]);
  end;
end;
procedure TSynFileSyn.VerifDelim(delim: string);
//Verifica la validez de un delimitador para un token delimitado o bloque
var c:char;
begin
  //verifica contenido
  if delim = '' then begin
    Err:='Delimitador vacío: ' + delim;
    exit;
  end;
  //verifica si inicia con caracter de identificador.
  if  delim[1] in car_ini_iden then begin
    //empieza como identificador
    for c in delim do
      if not CharsIdentif[c] then begin
        Err:='Delimitador-identificador erróneo: ' + delim;
        exit;
      end;
  end;
end;
procedure TSynFileSyn.AddBlock(dStart, dEnd: string; tipBlock: TBlockKind;
                              havFolding: boolean; tokKind: TtkTokenKind);
{Función genérica para agregar un token delimitado o bloque a la sintaxis. Si encuentra
 error, sale con el mensaje en "Err"}
var blk: TSynBlock;
begin
  VerifDelim(dStart);
  if Err <> '' then exit;
  VerifDelim(dEnd);
  if Err <> '' then exit;

  blk:= TSynBlock.Create;

  blk.dStart:=dStart;
  blk.dEnd:=dEnd;

  blk.tipBlock := tipBlock;
  blk.havFolding:= havFolding;
  blk.tokKind:=tokKind;

  lisBlocks.Add(blk);  //agrega
end;
//funciones de más alto nivel
procedure TSynFileSyn.AddTokenString(dStart, dEnd: string; multiline, havFolding: boolean);
//Función pública para agregar un token delimitado de tipo Cadena.
begin
  if multiline then
    AddBlock(dStart, dEnd, bkStringN, havFolding, tkString)
  else
    AddBlock(dStart, dEnd, bkString1, havFolding, tkString);
  //puede devolver error
end;
procedure TSynFileSyn.AddTokenComment(dStart, dEnd: string; havFolding: boolean);
//Función pública para agregar un token delimitado de tipo Comentario.
begin
  if (dEnd = '') or (dEnd = #13)  then begin  //comentario de una sola línea
    dEnd := #13;   //delimitador final
    AddBlock(dStart, dEnd, bkComment1, havFolding, tkComment);
  end else
    AddBlock(dStart, dEnd, bkCommentN, havFolding, tkComment);
  //puede devolver error
end;
procedure TSynFileSyn.AddIdentSpecEx(r: TdelInfo; actualizar: boolean);
{Punto de entrada único para agregar o modificar un identificador especial (Keyword,
 variable, constant, etc)}
var iden: string;
begin
  Err := '';
  iden := r.cad;
  if iden = '' then begin
    Err := 'Identificador vacío.';
    exit;
  end;
  if CaseSensitive then begin //sensible a la caja
    case iden[1] of
    'A': AgregaIdenTab(mA, r, actualizar);
    //minúsculas
    'a': AgregaIdenTab(mA_, r, actualizar);
    //adicionales
    '_': AgregaIdenTab(m_, r, actualizar);
    '$': AgregaIdenTab(mDol, r, actualizar);
    '@': AgregaIdenTab(mArr, r, actualizar);
    '%': AgregaIdenTab(mPer, r, actualizar);
    '&': AgregaIdenTab(mAmp, r, actualizar);
    end;
  end else begin  //no es sensible a la caja
    case UpCase(iden[1]) of
    'A': AgregaIdenTab(mA, r, actualizar);
    '_': AgregaIdenTab(m_, r, actualizar);
    '$': AgregaIdenTab(mDol, r, actualizar);
    '@': AgregaIdenTab(mArr, r, actualizar);
    '%': AgregaIdenTab(mPer, r, actualizar);
    '&': AgregaIdenTab(mAmp, r, actualizar);
    end;
  end;
  //puede salir con error
end;
procedure TSynFileSyn.AddIdentSpec(iden: string; catTok: TtkTokenKind);
//Método público para agregar un identificador especial cualquiera.
var r: TdelInfo;
begin
  if iden = '' then begin
    Err := 'Identificador vacío'; exit;
  end;
  r.cad := trim(iden);
  r.delBlock:=dbNull;
  r.dStart:='';
  r.dEnd:='';
  r.tTok:=catTok;   //marca como keyword
  r.tFol:=fdNull;
  AddIdentSpecEx(r,false);
  //puede salir con error
end;
procedure TSynFileSyn.AddKeyword(iden: string);
//Método público que agrega un identificador "Keyword" a la sintaxis
begin
  AddIdentSpec(iden, tkKeyword);
end;
procedure TSynFileSyn.AddDirective(iden: string);
//Método público que agrega un identificador "Directive" a la sintaxis
begin
  AddIdentSpec(iden, tkDirective);
end;
procedure TSynFileSyn.AddVariable(iden: string);
//Método público que agrega un identificador "Variable" a la sintaxis
begin
  AddIdentSpec(iden, tkVariable);
end;
procedure OrdenarMatSim(var a:TArrayDelimInfo);
//ordena una matriz "TArrayDelimInfo" pro el tamaño de "cad".
var
  i,j,maximo: integer;
  aux: TdelInfo;
begin
  maximo := High(a);
  for i:=0 to maximo-1 do
    for j:=i+1 to maximo do begin
      if (length(a[i].cad) < length(a[j].cad)) then begin
        aux:=a[i];
        a[i]:=a[j];
        a[j]:=aux;
      end;
    end;
end;
constructor TSynFileSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ClearSpecials;        //Inicia matrices
  CaseSensitive := false;
  (* Crea atributos. Los atributos son como categorías de palabras. El nombre que se
  le da no es importante.*)
  //Atributo para todos los identificadores.
  fIdentifAttri := TSynHighlighterAttributes.Create('Identifier');
  AddAttribute(fIdentifAttri);
  fIdentifAttri := nil;
  //atribuuto de palabras claves
  fKeywordAttri := TSynHighlighterAttributes.Create('Key');
  fKeywordAttri.Style := [fsBold];
  fKeywordAttri.Foreground:=clGreen;
  AddAttribute(fKeywordAttri);
  //atributo de directiva
  fDirectiveAttri := TSynHighlighterAttributes.Create('Directive');
  fDirectiveAttri.Foreground := clRed;
  AddAttribute(fDirectiveAttri);
  //atributo de variable
  fVariableAttri := TSynHighlighterAttributes.Create('Variable');
  AddAttribute(fVariableAttri);
  //atributo de comentarios
  fCommentAttri := TSynHighlighterAttributes.Create('Comment');
  fCommentAttri.Style := [fsItalic];
  fCommentAttri.Foreground := clGray;
  AddAttribute(fCommentAttri);
  //atributo de números
  fNumberAttri := TSynHighlighterAttributes.Create('Number');
  AddAttribute(fNumberAttri);
  fNumberAttri.Foreground := clFuchsia;
  //atributo de espacios. Sin atributos
  fSpaceAttri := TSynHighlighterAttributes.Create('space');
  AddAttribute(fSpaceAttri);
  //atributo de cadenas
  fStringAttri := TSynHighlighterAttributes.Create('String');
  fStringAttri.Foreground := clBlue;
  AddAttribute(fStringAttri);
  //atributo de símbolos
  fSymbolAttri := TSynHighlighterAttributes.Create('Symbol');
  AddAttribute(fSymbolAttri);
  //atributo de etiqueta
  fLabelAttri := TSynHighlighterAttributes.Create('Label');
  AddAttribute(fLabelAttri);
  //atributo de ensamblador
  fAsmAttri := TSynHighlighterAttributes.Create('Asm');
  AddAttribute(fAsmAttri);
  //atributo extra 1
  fExtra1Attri := TSynHighlighterAttributes.Create('Extra1');
  AddAttribute(fExtra1Attri);
  //atributo extra 2
  fExtra2Attri := TSynHighlighterAttributes.Create('Extra2');
  AddAttribute(fExtra2Attri);

  fRange := rsUnknown;   //inicia rango
  lisBlocks:=TLisBlocks.Create(true);  //crea lista de bloques con control

  ClearMethodTables;   //Crea tabla de funciones
  DefCharsIniIden('A..Za..z$_');
  DefCharsConIden('A..Za..z0123456789_');
  DefCharsIniNumb('0..9');
  DefCharsConNumb('0..9');
end;
destructor TSynFileSyn.Destroy;
begin
  lisBlocks.Free;            //libera
  //no es necesario destruir los attrributos, porque  la clase ya lo hace
  inherited Destroy;
end;
function TSynFileSyn.KeyComp(const aKey: String): Boolean; inline;
{Compara rápidamente una cadena con el token actual, apuntado por "fToIden".
 El tamaño del token debe estar en "fStringLen"}
var
  i: Integer;
  Temp: PChar;
begin
  Temp := fToIdent;
  if Length(aKey) = fStringLen then begin  //primera comparación
    Result := True;
    for i := 1 to fStringLen do begin
      if TabMayusc[Temp^] <> aKey[i] then //aKey[i] está en mayúscula
      begin
        Result := False;
        break;
      end;
      inc(Temp);
    end;
  end else  //definitívamente es diferente
    Result := False;
end;
//*************** procesamiento de tokens por contenido ********************
function ValidarCaracteres(var cars: string): boolean;
//Valida un conjunto de caracteres para ser usado en la definición de tokens por contenido
//Si hay error sale con TRUE
begin
  Result := false;
  if cars = '' then exit(true);   //validación
  cars := StringReplace(cars, 'A..Z', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',[rfReplaceAll]);
  cars := StringReplace(cars, 'a..z', 'abcdefghijklmnopqrstuvwxyz',[rfReplaceAll]);
  cars := StringReplace(cars, '0..9', '0123456789',[rfReplaceAll]);
  //podría actualizar la variable "Err"
end;
procedure TSynFileSyn.DefCharsIniIden(cars: string);
//Define los caracteres iniciales para identificadores. Solo se permiten "A-Za-z_$@%&"
//Se debe haber limpiado previamente con "ClearMethodTables"
var ingresado: boolean;
    c: char;
begin
  if ValidarCaracteres(cars) then exit;   //validación
  //agrega evento manejador
  car_ini_iden := [];  //inicia
  if CaseSensitive then  //sensible a la caja
    for c in cars do begin
      ingresado := true;
      case c of   //Aquí se definen los caracteres que son válidos
        'A': fProcTable[c] := @ProcA;
        '_'    : fProcTable[c] := @ProcUnder;
        '$'    : fProcTable[c] := @ProcDol;
        '@'    : fProcTable[c] := @ProcArr;
        '%'    : fProcTable[c] := @ProcPer;
        '&'    : fProcTable[c] := @ProcAmp;
      else begin
            //genera error pero no detiene ejecución
            Err := 'Caracter no válido como inicio de identificador: ' + c ;
            ingresado := false;
           end;
      end;
      if ingresado then car_ini_iden += [c];  //agrega
      //los caracteres no asignados, serán procesados por @ProcSymbol
    end
  else  //no es sensible a la caja
    for c in cars do begin
      ingresado := true;
      case c of   //Aquí se definen los caracteres que son válidos
        'A','a': fProcTable[c] := @ProcA;
        'B','b': fProcTable[c] := @ProcB;
        'C','c': fProcTable[c] := @ProcC;
        '_'    : fProcTable[c] := @ProcUnder;
        '$'    : fProcTable[c] := @ProcDol;
        '@'    : fProcTable[c] := @ProcArr;
        '%'    : fProcTable[c] := @ProcPer;
        '&'    : fProcTable[c] := @ProcAmp;
      else begin
            //genera error pero no detiene ejecución
            Err := 'Caracter no válido como inicio de identificador: ' + c ;
            ingresado := false;
           end;
      end;
      if ingresado then car_ini_iden += [c];  //agrega
      //los caracteres no asignados, serán procesados por @ProcSymbol
    end;
end;
procedure TSynFileSyn.DefCharsConIden(cars: string);
{Crea tabla para identificar rápidamente los caracteres de un identificador, sin considerar
 el caracter inicial.}
var c: Char;
begin
  if ValidarCaracteres(cars) then exit;   //validación
  //limpia matriz
  for c := #0 to #255 do begin
    CharsIdentif[c] := False;
    //aprovecha para crear la tabla de mayúsculas para comparaciones
    if CaseSensitive then TabMayusc[c] := c else TabMayusc[c] := UpCase(c);
  end;
  //marca las posiciones apropiadas
  for c in cars do CharsIdentif[c] := True;
end;
procedure TSynFileSyn.DefCharsIniNumb(cars: string);
//define los caracteres iniciales para números.
//Se debe haber limpiado previamente con "ClearMethodTables"
var c: char;
begin
  if ValidarCaracteres(cars) then exit;   //validación
  //agrega evento manejador
  for c in cars do fProcTable[c] := @ProcNumber;
  //los caracteres no asignados, serán procesados por @ProcSymbol
end;
procedure TSynFileSyn.DefCharsConNumb(cars: string);
{Crea tabla para identificar rápidamente los caracteres de un identificador, sin considerar el
 caracter inicial.}
var
  c: Char;
begin
  if ValidarCaracteres(cars) then exit;   //validación
  //limpia matriz
  for c := #0 to #255 do CharsNumber[c] := False;
  //marca las posiciones apropiadas
  for c in cars do CharsNumber[c] := True;
end;
procedure TSynFileSyn.DefCharsIniTok1(cars: string; tipBlock: TtkTokenKind);
//Define los caracteres iniciales para tokens por contenido 1.
//Se debe haber limpiado previamente con "ClearMethodTables"
var c: char;
begin
  catTokCon1:= tipBlock;  //fija categoría de token
  if ValidarCaracteres(cars) then exit;   //validación
  //agrega evento manejador
  for c in cars do fProcTable[c] := @ProcTokCont1;
  //los caracteres no asignados, serán procesados por @ProcSymbol
end;
procedure TSynFileSyn.DefCharsConTok1(cars: string);
{Crea tabla para identificar rápidamente los caracteres de un identificador, sin considerar el
 caracter inicial.}
var
  c: Char;
begin
  if ValidarCaracteres(cars) then exit;   //validación
  //limpia matriz
  for c := #0 to #255 do CharsToken1[c] := False;
  //marca las posiciones apropiadas
  for c in cars do CharsToken1[c] := True;
end;
procedure TSynFileSyn.DefCharsIniTok2(cars: string; tipBlock: TtkTokenKind);
//Define los caracteres iniciales para tokens por contenido 1.
//Se debe haber limpiado previamente con "ClearMethodTables"
var c: char;
begin
  catTokCon2:= tipBlock;  //fija categoría de token
  if ValidarCaracteres(cars) then exit;   //validación
  //agrega evento manejador
  for c in cars do fProcTable[c] := @ProcTokCont2;
  //los caracteres no asignados, serán procesados por @ProcSymbol
end;
procedure TSynFileSyn.DefCharsConTok2(cars: string);
{Crea tabla para identificar rápidamente los caracteres de un identificador, sin considerar el
 caracter inicial.}
var
  c: Char;
begin
  if ValidarCaracteres(cars) then exit;   //validación
  //limpia matriz
  for c := #0 to #255 do CharsToken2[c] := False;
  //marca las posiciones apropiadas
  for c in cars do CharsToken2[c] := True;
end;
procedure TSynFileSyn.ClearMethodTables;
{Construye la tabla de las funciones usadas para cada caracter inicial del tóken a procesar.
 Proporciona una forma rápida de identificar el caracter inicial de un token.}
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      //caracteres usados para identificadores y números
      'A'..'Z': fProcTable[I] := @ProcSymbol;
      'a'..'z': fProcTable[I] := @ProcSymbol;
      '0'..'9': fProcTable[I] := @ProcSymbol;
      //caracteres blancos, son fijos
      #1..#32 : fProcTable[I] := @ProcSpace;
      //fin de línea
      #0      : fProcTable[I] := @ProcNull;   //Se lee el caracter de marca de fin de cadena
      else
        fProcTable[I] := @ProcSymbol;   //los otros
    end;
end;
procedure TSynFileSyn.ProcIdent(var mat: TArrayDelimInfo); //inline;
//Procesa el identificador actual con la matriz indicada
var i: integer;
begin
  repeat inc(posFin)
  until not CharsIdentif[fLine[posFin]];
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := Fline + posIni + 1;  //puntero al identificador + 1
  fTokenID := tkIdentif;  //identificador común
  for i := 0 to High(mat) do
    if KeyComp(mat[i].cad) then begin
      //verifica si es delimitador
      case mat[i].delBlock of
      dbNull: fTokenID := mat[i].tTok; //no es delimitador de ningún tipo, pone su atributo
      dbStr1Start: begin    //cadena de una línea
          fTokenID := tkString;   //asigna token
          case mat[i].CatEnd of  //busca la rutina apropiada para procesar
          cEndIden: ProcBlockEndIdent(mat[i].dEnd);
          cEndSym : ProcBlockEndSym(mat[i].dEnd);
          cEndSym1: ProcBlockEndSym(mat[i].dEnd);  //podría ser optimizado
          end;
        end;
      dbStrNStart: begin    //cadena multilínea
          fTokenID := tkString;
          delBlk := mat[i].dEnd;   //asigna delimitador de bloque
          case mat[i].CatEnd of  //busca la rutina apropiada para procesar
          cEndIden: begin fRange := rsStringIden; if posFin=tamLin then exit; ProcBlockNEndIden; end; //marca rango y procesa
          cEndSym : begin fRange := rsStringSym; if posFin=tamLin then exit; ProcBlockNEndSym; end; //marca rango y procesa
          cEndSym1: begin fRange := rsStringSym; if posFin=tamLin then exit; ProcBlockNEndSym; end; //marca rango y procesa
          end;
        end;
      dbCom1Start: ProcComment1;    //comentario de una línea
      dbComNStart: begin    //comentario multilínea
          fTokenID := tkComment;
          delBlk := mat[i].dEnd;   //asigna delimitador de bloque
          case mat[i].CatEnd of  //busca la rutina apropiada para procesar
          cEndIden: begin fRange := rsCommentIden; if posFin=tamLin then exit; ProcBlockNEndIden; end; //marca rango y procesa
          cEndSym : begin fRange := rsCommentSym; if posFin=tamLin then exit; ProcBlockNEndSym; end; //marca rango y procesa
          cEndSym1: begin fRange := rsCommentSym; if posFin=tamLin then exit; ProcBlockNEndSym; end; //marca rango y procesa
          end;
        end;
      dbUni1Start: begin  //bloque unitoken de una línea
          fTokenID := mat[i].tTok;   //asigna token
          delBlk := mat[i].dEnd;   //asigna delimitador de bloque
          case mat[i].CatEnd of  //busca la rutina apropiada para procesar
           cEndIden: ProcBlockEndIdent(mat[i].dEnd);
           cEndSym : ProcBlockEndSym(mat[i].dEnd);
           cEndSym1: ProcBlockEndSym(mat[i].dEnd);  //{ TODO : podría ser optimizado}
          end;
        end
      else
        fTokenID := mat[i].tTok; //no es delimitador, solo toma su atributo.
      end;
      exit;
    end;
end;
procedure TSynFileSyn.ProcSimbDel;
//Procesa un caracter que puede ser origen de un delimitador símbolo.
var i: integer;
  nCarDisp: Integer;
begin
  fTokenID := tkSymbol;  //identificador inicial por defecto
  //prepara para las comparaciones
  nCarDisp := tamLin-posIni;   //calcula caracteres disponibles hasta fin de línea
  fToIdent := Fline + posIni;  //puntero al identificador. Lo guarda para comparación
  //hay un nuevo posible delimitador. Se hace la búsqueda
  for i := 0 to High(mSym) do begin  //se empieza con los de mayor tamaño
    //fijamos nuevo tamaño para comaprar
    fStringLen := length(mSym[i].cad);  //suponemos que tenemos esta cantidad de caracteres
    if fStringLen > nCarDisp then continue;  //no hay suficientes, probar con el siguiente
    if KeyComp(mSym[i].cad) then begin
      inc(posFin,fStringLen);  //apunta al siguiente token
      //lo encontró, vemos sus atributos
      case mSym[i].delBlock of
      dbNull: fTokenID := mSym[i].tTok; //no es delimitador de ningún tipo, pone su atributo
      dbStr1Start: begin            //cadena de una línea
          fTokenID := tkString;   //asigna token
          case mSym[i].CatEnd of  //busca la rutina apropiada para procesar
           cEndIden: ProcBlockEndIdent(mSym[i].dEnd);
           cEndSym : ProcBlockEndSym(mSym[i].dEnd);
           cEndSym1: ProcBlockEndSym(mSym[i].dEnd);  //{ TODO : podría ser optimizado}
          end;
        end;
      dbStrNStart: begin    //cadena multilínea
          fTokenID := tkString;
          delBlk := mSym[i].dEnd;   //asigna delimitador de bloque
          case mSym[i].CatEnd of  //busca la rutina apropiada para procesar
          cEndIden: begin fRange := rsStringIden; if posFin=tamLin then exit; ProcBlockNEndIden; end; //marca rango y procesa
          cEndSym : begin fRange := rsStringSym;  if posFin=tamLin then exit; ProcBlockNEndSym; end; //marca rango y procesa
          cEndSym1: begin fRange := rsStringSym;  if posFin=tamLin then exit; ProcBlockNEndSym; end; //marca rango y procesa
          end;
        end;
      dbCom1Start: ProcComment1;  //comentario de una línea
      dbComNStart: begin  //comentario multilínea
          fTokenID := tkComment;
//            if FLine[posFin] = #0 then exit;  //sale para que se procese como otro token
          delBlk := mSym[i].dEnd;   //asigna delimitador de bloque
          case mSym[i].CatEnd of  //busca la rutina apropiada para procesar
          cEndIden: begin fRange := rsCommentIden; if posFin=tamLin then exit; ProcBlockNEndIden; end; //marca rango y procesa
          cEndSym : begin fRange := rsCommentSym;  if posFin=tamLin then exit; ProcBlockNEndSym; end; //marca rango y procesa
          cEndSym1: begin fRange := rsCommentSym;  if posFin=tamLin then exit; ProcBlockNEndSym; end; //marca rango y procesa
          end;
        end;
      dbUni1Start: begin  //bloque unitoken de una línea
          fTokenID := mSym[i].tTok;   //asigna token
          delBlk := mSym[i].dEnd;   //asigna delimitador de bloque
          case mSym[i].CatEnd of  //busca la rutina apropiada para procesar
           cEndIden: ProcBlockEndIdent(mSym[i].dEnd);
           cEndSym : ProcBlockEndSym(mSym[i].dEnd);
           cEndSym1: ProcBlockEndSym(mSym[i].dEnd);  //{ TODO : podría ser optimizado}
          end;
        end
      else
        fTokenID := mSym[i].tTok; //no debería pasar
      end;
      exit;   //sale con el atributo asignado
    end;
  end;
  {No se encontró coincidencia.
   Ahora debemos continuar la exploración al siguiente caracter}
  posFin := posIni + 1;  //a siguiente caracter, y deja el actual como: fTokenID := tkSymbol
end;
// ************** Caracteres que pueden ser inicio de identificador **************
procedure TSynFileSyn.ProcUnder;
begin ProcIdent(m_);
end;
// ******************** Procesamiento de caracteres de símbolos ********************//
procedure TSynFileSyn.ProcString1Del1;
//Procesa cadenas de una sola línea y con delimitadores iguales y de un solo caracter.
var d: char;
begin
  d := fLine[posFin];   //toma delimitador
  fTokenID := tkString;   //marca como cadena
  Inc(posFin);   {no hay peligro en incrmentar porque siempre se lla a "ProcString1Del1" con el
               carcater actual <> #0}
  while posFin <> tamLin do begin
    if fLine[posFin] = d then begin //busca fin de cadena
      Inc(posFin);
      if (fLine[posFin] <> d) then break;  //si no es doble caracter
    end;
    Inc(posFin);
  end;
end;
procedure TSynFileSyn.ProcComment1;
//Procesa comentarios de una sola línea.
begin
  fTokenID := tkComment;   //marca como comentario
  //mueve hasta fin de línea
  while posFin <> tamLin do   //debe verificar siempre desde la posición actual
    Inc(posFin);
end;
procedure TSynFileSyn.ProcBlockNEndSym;
{Procesa en medio de un bloque de varias líneas que tiene un delimitador de símbolo. El tipo de
 token, debe estar ya asignado.}
var p: PChar;
begin
  if posFin = tamLin then begin ProcNull; exit; end;
  //busca delimitador final
  p := strpos(fLine+posFin,PChar(delBlk));
  if p = nil then begin   //no se encuentra
     posFin := strEnd(fLine+posFin) - fLine;  //apunta al fin de línea
  end else begin  //encontró
     posFin := p + length(delBlk) - fLine;
     fRange := rsUnknown;
  end;
end;
procedure TSynFileSyn.ProcBlockEndSym(delim: string);
{Procesa bloques de un solo token, y de una sola línea. El delimitador final debe ser un
 símbolo. El tipo de token, debe estar ya asignado.}
var p: PChar;
begin
  p := strpos(fLine+posFin,PChar(delim));
  if p = nil then begin   //no se encuentra
     posFin := strEnd(fLine+posFin) - fLine;  //apunta al fin de línea
  end else begin  //encontró
     posFin := p + length(delim) - fLine;
  end;
end;
procedure TSynFileSyn.ProcNull;
//Procesa la ocurrencia del cacracter #0
begin
  fTokenID := tkNull;   //Solo necesita esto para indicar que se llegó al final de la línae
end;
procedure TSynFileSyn.ProcSpace;
//Procesa caracter que es inicio de espacio
begin
  fTokenID := tkSpace;
  repeat  //captura todos los que sean espacios
    Inc(posFin);
  until (fLine[posFin] > #32) or (posFin = tamLin);
end;
procedure TSynFileSyn.ProcSymbol;
begin
  inc(posFin);
  while (posFin<>tamLin) and (fProcTable[fLine[posFin]] = @ProcSymbol)
  do inc(posFin);
  fTokenID := tkSymbol;
end;
procedure TSynFileSyn.ProcNumber;
begin
  fTokenID := tkNumber;
  repeat inc(posFin);
  until not CharsNumber[fLine[posFin]];
end;
procedure TSynFileSyn.ProcTokCont1; //Procesa tokens por contenido 1
begin
  fTokenID := catTokCon1;   //pone categoría
  repeat inc(posFin);
  until not CharsToken1[fLine[posFin]];
end;
procedure TSynFileSyn.ProcTokCont2; //Procesa tokens por contenido 2
begin
  fTokenID := catTokCon2;   //pone categoría
  repeat inc(posFin);
  until not CharsToken2[fLine[posFin]];
end;
procedure TSynFileSyn.SetLine(const NewValue: String; LineNumber: Integer);
{Es llamado por el editor, cada vez que necesita actualizar la información de coloreado
 sobre una línea. Despues de llamar a esta función, se espera que GetTokenEx, devuelva
 el token actual. Y también después de cada llamada a "Next".}
begin
  inherited;
  fLine := PChar(NewValue); //solo copia la dirección para optimizar
  tamLin := length(NewValue);
  posFin := 0;  //apunta al primer caracter
  Next;
end;
procedure TSynFileSyn.Next;
{Es llamado por SynEdit, para acceder al siguiente Token. Y es ejecutado por cada token de la línea
 en curso.
 En nuestro caso "FTokenPos" debe quedar apuntando al inicio del token y "Run" debe
 quedar apuntando al inicio del siguiente token o al caracter NULL (fin de línea).}
begin
  posIni := posFin;   //apunta al primer elemento
  case fRange of
    rsCommentSym : begin fTokenID := tkComment; ProcBlockNEndSym; end;
    rsCommentIden: begin fTokenID := tkComment; ProcBlockNEndIden; end;
    rsStringSym  : begin fTokenID := tkString; ProcBlockNEndSym; end;
    rsStringIden : begin fTokenID := tkString; ProcBlockNEndIden; end;
  else
    begin
      fRange := rsUnknown;
      fProcTable[fLine[posFin]]; //Se ejecuta la función que corresponda.
    end;
  end;
end;
function TSynFileSyn.GetEol: Boolean;
begin
  Result := fTokenId = tkNull;
end;
procedure TSynFileSyn.GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
begin
  TokenLength := posFin - posIni;
  TokenStart := FLine + posIni;
end;
function TSynFileSyn.GetTokenAttribute: TSynHighlighterAttributes;
{Debe devolver el atributo para el token actual. El token actual se actualiza con cada llamada
 a "Next", (o a "SetLine", para el primer token de la línea.)
 Esta función es la que usa SynEdit para definir el atributo del token actual}
begin
  //las filas comentadas no se usan y tenerlas comentadas mejora la velocidad
  case fTokenID of
//    tkNull: Result := nil;
    tkIdentif: Result := fIdentifAttri;
    tkKeyword   : Result := fKeywordAttri;
    tkDirective: Result := fDirectiveAttri;
    tkVariable: Result := fVariableAttri;
    tkNumber: Result := fNumberAttri;
//    tkSpace : Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkComment: Result := fCommentAttri;
    else Result := nil;
  end;
end;
function TSynFileSyn.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
{Este método es llamado por la clase "TSynCustomHighlighter", cuando se accede a alguna de
 sus propiedades:  CommentAttribute, IdentifierAttribute, KeywordAttribute, StringAttribute,
 SymbolAttribute o WhitespaceAttribute.}
begin
  case Index of
    SYN_ATTR_COMMENT   : Result := fCommentAttri;
    SYN_ATTR_IDENTIFIER: Result := fIdentifAttri;
    SYN_ATTR_KEYWORD   : Result := fKeywordAttri;
    SYN_ATTR_WHITESPACE: Result := fSpaceAttri;
    SYN_ATTR_STRING    : Result := fStringAttri;
    SYN_ATTR_SYMBOL    : Result := fSymbolAttri;
    else Result := nil;
  end;
end;
{Las siguientes funciones, son usadas por SynEdit para el manejo de las llaves, corchetes,
 parentesis y comillas. No son cruciales para el coloreado de tokens, pero deben responder bien.}
function TSynFileSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := posFin - posIni;
  SetString(Result, (FLine + posIni), Len);
end;
function TSynFileSyn.GetTokenPos: Integer;
begin
  Result := posIni;
end;
function TSynFileSyn.GetTokenKind: integer;
begin
  Result := Ord(fTokenId);
end;

end.

