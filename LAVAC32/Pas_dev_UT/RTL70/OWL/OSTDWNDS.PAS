
{*******************************************************}
{                                                       }
{       Turbo Pascal for Windows                        }
{       Standard windows unit for ObjectWindows         }
{                                                       }
{       Copyright (c) 1991 Borland International        }
{                                                       }
{*******************************************************}

unit OStdWnds;

{$R OSTDWNDS.RES}

interface

uses WinTypes, WinProcs, Messages, WinDos, Objects, OWindows, ODialogs,
  OMemory, OStdDlgs, Strings;

type

  { TSearchRec }
  TSearchRec = record
    SearchText: array[0..80] of Char;
    CaseSensitive: Bool;
    ReplaceText: array[0..80] of Char;
    ReplaceAll: Bool;
    PromptOnReplace: Bool;
    IsReplace: Boolean;
  end;

  { TEditWindow  }
  PEditWindow = ^TEditWindow;
  TEditWindow = object(TWindow)
    Editor: PEdit;
    SearchRec: TSearchRec;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
    procedure WMSetFocus(var Msg: TMessage);
      virtual wm_First + wm_SetFocus;
    procedure CMEditFind(var Msg: TMessage);
      virtual cm_First + cm_EditFind;
    procedure CMEditFindNext(var Msg: TMessage);
      virtual cm_First + cm_EditFindNext;
    procedure CMEditReplace(var Msg: TMessage);
      virtual cm_First + cm_EditReplace;
  private
    procedure DoSearch;
  end;

  { TFileWindow }
  PFileWindow = ^TFileWindow;
  TFileWindow = object(TEditWindow)
    FileName: PChar;
    IsNewFile: Boolean;
    constructor Init(AParent: PWindowsObject; ATitle, AFileName: PChar);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function CanClear: Boolean; virtual;
    function CanClose: Boolean; virtual;
    procedure NewFile;
    procedure Open;
    procedure Read;
    procedure SetFileName(AFileName: PChar);
    procedure ReplaceWith(AFileName: PChar);
    function Save: Boolean;
    function SaveAs: Boolean;
    procedure SetupWindow; virtual;
    procedure Write;
    procedure CMFileNew(var Msg: TMessage);
      virtual cm_First + cm_FileNew;
    procedure CMFileOpen(var Msg: TMessage);
      virtual cm_First + cm_FileOpen;
    procedure CMFileSave(var Msg: TMessage);
      virtual cm_First + cm_FileSave;
    procedure CMFileSaveAs(var Msg: TMessage);
      virtual cm_First + cm_FileSaveAs;
  end;

const
  REditWindow: TStreamRec = (
    ObjType: 80;
    VmtLink: Ofs(TypeOf(TEditWindow)^);
    Load:    @TEditWindow.Load;
    Store:   @TEditWindow.Store);

const
  RFileWindow: TStreamRec = (
    ObjType: 81;
    VmtLink: Ofs(TypeOf(TFileWindow)^);
    Load:    @TFileWindow.Load;
    Store:   @TFileWindow.Store);

procedure RegisterStdWnds;

implementation

{ TSearchDialog }

const
  sd_Search          = MakeIntResource($7F10);
  sd_Replace         = MakeIntResource($7F11);
  sd_BCSearch        = MakeIntResource($7F12);
  sd_BCReplace       = MakeIntResource($7F13);
  id_SearchText      = 100;
  id_CaseSensitive   = 101;
  id_ReplaceText     = 102;
  id_ReplaceAll      = 103;
  id_PromptOnReplace = 104;

type
  PSearchDialog = ^TSearchDialog;
  TSearchDialog = object(TDialog)
    constructor Init(AParent: PWindowsObject; Template: PChar;
      var SearchRec: TSearchRec);
  end;

constructor TSearchDialog.Init(AParent: PWindowsObject; Template: PChar;
  var SearchRec: TSearchRec);
var
  C: PWindowsObject;
