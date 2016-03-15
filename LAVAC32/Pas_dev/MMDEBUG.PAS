{************************************************}
{                                                }
{   Unité MMMCI                                  }
{                                                }
{   Projet LAVAC                                 }
{                                                }
{  (c) 1992-94 C Puissance 3 Informatique        }
{              MORGAN MULTIMEDIA                 }
{                                                }
{  par Guillaume de Bailliencourt                }
{                                                }
{  18/11/1994                                    }
{                                                }
{************************************************}

UNIT MMDEBUG;
{************************************************}
{ voir _debug.txt, _debug.res et _debug.pas ...  }
{************************************************}

interface


uses Windows,
		 Strings, ShellApi, ctl3D;

function GetDC(Wnd: HWnd): HDC;
function GetWindowDC(Wnd: HWnd): HDC;
function ReleaseDC(Wnd: HWnd; DC: HDC): Integer;

function GlobalAlloc(Flags: Word; Bytes: LongInt): THandle;
function GlobalLock(Mem: THandle): Pointer;
function GlobalUnlock(Mem: THandle): Bool;
function GlobalFree(Mem: THandle): THandle;
procedure AddDebugText(wMask : WORD; psz : PCHAR; pArgList : POINTER; bCRLF : BOOL);
procedure AddDebugFunction(wMask, wID, wMsg, wParam : WORD; lParam : DWORD; pszMsg : PCHAR; bCRLF : BOOL);
procedure UpdateDebugInfo;


type
			DWORD = longint;

const wDbgMask	:	WORD = 0;

const wFuncMask	:	WORD = 0;

			DBG_SYSTEM			= $0001;
			DBG_MCI					= $0002;
			DBG_FILE				= $0004;
			DBG_TUTOR				= $0008;
			DBG_FUNCTIONS		= $0010;

			FUNC_QCMWIN   	= $0001;
			FUNC_LAVACCR   	= $0002;
			FUNC_MMLAVAC   	= $0004;
			FUNC_QCMLAVAC  	= $0008;
			FUNC_OLEINIT   	= $0010;
			FUNC_MMMCI	   	= $0020;

			nFUNC_QCMWIN   	= 0000;
			nFUNC_LAVACCR   = 1000;
			nFUNC_MMLAVAC   = 2000;
			nFUNC_QCMLAVAC  = 3000;
			nFUNC_OLEINIT   = 4000;
			nFUNC_MMMCI	   	= 5000;

const WS_EX_MDICHILD          = $00000040;
const WS_EX_TOOLWINDOW        = $00000080;
const WS_EX_WINDOWEDGE        = $00000100;
const WS_EX_CLIENTEDGE        = $00000200;
const WS_EX_CONTEXTHELP       = $00000400;

const WS_EX_RIGHT             = $00001000;
const WS_EX_LEFT              = $00000000;
const WS_EX_RTLREADING        = $00002000;
const WS_EX_LTRREADING        = $00000000;
const WS_EX_LEFTSCROLLBAR     = $00004000;
const WS_EX_RIGHTSCROLLBAR    = $00000000;

const WS_EX_CONTROLPARENT     = $00010000;
const WS_EX_STATICEDGE        = $00020000;
const WS_EX_APPWINDOW         = $00040000;

const WS_EX_OVERLAPPEDWINDOW  = WS_EX_WINDOWEDGE OR WS_EX_CLIENTEDGE;
const WS_EX_PALETTEWINDOW     = WS_EX_WINDOWEDGE OR WS_EX_TOOLWINDOW OR WS_EX_TOPMOST;

const hDebug 					: HWND = 0;
			szText	   			:	array[0..255] of char = '';
			dwFreeSystemRes	: DWORD = 0;
			dwFreeGDIRes		: DWORD = 0;
			dwFreeUserRes		: DWORD = 0;
			szMask					: array[0..6] of char = '0';
			szSysResFmt			:	array[0..255] of char = 'System : %lu%% - GDI : %lu%% - User : %lu%%';
			lCntDC 					: longint = 0;
			szCntDCFmt			:	array[0..255] of char = 'GetDC - ReleaseDC = %ld';
			lCntMem					: longint = 0;
			szCntMemFmt			:	array[0..255] of char = 'GlobalAlloc - GlobalFree = %ld';


implementation

procedure FindCst(pszWord : PChar; dwVal : DWORD; pszRet : PCHAR; nSize : integer; var bSize : BYTE; fErrMsg : BOOL);
					external 'WINCONST' index 2;

function DebugProc(hDlg: HWnd; Message, wParam: Word;
	lParam: Longint): BOOL; export;
var
	f		: text;
	rc	: TRECT;
	i		: integer;

