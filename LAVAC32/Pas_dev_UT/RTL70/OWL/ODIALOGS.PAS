
{*******************************************************}
{                                                       }
{       Turbo Pascal for Windows Run-time Library       }
{       ObjectWindows Unit                              }
{                                                       }
{       Copyright (c) 1991 Borland International        }
{                                                       }
{*******************************************************}

unit ODialogs;

{$T-,R-}

interface

uses WinProcs, WinTypes, Messages, Objects, OWindows, Validate;

const

{ TCheckBox check states }

  bf_Unchecked = 0;
  bf_Checked   = 1;
  bf_Grayed    = 2;

{ Message number used for input validation }

  wm_PostInvalid = wm_User + 400;

type

{ TDialog creation attributes }

  TDialogAttr = record
    Name: PChar;
    Param: LongInt;
  end;

{ TDialog object }

  PDialog = ^TDialog;
  TDialog = object(TWindowsObject)
    Attr: TDialogAttr;
    IsModal: Boolean;
    constructor Init(AParent: PWindowsObject; AName: PChar);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Store(var S: TStream);
    function Create: Boolean; virtual;
    function Execute: Integer; virtual;
    procedure EndDlg(ARetValue: Integer); virtual;
    function GetItemHandle(DlgItemID: Integer): HWnd;
    function SendDlgItemMsg(DlgItemID: Integer; AMsg, WParam: Word;
      LParam: LongInt): LongInt;
    procedure Ok(var Msg: TMessage); virtual id_First + id_Ok;
    procedure Cancel(var Msg: TMessage); virtual id_First + id_Cancel;
    procedure WMInitDialog(var Msg: TMessage);
      virtual wm_First + wm_InitDialog;
    procedure WMQueryEndSession(var Msg: TMessage);
      virtual wm_First + wm_QueryEndSession;
    procedure WMClose(var Msg: TMessage);
      virtual wm_First + wm_Close;
    procedure WMPostInvalid(var Msg: TMessage);
      virtual wm_First + wm_PostInvalid;
    procedure DefWndProc(var Msg: TMessage); virtual;
  end;

{ TDlgWindow object }

  PDlgWindow = ^TDlgWindow;
  TDlgWindow = object(TDialog)
    constructor Init(AParent: PWindowsObject; AName: PChar);
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    function Create: Boolean; virtual;
  end;

{ TControl object }

  PControl = ^TControl;
  TControl = object(TWindow)
    constructor Init(AParent: PWindowsObject; AnId: Integer;
      ATitle: PChar; X, Y, W, H: Integer);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    function Register: Boolean; virtual;
    function GetClassName: PChar; virtual;
    procedure WMPaint(var Msg: TMessage); virtual wm_First + wm_Paint;
  end;

{ TGroupBox object }

  PGroupBox = ^TGroupBox;
  TGroupBox = object(TControl)
    NotifyParent: Boolean;
    constructor Init(AParent: PWindowsObject; AnID: Integer;
      AText: PChar; X, Y, W, H: Integer);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetClassName: PChar; virtual;
    procedure SelectionChanged(ControlId: Integer); virtual;
  end;

{ TButton object }

  PButton = ^TButton;
  TButton = object(TControl)
    constructor Init(AParent: PWindowsObject; AnId: Integer;
      AText: PChar; X, Y, W, H: Integer; IsDefault: Boolean);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    function GetClassName: PChar; virtual;
  end;

{ TCheckBox object }

  PCheckBox = ^TCheckBox;
  TCheckBox = object(TButton)
    Group: PGroupBox;
    constructor Init(AParent: PWindowsObject; AnID: Integer;
      ATitle: PChar; X, Y, W, H: Integer; AGroup: PGroupBox);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    procedure Check;
    procedure Uncheck;
    procedure Toggle;
    function GetClassName: PChar; virtual;
    function GetCheck: Word;
    procedure SetCheck(CheckFlag: Word);
    function Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
    procedure BNClicked(var Msg: TMessage);
      virtual nf_First + bn_Clicked;
  end;

{ TRadioButton object }

  PRadioButton = ^TRadioButton;
  TRadioButton = object(TCheckBox)
    constructor Init(AParent: PWindowsObject; AnID: Integer;
      ATitle: PChar; X, Y, W, H: Integer; AGroup: PGroupBox);
    function GetClassName: PChar; virtual;
  end;

{ TStatic object }

  PStatic = ^TStatic;
  TStatic = object(TControl)
    TextLen: Word;
    constructor Init(AParent: PWindowsObject; AnId: Integer;
      ATitle: PChar; X, Y, W, H: Integer; ATextLen: Word);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word;
      ATextLen: Word);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetClassName: PChar; virtual;
    function GetText(ATextString: PChar; MaxChars: Integer): Integer;
    function GetTextLen: Integer;
    procedure SetText(ATextString: PChar);
    procedure Clear;
    function Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
  end;

{ TEdit object }

  PEdit	= ^TEdit;
  TEdit = object(TStatic)
    Validator: PValidator;
    constructor Init(AParent: PWindowsObject; AnId: Integer; ATitle: PChar;
       X, Y, W, H: Integer; ATextLen: Word; Multiline: Boolean);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word;
      ATextLen: Word);
    constructor Load(var S: TStream);
    destructor  Done; virtual;
    function GetClassName: PChar; virtual;
    procedure Undo;
    function CanClose: Boolean; virtual;
    function CanUndo: Boolean;
    procedure Paste;
    procedure Copy;
    procedure Cut;
    function GetNumLines: Integer;
    function GetLineLength(LineNumber: Integer): Integer;
    function GetLine(ATextString: PChar;
      StrSize, LineNumber: Integer): Boolean;
    procedure GetSubText(ATextString: PChar; StartPos, EndPos: Integer);
    function DeleteSubText(StartPos, EndPos: Integer): Boolean;
    function DeleteLine(LineNumber: Integer): Boolean;
    procedure GetSelection(var StartPos, EndPos: Integer);
    function DeleteSelection: Boolean;
    function IsModified: Boolean;
    procedure ClearModify;
    function GetLineFromPos(CharPos: Integer): Integer;
    function GetLineIndex(LineNumber: Integer): Integer;
    function IsValid(ReportError: Boolean): Boolean;
    procedure Scroll(HorizontalUnit, VerticalUnit: Integer);
    function SetSelection(StartPos, EndPos: Integer): Boolean;
    procedure Insert(ATextString: PChar);
    function Search(StartPos: Integer; AText: PChar; CaseSensitive: Boolean): Integer;
    procedure SetupWindow; virtual;
    procedure SetValidator(AValid: PValidator);
    procedure Store(var S: TStream);
    function  Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
    procedure CMEditCut(var Msg: TMessage);
      virtual  cm_First + cm_EditCut;
    procedure CMEditCopy(var Msg: TMessage);
      virtual  cm_First + cm_EditCopy;
    procedure CMEditPaste(var Msg: TMessage);
      virtual  cm_First + cm_EditPaste;
    procedure CMEditDelete(var Msg: TMessage);
      virtual  cm_First + cm_EditDelete;
    procedure CMEditClear(var Msg: TMessage);
      virtual  cm_First + cm_EditClear;
    procedure CMEditUndo(var Msg: TMessage);
      virtual  cm_First + cm_EditUndo;
    procedure WMChar(var Msg: TMessage);
      virtual  wm_First + wm_Char;
    procedure WMKeyDown(var Msg: TMessage);
      virtual  wm_First + wm_KeyDown;
    procedure WMGetDlgCode(var Msg: TMessage);
      virtual  wm_First + wm_GetDlgCode;
    procedure WMKillFocus(var Msg: TMessage);
      virtual  wm_First + wm_KillFocus;
  end;

{ TListBox message name type }

  TMsgName = (
    mn_AddString, mn_InsertString, mn_DeleteString,
    mn_ResetContent, mn_GetCount, mn_GetText,
    mn_GetTextLen, mn_SelectString, mn_SetCurSel,
    mn_GetCurSel);

{ Multiple selction transfer record }

  PMultiSelRec = ^TMultiSelRec;
  TMultiSelRec = record
    Count: Integer;
    Selections: array[0..32760] of Integer;
  end;

{ TListBox object }

  PListBox = ^TListBox;
  TListBox = object(TControl)
    constructor Init(AParent: PWindowsObject; AnId: Integer;
      X, Y, W, H: Integer);
    function GetClassName: PChar; virtual;
    function AddString(AString: PChar): Integer;
    function InsertString(AString: PChar; Index: Integer): Integer;
    function DeleteString(Index: Integer): Integer;
    procedure ClearList;
    function Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
    function GetCount: Integer;
    function GetString(AString: PChar; Index: Integer): Integer;
    function GetStringLen(Index: Integer): Integer;
    function GetSelString(AString: PChar; MaxChars: Integer): Integer;
    function SetSelString(AString: PChar; Index: Integer): Integer;
    function GetSelIndex: Integer;
    function SetSelIndex(Index: Integer): Integer;
  private
    function GetMsgID(AMsg: TMsgName): Word; virtual;
  end;

{ TComboBox object }

  PComboBox = ^TComboBox;
  TComboBox = object(TListBox)
    TextLen: Word;
    constructor Init(AParent: PWindowsObject; AnID: Integer;
      X, Y, W, H: Integer; AStyle: Word; ATextLen: Word);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Integer;
      ATextLen: Word);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetClassName: PChar; virtual;
    procedure ShowList;
    procedure HideList;
    function Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
    procedure SetupWindow; virtual;
    function GetTextLen: Integer;
    function GetText(Str: PChar; MaxChars: Integer): Integer;
    procedure SetText(Str: PChar);
    function SetEditSel(StartPos, EndPos: Integer): Integer;
    function GetEditSel(var StartPos, EndPos: Integer): Boolean;
    procedure Clear;
  private
    function GetMsgID(AMsg: TMsgName): Word; virtual;
  end;

{ TScrollBar transfer record }

  TScrollBarTransferRec = record
    LowValue: Integer;
    HighValue: Integer;
    Position: Integer;
  end;

