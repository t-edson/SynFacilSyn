unit UMainForm;
{ =========================================================================
NAME FacilSyntaxTool

  Demo unit is part of a FacilSyntaxTool to test the capabilities of
  SynFacil as a proof of concept, based on the work of
  Tito Hinostroza units:

  SynFacilBasic
  SynFacilHighlighter

ORIGINAL SOURCE: https://github.com/t-edson/SynFacilSyn

COPYRIGHT (c) 12/2023 - Alexander Weidauer; alex.weidauer@ifgdv.de

This program is free software; you can redistribute it and/or modify
it under the same terms as SynFacilSyn itself, either version 1.21 or,
at your option, any later version of SynFacilSyn you may have available.

ADVISE: The units SynFacilBasic and SynFacilHighlighter are embedded as
original source code form https://github.com/t-edson/SynFacilSyn. No
modifications are made.
}

{$MODE OBJFPC}
{$LONGSTRINGS ON}
interface

{ === UNITS ============================================================== }
uses
  Buttons,
  Classes,
  Controls,
  Dialogs,
  ExtCtrls,
  Forms,
  Graphics,
  LCLType,
  Menus,
  StdCtrls,
  SynEdit,
  SynFacilHighlighter,
  SynHighlighterXML,
  SysUtils,
  XMLPropStorage;

{ === CONSTANTS ========================================================= }

const

CFG_NAME = 'syn-facil-tool.xml';

{$IFDEF UNIX}
  CFG_DIR  = '.syn-facil';
{$ENDIF}

{$IFDEF WINDOWS}
  CFG_DIR = 'Facil-Tool';
{$ENDIF}

{ === RESSOURCES ======================================================== }

resourcestring
  RS_CODE = 'Code';
  RS_CONFIG = 'Configuration';
  RS_EXT_ALL = '*.*';
  RS_EXT_XML = '*.xml';
  RS_FMT_MODLINE = 'LINE: %d COLUMN: %d FILE: %s';
  RS_MSG_MODIFY = '%s file %s was modified!%sDo you want to save the file?';
  RS_SYNTAX = 'Syntax';

type

