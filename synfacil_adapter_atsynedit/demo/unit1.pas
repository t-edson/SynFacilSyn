unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ATSynEdit,
  synfacil_adapter_atsynedit;

type
  { TForm1 }

  TForm1 = class(TForm)
    procedure edStringsLog(Sender: TObject; ALine, ALen: integer);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    ed: TATSynEdit;
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  adapter: TSynFacilAdapter;
const
  nTest = 10.20000;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.edStringsLog(Sender: TObject; ALine, ALen: integer);
begin
  adapter.StringsLog(Sender, ALine, ALen);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  adapter:= TSynFacilAdapter.Create(Self);
  adapter.SetSyntax('Pascal.xml');

  ed:= TATSynEdit.Create(Self);
  ed.Parent:= Self;
  ed.Font.Name:= 'Courier New';
  ed.Align:= alClient;
  ed.OptUnprintedVisible:= false;
  ed.OptRulerVisible:= false;
  ed.AdapterHilite:= adapter;
  ed.Strings.OnLog:=@edStringsLog;
  ed.LoadFromFile(ExtractFilePath(Application.ExeName)+'unit1.pas');
end;

end.

