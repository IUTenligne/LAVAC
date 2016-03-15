
{*******************************************************}
{                                                       }
{       Turbo Pascal for Windows                        }
{       Standard dialogs unit for ObjectWindows         }
{                                                       }
{       Copyright (c) 1991 Borland International        }
{                                                       }
{*******************************************************}

unit OStdDlgs;

interface

uses WinTypes, WinProcs, Messages, WinDos, OWindows, ODialogs, Strings;

{$R OSTDDLGS}

{ Include resource file constants }

{$I OSTDDLGS.INC}

const
  fsFileSpec = fsFileName + fsExtension;

type
  PFileDialog = ^TFileDialog;
  TFileDialog = object(TDialog)
    Caption: PChar;
    FilePath: PChar;
    PathName: array[0..fsPathName] of Char;
    Extension: array[0..fsExtension] of Char;
    FileSpec: array[0..fsFileSpec] of Char;
    constructor Init(AParent: PWindowsObject; AName, AFilePath: PChar);
    function CanClose: Boolean; virtual;
    procedure SetupWindow; virtual;
    procedure HandleFName(var Msg: TMessage); virtual id_First + id_FName;
    procedure HandleFList(var Msg: TMessage); virtual id_First + id_FList;
    procedure HandleDList(var Msg: TMessage); virtual id_First + id_DList;
  private
    procedure SelectFileName;
    procedure UpdateFileName;
    function UpdateListBoxes: Boolean;
  end;

const
  sd_WNInputDialog = $7F02;     { Normal input dialog template }
  sd_BCInputDialog = $7F05;     { BWCC input dialog template }

const
  id_Prompt = 100;
  id_Input  = 101;

type
  PInputDialog = ^TInputDialog;
  TInputDialog = object(TDialog)
    Caption: PChar;
    Prompt: PChar;
    Buffer: PChar;
    BufferSize: Word;
    constructor Init(AParent: PWindowsObject;
      ACaption, APrompt, ABuffer: PChar; ABufferSize: Word);
    function CanClose: Boolean; virtual;
    procedure SetupWindow; virtual;
  end;

implementation

function GetFileName(FilePath: PChar): PChar;
var
  P: PChar;