{ === TFrmMain -- Main Form Definition  ================================= }

  { TFrmMain }

  TFrmMain = class(TForm)
      { Button to end the application. }
      BtnQuit: TBitBtn;
      { Button to save the application configuration. }
      BtnStoreConfig: TBitBtn;
      { Button to call the syntax popoup menu. }
      BtnMenuSyntax: TBitBtn;
      { Button to open the application configuration. }
      BtnOpenConfig: TBitBtn;
      { Button to call the example code popoup menu. }
      BtnMenuCode: TBitBtn;

      { Checkox to enable automatic storage of the syntax file if,
        the syntax rules are applied to the highlighter. }
      ChkAsSyntax: TCheckBox;
      { Checkox to enable automatic storage of the example code file if,
        the syntax rules are applied to the highlighter. }
      ChkAsCode: TCheckBox;

      { Not used yet }
      DlgColor: TColorDialog;
      { OpenDialog to open files }
      DlgOpen: TOpenDialog;
      { SaveDialog to save files }
      DlgSave: TSaveDialog;

      { Edit to hold or change the configuration file }
      EdtFileConfig: TEdit;
      { Edit to hold or change the example code file }
      EdtFileCode: TEdit;
      { Edit to hold or change the xml syntax file }
      EdtFileSyntax: TEdit;
      { SynEditor for the example code file }
      EdtCode: TSynEdit;
      { SynEditor for the xml syntax file }
      EdtSyntax: TSynEdit;

      { GroupBox to group code related stuff }
      GbxCode: TGroupBox;
      { GroupBox to group syntax related stuff }
      GbxSyntax: TGroupBox;

      { Label for EdtConfig  }
      LabConfig: TLabel;
      { Menu entry to store example code as ...calls DlgStore }
      MnuCodeStoreAs: TMenuItem;
      { Menu entry to store example code using the current name }
      MnuStoreCode: TMenuItem;
      { Menu entry to open example code as ...calls DlgOpen }
      MnuOpenCode: TMenuItem;
      { Menu entry to applay the syntax rules to hilight the example code }
      MnuSyntaxApply: TMenuItem;
      { Menu entry to store xml syntax rules as ...calls DlgStore }
      MnuSyntaxStoreAs: TMenuItem;
      { Menu entry to store xml syntax using the current name }
      MnuSyntaxStore: TMenuItem;
      { Menu entry to open xml syntax rules ...calls DlgOpen }
      MnuSyntaxOpen: TMenuItem;
      { Menu separator }
      MnuSepApply: TMenuItem;

      { Panel to hold the config elements }
      PnlTop: TPanel;
      { Panel to hold the editors }
      PnlEditors: TPanel;
      { Panel to hold code config related components }
      PnlCodeTop: TPanel;
      { Panel to hold code syntax related components }
      PnlSyntaxTop: TPanel;
      { Panel code editor modeline }
      PnlCodeModLine: TPanel;
      { Panel syntax editor modeline }
      PnlSyntaxModline: TPanel;

      { Popup menu code }
      PopCode: TPopupMenu;
      { Popup menu syntax }
      PopSyntax: TPopupMenu;

      { Splitter between editor group boxes }
      SplitEditors: TSplitter;

      { Highighter fir the xml syntax file }
      HlXml: TSynXMLSyn;

      { Property storage for the app in ~/.syn-facil/syn-facil-tool.xml }
      XMLConfig: TXMLPropStorage;

      { === Event declarations ========================================== }

      { Open popup menu code example editor }
      procedure BtnMenuCodeClick(Sender: TObject);
      { Open popup menu syntax editor }
      procedure BtnMenuSyntaxClick(Sender: TObject);

      { Open the application configuration ..LoadEditDialog }
      procedure BtnOpenConfigClick(Sender: TObject);
      { Sores the current configuration }
      procedure BtnStoreConfigClick(Sender: TObject);
      { End the application ..FormCloseQuery }
      procedure BtnQuitClick(Sender: TObject);

      { Open the example code ..LoadEditDialog }
      procedure MnuOpenCodeClick(Sender: TObject);
      { Stores the example code editor ..SaveEdit }
      procedure MnuStoreCodeClick(Sender: TObject);
      { Stores the example code editor ..SaveEditAs }
      procedure MnuStoreAsCodeClick(Sender: TObject);

      { Apply the syntax rules to the example code editor }
      procedure MnuApplySyntaxClick(Sender: TObject);
      { Open the xml syntax rules ..LoadEditDialog  }
      procedure MnuOpenSyntaxClick(Sender: TObject);
      { Stores the xml rules ..SaveEdit }
      procedure MnuStoreSyntaxClick(Sender: TObject);
      { Stores the xml rules editor ..SaveEditAs }
      procedure MnuStoreAsSyntaxClick(Sender: TObject);

      { Check updates to trigger modline modifications for code editor }
      procedure EdtCodeChangeUpdating(ASender: TObject; AnUpdating: Boolean);
      { Check updates to trigger modline modifications for code editor }
      procedure EdtSyntaxChangeUpdating(ASender: TObject; AnUpdating: Boolean);

      { Init application when window is open load config }
      procedure FormActivate(Sender: TObject);
      { Check and store if editors are modified }
      procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
      { Init application allocate basic objects }
      procedure FormCreate(Sender: TObject);
      { Destroy allocated basic }
      procedure FormDestroy(Sender: TObject);
    public

      { === Public variables ============================================ }

      { The "generic" hilighter applied to the code example }
      HlGeneric:   TSynFacilSyn;
      { Home directory }
      DirUser:     String;
      { Configuration directory ~/.syn-facil }
      DirConfig:   String;
      { Configuration file ~/.syn-facil/syn-facil-tool.xml }
      FileConfig:  String;
      { File name abbrevation code example file for modeline }
      FileCode:    String;
      { File name abbrevation xml rule file for modeline }
      FileSyntax:  String;
      { Form.Activate and initialization was visited }
      Activated:   Boolean;

      { === Service routines ============================================ }

      { Applys the xml rules to the example config }
      procedure    ApplyGeneric;

      { Loads an Code or Syntax into the editor using the config.

        Parameter:
          aType -- Code, Config or Syntax
          aEdt  -- Edit holding the file name ..will be changed ..TEXT
          aFile -- abbrevated name
          aSyn  -- The editor

        Returns: TRUE if successful.
      }
      function     LoadEdit(const aType: String;
                            aEdt: TEdit;
                            var aFile: String;
                            aSyn: TSynEdit): Boolean;

      { Loads an Code, Config or Syntax into the editor/ xml properties
        using the open dialog.

        Parameter:
          aType -- Code, Config or Syntax
          aExt -- *.* or *.xml
          aDlg  -- The open dialog
          aEdt  -- Edit holding the file name ..will be changed ..TEXT
          aFile -- abbrevated name
          aSyn  -- The editor or NIL

        Returns: TRUE if successful.
      }
      function     LoadEditDlg(const aType, aExt: String;
                            aDlg: TOpenDialog;
                            aEdt: TEdit;
                            var aFile: String;
                            aSyn: TSynEdit): Boolean;

      { Save an edtor file with current filename

        Parameter:
          aType -- Code or Syntax
          aName -- Filename
          aSyn  -- Editor
          aAsk  -- TRUE Ask to perform and overwrite or
                   FALSE operate silently when auto-save is checked
      }
      procedure    SaveEdit(const aType, aName: String;
                            aSyn: TSynEdit; aAsk: Boolean = TRUE);

      { Save an editor file with current name whit dialog

        Parameter:
          aType -- Code, Config, Syntax
          aExt  -- Extensions *.*, *.xml
          aDlg  -- The save dialog
          aEdit -- Edit holhing the file name ..can be changed (VAR)
          aFile -- aFilename short
          aSyn  -- SynEdit -- for Code and Syntax or NIL for Config

        Returns: TRUE whe successful
      }
      function   SaveEditAs(const aType, aExt: String;
                            aDlg: TSaveDialog;
                            aEdt: TEdit;
                            var aFile: String;
                            aSyn: TSynEdit): Boolean;
  end;

