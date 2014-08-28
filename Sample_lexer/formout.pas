unit FormOut;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs;

type

  { TfrmOut }

  TfrmOut = class(TForm)
    SynEdit1: TSynEdit;
  private
    { private declarations }
  public
    procedure puts(s: string);
  end;

var
  frmOut: TfrmOut;

implementation

{$R *.lfm}

{ TfrmOut }

procedure TfrmOut.puts(s: string);
//Imprime un texto en la ventana de salida
begin
  SynEdit1.Lines.Add(s);
end;

end.

