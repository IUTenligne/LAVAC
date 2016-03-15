
{*******************************************************}
{                                                       }
{       Turbo Pascal for Windows Run-time Library       }
{       ObjectWindows Unit                              }
{                                                       }
{       Copyright (c) 1992 Borland International        }
{                                                       }
{*******************************************************}

unit OWindows;

{$T-}

interface

uses WinTypes, WinProcs, Messages, Objects;

{ Include resource file constants }

{$I OWINDOWS.INC}

const

{ TWindowsObject Flags masks }

  wb_KBHandler    = $01;
  wb_FromResource = $02;
  wb_AutoCreate   = $04;
  wb_MDIChild     = $08;
  wb_Transfer     = $10;

{ TWindowsObject Status codes }

  em_InvalidWindow     = -1;
  em_OutOfMemory       = -2;
  em_InvalidClient     = -3;
  em_InvalidChild      = -4;
  em_InvalidMainWindow = -5;

{ TWindowsObject Transfer codes }

  tf_SizeData =	0;
  tf_GetData  =	1;
  tf_SetData  =	2;

type

{ TMessage windows message record }

  PMessage = ^TMessage;
  TMessage = record
    Receiver: HWnd;
    Message: Word;
    case Integer of
      0: (
        WParam: Word;
        LParam: Longint;
	Result: Longint);
      1: (
	WParamLo: Byte;
        WParamHi: Byte;
        LParamLo: Word;
        LParamHi: Word;
        ResultLo: Word;
        ResultHi: Word);
  end;

{ Used by TWindowsObject }

  PMDIClient = ^TMDIClient;
  PScroller = ^TScroller;

{ TWindowsObject object }

  PWindowsObject = ^TWindowsObject;
  TWindowsObject = object(TObject)
    Status: Integer;
    HWindow: HWnd;
    Parent, ChildList: PWindowsObject;
    TransferBuffer: Pointer;
    Instance: TFarProc;
    Flags: Byte;
    constructor Init(AParent: PWindowsObject);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Store(var S: TStream);
    procedure DefWndProc(var Msg: TMessage); virtual {index 8};
    procedure DefCommandProc(var Msg: TMessage); virtual {index 12};
    procedure DefChildProc(var Msg: TMessage); virtual {index 16};
    procedure DefNotificationProc(var Msg: TMessage); virtual {index 20};
    procedure SetFlags(Mask: Byte; OnOff: Boolean);
    function IsFlagSet(Mask: Byte): Boolean;
    function FirstThat(Test: Pointer): PWindowsObject;
    procedure ForEach(Action: Pointer);
    function Next: PWindowsObject;
    function Previous: PWindowsObject;
    procedure Focus;
    function Enable: Boolean;
    function Disable: Boolean;
    procedure EnableKBHandler;
    procedure EnableAutoCreate;
    procedure DisableAutoCreate;
    procedure EnableTransfer;
    procedure DisableTransfer;
    function Register: Boolean; virtual;
    function Create: Boolean; virtual;
    procedure Destroy; virtual;
    function GetId: Integer; virtual;
    function ChildWithId(Id: Integer): PWindowsObject;
    function GetClassName: PChar; virtual;
    function GetClient: PMDIClient; virtual;
    procedure GetChildPtr(var S: TStream; var P);
    procedure PutChildPtr(var S: TStream; P: PWindowsObject);
    procedure GetSiblingPtr(var S: TStream; var P);
    procedure PutSiblingPtr(var S: TStream; P: PWindowsObject);
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    procedure SetupWindow; virtual;
    procedure Show(ShowCmd: Integer);
    function CanClose: Boolean;  virtual;
    function Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
    procedure TransferData(Direction: Word); virtual;
    procedure DispatchScroll(var Msg: TMessage); virtual;
    procedure CloseWindow;
    procedure GetChildren(var S: TStream);
    procedure PutChildren(var S: TStream);
    procedure AddChild(AChild: PWindowsObject);
    procedure RemoveChild(AChild: PWindowsObject);
    function IndexOf(P: PWindowsObject): Integer;
    function At(I: Integer): PWindowsObject;
    function CreateChildren: Boolean;
    function CreateMemoryDC: HDC;
    procedure WMVScroll(var Msg: TMessage); virtual wm_First + wm_VScroll;
    procedure WMHScroll(var Msg: TMessage); virtual wm_First + wm_HScroll;
    procedure WMCommand(var Msg: TMessage); virtual wm_First + wm_Command;
    procedure WMClose(var Msg: TMessage); virtual wm_First + wm_Close;
    procedure WMDestroy(var Msg: TMessage); virtual wm_First + wm_Destroy;
    procedure WMNCDestroy(var Msg: TMessage); virtual wm_First + wm_NCDestroy;
    procedure WMActivate(var Msg: TMessage); virtual wm_First + wm_Activate;
    procedure WMQueryEndSession(var Msg: TMessage);
      virtual wm_First + wm_QueryEndSession;
    procedure CMExit(var Msg: TMessage); virtual cm_First + cm_Exit;
  private
    CreateOrder: Word;
    SiblingList: PWindowsObject;
  end;

{ TWindow creation attributes }

  TWindowAttr = record
    Title: PChar;
    Style: LongInt;
    ExStyle: LongInt;
    X, Y, W, H: Integer;
    Param: Pointer;
    case Integer of
      0: (Menu: HMenu);         { Menu handle }
      1: (Id: Integer);         { Child identifier }
  end;

{ TWindow object }

  PWindow = ^TWindow;
  TWindow = object(TWindowsObject)
    Attr: TWindowAttr;
    DefaultProc: TFarProc;
    Scroller: PScroller;
    FocusChildHandle: THandle;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Store(var S: TStream);
    procedure SetCaption(ATitle: PChar);
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    procedure FocusChild;
    procedure UpdateFocusChild;
    function GetId: Integer; virtual;
    function Create: Boolean; virtual;
    procedure DefWndProc(var Msg: TMessage); virtual;
    procedure WMActivate(var Msg: TMessage);
      virtual wm_First + wm_Activate;
    procedure WMMDIActivate(var Msg: TMessage);
      virtual wm_First + wm_MDIActivate;
    procedure SetupWindow; virtual;
    procedure WMCreate(var Msg: TMessage);
      virtual wm_First + wm_Create;
    procedure WMHScroll(var Msg: TMessage);
      virtual wm_First + wm_HScroll;
    procedure WMVScroll(var Msg: TMessage);
      virtual wm_First + wm_VScroll;
    procedure WMPaint(var Msg: TMessage);
      virtual wm_First + wm_Paint;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure WMSize(var Msg: TMessage);
      virtual wm_First + wm_Size;
    procedure WMMove(var Msg: TMessage);
      virtual wm_First + wm_Move;
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMSysCommand(var Msg: TMessage);
      virtual wm_First + wm_SysCommand;
  private
    procedure UpdateWindowRect;
  end;

{ TMDIWindow object }

  PMDIWindow = ^TMDIWindow;
  TMDIWindow = object(TWindow)
    ClientWnd:  PMDIClient;
    ChildMenuPos: Integer;
    constructor Init(ATitle: PChar; AMenu: HMenu);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    procedure SetupWindow; virtual;
    procedure InitClientWindow; virtual;
    function GetClassName: PChar; virtual;
    function GetClient: PMDIClient; virtual;
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    procedure DefWndProc(var Msg: TMessage); virtual;
    function InitChild: PWindowsObject; virtual;
    function CreateChild: PWindowsObject; virtual;
    procedure CMCreateChild(var Msg: TMessage);
      virtual cm_First + cm_CreateChild;
    procedure TileChildren; virtual;
    procedure CascadeChildren; virtual;
    procedure ArrangeIcons; virtual;
    procedure CloseChildren; virtual;
    procedure CMTileChildren(var Msg: TMessage);
      virtual cm_First + cm_TileChildren;
    procedure CMCascadeChildren(var Msg: TMessage);
      virtual cm_First + cm_CascadeChildren;
    procedure CMArrangeIcons(var Msg: TMessage);
      virtual cm_First + cm_ArrangeIcons;
    procedure CMCloseChildren(var Msg: TMessage);
      virtual cm_First + cm_CloseChildren;
  end;

{ TMDIClient object }

  TMDIClient = object(TWindow)
    ClientAttr: TClientCreateStruct;
    constructor Init(AParent: PMDIWindow);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetClassName: PChar; virtual;
    function Register: Boolean; virtual;

    procedure TileChildren; virtual;
    procedure CascadeChildren; virtual;
    procedure ArrangeIcons; virtual;

    procedure WMPaint(var Msg: TMessage); virtual wm_First + wm_Paint;
  end;

