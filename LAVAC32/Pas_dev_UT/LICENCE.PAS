{************************************************}
{                                                }
{   Programme Protect                            }
{                                                }
{   Projet LAVAC                                 }
{                                                }
{  (c) 1992-95 C Puissance 3 Informatique        }
{              MORGAN MULTIMEDIA                 }
{                                                }
{  par Guillaume de Bailliencourt                }
{                                                }
{  27/02/1995                                    }
{                                                }
{************************************************}

Library Licence;

uses Windows, Dos, SysUtils, ShellAPI,
		 Strings, CommDlg, licdata;

{$R LICENCE.RES}
type TBIOSINFO = ARRAY[0..15] of BYTE;

const	CBI_OK = 0;
const	CBI_NOTFOUND = -1;
const	CBI_BADBIOS = -2;
const	CBI_LOCKED = -3;

type TSTATIONINFO = record
											nType			: TAPPTYPE;
											nNum 			: integer;
											nLock			: integer;
											dwTime		: longint;
											dwCode	  : longint;
											BiosInfo	: TBIOSINFO;
										end;

type TAPPINFO = record
											nType			: TAPPTYPE;
											nNbPR			: integer;
											nNbCR			: integer;
											nNum3			: integer;
											dwTime		: longint;
											dwCode	  : longint;
										end;

type  PLicence = ^TLicence;
			TLicence =	record
									dwOldTime	: longint;
									dwOldCode	: longint;
									szCode,
									szName,
									szFirm,
									szDept,
									szAddr,
									szCity,
									szPhon,
									szFax,
									szEmail,
									szNewNbPR,
									szNewNbCR,
									szVersion : array[0..84]of char;
									apInfo : array[0..255] of TAPPINFO;
									stInfo : array[0..255] of TSTATIONINFO;
								end;

			TOldLicence =	record
									dwTime	: longint;
									dwCode	: longint;
									szCode,
									szName,
									szFirm,
									szDept,
									szAddr,
									szCity,
									szPhon,
									szFax,
									szEmail,
									szNbPR,
									szNbCR,
									szVersion : array[0..84]of char;
								end;

			TOlderLicence =	record
									dwTime	: longint;
									dwCode	: longint;
									szCode,
									szName,
									szFirm,
									szDept,
									szAddr,
									szCity,
									szPhon,
									szFax		: array[0..84]of char;
								end;
{var
	hLogFnt   			 : TLogFont;
	hfnt						 : HFont;}

var
	bUserAnnule : BOOL;
	hDlgImpr		: HWND;
	acBiosInfo 	: TBIOSINFO;
	i						: integer;
	lic					: TLicence;
	szBuff			: array[0..255] of char;

const
	gszType			: array[0..255] of char= '';
	gnType 			: TAPPTYPE = ST_LAVAC;
	gnNum 			: integer = -1;
	gnStation		: integer = 0;

const
	gszDicName	: ARRAY[0..255] of char = '';

{	Due to the nature of Windows protected mode, wSegment must be
	&H0000, &H0040, &HA000, &HB000, &HC000, &HD000, &HE000 or &HF000
	or the call is ignored.}
{function vbPeek(wSegment : WORD; wOffset : WORD) : BYTE;	external 'vbAsm';}

function licGetCode(hWin : HWND; pszPath : PChar; n : integer) : PChar; export; forward;

function licCheckBIOS(var lic : TLicence; nType	: TAPPTYPE; var nNum : integer) : integer;
var
	i          : integer;
	j          : integer;
	nFound     : integer;
	dt : DateTime;
	dummy : WORD;
begin
	if nNum = -1 then begin
		nNum := GetPrivateProfileInt('NETWORK', 'PC', 0, szAPPINI[nType]);
		if nNum = 0 then nNum := GetPrivateProfileInt('NETWORK', 'STATION', 0, szAPPINI[nType]);
	end;
	gnStation := 0;
	nFound := CBI_NOTFOUND;
	for i := 0 to (SizeOf(lic.stInfo) DIV SizeOf(TSTATIONINFO)) - 1 do begin
		if (lic.stInfo[i].nType = nType) AND (lic.stInfo[i].nNum = nNum) then begin
			nFound := i;
			for j := 0 to SizeOf(TBIOSINFO) - 1 do begin
				if lic.stInfo[i].BiosInfo[j] <> acBiosInfo[j] then begin
					move(acBiosInfo, lic.stInfo[i].BiosInfo, SizeOf(TBIOSINFO));
					lic.stInfo[i].nLock := 0;
					gnStation := i;
					GetDate(dt.Year, dt.Month, dt.Day, dummy);
					GetTime(dt.Hour, dt.Min, dt.Sec, dummy);
					PackTime(dt, lic.stInfo[i].dwTime); { BIOS not checked => LOCK station }
					nFound := CBI_BADBIOS; { BIOS not checked => LOCK station }
					break;
				end;
			end;
			if nFound >= 0 then begin
				if lic.stInfo[i].nLock <> lic.stInfo[i].nNum then begin
					gnStation := i;
					nFound := CBI_LOCKED;
				end;
				break;
			end;
		end;
	end;
	licCheckBIOS := nFound;
end;

function licAddStation(var lic : TLicence; nType	: TAPPTYPE; var nNum : integer) : integer;
var nFound 		 : integer;
		i          : integer;
	dt : DateTime;
	dummy : WORD;
begin
		nFound := licCheckBIOS(lic, nType, nNum);
		case nFound  of
			CBI_NOTFOUND :
				begin
					for i := 0 to (SizeOf(lic.stInfo) DIV SizeOf(TSTATIONINFO)) - 1 do begin
						if lic.stInfo[i].nType = ST_EMPTY then begin
							lic.stInfo[i].nType := nType;
							lic.stInfo[i].nNum := nNum;
							lic.stInfo[i].nLock := nNum;
							GetDate(dt.Year, dt.Month, dt.Day, dummy);
							GetTime(dt.Hour, dt.Min, dt.Sec, dummy);
							PackTime(dt, lic.stInfo[i].dwTime);
							move(acBiosInfo, lic.stInfo[i].BiosInfo, SizeOf(TBIOSINFO));
							nFound := i;
							break;
						end;
					end;
				end;
		end;
		licAddStation := nFound;
end;

procedure licSetNum(nNum : integer); export;
begin
	gnNum := nNum;
end;