{ == Main Form ========================================================== }
var
  FrmMain: TFrmMain;

{ === Implementation ==================================================== }

implementation
{$R *.lfm}

{ TFrmMain }

procedure  TFrmMain.ApplyGeneric;
var
  lStream: TStringStream;
begin
  if (FileCode <> '') and EdtCode.Modified then begin
     if ChkAsCode.Checked then
        SaveEdit(RS_CODE, EdtFileCode.Text, EdtCode, FALSE);
  end;

  if (FileSyntax <> '') and EdtSyntax.Modified then begin
     if ChkAsSyntax.Checked then
        SaveEdit(RS_SYNTAX, EdtFileSyntax.Text, EdtSyntax, FALSE);
  end;

  lStream:= TStringStream.Create(EdtSyntax.Text);
  try
    try
        HlGeneric.LoadFromStream(lStream);
        EdtCode.Invalidate;
    except
       on e: Exception do begin
          MessageDlg(e.Message, mtError, [mbOK], 0);
          exit;
       end;
    end;
  finally
    lStream.Free;
  end;
end;

{ === Button events ===================================================== }

procedure TFrmMain.BtnOpenConfigClick(Sender: TObject);
begin
  if not LoadEditDlg(RS_CONFIG, RS_EXT_XML, DlgOpen,
                  EdtFileConfig, FileConfig, NIL) then Exit;
  XMLConfig.FileName := EdtFileConfig.Text;
  FileConfig:= EdtFileConfig.Text;
  try
    XMLConfig.Restore;
  except
     on e: Exception do begin
        MessageDlg(e.Message, mtError, [mbOK], 0);
        exit;
     end;
  end;
end;

procedure TFrmMain.BtnStoreConfigClick(Sender: TObject);
begin
  if not SaveEditAs(RS_CONFIG, RS_EXT_ALL, DlgSave, EdtFileConfig,
                    FileConfig, NIL ) then exit;
