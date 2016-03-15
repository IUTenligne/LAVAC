
{*******************************************************}
{                                                       }
{       Turbo Pascal for Windows Run-time Library       }
{       Windows 3.1 API Interface Unit                  }
{                                                       }
{       Copyright (c) 1992 Borland International        }
{                                                       }
{*******************************************************}

unit LZExpand;

interface

uses Windows;

{ Constants }

const
{ Error Return Codes }

  lzerror_BadInHandle = -1;            { invalid input handle }
  lzerror_BadOutHandle = -2;           { invalid output handle }
  lzerror_Read = -3;                   { corrupt compressed file format }
  lzerror_Write = -4;                  { out of space for output file }
  lzerror_GlobAlloc = -5;              { insufficient memory for LZFile struct }
  lzerror_GlobLock = -6;               { bad global handle }
  lzerror_BadValue = -7;               { input parameter out of acceptable range }
  lzerror_UnknownAlg = -8;             { compression algorithm not recognized }

{ Prototypes }

function LZStart: Integer; stdcall;
procedure LZDone; stdcall;
function CopyLZFile(Source, Dest: Integer): Longint; stdcall;

function LZCopy(Source, Dest: Integer): Longint; stdcall;
function LZInit(Source: Integer): Integer;  stdcall;
function GetExpandedName(Source, Buffer: PChar): Integer; stdcall;
function LZOpenFile(FileName: PChar; var ReOpenBuf: TOFStruct;
  Style: Word): Integer;stdcall;
function LZSeek(LZFile: Integer; SeekTo: Longint; Mode: Integer): Longint; stdcall;
function LZRead(LZFile: Integer; Buf: PChar; Count: Integer): Integer; stdcall;
procedure LZClose(LZFile: Integer); stdcall;

implementation

function LZStart: Integer; stdcall; external 'LZ32.dll' name 'LZStart';
procedure LZDone; stdcall; external 'LZ32.dll' name 'LZDone';
function CopyLZFile(Source, Dest: Integer): Longint; stdcall; external 'LZ32.dll' name 'CopyLZFile';

function LZCopy(Source, Dest: Integer): Longint; stdcall; external 'LZ32.dll' name 'LZCopy';
function LZInit(Source: Integer): Integer; stdcall; external 'LZ32.dll' name 'LZInit';
function GetExpandedName(Source, Buffer: PChar): Integer; stdcall; external 'LZ32.dll' name 'GetExpandedNameA';
function LZOpenFile(FileName: PChar; var ReOpenBuf: TOFStruct; Style: Word): Integer; stdcall; external 'LZ32.dll' name 'LZOpenFileA';
function LZSeek(LZFile: Integer; SeekTo: Longint; Mode: Integer): Longint; stdcall; external 'LZ32.dll' name 'LZSeek';
function LZRead(LZFile: Integer; Buf: PChar; Count: Integer): Integer; stdcall; external 'LZ32.dll' name 'LZRead';
procedure LZClose(LZFile: Integer); stdcall; external 'LZ32.dll' name 'LZClose';

end.