{ TScrollBar object }

  PScrollBar = ^TScrollBar;
  TScrollBar = object(TControl)
    LineMagnitude, PageMagnitude: Integer;
    constructor Init(AParent: PWindowsObject; AnID: Integer;
      X, Y, W, H: Integer; IsHScrollBar: Boolean);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetClassName: PChar; virtual;
    procedure SetupWindow; virtual;
    procedure GetRange(var LoVal, HiVal: Integer);
    function GetPosition: Integer;
    procedure SetRange(LoVal, HiVal: Integer);
    procedure SetPosition(ThumbPos: Integer);
    function DeltaPos(Delta: Integer): Integer;
    function Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
    procedure SBLineUp(var Msg: TMessage);
      virtual nf_First + sb_LineUp;
    procedure SBLineDown(var Msg: TMessage);
      virtual nf_First + sb_LineDown;
    procedure SBPageUp(var Msg: TMessage);
      virtual nf_First + sb_PageUp;
    procedure SBPageDown(var Msg: TMessage);
      virtual nf_First + sb_PageDown;
    procedure SBThumbPosition(var Msg: TMessage);
      virtual nf_First + sb_ThumbPosition;
    procedure SBThumbTrack(var Msg: TMessage);
      virtual nf_First + sb_ThumbTrack;
    procedure SBTop(var Msg: TMessage);
      virtual nf_First + sb_Top;
    procedure SBBottom(var Msg: TMessage);
      virtual nf_First + sb_Bottom;
  end;

{ Multi-selection support routines }

function AllocMultiSel(Size: Integer): PMultiSelRec;
procedure FreeMultiSel(P: PMultiSelRec);

{ Stream routine }

procedure RegisterODialogs;

const
  RDialog: TStreamRec = (
    ObjType: 54;
    VmtLink: Ofs(TypeOf(TDialog)^);
    Load:    @TDialog.Load;
    Store:   @TDialog.Store);

const
  RDlgWindow: TStreamRec = (
    ObjType: 55;
    VmtLink: Ofs(TypeOf(TDlgWindow)^);
    Load:    @TDlgWindow.Load;
    Store:   @TDlgWindow.Store);

const
  RControl: TStreamRec = (
    ObjType: 56;
    VmtLink: Ofs(TypeOf(TControl)^);
    Load:    @TControl.Load;
    Store:   @TControl.Store);

const
  RMDIClient: TStreamRec = (
    ObjType: 58;
    VmtLink: Ofs(TypeOf(TMDIClient)^);
    Load:    @TMDIClient.Load;
    Store:   @TMDIClient.Store);

const
  RButton: TStreamRec = (
    ObjType: 59;
    VmtLink: Ofs(TypeOf(TButton)^);
    Load:    @TButton.Load;
    Store:   @TButton.Store);

const
  RCheckBox: TStreamRec = (
    ObjType: 60;
    VmtLink: Ofs(TypeOf(TCheckBox)^);
    Load:    @TCheckBox.Load;
    Store:   @TCheckBox.Store);

const
  RRadioButton: TStreamRec = (
    ObjType: 61;
    VmtLink: Ofs(TypeOf(TRadioButton)^);
    Load:    @TRadioButton.Load;
    Store:   @TRadioButton.Store);

const
  RGroupBox: TStreamRec = (
    ObjType: 62;
    VmtLink: Ofs(TypeOf(TGroupBox)^);
    Load:    @TGroupBox.Load;
    Store:   @TGroupBox.Store);

const
  RListBox: TStreamRec = (
    ObjType: 63;
    VmtLink: Ofs(TypeOf(TListBox)^);
    Load:    @TListBox.Load;
    Store:   @TListBox.Store);

const
  RComboBox: TStreamRec = (
    ObjType: 64;
    VmtLink: Ofs(TypeOf(TComboBox)^);
    Load:    @TComboBox.Load;
    Store:   @TComboBox.Store);

const
  RScrollBar: TStreamRec = (
    ObjType: 65;
    VmtLink: Ofs(TypeOf(TScrollBar)^);
    Load:    @TScrollBar.Load;
    Store:   @TScrollBar.Store);

const
  RStatic: TStreamRec = (
    ObjType: 66;
    VmtLink: Ofs(TypeOf(TStatic)^);
    Load:    @TStatic.Load;
    Store:   @TStatic.Store);

const
  REdit: TStreamRec = (
    ObjType: 67;
    VmtLink: Ofs(TypeOf(TEdit)^);
    Load:    @TEdit.Load;
    Store:   @TEdit.Store);

implementation

uses Strings, OMemory;

{ Used while determining when to validate a TEdit control.  Inhibits
  focus change from validating the control when bringing up a dialog
  to report invalid data. }

const
  ProcessFocus: Boolean = True;

{ TDialog }

{ Constructor for a TDialog object.  Calls TWindowsObject.Init, creating
  an instance thunk for the TDialog. }

constructor TDialog.Init(AParent: PWindowsObject; AName: PChar);
begin
  TWindowsObject.Init(AParent);
  DisableAutoCreate;
  if PtrRec(AName).Seg <> 0 then Attr.Name := StrNew(AName)
  else Attr.Name := AName;
  Attr.Param := 0;
  IsModal := False;
end;

{ Destructor for a TDialog.  TWindowsObject.Done is called to free
  the instance thunk. }

destructor TDialog.Done;
begin
  if PtrRec(Attr.Name).Seg <> 0 then StrDispose(Attr.Name);
  TWindowsObject.Done;
end;

{ Constructor for a TDialog object.  Initializes the TDialog with
  data from the passed TStream. }

constructor TDialog.Load(var S: TStream);
var
  NameIsNumeric: Boolean;
begin
  TWindowsObject.Load(S);
  DisableAutoCreate;
  with Attr do
  begin
    S.Read(NameIsNumeric, SizeOf(NameIsNumeric));
    if NameIsNumeric then S.Read(Name, SizeOf(Name))
    else Name := S.StrRead;
    S.Read(Param, SizeOf(Param));
  end;
  S.Read(IsModal, SizeOf(IsModal));
end;

{ Stores data of the TDialog object in the passed TStream. }

procedure TDialog.Store(var S: TStream);
var
  NameIsNumeric: Boolean;
begin
  TWindowsObject.Store(S);
  with Attr do
  begin
    NameIsNumeric := PtrRec(Name).Seg = 0;
    S.Write(NameIsNumeric, SizeOf(NameIsNumeric));
    if NameIsNumeric then S.Write(Name, SizeOf(Name))
    else S.StrWrite(Name);
    S.Write(Param, SizeOf(Param));
  end;
  S.Write(IsModal, SizeOf(IsModal));
end;

{ Creates an MS-Windows modeless dialog, and associates the modeless
  dialog interface element with the TDialog.  Creation and association is
  not attempted if the Status data field is non-zero. }

function TDialog.Create: Boolean;
var
  HParent: HWnd;
begin
  if Status = 0 then
  begin
    DisableAutoCreate;
    EnableKBHandler;
    IsModal := False;
    if Parent = nil then HParent := 0 else HParent := Parent^.HWindow;
    HWindow := CreateDialogParam(HInstance, Attr.Name, HParent, Instance,
      Attr.Param);
    if HWindow = 0 then Status := em_InvalidWindow;
  end;
  Create := Status = 0;
end;

{ Creates an MS-Windows modal dialog, using the creation attributes
  previously set in the Attr data field.  Associates the modal dialog
  interface element with the TDialog.  Creation and association is not
  attempted if the Status data field is non-zero. }

function TDialog.Execute: Integer;
var
  HParent: HWnd;
  ReturnValue: Integer;
  OldKbHandler: PWindowsObject;
begin
  if Status = 0 then
  begin
    DisableAutoCreate;
    EnableKBHandler;
    IsModal := True;
    if Parent = nil then HParent := 0 else HParent := Parent^.HWindow;
    OldKbHandler := Application^.KBHandlerWnd;
    ReturnValue := DialogBoxParam(HInstance, Attr.Name, HParent, Instance,
      Attr.Param);
    Application^.KBHandlerWnd := OldKbHandler;
    { -1 if the function cannot create the dialog box }
    if ReturnValue = -1 then Status := em_InvalidWindow;
    HWindow := 0;
    Execute := ReturnValue;
  end
  else Execute := Status;
end;

{ Destroys the MS-Windows dialog associated with the TDialog. }

procedure TDialog.EndDlg(ARetValue: Integer);

  procedure DoEnableAutoCreate(P: PWindowsObject); far;
  begin
    if P^.HWindow <> 0 then P^.EnableAutoCreate;
  end;

begin
  if IsModal then
  begin
    ForEach(@DoEnableAutoCreate);
    EndDialog(HWindow, ARetValue)
  end;
end;

{ Responds to an incoming wm_InitDialog message.  This message is sent
  after an MS-Windows dialog is created and before the dialog is displayed.
  Calls SetupWindow to perform set up for the dialog. }

procedure TDialog.WMInitDialog(var Msg: TMessage);
begin
  SetupWindow;
end;

{ Respond to Windows attempt to close close down. Note: A DIALOG needs
  to invert the test because windows expects the opposite of a normal
  window. }

procedure TDialog.WMQueryEndSession(var Msg: TMessage);
begin
  if @Self = Application^.MainWindow then
    Msg.Result := Integer(not Application^.CanClose)
  else Msg.Result := Integer(not CanClose);
end;

{ Responds to a message from a child edit control that its contents
  are invalid.  Posts the invalid message using that child's Validator
  and returns the focus to that child.  This response method is used
  to allow the KillFocus processing for the Edit control to post the
  message outside the KillFocus chain, since posting a message box
  while the focus is being taken causes a number of problems.  The
  TEdit puts the handle to itself in WParam. }

procedure TDialog.WMPostInvalid(var Msg: TMessage);
var
  AnEdit: PEdit;
begin
  SetFocus(Msg.WParam);
  AnEdit := PEdit(GetObjectPtr(Msg.WParam));
  if (AnEdit <> nil) and (AnEdit^.Validator <> nil) then
    AnEdit^.Validator^.Error;
  ProcessFocus := True;
end;