function licSetLang(szLang : PCHAR) : PCHAR; export;
begin
	GetModuleFileName(hInstance, gszDicName, SizeOf(gszDicName));
	if StrRScan(gszDicName, '\') <> nil then begin
		StrRScan(gszDicName, '\')[0] := #0;
	end;
	StrCat(gszDicName, '\LIC');
	StrLCat(gszDicName, szLang, StrLen(gszDicName) + 2);
	StrCat(gszDicName, '.DIC');
	licSetLang := @gszDicName;
	{MessageBox(0, gszDicName, '', 0);}
end;

procedure licSetType(nType : TAPPTYPE); export;
begin
	gnType := nType;
end;

function licGetIni(szIni : PCHAR; cbIni : integer) : PCHAR; export;
begin
	StrLCopy(szIni, szAPPINI[gnType], cbIni);
	licGetIni := @szIni;
end;

function licLoadString(szSection, szKey, szFile : PCHAR) : PCHAR; export;
const alpszDup : Array[0..3] of PChar = (nil, nil, nil, nil);
			nDup 		 : integer = 0;
var szLoadString : Array[0..255] of char;
		p : PCHAR;

begin
	GetPrivateProfileString(szSection, szKey, '???', szLoadString, SizeOf(szLoadString), szFile);
	p := StrPos(szLoadString, '\n');
	while p <> nil do begin
		p[0] := #13;
		p[1] := #10;
		p := StrPos(p, '\n');
	end;
	if alpszDup[nDup] <> nil then StrDispose(alpszDup[nDup]);
	alpszDup[nDup] := StrNew(szLoadString);
	if alpszDup[nDup] <> nil then begin
		licLoadString := alpszDup[nDup];
		Inc(nDup);
		if nDup > 3 then nDup := 0;
	end;
end;

procedure licTranslateCtrl(hDlg : HWND; szFile : PCHAR); export;
var hWin : HWND;
		szKey : Array[0..255] of char;
begin
		hWin := hDlg;
		while hWin <> 0 do begin
			{SendMessage(hWin, WM_SETFONT, hfnt, 0);}
			GetWindowText(hWin, szKey, SizeOf(szKey));
			if szKey[0] = '#' then begin
				SetWindowText(hWin, licLoadString('CONTROL', szKey, szFile));
			end;
			if hWin = hDlg then begin
				hWin := GetWindow(hDlg, GW_CHILD);
			end else begin
				hWin := GetWindow(hWin, GW_HWNDNEXT);
			end;
		end;
end;

function GetPrinterDC(hWin : HWND) : HDC;
var
	cPrintInfo	: array[0..80] of char;
	pPrintInfo	: PChar;
	lpTemp,
	lpPrinter,
	lpDriver,
	lpInterface	: PChar;

const
	PrtDlg			: TPrintDlg = ();

begin
	FillChar(PrtDlg, 0, SizeOf(PrtDlg));
	PrtDlg.lStructSize := SizeOf(PrtDlg);
	PrtDlg.hWndOwner := hWin;
	PrtDlg.Flags := PD_RETURNDC OR PD_PRINTSETUP;
	PrtDlg.nCopies := 1;
	PrtDlg.hInstance := hInstance;
	PrintDlg(@PrtDlg);
	GetPrinterDC := PrtDlg.hDC;
	GlobalFree(PrtDlg.hDevMode);
	GlobalFree(PrtDlg.hDevNames);
	Exit;

	pPrintInfo := @cPrintInfo;
	if GetProfileString('windows', 'Device', '', pPrintInfo, 80) = 0 then begin
		GetPrinterDC := 0;
		Exit;
	end;
	lpPrinter := pPrintInfo;
	lpTemp := lpPrinter;
	lpInterface := nil;
	lpDriver := lpInterface;
	while lpTemp^ <> #0 do begin
			if lpTemp^ = ',' then	begin
				inc(lpTemp);
				lpTemp^ := #0;
				while lpTemp^ = ' ' do inc(lpTemp);
				if lpDriver = nil then begin
					lpDriver := lpTemp;
				end else begin
					lpInterface := lpTemp;
					break;
				end;
			end	else begin
				inc(lpTemp);
			end;
	end;
	GetPrinterDC := CreateDC(lpDriver, lpPrinter, lpInterface, nil);
end;


Procedure PrintError(CodeErr : integer);
var
	index : integer;
const
	szError: array[0..4] of PChar =  ('#1',
																		'#2',
																		'#3',
																		'#4',
																		'#5');
begin
        {
	if Bool(CodeErr AND SP_NOTREPORTED) then begin
		case CodeErr of
			SP_OUTOFDISK		: index := 0;
			SP_OUTOFMEMORY	: index := 1;
			SP_ERROR				: index := 2;
			SP_USERABORT,
			SP_APPABORT			: index := 3;
		else
                        index := 4;
		end;
		MessageBox(GetActiveWindow, licLoadString('STRING', szError[index], gszDicName) , nil, MB_OK OR MB_ICONEXCLAMATION);
	end;
        }
end;


function AbortProc(hImprDC: HDC; Code : integer) : Bool; export;
var
		msg : TMSG;
begin
		while NOT bUserAnnule AND PeekMessage(msg, 0, 0, 0, PM_REMOVE) do begin
			if (hDlgImpr = 0) OR NOT IsDialogMessage(hDlgImpr, msg) then begin
				TranslateMessage(msg);
				DispatchMessage(msg);
			end;
		end;
		AbortProc := NOT bUserAnnule;
end;


function PrintDlgProc(hDlg : HWND; msg, wParam : WORD; lParam : longint) : Bool; export;
var
		rDlg,
		rDsk			: TRECT;

begin
	case msg of
		WM_INITDIALOG:
			begin
				licTranslateCtrl(hDlg, gszDicName);
				GetWindowRect(GetDesktopWindow, rDsk);
				GetWindowRect(hDlg, rDlg);
				SetWindowPos(hDlg, 0, (rDsk.right - rDsk.left) DIV 2 - (rDlg.right - rDlg.left) DIV 2,
															(rDsk.bottom - rDsk.top) DIV 2 - (rDlg.bottom - rDlg.top) DIV 2,
															0,
															0,
															SWP_NOZORDER OR SWP_NOSIZE OR SWP_NOREDRAW);
			end;

		WM_COMMAND:
			begin
				MessageBeep(WORD(-1));
				bUserAnnule := TRUE;
				EnableWindow(GetParent(hDlg), TRUE);
				DestroyWindow(hDlg);
				hDlgImpr := 0;
			end;

		else
			begin
				PrintDlgProc := FALSE;
				Exit;
			end;
	end;
	PrintDlgProc := TRUE;
end;

function licPrint(hWin : HWND; lpszDocName : PChar; var lic : TLicence) : BOOL;
var
	i,
	CodeErr,
	LignesParPage,
	LigneAct,
	yPage,
	xPage,
	yChar,
	xChar							: integer;
	szLine						: array[0..128] of char;
	szStud						: array[0..128] of char;
	dt								: DateTime;

const
	di								: TDOCINFO = ();
	hImprDC						: HDC = 0;
	lpfnPrintDlgProc	: TFARPROC = nil;
	lpfnAbortProc			: TFARPROC = nil;
	tm								: TTEXTMETRIC = ();
	TabPos						: array[0..1] of integer = (0, 0);
	hBmp							: HBITMAP = 0;
	bmp								: TBITMAP = ();
	memdc							: HDC = 0;

const
	bPrinting : BOOL = FALSE;
begin
	if bPrinting then begin
		 licPrint := FALSE;
		 Exit;
	end else begin
			bPrinting := TRUE;

			hImprDC := GetPrinterDC(hWin);
			if hImprDC = 0 then	begin
				MessageBox(hWin, 'Invalid PrinterDC' , 'Error', MB_OK OR MB_ICONSTOP);
				bPrinting := FALSE;
				licPrint := FALSE;
				Exit;
			end;

			bUserAnnule := FALSE;
			EnableWindow(hWin, FALSE);

			lpfnPrintDlgProc := TFARPROC(MakeProcInstance(LongInt(@PrintDlgProc), GetWindowLong(hWin, GWL_HINSTANCE)));
			hDlgImpr := CreateDialog(GetWindowLong(hWin, GWL_HINSTANCE), 'AbortDlg', hWin, DLGPROC(lpfnPrintDlgProc));
			if hDlgImpr = 0 then begin
				MessageBox(hWin, 'Invalid AbortDlg' , 'Error', MB_OK OR MB_ICONSTOP);
				EnableWindow(hWin, TRUE);
				FreeProcInstance(LongInt(lpfnPrintDlgProc));
				DeleteDC(hImprDC);
				bPrinting := FALSE;
				licPrint := FALSE;
				Exit;
			end;

			lpfnAbortProc := TFARPROC(MakeProcInstance(LongInt(@AbortProc), GetWindowLong(hWin, GWL_HINSTANCE)));
			SetAbortProc(hImprDC, TAbortProc(lpfnAbortProc));

			memdc := CreateCompatibleDC(hImprDC);
			hBmp := LoadBitmap(hInstance, 'LAVAC');
			GetObject(hBmp, SizeOf(TBITMAP), @bmp);
			SelectObject(memdc, hBmp);

			di.cbSize := sizeof(TDOCINFO);
			di.lpszDocName := lpszDocName;
			di.lpszOutput := nil;
			CodeErr := StartDoc(hImprDC, di);
			if CodeErr < 0 then	begin
				MessageBox(hWin, 'StartDoc' , 'Error', MB_OK OR MB_ICONSTOP);
				PrintError(CodeErr);
				EnableWindow(hWin, TRUE);
				FreeProcInstance(LongInt(lpfnPrintDlgProc));
				FreeProcInstance(LongInt(lpfnAbortProc));
				DeleteDC(hImprDC);
				bPrinting := FALSE;
				licPrint := FALSE;
				Exit;
			end;

			GetTextMetrics(hImprDC, tm);
			yChar := tm.tmHeight + tm.tmExternalLeading;
			xChar := tm.tmAveCharWidth;
			xPage := GetDeviceCaps(hImprDC, HORZRES);
			yPage := GetDeviceCaps(hImprDC, VERTRES);
			LignesParPage := yPage DIV yChar - 1;

			CodeErr := StartPage(hImprDC);
			if CodeErr < 0 then begin
				MessageBox(hWin, 'StartPage' , 'Error', MB_OK OR MB_ICONSTOP);
				PrintError(CodeErr);
			end;

			Rectangle(hImprDC, 0, 0, xPage, yPage);
			BitBlt(hImprDC, 10, 30,
						 bmp.bmWidth,
						 bmp.bmHeight,
						 memdc, 0, 0,
						 SRCCOPY);

			LigneAct := 10;
			GetDlgItemText(hWin, 201, szLine, SizeOf(szLine));
			StrCat(szLine, '	: ');
			StrCat(szLine, lic.szCode);
			TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			inc(LigneAct, 2);

			GetDlgItemText(hWin, 202, szLine, SizeOf(szLine));
			StrCat(szLine, '	: ');
			wvsprintf(lic.szNewNbPR, '%d', @lic.apInfo[integer(gnType)].nNbPR);
			StrCat(szLine, lic.szNewNbPR);
			TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			inc(LigneAct, 2);

			GetDlgItemText(hWin, 203, szLine, SizeOf(szLine));
			StrCat(szLine, '	: ');
			wvsprintf(lic.szNewNbCR, '%d', @lic.apInfo[integer(gnType)].nNbCR);
			StrCat(szLine, lic.szNewNbCR);
			TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			inc(LigneAct, 2);

			GetDlgItemText(hWin, 204, szLine, SizeOf(szLine));
			StrCat(szLine, '	: ');
			GetDlgItemText(hWin, 109, szStud, SizeOf(szStud));
			StrCat(szLine, szStud);
			TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			inc(LigneAct, 2);

			GetDlgItemText(hWin, 205, szLine, SizeOf(szLine));
			StrCat(szLine, '		: ');
			StrCat(szLine, lic.szName);
			TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			inc(LigneAct, 2);

			GetDlgItemText(hWin, 206, szLine, SizeOf(szLine));
			StrCat(szLine, '	: ');
			StrCat(szLine, lic.szFirm);
			TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			inc(LigneAct, 2);

			GetDlgItemText(hWin, 207, szLine, SizeOf(szLine));
			StrCat(szLine, '	: ');
			StrCat(szLine, lic.szDept);
			TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			inc(LigneAct, 2);

			GetDlgItemText(hWin, 208, szLine, SizeOf(szLine));
			StrCat(szLine, '	: ');
			StrCat(szLine, lic.szAddr);
			TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			inc(LigneAct, 2);

			GetDlgItemText(hWin, 209, szLine, SizeOf(szLine));
			StrCat(szLine, '	: ');
			StrCat(szLine, lic.szCity);
			TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			inc(LigneAct, 2);

			GetDlgItemText(hWin, 210, szLine, SizeOf(szLine));
			StrCat(szLine, '	: ');
			StrCat(szLine, lic.szPhon);
			TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			inc(LigneAct, 2);

			GetDlgItemText(hWin, 211, szLine, SizeOf(szLine));
			StrCat(szLine, '		: ');
			StrCat(szLine, lic.szFax);
			TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			inc(LigneAct, 2);

			GetDlgItemText(hWin, 212, szLine, SizeOf(szLine));
			StrCat(szLine, '		: ');
			StrCat(szLine, lic.szEmail);
			TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			inc(LigneAct, 2);

			if GetParent(hWin) = 0 then begin
				StrCopy(szLine, 'Code Site	: ');
				UnPackTime(lic.apInfo[integer(gnType)].dwCode, dt);
				StrCat(szLine, licGetCode(hWin, lpszDocName, dt.Min));
				TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
			end;

			{####for i := 1 to 48 do begin
				wvsprintf(szLine, '%.2d', i);
				StrCat(szLine, ' : ');
				StrCat(szLine, licGetCode(hWin, lpszDocName, i));
				TabbedTextOut(hImprDC, xChar, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
				inc(i);
				wvsprintf(szLine, '%.2d', i);
				StrCat(szLine, ' : ');
				StrCat(szLine, licGetCode(hWin, lpszDocName, i));
				TabbedTextOut(hImprDC, xChar + 600, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
				inc(i);
				wvsprintf(szLine, '%.2d', i);
				StrCat(szLine, ' : ');
				StrCat(szLine, licGetCode(hWin, lpszDocName, i));
				TabbedTextOut(hImprDC, xChar + 600 * 2, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
				inc(i);
				wvsprintf(szLine, '%.2d', i);
				StrCat(szLine, ' : ');
				StrCat(szLine, licGetCode(hWin, lpszDocName, i));
				TabbedTextOut(hImprDC, xChar + 600 * 3, LigneAct * yChar, szLine, StrLen(szLine), 0, TabPos, 0);
				inc(LigneAct, 2);
			end;####}

			CodeErr := EndPage(hImprDC);
			if CodeErr < 0 then begin
				MessageBox(hWin, 'EndPage' , 'Error', MB_OK OR MB_ICONSTOP);
				PrintError(CodeErr);
			end;

			CodeErr := EndDoc(hImprDC);
			if CodeErr < 0 then begin
				MessageBox(hWin, 'EndDoc' , 'Error', MB_OK OR MB_ICONSTOP);
				PrintError(CodeErr);
			end;

			DeleteDC(memdc);
			DeleteObject(hBmp);

			if NOT bUserAnnule then begin
				EnableWindow(hWin, TRUE);
				DestroyWindow(hDlgImpr);
			end;
			FreeProcInstance(LongInt(lpfnPrintDlgProc));
			FreeProcInstance(LongInt(lpfnAbortProc));
			DeleteDC(hImprDC);

			bPrinting := FALSE;
			licPrint := NOT bUserAnnule OR (CodeErr >= 0);
	end;
end;

function licSaveTxt(pszPath : PChar; var lic : TLicence) : Bool; export;
var
		f			: text;
		i     : integer;
		j     : integer;
		dt : DateTime;
		szCode		: array[0..8]of char;
begin
	FileMode := OF_SHARE_DENY_NONE OR  OF_READWRITE;
	{$I-}
	assign(f, pszPath);
	rewrite(f);
	with lic do begin
		writeLn(f, '');
		writeLn(f, 'Informations :');
		writeLn(f, '--------------');
		writeLn(f, '');

		{wvsprintf(szCode, '%.8lX', dwOldTime);
		writeLn(f, 'dwOldTime : ', szCode);
		wvsprintf(szCode, '%.8lX', dwOldCode);
		writeLn(f, 'dwOldCode : ',szCode);}

		writeLn(f, 'Code	: ', szCode);
		writeLn(f, 'Nom	: ', szName);
		writeLn(f, 'Etab.	: ', szFirm);
		writeLn(f, 'Serv.	: ', szDept);
		writeLn(f, 'Addr.	: ', szAddr);
		writeLn(f, 'Ville	: ', szCity);
		writeLn(f, 'Tel.	: ', szPhon);
		writeLn(f, 'Fax	: ', szFax);
		writeLn(f, 'email	: ', szEmail);
		{writeLn(f, 'Nb PR	: ', szNewNbPR);
		writeLn(f, 'Nb CR	: ', szNewNbCR);}
		writeLn(f, 'Ver	: ', szVersion);
		writeLn(f, '');
		writeLn(f, 'Codes Sites :');
		writeLn(f, '-------------');
		writeLn(f, '');
		for i := 0 to (SizeOf(apInfo) DIV SizeOf(TAPPINFO)) - 1 do begin
			with apInfo[i] do if dwTime <> 0 then begin
				writeLn(f, 'Type	: ', szAPPDESC[TAPPTYPE(i)]);
				writeLn(f, 'Nb PR	: ', nNbPR);
				writeLn(f, 'Nb CR	: ', nNbCR);
				UnPackTime(lic.apInfo[integer(i)].dwCode, dt);
				writeLn(f, 'Nb ET	: ', dt.Min);
				{writeLn(f, 'nNum3	: ', nNum3);
				wvsprintf(szCode, '%.8lX', dwTime);
				writeLn(f, 'dwTime	: ', szCode);}
				wvsprintf(szCode, '%.8lX', @dwCode);
				writeLn(f, 'Code Site	: ', szCode);
				writeLn(f, '');
			end;
		end;
		writeLn(f, '');
		writeLn(f, 'Codes PC :');
		writeLn(f, '----------');
		writeLn(f, '');
		for i := 0 to (SizeOf(stInfo) DIV SizeOf(TSTATIONINFO)) - 1 do begin
			with stInfo[i] do if nType <> ST_EMPTY then begin
				writeLn(f, 'Type	: ', szAPPDESC[nType]);
				writeLn(f, 'Num	: ', nNum);
				{writeLn(f, 'Lock	: ', nLock);
				wvsprintf(szCode, '%.8lX', dwTime);
				writeLn(f, 'dwTime	: ', szCode);}
				wvsprintf(szCode, '%.8lX', @dwCode);
				writeLn(f, 'Code PC	: ', szCode);
				{write(f, 'Bios	: ');
				for j := 0 to SizeOf(BiosInfo) - 1 do begin
					write(f, chr(BiosInfo[j]));
				end;
				writeLn(f, '');}
				writeLn(f, '');
			end;
		end;
	end;
	close(f);
	{$I+}
	FileMode := OF_SHARE_DENY_NONE OR  OF_READ;
	InOutRes := 0;
	ShellExecute(GetActiveWindow, 'Open', pszPath, nil, nil, SW_SHOW);
end;

function licLoad(pszPath : PChar; var lic : TLicence) : Bool; export;
type
		PRun 	= ^TRun;
		TRun 	= array[1..32000] of byte;
var
		f			: file of TLicence;
		fOld  : file of TOldLicence;
		fOlder  : file of TOlderLicence;
		pLic	: PRun;
		i			: integer;

const
		licOld : TOldLicence = ();
		licOlder : TOlderLicence = ();

begin
	FillChar(lic, SizeOf(lic), BYTE(-1));
	FileMode := OF_SHARE_DENY_NONE OR  OF_READ;
	{$I-}
	assign(f, pszPath);
	reset(f);
	read(f, lic);
	close(f);
	{$I+}
	{$I-}
	if IOResult <> 0 then begin
		assign(fOld, pszPath);
		reset(fOld);
		read(fOld, licOld);
		close(fOld);
		{$I+}
		{$I-}
		if IOResult <> 0 then begin
			assign(fOlder, pszPath);
			reset(fOlder);
			read(fOlder, licOlder);
			close(fOlder);
			FillChar(lic, SizeOf(lic), BYTE(-1));
			Move(licOlder, lic, SizeOf(licOlder));
			lic.apInfo[integer(ST_LAVAC)].dwTime := licOlder.dwTime;
			lic.apInfo[integer(ST_LAVAC)].dwCode := licOlder.dwCode;
		end else begin
			FillChar(lic, SizeOf(lic), BYTE(-1));
			Move(licOld, lic, SizeOf(licOld));
			lic.apInfo[integer(ST_LAVAC)].dwTime := licOld.dwTime;
			lic.apInfo[integer(ST_LAVAC)].dwCode := licOld.dwCode;
		end;
	end;
	{$I+}
	if NOT Bool(IOResult) then begin
		pLic := PRun(@lic);
		for i := 1 to SizeOf(TLicence) do begin
			pLic^[i] := NOT pLic^[i];
		end;
		licLoad := TRUE;
	end else begin
		FillChar(lic, SizeOf(lic), BYTE(0));
		licLoad := FALSE;
	end;
end;

function licSave(pszPath : PChar; var lic : TLicence) : Bool; export;
type
		PRun 	= ^TRun;
		TRun 	= array[1..32000] of byte;
var
		f			: file of TLicence;
		pLic	: PRun;
		i			: integer;
begin
	pLic := PRun(@lic);
	for i := 1 to SizeOf(TLicence) do begin
		pLic^[i] := NOT pLic^[i];
	end;
	FileMode := OF_SHARE_DENY_NONE OR  OF_READWRITE;
	{$I-}
	assign(f, pszPath);
	reset(f);
	{$I+}
	if IOResult <> 0 then begin
		{$I-}
		rewrite(f);
		{$I+}
	end;
	{$I-}
	write(f, lic);
	close(f);
	{$I+}
	FileMode := OF_SHARE_DENY_NONE OR  OF_READ;
	for i := 1 to SizeOf(TLicence) do begin
		pLic^[i] := NOT pLic^[i];
	end;
	licSave := NOT Bool(IOResult);
end;

function licEnum(EnumProc : TENUMPROC; pszPath : PChar) : integer; export;
var
	i          : integer;
	j          : integer;
	szPath     : Array[0..255] of char;
begin
	if gszDicName[0] = #0 then licSetLang('FR');
	if NOT licLoad(pszPath, lic) then begin
		MessageBox(GetActiveWindow,
							licLoadString('STRING', '#10', gszDicName),
							licLoadString('STRING', '#11', gszDicName), MB_OK OR MB_ICONSTOP);
		licEnum := -1;
		Exit;
	end;
	for i := 1 to (SizeOf(lic.apInfo) DIV SizeOf(TAPPINFO)) - 1 do begin
		if (lic.apInfo[i].dwTime <> 0) then begin
			EnumProc(TAPPTYPE(i), -1, -1);
		end;
	end;
	for i := 1 to (SizeOf(lic.apInfo) DIV SizeOf(TAPPINFO)) - 1 do begin
		if (lic.apInfo[i].dwTime <> 0) then begin
			for j := 0 to (SizeOf(lic.stInfo) DIV SizeOf(TSTATIONINFO)) - 1 do begin
				if lic.stInfo[j].nType = TAPPTYPE(i) then begin
					EnumProc(lic.stInfo[j].nType, lic.stInfo[j].nNum, j);
				end;
			end;
		end;
	end;
	StrCopy(szPath, pszPath);
	szPath[StrLen(szPath) - 3] := 'T';
	szPath[StrLen(szPath) - 2] := 'X';
	szPath[StrLen(szPath) - 1] := 'T';
	licSaveTxt(szPath, lic);
	licEnum := 0;
end;

{*************************************************************}
{**                Fonction RequestProc                     **}
{*************************************************************}
function licRequestProc(hDlg: HWnd; Message, WParam: Word;
	LParam: Longint): Bool; export;

var	dummy			: Word;
		szTest1,
		szTest2,
		szTest3,
		szTest4,
		szFormat	: array[0..128]of char;
		szTime		: array[0..9]of char;
		rDlg,
		rDsk			: TRECT;
		bTrans		: Bool;
		nTest,
		nRet			: integer;

const
		pszPath		: PChar = nil;
		dt				: DateTime = ();
		bDecode 	: Boolean = FALSE;
		dwVersion	: longint = 0;
		nWinMajVer: integer = 0;
		nWinMinVer: integer = 0;
		nDosMajVer: integer = 0;
		nDosMinVer: integer = 0;

begin
	licRequestProc := TRUE;
	case Message of
		WM_INITDIALOG:
			begin
				licTranslateCtrl(hDlg, gszDicName);
				GetWindowText(hDlg, szFormat, SizeOf(szFormat));
				StrCat(szFormat, ' - ');
				StrCat(szFormat, szAPPDESC[gnType]);
				SetWindowText(hDlg, szFormat);
				GetWindowRect(GetDesktopWindow, rDsk);
				GetWindowRect(hDlg, rDlg);
				SetWindowPos(hDlg, 0, (rDsk.right - rDsk.left) DIV 2 - (rDlg.right - rDlg.left) DIV 2,
															(rDsk.bottom - rDsk.top) DIV 2 - (rDlg.bottom - rDlg.top) DIV 2,
															0,
															0,
															SWP_NOZORDER OR SWP_NOSIZE OR SWP_NOREDRAW);
				pszPath := PChar(lParam);
				FillChar(lic, SizeOf(lic), BYTE(0));
				if NOT licLoad(pszPath, lic) OR (lic.apInfo[integer(gnType)].dwTime = 0) then begin
					wvsprintf(gszType, '%d', @gnType);
					GetPrivateProfileString('LLSYSTEM', gszType, '#', szTime, SizeOf(szTime), 'LLSYSTEM.DLL');
					if szTime[0] = '#' then begin
						GetDate(dt.Year, dt.Month, dt.Day, dummy);
						GetTime(dt.Hour, dt.Min, dt.Sec, dummy);
						FillChar(lic, SizeOf(lic), 0);
						PackTime(dt, lic.apInfo[integer(gnType)].dwTime);
					end else begin
						Val(szTime, lic.apInfo[integer(gnType)].dwTime, nRet);
					end;
					wvsprintf(szTime, '$%lX', @lic.apInfo[integer(gnType)].dwTime);
					WritePrivateProfileString('LLSYSTEM', gszType, szTime, 'LLSYSTEM.DLL');
					GetDlgItemText(hDlg, 108, szFormat, SizeOf(szFormat));
					wvsprintf(lic.szCode, szFormat, @lic.apInfo[integer(gnType)].dwTime);
				end;
				SetDlgItemText(hDlg, 101, lic.szName);
				SetDlgItemText(hDlg, 102, lic.szFirm);
				SetDlgItemText(hDlg, 103, lic.szDept);
				SetDlgItemText(hDlg, 104, lic.szAddr);
				SetDlgItemText(hDlg, 105, lic.szCity);
				SetDlgItemText(hDlg, 106, lic.szPhon);
				SetDlgItemText(hDlg, 107, lic.szFax);
				wvsprintf(lic.szCode, 'L0430-1D84-7B67-%lX', @lic.apInfo[integer(gnType)].dwTime);
				SetDlgItemText(hDlg, 108, lic.szCode);
				UnPackTime(lic.apInfo[integer(gnType)].dwCode, dt);
				if dt.Min > 0 then SetDlgItemInt(hDlg, 109, dt.Min, TRUE);
				wvsprintf(lic.szNewNbPR, '%d', @lic.apInfo[integer(gnType)].nNbPR);
				SetDlgItemText(hDlg, 110, lic.szNewNbPR);
				wvsprintf(lic.szNewNbCR, '%d', @lic.apInfo[integer(gnType)].nNbCR);
				SetDlgItemText(hDlg, 111, lic.szNewNbCR);
				SetDlgItemText(hDlg, 112, lic.szEmail);
				SetFocus(GetDlgItem(hDlg, 110));
				{ si client DLL = codesite.exe, on peut modifier le code LAVAC }
				if GetParent(hDlg) = 0 then begin
					SendDlgItemMessage(hDlg, 108, EM_SETREADONLY, WORD(FALSE), 0);
					bDecode := TRUE;
				end;
				if NOT bDecode then begin
					GetDlgItemText(hDlg, 102, szTest1, SizeOf(szTest1));
					GetDlgItemText(hDlg, 103, szTest2, SizeOf(szTest2));
					nTest := GetDlgItemInt(hDlg, 109, bTrans, TRUE);
					GetDlgItemText(hDlg, 110, szTest3, SizeOf(szTest3));
					GetDlgItemText(hDlg, 111, szTest4, SizeOf(szTest4));
					if (szTest1[0] = #0) OR
						 (szTest2[0] = #0) OR
						 (nTest = 0) OR
						 (szTest3[0] = #0) OR
						 (szTest4[0] = #0) then begin
						EnableWindow(GetDlgItem(hDlg, 301), FALSE);
						EnableWindow(GetDlgItem(hDlg, 302), FALSE);
					end else begin
						EnableWindow(GetDlgItem(hDlg, 301), TRUE);
						EnableWindow(GetDlgItem(hDlg, 302), TRUE);
					end;
				end;
			end;

		WM_COMMAND:
			case LoWord(wParam) of
				101..112 :
					case HIWORD(wParam) of
						EN_CHANGE :
							if GetParent(hDlg) <> 0 then begin
								GetDlgItemText(hDlg, 102, szTest1, SizeOf(szTest1));
								GetDlgItemText(hDlg, 103, szTest2, SizeOf(szTest2));
								nTest := GetDlgItemInt(hDlg, 109, bTrans, TRUE);
								GetDlgItemText(hDlg, 110, szTest3, SizeOf(szTest3));
								GetDlgItemText(hDlg, 111, szTest4, SizeOf(szTest4));
								if (szTest1[0] = #0) OR
									 (szTest2[0] = #0) OR
									 (nTest = 0) OR
									 (szTest3[0] = #0) OR
									 (szTest4[0] = #0) then begin
									EnableWindow(GetDlgItem(hDlg, 301), FALSE);
									EnableWindow(GetDlgItem(hDlg, 302), FALSE);
								end else begin
									EnableWindow(GetDlgItem(hDlg, 301), TRUE);
									EnableWindow(GetDlgItem(hDlg, 302), TRUE);
								end;
							end;
					end;

				301 :
					begin
						GetDlgItemText(hDlg, 101, lic.szName, SizeOf(lic.szName));
						GetDlgItemText(hDlg, 102, lic.szFirm, SizeOf(lic.szFirm));
						GetDlgItemText(hDlg, 103, lic.szDept, SizeOf(lic.szDept));
						GetDlgItemText(hDlg, 104, lic.szAddr, SizeOf(lic.szAddr));
						GetDlgItemText(hDlg, 105, lic.szCity, SizeOf(lic.szCity));
						GetDlgItemText(hDlg, 106, lic.szPhon, SizeOf(lic.szPhon));
						GetDlgItemText(hDlg, 107, lic.szFax,  SizeOf(lic.szFax));
						GetDlgItemText(hDlg, 108, lic.szCode,  SizeOf(lic.szCode));
						dt.Min := GetDlgItemInt(hDlg, 109, bTrans, TRUE);
						PackTime(dt, lic.apInfo[integer(gnType)].dwCode);
						GetDlgItemText(hDlg, 110, lic.szNewNbPR, SizeOf(lic.szNewNbPR));
						Val(lic.szNewNbPR, lic.apInfo[integer(gnType)].nNbPR, nRet);
						GetDlgItemText(hDlg, 111, lic.szNewNbCR, SizeOf(lic.szNewNbCR));
						Val(lic.szNewNbCR, lic.apInfo[integer(gnType)].nNbCR, nRet);
						GetDlgItemText(hDlg, 112, lic.szEmail, SizeOf(lic.szEmail));
						if NOT bDecode then begin
							dwVersion := GetVersion;
							nWinMajVer := LOBYTE(LOWORD(dwVersion));
							nWinMinVer := HIBYTE(LOWORD(dwVersion));
							nDosMajVer := HIBYTE(HIWORD(dwVersion));
							nDosMinVer := LOBYTE(HIWORD(dwVersion));
							wvsprintf(lic.szVersion, 'Win %d.%.2d - Dos %d.%.2d', @nWinMajVer);
						end;
						{ si client DLL = codesite.exe, on peut modifier le code LAVAC }
						if bDecode then begin
							StrCopy(szTime, StrRScan(lic.szCode, '-'));
							szTime[0] := '$';
							Val(szTime, lic.apInfo[integer(gnType)].dwTime, nRet);
						end;
						licAddStation(lic, gnType, gnNum);
						licSave(pszPath, lic);
						if licPrint(hDlg, pszPath, lic) then begin
							if NOT bDecode then begin
								EndDialog(hDlg, -1);
							end;
						end else begin
							MessageBox(hDlg, licLoadString('STRING', '#6', gszDicName),
															 licLoadString('CONTROL', '#1', gszDicName), MB_OK OR MB_ICONSTOP);
						end;
					end;

				302 :
					begin
						GetDlgItemText(hDlg, 101, lic.szName, SizeOf(lic.szName));
						GetDlgItemText(hDlg, 102, lic.szFirm, SizeOf(lic.szFirm));
						GetDlgItemText(hDlg, 103, lic.szDept, SizeOf(lic.szDept));
						GetDlgItemText(hDlg, 104, lic.szAddr, SizeOf(lic.szAddr));
						GetDlgItemText(hDlg, 105, lic.szCity, SizeOf(lic.szCity));
						GetDlgItemText(hDlg, 106, lic.szPhon, SizeOf(lic.szPhon));
						GetDlgItemText(hDlg, 107, lic.szFax,  SizeOf(lic.szFax));
						GetDlgItemText(hDlg, 108, lic.szCode,  SizeOf(lic.szCode));
						dt.Min := GetDlgItemInt(hDlg, 109, bTrans, TRUE);
						PackTime(dt, lic.apInfo[integer(gnType)].dwCode);

						GetDlgItemText(hDlg, 110, lic.szNewNbPR, SizeOf(lic.szNewNbPR));
						Val(lic.szNewNbPR, lic.apInfo[integer(gnType)].nNbPR, nRet);
						GetDlgItemText(hDlg, 111, lic.szNewNbCR, SizeOf(lic.szNewNbCR));
						Val(lic.szNewNbCR, lic.apInfo[integer(gnType)].nNbCR, nRet);

						GetDlgItemText(hDlg, 112, lic.szEmail, SizeOf(lic.szEmail));
						if NOT bDecode then begin
							dwVersion := GetVersion;
							nWinMajVer := LOBYTE(LOWORD(dwVersion));
							nWinMinVer := HIBYTE(LOWORD(dwVersion));
							nDosMajVer := HIBYTE(HIWORD(dwVersion));
							nDosMinVer := LOBYTE(HIWORD(dwVersion));
							wvsprintf(lic.szVersion, 'Win %d.%.2d - Dos %d.%.2d', @nWinMajVer);
						end;
						{ si client DLL = codesite.exe, on peut modifier le code LAVAC }
						if bDecode then begin
							StrCopy(szTime, StrRScan(lic.szCode, '-'));
							szTime[0] := '$';
							Val(szTime, lic.apInfo[integer(gnType)].dwTime, nRet);
						end;
						licAddStation(lic, gnType, gnNum);
						licSave(pszPath, lic);
						if NOT bDecode then begin
							MessageBox(hDlg, licLoadString('STRING', '#7', gszDicName),
															 licLoadString('CONTROL', '#29', gszDicName), MB_OK OR MB_ICONINFORMATION);
							if licSave('A:\LAVAC.LIC', lic) then begin
								if NOT bDecode then begin
									MessageBox(hDlg, licLoadString('STRING', '#8', gszDicName),
																	 licLoadString('CONTROL', '#29', gszDicName), MB_OK OR MB_ICONINFORMATION);
								end;
								EndDialog(hDlg, -1);
							end else begin
								if NOT bDecode then begin
									MessageBox(hDlg, licLoadString('STRING', '#9', gszDicName),
																	 licLoadString('CONTROL', '#29', gszDicName), MB_OK OR MB_ICONSTOP);
								end;
							end;
						end else begin
								EndDialog(hDlg, -1);
						end;
					end;
			end;
	end;
	licRequestProc := FALSE;
end;

function licRequest(hWin : HWND; pszPath : PChar) : Bool; export;
var	lpRequestProc : TFarProc;
begin
	if gszDicName[0] = #0 then licSetLang('FR');
	lpRequestProc := TFARPROC(MakeProcInstance(LongInt(@licRequestProc), hInstance));
	DialogBoxParam(hInstance, 'LICENCE', hWin, DLGPROC(lpRequestProc), longint(pszPath));
	FreeProcInstance(LongInt(lpRequestProc));
end;

{*************************************************************}
{**                Fonction licInputProc                    **}
{*************************************************************}
function licInputProc(hDlg: HWnd; Message, WParam: Word;
	LParam: Longint): Bool; export;

var	dummy			: Word;
		dt,
		dt2				: DateTime;
		szInfo,
		szFormat	: array[0..255]of char;
		szCode		: array[0..8]of char;
		nRet			: integer;
		rDlg,
		rDsk			: TRECT;

const
		plic			: PLicence = nil;
		nDay			: integer = 0;

begin
	licInputProc := TRUE;
	case Message of
		WM_INITDIALOG:
			begin
				licTranslateCtrl(hDlg, gszDicName);
				GetWindowRect(GetDesktopWindow, rDsk);
				GetWindowRect(hDlg, rDlg);
				SetWindowPos(hDlg, 0, (rDsk.right - rDsk.left) DIV 2 - (rDlg.right - rDlg.left) DIV 2,
															(rDsk.bottom - rDsk.top) DIV 2 - (rDlg.bottom - rDlg.top) DIV 2,
															0,
															0,
															SWP_NOZORDER OR SWP_NOSIZE OR SWP_NOREDRAW);
				plic := PLicence(lParam);
				GetDate(dt2.Year, dt2.Month, dt2.Day, dummy);
				UnPackTime(plic^.apInfo[integer(gnType)].dwTime, dt);
				nDay	:= 30 - ((dt2.Year - dt.Year) * 365 +
											(dt2.Month - dt.Month) * 30 +
											(dt2.Day - dt.Day));
				GetDlgItemText(hDlg, 102, szFormat, SizeOf(szFormat));
				wvsprintf(szInfo, szFormat, @nDay);
				SetDlgItemText(hDlg, 102, szInfo);
				SetFocus(GetDlgItem(hDlg, 101));
			end;

		WM_COMMAND:
			case LoWord(wParam) of
				IDOK :
					begin
						GetDlgItemText(hDlg, 101, szCode, SizeOf(szCode));
						StrCopy(szFormat, '$');
						StrCat(szFormat, szCode);
						Val(szFormat, plic^.apInfo[integer(gnType)].dwCode, nRet);
						if nRet = 0 then begin
							EndDialog(hDlg, -1);
						end else begin
							MessageBeep(MB_ICONEXCLAMATION);
						end;
					end;

				IDCANCEL :
					begin
						EndDialog(hDlg, nDay);
					end;
			end;
	end;
	licInputProc := FALSE;
end;

{*************************************************************}
{**                Fonction licUnlockProc                    **}
{*************************************************************}
function licUnlockProc(hDlg: HWnd; Message, WParam: Word;
	LParam: Longint): Bool; export;

var	dummy			: Word;
		dt,
		dt2				: DateTime;
		szInfo,
		szFormat	: array[0..255]of char;
		szCode		: array[0..8]of char;
		nRet			: integer;
		rDlg,
		rDsk			: TRECT;

const
		plic			: PLicence = nil;
		nDay			: integer = 0;

begin
	licUnlockProc := TRUE;
	case Message of
		WM_INITDIALOG:
			begin
				licTranslateCtrl(hDlg, gszDicName);
				GetDlgItemText(hDlg, 103, szFormat, SizeOf(szFormat));
				wvsprintf(szInfo, szFormat, @gnNum);
				SetDlgItemText(hDlg, 103, szInfo);
				GetWindowRect(GetDesktopWindow, rDsk);
				GetWindowRect(hDlg, rDlg);
				SetWindowPos(hDlg, 0, (rDsk.right - rDsk.left) DIV 2 - (rDlg.right - rDlg.left) DIV 2,
															(rDsk.bottom - rDsk.top) DIV 2 - (rDlg.bottom - rDlg.top) DIV 2,
															0,
															0,
															SWP_NOZORDER OR SWP_NOSIZE OR SWP_NOREDRAW);
				plic := PLicence(lParam);
				GetDate(dt2.Year, dt2.Month, dt2.Day, dummy);
				UnPackTime(plic^.stInfo[gnStation].dwTime, dt);
				nDay	:= 30 - ((dt2.Year - dt.Year) * 365 +
											(dt2.Month - dt.Month) * 30 +
											(dt2.Day - dt.Day));
				GetDlgItemText(hDlg, 102, szFormat, SizeOf(szFormat));
				wvsprintf(szInfo, szFormat, @nDay);
				SetDlgItemText(hDlg, 102, szInfo);
				SetFocus(GetDlgItem(hDlg, 101));
			end;

		WM_COMMAND:
			case LoWord(wParam) of
				IDOK :
					begin
						GetDlgItemText(hDlg, 101, szCode, SizeOf(szCode));
						StrCopy(szFormat, '$');
						StrCat(szFormat, szCode);
						Val(szFormat, plic^.stInfo[gnStation].dwCode, nRet);
						if nRet = 0 then begin
							EndDialog(hDlg, -1);
						end else begin
							MessageBeep(MB_ICONEXCLAMATION);
						end;
					end;

				IDCANCEL :
					begin
						EndDialog(hDlg, nDay);
					end;
			end;
	end;
	licUnlockProc := FALSE;
end;

function licGetNumStud(hWin : HWND; pszPath : PChar) : integer; export;
var	dwCode	: longint;
		dt			: DateTime;
begin

	licGetNumStud := 255;
	exit;

	if gszDicName[0] = #0 then licSetLang('FR');
	if NOT licLoad(pszPath, lic) then begin
		MessageBox(hWin,
							licLoadString('STRING', '#10', gszDicName),
							licLoadString('STRING', '#11', gszDicName), MB_OK OR MB_ICONSTOP);
		licGetNumStud := -1;
		Exit;
	end;
	UnPackTime(lic.apInfo[integer(gnType)].dwCode, dt);
	licGetNumStud := dt.Min;
end;

function licGetText(hWin : HWND; pszPath : PChar) : PChar; export;
var	dt			: DateTime;
const
		szFmt : array[0..255] of char = '';
		szLicence : array[0..255] of char = '';
		aList : record
							pF	: PChar;
							cr1 : integer;
							lf1 : integer;
							pD	: PChar;
							cr2 : integer;
							lf2 : integer;
							n		: integer;
						end = (pF : nil; cr1 : 13; lf1 : 10;
									 pD : nil; cr2 : 13; lf2 : 10;
									 n : 0);
begin
	if gszDicName[0] = #0 then licSetLang('FR');
	licGetText := @szLicence;
	if NOT licLoad(pszPath, lic) then begin
		MessageBox(hWin,
							licLoadString('STRING', '#10', gszDicName),
							licLoadString('STRING', '#11', gszDicName), MB_OK OR MB_ICONSTOP);
		Exit;
	end;
	aList.pF := @lic.szFirm;
	aList.pD := @lic.szDept;
	UnPackTime(lic.apInfo[integer(gnType)].dwCode, dt);
	aList.n := dt.Min;
	StrCopy(szFmt, '%s%c%c%s%c%c');
	StrCat(szFmt, licLoadString('STRING', '#14', gszDicName));
	wvsprintf(szLicence, szFmt, @aList);
end;

function licFormatText(hWin : HWND; pszPath, pszCot, pszSep : PChar) : PChar; export;
var	dt			: DateTime;
		nNbET		: integer;
		szNbET	: array[0..9] of char;

const
		szLicence : array[0..2048] of char = '';
begin
	if gszDicName[0] = #0 then licSetLang('FR');
	licFormatText := @szLicence;
	if NOT licLoad(pszPath, lic) then begin
		MessageBox(hWin,
							licLoadString('STRING', '#10', gszDicName),
							licLoadString('STRING', '#11', gszDicName), MB_OK OR MB_ICONSTOP);
		Exit;
	end;
	StrCopy(szLicence, pszCot);
	StrCat(szLicence, lic.szCode);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, pszSep);
	StrCat(szLicence, pszCot);
	wvsprintf(lic.szNewNbPR, '%d', @lic.apInfo[integer(gnType)].nNbPR);
	StrCat(szLicence, lic.szNewNbPR);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, pszSep);
	StrCat(szLicence, pszCot);
	wvsprintf(lic.szNewNbCR, '%d', @lic.apInfo[integer(gnType)].nNbCR);
	StrCat(szLicence, lic.szNewNbCR);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, pszSep);
	StrCat(szLicence, pszCot);
	UnPackTime(lic.apInfo[integer(gnType)].dwCode, dt);
	nNbET := dt.Min;
	wvsprintf(szNbET, '%d', @nNBET);
	StrCat(szLicence, szNbET);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, pszSep);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, lic.szName);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, pszSep);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, lic.szFirm);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, pszSep);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, lic.szDept);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, pszSep);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, lic.szAddr);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, pszSep);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, lic.szCity);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, pszSep);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, lic.szPhon);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, pszSep);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, lic.szFax);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, pszSep);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, lic.szEmail);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, pszSep);
	StrCat(szLicence, pszCot);
	StrCat(szLicence, lic.szVersion);
	StrCat(szLicence, pszCot);