begin
  P := StrRScan(FilePath, '\');
  if P = nil then P := StrRScan(FilePath, ':');
  if P = nil then GetFileName := FilePath else GetFileName := P + 1;
end;

function GetExtension(FilePath: PChar): PChar;
var
  P: PChar;
begin
  P := StrScan(GetFileName(FilePath), '.');
  if P = nil then GetExtension := StrEnd(FilePath) else GetExtension := P;
end;

function HasWildCards(FilePath: PChar): Boolean;
begin
  HasWildCards := (StrScan(FilePath, '*') <> nil) or
    (StrScan(FilePath, '?') <> nil);
end;

{ TFileDialog }

constructor TFileDialog.Init(AParent: PWindowsObject;
  AName, AFilePath: PChar);
begin

  { If name is sd_FileOpen then use either sd_BCFileOpen or
    sd_WNFileOpen conditional on BWCCClassNames which is set
    to true if BWCC is used }

  if AName = PChar(sd_FileOpen) then
    if BWCCClassNames then AName := PChar(sd_BCFileOpen)
    else AName := PChar(sd_WNFileOpen);

  { If name is sd_FileSave then use either sd_BCFileSave or
    sd_WNFileSave conditional on BWCCClassNames which is set
    to true if BWCC is used }

  if AName = PChar(sd_FileSave) then
    if BWCCClassNames then AName := PChar(sd_BCFileSave)
    else AName := PChar(sd_WNFileSave);

  TDialog.Init(AParent, AName);
  Caption := nil;
  FilePath := AFilePath;
end;

function TFileDialog.CanClose: Boolean;
var
  PathLen: Word;
begin
  CanClose := False;
  GetDlgItemText(HWindow, id_FName, PathName, fsPathName + 1);
  FileExpand(PathName, PathName);
  PathLen := StrLen(PathName);
  if (PathName[PathLen - 1] = '\') or HasWildCards(PathName) or
    (GetFocus = GetDlgItem(HWindow, id_DList)) then
  begin
    if PathName[PathLen - 1] = '\' then
      StrLCat(PathName, FileSpec, fsPathName);
    if not UpdateListBoxes then
    begin
      MessageBeep(0);
      SelectFileName;
    end;
    Exit;
  end;
  StrLCat(StrLCat(PathName, '\', fsPathName), FileSpec, fsPathName);
  if UpdateListBoxes then Exit;
  PathName[PathLen] := #0;
  if GetExtension(PathName)[0] = #0 then
    StrLCat(PathName, Extension, fsPathName);
  AnsiLower(StrCopy(FilePath, PathName));
  CanClose := True;
end;

procedure TFileDialog.SetupWindow;
begin
  SendDlgItemMessage(HWindow, id_FName, em_LimitText, fsPathName, 0);
  if Caption <> nil then SetWindowText(HWindow, Caption);
  StrLCopy(PathName, FilePath, fsPathName);
  StrLCopy(Extension, GetExtension(PathName), fsExtension);
  if HasWildCards(Extension) then Extension[0] := #0;
  if not UpdateListBoxes then
  begin
    StrCopy(PathName, '*.*');
    UpdateListBoxes;
  end;
  SelectFileName;
end;

procedure TFileDialog.HandleFName(var Msg: TMessage);
begin
  if Msg.LParamHi = en_Change then
    EnableWindow(GetDlgItem(HWindow, id_Ok),
      SendMessage(Msg.LParamLo, wm_GetTextLength, 0, 0) <> 0);
end;

procedure TFileDialog.HandleFList(var Msg: TMessage);
begin
  case Msg.LParamHi of
    lbn_SelChange, lbn_DblClk:
      begin
        DlgDirSelect(HWindow, PathName, id_FList);
        UpdateFileName;
        if Msg.LParamHi = lbn_DblClk then Ok(Msg);
      end;
    lbn_KillFocus:
      SendMessage(Msg.LParamLo, lb_SetCurSel, Word(-1), 0);
  end;
end;

procedure TFileDialog.HandleDList(var Msg: TMessage);
begin
  case Msg.LParamHi of
    lbn_SelChange, lbn_DblClk:
      begin
        DlgDirSelect(HWindow, PathName, id_DList);
        StrCat(PathName, FileSpec);
        if Msg.LParamHi = lbn_DblClk then
          UpdateListBoxes else
          UpdateFileName;
      end;
    lbn_KillFocus:
      SendMessage(Msg.LParamLo, lb_SetCurSel, Word(-1), 0);
  end;
end;

procedure TFileDialog.SelectFileName;
begin
  SendDlgItemMessage(HWindow, id_FName, em_SetSel, 0, $7FFF0000);
  SetFocus(GetDlgItem(HWindow, id_FName));
end;

procedure TFileDialog.UpdateFileName;
begin
  SetDlgItemText(HWindow, id_FName, AnsiLower(PathName));
  SendDlgItemMessage(HWindow, id_FName, em_SetSel, 0, $7FFF0000);
end;

function TFileDialog.UpdateListBoxes: Boolean;
var
  R: Integer;
  Path: array[0..fsPathName] of Char;
begin
  UpdateListBoxes := False;
  if GetDlgItem(HWindow, id_FList) <> 0 then
  begin
    StrCopy(Path, PathName);
    R := DlgDirList(HWindow, Path, id_FList, id_FPath, 0);
    if R <> 0 then DlgDirList(HWindow, '*.*', id_DList, 0, $C010);
  end else
  begin
    StrLCopy(Path, PathName, GetFileName(PathName) - PathName);
    StrLCat(Path, '*.*', fsPathName);
    R := DlgDirList(HWindow, Path, id_DList, id_FPath, $C010);
  end;
  if R <> 0 then
  begin
    StrLCopy(FileSpec, GetFileName(PathName), fsFileSpec);
    StrCopy(PathName, FileSpec);
    UpdateFileName;
    UpdateListBoxes := True;
  end;
end;

{ TInputDialog }

constructor TInputDialog.Init(AParent: PWindowsObject;
  ACaption, APrompt, ABuffer: PChar; ABufferSize: Word);
var
  AName: PChar;
begin
  if BWCCClassNames then
    AName := PChar(sd_BCInputDialog)
  else
    AName := PChar(sd_WNInputDialog);

  TDialog.Init(AParent, AName);

  Caption := ACaption;
  Prompt := APrompt;
  Buffer := ABuffer;
  BufferSize := ABufferSize;
end;

function TInputDialog.CanClose: Boolean;
begin
  GetDlgItemText(HWindow, id_Input, Buffer, BufferSize);
  CanClose := True;
end;

procedure TInputDialog.SetupWindow;
begin
  TDialog.SetupWindow;
  SetWindowText(HWindow, Caption);
  SetDlgItemText(HWindow, id_Prompt, Prompt);
  SetDlgItemText(HWindow, id_Input, Buffer);
  SendDlgItemMessage(HWindow, id_Input, em_LimitText, BufferSize - 1, 0);
end;

end.