end;

procedure TFrmMain.BtnMenuSyntaxClick(Sender: TObject);
begin
   PopSyntax.PopUp( FrmMain.Left
                  + EdtFileSyntax.Width
                  + BtnMenuSyntax.Width
                  - 175,
                    FrmMain.Top
                  + PnlTop.Height
                  + PnlSyntaxTop.Height
                  + 20);
end;

procedure TFrmMain.BtnMenuCodeClick(Sender: TObject);
begin
  PopCode.PopUp( FrmMain.Left
               + GbxSyntax.Width
               + EdtFileCode.Width
               + BtnMenuCode.Width
               - 158,
                 FrmMain.Top
               + PnlTop.Height
               + PnlCodeTop.Height
               + 20);
end;

procedure TFrmMain.BtnQuitClick(Sender: TObject);
begin
  Close;
end;

{ === SynEdit events =================================================== }

procedure TFrmMain.EdtCodeChangeUpdating(ASender: TObject;
                                         AnUpdating: Boolean);
var
  lPos: TPoint;
begin
    PnlCodeModline.Caption:='.';
    if FileCode='' then Exit;
    lPos:=EdtCode.LogicalCaretXY;
    PnlCodeModline.Caption := Format(RS_FMT_MODLINE,
                                     [lPos.Y, lPos.X, FileCode]) ;
end;

procedure TFrmMain.EdtSyntaxChangeUpdating(ASender: TObject;
                                           AnUpdating: Boolean);
var
  lPos: TPoint;
begin
  PnlSyntaxModline.Caption:='.';
  if FileSyntax='' then Exit;
  lPos:=EdtSyntax.LogicalCaretXY;
  PnlSyntaxModline.Caption := Format(RS_FMT_MODLINE,
                              [lPos.Y, lPos.X, FileSyntax]) ;
end;

{ === Form events ===================================================== }

procedure TFrmMain.FormActivate(Sender: TObject);
begin
  if Activated then exit;
  Activated := true;
  if EdtFileCode.Text <> '' then begin
    if not LoadEdit(RS_CODE, EdtFileCode, FileCode, EdtCode) then
       exit;
  end;
  if EdtFileSyntax.Text <> '' then begin
    if not LoadEdit(RS_SYNTAX, EdtFileSyntax, FileSyntax, EdtSyntax) then
       exit;
    ApplyGeneric;
  end;
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject;
                                  var CanClose: Boolean);
begin
   if (FileCode <> '') and EdtCode.Modified then begin
     SaveEdit(RS_CODE, EdtFileCode.Text, EdtCode, not ChkAsCode.Checked)
   end;

   if (FileSyntax <> '') and EdtSyntax.Modified then begin
     SaveEdit(RS_SYNTAX, EdtFileSyntax.Text, EdtSyntax,
              not ChkAsSyntax.Checked)
   end;
   CanClose := True;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  HlGeneric := TSynFacilSyn.Create(self);
  EdtCode.Highlighter := HlGeneric;
  DirUser:= GetUserDir;
  DirConfig:= ConcatPaths([DirUser, CFG_DIR]);
  FileConfig:= ConcatPaths([DirConfig, CFG_NAME]);
  if not DirectoryExists(DirConfig) then CreateDir(DirConfig);
  XMLConfig.FileName:=FileConfig;
  XMLConfig.Restore;
  EdtFileConfig.Text := FileConfig;
  DlgOpen.Filename :='.';
  FileSyntax:='';
  FileCode:='';
  Activated:=False;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  HlGeneric.Free;
end;

{ === Loading routines ================================================== }

function TFrmMain.LoadEdit(const aType: String;
                           aEdt: TEdit;
                           var aFile: String;
                           aSyn: TSynEdit): Boolean;
begin
  try
    aSyn.Lines.LoadFromFile(aEdt.Text);
    aFile     := ExtractFileName(aEdt.Text);
    Result    := TRUE;
  except
     on e: Exception do begin
        MessageDlg(e.Message, mtError, [mbOK], 0);
        Result:= FALSE;
     end;
  end;
end;