end;

function licVerify(hWin : HWND; pszPath :PChar) : Bool; export;
var	dwCode			: longint;
		dt					: DateTime;
		lpInputProc : TFarProc;
		nRet 				: integer;
		bLicOK			: BOOL;

begin
	licVerify := true;
	exit;

	hWin := 0;
	if gszDicName[0] = #0 then licSetLang('FR');
	if NOT licLoad(pszPath, lic) then begin
		MessageBox(hWin,
							licLoadString('STRING', '#10', gszDicName),
							licLoadString('STRING', '#11', gszDicName), MB_OK OR MB_ICONSTOP);
		licVerify := FALSE;
		Exit;
	end;
	UnPackTime(lic.apInfo[integer(gnType)].dwCode, dt);
	dt.Year := 1980 + WORD(LoByte(HiWord(lic.apInfo[integer(gnType)].dwTime)) -
												 HiByte(HiWord(lic.apInfo[integer(gnType)].dwTime))) AND $007F;
	dt.Month := WORD(LoByte(LoWord(lic.apInfo[integer(gnType)].dwTime)) -
													HiByte(LoWord(lic.apInfo[integer(gnType)].dwTime))) AND $000F;
	dt.Day := WORD(Ord(lic.szName[0]) - Ord(lic.szFirm[0])) AND $001F;
	dt.Hour := WORD(Ord(lic.szDept[0]) - Ord(lic.szAddr[0])) AND $001F;
	dt.Sec := WORD(Ord(lic.szCity[0]) - Ord(lic.szPhon[0])) AND $003E;
	PackTime(dt, dwCode);

	{wvsprintf(szBuff, '%.8lX', dwCode);
	MessageBox(0, szBuff, '', 0);}

	bLicOK := FALSE;
	if lic.apInfo[integer(gnType)].dwCode <> dwCode then begin
		lpInputProc := TFARPROC(MakeProcInstance(LongInt(@licInputProc), hInstance));
		nRet := DialogBoxParam(hInstance, 'CODE', hWin, DLGPROC(lpInputProc), longint(@lic));
		FreeProcInstance(LongInt(lpInputProc));
		if lic.apInfo[integer(gnType)].dwCode = dwCode then begin
			if NOT licSave(pszPath, lic) then begin
				MessageBox(hWin,
												licLoadString('STRING', '#12', gszDicName),
												licLoadString('STRING', '#13', gszDicName),
												 MB_OK OR MB_ICONEXCLAMATION);
			end;
		end;
		if nRet = -1 then begin
			bLicOK := lic.apInfo[integer(gnType)].dwCode = dwCode;
		end else begin
			bLicOK := nRet > 0;
		end;
	end else begin
		bLicOK := TRUE;
	end;

	if bLicOK then begin
		nRet := licCheckBIOS(lic, gnType, gnNum);
		bLicOK := nRet >= CBI_OK;
		case nRet of
			CBI_NOTFOUND :
				begin
					gnStation := licAddStation(lic, gnType, gnNum);
					lic.stInfo[gnStation].nLock := 0;
					if NOT licSave(pszPath, lic) then begin
						MessageBox(hWin,
											licLoadString('STRING', '#12', gszDicName),
											licLoadString('STRING', '#13', gszDicName),
											MB_OK OR MB_ICONEXCLAMATION);
					end;
				end;

			CBI_BADBIOS,
			CBI_LOCKED :
					if NOT licSave(pszPath, lic) then begin
						MessageBox(hWin,
											licLoadString('STRING', '#12', gszDicName),
											licLoadString('STRING', '#13', gszDicName),
											MB_OK OR MB_ICONEXCLAMATION);
					end;
		end;
		case nRet of
			CBI_NOTFOUND,
			CBI_BADBIOS,
			CBI_LOCKED :
				begin
					lpInputProc := TFARPROC(MakeProcInstance(LongInt(@licUnlockProc), hInstance));
					nRet := DialogBoxParam(hInstance, 'UNLOCK', hWin, DLGPROC(lpInputProc), longint(@lic));
					FreeProcInstance(LongInt(lpInputProc));
					dt.Year := 1980 + WORD(LoByte(HiWord(lic.stInfo[gnStation].dwTime)) -
																 HiByte(HiWord(lic.stInfo[gnStation].dwTime))) AND $007F;
					dt.Month := WORD(LoByte(LoWord(lic.stInfo[gnStation].dwTime)) -
																	HiByte(LoWord(lic.stInfo[gnStation].dwTime))) AND $000F;
					dt.Day := WORD(Ord(lic.szName[0]) - Ord(lic.szFirm[0])) AND $001F;
					dt.Hour := WORD(Ord(lic.szDept[0]) - Ord(lic.szAddr[0])) AND $001F;
					dt.min := gnStation;
					dt.Sec := WORD(Ord(lic.szCity[0]) - Ord(lic.szPhon[0])) AND $003E;
					PackTime(dt, dwCode);
					if nRet = -1 then begin
						bLicOK := lic.stInfo[gnStation].dwCode = dwCode;
						if bLicOK then begin
							lic.stInfo[gnStation].nLock := lic.stInfo[gnStation].nNum;
						end;
					end else begin
						bLicOK := nRet > 0;
					end;
					if lic.stInfo[gnStation].dwCode = dwCode then begin
						if NOT licSave(pszPath, lic) then begin
							MessageBox(hWin,
												licLoadString('STRING', '#12', gszDicName),
												licLoadString('STRING', '#13', gszDicName),
												MB_OK OR MB_ICONEXCLAMATION);
						end;
					end;
				end;
		end;
	end;

	licVerify := bLicOK;
