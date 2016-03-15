
{*******************************************************}
{                                                       }
{       Turbo Pascal for Windows Run-time Library       }
{       ObjectWindows Unit                              }
{                                                       }
{       Copyright (c) 1991 Borland International        }
{                                                       }
{*******************************************************}

unit OPrinter;

{$R OPRINTER.RES}

{$S-,R-}

interface

uses WinTypes, WinProcs, Messages, Objects, OWindows, ODialogs;

{ TPrinter states }
const
  ps_Ok = 0;
  ps_InvalidDevice = -1;     { Device parameters (to set device)
                               invalid }
  ps_Unassociated = -2;      { Object not associated with a printer }

{ TPrintOut flags }
const
  pf_Graphics  = $01;        { Current band only accepts text }
  pf_Text      = $02;        { Current band only accepts graphics }
  pf_Both      = $03;        { Current band accepts both text and
                               graphics }
  pf_Banding   = $04;        { Set the printout is being banded }
  pf_Selection = $08;        { Printing the selection }

type
  PPrintDialogRec = ^TPrintDialogRec;
  TPrintDialogRec = record
    drStart: Integer;             { Starting page }
    drStop: Integer;              { Ending page }
    drCopies: Integer;            { Number of copies to print }
    drCollate: Boolean;           { Tell the printer to collate copies }
    drUseSelection: Boolean;      { Use seletion instead of Start, Stop }
  end;

{ TPrintOut represents the physical printed document which is to
  sent to a printer to be printed. TPrintOut does the rendering of
  the document onto the printer.  For every document, or document
  type, a cooresponding TPrintOut class should be created. }

type
  PPrintOut = ^TPrintOut;
  TPrintOut = object(TObject)
    Title: PChar;
    Banding: Boolean;
    ForceAllBands: Boolean;
    DC: HDC;
    Size: TPoint;
    constructor Init(ATitle: PChar);
    destructor Done; virtual;
    procedure BeginDocument(StartPage, EndPage: Integer;
      Flag: Word); virtual;
    procedure BeginPrinting; virtual;
    procedure EndDocument; virtual;
    procedure EndPrinting; virtual;
    function GetDialogInfo(var Pages: Integer): Boolean; virtual;
    function GetSelection(var Start, Stop: Integer): Boolean; virtual;
    function HasNextPage(Page: Word): Boolean; virtual;
    procedure PrintPage(Page: Word; var Rect: TRect; Flags: Word); virtual;
    procedure SetPrintParams(ADC: HDC; ASize: TPoint); virtual;
   end;

