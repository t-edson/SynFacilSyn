unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, SynEdit, SynEditHighlighter,
  SynHighlighterPHP, SynHighlighterPas, Lazlogger, dialogs,
  SynHighlighterFacil in '..\SynHighlighterFacil.pas';

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    ed1: TSynEdit;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure LoadSyntaxFile_hl1;
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}
//crea espacio para almacenar token
var hlt : TSynFacilSyn;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  //configure highlighters
  hlt := TSynFacilSyn.Create(self);  //my highlighter
  hlt.VariableAttri.Foreground:=clYellow;
  ed1.Highlighter := hlt;
  LoadSyntaxFile_hl1;

  ed1.Lines.LoadFromFile('codigo.pas' );
//  hlt.DefTokContent('','','',tkNumber);
//  if hlt.Err<>'' then ShowMessage(hlt.Err);
end;

procedure TForm1.LoadSyntaxFile_hl1;
begin
  hlt.LoadFromFile('Prueba.xml');
  ed1.Invalidate;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  LoadSyntaxFile_hl1;
end;

procedure TForm1.Button3Click(Sender: TObject);  //desmarcar
var i: Integer;
begin
  for i:=0 to  hlt.AttrCount-1 do
    hlt.Attribute[i].FrameColor:=clNone;
  ed1.Invalidate;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  hlt.ColBlock:=cbNull;
  ed1.Invalidate;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  hlt.ColBlock:=cbLevel;
  ed1.Invalidate;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  hlt.ColBlock:=cbBlock;
  ed1.Invalidate;
end;

procedure TForm1.Button9Click(Sender: TObject);
var
  lin: String;
  nTokens: integer = 0;
begin
  for lin in ed1.Lines do begin
    hlt.SetLine(lin,1);
    while not hlt.GetEol do begin
      inc(nTokens);
      hlt.Next;  //pasa al siguiente
    end;
  end;
  ShowMessage(IntToStr(nTokens));
end;

procedure TForm1.Button1Click(Sender: TObject);  //marcar
var i: Integer;
begin
  for i:=0 to  hlt.AttrCount-1 do
    hlt.Attribute[i].FrameColor:=clBlack;
  ed1.Invalidate;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  hlt.Free;
end;

end.