end;

function licGetCode(hWin : HWND; pszPath : PChar; n : integer) : PChar;
var	dwCode			: longint;
		dt					: DateTime;
		nRet 				: integer;
const
		szCode			: array[0..8]of char = '';
begin
	if gszDicName[0] = #0 then licSetLang('FR');
	licGetCode := @szCode;
	if NOT licLoad(pszPath, lic) then begin
		MessageBox(hWin,
							licLoadString('STRING', '#10', gszDicName),
							licLoadString('STRING', '#11', gszDicName), MB_OK OR MB_ICONSTOP);
		Exit;
	end;
	dt.Year := 1980 + WORD(LoByte(HiWord(lic.apInfo[integer(gnType)].dwTime)) -
												 HiByte(HiWord(lic.apInfo[integer(gnType)].dwTime))) AND $007F;
	dt.Month := WORD(LoByte(LoWord(lic.apInfo[integer(gnType)].dwTime)) -
									 HiByte(LoWord(lic.apInfo[integer(gnType)].dwTime))) AND $000F;
	dt.Day := WORD(Ord(lic.szName[0]) - Ord(lic.szFirm[0])) AND $001F;
	dt.Hour := WORD(Ord(lic.szDept[0]) - Ord(lic.szAddr[0])) AND $001F;
	dt.Min	:= n;
	dt.Sec := WORD(Ord(lic.szCity[0]) - Ord(lic.szPhon[0])) AND $003E;
	PackTime(dt, dwCode);

	lic.apInfo[integer(gnType)].dwCode := dwCode;
	licSave(pszPath, lic);

	wvsprintf(szCode, '%.8lX', @dwCode);