begin
	DebugProc := TRUE;
	case message of

		WM_INITDIALOG :
			begin
				wDbgMask := GetPrivateProfileInt('DEBUG', 'MASK', 0, 'LAVAC.INI');
				for i := 0 to 15 do begin
					if wDbgMask AND (1 SHL i) = (1 SHL i) then begin
						CheckDlgButton(hDlg, 301 + i, 1);
					end;
				end;

				wFuncMask := GetPrivateProfileInt('DEBUG', 'FUNCMASK', 0, 'LAVAC.INI');
				for i := 0 to 15 do begin
					if wFuncMask AND (1 SHL i) = (1 SHL i) then begin
						CheckDlgButton(hDlg, 401 + i, 1);
					end;
				end;

				SetWindowLong(hDlg, GWL_EXSTYLE, GetWindowLong(hDlg, GWL_EXSTYLE) OR
											WS_EX_PALETTEWINDOW OR WS_EX_CLIENTEDGE OR WS_EX_APPWINDOW);
				GetWindowRect(hDlg, rc);
				with rc do
					SetWindowPos(hDlg, 0, 0, 0, right - left + 3, bottom - top + 1, SWP_NOMOVE OR SWP_NOZORDER);
				for i := 100 to 111 do begin
					SendDlgItemMessage(hDlg, i, WM_SETFONT, GetStockObject(ANSI_VAR_FONT), 0);
				end;
				for i := 201 to 203 do begin
					SendDlgItemMessage(hDlg, i, WM_SETFONT, GetStockObject(ANSI_VAR_FONT), 0);
				end;
				for i := 301 to 317 do begin
					SendDlgItemMessage(hDlg, i, WM_SETFONT, GetStockObject(ANSI_VAR_FONT), 0);
				end;
				for i := 401 to 417 do begin
					SendDlgItemMessage(hDlg, i, WM_SETFONT, GetStockObject(ANSI_VAR_FONT), 0);
				end;
			end;

		WM_ERASEBKGND :
			begin
				{GetClientRect(hDlg, rc);
				FillRect(wParam, rc, GetStockObject(LTGRAY_BRUSH));
				exit;}
			end;

		WM_SYSCOMMAND :
			begin
				if wParam = SC_CLOSE then begin
					ShowWindow(hDlg, SW_SHOWMINIMIZED);
				end;
			end;

		WM_COMMAND :
			case wParam of

				301..317 :
					begin
						If IsDlgButtonChecked(hDlg, wParam) = 1 then begin
							wDbgMask := wDbgMask OR (1 SHL (wParam - 301));
						end else begin
							wDbgMask := wDbgMask AND NOT (1 SHL (wParam - 301));
						end;
						wvsprintf(szMask, '%d', @wDbgMask);
						WritePrivateProfileString('DEBUG', 'MASK', szMask, 'LAVAC.INI');
					end;

				401..417 :
					begin
						If IsDlgButtonChecked(hDlg, wParam) = 1 then begin
							wFuncMask := wFuncMask OR (1 SHL (wParam - 401));
						end else begin
							wFuncMask := wFuncMask AND NOT (1 SHL (wParam - 401));
						end;
						wvsprintf(szMask, '%d', @wFuncMask);
						WritePrivateProfileString('DEBUG', 'FUNCMASK', szMask, 'LAVAC.INI');
					end;

				201 :
					begin
						SetDlgItemText(hDlg, 111, '');
					end;

				202 :
					begin
						ShellExecute(hDlg, 'open', 'C:\LAVAC\DEBUG.TXT', nil, 'C:\LAVAC', SW_SHOW);
					end;

				203 :
					begin
						assign(f, 'C:\LAVAC\DEBUG.TXT');
						{$I-}
						erase(f);
						{$I+}
						if IOResult <> 0 then;
					end;

			end;

	end;
	DebugProc := FALSE;
end;

procedure AddDebugText(wMask : WORD; psz : PCHAR; pArgList : POINTER; bCRLF : BOOL);
var sz : array[0..257] of char;
		f		: text;