{ TPrinter represent the physical printer device.  To print a
  TPrintOut, send the TPrintOut to the TPrinter's Print method. }

  PPrinter = ^TPrinter;
  TPrinter = object(TObject)
    Device, Driver, Port: PChar;        { Printer device description }
    Status: Integer;                    { Device status, error is <> ps_Ok }
    Error: Integer;                     { < 0 if error occured during print }
    DeviceModule: THandle;              { Handle to printer driver module }
    DeviceMode: TDeviceMode;            { Function pointer to DevMode }
    ExtDeviceMode: TExtDeviceMode;      { Function pointer to ExtDevMode }
    DevSettings: PDevMode;              { Local copy of printer settings }
    DevSettingSize: Integer;            { Size of the printer settings }

    constructor Init;
    destructor Done; virtual;
    procedure ClearDevice;
    procedure Configure(Window: PWindowsObject);
    function GetDC: HDC; virtual;
    function InitAbortDialog(Parent: PWindowsObject;
      Title: PChar): PDialog; virtual;
    function InitPrintDialog(Parent: PWindowsObject; PrnDC: HDC;
      Pages: Integer; SelAllowed: Boolean;
      var Data: TPrintDialogRec): PDialog; virtual;
    function InitSetupDialog(Parent: PWindowsObject): PDialog; virtual;
    procedure ReportError(PrintOut: PPrintOut); virtual;
    procedure SetDevice(ADevice, ADriver, APort: PChar);
    procedure Setup(Parent: PWindowsObject);
    function Print(ParentWin: PWindowsObject; PrintOut: PPrintOut): Boolean;
  end;

{ TPrinterSetupDlg is a dialog to modify which printer a TPrinter
  object is attached to.  It displays the all the active printers
  in the system allowing the user to select the desired printer.
  The dialog also allow the user to call up the printer's
  "setup" dialog for further configuration of the printer. }

const
  id_Combo = 100;
  id_Setup = 101;

type
  PPrinterSetupDlg = ^TPrinterSetupDlg;
  TPrinterSetupDlg = object(TDialog)
    Printer: PPrinter;
    constructor Init(AParent: PWindowsObject; TemplateName: PChar;
      APrinter: PPrinter);
    destructor Done; virtual;
    procedure TransferData(TransferFlag: Word); virtual;
    procedure IDSetup(var Msg: TMessage);
      virtual id_First + id_Setup;
    procedure Cancel(var Msg: TMessage);
      virtual id_First + id_Cancel;
  private
    OldDevice, OldDriver, OldPort: PChar;
    DeviceCollection: PCollection;
  end;

const
  id_Title  = 101;
  id_Device = 102;
  id_Port   = 103;

type
  PPrinterAbortDlg = ^TPrinterAbortDlg;
  TPrinterAbortDlg = object(TDialog)
    constructor Init(AParent: PWindowsObject; Template, Title,
      Device, Port: PChar);
    procedure SetupWindow; virtual;
    procedure WMCommand(var Msg: TMessage);
      virtual wm_First + wm_Command;
  end;

const
  id_PrinterName  = 102;
  id_All          = 103;
  id_Selection    = 104;
  id_Pages        = 105;
  id_FromText     = 106;
  id_From         = 107;
  id_ToText       = 108;
  id_To           = 109;
  id_PrintQuality = 110;
  id_Copies       = 111;
  id_Collate      = 112;

type
  PPrintDialog = ^TPrintDialog;
  TPrintDialog = object(TDialog)
    Printer: PPrinter;
    PData: PPrintDialogRec;
    PrinterName: PStatic;
    Pages: Integer;
    Controls: PCollection;
    AllBtn, SelectBtn, PageBtn: PRadioButton;
    FromPage, ToPage: PEdit;
    Copies: PEdit;
    Collate: PCheckBox;
    PrnDC: HDC;
    SelAllowed: Boolean;
    constructor Init(AParent: PWindowsObject; Template: PChar; APrnDC: HDC;
      APages: Integer; APrinter: PPrinter; ASelAllowed: Boolean;
      var Data: TPrintDialogRec);
    procedure SetupWindow; virtual;
    procedure TransferData(Direction: Word); virtual;
    procedure IDSetup(var Msg: TMessage);
      virtual id_First + id_Setup;
  end;

type
  PEditPrintout = ^TEditPrintout;
  TEditPrintout = object(TPrintout)
    Editor: PEdit;
    NumLines: Integer;
    LinesPerPage: Integer;
    LineHeight: Integer;
    StartPos: Integer;
    StopPos: Integer;
    StartLine: Integer;
    StopLine: Integer;
    constructor Init(AEditor: PEdit; ATitle: PChar);
    procedure BeginDocument(StartPage, EndPage: Integer;
      Flags: Word); virtual;
    function GetDialogInfo(var Pages: Integer): Boolean; virtual;
    function GetSelection(var Start, Stop: Integer): Boolean; virtual;
    function HasNextPage(Page: Word): Boolean; virtual;
    procedure PrintPage(Page: Word; var Rect: TRect; Flags: Word); virtual;
    procedure SetPrintParams(ADC: HDC; ASize: TPoint); virtual;
  end;

type
  PWindowPrintout = ^TWindowPrintout;
  TWindowPrintout = object(TPrintOut)
    Window: PWindow;
    Scale: Boolean;
    constructor Init(ATitle: PChar; AWindow: PWindow);
    function GetDialogInfo(var Pages: Integer): Boolean; virtual;
    procedure PrintPage(Page: Word; var Rect: TRect; Flags: Word); virtual;
  end;

implementation

uses Strings;

const
  sr_On             = 32512;
  sr_ErrorTemplate  = 32513;
  sr_OutOfMemory    = 32514;
  sr_OutOfDisk      = 32515;
  sr_PrnCancel      = 32516;
  sr_PrnMgrAbort    = 32517;
  sr_GenError       = 32518;
  sr_ErrorCaption   = 32519;

const
  UserAbort: Boolean = False;

{ FormDriverStr ---------------------------------------------------- }

procedure FormDriverStr(DriverStr: PChar; MaxLen: Integer;
  Device, Port: PChar);
begin
  StrLCopy(DriverStr, Device, MaxLen);
  LoadString(hInstance, sr_On, @DriverStr[StrLen(DriverStr)],
    MaxLen - StrLen(DriverStr) - 1);
  StrLCat(DriverStr, Port, MaxLen);
end;

{ TPrintOut -------------------------------------------------------- }

constructor TPrintOut.Init(ATitle: PChar);
const
  Blank: array[0..0] of Char = '';
var
  S: array[0..31] of Char;
begin
  TObject.Init;
  if (ATitle = nil) or (ATitle^ = #0) then
    Title := @Blank
  else
  begin
    { Force the length to be 31 chars or less }
    StrLCopy(S, ATitle, SizeOf(S));
    Title := StrNew(S);
  end;
  Banding := False;
  ForceAllBands := True;
end;

destructor TPrintOut.Done;
begin
  StrDispose(Title);
  TObject.Done;
end;

{ This method is called before a document begins printing.  It is
  called once for every copy of the document that is printed.  The
  Flags parameter contains whether the selection is being printed
  and whether the document is going to be banded. }

procedure TPrintOut.BeginDocument(StartPage, EndPage: Integer; Flag: Word);
begin
end;

{ Called at the beginning of printing.  It is called once, regardless
  of how many copies of the document are being printed. }

procedure TPrintOut.BeginPrinting;
begin
end;

{ Called after each copy of the document is printed. }

procedure TPrintOut.EndDocument;
begin
end;

{ Called after all the copies of the documents are printed. }

procedure TPrintOut.EndPrinting;
begin
end;

{ Get the information necessary to bring up the page range selection
  dialog.  If this function returns true, the dialog will brought up.
  The pages value is optional,  if the page count is easily caluclated
  return the number of pages in the doucment; otherwise, return 0 and
  no limit will be applied to the dialog.  The document will stop
  printing when HasNextPage returns false. }

function TPrintOut.GetDialogInfo(var Pages: Integer): Boolean;
begin
  Pages := 0;
  GetDialogInfo := True;
end;

{ Called to determine, first, if the document being printed has a
  selection and then what is it.  If there is not a selection the
  selection radio button is disabled on the default print dialog. }

function TPrintOut.GetSelection(var Start, Stop: Integer): Boolean;
begin
  GetSelection := False;
end;

{ Called after every page to determine if another page is ready to
  print. }

function TPrintOut.HasNextPage(Page: Word): Boolean;
begin
  HasNextPage := False;
end;

{ Called to render the given page of the printout.  The pages
  will come in order in the range passed to BeginDocument.  The
  page might be called multiple time if banding is enabled. }

procedure TPrintOut.PrintPage(Page: Word; var Rect: TRect; Flags: Word);
begin
  Abstract;
end;

{ Called to register the DC and page size with the object.  This
  is the first method called after the object is passed to
  the Print method of a Printer object.  If this method is
  overriden, the inherited function must be called. }

procedure TPrintOut.SetPrintParams(ADC: HDC; ASize: TPoint);
begin
  DC := ADC;
  Size := ASize;
end;

{ FetchStr --------------------------------------------------------- }
{   Returns a pointer to the first comma delimited field pointed to  }
{   by Str. It replaces the comma with a #0 and moves the Str to the }
{   beginning of the next string (skipping white space).  Str will   }
{   will point to a #0 character if no more strings are left.  This  }
{   routine is used to fetch strings out of text retrieved from      }
{   WIN.INI.                                                         }

function FetchStr(var Str: PChar): PChar;
begin
  FetchStr := Str;
  if Str = nil then Exit;
  while (Str^ <> #0) and (Str^ <> ',') do
    Str := AnsiNext(Str);
  if Str^ = #0 then Exit;
  Str^ := #0;
  Inc(Str);
  while Str^ = ' ' do
    Str := AnsiNext(Str);
end;

{ TReplaceStatic --------------------------------------------------- }

type
  PReplaceStatic = ^TReplaceStatic;
  TReplaceStatic = object(TStatic)
    Text: PChar;
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word;
      AText: PChar);
    destructor Done; virtual;
    procedure SetupWindow; virtual;
  end;

constructor TReplaceStatic.InitResource(AParent: PWindowsObject; ResourceID: Word;
  AText: PChar);
begin
  TStatic.InitResource(AParent, ResourceID, 0);
  Text := StrNew(AText);
end;

destructor TReplaceStatic.Done;
begin
  StrDispose(Text);
  TStatic.Done;
end;

procedure TReplaceStatic.SetupWindow;
var
  A: array[0..80] of Char;
  B: array[0..80] of Char;
begin
  TStatic.SetupWindow;
  GetText(A, SizeOf(A) - 1);
  WVSPrintF(B, A, Text);
  SetText(B);
end;

{ TPrinterAbortDlg ----------------------------------------------------- }

constructor TPrinterAbortDlg.Init(AParent: PWindowsObject; Template,
  Title, Device, Port: PChar);
var
  Tmp: PWindowsObject;
begin
  TDialog.Init(AParent, Template);
  Tmp := New(PReplaceStatic, InitResource(@Self, id_Title, Title));
  Tmp := New(PReplaceStatic, InitResource(@Self, id_Device, Device));
  Tmp := New(PReplaceStatic, InitResource(@Self, id_Port, Port));
end;

procedure TPrinterAbortDlg.SetupWindow;
begin
  TDialog.SetupWindow;
  EnableMenuItem(GetSystemMenu(HWindow, False), sc_Close, mf_Grayed);
end;

procedure TPrinterAbortDlg.WMCommand(var Msg: TMessage);
begin
  UserAbort := True;
end;

{ TPrinter --------------------------------------------------------- }

{ This object type is an ecapsulation around the Windows printer
  device interface.  After the object is initialized the Status
  field must be check to see of the object was created correctly.
  Examples:
    Creating a default device printing object:

      DefaultPrinter := New(PPrinter, Init);

    Creating a device for a specific printer:

      PostScriptPrinter := New(PPrinter, Init);
      PostScriptPrinter^.SetDevice('PostScript Printer',
        'PSCRIPT','LPT2:');

    Allowing the user to configure the printer:

      DefaultPrinter^.Configure(MyWindow);
}

{ Initialize the TPrinter object assigned to the default printer }

constructor TPrinter.Init;
begin
  TObject.Init;
  Device := nil;
  Driver := nil;
  Port := nil;
  DeviceModule := 0;
  DevSettings := nil;
  Error := 0;
  SetDevice(nil, nil, nil);  { Associate with default printer }
end;

{ Deallocate allocated resources }

destructor TPrinter.Done;
begin
  ClearDevice;
  TObject.Done;
end;

{ Clears the association of this object with the current device }

procedure TPrinter.ClearDevice;
begin
  StrDispose(Device); Device := nil;
  StrDispose(Driver); Driver := nil;
  StrDispose(Port); Port := nil;
  if DeviceModule >= 32 then
  begin
    FreeLibrary(DeviceModule);
    DeviceModule := 0;
  end;
  if DevSettings <> nil then
    FreeMem(DevSettings, DevSettingSize);
  Status := ps_Unassociated;
end;

{ Associates the printer object with a new device. If the ADevice
  parameter is nil the Windows default printer is used, otherwise,
  the parameters must be ones contained in the [devices] section
  of the WIN.INI file. }

procedure TPrinter.SetDevice(ADevice, ADriver, APort: PChar);
var
  DriverName: array[0..80] of Char;
  DevModeSize: Integer;
  StubDevMode: TDevMode;

  procedure GetDefaultPrinter;
  var
    Printer: array[0..80] of Char;
    Cur: PChar;

  begin
    GetProfileString('windows', 'device', '', Printer,
      SizeOf(Printer) - 1);
    Cur := Printer;
    Device := StrNew(FetchStr(Cur));
    Driver := StrNew(FetchStr(Cur));
    Port := StrNew(FetchStr(Cur));
  end;

  function Equal(S1, S2: PChar): Boolean;
  begin
    Equal := (S1 <> nil) and (S2 <> nil) and
      (StrComp(S1, S2) = 0);
  end;

begin
  if Equal(Device, ADevice) and Equal(Driver, ADriver) and
    Equal(Port, APort) then Exit;
  ClearDevice;
  if ADevice = nil then
    GetDefaultPrinter
  else
  begin
    Device := StrNew(ADevice);
    Driver := StrNew(ADriver);
    Port := StrNew(APort);
  end;
  if (Device = nil) or (Driver = nil) or (Port = nil) then
  begin
    Status := ps_Unassociated;
    Exit;
  end;
  Status := ps_Ok;
  StrLCopy(DriverName, Driver, SizeOf(DriverName) - 1);
  StrLCat(DriverName, '.DRV', SizeOf(DriverName) - 1);
  DeviceModule := LoadLibrary(DriverName);
  if DeviceModule < 32 then Status := ps_InvalidDevice
  else
  begin
    { Grab the DevMode procedures }
    @ExtDeviceMode := GetProcAddress(DeviceModule, 'ExtDeviceMode');
    @DeviceMode := GetProcAddress(DeviceModule, 'DeviceMode');
    if (@DeviceMode = nil) and (@ExtDeviceMode = nil) then
      Status := ps_InvalidDevice;
    if @ExtDeviceMode <> nil then
    begin
      { Get default printer settings }
      DevSettingSize := ExtDeviceMode(0, DeviceModule, StubDevMode,
        Device, Port, StubDevMode, nil, 0);
      GetMem(DevSettings, DevSettingSize);
      ExtDeviceMode(0, DeviceModule, DevSettings^, Device, Port,
        DevSettings^, nil, dm_Out_Buffer);
    end
    else
      DevSettings := nil; { Cannot use local settings }
  end;
end;

{ Configure brings up a dialog as a child of the given window
  to configure the associated printer driver. }

procedure TPrinter.Configure(Window: PWindowsObject);
begin
  if Status = ps_Ok then
    if @ExtDeviceMode = nil then { driver is only supports DevMode }
      { If DeviceMode = nil, Status will <> ps_Ok }
      DeviceMode(Window^.HWindow, DeviceModule, Device, Port)
    else
      { Request driver to modify local copy of printer settings }
      ExtDeviceMode(Window^.HWindow, DeviceModule, DevSettings^, Device,
        Port, DevSettings^, nil, dm_In_Buffer or dm_Prompt or
          dm_Out_Buffer);
end;

{ Returns a device context for the associated printer, 0 if an
  error occurs or Status is <> ps_Ok }

function TPrinter.GetDC: HDC;
begin
  if Status = ps_Ok then
    GetDC := CreateDC(Driver, Device, Port, DevSettings)
  else GetDC := 0;
end;

{ Abort procedure used for printing }
function AbortProc(Prn: HDC; Code: Integer): Boolean; export;
var
  Msg: TMsg;
begin
  while not UserAbort and PeekMessage(Msg, 0, 0, 0, pm_Remove) do
    if not Application^.ProcessAppMsg(Msg) then
    begin
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
  AbortProc := not UserAbort;
end;

function TPrinter.Print(ParentWin: PWindowsObject;
  PrintOut: PPrintOut): Boolean;
type
  TAbortProc = function (Prn: HDC; Code: Integer): Boolean;
var
  PageSize: TPoint;
  PrnDC: HDC;
  Pages: Integer;
  BandRect: TRect;
  Banding: Boolean;
  FirstBand: Boolean;
  Flags: Word;
  AbortProcInst: TFarProc;
  Dlg: PWindowsObject;
  UseBandInfo: Boolean;
  PageNumber: Word;
  PageRange: TPrintDialogRec;
  OldCursor: HCursor;
  Copies: Integer;
  SelStart, SelStop: Integer;
  UsePageRangeDlg: Boolean;

procedure CalcBandingFlags;
type
  TBandInfoStruct = record
    fGraphicsFlag: Bool;
    fTextFlag: Bool;
    GraphcisRect: TRect;
  end;
var
  BandInfoRec: TBandInfoStruct;
  pFlags: Word;
begin
  { Calculate text verses graphics banding }
  if UseBandInfo then
  begin
    Escape(PrnDC, BandInfo, SizeOf(TBandInfoStruct), nil, @BandInfoRec);
    if BandInfoRec.fGraphicsFlag then pFlags := pf_Graphics;
    if BandInfoRec.fTextFlag then pFlags := pf_Text;
    Flags := (Flags and not pf_Both) or pFlags;
  end
  else
  begin
    { If a driver does not support BandInfo the Microsoft
      Recommended way of determining text only bands is if
      the first band is the full page, all others are
      graphcis only.  Otherwise it handles both. }
    if FirstBand and (LongInt((@BandRect.left)^) = 0)
       and (BandRect.right = PageSize.X) and
       (BandRect.bottom = PageSize.Y) then
      Flags := (Flags and not pf_Both) or pf_Text
    else
      if Flags and pf_Both = pf_Text then
        { All other bands are graphics only }
        Flags := (Flags and not pf_Both) or pf_Graphics
      else
        Flags := Flags or pf_Both;
  end;

  FirstBand := False;
end;

procedure WaitCursor;
begin
  OldCursor := SetCursor(LoadCursor(0, idc_Wait));
end;

procedure RestoreCursor;
begin
  SetCursor(OldCursor);
end;

begin
  Print := False; { Assume error occured }

  Error := 0;

  if PrintOut = nil then Exit;
  if ParentWin = nil then Exit;

  WaitCursor;

  PrnDC := GetDC;
  if PrnDC = 0 then Exit;

  { Get the page size }
  PageSize.X := GetDeviceCaps(PrnDC, HorzRes);
  PageSize.Y := GetDeviceCaps(PrnDC, VertRes);

  Printout^.SetPrintParams(PrnDC, PageSize);
  UsePageRangeDlg := Printout^.GetDialogInfo(Pages);

  with PageRange do
  begin
    drUseSelection := False;
    drStart := 1;
    if Pages = 0 then drStop := MaxInt
    else drStop := Pages;
    drCopies := 1;
    drCollate := True;
  end;

  if UsePageRangeDlg then
  begin
    if Application^.ExecDialog(InitPrintDialog(ParentWin, PrnDC, Pages,
        Printout^.GetSelection(SelStart, SelStop), PageRange)) <> id_OK then
    begin
      DeleteDC(PrnDC);
      Exit;
    end;
  end;

  if PageRange.drCollate then
    Copies := PageRange.drCopies
  else
  begin
    Flags := PageRange.drCopies;
    Escape(PrnDC, SetCopyCount, SizeOf(Flags), @Flags, nil);
    Copies := 1;
  end;

  with PageRange do
    if drUseSelection then
    begin
      drStart := SelStart;
      drStop := SelStop;
    end;

  Dlg := Application^.MakeWindow(InitAbortDialog(ParentWin,
    PrintOut^.Title));

  if Dlg = nil then
  begin
    DeleteDC(PrnDC);
    Exit;
  end;

  RestoreCursor;

  EnableWindow(ParentWin^.HWindow, False);

  AbortProcInst := MakeProcInstance(@AbortProc, hInstance);
  Escape(PrnDC, WinTypes.SetAbortProc, 0, PChar(AbortProcInst), nil);

  { Only band if the user requests banding and the printer
    supports banding }
  Banding := PrintOut^.Banding and
    (GetDeviceCaps(PrnDC, RasterCaps) or rc_Banding <> 0);

  if not Banding then
  begin
    { Set the banding rectangle to full page }
    LongInt((@BandRect.left)^) := 0;
    TPoint(Pointer(@BandRect.right)^) := PageSize;
  end
  else
  begin
    { Only use BandInfo if supported (note: using Flags as a temporary) }
    Flags := BandInfo;
    UseBandInfo :=
      Escape(PrnDC, QueryEscSupport, SizeOf(Flags), @Flags, nil) <> 0;
  end;

  Printout^.BeginPrinting;

  repeat
    Flags := pf_Both;
    if Banding then Flags := pf_Banding;
    if PageRange.drUseSelection then
      Flags := Flags or pf_Selection;
    Error := Escape(PrnDC, WinTypes.StartDoc, StrLen(PrintOut^.Title),
      PrintOut^.Title, nil);
    if Error > 0 then
    begin
      Printout^.BeginDocument(PageRange.drStart, PageRange.drStop,
        Flags);
      PageNumber := PageRange.drStart;
      repeat
        if Banding then
        begin
          FirstBand := True;
          Error := Escape(PrnDC, NextBand, 0, nil, @BandRect);
        end;
        repeat
          { Call the abort proc between bands or pages }
          TAbortProc(AbortProcInst)(PrnDC, 0);

          if Banding then
          begin
            CalcBandingFlags;
            if (PrintOut^.ForceAllBands) and
               (Flags and pf_Both = pf_Text) then
              SetPixel(PrnDC, 0, 0, 0);
          end;

          if Error > 0 then
          begin
            PrintOut^.PrintPage(PageNumber, BandRect, Flags);
            if Banding then
              Error := Escape(PrnDC, NextBand, 0, nil, @BandRect);
          end;
        until (Error <= 0) or not Banding or IsRectEmpty(BandRect);

        { NewFrame should only be called if not banding }
        if (Error > 0) and not Banding then
          Error := Escape(PrnDC, NewFrame, 0, nil, nil);

        Inc(PageNumber);
      until (Error <= 0) or not PrintOut^.HasNextPage(PageNumber) or
        (PageNumber > PageRange.drStop);

      Printout^.EndDocument;

      { Tell GDI the document is finished }
      if Error > 0 then
        if Banding and UserAbort then
          Escape(PrnDC, WinTypes.AbortDoc, 0, nil, nil)
        else
          Escape(PrnDC, WinTypes.EndDoc, 0, nil, nil);
    end;
    Dec(Copies);
  until (Copies = 0) or UserAbort;

  Printout^.EndPrinting;

  { Reset copies }
  if not PageRange.drCollate then
  begin
    Flags := 1;
    Escape(PrnDC, SetCopyCount, SizeOf(Flags), @Flags, nil);
  end;

  { Free allocated resources }
  FreeProcInstance(AbortProcInst);
  EnableWindow(ParentWin^.HWindow, True);
  Dispose(Dlg, Done);
  DeleteDC(PrnDC);

  if Error and sp_NotReported <> 0 then
    ReportError(PrintOut);

  Print := (Error > 0) and not UserAbort;

  UserAbort := False;
end;

function TPrinter.InitAbortDialog(Parent: PWindowsObject;
  Title: PChar): PDialog;
var
  Dlg: PDialog;
  Template: PChar;
begin
  if BWCCClassNames then Template := 'AbortDialogB'
  else Template := 'AbortDialog';
  InitAbortDialog := New(PPrinterAbortDlg, Init(Parent, Template, Title,
    Device, Port));
end;

function TPrinter.InitPrintDialog(Parent: PWindowsObject; PrnDC: HDC;
  Pages: Integer; SelAllowed: Boolean; var Data: TPrintDialogRec): PDialog;
var
  Template: PChar;
begin
  if BWCCClassNames then Template := 'PrintDialogB'
  else Template := 'PrintDialog';
  InitPrintDialog := New(PPrintDialog, Init(Parent, Template, PrnDC, Pages,
    @Self, SelAllowed, Data));
end;

function TPrinter.InitSetupDialog(Parent: PWindowsObject): PDialog;
var
  Template: PChar;
begin
  if BWCCClassNames then Template := 'PrinterSetupB'
  else Template := 'PrinterSetup';
  InitSetupDialog := New(PPrinterSetupDlg, Init(Parent, Template,
    @Self));
end;

procedure TPrinter.Setup(Parent: PWindowsObject);
begin
  if Status = ps_Ok then
    Application^.ExecDialog(InitSetupDialog(Parent));
end;

procedure TPrinter.ReportError(PrintOut: PPrintOut);
var
  ErrorMsg: array[0..80] of Char;
  ErrorCaption: array[0..80] of Char;
  ErrorTemplate: array[0..40] of Char;
  ErrorStr: array[0..40] of Char;
  ErrorId: Word;
  Msg, Title: PChar;
begin
  case Error of
    sp_AppAbort:    ErrorId := sr_PrnCancel;
    sp_Error:       ErrorId := sr_GenError;
    sp_OutOfDisk:   ErrorId := sr_OutOfDisk;
    sp_OutOfMemory: ErrorId := sr_OutOfMemory;
    sp_UserAbort:   ErrorId := sr_PrnMgrAbort;
  else
    Exit;
  end;

  LoadString(hInstance, sr_ErrorTemplate, ErrorTemplate,
    SizeOf(ErrorTemplate));
  LoadString(hInstance, ErrorId, ErrorStr, SizeOf(ErrorStr));
  Title := PrintOut^.Title;
  Msg := ErrorStr;
  WVSPrintF(ErrorMsg, ErrorTemplate, Title);
  LoadString(hInstance, sr_ErrorCaption, ErrorCaption,
    SizeOf(ErrorCaption));
  MessageBox(0, ErrorMsg, ErrorCaption, mb_Ok or mb_IconStop);
end;

{ TPrinterSetupDlg ------------------------------------------------- }

{ TPrinterSetupDlg assumes the template passed has a ComboBox with
  the control ID of 100 and a "Setup" button with id 101 }

const
  pdStrWidth = 80;

type
  PTransferRec = ^TTransferRec;
  TTransferRec = record
    Strings: PCollection;
    Selected: array[0..0] of Char;
  end;

  PDeviceRec = ^TDeviceRec;
  TDeviceRec = record
    Driver, Device, Port: PChar;
  end;

  PDeviceCollection = ^TDeviceCollection;
  TDeviceCollection = object(TCollection)
    procedure FreeItem(P: Pointer); virtual;
  end;

procedure TDeviceCollection.FreeItem(P: Pointer);
begin
  with PDeviceRec(P)^ do
  begin
    StrDispose(Driver);
    StrDispose(Device);
    StrDispose(Port);
  end;
  Dispose(PDeviceRec(P));
end;

constructor TPrinterSetupDlg.Init(AParent: PWindowsObject;
  TemplateName: PChar; APrinter: PPrinter);
var
  tmp: PComboBox;
  Devices,                                  { List of devices from the
                                              WIN.INI }
  Device: PChar;                            { Current device }
  DevicesSize: Integer;                     { Amount of bytes allocated
                                              to store 'devices' }
  Driver,                                   { Name of the driver for the
                                              device }
  Port: PChar;                              { Name of the port for the
                                              device }
  DriverLine: array[0..pdStrWidth] of Char; { Device line from WIN.INI }
  LineCur: PChar;                           { FetchStr pointer into
                                              DriverLine }
  DriverStr: array[0..pdStrWidth] of Char;  { Text being built for display }
  StrCur: PChar;                            { Temp pointer used for copying
                                              Port into the line }
  StrCurSize: Integer;                      { Room left in DriverStr to
                                              copy Port }
  DevRec: PDeviceRec;                       { Record pointer built to
                                              store in DeviceCollection }
begin
  TDialog.Init(AParent, TemplateName);
  tmp := New(PComboBox, InitResource(@Self, id_Combo, pdStrWidth));
  GetMem(TransferBuffer, SizeOf(PCollection) + pdStrWidth);
  PTransferRec(TransferBuffer)^.Strings := New(PStrCollection,
    Init(5, 5));
  Printer := APrinter;
  DeviceCollection := New(PDeviceCollection, Init(5, 5));

  if MaxAvail div 2 > 4096 then DevicesSize := 4096
  else DevicesSize := MaxAvail div 2;
  GetMem(Devices, DevicesSize);

  { Save initial values of printer for Cancel }
  OldDevice := StrNew(Printer^.Device);
  OldDriver := StrNew(Printer^.Driver);
  OldPort := StrNew(Printer^.Port);

  with PTransferRec(TransferBuffer)^ do
  begin
    { Get a list of devices from WIN.INI.  Stored in the form of
      <device 1>#0<device 2>#0...<driver n>#0#0
    }
    GetProfileString('devices', nil, '', Devices, DevicesSize);

    Device := Devices;
    while Device^ <> #0 do
    begin
      GetProfileString('devices', Device, '', DriverLine,
        SizeOf(DriverLine) - 1);

      FormDriverStr(DriverStr, SizeOf(DriverStr) - 1,Device, '');

      { Get driver portion of DeviceLine }
      LineCur := DriverLine;
      Driver := FetchStr(LineCur);

      { Copy the port information from the line }
      (*   This code is complicated because the device line is of
          the form:
           <device name> = <driver name> , <port> { , <port> }
          where port (in {}) can be repeated. *)

      StrCur := @DriverStr[StrLen(DriverStr)];
      StrCurSize := SizeOf(DriverStr) - StrLen(DriverStr) - 1;
      Port := FetchStr(LineCur);
      while Port^ <> #0 do
      begin
        StrLCopy(StrCur, Port, StrCurSize);
        Strings^.Insert(StrNew(DriverStr));
        New(DevRec);
        DevRec^.Device := StrNew(Device);
        DevRec^.Driver := StrNew(Driver);
        DevRec^.Port := StrNew(Port);
        DeviceCollection^.AtInsert(Strings^.IndexOf(@DriverStr), DevRec);
        Port := FetchStr(LineCur);
      end;
      Inc(Device, StrLen(Device) + 1);
    end;
    FreeMem(Devices, DevicesSize);

    { Set the current selection to Printer's current device }
    FormDriverStr(Selected, pdStrWidth, Printer^.Device, Printer^.Port);
  end;
end;

destructor TPrinterSetupDlg.Done;
begin
  StrDispose(OldDevice);
  StrDispose(OldDriver);
  StrDispose(OldPort);
  Dispose(DeviceCollection, Done);
  Dispose(PTransferRec(TransferBuffer)^.Strings, Done);
  FreeMem(TransferBuffer, SizeOf(PCollection) + pdStrWidth);
  TDialog.Done;
end;

procedure TPrinterSetupDlg.TransferData(TransferFlag: Word);
var
  DevRec: PDeviceRec;
begin
  TDialog.TransferData(TransferFlag);
  if TransferFlag = tf_GetData then
    with PTransferRec(TransferBuffer)^ do
      { Use the current selection to set Printer }
      with PDeviceRec(DeviceCollection^.At(Strings^.IndexOf(@Selected)))^ do
        { Set the printer to the new device }
        Printer^.SetDevice(Device, Driver, Port);
end;

procedure TPrinterSetupDlg.IDSetup(var Msg: TMessage);
begin
  TransferData(tf_GetData);
  Printer^.Configure(@Self);
end;

procedure TPrinterSetupDlg.Cancel(var Msg: TMessage);
begin
  TDialog.Cancel(Msg);
  { Restore old settings, just in case the user pressed the Setup button }
  if OldDriver = nil then Printer^.ClearDevice
  else Printer^.SetDevice(OldDevice, OldDriver, OldPort);
end;

{ TNumeric }

type
  PNumeric = ^TNumeric;
  TNumeric = object(TEdit)
    Min, Max: LongInt;
    constructor Init(AParent: PWindowsObject; AnId, X, Y, W, H: Integer;
      AMin, AMax: Integer; Digits: Integer);
    constructor InitResource(AParent: PWindowsObject; Id: Integer;
      AMin, AMax: Integer; Digits: Integer);
    function CanClose: Boolean; virtual;
    function GetValue(var Value: Integer): Boolean;
    procedure SetRange(AMin, AMax: Integer);
    procedure SetValue(Value: Integer);
    procedure WMChar(var Msg: TMessage);
      virtual wm_First + wm_Char;
  end;

constructor TNumeric.Init(AParent: PWindowsObject; AnId, X, Y, W,
  H: Integer; AMin, AMax: Integer; Digits: Integer);
begin
  TEdit.Init(AParent, AnId, '', X, Y, W, H, Digits + 1, False);
  Min := AMin;
  Max := AMax;
end;

constructor TNumeric.InitResource(AParent: PWindowsObject; Id: Integer;
  AMin, AMax: Integer; Digits: Integer);
begin
  TEdit.InitResource(AParent, Id, Digits + 1);
  Min := AMin;
  Max := AMax;
end;

function TNumeric.CanClose: Boolean;
var
  Value: Integer;
  Valid: Boolean;
  Text: array[0..255] of Char;
  P: array[0..1] of LongInt;
begin
  Valid := not IsWindowEnabled(HWindow) or
    (GetValue(Value) and (Value >= Min) and (Value <= Max));
  if not Valid then
  begin
    P[0] := Min;
    P[1] := Max;
    WVSPrintF(Text, 'Value not within range (%ld-%ld).', P);
    MessageBox(HWindow, Text, 'Invalid Range', mb_IconStop or mb_Ok);
    SetSelection(0, MaxInt);
    SetFocus(HWindow);
  end;
  CanClose := Valid;
end;

function TNumeric.GetValue(var Value: Integer): Boolean;
var
  Text: array[0..255] of Char;
  Code: Integer;
begin
  GetText(Text, SizeOf(Text));
  Val(Text, Value, Code);
  GetValue := Code = 0;
end;

procedure TNumeric.SetRange(AMin, AMax: Integer);
begin
  Min := AMin;
  Max := AMax;
end;

procedure TNumeric.SetValue(Value: Integer);
var
  Text: array[0..20] of Char;
begin
  Str(Value, Text);
  SetText(Text);
end;

procedure TNumeric.WMChar(var Msg: TMessage);
begin
  if not (Char(Msg.wParamLo) in ['A'..'Z','a'..'z',',','.','<','>',
    '/','?','~','`','!','@','#','$','%','^','&','*','(',')','_','=',
    '{','}','[',']','|','\',';',':','"']) then
    DefWndProc(Msg)
  else MessageBeep(0);
end;

{ TSelRadio }

type
  PSelRadio = ^TSelRadio;
  TSelRadio = object(TRadioButton)
    Enbl: Boolean;
    Controls: PCollection;
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word;
      AEnbl: Boolean; AControls: PCollection);
    procedure BNClicked(var Msg: TMessage);
      virtual nf_First + bn_Clicked;
  end;

constructor TSelRadio.InitResource(AParent: PWindowsObject;
  ResourceID: Word; AEnbl: Boolean; AControls: PCollection);
begin
  TRadioButton.InitResource(AParent, ResourceId);
  Enbl := AEnbl;
  Controls := AControls;
end;

{ Assumes the Controls collection contains PWindowsObjects }

procedure TSelRadio.BNClicked(var Msg: TMessage);

  procedure DoEnableDisable(P: PWindowsObject); far;
  begin
    if Enbl then P^.Enable else P^.Disable;
  end;

begin
  TRadioButton.BNClicked(Msg);
  Controls^.ForEach(@DoEnableDisable);
  if Enbl then PWindowsObject(Controls^.At(0))^.Focus;
end;

{ TPrintDialog }

constructor TPrintDialog.Init(AParent: PWindowsObject; Template: PChar;
  APrnDC: HDC; APages: Integer; APrinter: PPrinter; ASelAllowed: Boolean;
  var Data: TPrintDialogRec);
var
  P: PWindowsObject;

  function QLog10(X: Integer): Integer;
  var
    I, L: Integer;
  begin
    I := 1;
    L := 0;
    if X >= 10000 then QLog10 := 5
    else
    begin
      repeat
        I := I * 10;
        Inc(L);
      until I > X;
      QLog10 := L;
    end;
  end;

begin
  TDialog.Init(AParent, Template);
  Printer := APrinter;
  PData := @Data;
  PrnDC := APrnDC;
  Pages := APages;
  SelAllowed := ASelAllowed;

  PrinterName := New(PStatic, InitResource(@Self, id_PrinterName, 0));
  Controls := New(PCollection, Init(4, 4));
  if Pages <> 0 then
  begin
    FromPage := New(PNumeric, InitResource(@Self, id_From, 1, Pages,
      QLog10(Pages)));
    ToPage := New(PNumeric, InitResource(@Self, id_To, 1, Pages,
      QLog10(Pages)));
  end
  else
  begin
    FromPage := New(PNumeric, InitResource(@Self, id_From, 1, 32767, 0));
    ToPage := New(PNumeric, InitResource(@Self, id_To, 1, 32767, 0));
  end;
  Controls^.Insert(FromPage);
  Controls^.Insert(ToPage);
  Controls^.Insert(New(PStatic, InitResource(@Self, id_FromText, 0)));
  Controls^.Insert(New(PStatic, InitResource(@Self, id_ToText, 0)));
  AllBtn := New(PSelRadio, InitResource(@Self, id_All, False, Controls));
  SelectBtn := New(PSelRadio, InitResource(@Self, id_Selection, False,
    Controls));
  PageBtn := New(PSelRadio, InitResource(@Self, id_Pages, True, Controls));
  Copies := New(PNumeric, InitResource(@Self, id_Copies, 1, 999, 3));
  Collate := New(PCheckBox, InitResource(@Self, id_Collate));
end;

procedure TPrintDialog.SetupWindow;
var
  NameText: array[0..80] of Char;
begin
  TDialog.SetupWindow;
  with Printer^ do
    FormDriverStr(NameText, SizeOf(NameText), Device, Port);
  PrinterName^.SetText(NameText);
end;

procedure TPrintDialog.TransferData(Direction: Word);
var
  Esc: Integer;
  Val: LongInt;
  Msg: TMessage;
begin
  case Direction of
    tf_SetData:
      with PData^ do
      begin
        Collate^.SetCheck(Word(drCollate));
        Esc := SetCopyCount;
        if Escape(PrnDC, QueryEscSupport, SizeOf(Esc), @Esc, @Esc) = 0 then
          Collate^.Disable;
        PNumeric(Copies)^.SetValue(drCopies);
        AllBtn^.SetCheck(bf_Checked);
        AllBtn^.BNClicked(Msg);
        if not SelAllowed then SelectBtn^.Disable;
        if Pages = 1 then
          PageBtn^.Disable
        else
        begin
          if Pages <> 0 then
          begin
            PNumeric(FromPage)^.SetValue(drStart);
            PNumeric(ToPage)^.SetValue(drStop);
          end;
        end;
      end;
    tf_GetData:
      with PData^ do
      begin
        drCollate := Boolean(Collate^.GetCheck);
        PNumeric(Copies)^.GetValue(drCopies);
        if SelectBtn^.GetCheck = bf_Checked then
          drUseSelection := True
        else
        begin
          drUseSelection := False;

          if PageBtn^.GetCheck = bf_Checked then
          begin
            PNumeric(FromPage)^.GetValue(drStart);
            PNumeric(ToPage)^.GetValue(drStop);
          end;
        end;
      end;
  end;
end;

procedure TPrintDialog.IDSetup(var Msg: TMessage);
begin
  Printer^.Configure(@Self);
end;

{ TEditPrintout }

{ This object will print-out the contents of a TEdit control }

constructor TEditPrintout.Init(AEditor: PEdit; ATitle: PChar);
begin
  TPrintout.Init(ATitle);
  Editor := AEditor;

  { The following are calculated by SetPrintParams which is called
    before any other methods are called. }
  LinesPerPage := 0;
  NumLines := 0;
  LineHeight := 0;
  StartPos := 0;
  StopPos := 0;
  StartLine := 0;
  StopLine := 0;
end;

procedure TEditPrintout.BeginDocument(StartPage, EndPage: Integer;
  Flags: Word);
begin
  if Flags and pf_Selection = 0 then
  begin
    { not using the selection, print everything }
    StartLine := 0;
    StopLine := NumLines - 1;
    StartPos := 0;
    StopPos := 32767;
  end; { else leave values set by GetSelection }
end;

function TEditPrintout.GetSelection(var Start, Stop: Integer): Boolean;
begin
  Editor^.GetSelection(StartPos, StopPos);
  if StartPos = StopPos then GetSelection := False
  else
  begin
    with Editor^ do
    begin
      StartLine := GetLineFromPos(StartPos);
      StopLine := GetLineFromPos(StopPos);
      Start := 1;
      Stop := (StopLine - StartLine) div LinesPerPage + 1;
    end;
    GetSelection := True;
  end;
end;

function TEditPrintout.GetDialogInfo(var Pages: Integer): Boolean;
begin
  Pages := NumLines div LinesPerPage + 1;
  GetDialogInfo := True;
end;

procedure TEditPrintout.PrintPage(Page: Word; var Rect: TRect; Flags: Word);
var
  LineBuffer: array[0..255] of Char;
  I: Integer;
  FirstLine: Integer;
  CurLine: Integer;
  Len: Integer;
  XOff: Integer;
begin
  FirstLine := StartLine + (Page - 1) * LinesPerPage;
  for I := 0 to LinesPerPage - 1 do
  begin
    CurLine := I + FirstLine;
    if CurLine > StopLine then Exit;

    XOff := 0;

    with Editor^ do
    begin
      GetLine(LineBuffer, SizeOf(LineBuffer), CurLine);

      { Order of these next lines is important since the beginning
        and ending selections can be on the same line.  We don't want
        to move the text before we have cut off the end of the text. }
      if (CurLine = StopLine) and (StopPos < StrLen(LineBuffer)) then
        LineBuffer[StopPos - GetLineIndex(CurLine)] := #0;
      if CurLine = StartLine then
      begin
        Len := StartPos - GetLineIndex(CurLine);
        XOff := GetTextExtent(DC, LineBuffer, Len);
        StrCopy(LineBuffer, @LineBuffer[Len]);
      end;
    end;
    TextOut(DC, XOff, I * LineHeight, LineBuffer, StrLen(LineBuffer));
  end;
end;

function TEditPrintout.HasNextPage(Page: Word): Boolean;
begin
  { Always a next page.  Will never be asked for a page beyond what
    is calculated by Paginate }
  HasNextPage := True;
end;

procedure TEditPrintout.SetPrintParams(ADC: HDC; ASize: TPoint);
var
  TextMetrics: TTextMetric;
begin
  TPrintout.SetPrintParams(ADC, ASize);
  NumLines := Editor^.GetNumLines;
  GetTextMetrics(DC, TextMetrics);
  with TextMetrics do
    LineHeight := tmHeight + tmExternalLeading;
  LinesPerPage := Size.Y div LineHeight;
end;

{ TWindowPrintout }

constructor TWindowPrintout.Init(ATitle: PChar; AWindow: PWindow);
begin
  TPrintOut.Init(ATitle);
  Window := AWindow;
  Scale := True;
end;

procedure TWindowPrintout.PrintPage(Page: Word; var Rect: TRect;
  Flags: Word);
var
  PS: TPaintStruct;
  PrevMode: Integer;
  WindowSize: TRect;
  OldVExt, OldWExt: LongInt;
begin

  { Fake up a TPaintStruct to give the window banding information }
  with PS do
  begin
    rcPaint := Rect;
    fErase := False;
    fRestore := False;
  end;

  { Conditionally scale the DC to the window so the printout will
    resemble the window }
  if Scale then
  begin
    PrevMode := SetMapMode(DC, mm_Isotropic);
    GetClientRect(Window^.HWindow, WindowSize);
    OldVExt := SetViewportExt(DC, Size.X, Size.Y);
    with WindowSize do
    begin
      OldWExt := SetWindowExt(DC, right - left, bottom - top);
      IntersectClipRect(DC, left, top, right, bottom);
    end;
    DPtoLP(DC, PS.rcPaint, 2);
  end;

  { Call the window to paint itself }
  Window^.Paint(DC, PS);

  { Remove changes made to the DC }
  if Scale then
  begin
    SetWindowExt(DC, TPoint(OldWExt).X, TPoint(OldWExt).Y);
    SetViewportExt(DC, TPoint(OldVExt).X, TPoint(OldVExt).Y);
    SetMapMode(DC, PrevMode);
  end;
end;

{ Do not bring up the print dialog since only one page is to be printed }

function TWindowPrintout.GetDialogInfo(var Pages: Integer): Boolean;
begin
  Pages := 0;
  GetDialogInfo := False;
end;

end.