begin
  TDialog.Init(AParent, Template);
  C := New(PEdit, InitResource(@Self, id_SearchText,
    SizeOf(SearchRec.SearchText)));
  C := New(PCheckBox, InitResource(@Self, id_CaseSensitive));
  if (Template = sd_Replace) or (Template = sd_BCReplace) then
  begin
    C := New(PEdit, InitResource(@Self, id_ReplaceText,
      SizeOf(SearchRec.ReplaceText)));
    C := New(PCheckBox, InitResource(@Self, id_ReplaceAll));
    C := New(PCheckBox, InitResource(@Self, id_PromptOnReplace));
  end;
  TransferBuffer := @SearchRec;
end;

{ TEditWindow }

{ Constructor for a TEditWindow.  Initializes its data fields using passed
  parameters and default values.  Constructs its child edit control. }
constructor TEditWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TWindow.Init(AParent, ATitle);
  Editor := New(PEdit, Init(@Self, 200, nil, 0, 0, 0, 0, 0, True));
  with Editor^.Attr do
    Style := Style or es_NoHideSel;
  FillChar(SearchRec, SizeOf(SearchRec), #0);
end;

{ Load a TEditWindow from the given stream }
constructor TEditWindow.Load(var S: TStream);
begin
  TWindow.Load(S);
  GetChildPtr(S, Editor);
end;

{ Store a TEditWindow to the given stream }
procedure TEditWindow.Store(var S: TStream);
begin
  TWindow.Store(S);
  PutChildPtr(S, Editor);
end;

{ Responds to an incoming wm_Size message by resizing the child edit
  control according to the size of the TEditWindow's client area. }
procedure TEditWindow.WMSize(var Msg: TMessage);
begin
  TWindow.WMSize(Msg);
  SetWindowPos(Editor^.HWindow, 0, -1, -1, Msg.LParamLo+2, Msg.LParamHi+2,
    swp_NoZOrder);
end;

{ Responds to an incoming wm_SetFocus message by setting the focus to the
  child edit control. }
procedure TEditWindow.WMSetFocus(var Msg: TMessage);
begin
  SetFocus(Editor^.HWindow);
end;

procedure TEditWindow.DoSearch;
var
  S: array[0..80] of Char;
  P: Pointer;
  Rslt: Integer;
begin
  Rslt := 0;
  with SearchRec do
    repeat
      Rslt := Editor^.Search(-1, SearchText, CaseSensitive);
      if Rslt = -1 then
      begin
        if not IsReplace or not ReplaceAll then
        begin
          P := @SearchText;
          WVSPrintF(S, '"%0.60s" not found.', P);
          MessageBox(HWindow, S, 'Find error', mb_OK + mb_IconExclamation);
        end;
      end
      else
        if IsReplace then
          if not PromptOnReplace then Editor^.Insert(ReplaceText)
          else
          begin
            Rslt := MessageBox(HWindow, 'Replace this occurrence?',
              'Search/Replace', mb_YesNoCancel + mb_IconQuestion);
            if Rslt = id_Yes then Editor^.Insert(ReplaceText)
            else if Rslt = id_Cancel then Exit;
          end;
    until (Rslt = -1) or not ReplaceAll or not IsReplace;
end;

procedure TEditWindow.CMEditFind(var Msg: TMessage);
var
  Dialog: PChar;
begin
  if BWCCClassNames then
    Dialog := sd_BCSearch
  else
    Dialog := sd_Search;
  if Application^.ExecDialog(New(PSearchDialog, Init(@Self,
    Dialog, SearchRec))) = id_OK then
  begin
    SearchRec.IsReplace := False;
    DoSearch;
  end;
end;

procedure TEditWindow.CMEditFindNext(var Msg: TMessage);
begin
  DoSearch;
end;

procedure TEditWindow.CMEditReplace(var Msg: TMessage);
var
  Dialog: PChar;
begin
  if BWCCClassNames then
    Dialog := sd_BCReplace
  else
    Dialog := sd_Replace;
  if Application^.ExecDialog(New(PSearchDialog, Init(@Self,
    Dialog, SearchRec))) = id_OK then
  begin
    SearchRec.IsReplace := True;
    DoSearch;
  end;
end;

{ TFileWindow }

{ Constructor for a TFileWindow.  Initializes its data fields using
  passed parameters and default values. }
constructor TFileWindow.Init(AParent: PWindowsObject; ATitle,
  AFileName: PChar);
begin
  TEditWindow.Init(AParent, ATitle);
  IsNewFile := True;
  FileName := StrNew(AFileName);
end;

{ Dispose of the file name }
destructor TFileWindow.Done;
begin
  StrDispose(FileName);
  TEditWindow.Done;
end;

{ Load a TFileWindow from the stream }
constructor TFileWindow.Load(var S: TStream);
begin
  TEditWindow.Load(S);
  FileName := S.StrRead;
  IsNewFile := FileName = nil;
end;

{ Store a TFileWindow from the stream }
procedure TFileWindow.Store(var S: TStream);
begin
  TEditWindow.Store(S);
  S.StrWrite(FileName);
end;

{ Performs setup for a TFileWindow, appending 'Untitled' to its caption }
procedure TFileWindow.SetupWindow;
begin
  TEditWindow.SetupWindow;
  SetFileName(FileName);
  if FileName <> nil then Read;
end;

{ Sets the file name of the window and updates the caption.  Assumes
  that the AFileName parameter and the FileName instance variable were
  allocated by StrNew. }
procedure TFileWindow.SetFileName(AFileName: PChar);
var
  NewCaption: array[0..80] of Char;
  P: array[0..1] of PChar;
begin
  if FileName <> AFileName then
  begin
    StrDispose(FileName);
    FileName := StrNew(AFileName);
  end;
  P[0] := Attr.Title;
  if FileName = nil then P[1] := '(Untitled)'
  else P[1] := AFileName;
  if Attr.Title = nil then SetWindowText(HWindow, P[1])
  else
  begin
    WVSPrintF(NewCaption, '%0.40s - %0.37s', P[0]);
    SetWindowText(HWindow, NewCaption);
  end;
end;

{ Begins the edit of a new file, after determining that it is Ok to
  clear the TEdit's text. }
procedure TFileWindow.NewFile;
begin
  if CanClear then
  begin
    Editor^.Clear;
    InvalidateRect(Editor^.HWindow, nil, False);
    Editor^.ClearModify;
    IsNewFile := True;
    SetFileName(nil);
  end;
end;

{ Replaces the current file with the given file. }
procedure TFileWindow.ReplaceWith(AFileName: PChar);
begin
  SetFileName(AFileName);
  Read;
  InvalidateRect(Editor^.HWindow, nil, False);
end;

{ Brings up a dialog allowing the user to open a file into this
  window.  Save as selecting File|Open from the menus. }
procedure TFileWindow.Open;
var
  TmpName: array[0..fsPathName] of Char;
begin
  if CanClear and (Application^.ExecDialog(New(PFileDialog,
     Init(@Self, PChar(sd_FileOpen), StrCopy(TmpName, '*.*')))) = id_Ok) then
    ReplaceWith(TmpName);
end;

{ Reads the contents of a previously-specified file into the TEdit
  child control. }
procedure TFileWindow.Read;
const
  BufferSize = 1024;
var
  CharsToRead: LongInt;
  BlockSize: Integer;
  AStream: PDosStream;
  ABuffer: PChar;
begin
  AStream := New(PDosStream, Init(FileName, stOpen));
  ABuffer := MemAlloc(BufferSize + 1);
  CharsToRead := AStream^.GetSize;
  if ABuffer <> nil then
  begin
    Editor^.Clear;
    while CharsToRead > 0 do
    begin
      if CharsToRead > BufferSize then
        BlockSize := BufferSize
      else BlockSize := CharsToRead;
      AStream^.Read(ABuffer^, BlockSize);
      ABuffer[BlockSize] := Char(0);
      Editor^.Insert(ABuffer);
      CharsToRead := CharsToRead - BlockSize;
    end;
    IsNewFile := False;
    Editor^.ClearModify;
    Editor^.SetSelection(0, 0);
    FreeMem(ABuffer, BufferSize + 1);
  end;
  Dispose(AStream, Done);
end;

{ Saves the contents of the TEdit child control into the file currently
  being editted.  Returns true if the file was saved. }
function TFileWindow.Save: Boolean;
begin
  Save := True;
  if Editor^.IsModified then
    if IsNewFile then Save := SaveAs
    else Write;
end;

{ Saves the contents of the TEdit child control into a file whose name
  is retrieved from the user, through execution of a "Save" file
  dialog.  Returns true if the file was saved. }
function TFileWindow.SaveAs: Boolean;
var
  TmpName: array[0..fsPathName] of Char;
begin
  SaveAs := False;
  if FileName <> nil then StrCopy(TmpName, FileName)
  else TmpName[0] := #0;
  if Application^.ExecDialog(New(PFileDialog,
      Init(@Self, PChar(sd_FileSave), TmpName))) = id_Ok then
  begin
    SetFileName(TmpName);
    Write;
    SaveAs := True;
  end;
end;

{ Writes the contents of the TEdit child control to a previously-specified
  file.  If the operation will cause truncation of the text, first confirms
  (through displaying a message box) that it is OK to proceed. }
procedure TFileWindow.Write;
const
  BufferSize = 1024;
var
  CharsToWrite, CharsWritten: LongInt;
  BlockSize: Integer;
  AStream: PDosStream;
  ABuffer: pointer;
  NumLines: Integer;
begin
  NumLines := Editor^.GetNumLines;
  CharsToWrite := Editor^.GetLineIndex(NumLines-1) +
    Editor^.GetLineLength(NumLines-1);
  AStream := New(PDosStream, Init(FileName, stCreate));
  ABuffer := MemAlloc(BufferSize + 1);
  CharsWritten := 0;
  if ABuffer <> nil then
  begin
    while CharsWritten < CharsToWrite do
    begin
      if CharsToWrite - CharsWritten > BufferSize then
        BlockSize := BufferSize
      else BlockSize := CharsToWrite - CharsWritten;
      Editor^.GetSubText(ABuffer, CharsWritten, CharsWritten + BlockSize);
      AStream^.Write(ABuffer^, BlockSize);
      CharsWritten := CharsWritten + BlockSize;
    end;
    IsNewFile := False;
    Editor^.ClearModify;
    FreeMem(ABuffer, BufferSize + 1);
  end;
  Dispose(AStream, Done);
end;

{ Returns a Boolean value indicating whether or not it is Ok to clear
  the TEdit's text.  Returns True if the text has not been changed, or
  if the user Oks the clearing of the text. }
function TFileWindow.CanClear: Boolean;
var
  S: array[0..fsPathName+27] of Char;
  P: PChar;
  Rslt: Integer;
begin
  CanClear := True;
  if Editor^.IsModified then
  begin
    if FileName = nil then StrCopy(S, 'Untitled file has changed. Save?')
    else
    begin
      P := FileName;
      WVSPrintF(S, 'File "%s" has changed.  Save?', P);
    end;
    Rslt := MessageBox(HWindow, S, 'File Changed', mb_YesNoCancel or
      mb_IconQuestion);
    if Rslt = id_Yes then CanClear := Save
    else CanClear := Rslt <> id_Cancel;
  end;
end;

{ Returns a Boolean value indicating whether or not it is Ok to close
  the TEdit's text.  Returns the result of a call to Self.CanClear. }
function TFileWindow.CanClose: Boolean;
begin
  CanClose := CanClear;
end;

{ Responds to an incoming "New" command (with a cm_FileNew command
  identifier) by calling Self.New. }
procedure TFileWindow.CMFileNew(var Msg: TMessage);
begin
  NewFile;
end;

{ Responds to an incoming "Open" command (with a cm_FileOpen command
  identifier) by calling Self.Open. }
procedure TFileWindow.CMFileOpen(var Msg: TMessage);
begin
  Open;
end;

{ Responds to an incoming "Save" command (with a cm_FileSave command
  identifier) by calling Self.Save. }
procedure TFileWindow.CMFileSave(var Msg: TMessage);
begin
  Save;
end;

{ Responds to an incoming "SaveAs" command (with a cm_FileSaveAs command
  identifier) by calling Self.SaveAs. }
procedure TFileWindow.CMFileSaveAs(var Msg: TMessage);
begin
  SaveAs;
end;

procedure RegisterStdWnds;
begin
  RegisterType(REditWindow);
  RegisterType(RFileWindow);
end;

end.
