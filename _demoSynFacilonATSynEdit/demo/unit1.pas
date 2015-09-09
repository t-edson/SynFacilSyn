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
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
    ed: TATSynEdit;
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  adapter: TSynFacilAdapter;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  adapter:= TSynFacilAdapter.Create(Self, 'Pascal.xml');

  ed:= TATSynEdit.Create(Self);
  ed.Parent:= Self;
  ed.Font.Name:= 'Courier New';
  ed.Align:= alClient;
  ed.OptUnprintedVisible:= false;
  ed.OptRulerVisible:= false;
  ed.LoadFromFile(ExtractFilePath(Application.ExeName)+'unit1.pas');
  ed.AdapterHilite:= adapter;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  ed.Destroy;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ed.OptCaretBlinkEnabled:= not ed.OptCaretBlinkEnabled;
  ed.SetFocus;
end;

end.