end;

function licGetPCCode(hWin : HWND; pszPath : PChar; n : integer) : PChar; export;
var	dwCode			: longint;
		dt					: DateTime;
		nRet 				: integer;
const
		szCode			: array[0..8]of char = '';
begin
	if gszDicName[0] = #0 then licSetLang('FR');
	licGetPCCode := @szCode;
	if NOT licLoad(pszPath, lic) then begin
		MessageBox(hWin,
							licLoadString('STRING', '#10', gszDicName),
							licLoadString('STRING', '#11', gszDicName), MB_OK OR MB_ICONSTOP);
		Exit;
	end;
	dt.Year := 1980 + WORD(LoByte(HiWord(lic.stInfo[n].dwTime)) -
												 HiByte(HiWord(lic.stInfo[n].dwTime))) AND $007F;
	dt.Month := WORD(LoByte(LoWord(lic.stInfo[n].dwTime)) -
													HiByte(LoWord(lic.stInfo[n].dwTime))) AND $000F;
	dt.Day := WORD(Ord(lic.szName[0]) - Ord(lic.szFirm[0])) AND $001F;
	dt.Hour := WORD(Ord(lic.szDept[0]) - Ord(lic.szAddr[0])) AND $001F;
	dt.min := n;
	dt.Sec := WORD(Ord(lic.szCity[0]) - Ord(lic.szPhon[0])) AND $003E;
	PackTime(dt, dwCode);

	lic.stInfo[n].nLock := lic.stInfo[n].nNum;
	lic.stInfo[n].dwCode := dwCode;
	licSave(pszPath, lic);
	wvsprintf(szCode, '%.8lX', @dwCode);
