unit xmlparser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

function fnxmlparser(xmlFilename, szSearch,  szTitle,  szDescription,  szAuthor : PChar) : integer;  cdecl;

implementation

function fnxmlparser(xmlFilename, szSearch,  szTitle,  szDescription,  szAuthor : PChar) : integer;  cdecl; external 'xmlparser.dll';

end.

