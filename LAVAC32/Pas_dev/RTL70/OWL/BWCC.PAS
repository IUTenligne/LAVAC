{*******************************************************}
{                                                       }
{       Turbo Pascal                                    }
{       Borland Custom Control Interface Unit           }
{                                                       }
{       Copyright (c) 1991 Borland International        }
{                                                       }
{*******************************************************}

unit BWCC;

interface

uses WinTypes, Messages, OWindows, ODialogs;

const
  BwccVersion        = $0103;

{ From version 1.02 onward BWCCGetversion returns a Longint
  The low-order word contains the version number
  and the high-order word contains the locale. }

const
  Bwcc_Locale_US    = 1;
  Bwcc_Locale_JAPAN = 2;

{ Our Custom Dialog class }
  BorDlgClass   = 'BorDlg';

{ Borland dialog window uses this property for instance data
  users should not use a property with this name! }
  BorDlgProp    = 'FB';

  IdHelp        = 998;               { Id of help button }

{ Button style definitions:
  the Borland buttons use Windows button styles for button type: i.e.
  bs_PushButton/bs_DefPushButton }

  Button_Class ='BorBtn';            { Our Bitmap Buttons }
  Radio_Class  ='BorRadio';          { Our radio buttons }
  Check_Class  ='BorCheck';          { Our Checkboxes }

{ Styles }
  bbs_Bitmap:Longint    =  $8000;    { this is a bitmap static }
  bbs_DlgPaint:Longint  =  $4000;    { used at runtime by dialog class }
  bbs_ParentNotify:Longint=$2000;    { Notify parent of TAB keys and focus }
  bbs_OwnerDraw:Longint =  $1000;    { let parent paint via wm_DrawItem }

{ Messages }
  bbm_SetBits    =  ( BM_SETSTYLE + 10);

{ Notifications }
  bbn_SetFocus      =  ( bn_DoubleClicked + 10);
  bbn_SetFocusmouse =  ( bn_DoubleClicked + 11);
  bbn_GotaTab       =  ( bn_DoubleClicked + 12);
  bbn_GotaBTab      =  ( bn_DoubleClicked + 13);

  Shade_Class = 'BorShade';

{   The following is the name of the window message passed to
    RegisterWindowMessage for CtlColor processing for group box shades:}
  BWCC_CtlColor_Shade = 'BWCC_CtlColor_Shade';

  bss_Group         =      1;        {  group box              }
  bss_Hdip          =      2;        {  horizontal border      }
  bss_Vdip          =      3;        {  hertical border        }
  bss_Hbump         =      4;        {  horizontal speed bump  }
  bss_Vbump         =      5;        {  vertical speed bump    }
  bss_RGroup        =      6;        {  raised group box }

(*!!  bss_DlgErase      =  $8000;        {  Dialog Window erases for us }
  bss_DlgPaint      =  $4000;        {  Dialog Window paints for us }
*)
  bss_Caption       = $8000;   { Caption is above group }
  bss_CtlColor      = $4000;   { Send wm_CtlColor message to parent of control }
  bss_NoPrefix      = $2000;   { & in caption does not underline the next letter }
  bss_Left          = $0000;   { Caption is left-justified }
  bss_Center        = $0100;   { Caption is centered }
  bss_Right         = $0200;   { Caption is right-justified }
  bss_AlignMask     = $0300;

  Static_Class =   'BorStatic';      {  Our statics }

{ Function declarations }

function DialogBox(Instance: THandle; Templatename: PChar;
  WndParent: HWnd; DialogFunc: TFarProc): Integer;
function DialogBoxParam(Instance: THandle; TemplateName: PChar;
  WndParent: HWnd; DialogFunc: TFarProc; InitParam: LongInt): Integer;
function CreateDialog(Instance: THandle; TemplateName: PChar;
  WndParent: HWnd; DialogFunc: TFarProc): HWnd;
function CreateDialogParam(Instance: THandle; TemplateName: PChar;
  WndParent: HWnd; DialogFunc: TFarProc; InitParam: LongInt): HWnd;
