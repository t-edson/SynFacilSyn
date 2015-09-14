{ATSynEdit adapter for SynfacilSyn }
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
  {Will contain the current status in one line.}
  TSynFacilLineStates = TFPList;

  { TSynFacilAdapter }

  TSynFacilAdapter = class(TATAdapterHilite)
  private
    hlt    : TSynFacilSyn;
    states : TSynFacilLineStates;
    fRange : TPtrTokEspec;
    firstModified: Integer;
    UpdatedToIdx: integer; //the top index of states[] that have valid value for range.
    LastCalc: integer;  //last line painted
    procedure SetStartRangeForLine(ed: TATSynEdit; lin: integer);
    function UpdatedToLin: integer; //top line that have valid value for range.
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
  {Te state is saved in states[] every LINES_PER_STATE. So if LINES_PER_STATE is 8,
   we will have:
   LINE       LINE       ENDING STATE
   NUMBER     INDEX      SAVED IN
   ---------- ---------- -------------
   -          -          states[0]
   1          0
   2          1
   ...
   7          6
   8          7          states[1]
   9          8
   ...
   16         15         states[2]
   ...
   24         23         states[3]
   ...
  }
{ TSynFacilAdapter }

constructor TSynFacilAdapter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  hlt:= TSynFacilSyn.Create(Self);
  states := TFPList.Create;
  UpdatedToIdx := 0;   //updated to before of first line
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

procedure TSynFacilAdapter.StringsLog(Sender: TObject; ALine, ALen: integer);
begin
  if (Aline>=0) and (Aline<firstModified) then firstModified := ALine;
//  DebugLn('OnLog: ALine=' + IntToStr(ALine) + ' ALen=' + IntToSTr(Alen));
end;

function TSynFacilAdapter.UpdatedToLin: integer;
begin
  Result := UpdatedToIdx * LINES_PER_STATE - 1;  //it's 0-based.
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
  if LastCalc>=ALineIndex then begin
    //first line painted
    DebugLn('-OnEditorCalcHilite: requiring range for Start of line ' + IntToStr(ALineIndex+1));
    SetStartRangeForLine(ed, ALineIndex);
  end;
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
  LastCalc := ALineIndex;
end;

procedure TSynFacilAdapter.SetStartRangeForLine(ed: TATSynEdit; lin: integer);
{Return the proper value for the range needed before to scan the line of index "lin".
 It corresponds to the value of range, at the end of the line before.
}
var
  i: Integer;
  ist: Integer;
  idxState: Integer;
begin
  if lin=0 then begin
     hlt.Range := nil;
     exit;
  end;
  //calculate the idx of state[] needed to get the range
  idxState := lin div LINES_PER_STATE;
  if idxState <= UpdatedToIdx then begin
    //There is updated information until line: lin*idxState-1
    //Explore until the line "lin-1"
    hlt.Range:=states[idxState];  //no problem with UpdatedToIdx=0, because states[0] = nil
    for i:=idxState*LINES_PER_STATE to lin-1 do begin
      hlt.SetLine(ed.Strings.lines[i], i);
      while true do begin
        if hlt.GetEol then break;
        hlt.Next;
      end;
    end;
  end else begin
    //It's necessary to calculate
    //Scan from the last valid range to the value needed
    hlt.Range:=states[UpdatedToIdx];  //no problem with UpdatedToIdx=0, because states[0] = nil
    for i:=UpdatedToIdx*LINES_PER_STATE to lin-1 do begin
      hlt.SetLine(ed.Strings.lines[i], i);
      while true do begin
        if hlt.GetEol then begin
          if (i+1) mod LINES_PER_STATE = 0 then begin
            ist := (i+1) div LINES_PER_STATE;
            DebugLn('  Updating state for line:' + IntToStr(i+1) +
                    ' in states[' + IntToStr(ist) + ']');
            states[ist] := hlt.Range;
            UpdatedToIdx:=ist;   //until here, we have valid information
          end;
          break;
        end;
        hlt.Next;
      end;
    end;
  end;
end;

procedure TSynFacilAdapter.OnEditorChange(Sender: TObject);
var
  ed: TATSynEdit;
  NeededIdx: Integer;
  UpdatedToIdx0: Integer;
begin
  ed:= Sender as TATSynEdit;
  //Calculate necessary space in state[].
  NeededIdx := ed.Strings.Count div LINES_PER_STATE + 1;
//  DebugLn('EditorChange: ed with lines:' + IntToStr(ed.Strings.Count) +
//                   ' Needed: '+ IntToStr(NeededIdx));
  //Add if there are less
  while states.Count<NeededIdx do begin
    states.Add(nil);
  end;
  //Remove if there are more
  if states.Count > NeededIdx then begin
    states.Count:= NeededIdx;
  end;
  //Adjust UpdatedToIdx if there are less lines
  if NeededIdx-1<UpdatedToIdx then begin
    DebugLn('EditorChange: UpdatedToIdx truncated to:' + IntToStr(NeededIdx-1));
    UpdatedToIdx:=NeededIdx-1;
  end;
  //Update UpdatedToIdx, according to lines modified
  //firstModified := 0;
  UpdatedToIdx0:=firstModified div LINES_PER_STATE;
  if UpdatedToIdx0<UpdatedToIdx then UpdatedToIdx := UpdatedToIdx0;
  DebugLn('EditorChange: UpdatedToIdx=' + IntToStr(UpdatedToIdx));

  //showmessage('onchange');
  firstModified := MaxInt;  //clean flag}
end;

end.