begin

		if wMask AND wDbgMask <> wMask then exit;

		SendDlgItemMessage(hDebug, 111, EM_SETSEL, WORD(FALSE), MAKELONG(0, WORD(-1)));
		SendDlgItemMessage(hDebug, 111, EM_SETSEL, WORD(TRUE), MAKELONG(WORD(-1), 0));
		if pArgList = nil then begin
			StrCopy(sz, psz);
		end else begin
			wvsprintf(sz, psz, pArgList);
		end;
		if bCRLF then StrCat(sz, #13#10);
		SendDlgItemMessage(hDebug, 111, EM_REPLACESEL, 0, DWORD(@sz));

		assign(f, 'C:\LAVAC\DEBUG.TXT');
		{$I-}
		append(f);
		{$I+}
		if IOResult <> 0 then begin
			{$I-}
			rewrite(f);
			{$I+}
		end;
		{$I-}
		Write(f, sz);
		close(f);
		{$I+}
		InOutRes := 0;
end;

procedure AddDebugFunction(wMask, wID, wMsg, wParam : WORD; lParam : DWORD; pszMsg : PCHAR; bCRLF : BOOL);
var
	hLib 		: THANDLE;
	szDebug : array[0..256] of char;
	bSize 	: BYTE;
const
	szRet		: array[0..32] of char = '';

begin

	if wDbgMask AND DBG_FUNCTIONS <> DBG_FUNCTIONS then exit;

	if wFuncMask AND wMask <> wMask then exit;

	hLib := LoadLibrary('_DEBUG.DLL');

	LoadString(hLib, wID, szDebug, SizeOf(szDebug));

	if pszMsg <> nil then begin
		bSize := 2;
		FindCst(pszMsg, wMsg, szRet, SizeOf(szRet), bSize, FALSE);
		StrCat(szDebug, #9);
		StrCat(szDebug, szRet);
	end;

	AddDebugText(DBG_FUNCTIONS, szDebug, nil, TRUE);

	FreeLibrary(hLib);
end;

procedure UpdateDebugInfo;
const
			hApp : HWND = 0;

begin

	if (hDebug = 0) then begin
		Ctl3dRegister(hInstance);
		Ctl3dAutoSubclass(hInstance);

		hDebug := CreateDialog(HInstance, 'DEBUG', GetDesktopWindow, DLGPROC(@DebugProc));
		ShowWindow(hDebug, SW_SHOW);
		UpdateWindow(hDebug);
		BringWindowToTop(hDebug);

	end else begin
		if hApp = 0 then begin
			hApp := FindWindow(nil, 'LAVAC_ET');
			if hApp = 0 then begin
				hApp := FindWindow(nil, 'Lavac Créateur');
			end;
		end else begin
			{SetParent(hDebug, hApp);}
		end;
	end;

	dwFreeSystemRes := 50; //GetFreeSystemResources(GFSR_SYSTEMRESOURCES);
	dwFreeGDIRes := 50; // GetFreeSystemResources(GFSR_GDIRESOURCES);
	dwFreeUserRes := 50; // GetFreeSystemResources(GFSR_USERRESOURCES);
	wvsprintf(szText, szSysResFmt, @dwFreeSystemRes);
	SetDlgItemText(hDebug, 101, szText);

	wvsprintf(szText, szCntDCFmt, @lCntDC);
	SetDlgItemText(hDebug, 102, szText);

	wvsprintf(szText, szCntMemFmt, @lCntMem);
	SetDlgItemText(hDebug, 103, szText);

end;

function GetDC(Wnd: HWnd): HDC;
var hRet : HDC;
begin
	hRet := Windows.GetDC(Wnd);
	GetDC := hRet;
	if hRet <> 0 then begin
		inc(lCntDC);
		UpdateDebugInfo;
	end;
end;

function GetWindowDC(Wnd: HWnd): HDC;
var hRet : HDC;
begin
	hRet := Windows.GetWindowDC(Wnd);
	GetWindowDC := hRet;
	if hRet <> 0 then begin
		inc(lCntDC);
		UpdateDebugInfo;
	end;
end;

function ReleaseDC(Wnd: HWnd; DC: HDC): Integer;
var nRet : integer;
begin
	nRet := Windows.ReleaseDC(Wnd, DC);
	ReleaseDC := nRet;
	if nRet <> 0 then begin
		dec(lCntDC);
		UpdateDebugInfo;
	end;
end;

function GlobalAlloc(Flags: Word; Bytes: LongInt): THandle;
var hRet : THANDLE;
begin
	hRet := Windows.GlobalAlloc(Flags, Bytes);
	GlobalAlloc := hRet;
	if hRet <> 0 then begin
		inc(lCntMem);
		UpdateDebugInfo;
	end;
end;

function GlobalLock(Mem: THandle): Pointer;
var p : Pointer;
begin
	p := Windows.GlobalLock(Mem);
	GlobalLock := p;
	if p = nil then begin
		AddDebugText(DBG_SYSTEM, 'Mem not locked...', nil, TRUE);
	end;
end;

function GlobalUnlock(Mem: THandle): Bool;
var bRet : Bool;
begin
	bRet := Windows.GlobalUnlock(Mem);
	GlobalUnlock := bRet;
	if bRet then begin
		AddDebugText(DBG_SYSTEM, 'Mem not unlocked...', nil, TRUE);
	end;
end;

function GlobalFree(Mem: THandle): THandle;
var hRet : THANDLE;
begin
	hRet := Windows.GlobalFree(Mem);
	GlobalFree := hRet;
	if (hRet = 0) AND
		 (Mem <> 0) then begin
		dec(lCntMem);
		UpdateDebugInfo;
	end;
end;

end.
