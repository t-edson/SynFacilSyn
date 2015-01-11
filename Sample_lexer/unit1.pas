unit Unit1;
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SynEdit, Forms, Controls, Dialogs,
  StdCtrls, FormOut, SynEditHighlighter, SynFacilHighlighter, SynFacilBasic;

type
  { TForm1 }
  TForm1 = class(TForm)
    Button1: TButton;
    Button3: TButton;
    Button2: TButton;
    SynEdit1: TSynEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure ShowCurrentTok;
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  xLex : TSynFacilSyn;

implementation
{$R *.lfm}

procedure TForm1.ShowCurrentTok;
var
  tmp: String;
  blk: String;
  Token: String;
  TokenType: Integer;
begin
  Token := xLex.GetToken; //lee el token
  TokenType := xLex.GetTokenKind;  //lee atributo
  tmp := TSynHighlighterAttributes(TokenType).Name;
  if xLex.TopCodeFoldBlock = nil then blk := 'nil    '
  else blk := xLex.TopCodeFoldBlock.name;
  frmOut.puts( tmp + space(12-length(tmp))+ '('+ blk +'): ' +
               Token);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  lin: String;
begin
  frmOut.Show;  //show console
  frmOut.SynEdit1.Text:='';
  //Explore
  xLex.ResetRange;    //para que inicie "fRange" apropiadamente
  for lin in SynEdit1.lines do begin
    xLex.SetLine(lin,0);    //xLex es el resaltador
    while not xLex.GetEol do begin
      ShowCurrentTok;
      xLex.Next;  //pasa al siguiente
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  lin: String;
  lineas: TStringList;
begin
  frmOut.Show;  //show console
  frmOut.SynEdit1.Text:='';
  ///////////Create content
  lineas := TStringList.Create;
  lineas.Text:= '//código ejemplo'+LineEnding+
                '{'+LineEnding+
                '  x = x + 2;'+LineEnding+
                '  c = "Hola mundo";'+LineEnding+
                '  /*Este es un'+LineEnding+
                '  comentario de'+LineEnding+
                '  varias líneas */'+LineEnding+
                '}'+LineEnding+'';
  //Explore
  xLex.ResetRange;    //para que inicie "fRange" apropiadamente
  for lin in lineas do begin
    xLex.SetLine(lin,0);    //xLex es el resaltador
    while not xLex.GetEol do begin
      ShowCurrentTok;
      xLex.Next;  //pasa al siguiente
    end;
  end;
  lineas.Destroy;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  lin: String;
  lineas: TStringList;
  i: Integer;
begin
  frmOut.Show;  //show console
  frmOut.SynEdit1.Text:='';

  ///////////Create content
  lineas := TStringList.Create;
  lineas.Text:= '//código ejemplo'+LineEnding+
                '{'+LineEnding+
                '  x = x + 2;'+LineEnding+
                '  c = "Hola mundo";'+LineEnding+
                '  /*Este es un'+LineEnding+
                '  comentario de'+LineEnding+
                '  varias líneas */'+LineEnding+
                '}'+LineEnding+'';

  ///////////First, scan all lines
  xLex.ResetRange;    //para que inicie "fRange" apropiadamente
  for i:=0 to lineas.Count-1 do begin
    lin := lineas[i];
    xLex.SetLine(lin,0);      //”xLex” es el resaltador
    while true do begin
      if xLex.GetEol then begin
        lineas.Objects[i] := TObject(xLex.Range);
        break;
      end;
      xLex.Next;  //pasa al siguiente
    end;
  end;
  ////////////Show token on line 6
  frmOut.puts('Token 1 at Line 6:');
  xLex.Range := TPtrTokEspec(lineas.Objects[4]);  //recupera rango de la línea anterior
  xLex.SetLine(lineas[5],0);     //asigna cadena
  ShowCurrentTok;

  lineas.Destroy;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  blk: TFaSynBlock;
begin
  xLex := TSynFacilSyn.Create(nil);   //crea lexer
  ///////////define syntax for the lexer
  xLex.ClearMethodTables;           //limpìa tabla de métodos
  xLex.ClearSpecials;               //para empezar a definir tokens
  //crea tokens por contenido
  xLex.DefTokIdentif('[$A-Za-z_]', '[A-Za-z0-9_]*');
  xLex.DefTokContent('[0-9]', '[0-9.]*', xLex.tkNumber);
  //define keywords
  xLex.AddIdentSpecList('begin end else elsif', xLex.tkKeyword);
  xLex.AddIdentSpecList('true false int string', xLex.tkKeyword);
  //create delimited tokens
  xLex.DefTokDelim('''','''', xLex.tkString);
  xLex.DefTokDelim('"','"', xLex.tkString);
  xLex.DefTokDelim('//','', xLex.tkComment);
  xLex.DefTokDelim('/\*','*/', xLex.tkComment, tdMulLin);
  //define syntax block
  blk := xLex.AddBlock('{','}');
  blk.name:='bLlaves';
  xLex.Rebuild;
end;
procedure TForm1.FormDestroy(Sender: TObject);
begin
  xLex.Destroy;
end;

end.