function TFrmMain.LoadEditDlg(const aType, aExt: String;
                           aDlg: TOpenDialog;
                           aEdt: TEdit;
                           var aFile: String;
                           aSyn: TSynEdit): Boolean;
begin
  aDlg.Filter   := aType+'|'+aExt;
  aDlg.FileName := aEdt.Text;
  if not aDlg.Execute then exit;
  aFile    := '';
  aEdt.Text:='';
  try
    if Assigned(aSyn) then aSyn.Lines.LoadFromFile(aDlg.FileName);
    aEdt.Text:=aDlg.FileName;
    if Assigned(aSyn) then aFile:= ExtractFileName(aDlg.FileName)
                      else aFile:= aDlg.FileName;
    Result := TRUE;
  except
     on e: Exception do begin
        MessageDlg(e.Message, mtError, [mbOK], 0);
        Result:= FALSE;
     end;
  end;
end;

{ === Popup Menu events ================================================= }

procedure TFrmMain.MnuApplySyntaxClick(Sender: TObject);
begin
  ApplyGeneric;
end;

procedure TFrmMain.MnuOpenCodeClick(Sender: TObject);
begin
  if not LoadEditDlg(RS_CODE, RS_EXT_ALL, DlgOpen,
                  EdtFileCode, FileCode, EdtCode) then Exit;
end;

procedure TFrmMain.MnuOpenSyntaxClick(Sender: TObject);
begin
  if not LoadEditDlg(RS_SYNTAX, RS_EXT_XML, DlgOpen,
                  EdtFileSyntax, FileSyntax, EdtSyntax) then Exit;
  ApplyGeneric;
end;

procedure TFrmMain.MnuStoreCodeClick(Sender: TObject);
begin
  SaveEdit(RS_CODE,EdtFileCode.Text,EdtCode, FALSE);
end;

procedure TFrmMain.MnuStoreAsCodeClick(Sender: TObject);
begin
  if not SaveEditAs(RS_CODE, RS_EXT_ALL, DlgSave, EdtFileCode,
                    FileCode, EdtCode ) then exit;
end;

procedure TFrmMain.MnuStoreSyntaxClick(Sender: TObject);
begin
  SaveEdit(RS_SYNTAX,EdtFileSyntax.Text,EdtSyntax, FALSE);
end;

procedure TFrmMain.MnuStoreAsSyntaxClick(Sender: TObject);
begin
  if not SaveEditAs(RS_SYNTAX, RS_EXT_XML, DlgSave, EdtFileSyntax,
                    FileSyntax, EdtSyntax ) then exit;

end;

{ === Store routines ==================================================== }

function TFrmMain.SaveEditAs(const aType, aExt: String;
                           aDlg: TSaveDialog;
                           aEdt: TEdit;
                           var aFile: String;
                           aSyn: TSynEdit): Boolean;
begin
  aDlg.Filter   := aType+'|'+aExt;
  aDlg.FileName := aEdt.Text;
  if not aDlg.Execute then exit;
  aFile    := '';
  aEdt.Text:='';
  try
    if Assigned(aSyn) then aSyn.Lines.SaveToFile(aDlg.FileName);
    aEdt.Text:=aDlg.FileName;
    if Assigned(aSyn) then aFile:= ExtractFileName(aDlg.FileName)
                      else aFile:= aDlg.FileName;
    Result := TRUE;
  except
     on e: Exception do begin
        MessageDlg(e.Message, mtError, [mbOK], 0);
        Result:= FALSE;
     end;
  end;
end;

procedure TFrmMain.SaveEdit(const aType,  aName: String;
                            aSyn: TSynEdit; aAsk: Boolean);
begin
  if aAsk then begin
     if MessageDlg(Format(RS_MSG_MODIFY, [aType, aName, LineEnding]),
                   mtConfirmation, [mbYes, mbNo], 0) = mrNo then Exit;
  end;

  try
    aSyn.Lines.SaveToFile(aName);
  except
     on e: Exception do begin
        MessageDlg(e.Message, mtError, [mbOK], 0);
     end;
  end;
end;

end.

