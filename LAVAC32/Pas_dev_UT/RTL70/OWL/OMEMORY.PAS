
{*******************************************************}
{                                                       }
{       Turbo Pascal for Windows Run-time Library       }
{       ObjectWindows Unit                              }
{                                                       }
{       Copyright (c) 1991 Borland International        }
{                                                       }
{*******************************************************}

unit OMemory;

interface

const
  SafetyPoolSize: Word = 8192;

procedure InitMemory;
procedure DoneMemory;
function LowMemory: Boolean;
procedure RestoreMemory;
function MemAlloc(Size: Word): Pointer;
function MemAllocSeg(Size: Word): Pointer;

implementation

uses WinProcs, WinTypes;

const
  SafetyPool: Pointer = nil;
  DisablePool: Boolean = False;

function LowMemory: Boolean;
begin
  LowMemory := SafetyPool = nil;
end;

procedure RestoreMemory;
begin
  if LowMemory then
    GetMem(SafetyPool, SafetyPoolSize);
end;

function MemAlloc(Size: Word): Pointer;
var
  Tmp: Pointer;
begin
  DisablePool := True;
  GetMem(Tmp, Size);
  MemAlloc := Tmp;
  DisablePool := False;
end;

function MemAllocSeg(Size: Word): Pointer;
begin
  MemAllocSeg := GlobalLock(GlobalAlloc(gmem_Fixed, Size));
end;

function HeapFunc(Size: Word): Integer; far;
begin
  if Size <> 0 then
    if DisablePool then HeapFunc := 1
    else if LowMemory then HeapFunc := 0
    else
    begin
      FreeMem(SafetyPool, SafetyPoolSize);
      SafetyPool := nil;
      HeapFunc := 2;
    end;
end;

procedure InitMemory;
begin
  RestoreMemory;
  HeapError := @HeapFunc;
end;

procedure DoneMemory;
begin
  FreeMem(SafetyPool, SafetyPoolSize);
  SafetyPool := nil;
end;

end.