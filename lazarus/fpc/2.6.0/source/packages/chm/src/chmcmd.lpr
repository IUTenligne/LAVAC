{ Copyright (C) <2005> <Andrew Haines> chmcmd.pas

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}
{
  See the file COPYING, included in this distribution,
  for details about the copyright.
}
program chmcmd;

{$mode objfpc}{$H+}

uses
  Classes, Sysutils, chmfilewriter, GetOpts;

Const 
  CHMCMDVersion = '2.6.0';

Procedure Usage;

begin
  Writeln(StdErr,'Usage: chmcmd [options] <filename>');
  writeln(stderr);
  writeln(stderr,'The following options are available :');
  writeln(stderr,' --html-scan       : scan html for missing files or alinks  ');
  writeln(stderr,' --no-html-scan    : don''t scan html for missing files or alinks ');
  writeln(stderr,' -h, --help        : print this text');
  writeln(stderr,'--verbosity number : set verbosity level 0..5, 0 is least');
  writeln(stderr,'--generate-xml     : (if .hhp file), also generate a xml project from .hhp');
  writeln(stderr);
  writeln(stderr,' .hhp projects are default scanned for html, .xml not');
  Halt(1);
end;

var
  theopts : array[1..6] of TOption;

procedure InitOptions;

begin
  with theopts[1] do
   begin
    name:='html-scan';
    has_arg:=0;
    flag:=nil;
    value:=#0;
  end;
  with theopts[2] do
   begin
    name:='no-html-scan';
    has_arg:=0;
    flag:=nil;
    value:=#0;
  end;
  with theopts[3] do
   begin
    name:='verbosity';
    has_arg:=1;
    flag:=nil;
    value:=#0;
  end;
  with theopts[4] do
   begin
    name:='generate-xml';
    has_arg:=0;
    flag:=nil;
    value:=#0;
  end;
  with theopts[5] do
   begin
    name:='help';
    has_arg:=0;
    flag:=nil;
  end;
  with theopts[6] do
   begin
    name:='';
    has_arg:=0;
    flag:=nil;
  end;
end;

Type THtmlScanenum = (scandefault,scanforce,scanforcedno);

var
  GenerateXMLForHHP  : boolean = false;
  alloweddetaillevel : integer = 0;     // show if msg.detaillevel<=allowdetaillevel
  htmlscan           : THtmlScanEnum = Scandefault;

procedure OnError (Project: TChmProject;errorkind:TChmProjectErrorKind;msg:String;detailevel:integer=0);
begin
  if detailevel<=alloweddetaillevel then
    if errorkind<>chmnone then
      writeln(ChmErrorKindText[errorkind],': ',msg)
    else
      writeln(msg);
end;

procedure Processfile(name:string);

var
  OutStream: TFileStream;
  Project: TChmProject;
  xmlname: string;
  ishhp  : boolean;

begin
  ishhp:=uppercase(extractfileext(name))='.HHP';
  Project := TChmProject.Create;
  Project.ReadMeMessage:='Compiled by CHMCmd '+CHMCMDVersion;
  if ishhp then
    begin
      xmlname:=changefileext(name,'.hhp.xml');
      Project.OnError:=@OnError;
      try
        Project.LoadFromHHP(name,false) ;          // we need a param for this second param later
       except
         on e:exception do
           begin
             Writeln('This HHP CHM project seems corrupt, please check it ',name);
             halt(1);
           end;
       end;
      project.ScanHtmlContents:=htmlscan<>scanforcedno;  // .hhp default SCAN
    end
  else
    begin
     try
      project.ScanHtmlContents:=htmlscan=scanforce;  // .hhp default SCAN
      Project.LoadFromFile(name);
     except
       on e:exception do
         begin
           Writeln('This XML CHM project seems corrupt, please check it ',name);
           halt(1);
         end;
       end;
    end;
  OutStream := TFileStream.Create(Project.OutputFileName, fmCreate, fmOpenWrite);
  Project.WriteChm(OutStream);
  if ishhp and GenerateXMLForHHP then
    begin
      Writeln('Generating XML ',xmlname,'.');
      Project.SaveToFile(xmlname);
    end;
  OutStream.Free;
  Project.Free;

end;

var
  name   : string;
  optionindex : integer;
  c      : char;
  verbtemp : integer;
  verbbool : boolean;

begin
  InitOptions;
  Writeln(stderr,'chmcmd, a CHM compiler. (c) 2010 Free Pascal core.');
  Writeln(Stderr);
  repeat
    c:=getlongopts('h',@theopts[1],optionindex);
    case c of
      #0 : begin
             case optionindex-1 of
               0 : htmlscan:=scanforce;
               1 : htmlscan:=scanforcedno;
               2 : begin
                     verbbool:=trystrtoint(optarg,verbtemp);
                     if verbbool then
                       verbbool:=(verbtemp>=0) and (verbtemp<6);
                     if verbbool then
                       alloweddetaillevel:=verbtemp
                     else
                       begin
                         Writeln('Illegal value for switch --verbosity :',optarg);
                         Usage;
                         Halt;
                       end;
                   end;
               3 : GenerateXMLForHHP:=true;
               4 : begin;
                    Usage;
                    Halt;
                   end;
                end;
           end;
      '?' : begin
              writeln('unknown option',optopt);
              usage;
              halt;
            end;
   end; { case }
 until c=endofoptions;
 if (paramcount-optind)=0 then  // if equal, then 1 parameter
    begin
      name:=paramstr(optind);
      if not fileexists(name) then
        begin
          Writeln('Can''t find project file ',name);
          halt;
        end;
      ProcessFile(Name);
    end
 else
   begin
     Writeln('Invalid number of parameters :', paramcount-optind+1);
     Usage;
     halt;
   end;
end.