end;

exports
	licRequest		index 1,
	licGetNumStud	index 2,
	licVerify 		index 3,
	licGetCode		index 4,
	licGetText		index 5,
	licFormatText	index 6,
	licSetLang    index 7,
	licLoadString index 8,
	licTranslateCtrl index 9,
	licSetType    index 10,
	licSetNum	    index 11,
	licGetIni			index 12,
	licEnum				index 13,
	licGetPCCode	index 14;

begin
	{with hLogFnt do begin
	 lfHeight:= -11;
	 lfWidth:= 0;
	 lfEscapement:= 0;
	 lfOrientation:= 0;
	 lfWeight:= FW_NORMAL;
	 lfItalic:= 0;
	 lfUnderline:= 0;
	 lfStrikeOut:= 0;
	 lfCharSet:= 0;
	 lfOutPrecision:= 3;
	 lfClipPrecision:= 2;
	 lfQuality:= 1;
	 lfPitchAndFamily:= 34;
	 StrCopy(lfFaceName, 'Arial');
	end;
	hfnt := CreateFontIndirect(hLogFnt);}
	for i := 0 to SizeOf(TBIOSINFO) - 1 do begin
		{acBiosInfo[i] := vbPeek($F000, $FFF0 + i);}
		acBiosInfo[i] := 0;
	end;
end.