{ TScroller object }

  TScroller = object(TObject)
    Window: PWindow;
    XPos: LongInt;	{ current horizontal pos in horz scroll units }
    YPos: LongInt;	{ current vertical pos in vert scroll units }
    XUnit: Integer;	{ logical device units per horz scroll unit }
    YUnit: Integer;	{ logical device units per vert scroll unit }
    XRange: LongInt;	{ # of scrollable horz scroll units }
    YRange: LongInt;	{ # of scrollable vert scroll units }
    XLine: Integer;	{ # of horz scroll units per line }
    YLine: Integer;	{ # of vert scroll units per line }
    XPage: Integer;	{ # of horz scroll units per page }
    YPage: Integer;	{ # of vert scroll units per page }
    AutoMode: Boolean;  { auto scrolling mode  }
    TrackMode: Boolean; { track scroll mode    }
    AutoOrg: Boolean;   { AutoOrg indicates Scroller offsets origin }
    HasHScrollBar: Boolean;
    HasVScrollBar: Boolean;
    constructor Init(TheWindow: PWindow; TheXUnit, TheYUnit: Integer;
      TheXRange, TheYRange: LongInt);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Store(var S: TStream);
    procedure SetUnits(TheXUnit, TheYUnit: LongInt);
    procedure SetPageSize; virtual;
    procedure SetSBarRange; virtual;
    procedure SetRange(TheXRange, TheYRange: LongInt);
    procedure BeginView(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure EndView; virtual;
    procedure VScroll(ScrollRequest: Word; ThumbPos: Integer); virtual;
    procedure HScroll(ScrollRequest: Word; ThumbPos: Integer); virtual;
    procedure ScrollTo(X, Y: LongInt);
    procedure ScrollBy(Dx, Dy: LongInt);
    procedure AutoScroll; virtual;
    function IsVisibleRect(X, Y: LongInt; XExt, YExt: Integer): Boolean;
  private
    function XScrollValue(ARangeUnit: Longint): Integer;
    function YScrollValue(ARangeUnit: Longint): Integer;
    function XRangeValue(AScrollUnit: Integer): Longint;
    function YRangeValue(AScrollUnit: Integer): Longint;
  end;

{ TApplication object }

  PApplication = ^TApplication;
  TApplication = object(TObject)
    Status: Integer;
    Name: PChar;
    MainWindow: PWindowsObject;
    HAccTable: THandle;
    KBHandlerWnd: PWindowsObject;
    constructor Init(AName: PChar);
    destructor Done; virtual;
    function IdleAction: Boolean; virtual;
    procedure InitApplication; virtual;
    procedure InitInstance; virtual;
    procedure InitMainWindow; virtual;
    procedure Run; virtual;
    procedure SetKBHandler(AWindowsObject: PWindowsObject);
    procedure MessageLoop; virtual;
    function ProcessAppMsg(var Message: TMsg): Boolean; virtual;
    function ProcessDlgMsg(var Message: TMsg): Boolean; virtual;
    function ProcessAccels(var Message: TMsg): Boolean; virtual;
    function ProcessMDIAccels(var Message: TMsg): Boolean; virtual;
    function MakeWindow(AWindowsObject: PWindowsObject): PWindowsObject; virtual;
    function ExecDialog(ADialog: PWindowsObject): Integer; virtual;
    function ValidWindow(AWindowsObject: PWindowsObject): PWindowsObject; virtual;
    procedure Error(ErrorCode: Integer); virtual;
    function CanClose: Boolean; virtual;
  end;

{ Utility functions }

function GetObjectPtr(HWindow: HWnd): PWindowsObject;

{ Stream routines }

procedure RegisterOWindows;
procedure RegisterWObjects;

{ Longint inline routines }

function LongMul(X, Y: Integer): Longint;
inline($5A/$58/$F7/$EA);

function LongDiv(X: Longint; Y: Integer): Integer;
inline($59/$58/$5A/$F7/$F9);

{ Application object pointer }

const
  Application: PApplication = nil;

{ Stream registration records }

const
  RWindowsObject: TStreamRec = (
    ObjType: 52;
    VmtLink: Ofs(TypeOf(TWindowsObject)^);
    Load:    @TWindowsObject.Load;
    Store:   @TWindowsObject.Store);

const
  RWindow: TStreamRec = (
    ObjType: 53;
    VmtLink: Ofs(TypeOf(TWindow)^);
    Load:    @TWindow.Load;
    Store:   @TWindow.Store);

const
  RMDIWindow: TStreamRec = (
    ObjType: 57;
    VmtLink: Ofs(TypeOf(TMDIWindow)^);
    Load:    @TMDIWindow.Load;
    Store:   @TMDIWindow.Store);

const
  RScroller: TStreamRec = (
    ObjType: 68;
    VmtLink: Ofs(TypeOf(TScroller)^);
    Load:    @TScroller.Load;
    Store:   @TScroller.Store);

type
  TCreateDialogParam = function (HInstance: THandle; TemplateName: PChar;
    WndParent: HWnd; DialogFunc: TFarProc; InitParam: LongInt): HWnd;
  TDialogBoxParam = function (HInstance: THandle; TemplateName: PChar;
    WndParent: HWnd; DialogFunc: TFarProc; InitParam: LongInt): Integer;
  TDefaultProc = function (Wnd: HWnd; Msg, wParam: Word;
    lParam: LongInt): LongInt;
  TMessageBox = function (WndParent: HWnd; Txt, Caption: PChar;
    TextType: Word): Integer;

const
  CreateDialogParam: TCreateDialogParam = WinProcs.CreateDialogParam;
  DialogBoxParam: TDialogBoxParam = WinProcs.DialogBoxParam;
  DefWndDlgProc: TDefaultProc = WinProcs.DefWindowProc;
  DefMDIDlgProc: TDefaultProc = WinProcs.DefMDIChildProc;
  DefDlgProc: TDefaultProc = WinProcs.DefDlgProc;
  MessageBox: TMessageBox = WinProcs.MessageBox;

  BWCCClassNames: Boolean = False;

implementation

uses Strings, OMemory, ODialogs;

type

{ Windows window procedure type }

  TWindowProc = function(Window: HWND; Message: Word; WParam: Word;
    LParam: Longint): Longint;

{ Fixup list for TWindowsObject stream support }

  PFixupList = ^TFixupList;
  TFixupList = array[1..4096] of Pointer;

{ Object instance jump vector }

  PObjectInstance = ^TObjectInstance;
  TObjectInstance = record
    Code: Byte;
    Offset: Integer;
    case Integer of
      0: (Next: PObjectInstance);
      1: (ObjectPtr: PObject);
  end;

{ Object instance block }

  PInstanceBlock = ^TInstanceBlock;
  TInstanceBlock = record
    Next: Word;
    Code: array[1..5] of Byte;
    WndProcPtr: Pointer;
    Instances: array[0..34] of TObjectInstance;
  end;

{ Virtual method table }

  TVMT = record
    InstSize: Word;
    NegCheckSum: Word;
    DMTPtr: Word;
    Reserved: Word;
    EntryTable: record end;
  end;

{ Dynamic method table }

  TDMT = record
    Parent: Word;
    CacheIndex: Word;
    CacheEntry: Word;
    EntryCount: Word;
    EntryTable: record end;
  end;

{ TWindowsObject VMT offsets }

const
  TWindowsObject_DefWndProc          = SizeOf(TVMT) + 4;
  TWindowsObject_DefCommandProc      = SizeOf(TVMT) + 8;
  TWindowsObject_DefChildProc        = SizeOf(TVMT) + 12;
  TWindowsObject_DefNotificationProc = SizeOf(TVMT) + 16;

{ Object instance manager variables }

const
  InstBlockList: Word = 0;
  InstFreeList: PObjectInstance = nil;
  StdWndProcInstance: TFarProc = nil;

{ Creation window pointer for InitWndProc }

const
  CreationWindow: PWindowsObject = nil;

  psSegProp: array[0..3] of Char = 'OW1';
  psOfsProp: array[0..3] of Char = 'OW2';

{ Fixup list for TWindowsObject stream support }

const
  FixupList: PFixupList = nil;

const
  __OWL_DISPATCH_HOOK__: Pointer = nil;

{ Lookup a dynamic method call:
  In	 AX = Dynamic method index
	 BX = DS-based VMT offset
	 DX = Default method VMT offset

  Out DS:DI = Location of the method's address }

procedure DMTLookup; near; assembler;
asm
	MOV	SI,[BX].TVMT.DMTPtr
	OR	SI,SI
	JE	@@3
	CMP	AX,[SI].TDMT.CacheIndex
	JNE	@@1
	MOV	DI,[SI].TDMT.CacheEntry
        JMP     @@5
@@1:	MOV	DI,DS
	MOV	ES,DI
	CLD
@@2:	MOV	CX,[SI].TDMT.EntryCount
	LEA	DI,[SI].TDMT.EntryTable
	REPNE	SCASW
	JE	@@4
	MOV	SI,ES:[SI].TDMT.Parent
	OR	SI,SI
	JNE	@@2
@@3:	ADD	BX,DX
        MOV     DI,BX
	JMP	@@5
@@4:	MOV	DX,[SI].TDMT.EntryCount
	DEC	DX
	SHL	DX,1
	SUB	DX,CX
	SHL	DX,1
	ADD	DI,DX
        MOV     SI,[BX].TVMT.DMTPtr
	MOV	[SI].TDMT.CacheIndex,AX
	MOV	[SI].TDMT.CacheEntry,DI
@@5:
end;

{ Attach properties to provide a backup method retieving the object
  pointer from a HWindow }

procedure AttachProperties(HWindow: HWnd; Self: Pointer); assembler;
asm
	PUSH	HWindow
        PUSH	DS
        MOV	AX,OFFSET psSegProp
        PUSH	AX
        PUSH	Self.Word[2]
        CALL	SetProp
	PUSH	HWindow
        PUSH	DS
        MOV	AX,OFFSET psOfsProp
        PUSH	AX
        PUSH	Self.Word[0]
        CALL	SetProp
end;

{ Remove properties associated with a window }

procedure RemoveProperties(HWindow: HWnd); assembler;
asm
	PUSH	HWindow
	PUSH	DS
	MOV	AX,OFFSET psSegProp
        PUSH	AX
	CALL	RemoveProp
	PUSH	HWindow
	PUSH	DS
	MOV	AX,OFFSET psOfsProp
        PUSH	AX
	CALL	RemoveProp
end;

{ Return pointer to TWindowsObject given a window handle }

function GetObjectPtr(HWindow: HWND): PWindowsObject; assembler;
asm
	PUSH	HWindow
	CALL    IsWindow
	OR	AX,AX
	CWD
	JZ	@@2
	PUSH	HWindow
	MOV	AX,GWL_WNDPROC
	PUSH	AX
	CALL	GetWindowLong
	MOV	BX,AX
	MOV	ES,DX
	XOR	AX,AX
	CWD
	CMP	ES:[BX].Byte[0], 0E8H
	JNE	@@1
	MOV	CX,2-3
	SUB	CX,BX
	CMP	CX,ES:[BX].Word[1]
	JNE	@@1
	CMP	ES:Word[2],02E5BH
	JNE	@@1
	MOV	AX,ES:[BX].Word[3]
	MOV	DX,ES:[BX].Word[5]
        JMP	@@2
@@1:	PUSH	HWindow
	PUSH	DS
        MOV	AX,OFFSET psSegProp
        PUSH	AX
        CALL	GetProp
        PUSH	AX
        PUSH	HWindow
        PUSH	DS
        MOV	AX,OFFSET psOfsProp
        PUSH	AX
        CALL	GetProp
        POP	DX
@@2:
end;

{ Owl dispatch hook call }
{ In	DS:DI	Location of the method to be called }
{ Out	DS:DI	Location of the method to be called }

procedure DispatchHook(var Msg: TMessage; Self: Pointer); near; assembler;
asm
	PUSH	DI
        PUSH	DS
	LES	SI,Msg
        PUSH	ES:[SI].TMessage.Receiver
        PUSH	ES:[SI].TMessage.Message
        PUSH	ES:[SI].TMessage.wParam
        PUSH	ES:[SI].TMessage.lParamHi
        PUSH	ES:[SI].TMessage.lParamLo
        LES	SI,[DI]
        PUSH	ES
        PUSH	SI
	LES	SI,Self
        PUSH	ES
        PUSH	SI
        CALL	DWORD PTR [__OWL_DISPATCH_HOOK__]
        POP	DS
        POP	DI
        POP	BP
        RET		{ Avoid they RET 8 since the caller needs
			  the parameters left on the stack }
end;

{ Standard window procedure }

function StdWndProc(HWindow: HWND; Message: Word; WParam: Word;
  LParam: Longint): Longint; export; assembler;
asm
	MOV	DX,HWindow
	MOV	ES:[BX].TWindowsObject.HWindow,DX
	XOR	AX,AX
        PUSH	AX			{ ResultHi }
        INC	AX
        PUSH	AX			{ ResultLo }
        PUSH	LParam.Word[2]		{ LParamHi }
        PUSH	LParam.Word[0]		{ LParamLo }
        PUSH	WParam			{ WParam }
        MOV	AX,Message
        PUSH	AX			{ Message }
	PUSH	DX			{ Receiver }
        MOV	DX,SP
        PUSH	SS
        PUSH	DX
        PUSH	ES
        PUSH	BX
        MOV	BX,ES:[BX]
        OR	AX,AX
        JNS	@@1
        MOV	DI,BX
        ADD	DI,TWindowsObject_DefWndProc
        JMP	@@2
@@1:    MOV	DX,TWindowsObject_DefWndProc
	CALL	DMTLookup
@@2:	MOV	CX,__OWL_DISPATCH_HOOK__.Word[2]
        JCXZ	@@3
        CALL	DispatchHook
@@3:    CALL	DWORD PTR [DI]
	ADD	SP,10
	POP	AX
	POP	DX
end;

{ Initialization window procedure }

function InitWndProc(HWindow: HWND; Message: Word; WParam: Word;
  LParam: Longint): Longint; export; assembler;
asm
	PUSH	HWindow
	MOV	AX,gwl_WndProc
	PUSH	AX
	LES	DI,CreationWindow
	LES	DI,ES:[DI].TWindowsObject.Instance
	PUSH	ES
	PUSH	DI
	CALL	SetWindowLong
        PUSH	HWindow
        LES	DI,CreationWindow
        PUSH	ES
        PUSH	DI
        CALL	AttachProperties
	PUSH	HWindow
	PUSH	Message
	PUSH	WParam
	PUSH	LParam.Word[2]
	PUSH	LParam.Word[0]
	MOV	AX,DS
	LES	DI,CreationWindow
	CALL	ES:[DI].TWindowsObject.Instance
end;

{ Allocate an object instance }

function MakeObjectInstance(P: PWindowsObject): TFarProc;
const
  BlockCode: array[1..5] of Byte = (
    $5B,              { POP BX             }
    $2E, $C4, $1F,    { LES BX,CS:[BX]     }
    $EA);             { JMP FAR StdWndProc }
var
  Block: PInstanceBlock;
  Instance: PObjectInstance;
begin
  if InstFreeList = nil then
  begin
    Block := GlobalLock(GlobalAlloc(gmem_Fixed, SizeOf(TInstanceBlock)));
    Block^.Next := InstBlockList;
    Move(BlockCode, Block^.Code, 5);
    Block^.WndProcPtr := StdWndProcInstance;
    Instance := @Block^.Instances;
    repeat
      Instance^.Code := $E8;  { CALL NEAR PTR Offset }
      Instance^.Offset := (2 - 3) - PtrRec(Instance).Ofs;
      Instance^.Next := InstFreeList;
      InstFreeList := Instance;
      Inc(PtrRec(Instance).Ofs, SizeOf(TObjectInstance));
    until PtrRec(Instance).Ofs = SizeOf(TInstanceBlock);
    InstBlockList := PtrRec(Block).Seg;
    ChangeSelector(PtrRec(Block).Seg, PtrRec(Block).Seg);
  end;
  MakeObjectInstance := TFarProc(InstFreeList);
  PtrRec(Instance).Ofs := PtrRec(InstFreeList).Ofs;
  PtrRec(Instance).Seg := AllocCSToDSAlias(PtrRec(InstFreeList).Seg);
  InstFreeList := Instance^.Next;
  Instance^.ObjectPtr := P;
  FreeSelector(PtrRec(Instance).Seg);
end;

{ Free an object instance }

procedure FreeObjectInstance(P: TFarProc);
var
  Instance: PObjectInstance;
begin
  PtrRec(Instance).Ofs := PtrRec(P).Ofs;
  PtrRec(Instance).Seg := AllocCSToDSAlias(PtrRec(P).Seg);
  Instance^.Next := InstFreeList;
  FreeSelector(PtrRec(Instance).Seg);
  InstFreeList := PObjectInstance(P);
end;

function LongMin(A, B: LongInt): LongInt;
begin
  if A < B then LongMin := A else LongMin := B;
end;

function LongMax(A, B: LongInt): LongInt;
begin
  if A > B then LongMax := A else LongMax := B;
end;

{ TWindowsObject }

{ Constructor for a TWindowsObject.  If a parent window is passed, adds the
  TWindowsObject to its parent's list of children.  Makes an instance
  thunk to be used in associating an MS-Windows interface element to the
  TWindowsObject. }

constructor TWindowsObject.Init(AParent: PWindowsObject);
begin
  TObject.Init;
  Status := 0;
  HWindow := 0;
  CreateOrder := 0;
  Parent := AParent;
  if Parent <> nil then Parent^.AddChild(@Self)
  else SiblingList := nil;
  ChildList := nil;
  TransferBuffer := nil;
  Instance := MakeObjectInstance(@Self);
  Flags := 0;
  EnableAutoCreate;
end;

{ Destructor for a TWindowsObject.  Disposes of each window in its
  ChildList and removes itself from a non-nil parent's list of children.
  Destroys a still-associated MS-Windows interface element and frees the
  instance thunk used for association of an MS-Windows element to the
  TWindowsObject. }

destructor TWindowsObject.Done;

  procedure FreeChild(P: PWindowsObject); far;
  begin
    P^.Free;
  end;

begin
  Destroy;
  ForEach(@FreeChild);
  if Parent <> nil then Parent^.RemoveChild(@Self);
  FreeObjectInstance(Instance);
  TObject.Done;
end;

{ Constructs an instance of TWindowsObject from the passed TStream.
  Loads each child window stored from ChildList. }

constructor TWindowsObject.Load(var S: TStream);
begin
  TObject.Init;
  S.Read(Status, SizeOf(Status));
  HWindow := 0;
  Parent := nil;
  SiblingList := nil;
  ChildList := nil;
  TransferBuffer := nil;
  Instance := MakeObjectInstance(@Self);
  S.Read(Flags, SizeOf(Flags));
  S.Read(CreateOrder, SizeOf(CreateOrder));
  GetChildren(S);
end;

{ Stores the TWindowsObject in the passed TStream.  Stores each child
  window in ChildList. }

procedure TWindowsObject.Store(var S: TStream);
var
  SavedFlags: Byte;
begin
  S.Write(Status, SizeOf(Status));
  SavedFlags := Flags;
  if HWindow <> 0 then SavedFlags := SavedFlags or wb_AutoCreate;
  S.Write(SavedFlags, SizeOf(SavedFlags));
  S.Write(CreateOrder, SizeOf(CreateOrder));
  PutChildren(S);
end;

{ Adds the TWindowsObjects stored on the given stream into its
  child list.  Used by TWindowsObject.Load.  Adds to the fixup
  list to insure that references to other to-be-loaded
  TWindowsObjects are preserved.
  IMPORTANT: This method assumes that the current child list
  is empty! }

procedure TWindowsObject.GetChildren(var S: TStream);
var
  ChildCount, I: Integer;
  SaveFixup: PFixupList;
  W: PWindowsObject;
  P, Q: ^Pointer;
begin
  SaveFixup := FixupList;
  S.Read(ChildCount, SizeOf(ChildCount));
  asm
	MOV     CX,ChildCount
	SHL     CX,1
	SHL     CX,1
	SUB     SP,CX
	MOV     FixupList.Word[0],SP
	MOV     FixupList.Word[2],SS
	MOV     DI,SP
	PUSH    SS
	POP     ES
	XOR     AL,AL
	CLD
	REP     STOSB
  end;
  for I := 1 to ChildCount do
  begin
    AddChild(PWindowsObject(S.Get));
    ChildList^.Parent := @Self;
  end;
  W := ChildList;
  for I := 1 to ChildCount do
  begin
    W := W^.Next;
    P := FixupList^[I];
    while P <> nil do
    begin
      Q := P;
      P := P^;
      Q^ := W;
    end;
  end;
  FixupList := SaveFixup;
end;

{ Puts all the windows in the child list onto the given stream.  They
  can be retrieved by calling the GetChildren method.  Used by the
  TWindowsObject.Store method. This method also ensure that the
  CreateOrder field is up to date, which is used by TWindow.Create.
  This will ensure the order the windows will be created in is
  the current order Windows has them in.}

procedure TWindowsObject.PutChildren(var S: TStream);
var
  ChildCount: Integer;

  procedure AssignCreateOrder;
  var
    CurWindow: HWnd;
    Wnd: PWindowsObject;
    I: Integer;
  begin
    Wnd := GetClient;
    if Wnd = nil then CurWindow := HWindow
    else CurWindow := Wnd^.HWindow;
    CurWindow := GetWindow(CurWindow, gw_Child);
    if CurWindow <> 0 then
    begin
      CurWindow := GetWindow(CurWindow, gw_HwndLast);
      I := 1;
      while CurWindow <> 0 do
      begin
	Wnd := GetObjectPtr(CurWindow);
	if Wnd <> nil then
	begin
	  Wnd^.CreateOrder := I;
	  Inc(I);
	end;
	CurWindow := GetWindow(CurWindow, gw_HwndPrev);
      end;
    end;
  end;


  procedure DoPutChild(P: PWindowsObject); far;
  begin
    S.Put(P);
  end;

begin
  AssignCreateOrder;
  ChildCount := IndexOf(ChildList);
  S.Write(ChildCount, SizeOf(ChildCount));
  ForEach(@DoPutChild);
end;

{ Create the children of this object.  Returns true if the
  all the windows where sucessfully created.
}

function TWindowsObject.CreateChildren: Boolean;
var
  I: Integer;
  P: PWindowsObject;
  Failure: Boolean;

  function OrderIsI(P: PWindowsObject): Boolean; far;
  begin
    OrderIsI := P^.CreateOrder = I;
  end;

  function CantCreateChild(P: PWindowsObject): Boolean;
  var
    Created: Boolean;
    Text: array[0..80] of Char;
  begin
    with P^ do
    begin
      Created := not IsFlagSet(wb_AutoCreate) or Create;
      if Created and IsIconic(HWindow) then
      begin
	GetWindowText(HWindow, Text, SizeOf(Text));
	SetWindowText(HWindow, Text);
      end;
    end;
    CantCreateChild := not Created;
  end;

  function CreateZeroChild(P: PWindowsObject): Boolean; far;
  begin
    CreateZeroChild := (P^.CreateOrder = 0) and CantCreateChild(P);
  end;

begin
  I := 1;
  Failure := False;
  repeat
    P := FirstThat(@OrderIsI);
    if P <> nil then Failure := CantCreateChild(P);
    Inc(I);
  until Failure or (P = nil);
  CreateChildren := not Failure and (FirstThat(@CreateZeroChild) = nil);
end;

{ Gets a pointer to a child window from the passed stream }

procedure TWindowsObject.GetChildPtr(var S: TStream; var P);
var
  Index: Word;
begin
  S.Read(Index, SizeOf(Word));
  Pointer(P) := At(Index);
end;

{ Puts a pointer to a child window onto the passed stream }

procedure TWindowsObject.PutChildPtr(var S: TStream; P: PWindowsObject);
var
  Index: Word;
begin
  if P = nil then Index := 0 else Index := IndexOf(P);
  S.Write(Index, SizeOf(Word));
end;

{ Gets a pointer to a sibling window from the passed stream.  This method
  is only valid during a Load constructor and is not valid until the
  constructor returns.  The pointer will not be given a valid value until
  the parent window's load constructor loads all of the window's sibling
  windows. }

procedure TWindowsObject.GetSiblingPtr(var S: TStream; var P);
var
  Index: Integer;
begin
  S.Read(Index, SizeOf(Word));
  if (Index = 0) or (FixupList = nil) then Pointer(P) := nil else
  begin
    Pointer(P) := FixupList^[Index];
    FixupList^[Index] := @P;
  end;
end;

{ Puts a pointer to a sibling window on to a stream.  The pointer can be
  read from the stream using GetSiblingPtr.  This method is only valid
  during a Store procedure. }

procedure TWindowsObject.PutSiblingPtr(var S: TStream; P: PWindowsObject);
var
  Index: Integer;
begin
  if P = nil then Index := 0 else Index := Parent^.IndexOf(P);
  S.Write(Index, SizeOf(Word));
end;

{ Transfers window 'data' to/from the passed data buffer.  Used to
  initialize dialogs and get data out of them.  The TransferFlag passed
  specifies whether data is to be read from or written to the passed
  buffer, or whether the data element size is simply to be returned. The
  return value is the size (in bytes) of the transfer data.  This method
  simply returns zero and is redefined in TControl descendant classes.}

function TWindowsObject.Transfer(DataPtr: Pointer; TransferFlag: Word): Word;
begin
  Transfer := 0;
end;

{ Focus the window }

procedure TWindowsObject.Focus;
begin
  if HWindow <> 0 then SetFocus(HWindow);
end;

{ Enable then window }

function TWindowsObject.Enable: Boolean;
begin
  if HWindow <> 0 then Enable := EnableWindow(HWindow, True)
  else Enable := False;
end;

{ Disable the window }

function TWindowsObject.Disable: Boolean;
begin
  if HWindow <> 0 then Disable := EnableWindow(HWindow, False)
  else Disable := False;
end;

{ Sets flag which indicates that the TWindowsObject has requested
  "keyboard handling" (translation of keyboard input into control
  selections) similiar to the way that dialogs function. }

procedure TWindowsObject.EnableKBHandler;
begin
  SetFlags(wb_KBHandler, True);
end;

{ Sets flag which indicates that the TWindowsObject should be
  created if a create is sent while in the parent's child list. }

procedure TWindowsObject.EnableAutoCreate;
begin
  SetFlags(wb_AutoCreate, True);
end;

{ Sets flag which indicates that the TWindowsObject can/will
  tranfer data via the transfer mechanism.  Used in conjunction
  with the Transfer method which actually does the transfer. }

procedure TWindowsObject.EnableTransfer;
begin
  SetFlags(wb_Transfer, True);
end;

{ Sets flag which indicates that the TWindowsObject should not be
  created if a create is sent while in the parent's child list. }

procedure TWindowsObject.DisableAutoCreate;
begin
  SetFlags(wb_AutoCreate, False);
end;

{ Sets flag which indicates that the TWindowsObject cannot/
  will not tranfer data via the transfer mechanism. }

procedure TWindowsObject.DisableTransfer;
begin
  SetFlags(wb_Transfer, False);
end;

{ Sets flag(s) for the TWindowsObject, which are stored in its Flags data
  field.  The mask of the flag(s) to be set (wb_KBHandler, etc.), and
  an OnOff "flag" is passed --  On = True, Off = False. }

procedure TWindowsObject.SetFlags(Mask: Byte; OnOff: Boolean);
begin
  if OnOff then Flags := Flags or Mask else Flags := Flags and not Mask;
end;

{ Determines whether the flag whose mask is passed has been set, returning
  a Boolean indicator --  True = On, False = Off. }

function TWindowsObject.IsFlagSet(Mask: Byte): Boolean;
begin
  IsFlagSet := Flags and Mask = Mask;
end;

{ Adds the passed pointer to a child window to the linked list
  of sibling windows which Self's ChildList points to. }

procedure TWindowsObject.AddChild(AChild: PWindowsObject);
begin
  if AChild <> nil then
    if ChildList = nil then
    begin
      ChildList := AChild;
      AChild^.SiblingList := AChild;
    end else
    begin
      AChild^.SiblingList := ChildList^.SiblingList;
      ChildList^.SiblingList := AChild;
      ChildList := AChild;
    end;
end;

{ Returns a pointer to the TWindowsObject's next sibling (the next window
  in its parent's child window list).  If Self was the last child added to
  the list, returns a pointer to the first child added. }

function TWindowsObject.Next: PWindowsObject;
begin
  Next := SiblingList;
end;

{ Returns a pointer to the TWindowsObject's previous sibling (the window
  previous to the TWindowsObject in its parent's child window list). Returns
  the sibling which points to Self.  If Self was the first child added to
  the list, returns a pointer to the last child added.}

function TWindowsObject.Previous: PWindowsObject;
var
  CurrentIndex: PWindowsObject;
begin
  if SiblingList = nil then Previous := nil else
  begin
    CurrentIndex := @Self;
    while CurrentIndex^.Next <> @Self do
      CurrentIndex := CurrentIndex^.Next;
    Previous := CurrentIndex;
  end;
end;

{ Removes the passed pointer to a child window from the linked list of
  sibling windows which Self's ChildList points to. }

procedure TWindowsObject.RemoveChild(AChild: PWindowsObject);
var
  LastChild, NextChild: PWindowsObject;
begin
  if ChildList <> nil then
  begin
    LastChild := ChildList;
    NextChild := LastChild;
    while (NextChild^.SiblingList <> LastChild) and
        (NextChild^.SiblingList <> AChild) do
      NextChild := NextChild^.SiblingList;
    if NextChild^.SiblingList = AChild then
      if NextChild^.SiblingList = NextChild then ChildList := nil else
      begin
        if NextChild^.SiblingList = ChildList then ChildList := NextChild;
        NextChild^.SiblingList := NextChild^.SiblingList^.SiblingList;
      end;
  end;
end;

{ Returns a generic pointer to the first TWindowsObject in the ChildList
  that meets some specified criteria.  If no child in the list meets the
  criteria, nil is returned.   The Test parameter passed is a pointer to
  a Boolean function, defining the criteria, which accepts a pointer to a 
  child window.  The Test function must return a Boolean value indicating
  whether the child passed meets the criteria.  }

function TWindowsObject.FirstThat(Test: Pointer): PWindowsObject; assembler;
var
  Last: Pointer;
asm
        LES     DI,Self
        LES     DI,ES:[DI].TWindowsObject.ChildList
        MOV     AX,ES
        OR      AX,DI
        JE      @@2
        MOV     Last.Word[0],DI
        MOV     Last.Word[2],ES
@@1:    LES     DI,ES:[DI].TWindowsObject.SiblingList
        PUSH    ES
        PUSH    DI
        PUSH    ES
        PUSH    DI
        MOV     AX,[BP]
        AND     AL,0FEH
        PUSH    AX
        CALL    Test
        POP     DI
        POP     ES
        OR      AL,AL
        JNE     @@2
        CMP     DI,Last.Word[0]
        JNE     @@1
	MOV     AX,ES
        CMP     AX,Last.Word[2]
        JNE     @@1
        XOR     DI,DI
        MOV     ES,DI
@@2:    MOV     AX,DI
        MOV     DX,ES
end;

{ Iterates over each child window in Self's ChildList, calling the
  procedure whose pointer is passed as the Action to be performed for
  each child.  A pointer to a child is passed as the one parameter to
  the iteration procedure. }

procedure TWindowsObject.ForEach(Action: Pointer); assembler;
var
  Last: Pointer;
asm
        LES     DI,Self
        LES     DI,ES:[DI].TWindowsObject.ChildList
        MOV     AX,ES
        OR      AX,DI
        JE      @@4
        MOV     Last.Word[0],DI
        MOV     Last.Word[2],ES
        LES     DI,ES:[DI].TWindowsObject.SiblingList
@@1:    CMP     DI,Last.Word[0]
        JNE     @@2
        MOV     AX,ES
        CMP     AX,Last.Word[2]
        JE      @@3
@@2:    PUSH    ES:[DI].TWindowsObject.SiblingList.Word[2]
	PUSH    ES:[DI].TWindowsObject.SiblingList.Word[0]
        PUSH    ES
        PUSH    DI
        MOV     AX,[BP]
        AND     AL,0FEH
        PUSH    AX
        CALL    Action
        POP     DI
        POP     ES
        JMP     @@1
@@3:    MOV     AX,[BP]
        AND     AL,0FEH
        PUSH    AX
        CALL    Action
@@4:
end;

{ Returns the Id of the TWindowsObject, used to identify the window in
  a specified parent's ChildList.  Redefined by TControl descendants to
  return their identifier from their attributes structure.  -1 is returned
  here as the default identifier.  This precludes any window with a -1 Id
  from being easily found.  This is the usual Windows strategy for handling
  static (unchanging child) windows like static controls.  If you need to
  address individual static controls, give them an id <> -1. }

function TWindowsObject.GetId: Integer;
begin
  GetId := -1;
end;

{ Returns the 1 based position at which the passed child window appears
  in Self's ChildList.  If the child does not appear in the list, 0 is
  returned.}

function TWindowsObject.IndexOf(P: PWindowsObject): Integer; assembler;
asm
        LES     DI,Self
        LES     DI,ES:[DI].TWindowsObject.ChildList
        MOV     AX,ES
        OR      AX,DI
        JE      @@3
        MOV     CX,DI
        MOV     BX,ES
        XOR     AX,AX
@@1:    INC     AX
        LES     DI,ES:[DI].TWindowsObject.SiblingList
        MOV     DX,ES
        CMP     DI,P.Word[0]
        JNE     @@2
        CMP     DX,P.Word[2]
        JE      @@3
@@2:    CMP     DI,CX
        JNE     @@1
        CMP     DX,BX
        JNE     @@1
        XOR     AX,AX
@@3:
end;

{ Returns the child at the passed position in Self's ChildList.  The
  ChildList is circularly-referent so that passing a position larger than
  the number of children will cause the traversal of the list to wrap. }

function TWindowsObject.At(I: Integer): PWindowsObject; assembler;
asm
        LES     DI,Self
        LES     DI,ES:[DI].TWindowsObject.ChildList
        MOV     AX,ES
        OR      AX,DI
        JE      @@2
        MOV     CX,I
@@1:    LES     DI,ES:[DI].TWindowsObject.SiblingList
        LOOP    @@1
@@2:    MOV     AX,DI
        MOV     DX,ES
end;

{ Returns a pointer to the window in the ChildList with the passed Id.
  If no child in the list has the passed Id, nil is returned. }

function TWindowsObject.ChildWithId(Id: Integer): PWindowsObject;

  function IsItThisChild(P: PWindowsObject): Boolean; far;
  begin
    IsItThisChild := P^.GetId = Id;
  end;

begin
  ChildWithId := FirstThat(@IsItThisChild);
end;

{ Performs default processing for an incoming message.  Does nothing, as
  defined here, relying on the Result field of the passed Msg argument to
  indicate to Windows that the message was/was not processed.  Is redefined
  in descendant classes to invoke appropriate default processing, as
  defined by MS-Windows. }

procedure TWindowsObject.DefWndProc(var Msg: TMessage);
begin
end;

{ Calls a procedure in the TWindowsObject's DVMT which is tagged with the
  the passed DVMTIndex, if found.  Else calls the passed FailureProc.  Used
  internally in the OW to match incoming Windows messages to a specified
  response method. }

procedure MsgPerform(W: PWindowsObject; var M: TMessage; DVMTIndex: Word;
  FailureProc: Integer); assembler;
asm
	MOV	DX,FailureProc
	MOV	AX,DVMTIndex
	LES	DI,M
	PUSH	ES
	PUSH	DI
	LES	BX,W
	PUSH	ES
	PUSH	BX
	MOV	BX,ES:[BX]
	CALL	DMTLookup
	MOV	CX,__OWL_DISPATCH_HOOK__.Word[2]
	JCXZ	@@1
	CALL	DispatchHook
@@1:	CALL    DWORD PTR [DI]
end;

{ Responds to an incoming wm_Command message.  If a child window had the
  focus when the message was sent or the child window sent a notification
  message to its parent, the message is sent to the child window. If the
  message cannot be given to a child window, it is given to Self. }

procedure TWindowsObject.WMCommand(var Msg: TMessage);
var
  CurrentWindow, Control: HWnd;
  Child: PWindowsObject;
begin
  if IsFlagSet(wb_KBHandler) and (Msg.LParam = 0) then
  begin
    Control := GetDlgItem(HWindow, Msg.WParam);
    if (Control <> 0) and (Word(SendMessage(Control, wm_GetDlgCode,
      0, 0)) and (dlgc_DefPushButton or dlgc_UndefPushButton) <> 0) then
    begin
      Msg.LParamLo := Control;
      Msg.LParamHi := bn_Clicked;
    end;
  end;
  if (Msg.lParamLo = 0) then		{ it's a command message and... }
  begin
    if (Msg.wParam < cm_Count) then	{ ...we can route it }
    begin
      { Find the object closed to the focus window }
      CurrentWindow := GetFocus; { window with focus when command was sent }
      Child := GetObjectPtr(CurrentWindow);
      while (Child = nil) and (CurrentWindow <> 0) and
	(CurrentWindow <> HWindow) do
      begin
	CurrentWindow := GetParent(CurrentWindow);
	Child := GetObjectPtr(CurrentWindow);
      end;

      { If the object is found, route to the object, else handle it yourself }
      if Child = nil then Child := @Self;
      MsgPerform(Child, Msg, cm_First + Msg.wParam,
	TWindowsObject_DefCommandProc)
    end
    else
      DefWndProc(Msg);
  end
  else
  begin
    { Find the child that generated the notification }
    Child := GetObjectPtr(GetDlgItem(HWindow, Msg.WParam));

    { If the child is found, give the notification to the child,
      else give it to Self as an "id" notification. }
    if (Child <> nil) and (Msg.lParamHi < nf_Count) then
      MsgPerform(Child, Msg, nf_First + Msg.lParamHi,
	  TWindowsObject_DefNotificationProc)
    else if Msg.wParam < id_Count then
      MsgPerform(@Self, Msg, id_First + Msg.wParam,
          TWindowsObject_DefChildProc)
    else DefChildProc(Msg);
  end;
end;

{ Dispatches scroll messages as if they where WMCommand message, that is
  by routing them to the scroll bar control as a notificationa and to
  Self as an "id" notification. }

procedure TWindowsObject.DispatchScroll(var Msg: TMessage);
var
  CurrentWindow: HWnd;
  Child: PWindowsObject;
  ChildId: Word;
begin
  if Msg.lParamHi <> 0 then
  begin
    Child := GetObjectPtr(Msg.lParamHi);
    if Child <> nil then
      MsgPerform(Child, Msg, nf_First + Msg.wParam,
        TWindowsObject_DefNotificationProc)
    else
    begin
      ChildId := GetWindowWord(Msg.lParamHi, gww_ID);
      if ChildId < id_Count then
        MsgPerform(@Self, Msg, id_First + ChildId,
          TWindowsObject_DefChildProc)
      else DefChildProc(Msg);
    end;
  end else DefWndProc(Msg);
end;

{ Responds to an incoming wm_VScroll message by calling DispatchScroll. 
  If message is not handled, calls DefWndProc.  If the window has a
  window's style scroll bar, the DispatchScroll processing is bypassed
  since it cannot be determined who generated the scroll message. }

procedure TWindowsObject.WMVScroll(var Msg: TMessage);
begin
  if (GetWindowLong(HWindow, gwl_Style) and ws_VScroll) = 0 then
    DispatchScroll(Msg)
  else DefWndProc(Msg);
end;

{ Responds to an incoming wm_HScroll message by calling DispatchScroll.
  If message is not handled, calls DefWndProc.  If the window has a
  window's style scroll bar, the DispatchScroll processing is bypassed
  since it cannot be determined who generated the scroll message. }

procedure TWindowsObject.WMHScroll(var Msg: TMessage);
begin
  if (GetWindowLong(HWindow, gwl_Style) and ws_HScroll) = 0 then
    DispatchScroll(Msg)
  else DefWndProc(Msg);
end;

{ Performs default processing for a command message (menu selection or
  accelerator.  If the original message receiver was this object, give
  the message to DefWndProc, else if the object has a parent, give the
  message to the parent, else give the message to the original receiver. }

procedure TWindowsObject.DefCommandProc(var Msg: TMessage);
var
  Target: PWindowsObject;
begin
  if Msg.Receiver = HWindow then Target := nil else
    if Parent <> nil then Target := Parent else
      Target := GetObjectPtr(Msg.Receiver);
  if Target = nil then DefWndProc(Msg) else
    MsgPerform(Target, Msg, cm_First + Msg.WParam,
      TWindowsObject_DefCommandProc)
end;

{ Performs default processing for an incoming notification message from
  a child of the TWindowsObject. Nothing can be done by default of a
  child notification (or "id" message). The user can override this method
  if it is more convienent to handle "id" messages in a case statement. }

procedure TWindowsObject.DefChildProc(var Msg: TMessage);
begin
  DefWndProc(Msg);
end;

{ Performs default processing for a notification message generated by the
  TWindowsObject. (The TWindowsObject has the option to perform processing
  in response to its own notification messages. )  It passes the message to
  the parent as an "id" message.  It is assumed that the object giving this
  message to this object is the parent of this object.  This is done in
  WMCommand, WMHScroll, or WMVScroll of the parent. Notifications are
  translated into "id" message so that the parent does not confuse child
  notification with its own notifications. Since the Msg record does not
  contain the id if its an WMHScroll or WMVScroll the id is looked up
  explicitly.}

procedure TWindowsObject.DefNotificationProc(var Msg: TMessage);
begin
  if Parent <> nil then
    if Msg.Message = wm_Command then
      MsgPerform(Parent, Msg, id_First + Msg.WParam,
        TWindowsObject_DefChildProc)
    else
      MsgPerform(Parent, Msg, id_First + GetWindowWord(HWindow,
        gww_ID), TWindowsObject_DefChildProc);
end;

{ Generates a run-time error (via call to inherited Abstract method)
  because an attempt should not be made to create an interface element to
  be associated with an instance of this abstract object type.
  Placeholder for descendant methods to redefine to create an MS-Windows
  element to be associated with a OW window object. }

function TWindowsObject.Create: Boolean;
begin
  Abstract;
end;

{ Destroys an MS-Windows element associated with the TWindowsObject after
  setting the wb_AutoCreate flag to ON for each of the windows in Self's
  ChildList. }

procedure TWindowsObject.Destroy;

  procedure DoEnableAutoCreate(P: PWindowsObject); far;
  begin
    if P^.HWindow <> 0 then P^.EnableAutoCreate;
  end;

begin
  if HWindow <> 0 then
  begin
    ForEach(@DoEnableAutoCreate);
    if IsFlagSet(wb_MDIChild) and (Parent^.GetClient <> nil) then
      SendMessage((Parent^.GetClient)^.HWindow, wm_MDIDestroy, HWindow, 0)
    else DestroyWindow(HWindow);
  end;
end;

{ Returns the name of the MS-Windows window class for TWindowsObjects. The
  default window class name is 'TurboWindow'. }

function TWindowsObject.GetClassName: PChar;
begin
  GetClassName := 'TurboWindow';
end;

{ Initializes the passed parameter with the registration attributes for
  the TWindowsObject.  This method serves as a placeholder for descendant
  classes to redefine to specify registration attributes for the MS-Windows
  class of a window object. }

procedure TWindowsObject.GetWindowClass(var AWndClass: TWndClass);
begin
  Abstract;
end;

{ Performs setup following creation of an associated MS-Windows window.
  Iterates though Self's ChildList, attempting to create an associated
  MS-Windows interface element for each child window object in the list.
  (A child's Create method is not called if its wb_AutoCreate flag is not
  set).  Calls TransferData to transfer data for its children for whom
  data transfer is enabled.  Can be redefined in descendant classes to
  perform additional special initialization.  The private field
  CreateOrder is used to ensure the create order is consistent through
  load and store of the object.  If the object is store'ed, store will
  fill in this value.  CreateOrder ranges in value from 1 to N where N
  is the number of objects with values.  All other objects will have a
  CreateOrder of Zero, which implies the object will be created
  after the last object with a create order.}

procedure TWindowsObject.SetupWindow;
begin
  if not CreateChildren then Status := em_InvalidChild
  else TransferData(tf_SetData);
end;

{ Transfers data between the TWindowsObject's data buffer and the child
  windows in its ChildList. (Data is not transfered between any child
  windows whose wb_Transfer flag is not set). }

procedure TWindowsObject.TransferData(Direction: Word);
var
  DataPtr: Pointer;

  procedure TransferDataChild(AChild: PWindowsObject); far;
  begin
    if AChild^.IsFlagSet(wb_Transfer) then
      Inc(PtrRec(DataPtr).Ofs, AChild^.Transfer(DataPtr, Direction));
  end;

begin
  if TransferBuffer <> nil then
  begin
    DataPtr := TransferBuffer;
    ForEach(@TransferDataChild);
  end;
end;

{ Registers the TWindowsObject's MS-Windows, if not already registered. }

function TWindowsObject.Register: Boolean;
var
  WindowClass: TWndClass;
begin
  Register := True;
  if not GetClassInfo(HInstance, GetClassName, WindowClass) then
  begin
    GetWindowClass(WindowClass);
    Register := RegisterClass(WindowClass);
  end;
end;

{ Displays the TWindowsObject, after checking that it has a valid
 (non-zero) handle. }

procedure TWindowsObject.Show(ShowCmd: Integer);
begin
  if HWindow <> 0 then ShowWindow(HWindow, ShowCmd);
end;

{ Returns a Boolean value indicating whether or not it is Ok to close
  the TWindowsObject.  Iterates through Self's ChildList, calling the
  CanClose method of each.  Returns False if any of the child windows
  return False. }

function TWindowsObject.CanClose: Boolean;

  function CannotCloseChild(P: PWindowsObject): Boolean; far;
  begin
    CannotCloseChild := (P^.HWindow <> 0) and not P^.CanClose;
  end;

begin
  CanClose := FirstThat(@CannotCloseChild) = nil;
end;

{ The default response to a WMClose message is to send a CloseWindow
  message.  CloseWindow sends a CanClose to determine if the window
  can be closed. }
procedure TWindowsObject.WMClose(var Msg: TMessage);
begin
  CloseWindow;
end;

{ Responds to an incoming wm_Close message or an explicit CloseWindow.
  Destroys the associated MS-Windows interface element and frees Self after
  determining that it is Ok to do so.  If Self is the main window of the
  application, calls the CanClose method of the application, else calls
  Self.CanClose, before calling Free. }

procedure TWindowsObject.CloseWindow;
var
  WillClose: Boolean;
begin
  if @Self = Application^.MainWindow then
    WillClose := Application^.CanClose
  else WillClose := CanClose;
  if WillClose then Free;
end;

{ Create a memory DC that is compatible with the given window }

function TWindowsObject.CreateMemoryDC: HDC;
var
  DC: HDC;
begin
  DC := GetDC(HWindow);
  CreateMemoryDC := CreateCompatibleDC(DC);
  ReleaseDC(HWindow, DC);
end;

{ Responds to an incoming wm_Destroy message.  If Self is the
  application's main window posts a 'quit' message to end the application. }

procedure TWindowsObject.WMDestroy(var Msg: TMessage);
begin
  if @Self = Application^.MainWindow then
    PostQuitMessage(HWindow);
  DefWndProc(Msg);
end;

{ Responds to an incoming wm_NCDestroy message, the last message sent to
  an MS-Windows interface element.  Removes any properties that have been
  associated with HWindow. Sets the HWindow data field of the
  TWindowsObject to zero to indicate that an interface element is no
  longer associated with the object. }

procedure TWindowsObject.WMNCDestroy(var Msg: TMessage);
begin
  if HWindow <> 0 then RemoveProperties(HWindow);
  DefWndProc(Msg);
  HWindow := 0;
end;

{ Responds to an incoming wm_Activate message.  If the TWindowsObject is
  being activated and if it has requested keyboard handling for its
  messages, enables the "keyboard handler" by calling the
  SetKBHandler method of the application. }

procedure TWindowsObject.WMActivate(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if Msg.WParam <> 0 then
    if IsFlagSet(wb_KBHandler) then
      Application^.SetKBHandler(@Self)
    else
      Application^.SetKBHandler(nil);
end;

{ Respond to Windows attempt to close down. }

procedure TWindowsObject.WMQueryEndSession(var Msg: TMessage);
begin
  if @Self = Application^.MainWindow then
    Msg.Result := Integer(Application^.CanClose)
  else Msg.Result := Integer(CanClose);
end;

{ If the window receives an Exit menu choice, it will attempt
  to close down the window. }

procedure TWindowsObject.CMExit(var Msg: TMessage);
begin
  if @Self = Application^.MainWindow then
    CloseWindow else
    DefCommandProc(Msg);
end;

{ Returns a nil pointer to indicate that the TWindowsObject is not a
  TMDIWindow.  Is redefined for descendant TMDIWindows to return a pointer
  to their TMDIClient window. }

function TWindowsObject.GetClient: PMDIClient;
begin
  GetClient := nil;
end;

{ TWindow }

{ Constructor for a TWindow.  Initializes its data fields using passed
  parameters and default values. }

constructor TWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TWindowsObject.Init(AParent);
  with Attr do
  begin
    Title := StrNew(ATitle);
    DefaultProc := @DefWindowProc;
    if AParent = nil then
      Style := ws_OverlappedWindow
    else
      if AParent^.GetClient <> nil then
      begin
	SetFlags(wb_MDIChild, True);
	DefaultProc := @DefMDIChildProc;
	Style := ws_ClipSiblings;
      end
      else Style := ws_Visible;
    ExStyle := 0;
    X := cw_UseDefault;
    Y := 0;
    W := cw_UseDefault;
    H := 0;
    Param := nil;
    Menu := 0;
  end;
  Scroller := nil;
  FocusChildHandle := 0;
end;

{ Destructor for a TWindow.  Disposes of its Scroller if the TScroller
  object was constructed, then calls TWindowsObject's Done destructor. }

destructor TWindow.Done;
begin
  StrDispose(Attr.Title);
  if Scroller <> nil then
  begin
    Dispose(Scroller, Done);
    Scroller := nil;
  end;
  TWindowsObject.Done;
end;

{ Constructor for a TWindow to be associated with a MS-Windows interface
  element created by MS-Windows from a resource definition. Initializes
  its data fields using passed parameters and default values. }

constructor TWindow.InitResource(AParent: PWindowsObject; ResourceID: Word);
begin
  TWindowsObject.Init(AParent);
  SetFlags(wb_FromResource, True);
  FillChar(Attr, SizeOf(Attr), 0);
  Attr.ID := ResourceID;
  DefaultProc := nil;
  Scroller := nil;
  FocusChildHandle := 0;
end;

{ Constructor for a TWindow.  Initializes the object with data from the
  passed TStream.  Loads its Scroller object, if stored. }

constructor TWindow.Load(var S: TStream);
begin
  TWindowsObject.Load(S);
  if IsFlagSet(wb_FromResource) then
  begin
    DefaultProc := nil;
    FillChar(Attr, SizeOf(Attr), 0)
  end
  else
  begin
    with Attr do
    begin
      Title := S.StrRead;
      S.Read(Style, SizeOf(Style));
      S.Read(ExStyle, SizeOf(ExStyle));
      S.Read(X, SizeOf(X));
      S.Read(Y, SizeOf(Y));
      S.Read(W, SizeOf(W));
      S.Read(H, SizeOf(H));
      S.Read(Param, SizeOf(Param));
    end;
    if IsFlagSet(wb_MDIChild) then
      DefaultProc := @DefMDIChildProc
    else DefaultProc := @DefWindowProc;
  end;
  S.Read(Attr.Id, SizeOf(Attr.Id));
  Scroller := PScroller(S.Get);
  if Scroller <> nil then Scroller^.Window := @Self;
  FocusChildHandle := 0;
end;

{ Stores data of the TWindow in the passed TStream.  Stores its Scroller
  object, if constructed. }

procedure TWindow.Store(var S: TStream);
var
  SaveStyle: LongInt;
begin
  TWindowsObject.Store(S);
  if not IsFlagSet(wb_FromResource) then
    with Attr do
    begin
      SaveStyle := Style and not (ws_Minimize or ws_Maximize);
      if HWindow <> 0 then
	if IsIconic(HWindow) then SaveStyle := SaveStyle or ws_Minimize
	else if IsZoomed(HWindow) then SaveStyle := SaveStyle or ws_Maximize;
      S.StrWrite(Title);
      S.Write(SaveStyle, SizeOf(SaveStyle));
      S.Write(ExStyle, SizeOf(ExStyle));
      S.Write(X, SizeOf(X));
      S.Write(Y, SizeOf(Y));
      S.Write(W, SizeOf(W));
      S.Write(H, SizeOf(H));
      S.Write(Param, SizeOf(Param));
    end;
  S.Write(Attr.Id, SizeOf(Attr.Id));
  S.Put(Scroller);
end;

{ Sets the caption of the window. }

procedure TWindow.SetCaption(ATitle: PChar);
begin
  with Attr do
  begin
    StrDispose(Title);
    Title := StrNew(ATitle);
    SetWindowText(HWindow, Title);
  end;
end;

{ Specifies registration attributes for the MS-Windows window class of the
  TWindow, allowing instances of TWindow to be registered.  Sets the fields
  of the passed TWndClass parameter to the default attributes appropriate
  for a TWindow. }

procedure TWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  AWndClass.cbClsExtra		:= 0;
  AWndClass.cbWndExtra		:= 0;
  AWndClass.hInstance		:= HInstance;
  AWndClass.hIcon		:= LoadIcon(0, idi_Application);
  AWndClass.hCursor		:= LoadCursor(0, idc_Arrow);
  AWndClass.hbrBackground	:= HBrush(color_Window + 1);
  AWndClass.lpszMenuName	:= nil;
  AWndClass.lpszClassName	:= GetClassName;
  AWndClass.style		:= cs_HRedraw or cs_VRedraw;
  AWndClass.lpfnWndProc   	:= @InitWndProc;
end;

{ Returns the resource id of the TWindow found in the attributes
  structure (the Attr data field). }

function TWindow.GetId: Integer;
begin
  GetId := Attr.Id;
end;

{ Specifies default processing for an incoming message.  Invokes default
  processing, defined by MS-Windows. Stores the result of the call to the
  default window procedure in the Result field of the message record. }

procedure TWindow.DefWndProc(var Msg: TMessage); assembler;
asm
	LES	DI,Self
	PUSH	ES:[DI].TWindow.DefaultProc.Word[2]
	PUSH	ES:[DI].TWindow.DefaultProc.Word[0]
	PUSH	ES:[DI].TWindowsObject.HWindow
	LES	DI,Msg
	PUSH	ES:[DI].TMessage.Message
	PUSH	ES:[DI].TMessage.WParam
	PUSH	ES:[DI].TMessage.LParamHi
	PUSH	ES:[DI].TMessage.LParamLo
	CALL	CallWindowProc
	LES	DI,Msg
	MOV	ES:[DI].TMessage.ResultLo,AX
	MOV	ES:[DI].TMessage.ResultHi,DX
end;

{ Associates an MS-Windows interface element with the TWindow object,
  after creating the interface element if not already created.  When
  creating an element, uses the creation attributes previously set in the
  Attr data field.  (Simply associates the TWindow with an
  already-created interface element if the "FromResource" flag is set.)
  If the TWindow could be successfully associated, calls SetupWindow and
  returns True.  Association is not attempted if the TWindow's Status
  data field is non-zero.  }

function TWindow.Create: Boolean;
var
  HParent: HWnd;
  TheMDIClient: PMDIClient;
  CreateStruct: TMDICreateStruct;
begin
  if Status = 0 then
  begin
    DisableAutoCreate;
    if Parent = nil then HParent := 0 else HParent := Parent^.HWindow;
    if not IsFlagSet(wb_FromResource) then
    begin
      if Register then
      begin
        CreationWindow := @Self;
	if not IsFlagSet(wb_MDIChild) then
          with Attr do
            HWindow := CreateWindowEx(ExStyle, GetClassName, Title,
              Style, X, Y, W, H, HParent, Menu, HInstance, Param)
        else { MDI Child window }
	begin
	  with CreateStruct do
	  begin
	    szClass := GetClassName;
	    szTitle := Attr.Title;
	    hOwner := HInstance;
	    x := Attr.X; y := Attr.Y; cx := Attr.W; cy := Attr.H;
	    style := Attr.Style;
	  end;
	  TheMDIClient := Parent^.GetClient;
	  if TheMDIClient <> nil then
	    HWindow := HWnd(SendMessage(TheMDIClient^.HWindow, wm_MDICreate, 0,
	      Longint(@CreateStruct)));
	end; { MDI Child window }
      end;
    end
    else { Windows already created window }
      HWindow := GetDlgItem(HParent, Attr.ID);
    if HWindow = 0 then
      Status := em_InvalidWindow
    else
      if GetObjectPtr(HWindow) = nil then
      begin
        AttachProperties(HWindow, @Self);
	DefaultProc := TFarProc(SetWindowLong(HWindow, gwl_WndProc,
	  LongInt(Instance)));
	SetupWindow;
      end;
  end;
  Create := Status = 0;
end;

{ Called upon activation or un-iconization to re-focus the last
  focused child }

procedure TWindow.FocusChild;
begin
  if (FocusChildHandle <> 0) and IsWindow(FocusChildHandle) and
      not IsIconic(HWindow) then
    SetFocus(FocusChildHandle);
end;

{ Updates the value of FocusChildHandle }

procedure TWindow.UpdateFocusChild;
var
  CurrentFocus: Word;
begin
  CurrentFocus := GetFocus;
  if (CurrentFocus <> 0) and IsChild(HWindow, CurrentFocus) then
    FocusChildHandle := CurrentFocus;
end;

{ Updates the coordinates in Attr to their new values }

procedure TWindow.UpdateWindowRect;
var
  WndRect: TRect;
  MDIClient: PMDIClient;
begin
  if not (IsIconic(HWindow) or IsZoomed(HWindow)) then
  begin
    GetWindowRect(HWindow, WndRect);
    Attr.W := WndRect.right - WndRect.left;
    Attr.H := WndRect.bottom - WndRect.top;
    if Parent <> nil then
    begin
      MDIClient := Parent^.GetClient;
      if (MDIClient <> nil) and IsFlagSet(wb_MDIChild) then 
        ScreenToClient(MDIClient^.HWindow, PPoint(@WndRect)^)
      else
        if Attr.Style and ws_Child <> 0 then
          ScreenToClient(Parent^.HWindow, PPoint(@WndRect)^);
    end;
    Attr.X := WndRect.left;
    Attr.Y := WndRect.top;
  end;
end;

{ Response method for an incoming wm_Activate message.  If the TWindow has
  requested keyboard handling for its messages, saves the child with the
  focus if is being deactivated and restores the focus to this child when
  the TWindow is reactivated. }

procedure TWindow.WMActivate(var Msg: TMessage);
var
  CurrentFocus: HWnd;
begin
  TWindowsObject.WMActivate(Msg);
  if IsFlagSet(wb_KBHandler) then
  begin
    if (Msg.WParam <> 0) then FocusChild
    else UpdateFocusChild;
  end;
end;

procedure TWindow.WMMDIActivate(var Msg: TMessage);
begin
  WMActivate(Msg);
end;

{ Initializes ("sets up") the TWindow.  Called following a successful
  association between an MS-Windows interface element and a TWindow.  Sets
  the focus to TWindows created as MDI children.  If the TWindow has a
  TScroller object, calls the TScroller's SetSBarRange to set the range of
  the TWindow's window scrollbars.  Calls TWindowsObject.SetupWindow to
  create windows in child list.  Can be redefined in descendant classes to
  perform additional initialization. }

procedure TWindow.SetupWindow;
begin
  TWindowsObject.SetupWindow;
  if IsFlagSet(wb_MDIChild) then SetFocus(HWindow);
  if Scroller <> nil then Scroller^.SetSBarRange;
  UpdateWindowRect;
end;

{ WMCreate is received only if our default procedure is installed and
  therefore we can setup the already created window. }

procedure TWindow.WMCreate(var Msg: TMessage);
begin
  SetupWindow;
  DefWndProc(Msg);
end;

{ Response method for an incoming wm_HScroll message.  If the message is
  from a scrollbar control, calls DispatchScroll directly to avoid calling
  TWindowsObject.WMHScroll so that GetWindowLong is called only once.
  Else passes the message to the TWindow's Scroller if it has been
  constructed, and calls DefWndProc. Assumes because of a Windows bug that
  if the window has the scrollbar style, it will not have scrollbar
  controls. }

procedure TWindow.WMHScroll(var Msg: TMessage);
begin
  if (GetWindowLong(HWindow, gwl_Style) and ws_HScroll) = 0 then
    DispatchScroll(Msg)
  else if (Scroller <> nil) then
    Scroller^.HScroll(Msg.WParam, Msg.LParamLo)
  else DefWndProc(Msg);
end;

{ Response method for an incoming wm_VScroll message.  If the message is
  from a scrollbar control, calls DispatchScroll directly to avoid calling
  TWindowsObject.WMHScroll so that GetWindowLong is called only once.
  Else passes the message to the TWindow's Scroller if it has been
  constructed, and calls DefWndProc.  Assumes because of a Windows bug that
  if the window has the scrollbar style, it will not have scrollbar
  controls.}

procedure TWindow.WMVScroll(var Msg: TMessage);
begin
  if (GetWindowLong(HWindow, gwl_Style) and ws_VScroll) = 0 then
    DispatchScroll(Msg)
  else if (Scroller <> nil) then
    Scroller^.VScroll(Msg.WParam, Msg.LParamLo)
  else DefWndProc(Msg);
end;

{ Response method for an incoming wm_Paint message. Calls Self.Paint,
  performing Windows-required paint setup and cleanup before and after.
  (If the TWindow has a TScroller, also calls its BeginView and EndView
  methods before and after call to Paint. }

procedure TWindow.WMPaint(var Msg: TMessage);
var
  PaintInfo: TPaintStruct;
begin
  BeginPaint(HWindow, PaintInfo);
  if Scroller <> nil then Scroller^.BeginView(PaintInfo.HDC, PaintInfo);
  Paint(PaintInfo.HDC, PaintInfo);
  if Scroller <> nil then Scroller^.EndView;
  EndPaint(HWindow, PaintInfo);
end;

{ Redraws the contents of the TWindow after a WMPaint message is received.
  Placeholder for descendant object types to redefine. }

procedure TWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
begin
end;

{ Response method for an incoming wm_Size message.  Calls the SetPageSize
  method of the TWindow's Scroller, if it has been constructed.  Also
  saves the normal size of the window in Attr. }

procedure TWindow.WMSize(var Msg: TMessage);
var
  WndRect: TRect;
begin
  if (Scroller <> nil) and (Msg.WParam <> sizeIconic) then
    Scroller^.SetPageSize;
  if Msg.wParam = sizeNormal then
  begin
    GetWindowRect(HWindow, WndRect);
    Attr.H := WndRect.bottom - WndRect.top;
    Attr.W := WndRect.right - WndRect.left;
  end;
  DefWndProc(Msg);
end;

{ Save the normal position of the window.  If IsIconic and IsZoomed
  ignore the position since it does not reflect the normal state. }

procedure TWindow.WMMove(var Msg: TMessage);
begin
  UpdateWindowRect;
  DefWndProc(Msg);
end;

{ Response method for an incoming wm_LButtonDown message.  If the TWindow's
  Scroller has been constructed and if auto-scrolling has been requested,
  captures mouse input, loops until a wm_LButtonUp message comes in calling
  the Scroller's AutoScroll method, and then releases capture on mouse
  input. }

procedure TWindow.WMLButtonDown(var Msg: TMessage);
var
  LoopMsg: TMsg;
begin
  if (Scroller <> nil) and Scroller^.AutoMode then
  begin
    SetCapture(HWindow);
    repeat
      if PeekMessage(LoopMsg, 0, 0, 0, pm_Remove) then
      begin
	TranslateMessage(LoopMsg);
        DispatchMessage(LoopMsg);
      end;
      Scroller^.AutoScroll;
    until LoopMsg.Message = wm_LButtonUp;
    ReleaseCapture;
  end;
  DefWndProc(Msg);
end;

procedure TWindow.WMSysCommand(var Msg: TMessage);
begin
  if IsFlagSet(wb_KBHandler) then
    case Msg.wParam of
      sc_Minimize: UpdateFocusChild;
      sc_Restore: FocusChild;
    end;
  DefWndProc(Msg);
end;

{ TMDIWindow }

{ Constructor for a TMDIWindow.  Initializes the object with data from
  the passed TStream.  Loads its ClientWnd, if stored. }

constructor TMDIWindow.Load(var S: TStream);
begin
  TWindow.Load(S);
  ClientWnd := PMDIClient(S.Get);
  ClientWnd^.Parent := @Self;
  S.Read(ChildMenuPos, SizeOf(ChildMenuPos));
end;

{ Stores data of the TMDIWindow in the passed TStream.  Stores its
  ClientWnd. }

procedure TMDIWindow.Store(var S: TStream);
begin
  TWindow.Store(S);
  S.Put(ClientWnd);
  S.Write(ChildMenuPos, SizeOf(ChildMenuPos));
end;

{ Constructor for a TMDIWindow.  Initializes its data fields using passed
  parameters and default values. }

constructor TMDIWindow.Init(ATitle: PChar; AMenu: HMenu);
begin
  TWindow.Init(nil, ATitle);
  Attr.Menu := AMenu;
  ChildMenuPos := 0;
  ClientWnd := nil;
  InitClientWindow;
end;

{ Constructs the TMDIWindow's MDI client window. }

procedure TMDIWindow.InitClientWindow;
begin
  ClientWnd := new(PMDIClient, Init(@Self));
end;

{ Destructor for a TMDIWindow.  Disposes of the TMDIWindow's MDI client 
  window. }

destructor TMDIWindow.Done;
begin
  TWindow.Done;
  if ClientWnd <> nil then Dispose(ClientWnd, Done);
end;

{ Returns the default name of the MS-Windows window class for a
  TMDIWindow - 'TurboMDIWindow' }

function TMDIWindow.GetClassName: PChar;
begin
  GetClassName := 'TurboMDIWindow';
end;

{ Returns a pointer to the TMDIWindow's MDI client window. }

function TMDIWindow.GetClient: PMDIClient;
begin
  GetClient := ClientWnd;
end;

{ Sets up the TMDIWindow by constructing and creating its TMDIClient. }

procedure TMDIWindow.SetupWindow;
var
  FrameMenu: HMenu;
  R: TRect;
begin
  FrameMenu := GetMenu(HWindow);
  ClientWnd^.ClientAttr.hWindowMenu := GetSubMenu(FrameMenu, ChildMenuPos);
  GetClientRect(HWindow, R);
  with ClientWnd^.Attr do
  begin
    if X = cw_UseDefault then
    begin
      X := R.left;
      Y := R.top;
    end;
    if W = cw_UseDefault then
    begin
      W := R.right - R.left;
      H := R.bottom - R.top;
    end;
  end;
  if not ClientWnd^.Create then
    Status := em_InvalidClient;
  TWindow.SetupWindow;
end;

{ Specifies registration attributes for the MS-Windows window class of the
  TMDIWindow.  Sets the fields of the passed TWndClass parameter to the
  default attributes appropriate for a TMDIWindow. }

procedure TMDIWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  TWindow.GetWindowClass(AWndClass);
  AWndClass.style := 0;
end;

{ Specifies default processing for an incoming message.  Calls the
  MS-Windows default window procedure which is appropriate for a
  TMDIWindow.  Stores the result of the call in the Result field of
  the passed message record. }

procedure TMDIWindow.DefWndProc(var Msg: TMessage); assembler;
asm
	LES	DI,Self
	PUSH	ES:[DI].TMDIWindow.HWindow
	LES	DI,ES:[DI].TMDIWindow.ClientWnd
	MOV	AX,ES
	OR	AX,DI
	JE	@@1
	MOV	AX,ES:[DI].TMDIClient.HWindow
@@1:	PUSH	AX
	LES	DI,Msg
	PUSH	ES:[DI].TMessage.Message
	PUSH	ES:[DI].TMessage.WParam
	PUSH	ES:[DI].TMessage.LParamHi
	PUSH	ES:[DI].TMessage.LParamLo
	CALL	DefFrameProc
	LES	DI,Msg
	MOV	ES:[DI].TMessage.ResultLo,AX
	MOV	ES:[DI].TMessage.ResultHi,DX
end;

{ Constructs a new MDI child window object.  By default, constructs an
  instance of TWindow as an MDI child window object.  Will almost always be
  redefined by descendants to construct an instance of a user-defined
  TWindow descendant as an MDI child window object. }

function TMDIWindow.InitChild: PWindowsObject;
begin
  InitChild := New(PWindow, Init(@Self, 'MDI Child'));
end;

{ Creates a valid new MDI child window after calling Self.InitChild to
  construct a new MDI child window object. }

function TMDIWindow.CreateChild: PWindowsObject;
begin
  CreateChild := Application^.MakeWindow(InitChild);
end;

{ Responds to an incoming "CreateChild" command (with a cm_CreateChild
  command identifier) by calling Self.CreateChild to construct and create
  a new MDI child. }

procedure TMDIWindow.CMCreateChild(var Msg: TMessage);
begin
  CreateChild;
end;

{ Arranges iconized MDI child windows by calling the ArrangeIcons method
  of the MDI client window object. }

procedure TMDIWindow.ArrangeIcons;
begin
  ClientWnd^.ArrangeIcons;
end;

{ Cascades the MDI child windows by calling the CascadeChildren method of
  the MDI client window object. }

procedure TMDIWindow.CascadeChildren;
begin
  ClientWnd^.CascadeChildren;
end;

{ Tiles the MDI child windows by calling the TileChildren method of the
  MDI client window object. }

procedure TMDIWindow.TileChildren;
begin
  ClientWnd^.TileChildren;
end;

{ Closes each MDI child, after calling the child's CanClose method to
  ensure that it is Ok to do so. }

procedure TMDIWindow.CloseChildren; 

  function CannotClose(P: PWindow): Boolean; far;
  begin
    if P^.IsFlagSet(wb_MDIChild) then
      CannotClose := not P^.CanClose
    else CannotClose := False;
  end;

  procedure CloseChild(P: PWindow); far;
  begin
    if P^.IsFlagSet(wb_MDIChild) then P^.Free;
  end;

begin
  if FirstThat(@CannotClose) = nil then ForEach(@CloseChild);
end;

{ Responds to an incoming "Tile" command (with a cm_TileChildren command
  identifier) by calling Self.TileChildren to tile the MDI child
  windows. }

procedure TMDIWindow.CMTileChildren(var Msg: TMessage);
begin
  TileChildren;
end;

{ Responds to an incoming "Cascade" command (with a cm_CascadeChildren
  command identifier) by calling Self.CascadeChildren to cascade the MDI
  child windows. }

procedure TMDIWindow.CMCascadeChildren(var Msg: TMessage);
begin
  CascadeChildren;
end;  

{ Responds to an incoming "Arrange" command (with a cm_ArrangeIcons
  command identifier) by calling Self.ArrangeIcons to arrange the
  icons of the MDI child windows. }

procedure TMDIWindow.CMArrangeIcons(var Msg: TMessage);
begin
  ArrangeIcons;
end;  

{ Responds to an incoming "CloseAll" command (with a cm_CloseChildren
  command identifier) by calling Self.CloseChildren to close the
  MDI child windows. }

procedure TMDIWindow.CMCloseChildren(var Msg: TMessage);
begin
  CloseChildren;
end;

{ TMDIClient }

{ Constructor for a TMDIClient.  Initializes the object with data from the
  passed TStream. }

constructor TMDIClient.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(ClientAttr, SizeOf(ClientAttr));
  Attr.Param := PChar(@ClientAttr);
end;

{ Stores data of the TMDIClient in the passed TStream. }

procedure TMDIClient.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(ClientAttr, SizeOf(ClientAttr));
end;

{ Constructor for a TMDIClient.  Initializes its data fields using passed
  parameter and default values.  The size is calculated so that a
  child window can be correctly created before the window is show.  If
  this is not done, the default size of the window would be zero. }

constructor TMDIClient.Init(AParent: PMDIWindow);
var
  SizeRect: TRect;
begin
  inherited Init(AParent, nil);
  Attr.Style := ws_Child or ws_Visible or ws_Group or ws_TabStop or
    ws_ClipChildren or ws_HScroll or ws_VScroll;
  Parent^.RemoveChild(@Self);
  ClientAttr.hWindowMenu := HMenu(0);
  ClientAttr.idFirstChild := id_FirstMDIChild;
  Attr.Param := PChar(@ClientAttr);
end;

{ Returns the name of the MS-Windows window class for a TMDIClient. }

function TMDIClient.GetClassName: PChar;
begin
  GetClassName := 'MDIClient';
end;

{ 'MDIClient' is supplied by MS Windows so return true }

function TMDIClient.Register: Boolean;
begin
  Register := True;
end;

{ Arranges iconized MDI child windows. }

procedure TMDIClient.ArrangeIcons;
begin
  SendMessage(HWindow, wm_MDIIconArrange, 0, 0);
end;

{ Cascades the MDI child windows. }

procedure TMDIClient.CascadeChildren;
begin
  SendMessage(HWindow, wm_MDICascade, 0, 0);
end;

{ Tiles the MDI child windows. }

procedure TMDIClient.TileChildren;
begin
  SendMessage(HWindow, wm_MDITile, 0, 0);
end;

{ Prevent a call to Paint since we are using a MS Windows supplied
  class }

procedure TMDIClient.WMPaint(var Msg: TMessage);
begin
  DefWndProc(Msg);
end;

{ TScroller }

{ Private. LongMulDiv multiplys the first two arguments and then
  divides by the third.  This is used so that real number
  (floating point) arithmetic is not necessary.  This routine saves
  the possible 64-bit value in a temp before doing the divide.  Does
  not do error checking like divide by zero.  Also assumes that the
  result is in the 32-bit range (Actually 31-bit, since this algorithm
  is for unsigned). }

function LongMulDiv(Mult1, Mult2, Div1: Longint): Longint; assembler;
type
  Quadword = record
    w0, w1, w2, w3: Word;
  end;
var
  Temp: Quadword;
asm
{ Mul }
	MOV	DX,Mult1.Word[2]
	MOV	AX,Mult1.Word[0]
        MOV	CX,Mult2.Word[2]
	MOV	BX,Mult2.Word[0]

        MOV     DI,DX
        MOV     SI,AX

        MUL     BX
        MOV     Temp.w0,AX
        MOV     Temp.w1,DX

        MOV     AX,DI
        MUL     CX
        MOV     Temp.w2,AX
        MOV     Temp.w3,DX

        MOV     AX,DI
        MUL     BX
        ADD     Temp.w1,AX
        ADC     Temp.w2,DX
        ADC     Temp.w3,0

        MOV     AX,SI
        MUL     CX
        ADD     Temp.w1,AX
        ADC     Temp.w2,DX
        ADC     Temp.w3,0

	MOV	DX,Temp.w3
	MOV	SI,Temp.w2
	MOV	BX,Temp.w1
	MOV	AX,Temp.w0
{ Adjust for rounding }
	MOV	CX,Div1.Word[2]
	MOV	DI,Div1.Word[0]
	SHR	CX,1
        RCR	DI,1
        ADD	AX,DI
	ADC	BX,CX
	ADC	SI,0
	ADC	DX,0
{ Div }
        MOV     CX,32
        CLC

@1:	RCL     AX,1
        RCL     BX,1
        RCL     SI,1
        RCL     DX,1
        JNC     @3

@2:	SUB	SI,Div1.Word[0]
        SBB	DX,Div1.Word[2]
        STC
        LOOP    @1
        JMP     @5

@3:	CMP     DX,Div1.Word[2]
        JC      @4
        JNE     @2
        CMP     SI,Div1.Word[0]
        JNC     @2

@4:	CLC
        LOOP    @1

@5:	RCL     AX,1
        RCL     BX,1

        MOV     CX,SI
        MOV     DX,BX
end;

{ Constructs a TScroller object, initializing its data fields to default
  values. }
constructor TScroller.Init(TheWindow: PWindow; TheXUnit, TheYUnit: Integer;
  TheXRange, TheYRange: LongInt);
begin
  TObject.Init;
  Window := TheWindow;
  XPos := 0;  YPos := 0;
  XUnit := TheXUnit;
  YUnit := TheYUnit;
  XRange := TheXRange;
  YRange := TheYRange;
  XLine := 1;  YLine := 1;
  XPage := 1;  YPage := 1;
  AutoMode := True; 
  TrackMode := True;
  AutoOrg := True;
  HasHScrollBar := (Window <> nil) and 
    ((Window^.Attr.Style and ws_HScroll) = ws_HScroll);
  HasVScrollBar := (Window <> nil) and
    ((Window^.Attr.Style and ws_VScroll) = ws_VScroll);
end;

{ Constructs an instance of TScroller from the passed TStream. }

constructor TScroller.Load(var S: TStream);
begin
  TObject.Init;
  S.Read(XPos, SizeOf(XPos));
  S.Read(YPos, SizeOf(YPos));
  S.Read(XUnit, SizeOf(XUnit));
  S.Read(YUnit, SizeOf(YUnit));
  S.Read(XRange, SizeOf(XRange));
  S.Read(YRange, SizeOf(YRange));
  S.Read(XLine, SizeOf(XLine));
  S.Read(YLine, SizeOf(YLine));
  S.Read(XPage, SizeOf(XPage));
  S.Read(YPage, SizeOf(YPage));
  S.Read(AutoMode, SizeOf(AutoMode));
  S.Read(TrackMode, SizeOf(TrackMode));
  S.Read(AutoOrg, SizeOf(AutoOrg));
  S.Read(HasHScrollBar, SizeOf(HasHScrollBar));
  S.Read(HasVScrollBar, SizeOf(HasVScrollBar));
end;

{ Destructs the scroller and resets the owning window's Scroller
  field to nil }

destructor TScroller.Done;
begin
  if (Window <> nil) and (Window^.Scroller = @Self) then
    Window^.Scroller := nil;
  TObject.Done;
end;

{ Stores the TScroller in the passed TStream. }

procedure TScroller.Store(var S: TStream);
begin
  S.Write(XPos, SizeOf(XPos));
  S.Write(YPos, SizeOf(YPos));
  S.Write(XUnit, SizeOf(XUnit));
  S.Write(YUnit, SizeOf(YUnit));
  S.Write(XRange, SizeOf(XRange));
  S.Write(YRange, SizeOf(YRange));
  S.Write(XLine, SizeOf(XLine));
  S.Write(YLine, SizeOf(YLine));
  S.Write(XPage, SizeOf(XPage));
  S.Write(YPage, SizeOf(YPage));
  S.Write(AutoMode, SizeOf(AutoMode));
  S.Write(TrackMode, SizeOf(TrackMode));
  S.Write(AutoOrg, SizeOf(AutoOrg));
  S.Write(HasHScrollBar, SizeOf(HasHScrollBar));
  S.Write(HasVScrollBar, SizeOf(HasVScrollBar));
end;

{ Private. Converts a horizontal range value from the scrollbar to
  a horizontal scroll value. }

function TScroller.XScrollValue(ARangeUnit: Longint): Integer;
begin
  XScrollValue := LongMulDiv(ARangeUnit, MaxInt, XRange);
end;

{ Private. Converts a vertical range value from the scrollbar to a
  vertical scroll value. }

function TScroller.YScrollValue(ARangeUnit: Longint): Integer;
begin
  YScrollValue := LongMulDiv(ARangeUnit, MaxInt, YRange);
end;

{ Private. Converts a horizontal scroll value from the scrollbar to
  a horizontal range value. }

function TScroller.XRangeValue(AScrollUnit: Integer): Longint;
begin
  XRangeValue := LongMulDiv(AScrollUnit, XRange, MaxInt);
end;

{ Private. Converts a vertical scroll value from the scrollbar to a
  vertical range value. }

function TScroller.YRangeValue(AScrollUnit: Integer): Longint;
begin
  YRangeValue := LongMulDiv(AScrollUnit, YRange, MaxInt);
end;

{ Sets the number of units per page (amount by which to scroll on a page
  scroll request) according to the current size of the Window's client
  area. }

procedure TScroller.SetPageSize;
var
  ClientRect: TRect;
  Width, Height: Integer;
begin
  if (Window <> nil) and (Window^.HWindow <> 0) then
  begin
    GetClientRect(Window^.HWindow, ClientRect);
    with ClientRect do
    begin
      Width := Right - Left;  Height := Bottom - Top;
      if (Width <> 0) and (Height <> 0) and (XUnit > 0) and (YUnit > 0) then
      begin
        XPage := ((Width+1) div XUnit) -1;
        YPage := ((Height+1) div YUnit) -1;
      end;
    end;
  end;
end;
 
{ Sets the range of the TScroller and also sets the range of its Window's
  scrollbars. }

procedure TScroller.SetRange(TheXRange, TheYRange: LongInt);
begin
  XRange := TheXRange;
  YRange := TheYRange;
  SetSBarRange; 
  if HasHScrollBar then SetScrollPos(Window^.HWindow, sb_Horz, XPos, True);
  if HasVScrollBar then SetScrollPos(Window^.HWindow, sb_Vert, YPos, True);
  ScrollTo(LongMin(TheXRange, XPos), LongMin(TheYRange, YPos));
end;

{ Resets the X and Y scroll unit size (in device units) to the passed
  parameters.  Calls SetPageSize to update the X and Y page size, which
  are specified in scroll units. }

procedure TScroller.SetUnits(TheXUnit, TheYUnit: LongInt);
begin
  XUnit := TheXUnit;
  YUnit := TheYUnit;
  SetPageSize; 
end;

{ Sets the range of the Window's scrollbars. }

procedure TScroller.SetSBarRange;
begin
  if Window <> nil then
  begin
    if HasHScrollBar then SetScrollRange(Window^.HWindow, sb_Horz, 0,
      LongMax(0, LongMin(XRange, MaxInt)), False);
    if HasVScrollBar then SetScrollRange(Window^.HWindow, sb_Vert, 0,
      LongMax(0, LongMin(YRange, MaxInt)), False);
  end;
end;

{ Sets the origin for the paint display context according to XPos, YPos. }

procedure TScroller.BeginView(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  XOrg, YOrg: LongInt;
begin
  XOrg := XPos * XUnit;
  YOrg := YPos * YUnit;
  if AutoOrg and (XOrg <= MaxInt) and (YOrg <= MaxInt) then
    SetViewPortOrg(PaintDC, -XOrg, -YOrg);
end;

{ Updates the position of the Window's scrollbar(s). }

procedure TScroller.EndView;
var
  TempPos: Longint;
begin
  if Window <> nil then
  begin
    if HasHScrollBar then
    begin
      if (XRange > MaxInt) then
        TempPos := XScrollValue(XPos) else TempPos := XPos;
      if GetScrollPos(Window^.HWindow, sb_Horz) <> TempPos then
        SetScrollPos(Window^.HWindow, sb_Horz, TempPos, True);
    end;
    if HasVScrollBar then
    begin
      if (YRange > MaxInt) then
        TempPos := YScrollValue(YPos) else TempPos := YPos;
      if GetScrollPos(Window^.HWindow, sb_Vert) <> TempPos then
        SetScrollPos(Window^.HWindow, sb_Vert, TempPos, True);
    end;
  end;
end;

{ Scrolls vertically according to scroll action and thumb position. }

procedure TScroller.VScroll(ScrollRequest: Word; ThumbPos: Integer);
begin
  case ScrollRequest of
    sb_LineDown: ScrollBy(0, YLine);
    sb_LineUp: ScrollBy(0, -YLine);
    sb_PageDown: ScrollBy(0, YPage);
    sb_PageUp: ScrollBy(0, -YPage);
    sb_ThumbPosition:
      if (YRange > MaxInt) then
	ScrollTo(XPos, YRangeValue(ThumbPos)) else ScrollTo(XPos, ThumbPos);
    sb_ThumbTrack:
      begin
	if TrackMode then
	  if (YRange > MaxInt) then
            ScrollTo(XPos, YRangeValue(ThumbPos)) 
          else ScrollTo(XPos, ThumbPos);
	if ((Window <> nil) and HasVScrollBar) then
	  SetScrollPos(Window^.HWindow, sb_Vert, ThumbPos, True);
      end;
  end;
end;

{ Scrolls horizontally according to scroll action and thumb position. }

procedure TScroller.HScroll(ScrollRequest: Word; ThumbPos: Integer);
begin
  case ScrollRequest of
    sb_LineDown: ScrollBy(XLine, 0);
    sb_LineUp: ScrollBy(-XLine, 0);
    sb_PageDown: ScrollBy(XPage, 0);
    sb_PageUp: ScrollBy(-XPage, 0);
    sb_ThumbPosition:
      if (XRange > MaxInt) then
	ScrollTo(XRangeValue(ThumbPos), YPos) else ScrollTo(ThumbPos, YPos);
    sb_ThumbTrack:
      begin
	if TrackMode then
          if (XRange > MaxInt) then
	    ScrollTo(XRangeValue(ThumbPos), YPos)
          else ScrollTo(ThumbPos, YPos);
	if ((Window <> nil) and HasHScrollBar) then
            SetScrollPos(Window^.HWindow, sb_Horz, ThumbPos, True);
      end;
  end;
end;

{ Scrolls to an (X,Y) position, after checking boundary conditions.  Causes
  a WMPaint message to be sent.  First scrolls the contents of the client
  area, if a portion of the client area will remain visible. }

procedure TScroller.ScrollTo(X, Y: LongInt);
var
  NewXPos, NewYPos: LongInt;
begin
  if Window <> nil then
  begin
    NewXPos := LongMax(0, LongMin(X, XRange));
    NewYPos := LongMax(0, LongMin(Y, YRange));
    if (NewXPos <> XPos) or (NewYPos <> YPos) then
    begin
      if AutoOrg or (Abs(YPos - NewYPos) < YPage) and 
          (Abs(XPos - NewXPos) < XPage) then
        ScrollWindow(Window^.HWindow,
          (XPos - NewXPos) * XUnit, (YPos - NewYPos) * YUnit, nil, nil)
      else
        InvalidateRect(Window^.HWindow, nil, True);
      XPos := NewXPos;
      YPos := NewYPos;
      UpdateWindow(Window^.HWindow);
    end;
  end;
end;

{ Scrolls to a position calculated using the passed "Delta" values. }

procedure TScroller.ScrollBy(Dx, Dy: LongInt);
begin
  ScrollTo(XPos + Dx, YPos + Dy);
end;

{ Performs "auto-scrolling".  (Dragging the mouse from within the client
  area of the Window to without results in auto-scrolling when the AutoMode
  data field of the Scroller is True). }

procedure TScroller.AutoScroll;
var
  CursorPos: TPoint;
  ClientRect: TRect;
  Dx, Dy: LongInt;
begin
  if (AutoMode and (Window <> nil)) then
  begin
    GetCursorPos(CursorPos);
    ScreenToClient(Window^.HWindow, CursorPos);
    GetClientRect(Window^.HWindow, ClientRect);
    Dx := 0; Dy := 0;
    if CursorPos.Y < 0 then
      Dy := LongMin(-YLine, LongMax(-YPage, (CursorPos.Y div 10) * YLine))
    else
      if CursorPos.Y > ClientRect.Bottom then
	Dy := LongMax(YLine, LongMin(YPage, ((CursorPos.Y - ClientRect.Bottom) div 10) * YLine));
    if CursorPos.X < 0 then
      Dx := LongMin(-XLine, LongMax(-XPage, (CursorPos.X div 10) * XLine))
    else
      if CursorPos.X > ClientRect.Right then
	Dx := LongMax(XLine, LongMin(XPage, ((CursorPos.X - ClientRect.Right) div 10) * XLine));
    ScrollBy(Dx, Dy);
  end;
end;

{ Returns a Boolean value indicating whether or not the passed area
  (in units) is currently visible. }

function TScroller.IsVisibleRect(X, Y: LongInt; XExt, YExt: Integer): Boolean;
begin
  IsVisibleRect := (X + XExt >= XPos) and (Y + YExt >= YPos)
    and (X < XPos + XPage) and (Y < YPos + YPage);
end;

{ TApplication }

{ Constructor for a TApplication object.  Sets the global Application
  variable to point to Self. Initializes instances, creating and
  displaying their main window (calls InitApplication for the first
  executing instance; calls InitInstance for all instances).}

constructor TApplication.Init(AName: PChar);
begin
  TObject.Init;
  Name := AName;
  Application := @Self;
  HAccTable := 0;
  Status := 0;
  MainWindow := nil;
  KBHandlerWnd := nil;
  StdWndProcInstance := MakeProcInstance(@StdWndProc, HInstance);
  InitMemory;
  if HPrevInst = 0 then InitApplication;
  if (Status = 0) then InitInstance;
end;

destructor TApplication.Done;
begin
  FreeProcInstance(StdWndProcInstance);
  TObject.Done;
end;

{ A place to perform any actions required outside of the message loop.
  Should return true if the it is desired that the IdleAction be called
  again, else return false.  It will always be called at least once
  when the application goes idle. }

function TApplication.IdleAction: Boolean;
begin
  IdleAction := False;
end;

{ Handles initialization for the first executing instance of the OW
  application. }

procedure TApplication.InitApplication;
begin
end;

{ Handles initialization for each executing instance of the OW
  application.  Creates and displays the main window. }

procedure TApplication.InitInstance;
begin
  InitMainWindow;
  MainWindow := MakeWindow(MainWindow);
  if MainWindow <> nil then
    MainWindow^.Show(CmdShow)
  else Status := em_InvalidMainWindow;
end;

{ Initializes the application's MainWindow object. }

procedure TApplication.InitMainWindow;
begin
  MainWindow := new(PWindow, Init(nil, nil));
end;

{ Runs the application.  Enters message loop if initialization was
  successful. }

procedure TApplication.Run;
begin
  if (Status = 0) then MessageLoop
  else Error(Status);
end;

{ Activates and deactivates "keyboard handling" (translation of keyboard
  input into control selections) for the currently active TWindowsObject.
  by setting the KBHandlerWnd to the parameter passed. This method
  is called internally by the OW whenever a OW window is activated.  If
  "keyboard handling" has been requested for the TWindowsObject, the
  parameter passed is non-nil, else nil is passed.  "Keyboard handling" is
  requested, by default, for all modeless dialogs and may be requested for
  a TWindow via a call to its EnableKBHandler method.}

procedure TApplication.SetKBHandler(AWindowsObject: PWindowsObject);
begin
  KBHandlerWnd := AWindowsObject;
end;

{ General message loop.  Retrieves and processes a message from the OW
  application's message queue.  Calls ProcessAppMsg to allow special
  handling of the message.  If not specially handled, performs default
  processing of the message, dispatching the message to the TWindowsObject's
  window procedure).  All unusual processing can be accomplished by
  redefining ProcessAppMsg or any of the Process... methods. }

procedure TApplication.MessageLoop;
var
  Message: TMsg;
  IsDone: Boolean;
begin
  IsDone := False;
  repeat
    if PeekMessage(Message, 0, 0, 0, pm_Remove) then
    begin
      if Message.Message = wm_Quit then IsDone := True
      else
        if not ProcessAppMsg(Message) then
        begin
          TranslateMessage(Message);
          DispatchMessage(Message);
        end
    end
    else
      if not IdleAction then
        WaitMessage;
  until IsDone;
  Status := Message.WParam;
end;

{ Performs special handling for the message last retrieved.  Translates
  keyboard input messages into control selections or command messages,
  when appropriate.  Dispatches message, if translated. }

function TApplication.ProcessAppMsg(var Message: TMsg): Boolean;
begin
  ProcessAppMsg :=
    ProcessDlgMsg(Message) or
    ProcessMDIAccels(Message) or
    ProcessAccels(Message);
end;

{ Attempts to translate a message into a control selection if the currently
  active OW window has requested "keyboard handling".  (Some keyboard
  input messages are translated into control selection messages).
  Dispatches message, if translated. }

function TApplication.ProcessDlgMsg(var Message: TMsg): Boolean;
begin
  ProcessDlgMsg := False;
  if (KBHandlerWnd <> nil) and (KBHandlerWnd^.HWindow <> 0) then
    ProcessDlgMsg := IsDialogMessage(KBHandlerWnd^.HWindow,
      Message);
end;

{ Attempts to translate a message into a command message if the TApplication
  has loaded an accelerator table. (Keyboard input messages for which an
  entry exists in the accelerator table are translated into command
  messages.)  Dispatches message, if translated.  (Translation of MDI
  accelerator messages is performed in ProcessMDIAccels method.)  }

function TApplication.ProcessAccels(var Message: TMsg): Boolean;
begin
  ProcessAccels := (HAccTable <> 0) and
    (TranslateAccelerator(MainWindow^.HWindow, HAccTable, Message) <> 0);
end;

{ Attempts to translate a message into a system command message for MDI
  TApplications (whose main window is a TMDIWindow). (Some keyboard
  input messages are translated into system commands for MDI applications).
  Dispatches message, if translated. }

function TApplication.ProcessMDIAccels(var Message: TMsg): Boolean;
var
  MDIClient: PWindowsObject;
begin
  MDIClient := MainWindow^.GetClient;
  ProcessMDIAccels := (MDIClient <> nil) and
    TranslateMDISysAccel(MDIClient^.HWindow, Message);
end;

{ Determines whether or not the passed TWindowsObject can be considered
  valid.  Returns a pointer to the TWindowsObject if valid.  If invalid,
  calls Error and disposes of the TWindowsObject, returning  nil.  A
  TWindowsObject is considered invalid if a low memory condition exists or
  if the TWindowsObject has a non-zero status. }

function TApplication.ValidWindow(AWindowsObject: PWindowsObject): PWindowsObject;
begin
  ValidWindow := nil;
  if AWindowsObject <> nil then
  begin
    if LowMemory then
    begin
      Error(em_OutOfMemory);
      Dispose(AWindowsObject, Done);
      RestoreMemory;
    end
    else if AWindowsObject^.Status <> 0 then
    begin
      Error(AWindowsObject^.Status);
      Dispose(AWindowsObject, Done);
    end else ValidWindow := AWindowsObject;
  end;
end;

{ Attempts to associate an interface element with the TWindowsObject, if
  the object is valid.  Calls ValidWindow and the Create method of the
  TWindowsObject.  If either call returns an error, calls Error and
  disposes of the TWindowsObject, returning a nil pointer. }

function TApplication.MakeWindow(AWindowsObject: PWindowsObject): PWindowsObject;
begin
  MakeWindow := nil;
  if (AWindowsObject <> nil) and (ValidWindow(AWindowsObject) <> nil) then
    if not AWindowsObject^.Create then
    begin
      Error(AWindowsObject^.Status);
      Dispose(AWindowsObject, Done);
    end
    else MakeWindow := AWindowsObject;
end;

{ Attempts to execute the passed TDialog, if the TDialog is valid.
  If valid (determined by call to TDialog.ValidWindow) returns True,
  calls Execute, and disposes of the TDialog.  Calls Error if Execute
  returns an error.  Returns the result of the call to Execute 
  (or id_Cancel if not called). }

function TApplication.ExecDialog(ADialog: PWindowsObject): Integer;
var
  ReturnValue: Integer;
begin
  ExecDialog := id_Cancel;
  if ValidWindow(ADialog) <> nil then
  begin
    ReturnValue := PDialog(ADialog)^.Execute;
    if ReturnValue < 0 then
      Error(ReturnValue)
    else
      ExecDialog := ReturnValue;
    Dispose(ADialog, Done);
  end;
end;

{ Placeholder; may be redefined to process errors consistantly
  throughout the application. }

procedure TApplication.Error(ErrorCode: Integer);
var
  ErrorString: array[0..31] of Char;
begin
  WVSPrintF(ErrorString, 'Error code = %d. Continue?', ErrorCode);
  if MessageBox(0, ErrorString, 'Application Error',
      mb_IconStop + mb_YesNo) = id_No then
    Halt(ErrorCode);
end;

{ Determines whether the application can be closed, returning a Boolean
  indicator.  The default behavior specified here is to return the result
  of a call to the CanClose method of the TApplication's MainWindow. }

function TApplication.CanClose: Boolean;
begin
  CanClose := MainWindow^.CanClose;
end;

{ Objects registration procedure }

{ Provided for OW 1.0 compatibility }

procedure RegisterWObjects;
begin
  RegisterType(RCollection);
  RegisterType(RStringCollection);
  RegisterType(RStrCollection);
  RegisterType(RWindowsObject);
  RegisterType(RWindow);
  RegisterType(RDialog);
  RegisterType(RDlgWindow);
  RegisterType(RControl);
  RegisterType(RMDIWindow);
  RegisterType(RMDIClient);
  RegisterType(RButton);
  RegisterType(RCheckBox);
  RegisterType(RRadioButton);
  RegisterType(RGroupBox);
  RegisterType(RListBox);
  RegisterType(RComboBox);
  RegisterType(RScrollBar);
  RegisterType(RStatic);
  RegisterType(REdit);
  RegisterType(RScroller);
end;

procedure RegisterOWindows;
begin
  RegisterType(RWindow);
  RegisterType(RMDIWindow);
  RegisterType(RMDIClient);
  RegisterType(RScroller);
end;

end.
