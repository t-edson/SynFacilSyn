program FacilSyntaxTool;
{ =========================================================================
NAME FacilSyntaxTool

  Demo program to test the capabilities of SynFacil as a proof of concept
  based on the work of Tito Hinostroza units:

  SynFacilBasic
  SynFacilHighlighter

ORIGINAL SOURCE: https://github.com/t-edson/SynFacilSyn


COPYRIGHT (c) 12/2023 - Alexander Weidauer; alex.weidauer@ifgdv.de

This program is free software; you can redistribute it and/or modify
it under the same terms as SynFacilSyn itself, either version 1.21 or,
at your option, any later version of SynFacilSy you may have available.
}

{$MODE OBJFPC}
{$LONGSTRINGS ON}

uses
  {$IFDEF UNIX}
    {$IFDEF UseCThreads}
    cthreads,
    {$ENDIF}
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, UMainForm;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