function BWCCMessageBox(WndParent: HWnd; Txt, Caption: PChar;
  TextType: Word): Integer;
function BWCCDefDlgProc(Dlg: HWnd; Msg, wParam: Word; lParam:
  LongInt): LongInt;
function BWCCGetPattern: HBrush;
function BWCCGetVersion: Longint;
function SpecialLoadDialog(hResMod: THandle; Templatename: PChar;
  DialogFunc: TFarProc): THandle;
function MangleDialog(hDlg: THandle; hResMod: THandle;
  DialogFunc: TFarProc): THandle;
function BWCCDefWindowProc(hWindow: HWnd; Message, wParam: Word;
  lParam: LongInt): LongInt;
function BWCCDefMDIChildProc(hWindow: HWnd; Message, wParam: Word;
  lParam: LongInt): LongInt;

{ ObjectWindows objects specific to BWCC }

type
  PBDivider = ^TBDivider;
  TBDivider = object(TControl)
    constructor Init(AParent: PWindowsObject; AnId: Integer; AText: PChar;
      X, Y, W, H: Integer;  IsVertical, IsBump: Boolean);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    function GetClassName: PChar; virtual;
  end;

  PBStaticBmp = ^TBStaticBmp;
  TBStaticBmp = object(TControl)
    constructor Init(AParent: PWindowsObject; AnId: Integer; AText: PChar;
      X, Y, W, H: Integer);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    function GetClassName: PChar; virtual;
  end;

implementation

function SpecialLoadDialog;             external 'BWCC' index 1;
function DialogBox;                     external 'BWCC' index 2;
function DialogBoxParam;                external 'BWCC' index 3;
function CreateDialog;                  external 'BWCC' index 4;
function CreateDialogParam;             external 'BWCC' index 5;
function BWCCDefDlgProc;                external 'BWCC' index 6;
function BWCCMessageBox;                external 'BWCC' index 9;
function BWCCGetPattern;                external 'BWCC' index 10;
function BWCCGetVersion;                external 'BWCC' index 11;
function MangleDialog;                  external 'BWCC' index 12;
function BWCCDefWindowProc;             external 'BWCC' index 14;
function BWCCDefMDIChildProc;           external 'BWCC' index 15;

{ TBDivider }

constructor TBDivider.Init(AParent: PWindowsObject; AnId: Integer;
  AText: PChar; X, Y, W, H: Integer;  IsVertical, IsBump: Boolean);
begin
  TControl.Init(AParent, AnId, AText, X, Y, W, H);
  DisableTransfer;
  if IsVertical then
    if IsBump then
      Attr.Style := Attr.Style or BSS_VBUMP
    else
      Attr.Style := Attr.Style or BSS_VDIP
  else
    if IsBump then
      Attr.Style := Attr.Style or BSS_HBUMP
    else
      Attr.Style := Attr.Style or BSS_HDIP;
end;

constructor TBDivider.InitResource(AParent: PWindowsObject;
  ResourceID: Word);
begin
  TControl.InitResource(AParent, ResourceID);
  DisableTransfer;
end;

function TBDivider.GetClassName: PChar;
begin
  GetClassName := 'BORSHADE';
end;

{ TBStaticBmp }

constructor TBStaticBmp.Init(AParent: PWindowsObject; AnId: Integer;
  AText: PChar; X, Y, W, H: Integer);
begin
  TControl.Init(AParent, AnId, AText, X, Y, W, H);
  Attr.Style := Attr.Style or BBS_BITMAP;
  DisableTransfer;
end;

constructor TBStaticBmp.InitResource(AParent: PWindowsObject; ResourceID: Word);
begin
  TControl.InitResource(AParent, ResourceID);
  DisableTransfer;
end;

function TBStaticBmp.GetClassName: PChar;
begin
  GetClassName := 'BORBTN';
end;

begin
  OWindows.CreateDialogParam := CreateDialogParam;
  OWindows.DialogBoxParam := DialogBoxParam;
  OWindows.DefDlgProc := BWCCDefDlgProc;
  OWindows.MessageBox := BWCCMessageBox;
  OWindows.BWCCClassNames := True;
end.