{ Returns the handle of the dialog's control which has the passed Id. }

function TDialog.GetItemHandle(DlgItemID: Integer): HWND;
begin
  GetItemHandle := GetDlgItem(HWindow, DlgItemID);
end;

{ Sends the passed message to the dialog's control which has the passed
  Id. }

function TDialog.SendDlgItemMsg(DlgItemID: Integer; AMsg, WParam: Word;
  LParam: LongInt): LongInt;
begin
  SendDlgItemMsg :=
    SendDlgItemMessage(HWindow, DlgItemID, AMsg, WParam, LParam);
end;

{ Specifies that default processing for an incoming message is to be
  performed by MS-Windows by setting the Result field of the passed Msg
  to zero. }

procedure TDialog.DefWndProc(var Msg: TMessage);
begin
  Msg.Result := 0;
end;

{ Responds to an incoming notification message from a button with an Id
  equal to id_OK.  Calls CanClose.  If the call returns True, calls
  TransferData and then ends the dialog, returning id_OK. }

procedure TDialog.Ok(var Msg: TMessage);
begin
  if IsModal then
  begin
    if CanClose then
    begin
      TransferData(tf_GetData);
      EndDlg(id_OK);
    end;
  end else CloseWindow;
end;

{ Responds to an incoming notification message from a button with an Id
  equal to id_Cancel.  Ends the dialog, returning id_Cancel. }

procedure TDialog.Cancel(var Msg: TMessage);
begin
  if IsModal then EndDlg(id_Cancel) else CloseWindow;
end;

procedure TDialog.WMClose(var Msg: TMessage);
begin
  Cancel(Msg);
end;

{ TDlgWindow }

{ Constructor for a TDlgWindow object.  Calls TDialog.Init, setting
  the auto creation flag to True so that DlgWindow's appearing in
  their parent's child window list will be recreated. }

constructor TDlgWindow.Init(AParent: PWindowsObject; AName: PChar);
begin
  TDialog.Init(AParent, AName);
  EnableAutoCreate;
end;

{ Specifies registration attributes for the MS-Windows window class of the
  TDlgWindow, allowing instances of TDlgWindow to be registered.  Sets the
  fields of the passed TWndClass parameter to the default attributes
  appropriate for a TDlgWindow. }

procedure TDlgWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  AWndClass.style := cs_HRedraw or cs_VRedraw;
  AWndClass.lpfnWndProc := @DefDlgProc;
  AWndClass.cbClsExtra := 0;
  AWndClass.cbWndExtra := DlgWindowExtra;
  AWndClass.hbrBackground := HBrush(color_window + 1);
  AWndClass.lpszMenuName := nil;
  AWndClass.hInstance := HInstance;
  AWndClass.hIcon := LoadIcon(0, idi_Application);
  AWndClass.hCursor := LoadCursor(0, idc_Arrow);
  AWndClass.lpszClassName := GetClassName;
end;

{ Creates an MS-Windows dialog window and associates the dialog window
  interface element with the TDlgWindow.  Calls Self.Register to ensure
  that the TDlgWindow's MS-Windows window class has been registered, then
  calls TDialog.Create. }

function TDlgWindow.Create: Boolean;
begin
  Create := False;
  if Register then Create := TDialog.Create;
end;

{ TControl }

{ Constructor for a TControl.  Calls TWindow.Init, and sets
  creation attributes using the parameters passed and default values. }

constructor TControl.Init(AParent: PWindowsObject; AnId: Integer;
  ATitle: PChar; X, Y, W, H: Integer);
begin
  TWindow.Init(AParent, ATitle);
  Attr.Id := AnId;
  Attr.X := X;
  Attr.Y := Y;
  Attr.W := W;
  Attr.H := H;
  Attr.Style := ws_Child or ws_Visible or ws_Group or ws_TabStop;
end;

{ Constructor for a TControl to be associated with a MS-Windows
  interface element created by MS-Windows from a resource definition.
  Initializes its data fields using passed parameters.  Data transfer
  is enabled for the TControl. }

constructor TControl.InitResource(AParent: PWindowsObject; ResourceID: Word);
begin
  TWindow.InitResource(AParent, ResourceID);
  EnableTransfer;
end;

{ Generates a run-time error (via call to inherited Abstract method)
  because an attempt should not be made to retrieve the window class name
  for an instance of this abstract object type.  Redefines ancestor's
  GetClassName, which returns a pointer to the name of the MS-Windows
  window class of the window object. Descendant classes redefine this
  method to return the MS-Windows window class name for their instances. }

function TControl.GetClassName: PChar;
begin
  Abstract;
end;

{ Redefines ancestor's Register method, which registers an MS-Windows class
  for a window object.  This method simply returns True because TControl
  descendants have pre-registered MS-Windows window classes. }

function TControl.Register: Boolean;
begin
  Register := True;
end;

{ Responds to an incoming wm_Paint message by calling the default window
  procedure, supplied by MS-Windows, which is appropriate for the TControl.
  Redefines ancestor's WMPaint. }

procedure TControl.WMPaint(var Msg: TMessage);
begin
  DefWndProc(Msg);
end;

{ TButton }

{ Constructor for a TButton object.  Initializes its data fields using
  parameters passed and default values. }

constructor TButton.Init(AParent: PWindowsObject; AnId: Integer; AText: PChar;
  X, Y, W, H: Integer; IsDefault:  Boolean);
begin
  TControl.Init(AParent, AnId, AText, X, Y, W, H);
  if IsDefault then
    Attr.Style := Attr.Style or bs_DefPushButton
  else Attr.Style := Attr.Style or bs_PushButton;
end;

{ Constructor for a TButton to be associated with a MS-Windows interface
  element created by MS-Windows from a resource definition. Initializes
  its data fields using passed parameters.  Disables transfer of state
  data for the TButton. }

constructor TButton.InitResource(AParent: PWindowsObject; ResourceID: Word);
begin
  TControl.InitResource(AParent, ResourceID);
  DisableTransfer;
end;

{ Returns the name of the MS-Windows window class for TButtons. }

function TButton.GetClassName: PChar;
begin
  if BWCCClassNames then
    GetClassName := 'BorBtn'
  else
    GetClassName := 'Button';
end;

{ TCheckBox }

{ Constructor for a TCheckBox object.  Initializes the object with data
  from the passed TStream. }

constructor TCheckBox.Load(var S: TStream);
begin
  TButton.Load(S);
  GetSiblingPtr(S, Group);
end;

{ Stores data of the TCheckBox object in the passed TStream. }

procedure TCheckBox.Store(var S: TStream);
begin
  TButton.Store(S);
  PutSiblingPtr(S, Group);
end;

{ Constructor for a TCheckBox object.  Initializes its data fields using
  passed parameters and default values. }

constructor TCheckBox.Init(AParent: PWindowsObject; AnID: Integer;
  ATitle: PChar; X, Y, W, H: Integer; AGroup: PGroupBox);
begin
  TControl.Init(AParent, AnID, ATitle, X, Y, W, H);
  Attr.Style := ws_Child or ws_Visible or ws_TabStop or bs_AutoCheckbox;
  Group := AGroup;
end;

{ Constructor for a TControl to be associated with a MS-Windows
  interface element created by MS-Windows from a resource definition.
  Initializes its data fields using passed parameters.  Data transfer
  is enabled for the TCheckBox. }

constructor TCheckBox.InitResource(AParent: PWindowsObject; ResourceID: Word);
begin
  TButton.InitResource(AParent, ResourceID);
  EnableTransfer;
  Group := nil;
end;

{ Transfers state information for the TCheckBox. The TransferFlag passed
  specifies whether data is to be read from or written to the passed
  buffer, or whether the data element size is simply to be returned. The
  return value is the size (in bytes) of the transfer data. }

function TCheckBox.Transfer(DataPtr: Pointer; TransferFlag: Word): Word;
var
  CheckFlag: Word;
begin
  if TransferFlag = tf_GetData then
  begin
    CheckFlag := GetCheck;
    Move(CheckFlag, DataPtr^, SizeOf(CheckFlag));
  end
  else if TransferFlag = tf_SetData then SetCheck(Word(DataPtr^)); 
  Transfer := SizeOf(CheckFlag);
end;

{ Returns the check state of the associated check box.  Returns bf_Unchecked
  (0), bf_Checked (1), or (if 3-state) bf_Grayed (2). }

function TCheckBox.GetCheck: Word;
begin
  GetCheck := SendMessage(HWindow, bm_GetCheck, 0, 0);
end;

{ Returns the name of the MS-Windows window class for TCheckBox. }

function TCheckBox.GetClassName: PChar;
begin
  if BWCCClassNames then
    GetClassName := 'BorCheck'
  else
    GetClassName := TButton.GetClassName;
end;

{ Sets the check state of the associated check box.  Unchecks, checks, or
  grays the checkbox (if 3-state) according to the CheckFlag passed.
  (Pass bf_Unchecked (0), bf_Checked (1), or bf_Grayed (2)). If a Group has
  been specified for the TCheckBox, notifies the Group that the state of the
  check box has changed. }

procedure TCheckBox.SetCheck(CheckFlag: Word);
begin
  SendMessage(HWindow, bm_SetCheck, CheckFlag, 0);
  if (Group <> nil) then Group^.SelectionChanged(Attr.Id);
end;

{ Places a checkmark in associated check box. }

procedure TCheckBox.Check;
begin
  SetCheck(1);
end;

{ Removes a checkmark from the associated check box. }

procedure TCheckBox.Uncheck;
begin
  SetCheck(0);
end;

{ Toggles the check state of the check box. }

procedure TCheckBox.Toggle;
begin
  if ((GetWindowLong(HWindow, gwl_Style) and bs_Auto3State) =  bs_Auto3State) then
    SetCheck((GetCheck+1) mod 3)
  else SetCheck((GetCheck+1) mod 2);
end;

{ Responds to an incoming bn_Clicked message.  If a Group has been
  specified for the TCheckBox, notifies the Group that the state of
  this TCheckBox has changed. }

procedure TCheckBox.BNClicked(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if (Group <> nil) then
    Group^.SelectionChanged(Attr.Id);
  DefNotificationProc(Msg);
end;

{ TRadioButton }

{ Constructor for a TRadioButton object.  Initializes its data fields
  using passed parameters and default values. }

constructor TRadioButton.Init(AParent: PWindowsObject; AnID: Integer;
  ATitle: PChar; X, Y, W, H: Integer; AGroup: PGroupBox);
begin
  TCheckBox.Init(AParent, AnID, ATitle, X, Y, W, H, AGroup);
  Attr.Style := ws_Child or ws_Visible or bs_AutoRadioButton;
end;

{ Returns the name of the MS-Windows window class for TRadioButton. }

function TRadioButton.GetClassName: PChar;
begin
  if BWCCClassNames then
    GetClassName := 'BorRadio'
  else
    GetClassName := TButton.GetClassName;
end;

{ TGroupBox }

{ Constructor for a TGroupBox object.  Initializes the object with data
  from the passed TStream. }

constructor TGroupBox.Load(var S: TStream);
begin
  TControl.Load(S);
  S.Read(NotifyParent, SizeOf(NotifyParent));
end;

{ Stores data of the TGroupBox object in the passed TStream. }

procedure TGroupBox.Store(var S: TStream);
begin
  TControl.Store(S);
  S.Write(NotifyParent, SizeOf(NotifyParent));
end;

{ Constructor for a TGroupBox object.  Initializes its data fields using
  parameters passed and default values. }

constructor TGroupBox.Init(AParent: PWindowsObject; AnID: Integer;
  AText: PChar; X, Y, W, H: Integer);
begin
  TControl.Init(AParent, AnId, AText, X, Y, W, H);
  NotifyParent := True;
  Attr.Style := (Attr.Style or bs_GroupBox) and (not ws_TabStop);
end;

{ Constructor for a TGroupBox to be associated with a MS-Windows interface
  element created by MS-Windows from a resource definition. Initializes
  its data fields using passed parameters.  Disables transfer of state
  data for the TGroupBox.  }

constructor TGroupBox.InitResource(AParent: PWindowsObject; ResourceID: Word);
begin
  TControl.InitResource(AParent, ResourceID);
  NotifyParent := True;
  DisableTransfer;
end;

{ Returns the name of MS-Windows window class for a TGroupBox. }

function TGroupBox.GetClassName: PChar;
begin
  GetClassName := 'Button';
end;

{ Notifies parent that the selection in the associated groupbox has
  changed.  This method is called by TCheckBoxes grouped in the groupbox
  when their state changes. }

procedure TGroupBox.SelectionChanged(ControlId: Integer);
begin
  if NotifyParent then
    SendMessage(Parent^.HWindow, wm_Command, Attr.ID,
      MakeLong(HWindow, ControlId));
end;

{ TStatic }

{ Constructor for a TStatic object.  Initializes its data fields using
  passed parameters and default values.   By default, an associated
  static control will have left-justified text. }

constructor TStatic.Init(AParent: PWindowsObject; AnId: Integer;
  ATitle: PChar; X, Y, W, H: Integer; ATextLen: Word);
begin
  TControl.Init(AParent, AnId, ATitle, X, Y, W, H);
  TextLen := ATextLen;
  Attr.Style := (Attr.Style or ss_Left) and (not ws_TabStop);
end;

{ Constructor for a TStatic to be associated with a MS-Windows
  interface element created by MS-Windows from a resource definition.
  Initializes its data fields using passed parameters.  Data transfer
  is disabled, by default, for the TStatic. }

constructor TStatic.InitResource(AParent: PWindowsObject; ResourceID: Word;
  ATextLen: Word);
begin
  TControl.InitResource(AParent, ResourceID);
  TextLen := ATextLen;
end;

{ Constructor for a TStatic object.  Initializes the object with data
  from the passed TStream. }

constructor TStatic.Load(var S: TStream);
begin
  TControl.Load(S);
  S.Read(TextLen, SizeOf(TextLen));
end;

{ Stores data of the TStatic object in the passed TStream. }

procedure TStatic.Store(var S: TStream);
begin
  TControl.Store(S);
  S.Write(TextLen, SizeOf(TextLen));
end;

{ Returns the name of the MS-Windows window class for a TStatic control. }

function TStatic.GetClassName: PChar;
begin
  GetClassName := 'Static';
end;

{ Transfers state information for TStatic controls. The TransferFlag passed
  specifies whether data is to be read from or written to the passed
  buffer, or whether the data element size is simply to be returned. The
  return value is the size (in bytes) of the transfer data. TStatic objects
  are different from other TControl objects in one key respect.  If the
  TStatic is created with InitResource then wb_EnableTransfer is False, else
  it is true.  This presupposes that if you are interested in creating a
  TStatic object directly, you probably want to be able to initialize it.
  This behavior can be modified with EnableTransfer/DisableTransfer.}

function TStatic.Transfer(DataPtr: Pointer; TransferFlag: Word): Word;
begin
  if TransferFlag = tf_GetData then
    GetText(DataPtr, TextLen)
  else if TransferFlag = tf_SetData then
    SetText(DataPtr);
  Transfer := TextLen;
end;

{ Fills the passed string with the text of the associated text
  control.  Returns the number of characters copied.  }

function TStatic.GetText(ATextString: PChar; MaxChars: Integer): Integer;
begin
  GetText := GetWindowText(HWindow, ATextString, MaxChars);
end;

{ Returns the length of the control's text }

function TStatic.GetTextLen: Integer;
begin
  GetTextLen := GetWindowTextLength(HWindow);
end;

{ Sets the contents of the associated static text control to the passed
  string. }

procedure TStatic.SetText(ATextString: PChar);
begin
  SetWindowText(HWindow, ATextString);
end;

{ Clears the text of the associated static text control. }

procedure TStatic.Clear;
begin
  SetText('');
end;

{ TEdit }

{ Constructor for a TEdit object.  Initializes its data fields using
  passed parameters and default values.   By default, an associated
  static control will have a border and its text will be left-justified.
  Also by default, an associated multiline edit control will have
  horizontal and vertical scroll bars. }

constructor TEdit.Init(AParent: PWindowsObject; AnId: Integer; ATitle: PChar;
  X, Y, W, H: Integer; ATextLen: Word; Multiline: Boolean);
begin
  TStatic.Init(AParent, AnId, ATitle, X, Y, W, H, ATextLen);
  Attr.Style := (Attr.Style and not ss_Left) or es_Left or
    es_AutoHScroll or ws_Border or ws_TabStop;
  if Multiline then
    Attr.Style := Attr.Style or es_Multiline or es_AutoVScroll or
      ws_VScroll or ws_HScroll;
  Validator := nil;
end;

{ Constructor for a TEdit that is to be associated with a Windows
  resource.  Identical to ancestral InitResource with the addition
  of an initialization for the Validator.
}
constructor TEdit.InitResource(AParent: PWindowsObject; ResourceID: Word;
  ATextLen: Word);
begin
  inherited InitResource(AParent, ResourceID, ATextLen);
  Validator := nil;
end;

{ Constructor for a TEdit object.  Initializes the object with data
  from the passed TStream. }

constructor TEdit.Load(var S: TStream);
begin
  TStatic.Load(S);
  Validator := PValidator(S.Get);
end;

{ Destroys an instance of TEdit by disposing of its Validator (if any),
  and then calling upon the inherited destructor to complete the process. }

destructor TEdit.Done;
begin
  SetValidator(nil);
  inherited Done;
end;

{ Returns the name of the MS-Windows window class for TEdits. }

function TEdit.GetClassName: PChar;
begin
  GetClassName := 'Edit';
end;

{ Only allows the Edit Control to be closed if it passes
  Validation.  Otherwise returns the focus to Self. }

function TEdit.CanClose: Boolean;
var
  OkToClose: Boolean;
begin
  OkToClose := inherited CanClose;
  if OkToClose then
    if IsWindowEnabled(HWindow) and not IsValid(True) then
    begin
      OkToClose := False;
      SetFocus(HWindow);
    end;
  CanClose := OkToClose;
end;

{ Returns a Boolean value indicating whether or not the last change to the
  text of the associated edit control can be undone.  }

function TEdit.CanUndo: Boolean;
begin
  CanUndo := SendMessage(HWindow, em_CanUndo, 0, 0) <> 0;
end;

{ Undoes the last change to the to the text of the associated edit
  control. }

procedure TEdit.Undo;
begin
  SendMessage(HWindow, wm_Undo, 0, 0);
end;

{ Pastes the contents of the clipboard into the text of the associated
  edit control. }

procedure TEdit.Paste;
begin
  SendMessage(HWindow, wm_Paste, 0, 0);
end;

{ Copies the text selected in the associated edit control to the
  clipboard. }

procedure TEdit.Copy;
begin
  SendMessage(HWindow, wm_Copy, 0, 0);
end;

{ Cuts the text selected in the associated edit control into the
  clipboard. }

procedure TEdit.Cut;
begin
  SendMessage(HWindow, wm_Cut, 0, 0);
end;

{ Responds to an incoming "Cut" command (with a cm_EditCut command
  identifier) by calling Self.Cut. }

procedure TEdit.CMEditCut(var Msg: TMessage);
begin
  Cut;
end;
    
{ Responds to an incoming "Copy" command (with a cm_EditCopy command
  identifier) by calling Self.Copy. }

procedure TEdit.CMEditCopy(var Msg: TMessage);
begin
  Copy;
end;

{ Responds to an incoming "Paste" command (with a cm_EditPaste command
  identifier) by calling Self.Paste. }

procedure TEdit.CMEditPaste(var Msg: TMessage);
begin
  Paste;
end;

{ Responds to an incoming "Delete" command (with a cm_EditDelete command
  identifier) by calling Self.Delete. }

procedure TEdit.CMEditDelete(var Msg: TMessage);
begin
  DeleteSelection;
end;

{ Responds to an incoming "Clear" command (with a cm_EditClear command
  identifier) by calling Self.Clear. }

procedure TEdit.CMEditClear(var Msg: TMessage);
begin
  Clear;
end;

{ Responds to an incoming "Undo" command (with a cm_EditUndo command
  identifier) by calling Self.Undo. }

procedure TEdit.CMEditUndo(var Msg: TMessage);
begin
  Undo;
end;

{ Returns the number of lines in the associated edit control.  Returns
  zero if an error occurs or if the edit control contains no text. }

function TEdit.GetNumLines: Integer;
begin
  GetNumLines := SendMessage(HWindow, em_GetLineCount, 0, 0);
end;

{ Returns the length of the line (whose number is passed) in the
 associated edit control.  If -1 is passed as the line number, the
 following applies: returns the length of the line upon which the caret
 is positioned; if text is selected on the line, returns the line length
 minus the number of selected characters; if selected text spans more
 than one line,  returns the length of the lines minus the number of
 selected characters. }

function TEdit.GetLineLength(LineNumber: Integer): Integer;
var
  StartPos: Integer;
begin
  StartPos := -1;
  if (LineNumber > -1) then
    StartPos := GetLineIndex(LineNumber);
  GetLineLength := SendMessage(HWindow, em_LineLength, StartPos, 0);
end;

{ Retrieves the text of the line of the associated edit control with the
  passed line number.  Return False if an error occurs or if the text will
  not fit in the passed buffer. }

function TEdit.GetLine(ATextString: PChar;
  StrSize, LineNumber: Integer): Boolean;
var
  BytesCopied: Integer;
begin
  if (StrSize >= GetLineLength(LineNumber) + 1) then
  begin
    PWord(ATextString)^ := StrSize;
    BytesCopied := SendMessage(HWindow, em_GetLine, LineNumber,
      LongInt(ATextString));
    ATextString[BytesCopied] := #0;
    GetLine := True;
  end
  else GetLine := False;
end;

{ Selects the text in the associated edit control which begins and ends
  at the passed positions. }

function TEdit.SetSelection(StartPos, EndPos: Integer): Boolean;
var
  LValue: LongRec;
begin
  LValue.Lo := StartPos;
  LValue.Hi := EndPos;
  SetSelection := SendMessage(HWindow, em_SetSel, 0, Longint(LValue)) <> 0;
end;

{ Returns, in the passed var parameters, the starting and ending
  positions of the text selected in the associated edit control. }

procedure TEdit.GetSelection(var StartPos, EndPos: Integer);
var
  RetValue: LongRec;
begin
  Longint(RetValue) := SendMessage(HWindow, em_GetSel, 0, 0);
  StartPos := RetValue.Lo;
  EndPos := RetValue.Hi;
end;

{ Returns a Boolean value indicating whether or not the user has changed
  the text in the associated edit control. }

function TEdit.IsModified: Boolean;
begin
  IsModified := (SendMessage(HWindow, em_GetModify, 0, 0) <> 0);
end;

{ Performs the actual validation of Self, returning True if Self
  is valid, and False if not, and setting the focus to Self if
  invalid.  Reports an error to the user if ReportError is True,
  otherwise just returns the validity to allow deferred reporting.
  Local method for use by all other methods which must validate.
  NOTE that validation is only performed for Edit Controls containing
  a single line of text. }

function TEdit.IsValid(ReportError: Boolean): Boolean;
var
  S  : string;
  Sz : array [0..255] of Char;
begin
  IsValid := True;  { Unless proven otherwise }

  if (Validator <> nil) and (GetNumLines <= 1) then
  begin
    if TextLen > High(Sz) then
      GetText(Sz, High(Sz))
    else
      GetText(Sz, TextLen);

    S := StrPas(Sz);

    if ReportError then
      IsValid := Validator^.Valid(S)
    else
      IsValid := Validator^.IsValid(S);
  end;
end;

{ Clears the change flag for the associated edit control. }

procedure TEdit.ClearModify;
begin
  SendMessage(HWindow, em_SetModify, 0, 0);
end;

{ Returns the number of the line of the associated edit control which
  contains the character whose position is passed.  If the position
  passed is greater than the position of the last character, the number
  of the last line is returned. If -1 is passed, the number of the line
  which contains the first selected character is returned. }

function TEdit.GetLineFromPos(CharPos: Integer): Integer;
begin
  GetLineFromPos := SendMessage(HWindow, em_LineFromChar, CharPos, 0);
end;

{ Returns the number of characters in the associated edit control that
  occur before the line whose number is passed.  If -1 is passed, the
  line number of the line upon which the caret is positioned is used. }

function TEdit.GetLineIndex(LineNumber: Integer): Integer;
begin
  GetLineIndex := SendMessage(HWindow, em_LineIndex, LineNumber, 0);
end;

{ Scrolls the text of the associated edit control by the specified
  horizontal and vertical amounts. }

procedure TEdit.Scroll(HorizontalUnit, VerticalUnit: Integer);
var
  LValue: LongRec;
begin
  LValue.Lo := VerticalUnit;
  LValue.Hi := HorizontalUnit;
  SendMessage(HWindow, em_LineScroll, 0, LongInt(LValue));
end;

{ Sets the selection of the associated edit control to the passed string.
  (Does a "paste" type of action without affecting the clipboard). }

procedure TEdit.Insert(ATextString: PChar);
begin
  SendMessage(HWindow, em_ReplaceSel, 0, LongInt(ATextString));
end;

{ Searchs for and selects the given text in the edit control and
  returns the offset of the text or -1 if the text is not found.
  If the StartPos = -1 then it is assumed that the start pos is
  the end of the current selection.
}
function TEdit.Search(StartPos: Integer; AText: PChar;
  CaseSensitive: Boolean): Integer;
var
  SText, Line, Pos: PChar;
  LineSize, LineLen, NumLines, CurLine, Offset, SBeg: Integer;
begin
  Search := -1;
  if AText[0] = #0 then Exit;
  Line := nil;
  LineSize := 0;
  if StartPos = -1 then GetSelection(SBeg, StartPos);
  if CaseSensitive then
    SText := AText else
    SText := AnsiLower(StrNew(AText));
  CurLine := GetLineFromPos(StartPos);
  Offset :=  StartPos - GetLineIndex(CurLine);
  NumLines := GetNumLines;
  while CurLine < NumLines do
  begin
    LineLen := GetLineLength(CurLine);
    if LineLen >= LineSize then
    begin
      if Line <> nil then FreeMem(Line, LineSize);
      LineSize := LineLen + 1;
      Line := MemAlloc(LineSize);
    end;
    if Line = nil then Exit;
    GetLine(Line, LineSize, CurLine);
    if not CaseSensitive then AnsiLower(Line);
    Pos := StrPos(@Line[Offset], SText);
    if Pos <> nil then
    begin
      SBeg := GetLineIndex(CurLine) + (Pos - Line);
      SetSelection(SBeg, SBeg + StrLen(SText));
      Search := SBeg;
      CurLine := MaxInt - 1;
    end;
    Offset := 0;
    Inc(CurLine);
  end;
  if Line <> nil then FreeMem(Line, LineSize);
  if not CaseSensitive then StrDispose(SText);
end;

{ Deletes the selected text in the associated edit control.  Returns
  False if no text is selected. }

function TEdit.DeleteSelection: Boolean;
var
  StartPos, EndPos: Integer;
begin
  DeleteSelection := True;
  GetSelection(StartPos, EndPos);
  if StartPos <> EndPos then
    SendMessage(HWindow, wm_Clear, 0, 0)
  else DeleteSelection := False;
end;

{ Deletes the text of the associated edit control between the passed
  positions.  Returns False if an error occurs. }

function TEdit.DeleteSubText(StartPos, EndPos: Integer): Boolean;
begin
  DeleteSubText :=
    SetSelection(StartPos, EndPos) and DeleteSelection;
end;

{ Deletes the text at the passed line number in the associated edit
  control.  If -1 is passed, deletes the current line.  Returns False
  if the line passed is out of range (and not -1) or if an error occurs. }

function TEdit.DeleteLine(LineNumber: Integer): Boolean;
var
  FirstPos, LastPos: Integer;
begin
  DeleteLine := False;
  if LineNumber = -1 then LineNumber := GetLineFromPos(GetLineIndex(-1));
  FirstPos := GetLineIndex(LineNumber);
  if FirstPos <> -1 then
  begin
    LastPos := GetLineIndex(LineNumber + 1);
    if LastPos = -1 then LastPos := FirstPos + GetLineLength(LineNumber);
    if (FirstPos = 0) and (FirstPos = LastPos) then
    begin
      SetText('');
      DeleteLine := True;
    end
    else
      DeleteLine := DeleteSubText(FirstPos, LastPos);
  end;
end;

{ Retrieves the text of the associated edit control between the passed
  positions. }

procedure TEdit.GetSubText(ATextString: PChar;
  StartPos, EndPos: Integer);
const
  cr_lf: PChar = #13#10;
var
  StartLine, EndLine, StartChar, EndChar: Integer;
  TempSize, TempIndex, TempStart, TempEnd: Integer;
  TempLine, TempLineLength: Integer;
  OkToContinue: Boolean;
  PLine: PChar;
begin
  if EndPos >= StartPos then
  begin
    StartLine := GetLineFromPos(StartPos);
    EndLine := GetLineFromPos(EndPos);
    StartChar := StartPos - GetLineIndex(StartLine);
    EndChar := EndPos - GetLineIndex(EndLine);
    TempIndex := 0;
    OkToContinue := True;
    for TempLine := StartLine to EndLine do
      if OkToContinue then
      begin
	TempLineLength := GetLineLength(TempLine);
        Inc(TempLineLength, 2); { Count the CR/LF }
        { Allocate memory for the line, leaving room for the terminating 0 }
	GetMem(PLine, TempLineLength + 1);
	if TempLine = StartLine then TempStart := StartChar
	else TempStart := 0;
	if TempLine = EndLine then TempEnd := EndChar
	else TempEnd := TempLineLength;
	TempSize := TempEnd - TempStart;
	if GetLine(PLine, TempLineLength + 1, TempLine) then
	begin
          StrCat(PLine, cr_lf); { Add back then CR/LF }
	  StrMove(@ATextString[TempIndex], @PLine[TempStart], TempSize);
	  TempIndex := TempIndex + TempSize;
        end
	else OkToContinue := False;
	FreeMem(PLine, TempLineLength + 1);
      end;
    ATextString[TempIndex] := #0;
  end;
end;

{ Stores data of the TEdit object in the passed TStream. }
procedure TEdit.Store(var S: TStream);
begin
  TStatic.Store(S);
  S.Put(Validator);
end;

{ Sets the given Validator object to be Self's validator.  Disposes
  of the current validator, if any. }

procedure TEdit.SetValidator(AValid: PValidator);
begin
  if Validator <> nil then Validator^.Free;
  Validator := AValid;
end;

{ The window belongs to us if any of the window handles has an object
  attached }

function IsOurs(Wnd: HWnd): Boolean;
begin
  while (Wnd <> 0) and (GetObjectPtr(Wnd) = nil) do
    Wnd := GetParent(Wnd);
  IsOurs := Wnd <> 0;
end;

{ Validates Self whenever the focus is about to be lost.
  Holds onto the focus if Self is not valid.  Checks first
  to make sure that the focus is not being taken by either
  (a) another app, or (b) a Cancel button, or (c) an OK
  button (in which case CanClose will validate); in each case,
  we don't want to validate. }

procedure TEdit.WMKillFocus(var Msg: TMessage);
var
  BtnId : Integer;
begin
  if ProcessFocus and IsOurs(Msg.WParam) then
  begin
    BtnId := GetDlgCtrlID(Msg.WParam);

    { Note that we do not allow IsValid to post the message
      box, since the change of focus resulting from that message
      will interfere with the change we are in the process of
      completing.  Instead, post a message to the Parent informing
      it of the validation failure, and providing it with a handle
      to Self. }

    if (BtnId <> id_Cancel) and (BtnId <> id_Ok) and not IsValid(False) then
    begin
      DefWndProc(Msg);
      ProcessFocus := False;
      PostMessage(Parent^.HWindow, wm_PostInvalid, HWindow, 0);
      Msg.Result := 0;
      Exit;
    end
  end;
  DefWndProc(Msg);
end;

{ Validates Self whenever a character is entered.  Allows
  the character entry to be processed normally, then validates
  the result and restores Self's text to its original state
  if there is an incorrect entry.

  By default, the SupressFill parameter of the IsValidInput
  method call to the Validator is set to False, so that it
  is free to modify the string, if it is so configured. }

procedure TEdit.WMChar(var Msg: TMessage);
var
  S         : string;
  Sz, OldSz : array [0..255] of Char;
  Len       : Integer;
  StartPos, EndPos: Integer;
  WasAppending: Boolean;
begin
  if (Validator <> nil) and (GetNumLines <= 1) and
    (Msg.wParam <> vk_Back) then
  begin
    Len := TextLen;
    if Len > High(OldSz) then Len := High(OldSz);
    GetText(OldSz, Len);
    GetSelection(StartPos, EndPos);
    WasAppending := EndPos = StrLen(OldSz);

    DefWndProc(Msg);      { Process the new char ... }

    GetText(Sz, Len);
    S := StrPas(Sz);      { Validator expects a Pascal string }

    { Run the result of the edit through the validator.  If incorrect,
      then restore the original text.  Otherwise, set the (possibly)
      modified result of the validation back into the edit control,
      so the results of the auto-fill (if any) can be viewed.
    }
    GetSelection(StartPos, EndPos);
    if (Validator^.Options and voOnAppend = 0) or
      (WasAppending and (EndPos = StrLen(Sz))) then
    begin
      if not Validator^.IsValidInput(S, False) then
        SetText(OldSz)
      else
      begin
        StrPCopy(Sz, S);
        SetText(Sz);
        if (StartPos >= StrLen(OldSz)) and (StrLen(Sz) > StrLen(OldSz)) then
          StartPos := StrLen(Sz);
        if (EndPos >= StrLen(OldSz)) and (StrLen(Sz) > StrLen(OldSz)) then
          EndPos := StrLen(Sz);
      end;
      SetSelection(StartPos, EndPos);
    end
    else
    begin
      if EndPos = StrLen(Sz) then
        if not Validator^.IsValidInput(S, False) then
          Validator^.Error;
    end;
  end
  else
    DefWndProc(Msg);
end;

{ Responds to the GetDlgCode query according to the
  current state of the control.  If the edit control
  contains valid input, then TABs are allowed for
  changing focus.  Otherwise, requests that TABs be
  sent to Self, where we will generate the Invalid
  message (See WMKeyDown below). }

procedure TEdit.WMGetDlgCode(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if not IsValid(False) then
    Msg.Result := Msg.Result or dlgc_WantTab;
end;

{ If the TAB key is sent to the Edit Control, check
  the validity before allowing the focus to change.
  The control will only get a TAB if WMGetDlgCode (above)
  allows it, which is done when the control contains
  invalid input (we re-validate here just for completeness,
  in case descendants redefine any of this behavior).

  We need to validate on TAB focus-changes because there
  is a case not handled by WMKillFocus: when focus is
  lost to an OK or CANCEL button by tabbing. }

procedure TEdit.WMKeyDown(var Msg: TMessage);
var
  WasAppending: Boolean;
  StartSel, EndSel: Integer;
  Sz: array[0..255] of Char;
  S: String;
begin
  if (Msg.WParam = vk_Tab) then
    if not IsValid(True) then
      Exit;
  if (Validator <> nil) and (Validator^.Options and voOnAppend <> 0)
    and (GetNumLines <= 1) then
  begin
    GetSelection(StartSel, EndSel);
    GetText(Sz, SizeOf(Sz));
    WasAppending := EndSel = StrLen(Sz);
    DefWndProc(Msg);
    if not WasAppending then
    begin
      GetSelection(StartSel, EndSel);
      GetText(Sz, SizeOf(Sz));
      S := StrPas(Sz);
      if (EndSel = StrLen(Sz)) and
          not Validator^.IsValidInput(S, False) then
        Validator^.Error;
    end;
  end
  else    
    DefWndProc(Msg);     { Else just ignore the TAB }
end;

{ Transfers state information for TEdit controls. The TransferFlag passed
  specifies whether data is to be read from or written to the passed
  buffer, or whether the data element size is simply to be returned. The
  return value is the size (in bytes) of the transfer data.  TEdits trans-
  fer their data in one of two ways: if the TEdit does not own a Validator,
  it simply uses the inherited Transfer to transfer the edit text in the
  usual fashion.  If a Validator exists, however, it is used to transfer
  the data in the actual converted form corresponding to the Validator.
  This allows the application to treat the Edit control as, for example,
  an integer editor. }

function TEdit.Transfer(DataPtr: Pointer; TransferFlag: Word): Word;
var
  VTrans: TVTransfer;
  Sz    : PChar;
  S     : string;
  Trans : Word;
begin
  if (Validator <> nil) and (GetNumLines <= 1) then
  begin
    if TransferFlag = tf_GetData then
      VTrans := vtGetData   {GetText(DataPtr, TextLen)}
    else if TransferFlag = tf_SetData then
      VTrans := vtSetData   {SetText(DataPtr);}
    else
      VTrans := vtDataSize;

    GetMem(Sz, TextLen);
    GetText(Sz, TextLen);
    S := StrPas(Sz);

    Trans := Validator^.Transfer(S, DataPtr, VTrans);

    { If the validator does not implement a Transfer function, it will
      report a transfer amount of zero bytes.  In that case, we revert
      to the standard transfer behavior.  Otherwise, complete the transfer
      by setting the result of a SetData transfer back into the control. }

    if Trans = 0 then
      Trans := inherited Transfer(DataPtr, TransferFlag)
    else
      if VTrans = vtSetData then
      begin
        if Length(S) > TextLen-1 then
        begin
          FreeMem(Sz, TextLen);
          GetMem(Sz, Length(S)+1);
        end;
        StrPCopy(Sz, S);
        SetText(Sz);
      end;
    Transfer := Trans;
    FreeMem(Sz, TextLen);
  end
  else
    Transfer := inherited Transfer(DataPtr, TransferFlag);
end;

{ Limits the amount of text that an edit control can have to the
  value of TextLen }

procedure TEdit.SetupWindow;
begin
  TStatic.SetupWindow;
  if TextLen <> 0 then SendMessage(HWindow, em_LimitText, TextLen - 1, 0);
end;

{ TListBox }

{ Constructor for an instance of TListBox.  Initializes its data fields
  using parameters passed and default values.  By default, an MS-Windows
  listbox associated with the TListBox will: be visible upon creation;
  have a border and a vertical scrollbar; maintain entries in alphabetical
  order; and notify its parent when a selection is made. }

constructor TListBox.Init(AParent: PWindowsObject; AnId: Integer;
  X, Y, W, H: Integer);
begin
  TControl.Init(AParent, AnId, nil, X, Y, W, H);
  Attr.Style := Attr.Style or lbs_Standard;
end;

{ Returns the name of MS-Windows window class for a TListBox. }

function TListBox.GetClassName: PChar;
begin
  GetClassName := 'Listbox';
end;

{ Transfers state information for a TListBox. The TransferFlag passed
  specifies whether data is to be read from or written to the passed
  buffer, or whether the data element size is simply to be returned.  The
  return value is the size (in bytes) of the transfer data. }

function TListBox.Transfer(DataPtr: Pointer; TransferFlag: Word): Word;
type
  PSingleRec = ^TSingleRec;
  TSingleRec = record
    Strings: PStrCollection;
    Selection: Integer;
  end;
  PMultiRec = ^TMultiRec;
  TMultiRec = record
    Strings: PStrCollection;
    Selections: PMultiSelRec;
  end;
var
  I: Integer;
  Style: LongInt;

  procedure DoAdd(P: PChar); far;
  begin
    AddString(P);
  end;

begin
  Style := GetWindowLong(HWindow, gwl_Style);
  if TransferFlag = tf_GetData then
    if Style and lbs_MultipleSel <> lbs_MultipleSel then
      with PSingleRec(DataPtr)^ do
	Selection := Integer(SendMessage(HWindow, lb_GetCurSel, 0, 0))
    else
      with PMultiRec(DataPtr)^ do
      begin
	FreeMultiSel(Selections);
	I := Integer(SendMessage(HWindow, lb_GetSelCount, 0, 0));
	Selections := AllocMultiSel(I);
	if Selections <> nil then
	  SendMessage(HWindow, lb_GetSelItems, I,
	    LongInt(@Selections^.Selections));
      end
  else if TransferFlag = tf_SetData then
    if Style and lbs_MultipleSel <> lbs_MultipleSel then
      with PSingleRec(DataPtr)^ do
      begin
	SendMessage(HWindow, lb_ResetContent, 0, 0);
	Strings^.ForEach(@DoAdd);
	SendMessage(HWindow, lb_SetCurSel, Selection, 0);
      end
    else
      with PMultiRec(DataPtr)^ do
      begin
	SendMessage(HWindow, lb_ResetContent, 0, 0);
	Strings^.ForEach(@DoAdd);
	SendMessage(HWindow, lb_SetSel, 0, -1); { Unselect all }
	if Selections <> nil then
	  with Selections^ do
	    for I := 0 to Count - 1  do
	      SendMessage(HWindow, lb_SetSel, 1, Selections[I]);
      end;
  if Style and lbs_MultipleSel <> lbs_MultipleSel then
    Transfer := SizeOf(TSingleRec)
  else Transfer := SizeOf(TMultiRec);
end;

{ Adds a string to an associated listbox.  Returns index of the string
  in the list (the first entry is at index 0).  A negative value is
  returned if an error occurs. }

function TListBox.AddString(AString: PChar): Integer;
begin
  AddString := Integer(SendMessage(HWindow, GetMsgID(mn_AddString),
    0, LongInt(AString)));
end;

{ Inserts a string in the associated listbox at the passed index,
  returning the index of the string in the list.  A negative value is
  returned if an error occurs. }

function TListBox.InsertString(AString: PChar; Index: Integer): Integer;
begin
  InsertString := Integer(SendMessage(HWindow, GetMsgID(mn_InsertString),
    Index, LongInt(AString)));
end;

{ Deletes the string at the passed index in the associated listbox. 
  Returns a count of the entries remaining in the list.  A negative value
  is returned if an error occurs. }

function TListBox.DeleteString(Index: Integer): Integer;
begin
  DeleteString := Integer(SendMessage(HWindow, GetMsgID(mn_DeleteString), 
    Index, 0));
end;

{ Clears all the entries in the associated listbox. }

procedure TListBox.ClearList;
begin
  SendMessage(HWindow, GetMsgID(mn_ResetContent), 0, 0);
end;

{ Returns the number of entries in the associated listbox. A negative
  value is returned if an error occurs. }

function TListBox.GetCount: Integer;
begin
  GetCount := Integer(SendMessage(HWindow, GetMsgID(mn_GetCount), 0, 0));
end; 

{ Retrieves the contents of the string at the passed index of the
  associated listbox, returning the length of the string (in bytes) as
  the value of the call. A negative value is returned if the passed
  index is not valid. }

function TListBox.GetString(AString: PChar; Index: Integer): Integer;
begin
  GetString := Integer(SendMessage(HWindow, GetMsgID(mn_GetText), Index, 
    LongInt(AString)));
end; 

{ Returns the length of the string at the passed index in the associated
  listbox.  Note that the strings in the listbox are stored as
  null-terminated arrays of characters rather than the traditional Pascal
  type of string. The length returned does not include the null 
  terminator.  A negative value is returned if an error occurs. }

function TListBox.GetStringLen(Index: Integer): Integer;
begin
  GetStringLen := Integer(SendMessage(HWindow, GetMsgID(mn_GetTextLen),
    Index, 0));
end; 

{ Retrieves the text of the string which is selected in the associated
  listbox.  Returns the number of characters copied.  -1 is returned if
  no string is selected.  Since the Windows function is not passed a
  size parameter, we have to allocate a string to hold the largest
  string (gotten from a query), and copy a part of it. }

function TListBox.GetSelString(AString: PChar; MaxChars: Integer): Integer;
var
  Index: Integer;
  Length: Integer;
  TempString: PChar;
begin
  GetSelString := -1;
  Index := GetSelIndex;
  Length := GetStringLen(Index);
  if (Index > -1) then
    if (MaxChars >= Length) then
      GetSelString := GetString(AString, Index)
    else
    begin
      TempString := MemAlloc(Length+1);
      if TempString <> nil then
      begin
        GetString(TempString, Index);
        StrLCopy(AString, TempString, MaxChars);
        FreeMem(TempString, Length+1);
        GetSelString := MaxChars;
      end;
    end;
end;

{ Selects the first string in the associated listbox following the passed
  index which begins with the passed string.  Searches for a match
  beginning at the passed Index.  If a match is not found after the last
  string has been compared, the search continues from the beginning of the
  list until a match is found or until the list has been completely
  traversed.  Searches from beginning of list when -1 is passed as the
  index.  Returns the index of the selected string.  A negative value is
  returned if an error occurs. }

function TListBox.SetSelString(AString: PChar; Index: Integer): Integer;
begin
  SetSelString := Integer(SendMessage(HWindow, GetMsgID(mn_SelectString), 
    Word(Index), LongInt(AString)));
end; 

{ Returns the index of the selected string in the associated listbox.  A
  negative value is returned if no string is selected. }

function TListBox.GetSelIndex: Integer;
begin
  GetSelIndex := Integer(SendMessage(HWindow, GetMsgID(mn_GetCurSel), 
    0, 0));
end; 

{ Selects the string at passed index in the associated listbox and forces
  the string into view.  Clears selection when -1 is passed as the index.
  A negative value is returned if an error occurs. }

function TListBox.SetSelIndex(Index: Integer): Integer;
begin
  SetSelIndex := Integer(SendMessage(HWindow, GetMsgID(mn_SetCurSel), 
    Index, 0));
end;

{ Returns the appropriate MS-Windows message Integer identifier for the
  function identified by the passed MsgName string.  Allows instances of
  TComboBox to inherit many TListBox methods. }

function TListBox.GetMsgID(AMsg: TMsgName): Word;
const
  MsgXlat: array[TMsgName] of Word =
    (lb_AddString,    lb_InsertString, lb_DeleteString,
     lb_ResetContent, lb_GetCount,     lb_GetText,
     lb_GetTextLen,   lb_SelectString, lb_SetCurSel,
     lb_GetCurSel);
begin
  GetMsgId := MsgXLat[AMsg];
end;

{ TComboBox }

{ Constructor for a TCheckBox object.  Initializes its data fields using
  parameters passed and default values.  By default, an MS-Windows combobox
  associated with the TComboBox will have a vertical scrollbar and will
  maintain its entries in alphabetical order. }

constructor TComboBox.Init(AParent: PWindowsObject; AnID: Integer;
  X, Y, W, H: Integer; AStyle, ATextLen: Word);
begin
  TListBox.Init(AParent, AnID, X, Y, W, H);
  TextLen := ATextLen;
  Attr.Style :=
    ws_Child or ws_Visible or ws_Group or ws_TabStop or cbs_Sort
    or cbs_AutoHScroll or ws_VScroll or AStyle;
end;

constructor TComboBox.InitResource(AParent: PWindowsObject;
  ResourceID: Integer; ATextLen: Word);
begin
  TListBox.InitResource(AParent, ResourceID);
  TextLen := ATextLen;
end;

{ Constructor for a TComboBox object.  Initializes the object with data
  from the passed TStream. }

constructor TComboBox.Load(var S: TStream);
begin
  TListBox.Load(S);
  S.Read(TextLen, SizeOf(TextLen));
end;

{ Stores data of the TComboBox object in the passed TStream. }

procedure TComboBox.Store(var S: TStream);
begin
  TListBox.Store(S);
  S.Write(TextLen, SizeOf(TextLen));
end;

{ Returns the name of MS-Windows window class for a TComboBox. }

function TComboBox.GetClassName: PChar;
begin
  GetClassName := 'Combobox';
end;

{ Shows the list of an associated drop-down combobox. }

procedure TComboBox.ShowList;
begin
  if GetWindowLong(HWindow, gwl_Style) and cbs_DropDown = cbs_DropDown then
    SendMessage(HWindow, cb_ShowDropDown, 1, 0);
end;

{ Hides the list of an associated drop-down combobox. }

procedure TComboBox.HideList;
begin
  if GetWindowLong(HWindow, gwl_Style) and cbs_DropDown = cbs_DropDown then
    SendMessage(HWindow, cb_ShowDropDown, 0, 0);
end;

function TComboBox.Transfer(DataPtr: Pointer; TransferFlag: Word): Word;
type
  PTranRec = ^TTranRec;
  TTranRec = record
    Strings: PStrCollection;
    Selection: array[0..32767] of Char;
  end;

  procedure DoAdd(P: PChar); far;
  begin
    AddString(P);
  end;

begin
  if TransferFlag = tf_GetData then
    with PTranRec(DataPtr)^ do
      GetWindowText(HWindow, Selection, TextLen)
  else if TransferFlag = tf_SetData then
    with PTranRec(DataPtr)^ do
    begin
      SendMessage(HWindow, cb_ResetContent, 0, 0);
      Strings^.ForEach(@DoAdd);
      SetSelString(Selection, -1);
      SetWindowText(HWindow, Selection);
    end;
  Transfer := SizeOf(Pointer) + TextLen;
end;

{ Returns the appropriate Windows message Integer identifier for the
  function identified by the passed MsgName string. Allows instances
  of TComboBox to inherit many TListBox methods. }

function TComboBox.GetMsgID(AMsg: TMsgName): Word;
const
  MsgXlat: array[TMsgName] of Word =
    (cb_AddString,    cb_InsertString, cb_DeleteString,
     cb_ResetContent, cb_GetCount,     cb_GetLBText,
     cb_GetLBTextLen, cb_SelectString, cb_SetCurSel,
     cb_GetCurSel);
begin
  GetMsgId := MsgXLat[AMsg];
end;

procedure TComboBox.SetupWindow;
begin
  TListBox.SetupWindow;
  if TextLen <> 0 then SendMessage(HWindow, cb_LimitText, TextLen - 1, 0);
end;

{ Returns the lenght of the associated edit control's text }

function TComboBox.GetTextLen: Integer;
begin
  GetTextLen := GetWindowTextLength(HWindow);
end;

{ Fills the supplied string with the text of the associated edit
  control. Returns the number of characters copied. }

function TComboBox.GetText(Str: PChar; MaxChars: Integer): Integer;
begin
  GetText := GetWindowText(HWindow, Str, MaxChars);
end;

{ Sets and selects the contents of the associated edit control to the
  supplied string. }

procedure TComboBox.SetText(Str: PChar);
begin
  if SetSelString(Str, -1) < 0 then
  begin
    SetWindowText(HWindow, Str);
    SetEditSel(0, StrLen(Str));
  end;
end;

{ Selects characters in the edit control of the combo box which
  are between StartPos and EndPos. Returns cm_Err if the combo
  box does not have an edit control. }

function TComboBox.SetEditSel(StartPos, EndPos: Integer): Integer;
begin
  SetEditSel := Integer(SendMessage(HWindow, cb_SetEditSel, 0,
    MakeLong(StartPos, EndPos)));
end;

{ Returns, in the supplied var parameters, the starting and ending
  positions of the text selected in the associated edit control.
  Returns False if the combo box has no edit control }

function TComboBox.GetEditSel(var StartPos, EndPos: Integer): Boolean;
var
  RetValue: LongInt;
begin
  RetValue := SendMessage(HWindow, cb_GetEditSel, 0, 0);
  StartPos := LoWord(RetValue);
  EndPos := HiWord(RetValue);
  GetEditSel := RetValue <> cb_Err;
end;

{ Clears the text of the associated edit control }

procedure TComboBox.Clear;
begin
  SetText('');
end;

{ TScrollBar }

{ Constructor for a TScrollBar object.  Initializes the object with
  data from the passed TStream. }

constructor TScrollBar.Load(var S: TStream);
begin
  TControl.Load(S);
  S.Read(LineMagnitude, SizeOf(LineMagnitude));
  S.Read(PageMagnitude, SizeOf(PageMagnitude));
end;

{ Stores data of the TScrollBar object in the passed TStream. }

procedure TScrollBar.Store(var S: TStream);
begin
  TControl.Store(S);
  S.Write(LineMagnitude, SizeOf(LineMagnitude));
  S.Write(PageMagnitude, SizeOf(PageMagnitude));
end;

{ Constructor for a TScrollBar object.  Initializes its data fields
  (including its creation attributes) using parameters passed and
  default values. If the size attribute (H for horizontal scrollbars,
  W for vertical) is zero, the attribute is set to the appropriate
  system metric. }

constructor TScrollBar.Init(AParent: PWindowsObject; AnID: Integer;
  X, Y, W, H: Integer; IsHScrollBar: Boolean);
begin
  TControl.Init(AParent, AnID, nil, X, Y, W, H);
  LineMagnitude := 1;
  PageMagnitude := 10;
  if IsHScrollBar then
  begin
    Attr.Style := Attr.Style or sbs_Horz;
    if Attr.H = 0 then Attr.H := GetSystemMetrics(sm_CYHScroll);
  end
  else
  begin
    Attr.Style := Attr.Style or sbs_Vert;
    if Attr.W = 0 then Attr.W := GetSystemMetrics(sm_CXVScroll);
  end;
end;

constructor TScrollBar.InitResource(AParent: PWindowsObject; ResourceID: Word);
begin
  TControl.InitResource(AParent, ResourceID);
  LineMagnitude := 1;
  PageMagnitude := 10;
end;

{ Returns the name of MS-Windows window class for a TScrollBar. }

function TScrollBar.GetClassName: PChar;
begin
  GetClassName := 'Scrollbar';
end;

{ Transfers state information for a TScrollbar.  The TransferFlag passed
  specifies whether data is to be read from or written to the passed
  buffer, or whether the data element size is simply to be returned.  The
  return value is the size (in bytes) of the transfer data. }

function TScrollbar.Transfer(DataPtr: Pointer; TransferFlag: Word): Word;
var
  LoVal, HiVal, Pos: Integer;
  NewPtr: Pointer;
begin
  NewPtr := DataPtr;
  if TransferFlag = tf_GetData then
  begin
    GetRange(LoVal, HiVal);
    Pos := GetPosition;
    Move(LoVal, NewPtr^, SizeOf(Integer));
    Inc(LongInt(NewPtr), SizeOf(Integer));
    Move(HiVal, NewPtr^, SizeOf(Integer));
    Inc(LongInt(NewPtr), SizeOf(Integer));
    Move(Pos,   NewPtr^, SizeOf(Integer));
  end
  else if TransferFlag = tf_SetData then
  begin
    LoVal := Integer(NewPtr^);
    Inc(LongInt(NewPtr), SizeOf(Integer));
    HiVal := Integer(NewPtr^);
    Inc(LongInt(NewPtr), SizeOf(Integer));
    Pos := Integer(NewPtr^);
    SetRange(LoVal, HiVal);
    SetPosition(Pos);
  end;
  Transfer := (SizeOf(Integer) * 3);
end;

{ Sets up an associated scrollbar by setting its range to 0..100. }

procedure TScrollBar.SetupWindow;
begin
  TControl.SetupWindow;
  SetRange(0, 100);
end; 

{ Retrieves the range of values that the associated scrollbar can
  return. }

procedure TScrollBar.GetRange(var LoVal, HiVal: Integer);
begin
  GetScrollRange(HWindow, sb_Ctl, LoVal, HiVal);
end;

{ Returns the position of the thumb of the associated scrollbar. }

function TScrollBar.GetPosition: Integer;
begin
  GetPosition := GetScrollPos(HWindow, sb_Ctl);
end;
  
{ Sets the range of values that the associated scrollbar can return. }

procedure TScrollBar.SetRange(LoVal, HiVal: Integer);
begin
  SetScrollRange(HWindow, sb_Ctl, LoVal, HiVal, False);
end;

{ Sets the position of the thumb of the associated scrollbar. }

procedure TScrollBar.SetPosition(ThumbPos: Integer);
var
  LoVal, HiVal: Integer;
begin
  GetRange(LoVal, HiVal);
  if ThumbPos > HiVal then ThumbPos := HiVal
  else if ThumbPos < LoVal then ThumbPos := LoVal;
  if ThumbPos <> GetPosition then
    SetScrollPos(HWindow, sb_Ctl, ThumbPos, True);
end;

{ Changes the position (by Delta) of the thumb of the associated
  scrollbar.  Returns the new position. }

function TScrollBar.DeltaPos(Delta: Integer): Integer;
begin
  if Delta <> 0 then SetPosition(GetPosition + Delta);
  DeltaPos := GetPosition;
end;

{ Responds to an sb_LineUp notification message which the associated
  scrollbar sent to its parent.  Changes the position (by LineMagnitude)
  of the thumb of the associated scrollbar. }

procedure TScrollBar.SBLineUp(var Msg: TMessage);
begin
  DeltaPos(0 - LineMagnitude);
  DefNotificationProc(Msg);
end;

{ Responds to an sb_LineDown notification message which the associated
  scrollbar sent to its parent.  Changes the position (by LineMagnitude)
  of the thumb. }

procedure TScrollBar.SBLineDown(var Msg: TMessage);
begin
  DeltaPos(LineMagnitude);
  DefNotificationProc(Msg);
end;

{ Responds to an sb_PageUp notification message which the associated
  scrollbar sent to its parent.  Changes the position (by PageMagnitude)
  of the thumb. }

procedure TScrollBar.SBPageUp(var Msg: TMessage);
begin
  DeltaPos(0 - PageMagnitude);
  DefNotificationProc(Msg);
end;

{ Responds to an sb_PageDown notification message which the associated
  scrollbar sent to its parent.  Changes the position (by PageMagnitude)
  of the thumb. }

procedure TScrollBar.SBPageDown(var Msg: TMessage);
begin
  DeltaPos(PageMagnitude);
  DefNotificationProc(Msg);
end;

{ Responds to an sb_ThumbPosition notification message which the
  associated scrollbar sent to its parent.  Moves the thumb of the 
  scrollbar to the new position. }

procedure TScrollBar.SBThumbPosition(var Msg: TMessage);
begin
  SetPosition(Msg.LParamLo);
  DefNotificationProc(Msg);
end;

{ Responds to an sb_ThumbTrack notification message which the associated
  scrollbar sent to its parent.  Draws the thumb in the current position
  on the track. }

procedure TScrollBar.SBThumbTrack(var Msg: TMessage);
begin
  SetPosition(Msg.LParamLo);
  DefNotificationProc(Msg);
end;

{ Responds to an sb_Top notification message which the associated
  scrollbar sent to its parent.  Moves the thumb to the top of the
  scrollbar. }

procedure TScrollBar.SBTop(var Msg: TMessage);
var
  Lo, Hi: Integer;
begin
  GetRange(Lo, Hi);
  SetPosition(Lo);
  DefNotificationProc(Msg);
end;

{ Responds to an sb_Bottom notification message which the associated
  scrollbar sent to its parent.  Moves the thumb to the bottom of the
  scrollbar. }

procedure TScrollBar.SBBottom(var Msg: TMessage);
var
  Lo, Hi: Integer;
begin
  GetRange(Lo, Hi);
  SetPosition(Hi);
  DefNotificationProc(Msg);
end;

{ ListBox multiple selection transfer records }

function AllocMultiSel(Size: Integer): PMultiSelRec;
var
  P: PMultiSelRec;
begin
  AllocMultiSel := nil;
  if Size <> 0 then
  begin
    P := MemAlloc( (Size + 1) * 2);
    if P <> nil then
    begin
      P^.Count := Size;
      AllocMultiSel := P;
    end;
  end;
end;

procedure FreeMultiSel(P: PMultiSelRec);
begin
  if P <> nil then FreeMem(P, (P^.Count + 1) * 2);
end;

{ Stream routine }

procedure RegisterODialogs;
begin
  RegisterType(RDialog);
  RegisterType(RDlgWindow);
  RegisterType(RControl);
  RegisterType(RButton);
  RegisterType(RCheckBox);
  RegisterType(RRadioButton);
  RegisterType(RGroupBox);
  RegisterType(RListBox);
  RegisterType(RComboBox);
  RegisterType(RScrollBar);
  RegisterType(RStatic);
  RegisterType(REdit);
end;

end.
