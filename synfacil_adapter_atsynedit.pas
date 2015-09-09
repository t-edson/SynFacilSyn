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
  { TATAdapterHilite }

  { TSynFacilAdapter }

  TSynFacilAdapter = class(TATAdapterHilite)
  private
    hlt: TSynFacilSyn;
  public
    constructor Create(AOwner: TComponent; const AFileXml: string);
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

constructor TSynFacilAdapter.Create(AOwner: TComponent; const AFileXml: string);
begin
  inherited Create(AOwner);
  hlt:= TSynFacilSyn.Create(self);
  hlt.LoadFromFile(AFileXml);
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
var
  ed: TATSynEdit;
  Str: atString;
  tokType: TSynHighlighterAttributes;
begin
  ed:= Sender as TATSynEdit;
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

procedure TSynFacilAdapter.OnEditorChange(Sender: TObject);
begin
  showmessage('change-need recalc hilite');
end;


end.

