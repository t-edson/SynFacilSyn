unit synfacil_adapter_atsynedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics,
  ATSynEdit,
  ATSynEdit_Adapters,
  ATSynEdit_CanvasProc,
  SynFacilBasic,
  SynFacilHighlighter;

type
  { TSynFacilAdapter }

  TSynFacilAdapter = class(TATAdapterHilite)
  private
    hlt: TSynFacilSyn;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetSyntax(const AFilename: string);
    destructor Destroy; override;
    procedure OnEditorCalcHilite(Sender: TObject;
      var AParts: TATLineParts;
      ALineIndex, ACharIndex, ALineLen: integer;
      var AColorAfterEol: TColor); override;
    procedure OnEditorChange(Sender: TObject); override;
  end;


implementation

uses
  Dialogs,
  ATStringProc,
  Synedit,
  SynEditHighlighter;


{ TSynFacilAdapter }

constructor TSynFacilAdapter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  hlt:= TSynFacilSyn.Create(Self);
end;

procedure TSynFacilAdapter.SetSyntax(const AFilename: string);
begin
  hlt.LoadFromFile(AFilename);
end;

destructor TSynFacilAdapter.Destroy;
begin
  FreeAndNil(hlt);
  inherited;
end;

procedure TSynFacilAdapter.OnEditorCalcHilite(Sender: TObject;
  var AParts: TATLineParts; ALineIndex, ACharIndex, ALineLen: integer;
  var AColorAfterEol: TColor);
var
  npart, noffset: integer;
  ed: TATSynEdit;
  Str: atString;
  atr: TSynHighlighterAttributes;
begin
  ed:= Sender as TATSynEdit;
  Str:= Copy(ed.Strings.Lines[ALineIndex], ACharIndex, ALineLen);
  hlt.SetLine(Str, ALineIndex);
  npart:= 0;
  noffset:= 0;
  while not hlt.GetEol do
  begin
    atr:= TSynHighlighterAttributes(hlt.GetTokenKind);
    AParts[npart].ColorBG:= atr.Background;
    if atr.Foreground<>clNone then
      AParts[npart].ColorFont:= atr.Foreground;
    AParts[npart].FontItalic:= fsItalic in atr.Style;
    AParts[npart].FontBold:= fsBold in atr.Style;
    AParts[npart].Offset:= noffset;
    AParts[npart].Len:= length(hlt.GetToken);
    inc(noffset, AParts[npart].Len);
    //pasa al siguiente
    hlt.Next;
    inc(npart);
    if npart>High(AParts) then break;
  end;
end;

procedure TSynFacilAdapter.OnEditorChange(Sender: TObject);
begin
  //showmessage('onchange');
end;


end.

