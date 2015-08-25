unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ATSynEdit, ATSynEdit_Keymap_Init, ATStringProc, ATSynEdit_CanvasProc,
 SynEditHighlighter, SynFacilHighlighter;

type
  { TForm1 }

  TForm1 = class(TForm)
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
    ed: TATSynEdit;
    procedure EditCalcLine(Sender: TObject; var AParts: TATLineParts;
      ALineIndex, ACharIndex, ALineLen: integer; var AColorAfterEol: TColor);
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  hlt : TSynFacilSyn;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  hlt := TSynFacilSyn.Create(self);
  hlt.LoadFromFile('Pascal.xml');

  ed:= TATSynEdit.Create(Self);
  ed.Parent:= Self;
  ed.Font.Name:= 'Courier New';
  ed.Align:= alClient;
  ed.OptUnprintedVisible:= false;
  ed.OptRulerVisible:= false;
//  ed.Colors.TextBG:= $e0f0f0;
  ed.LoadFromFile(ExtractFilePath(Application.ExeName)+'unit1.pas');
  ed.OnCalcHilite := @EditCalcLine;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  ed.Destroy;
  hlt.Destroy;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ed.OptCaretBlinkEnabled:= not ed.OptCaretBlinkEnabled;
  ed.SetFocus;
end;

procedure TForm1.EditCalcLine(Sender: TObject; var AParts: TATLineParts;
  ALineIndex, ACharIndex, ALineLen: integer; var AColorAfterEol: TColor);
var
  npart, noffset: integer;
var
  Str: atString;
  i: integer;
  tokType: TSynHighlighterAttributes;
begin
  Str:= Copy(ed.Strings.Lines[ALineIndex], ACharIndex, ALineLen);
  hlt.SetLine(Str, ALineIndex);
  npart:= 0;
  noffset:= 0;
  while not hlt.GetEol do begin
    tokType := TSynHighlighterAttributes(hlt.GetTokenKind);
    with AParts[npart] do begin
      if tokType  = hlt.tkKeyword then begin
        ColorBG:= clYellow;
        ColorFont:= clgreen;
        FontItalic:= true;
        FontBold:= true;
      end else if tokType  = hlt.tkComment then begin
        ColorBG:= clNone;
        ColorFont:= clGray;
        FontItalic:= true;
        FontBold:= true;
      end else begin
        ColorBG:= clNone;
        ColorFont:= clBlack;
        FontItalic:= false;
        FontBold:= false;
      end;
      Offset:= noffset;
      Len:= length(hlt.GetToken);
      inc(noffset, len);
    end;
    //pasa al siguiente
    hlt.Next;
    inc(npart);
    if npart>High(AParts) then break;
  end;
end;

end.

