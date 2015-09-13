unit synfacil_adapter_atsynedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, Graphics, LazLogger,
  ATSynEdit,
  ATSynEdit_Adapters,
  ATSynEdit_CanvasProc,
  SynEditHighlighter,
  SynFacilBasic,
  SynFacilHighlighter;

type
  {Will contain the current status in one line}
  TSynFacilLineStates = TFPList;

  { TSynFacilAdapter }

  TSynFacilAdapter = class(TATAdapterHilite)
  private
    hlt    : TSynFacilSyn;
    states : TSynFacilLineStates;
    fRange : TPtrTokEspec;
  public
    procedure SetSyntax(const AFilename: string);
    procedure StringsLog(Sender: TObject; ALine, ALen: integer);
    procedure OnEditorCalcHilite(Sender: TObject;
      var AParts: TATLineParts;
      ALineIndex, ACharIndex, ALineLen: integer;
      var AColorAfterEol: TColor); override;
    procedure OnEditorChange(Sender: TObject); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;


implementation

uses
  Dialogs,
  ATStringProc,
  Synedit;

const
  LINES_PER_STATE = 8;  //every how many lines, it will be saved the state

{ TSynFacilAdapter }

constructor TSynFacilAdapter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  hlt:= TSynFacilSyn.Create(Self);
  states := TFPList.Create;
end;

procedure TSynFacilAdapter.SetSyntax(const AFilename: string);
begin
  hlt.LoadFromFile(AFilename);
end;

destructor TSynFacilAdapter.Destroy;
begin
  states.Destroy;
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
    hlt.Next;
    inc(npart);
    if npart>High(AParts) then break;
  end;
end;

procedure TSynFacilAdapter.StringsLog(Sender: TObject; ALine, ALen: integer);
begin
  DebugLn('OnLog: ALine=' + IntToStr(ALine) + ' ALen=' + IntToSTr(Alen));
end;

procedure TSynFacilAdapter.OnEditorChange(Sender: TObject);
var
  ed: TATSynEdit;
  Needed: Integer;
  firstModified: Integer;
  scanFrom: Integer;
  scanTo: Integer;
  i: Integer;
  stateFrom: Integer;
begin
  ed:= Sender as TATSynEdit;
  //Calculate necessary lines
  Needed := ed.Strings.Count div LINES_PER_STATE;
  DebugLn('Change: ed with lines:' + IntToStr(ed.Strings.Count) +
                   'Needed: '+ IntToStr(Needed));
  //Add if there are less
  while states.Count<Needed do
    states.Add(nil);
  //Remove if there are more
  if states.Count > Needed then
    states.Count:= Needed;
  //Calculate the first line modified, and lines shown
  firstModified := 0;  //??? No better information
  stateFrom := firstModified div LINES_PER_STATE;
  scanFrom :=  stateFrom * LINES_PER_STATE;
  scanTo := ed.LineBottom;
  //Set initial state
  if scanFrom = 0 then begin
    //first line
    hlt.ResetRange;
  end else begin
    //following lines
    hlt.Range:=states[stateFrom];
  end;
  DebugLn('  scanning from:' + IntToStr(scanFrom)+ ' to ' + IntToStr(scanTo));
  //scan necessary lines
  for i:= scanFrom to scanTo do
  begin
    hlt.SetLine(ed.Strings.lines[i], i);
    while true do begin
      if hlt.GetEol then begin
        if i mod LINES_PER_STATE = 0 then begin
          DebugLn('    saving state for line:' + IntToStr(i));
//          lineas.Objects[i] := TObject(hlt.Range);
          states[i mod LINES_PER_STATE] := hlt.Range;
        end;
        break;
      end;
      hlt.Next;
    end;
  end;
  //showmessage('onchange');
end;

end.

