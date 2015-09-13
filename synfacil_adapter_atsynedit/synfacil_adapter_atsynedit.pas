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
    firstModified: Integer;
    procedure ScanLines(ed: TATSynEdit; const scanFrom, scanTo: integer);
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
  ist: Integer;
begin
  DebugLn('-OnEditorCalcHilite: ALineIndex=' + IntToStr(ALineIndex));
  ed:= Sender as TATSynEdit;
  Str:= Copy(ed.Strings.Lines[ALineIndex], ACharIndex, ALineLen);
  if ALineIndex mod LINES_PER_STATE = 0 then begin
    ist := ALineIndex div LINES_PER_STATE - 1;
    DebugLn('OnCalcHilite: Getting state for line:'+ IntToStr(ALineIndex+1) +
                      ' from states[' + IntToStr(ist)+']');
    if ist = -1 then
      hlt.Range := nil
    else
      hlt.Range := states[ist];
  end;
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
  if (Aline>=0) and (Aline<firstModified) then firstModified := ALine;
//  DebugLn('OnLog: ALine=' + IntToStr(ALine) + ' ALen=' + IntToSTr(Alen));
end;
procedure TSynFacilAdapter.ScanLines(ed: TATSynEdit; const scanFrom, scanTo: integer);
{Scans an interval of lines to update the state of the range in States[].
 States[] save the state of the highlighter at the end of the exploration. It's
 saved only for every LINES_PER_STATE lines, for to save memory and avoid to change
 frecuently the size of the list states[]. }
var
  i: Integer;
  ist: Integer;
begin
  DebugLn('  ScanLines: scanning from:' + IntToStr(scanFrom+1)+ ' to ' + IntToStr(scanTo+1));
  //scan necessary lines
  for i:= scanFrom to scanTo do
  begin
    hlt.SetLine(ed.Strings.lines[i], i);
    while true do begin
      if hlt.GetEol then begin
        if (i+1) mod LINES_PER_STATE = 0 then begin
          ist := (i+1) div LINES_PER_STATE;
          DebugLn('  ScanLines: saving state for line:' + IntToStr(i+1) +
                  ' in states[' + IntToStr(ist) + ']');
          states[ist] := hlt.Range;
        end;
        break;
      end;
      hlt.Next;
    end;
  end;
end;
procedure TSynFacilAdapter.OnEditorChange(Sender: TObject);
var
  ed: TATSynEdit;
  Needed: Integer;
  scanFrom: Integer;
  scanTo: Integer;
  stateFrom: Integer;
begin
  ed:= Sender as TATSynEdit;
  //Calculate necessary lines
  Needed := ed.Strings.Count div LINES_PER_STATE + 1;
  DebugLn('EditorChange: ed with lines:' + IntToStr(ed.Strings.Count) +
                   ' Needed: '+ IntToStr(Needed));
  //Add if there are less
  while states.Count<Needed do
    states.Add(nil);
  //Remove if there are more
  if states.Count > Needed then
    states.Count:= Needed;
  //Calculate the first line modified, and lines shown
  //firstModified := 0;
  DebugLn('EditorChange: text modified from:' + IntToStr(firstModified+1));
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
  ScanLines(ed, scanFrom, scanTo);
  //showmessage('onchange');
  firstModified := MaxInt;  //clean flag
end;

end.

