unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, SynEdit, SynEditHighlighter,
  SynHighlighterPHP, SynHighlighterPas, Lazlogger,
  SynFacilHighlighter;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ed1: TSynEdit;
    ed2: TSynEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ed1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ed1KeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure LoadSyntaxFile_hl1;
    procedure LoadTestFile(arch: string);
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}
//crea espacio para almacenar token
var hlt1 : TSynFacilSyn;
    hlt2 : TSynPasSyn;  //tSynPHPSyn;
    lineas : TStringList;
    t1, t2 : TDateTime;
    q: PChar = '                                                ';

procedure ExplorarArchivo(lineas: TStringList; hlt: TSynCustomHighlighter);
//Explora un archivo usando el resaltador indicado.
var
  p: PChar;
  tam: integer;
  lin : string;
begin
  for lin in lineas do begin
    //debug.OutPut(lin);
    hlt.SetLine(lin,1);
    while not hlt.GetEol do begin
      hlt.Next;
      hlt.GetTokenEx(p,tam);
//strlcopy(q,p,tam);  //copia token
//      debug.OutPut(q);
      hlt.GetTokenAttribute;
    end;
  end;
end;
{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  lineas := TStringList.Create;
  //configure highlighters
  hlt1 := TSynFacilSyn.Create(self);  //my highlighter
  ed1.Highlighter := hlt1;
  LoadSyntaxFile_hl1;
//  hlt1.KeywordAttribute.Background:=clGreen;
//  hlt1.KeywordAttribute.Foreground:=clYellow;
//  hlt1.StringAttribute.Background:=clRed;
{
  hlt1.ClearMethodTables;          //limpìa tabla de métodos
  //crea tokens por contenido
  hlt1.DefTokIdentif('$A..Za..z_', 'A..Za..z0..9_');
  hlt1.DefTokContent('0..9.', '0..9xabcdefXABCDEF', '', tkNumber);
  //define palabras claves
  hlt1.ClearSpecials;
  hlt1.AddIdentSpec('__file__',tkKeyword);
  hlt1.AddIdentSpec('__line__',tkKeyword);
  hlt1.AddIdentSpec('array',tkKeyword);
  hlt1.AddIdentSpec('and',tkKeyword);
  hlt1.AddIdentSpec('break',tkKeyword);
  //forma alternativa de declaración
  hlt1.AddIdentSpecL('case class const continue',tkKeyword);
  hlt1.AddIdentSpecL('default die do double',tkKeyword);
  hlt1.AddIdentSpecL('else elseif echo empty endfor endif',tkKeyword);
  hlt1.AddIdentSpecL('endswitch endwhile eval exit extends',tkKeyword);
  hlt1.AddIdentSpecL('function false float for',tkKeyword);
  //forma alternativa de declaración
  hlt1.AddKeyword('global');
  hlt1.AddKeyword('highlight_file');
  hlt1.AddKeyword('highlight_string');
  hlt1.AddKeyword('if');
  hlt1.AddKeyword('int');
  hlt1.AddKeyword('include');
  hlt1.AddKeyword('integer');
  hlt1.AddKeyword('isset');
  hlt1.AddKeyword('list');
  hlt1.AddKeyword('new');
  hlt1.AddKeyword('object');
  hlt1.AddKeyword('old_function');
  hlt1.AddKeyword('or');
  hlt1.AddKeyword('print');
  hlt1.AddKeyword('real');
  hlt1.AddKeyword('require');
  hlt1.AddKeyword('return');
  hlt1.AddKeyword('show_source');
  hlt1.AddKeyword('static');
  hlt1.AddKeyword('string');
  hlt1.AddKeyword('switch');
  hlt1.AddKeyword('true');
  hlt1.AddKeyword('unset');
  hlt1.AddKeyword('var');
  hlt1.AddKeyword('while');
  hlt1.AddKeyword('xor');
  //crea tokens delimitados
  hlt1.DefTokDelim('''','''',tkString);
  hlt1.DefTokDelim('"','"',tkString);
  hlt1.DefTokDelim('//','',tkComment);
  hlt1.DefTokDelim('/*','*/', tkComment, tdMulLin);
  hlt1.Rebuild;  //reconstruye
}
//  hlt1.AddBlock('inicio','fin','',true,hlt1.MainBlk);
//  hlt1.AddBlock('function','end','',false);
//  hlt1.Rebuild;
  hlt2 := TSynPasSyn.Create(self);  //Lazarus highlighter
  hlt2.KeywordAttribute.Foreground:=clGreen;
  hlt2.CommentAttribute.Foreground:=clGray;
  hlt2.StringAttribute.Foreground:=clBlue;
  hlt2.NumberAttri.Foreground:=clFuchsia;
  hlt2.DirectiveAttri.Foreground:=clRed;
  ed2.Highlighter := hlt2;
//  LoadTestFile('codigo_chico.pas' );
  LoadTestFile('codigo.pas' );
end;

procedure TForm1.LoadTestFile(arch: string);
begin
  //load file on StringList, for test
  lineas.LoadFromFile(arch);
  //////load file on editors, for show
  ed1.Lines.LoadFromFile(arch);
  ed2.Lines.LoadFromFile(arch);
end;
procedure TForm1.LoadSyntaxFile_hl1;
begin
  hlt1.LoadFromFile('Prueba.xml');
//  LoadTestFile('codigo.pas' );
  ed1.Invalidate;
  memo3.Lines.LoadFromFile('Prueba.xml');
end;
procedure TForm1.Button1Click(Sender: TObject);
var i: integer;
begin
  //Test Scriptable Highlighter
  t1 := now;
  for i:= 1 to 1000 do
    ExplorarArchivo(lineas, hlt1);
  t2 := now;
  memo1.Lines.Add('Total secs: ' + FormatFloat('0.00',(t2-t1)*24*60*60));
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  LoadSyntaxFile_hl1;
end;

procedure TForm1.Button3Click(Sender: TObject);  //Test Lazarus PHP Highlighter
var i: integer;
begin
  t1 := now;
  for i:= 1 to 1000 do
    ExplorarArchivo(lineas, hlt2);
  t2 := now;
  memo2.Lines.Add('Total secs: ' + FormatFloat('0.00',(t2-t1)*24*60*60));
end;

procedure TForm1.ed1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//  debugln('-------------------------');
end;

procedure TForm1.ed1KeyPress(Sender: TObject; var Key: char);
begin
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  hlt1.Free;
  hlt2.Free;
  lineas.Free;
end;

end.

