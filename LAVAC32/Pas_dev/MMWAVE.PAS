{************************************************}
{                                                }
{   Unité MMWAVE                                 }
{                                                }
{   Projet LAVAC                                 }
{                                                }
{  (c) 1992-95 C Puissance 3 Informatique        }
{              MORGAN MULTIMEDIA                 }
{                                                }
{  par Guillaume de Bailliencourt                }
{                                                }
{  27/12/1995                                    }
{                                                }
{************************************************}

UNIT MMWAVE;

interface

uses Windows, Dos, SysUtils, VFW, MMSystem, MMLavac, MMDrwDib, MCIWnd, Strings;

const
		MAXPOINTS					= 16382;

const
	 szNOWAVE = 'nowave.wav';
	 szNOWAVEPATH : ARRAY[0..255] of char = '';

type
		DWORD							= longint;

		PtrRec 						= record
													Lo,
													Hi: Word
												end;

		PAPOINT           = ^TAPOINT;
		TAPOINT						= array[0..MAXPOINTS] of TPOINT;

		PPOINTS						= ^TPOINTS;
		TPOINTS						= record
													hap				 : THANDLE;
													pap 			 : PAPOINT;
													lPoints		 : longint;
													pNext			 : PPOINTS;
												end;

		PWAVEINFO					= ^TWAVEINFO;
		TWAVEINFO					= record
													pszFile    : PCHAR;
													hFormat		 : THANDLE;
													pFormat		 : PPCMWAVEFORMAT;
													dwDataSize : DWORD;
												end;

		PWAVEDATA					= ^TWAVEDATA;
		TWAVEDATA					= record
													pszFile    : PCHAR;
													hData			 : THANDLE;
													pData			 : POINTER;
													dwDataSize : DWORD;
												end;

		PWAVE            = ^TWAVE;
		TWAVE						 = record
													pszFile    : PCHAR;
													pszName    : PCHAR;
													nNum		   : integer;
													bDummy		 : BOOL;
													bModify		 : BOOL;
													pInfo			 : PWAVEINFO;
													pData			 : PWAVEDATA;
													pLstPoints : PPOINTS;
													pNext			 : PWAVE;
											 end;

function LoadWaveInfo(pszFileName : PCHAR) : PWAVEINFO;
function LoadWaveData(pszFileName : PCHAR) : PWAVEDATA;
function MakePoints(pWInfo : PWAVEINFO; pWData : PWAVEDATA; nHeight : integer; dwHeight, dwSamplePerPixel : DWORD;
										lOfs : longint) : PPOINTS;
function PlayWave(hWin : HWND; pWaves, pWavFrom, pWavTo : PWAVE; dwFrom, dwTo, dwHeight, dwSamplePerPixel : DWORD;
									nRate : integer) : BOOL;
function DrawPoints(dc : HDC; pCurWave : PWAVE; dwRGB : TCOLORREF) : integer;
function WavEditProc(Dialog: HWnd; Message, WParam: Word;
	LParam: Longint): Bool; stdcall;

implementation

procedure AHIncr; external 'KERNEL' index 114;


const

	UM_LBUTTONDOWN   = WM_USER + 101;
	UM_MOUSEMOVE	 	 = WM_USER + 102;
	UM_LBUTTONUP		 = WM_USER + 103;
	UM_LBUTTONDBLCLK = WM_USER + 104;

	MOUSE_NONE = 0;
	MOUSE_ONFROM = 1;
	MOUSE_ONTO = 2;
	MOUSE_ONEDGE = 3;
	MOUSE_MOVEFROM = 4;
	MOUSE_MOVETO = 5;
	MOUSE_MOVEEDGE = 6;

	nMouseMode : integer = MOUSE_NONE;
	bPlaying : BOOL = FALSE;
	lpSubClsProc : WNDPROC = nil;
	lpOldSubClsProc : WNDPROC = nil;

	hWavOut		:	HWAVEOUT = 0;

function LoadWaveInfo(pszFileName : PCHAR) : PWAVEINFO;
var
		hMyMmio							: HMMIO;
		mmckinfoParent,
		mmckinfoSubchunk	: TMMCKINFO;
		wi								: TWAVEINFO;
		pwi								: PWAVEINFO;
		dwFmtSize					: DWORD;

begin
			LoadWaveInfo := nil;

			{ Open the given file for reading using buffered I/O. }
			hMyMmio := mmioOpen(pszFileName, nil, MMIO_READ OR MMIO_ALLOCBUF);
			if hMyMmio = 0 then	begin
					MessageBox(GetActiveWindow, 'Failed to open file.',
										 'LoadWaveInfo', MB_OK OR MB_ICONEXCLAMATION);
					exit;
			end;

			{ Locate a 'RIFF' chunk with a 'WAVE' form type
			 * to make sure it's a WAVE file.	 }
			mmckinfoParent.fccType := mmioStringToFOURCC('WAVE', 0);
			if mmioDescend(hMyMmio, @mmckinfoParent, nil, MMIO_FINDRIFF) <> 0 then begin
					MessageBox(GetActiveWindow, 'This is not a WAVE file.',
										 'LoadWaveInfo', MB_OK OR MB_ICONEXCLAMATION);
					mmioClose(hMyMmio, 0);
					exit;
			end;

			{ Now, find the format chunk (form type 'fmt '). It should be
			 * a subchunk of the 'RIFF' parent chunk.	 }
			mmckinfoSubchunk.ckid := mmioStringToFOURCC('fmt ', 0);
			if mmioDescend(hMyMmio, @mmckinfoSubchunk, @mmckinfoParent, MMIO_FINDCHUNK) <> 0 then begin
					MessageBox(GetActiveWindow, 'WAVE file is corrupted.',
										 'LoadWaveInfo', MB_OK OR MB_ICONEXCLAMATION);
					mmioClose(hMyMmio, 0);
					exit;
			end;

			{ Get the size of the format chunk, allocate and lock memory for it.	 }
			dwFmtSize := mmckinfoSubchunk.cksize;
			wi.hFormat := GlobalAlloc(GMEM_MOVEABLE , dwFmtSize);
			if wi.hFormat = 0 then	begin
					MessageBox(GetActiveWindow, 'Out of memory.',
										 'LoadWaveInfo', MB_OK OR MB_ICONEXCLAMATION);
					mmioClose(hMyMmio, 0);
					exit;
			end;

			wi.pFormat := PPCMWAVEFORMAT(GlobalLock(wi.hFormat));
			if wi.pFormat = nil then	begin
					MessageBox(GetActiveWindow, 'Failed to lock memory for format chunk.',
										 'LoadWaveInfo', MB_OK OR MB_ICONEXCLAMATION);
					GlobalFree(wi.hFormat);
					mmioClose(hMyMmio, 0);
					exit;
			end;

			{ Read the format chunk. }
			if mmioRead(hMyMmio, PChar(wi.pFormat), dwFmtSize) <> dwFmtSize then begin
					MessageBox(GetActiveWindow, 'Failed to read format chunk.',
										 'LoadWaveInfo', MB_OK OR MB_ICONEXCLAMATION);
					GlobalUnlock( wi.hFormat );
					GlobalFree( wi.hFormat );
					mmioClose(hMyMmio, 0);
					exit;
			end;

			{ Ascend out of the format subchunk. }
			mmioAscend(hMyMmio, @mmckinfoSubchunk, 0);

			{ Find the data subchunk. }
			mmckinfoSubchunk.ckid := mmioStringToFOURCC('data', 0);
			if mmioDescend(hMyMmio, @mmckinfoSubchunk, @mmckinfoParent, 	MMIO_FINDCHUNK) <> 0 then begin
					MessageBox(GetActiveWindow, 'WAVE file has no data chunk.',
										 'LoadWaveInfo', MB_OK OR MB_ICONEXCLAMATION);
					mmioClose(hMyMmio, 0);
					exit;
			end;

			{ Get the size of the data subchunk. }
			wi.dwDataSize := mmckinfoSubchunk.cksize;

			{ We're done with the file, close it. }
			mmioClose(hMyMmio, 0);

			pwi := New(PWAVEINFO);
			if pwi <> nil then begin
				pwi^ := wi;
				pwi^.pszFile := StrNew(pszFileName);
				LoadWaveInfo := pwi;
			end;
end;

function LoadWaveData(pszFileName : PCHAR) : PWAVEDATA;
var
		hMyMmio							: HMMIO;
		mmckinfoParent,
		mmckinfoSubchunk	: TMMCKINFO;
		hOldCursor				: HCURSOR;
		wd								: TWAVEDATA;
		pwd								: PWAVEDATA;

begin
			LoadWaveData := nil;
			{ Open the given file for reading using buffered I/O. }
			hMyMmio := mmioOpen(pszFileName, nil, MMIO_READ OR MMIO_ALLOCBUF);
			if hMyMmio = 0 then	begin
					MessageBox(GetActiveWindow, 'Failed to open file.',
										 'LoadWaveData', MB_OK OR MB_ICONEXCLAMATION);
					exit;
			end;

			{ Locate a 'RIFF' chunk with a 'WAVE' form type
			 * to make sure it's a WAVE file.	 }
			mmckinfoParent.fccType := mmioStringToFOURCC('WAVE', 0);
			if mmioDescend(hMyMmio, @mmckinfoParent, nil, MMIO_FINDRIFF) <> 0 then begin
					MessageBox(GetActiveWindow, 'This is not a WAVE file.',
										 'LoadWaveData', MB_OK OR MB_ICONEXCLAMATION);
					mmioClose(hMyMmio, 0);
					exit;
			end;

			{ Find the data subchunk. }
			mmckinfoSubchunk.ckid := mmioStringToFOURCC('data', 0);
			if mmioDescend(hMyMmio, @mmckinfoSubchunk, @mmckinfoParent, 	MMIO_FINDCHUNK) <> 0 then begin
					MessageBox(GetActiveWindow, 'WAVE file has no data chunk.',
										 'LoadWaveData', MB_OK OR MB_ICONEXCLAMATION);
					mmioClose(hMyMmio, 0);
					exit;
			end;

			{ Get the size of the data subchunk. }
			wd.dwDataSize := mmckinfoSubchunk.cksize;
			if wd.dwDataSize > 0 then	begin
				{ Allocate and lock memory for the waveform data. }
				wd.hData := GlobalAlloc(GMEM_MOVEABLE , wd.dwDataSize );
				if (wd.hData = 0)  then	begin
						MessageBox(GetActiveWindow, 'Out of memory.',
											 'LoadWaveData', MB_OK OR MB_ICONEXCLAMATION);
						mmioClose(hMyMmio, 0);
						exit;
				end;

				wd.pData := GlobalLock(wd.hData);
				if (wd.pData = nil) then begin
						MessageBox(GetActiveWindow, 'Failed to lock memory.',
											 'LoadWaveData', MB_OK OR MB_ICONEXCLAMATION);
						GlobalFree( wd.hData );
						mmioClose(hMyMmio, 0);
						exit;
				end;

				{ Read the waveform data subchunk. }
				hOldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
				SetCapture(GetActiveWindow);
				if mmioRead(hMyMmio, PChar(wd.pData), wd.dwDataSize) <> wd.dwDataSize then	begin
						MessageBox(GetActiveWindow, 'Failed to read data chunk.',
											 'LoadWaveData', MB_OK OR MB_ICONEXCLAMATION);
						GlobalUnlock( wd.hData );
						GlobalFree( wd.hData );
						mmioClose(hMyMmio, 0);
						SetCursor(hOldCursor);
						ReleaseCapture;
						exit;
				end;
			end else begin
				wd.hData := 0;
				wd.pData := nil;
			end;

			SetCursor(hOldCursor);
			ReleaseCapture;

			{ We're done with the file, close it. }
			mmioClose(hMyMmio, 0);

			pwd := New(PWAVEDATA);
			if pwd <> nil then begin
				pwd^ := wd;
				pwd^.pszFile := StrNew(pszFileName);
				LoadWaveData := pwd;
			end;
end;

function SaveWave(pWav : PWAVE) : BOOL;
var
		hMyMmio							: HMMIO;
		mmckinfoParent,
		mmckinfoSubchunk	: TMMCKINFO;
		hOldCursor				: HCURSOR;
		wRet							: WORD;

begin
	SaveWave := FALSE;

	hmio := mmioOpen(pWav^.pszFile, NIL, MMIO_CREATE OR MMIO_WRITE OR MMIO_DENYNONE);
	if hmio = 0 then begin
		MessageBox(GetActiveWindow, 'Can''t create file', pWav^.pszFile, MB_OK + MB_ICONSTOP);
		exit;
	end;

	{Create chunk WAVE}
	FillChar(mmckinfoParent, SizeOf(mmckinfoParent), 0);
	mmckinfoParent.fccType := mmioStringToFOURCC('WAVE', 0);
	wRet := mmioCreateChunk(hmio, @mmckinfoParent, MMIO_CREATERIFF);
	if wRet <> 0 then begin
		 case wRet of
				 MMIOERR_CANNOTWRITE :
					 MessageBox(GetActiveWindow, 'Can''t create chunk', 'WAVE MMIOERR_CANNOTWRITE', MB_OK + MB_ICONSTOP);
				 MMIOERR_CANNOTSEEK  :
					 MessageBox(GetActiveWindow, 'Can''t create chunk', 'WAVE MMIOERR_CANNOTSEEK', MB_OK + MB_ICONSTOP);
				 else
					 MessageBox(GetActiveWindow, 'Can''t create chunk', 'WAVE MMIOERR_UNKNOWN', MB_OK + MB_ICONSTOP);
		 end;
		 mmioClose(hmio, 0);
		 exit;
	end;

	{Create chunk fmt}
	mmckinfoSubChunk.ckid := mmioStringToFOURCC('fmt', 0);
	mmckinfoSubChunk.cksize := SizeOf(TPCMWAVEFORMAT);
	if BOOL(mmioCreateChunk(hmio, @mmckinfoSubChunk, 0)) then begin
		MessageBox(GetActiveWindow, 'Can''t create chunk', 'fmt Create', MB_OK + MB_ICONSTOP);
		mmioClose(hmio, 0);
		exit;
	end;
	if (pWav^.pInfo^.pFormat <> nil) AND
		 (mmioWrite(hmio, PSTR(pWav^.pInfo^.pFormat), mmckinfoSubChunk.cksize) <> mmckinfoSubChunk.cksize) then begin
		MessageBox(GetActiveWindow, 'Can''t fill chunk', 'fmt Write', MB_OK + MB_ICONSTOP);
		mmioClose(hmio, 0);
		exit;
	end;

	{Create data}
	mmckinfoSubChunk.ckid := mmioStringToFOURCC('data', 0);
	mmckinfoSubChunk.cksize :=  pWav^.pData^.dwDataSize;
	if BOOL(mmioCreateChunk(hmio, @mmckinfoSubChunk, 0)) then begin
		MessageBox(GetActiveWindow, 'Can''t create chunk', 'data Create', MB_OK + MB_ICONSTOP);
		mmioClose(hmio, 0);
		exit;
	end;

	{New Wave File created...}
	if (mmioWrite(hmio, pWav^.pData^.pData, pWav^.pData^.dwDataSize) <>pWav^.pData^.dwDataSize) then begin
		MessageBox(GetActiveWindow, 'Can''t fill chunk', 'data Write', MB_OK + MB_ICONSTOP);
		mmioClose(hmio, 0);
		exit;
	end;

	mmioAscend(hmio, @mmckinfoSubChunk, 0);	{mise à jour subchunk data size}
	mmioAscend(hmio, @mmckinfoParent, 0);		{mise à jour subchunk WAVE size}
	mmioClose(hmio, 0);
	SaveWave := TRUE;
end;

function MakePointsList(pWInfo : PWAVEINFO; pWData : PWAVEDATA; nHeight : integer; dwSamplePerPixel : DWORD) : PPOINTS;
var
		pFirst,
		pCur							: PPOINTS;
		i,
		nBlocks						: integer;
		dwOfs,
		dwWidth,
		dwSample					: DWORD;

begin

	MakePointsList := nil;

	if pWData^.dwDataSize = 0 then exit;

	dwSample := pWData^.dwDataSize DIV pWInfo^.pFormat^.wf.nBlockAlign;
	dwWidth := dwSample DIV dwSamplePerPixel;
	{WriteLn(' dwDataSize=', pWData^.dwDataSize, ' dwSample=', dwSample, ' dwWidth=', dwWidth);}

	if dwWidth <= MAXPOINTS DIV 2 then begin
		MakePointsList := MakePoints(pWInfo, pWData, nHeight, dwWidth, dwSamplePerPixel, 0);
		Exit;
	end;

	nBlocks := dwWidth DIV (MAXPOINTS DIV 2);
	dwBlockSize := (MAXPOINTS DIV 2) * longint(dwSamplePerPixel) * longint(pWInfo^.pFormat^.wf.nBlockAlign);
	{WriteLn('nBlocks=', nBlocks, ' dwBlockSize=', dwBlockSize);}

	pFirst := MakePoints(pWInfo, pWData, nHeight, MAXPOINTS DIV 2, dwSamplePerPixel, 0);
	dwOfs := dwBlockSize;
	dec(nBlocks);
	dec(dwWidth, MAXPOINTS DIV 2);

	pCur := pFirst;
	while (nBlocks > 0) AND
				(pCur <> nil) do begin
		pCur^.pNext := MakePoints(pWInfo, pWData, nHeight, MAXPOINTS DIV 2, dwSamplePerPixel, dwOfs);
		pCur := pCur^.pNext;
		inc(dwOfs, dwBlockSize);
		dec(nBlocks);
		dec(dwWidth, MAXPOINTS DIV 2);
		{WriteLn('nBlocks=', nBlocks, ' dwOfs=', dwOfs, ' pCur=', DWORD(pCur), ' dwWidth=', dwWidth);}
	end;

	if pCur <> nil then begin
		if dwWidth <> 0 then begin
			{WriteLn('dwWidth=', dwWidth);}
			pCur^.pNext := MakePoints(pWInfo, pWData, nHeight, dwWidth, dwSamplePerPixel, dwOfs);
		end;
	end;

	MakePointsList := pFirst;

end;

function MakePoints(pWInfo : PWAVEINFO; pWData : PWAVEDATA; nHeight : integer; dwHeight, dwSamplePerPixel : DWORD;
										lOfs : longint) : PPOINTS;
var
		i,
		j									: longint;
		Sample,
		min,
		max,
		nTop,
		nBase							: integer;
		hOldCursor				: HCURSOR;
		wSize							: WORD;
		pSample						: POINTER;
		pts								: TPOINTS;
		ppts							: PPOINTS;
		nXOfs							: integer;

begin
			MakePoints := nil;

			pts.pNext := nil;

			nBase := nHeight DIV 2;
			pts.lPoints := dwHeight * 2;

			nXOfs := (lOfs DIV pWInfo^.pFormat^.wf.nBlockAlign) DIV dwSamplePerPixel;

			if (pts.lPoints = 0) then begin
				exit;
			end;

			if (pts.lPoints > MAXPOINTS) then begin
					MessageBox(GetActiveWindow, 'Too many points.',
										 'MakePoints', MB_OK OR MB_ICONEXCLAMATION);
				exit;
			end;

			{ Allocate and lock memory for the waveform data points. }
			pts.hap := GlobalAlloc(GMEM_MOVEABLE , longint(pts.lPoints * SizeOf(TPOINT)));
			if (pts.hap = 0) then	begin
					MessageBox(GetActiveWindow, 'Out of memory.',
										 'MakePoints', MB_OK OR MB_ICONEXCLAMATION);
					exit;
			end;

			pts.pap := PAPOINT(GlobalLock(pts.hap));
			if (pts.pap = nil) then begin
					MessageBox(GetActiveWindow, 'Failed to lock memory.',
										 'MakePoints', MB_OK OR MB_ICONEXCLAMATION);
					GlobalFree(pts.hap);
					exit;
			end;

			{hOldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
			SetCapture(GetActiveWindow);}
			{$IFOPT R+}
				{$R-}
				{$DEFINE _RANGE_ON}
			{$ENDIF}
			{ Prepare the point array. }
			i := 0;
			Sample := 0;
			wSize := pWInfo^.pFormat^.wf.nBlockAlign DIV pWInfo^.pFormat^.wf.nChannels;
			case wSize of
				1 :	begin
							nTop := 255;
							inc(nBase, nBase);
						end;
				2 :	nTop := 32767;
			end;
			while i < pts.lPoints do begin
				min := nTop;
				max := -nTop;
				j := 0;
				while j < dwSamplePerPixel do begin
					if lOfs > pWData^.dwDataSize then break;
					//pSample := Ptr(PtrRec(pWData^.pData).Hi + PtrRec(lOfs).Hi * Ofs(AHIncr), PtrRec(lOfs).Lo);
					pSample := pWData^.pData + lOfs;
					Move(pSample^, Sample, wSize);
					if Sample > max then max := Sample;
					if Sample < min then min := Sample;
					inc(lOfs, pWInfo^.pFormat^.wf.nBlockAlign);
					inc(j);
				end;
				pts.pap^[i].x := i DIV 2 + nXOfs;
				pts.pap^[i].y := integer(nBase - MulDiv(min, nBase, nTop));
				inc(i);
				pts.pap^[i].x := pts.pap^[i - 1].x;
				pts.pap^[i].y := integer(nBase - MulDiv(max, nBase, nTop));
				inc(i);
			end;
			{$IFDEF _RANGE_ON}
				{$R+}
				{$UNDEF _RANGE_ON}
			{$ENDIF}
			{SetCursor(hOldCursor);
			ReleaseCapture;}

			ppts := New(PPOINTS);
			if ppts <> nil then begin
				ppts^ := pts;
				MakePoints := ppts;
			end;

end;

function DrawPoints(dc : HDC; pCurWave : PWAVE; dwRGB : TCOLORREF) : integer;
var
		pPts 							: PPOINTS;
		hMyPen,
		hOldPen						: HPEN;
		hOldFont					: HFONT;
		hOldBrush					: HBRUSH;
		pLast,
		pNext						  : PPOINTS;
		szNum							: array[0..15] of char;
		x									: integer;
begin

	DrawPoints := -1;

	if pCurWave = nil then exit;

	pPts := pCurWave^.pLstPoints;

	if pCurWave^.bDummy then begin
		hMyPen := CreatePen(PS_DOT, 1, dwRGB);
	end else begin
		hMyPen := CreatePen(PS_SOLID, 1, dwRGB);
	end;
	hOldPen := SelectObject(dc, hMyPen);
	hOldBrush	:= SelectObject(dc, GetStockObject(BLACK_BRUSH));
	SetBkColor(dc, RGB(0, 0, 0));

	{ parcour la liste de des tableaux de points et les traces }
	pNext := pPts;
	pLast := pNext;
	while pNext <> nil do begin
		if NOT PolyLine(dc, TPOINT(pNext^.pap^[0]), pNext^.lPoints) then begin
			MessageBeep(WORD(-1));
		end;
		pLast := pNext;
		pNext := pNext^.pNext;
	end;

	hOldFont := SelectObject(dc, GetStockObject(ANSI_VAR_FONT));

	wvsprintf(szNum, '(%d)', @pCurWave^.nNum);
	SetTextColor(dc, RGB(0, 255, 255));
	SetTextAlign(dc, TA_CENTER);
	if (pLast <> nil) then begin
		x := pLast^.pap^[pLast^.lPoints - 1].x DIV 2;
	end else begin
		x := 0;
	end;
	TextOut(dc, x, 8, pCurWave^.pszName, StrLen(pCurWave^.pszName));
	TextOut(dc, x, 22, szNum, StrLen(szNum));
	if pCurWave^.bDummy then begin
		StrCopy(szNum, 'Vide');
		SetTextAlign(dc, TA_CENTER OR TA_BASELINE);
		TextOut(dc, x, pLast^.pap^[pLast^.lPoints - 1].y - 8, szNum, StrLen(szNum));
	end;

	SelectObject(dc, hOldBrush);
	SelectObject(dc, hOldFont);
	SelectObject(dc, hOldPen);
	DeleteObject(hMyPen);

	if (pLast <> nil) AND
		 (pLast^.lPoints > 0) then DrawPoints := pLast^.pap^[pLast^.lPoints - 1].x;
end;

function GetScreenOfs(pWaves, pSearchWav : PWAVE) : DWORD;
var
		pCurWav					  : PWAVE;
		dwScreenOfs					: DWORD;
begin

	GetScreenOfs := 0;

	if pWaves = nil then exit;
	if pSearchWav = nil then exit;

	dwScreenOfs := 0;
	pCurWav := pWaves;
	while (pCurWav <> nil) AND
				(pCurWav <> pSearchWav) do begin
		if (pCurWav^.pLstPoints <> nil) AND
			 (pCurWav^.pLstPoints^.lPoints > 0) then inc(dwScreenOfs, pCurWav^.pLstPoints^.pap^[pCurWav^.pLstPoints^.lPoints - 1].x);
		pCurWav := pCurWav^.pNext;
	end;

	GetScreenOfs := dwScreenOfs;
end;

function DrawMarker(dc : HDC; x, y, nIn, nOut : integer; dwRGB : TCOLORREF) : integer;
var
		hMyPen,
		hOldPen						: HPEN;
		hMyBrush,
		hOldBrush					: HBRUSH;
		aPoint						: array[0..7] of TPOINT;
begin

	DrawMarker := 0;

	hMyPen := CreatePen(PS_SOLID, 1, dwRGB);
	hOldPen := SelectObject(dc, hMyPen);

	hMyBrush := CreateSolidBrush(dwRGB);
	hOldBrush := SelectObject(dc, hMyBrush);

	aPoint[0].x := x - nIn;
	aPoint[0].y := 0;
	aPoint[1].x := x;
	aPoint[1].y := nIn;
	aPoint[2].x := x;
	aPoint[2].y := y - nIn;
	aPoint[3].x := x - nIn;
	aPoint[3].y := y;
	aPoint[4].x := x + nOut;
	aPoint[4].y := y;
	aPoint[5].x := x;
	aPoint[5].y := y - nOut;
	aPoint[6].x := x;
	aPoint[6].y := nOut;
	aPoint[7].x := x + nOut;
	aPoint[7].y := 0;

	Polygon(dc, aPoint, 8);

	SelectObject(dc, hOldBrush);
	DeleteObject(hMyBrush);

	SelectObject(dc, hOldPen);
	DeleteObject(hMyPen);

	DrawMarker := 1;
end;

function SetWindowOrg(_para1:HDC; _para2:longint; _para3:longint):WINBOOL;
begin
     SetWindowOrg := SetWindowOrgEx(_para1, _para2, _para3, nil);
end;

function PlayWave(hWin : HWND; pWaves, pWavFrom, pWavTo : PWAVE; dwFrom, dwTo, dwHeight, dwSamplePerPixel : DWORD;
									nRate : integer) : BOOL;
var
	hWavHdr		:	THANDLE;
	pWavHdr		: PWAVEHDR;
	pWav			: PWAVE;
	wRet			: WORD;
	MSG				: TMSG;
	mmt				: TMMTIME;
	dwOldSample		: DWORD;
	dc				: HDC;

	nOldSamplePerSec,
	nOldAvgBytesPerSec : DWORD;

begin
	if pWaves = nil then exit;
	if pWavFrom = nil then exit;
	if pWavTo = nil then exit;

	pWav := pWavFrom;

	dwFrom := (dwFrom DIV (pWav^.pInfo^.pFormat^.wf.nBlockAlign * pWav^.pInfo^.pFormat^.wf.nChannels))
										 *  (pWav^.pInfo^.pFormat^.wf.nBlockAlign * pWav^.pInfo^.pFormat^.wf.nChannels);

	dwTo := (dwTo DIV (pWav^.pInfo^.pFormat^.wf.nBlockAlign * pWav^.pInfo^.pFormat^.wf.nChannels))
										 *  (pWav^.pInfo^.pFormat^.wf.nBlockAlign * pWav^.pInfo^.pFormat^.wf.nChannels);

	nOldSamplePerSec := pWav^.pInfo^.pFormat^.wf.nSamplesPerSec;
	nOldAvgBytesPerSec := pWav^.pInfo^.pFormat^.wf.nAvgBytesPerSec;

	pWav^.pInfo^.pFormat^.wf.nSamplesPerSec := nOldSamplePerSec * nRate DIV 100;
	pWav^.pInfo^.pFormat^.wf.nAvgBytesPerSec := pWav^.pInfo^.pFormat^.wf.nSamplesPerSec *
																					 pWav^.pInfo^.pFormat^.wf.nBlockAlign *
																					 pWav^.pInfo^.pFormat^.wf.nChannels;

	if BOOL(waveOutOpen(@hWavOut, WORD(WAVE_MAPPER),
											@pWav^.pInfo^.pFormat^.wf, 0, 0, WAVE_FORMAT_QUERY)) then begin
			pWav^.pInfo^.pFormat^.wf.nSamplesPerSec := nOldSamplePerSec;
			pWav^.pInfo^.pFormat^.wf.nAvgBytesPerSec := nOldAvgBytesPerSec;
			MessageBox(GetActiveWindow, 'The waveform device can''t play this format.',
									 'PlayWave', MB_OK OR MB_ICONEXCLAMATION);
			exit;
	end;

	if BOOL(waveOutOpen(@hWavOut, WORD(WAVE_MAPPER),
											@pWav^.pInfo^.pFormat^.wf, 0, 0, 0)) then begin
			pWav^.pInfo^.pFormat^.wf.nSamplesPerSec := nOldSamplePerSec;
			pWav^.pInfo^.pFormat^.wf.nAvgBytesPerSec := nOldAvgBytesPerSec;
			MessageBox(GetActiveWindow, 'Failed to open waveform output device.',
									 'PlayWave', MB_OK OR MB_ICONEXCLAMATION);
			exit;
	end;

	pWav^.pInfo^.pFormat^.wf.nSamplesPerSec := nOldSamplePerSec;
	pWav^.pInfo^.pFormat^.wf.nAvgBytesPerSec := nOldAvgBytesPerSec;

	{ Allocate a waveform data header. The WAVEHDR must be
		globally allocated and locked.}
	hWavHdr := GlobalAlloc(GMEM_MOVEABLE, sizeof(TWAVEHDR));
	if hWavHdr = 0 then begin
			waveOutClose(hWavOut);
			MessageBox(GetActiveWindow, 'Not enough memory for header.',
									 'PlayWave', MB_OK OR MB_ICONEXCLAMATION);
			exit;
	end;

	pWavHdr := PWAVEHDR(GlobalLock(hWavHdr));
	if pWavHdr = nil then begin
			waveOutClose(hWavOut);
			GlobalFree(hWavHdr);
			MessageBox(GetActiveWindow, 'Failed to lock memory for header.',
									 'PlayWave', MB_OK OR MB_ICONEXCLAMATION);
			exit;
	end;

	{ Set up WAVEHDR structure and prepare it to be written to wave device. }

	bPlaying := TRUE;
	mmt.wType := TIME_SAMPLES;
	mmt.sample := 0;
	//pWavHdr^.lpData := Ptr(PtrRec(pWav^.pData^.pData).Hi + PtrRec(dwFrom).Hi * Ofs(AHIncr), PtrRec(dwFrom).Lo);
	pWavHdr^.lpData := pWav^.pData^.pData + dwFrom;
	pWavHdr^.dwBufferLength := pWav^.pData^.dwDataSize - dwFrom;
	if (pWav = pWavTo) then begin
			pWavHdr^.dwBufferLength := dwTo - dwFrom;
	end;

	dc := GetDC(GetDlgItem(hWin, 103));
	SetWindowOrg(dc, GetTrackPos(GetDlgItem(hWin, 108))
									 - (dwFrom DIV (pWav^.pInfo^.pFormat^.wf.nBlockAlign * pWav^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel))
									 - (GetScreenOfs(pWaves, pWav)), 0);
	PatBlt(dc, mmt.sample, 0, 1, dwHeight, PATINVERT);
	while (pWav <> nil) AND
				(pWav <> pWavTo^.pNext) AND
				bPlaying do begin

		pWavHdr^.dwFlags := 0;
		pWavHdr^.dwLoops := 0;
		pWavHdr^.dwUser := 0;

		if BOOL(waveOutPrepareHeader(hWavOut, pWavHdr, sizeof(TWAVEHDR))) then begin
				waveOutClose(hWavOut);
				GlobalUnlock(hWavHdr);
				GlobalFree(hWavHdr);
				MessageBox(GetActiveWindow, 'Unable to prepare wave header.',
										 'PlayWave', MB_OK OR MB_ICONEXCLAMATION);
				bPlaying := FALSE;
				exit;
		end;

		{ Then the data block can be sent to the output device. }
		wRet := waveOutWrite(hWavOut, pWavHdr, sizeof(TWAVEHDR));
		if (wRet <> 0) then begin
				waveOutUnprepareHeader(hWavOut, pWavHdr, sizeof(TWAVEHDR));
				waveOutClose(hWavOut);
				GlobalUnlock(hWavHdr);
				GlobalFree(hWavHdr);
				MessageBox(GetActiveWindow, 'Failed to write block to device.',
										 'PlayWave', MB_OK OR MB_ICONEXCLAMATION);
				bPlaying := FALSE;
				exit;
		end;

		while (pWavHdr^.dwFlags AND MHDR_DONE) <> MHDR_DONE do begin
			if PeekMessage(MSG, 0, 0, 0, PM_REMOVE) then begin
				TranslateMessage(MSG);
				DispatchMessage(MSG);
			end;
			dwOldSample := mmt.sample;
			WaveOutGetPosition(hWavOut, @mmt, sizeof(TMMTIME));
			mmt.sample := mmt.sample DIV dwSamplePerPixel {DIV 2 {???}};
			if dwOldSample <> mmt.sample then begin
				PatBlt(dc, dwOldSample, 0, 1, dwHeight, PATINVERT);
				PatBlt(dc, mmt.sample, 0, 1, dwHeight, PATINVERT);
			end;
		end;

		waveOutUnprepareHeader(hWavOut, pWavHdr, sizeof(TWAVEHDR));
		pWav := pWav^.pNext;
		if pWav <> nil then begin
			pWavHdr^.lpData := pWav^.pData^.pData;
			pWavHdr^.dwBufferLength := pWav^.pData^.dwDataSize;
			if (pWav = pWavTo) then begin
					pWavHdr^.dwBufferLength := dwTo;
			end;
		end;
	end;
	PatBlt(dc, dwOldSample, 0, 1, dwHeight, PATINVERT);
	ReleaseDC(GetDlgItem(hWin, 103), dc);

	waveOutClose(hWavOut);
	GlobalUnlock(hWavHdr);
	GlobalFree(hWavHdr);
	bPlaying := FALSE;

end;

procedure DisposePoints(pCurWave : PWAVE);
var
	pNextPts	 : PPOINTS;
begin
	while pCurWave^.pLstPoints <> nil do begin
		pNextPts := pCurWave^.pLstPoints^.pNext;
		GlobalUnlock(pCurWave^.pLstPoints^.hap);
		GlobalFree(pCurWave^.pLstPoints^.hap);
		Dispose(pCurWave^.pLstPoints);
		pCurWave^.pLstPoints := pNextPts;
	end;
end;

procedure DisposeWave(Dialog : HWND; dwSamplePerPixel : DWORD; pCurWave : PWAVE);
var
		szText						: array[0..255] of char;
		wRet							: WORD;
		rc								: TRECT;
begin


	{if pCurWave^.bModify then begin
		wvsprintf(szText, 'Voulez-vous écouter les modifications du fichier %s de la séquence %d ?', pCurWave^.pszFile);
		wRet := MessageBox(GetActiveWindow, szText, 'Question', MB_YESNO + MB_ICONQUESTION);

		if wRet = IDYES then begin
			GetClientRect(GetDlgItem(Dialog, 103), rc);
			PlayWave(Dialog,
							 pCurWave,
							 pCurWave,
							 pCurWave,
							 0,
							 pCurWave^.pData^.dwDataSize,
							 rc.bottom, dwSamplePerPixel, GetTrackPos(GetDlgItem(Dialog, 109)) * 10 + 20);
		end;

		wvsprintf(szText, 'Voulez-vous enregistrer les modifications du fichier %s de la séquence %d ?', pCurWave^.pszFile);
		wRet := MessageBox(GetActiveWindow, szText, 'Question', MB_YESNO + MB_ICONQUESTION);

		if wRet = IDYES then begin
			SaveWave(pCurWave);
		end;
	end;}

	SaveWave(pCurWave);

	if pCurWave^.pInfo <> nil then begin
		GlobalUnlock(pCurWave^.pInfo^.hFormat);
		GlobalFree(pCurWave^.pInfo^.hFormat);
		if pCurWave^.pInfo^.pszFile <> nil then StrDispose(pCurWave^.pInfo^.pszFile);
		Dispose(pCurWave^.pInfo);
		pCurWave^.pInfo := nil;
	end;

	if pCurWave^.pData <> nil then begin
		GlobalUnlock(pCurWave^.pData^.hData);
		GlobalFree(pCurWave^.pData^.hData);
		if pCurWave^.pData^.pszFile <> nil then StrDispose(pCurWave^.pData^.pszFile);
		Dispose(pCurWave^.pData);
		pCurWave^.pData := nil;
	end;

	DisposePoints(pCurWave);
	pCurWave^.pLstPoints := nil;

	if pCurWave^.pszFile <> nil then StrDispose(pCurWave^.pszFile);

	if pCurWave^.pszName <> nil then StrDispose(pCurWave^.pszName);

	if pCurWave <> nil then Dispose(pCurWave);
end;

procedure UpdatePoints(Dialog : HWND; pWaves : PWAVE;
											 var dwMaxSize, dwTotSize, dwSamplePerPixel : DWORD;
											 var nScrollDiv : integer);
var
	pCurWave : PWAVE;
	rc			 : TRECT;
begin
	if pWaves = nil then exit;

	dwMaxSize := 0;
	dwTotSize := 0;
	pCurWave := pWaves;
	while pCurWave <> nil do begin
		if pCurWave^.pInfo^.dwDataSize DIV pCurWave^.pInfo^.pFormat^.wf.nBlockAlign > dwMaxSize then begin
			dwMaxSize := pCurWave^.pInfo^.dwDataSize DIV pCurWave^.pInfo^.pFormat^.wf.nBlockAlign;
		end;
		inc(dwTotSize, pCurWave^.pInfo^.dwDataSize DIV pCurWave^.pInfo^.pFormat^.wf.nBlockAlign);
		pCurWave := pCurWave^.pNext;
	end;

	dwSamplePerPixel := (dwMaxSize DIV MAXPOINTS) * 2;

	GetClientRect(GetDlgItem(Dialog, 103), rc);
	dwSamplePerPixel := dwMaxSize DIV rc.right;

	if dwSamplePerPixel < 2 then dwSamplePerPixel := 2;

	nScrollDiv := (dwTotSize DIV dwSamplePerPixel) DIV 32767 + 1;

	dwSamplePerPixel := dwSamplePerPixel * nScrollDiv;

	pCurWave := pWaves;
	while pCurWave <> nil do begin
		DisposePoints(pCurWave);
		pCurWave^.pLstPoints := MakePointsList(pCurWave^.pInfo, pCurWave^.pData, rc.bottom, dwSamplePerPixel);
		pCurWave := pCurWave^.pNext;
	end;

	SetTrackRange(GetDlgItem(Dialog, 108), 0,
								(dwTotSize DIV dwSamplePerPixel) DIV nScrollDiv - rc.right, TRUE);

	SendMessage(Dialog, WM_HSCROLL, SB_THUMBPOSITION, MAKELONG(0, GetDlgItem(Dialog, 108)));
end;

function SubClsProc(Dialog: HWnd; Message, WParam: DWord;
	LParam: Longint): Bool; StdCall;

begin

	case Message of

			WM_LBUTTONDOWN :
				begin
					PostMessage(GetParent(Dialog), UM_LBUTTONDOWN, wParam, lParam);
				end;

			WM_MOUSEMOVE :
				begin
					PostMessage(GetParent(Dialog), UM_MOUSEMOVE, wParam, lParam);
				end;

			WM_LBUTTONUP :
				begin
					PostMessage(GetParent(Dialog), UM_LBUTTONUP, wParam, lParam);
				end;

			WM_LBUTTONDBLCLK :
				begin
					PostMessage(GetParent(Dialog), UM_LBUTTONDBLCLK, wParam, lParam);
				end;

	end;
	SubClsProc := BOOL(CallWindowProc(lpOldSubClsProc, Dialog, Message, wParam, 	lParam));
end;

function WavEditProc(Dialog: HWnd; Message, WParam: Word;
	LParam: Longint): Bool; stdcall;

var
			szCaption,
			szLecon,
			szFormat	 : Array[0..127]of char;
			pLecon		 : PCHAR;
			rc,
			rcSel			 : TRECT;
			dc 				 : hDC;
			ps 				 : TPaintStruct;
			iMax,
			iMin,
			dn				 : integer;
			pNextWave,
			pNewWave,
			pCurWave	 : PWAVE;
			pNextPts	 : PPOINTS;
			tQuestion	 : TypeQuestion;
			nX,
			nOfs,
			nRet,
			i					 : integer;
			dwRet			 : DWORD;
			hdcChild 	 : HDC;
			hwndChild  : HWND;
			nCtlType 	 : integer;
			pt				 : TPOINT;
			hClip,
			hData,
			hReAlloc	 : THANDLE;
			pClip,
			pData			 : POINTER;
			dwRemoved  : DWORD;
			dwAdded    : DWORD;
			dwCurDataSize	   : DWORD;
			dwNextDataSize   : DWORD;
			pWaveSwap	 : PWAVE;
			nSwap      : integer;
			dwSwap		 : DWORD;

const
			tOldLecon	 : TypeLecon = ();
			iPos			 : integer = 0;
			pWaveFrom  : PWAVE = nil;
			pWaveTo    : PWAVE = nil;
			pWaves		 : PWAVE = nil;
			pWaveEdge	 : PWAVE = nil;
			dwMaxSize	 			 : DWORD = 0;
			dwTotSize	 			 : DWORD = 0;
			dwSamplePerPixel : DWORD = 2;
			nScrollDiv 			 : integer = 1;
			dwFrom           : DWORD = 0;
			dwTo	           : DWORD = 0;
			nEdge            : integer = -1;
			nFrom            : integer = 0;
			nTo	             : integer = 0;
			nFirst         	 : integer = 0;
			nLast         	 : integer = 0;
			nCount         	 : integer = 0;
			dwRGB						 : DWORD = $0F00;

begin
	WavEditProc := True;

	case Message of
		wm_InitDialog:
			begin

				StrCopy(szNOWAVEPATH, PathSons);
				StrCat(szNOWAVEPATH, szNOWAVE);
				iPos						 := 0;
				dwTotSize	 			 := 0;
				dwMaxSize	 			 := 0;
				dwSamplePerPixel := 2;
				nScrollDiv 			 := 1;
				pWaves		 			 := nil;

				CenterDialog(Dialog);

				tOldLecon := tLecon;

				GetWindowText(Dialog, szFormat, SizeOf(szFormat));
				GetDlgItemText(hListBar, idl_lecon, szLecon, SizeOf(szLecon));
				pLecon := @szLecon;
				wvsprintf(szCaption, szFormat, pLecon);
				SetWindowText(Dialog, szCaption);

				GetLessonRec(GetCurItemData(hListBar, idl_Lecon) + 1, 	tLecon);
				dwRet := SendDlgItemMessage(hLeconProc, idl_ListeQ, LB_GETSELITEMS, 1, DWORD(@nFirst));
				if dwRet <> LB_ERR then begin
					dwRet := SendDlgItemMessage(hLeconProc, idl_ListeQ, LB_GETCOUNT, 0, 0);
					if dwRet = LB_ERR then dwRet := 0;
					nCount := dwRet;
					pCurWave := pWaves;
					inc(nFirst);
					nLast := nFirst + 2;
					if nLast > nCount then nLast := nCount;
					for i := nFirst to nLast do begin

						GetQuestionRec(i, 	tQuestion);
						pNewWave := New(PWAVE);
						if pNewWave <> nil then begin

							{ init item }
							if (tQuestion.FichierQuestion[0] <> #0) AND
								 FileExist(tQuestion.FichierQuestion) then begin
								pNewWave^.pszFile 		:= StrNew(tQuestion.FichierQuestion);
								pNewWave^.bDummy	 		:= FALSE;
							end else begin
								pNewWave^.pszFile 		:= StrNew(szNOWAVEPATH);
								pNewWave^.bDummy	 		:= TRUE;
							end;
							pNewWave^.bModify	 		:= FALSE;
							pNewWave^.pszName 		:= StrNew(tQuestion.Nom);
							pNewWave^.nNum		 		:= i;
							pNewWave^.pInfo				:= nil;
							pNewWave^.pData				:= nil;
							pNewWave^.pLstPoints 	:= nil;
							pNewWave^.pNext	 	 		:= nil;

							{ charge info pour tous les items }
							if (pNewWave^.pszFile <> nil)	then begin
								pNewWave^.pInfo := LoadWaveInfo(pNewWave^.pszFile);
								if (pNewWave^.pInfo <> nil) then begin
									if pNewWave^.pInfo^.dwDataSize DIV pNewWave^.pInfo^.pFormat^.wf.nBlockAlign > dwMaxSize then begin
										dwMaxSize := pNewWave^.pInfo^.dwDataSize DIV pNewWave^.pInfo^.pFormat^.wf.nBlockAlign;
									end;
									inc(dwTotSize, pNewWave^.pInfo^.dwDataSize DIV pNewWave^.pInfo^.pFormat^.wf.nBlockAlign);
								end;
							end;

							if pCurWave = nil then begin
								{ tête de liste ... }
								pCurWave := pNewWave;
								pWaves := pCurWave;
							end else begin
								{ ... suite de liste }
								pCurWave^.pNext := pNewWave;
								pCurWave := pCurWave^.pNext;
							end;
						end;
					end;

					dwSamplePerPixel := (dwMaxSize DIV MAXPOINTS) * 2;

					GetClientRect(GetDlgItem(Dialog, 103), rc);
					dwSamplePerPixel := dwMaxSize DIV rc.right;

					if dwSamplePerPixel < 2 then dwSamplePerPixel := 2;

					nScrollDiv := (dwTotSize DIV dwSamplePerPixel) DIV 32767 + 1;

					dwSamplePerPixel := dwSamplePerPixel * nScrollDiv;

					{ charge data }
					pWaveFrom := pWaves;
					pCurWave := pWaves;
					while pCurWave <> nil do begin
						pCurWave^.pData := LoadWaveData(pCurWave^.pszFile);
						if pCurWave^.pData <> nil then begin
							GetClientRect(GetDlgItem(Dialog, 103), rc);
							pCurWave^.pLstPoints := MakePointsList(pCurWave^.pInfo, pCurWave^.pData, rc.bottom, dwSamplePerPixel);
						end;
						pWaveTo := pCurWave;
						pCurWave := pCurWave^.pNext;
					end;

					dwFrom := 0;
					nFrom := 0;
					dwTo := pWaveTo^.pData^.dwDataSize;
					nTo := pWaveTo^.pData^.dwDataSize DIV
								(pWaveTo^.pInfo^.pFormat^.wf.nBlockAlign * pWaveTo^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel) - 1;

					SetTrackRange(GetDlgItem(Dialog, 108), 0,
												(dwTotSize DIV dwSamplePerPixel) DIV nScrollDiv - rc.right, TRUE);
					SetTrackPos(GetDlgItem(Dialog, 108), 0, TRUE);

					SetTrackRange(GetDlgItem(Dialog, 109), 0, 	23, TRUE);
					SetTrackPos(GetDlgItem(Dialog, 109), 8, TRUE);

				end;
				lpSubClsProc := WNDPROC(MakeProcInstance(LongInt(@SubClsProc), hInstance));
				lpOldSubClsProc := WNDPROC(SetWindowLong(GetDlgItem(Dialog, 103), GWL_WNDPROC, LongInt(lpSubClsProc)));
				SetTimer(Dialog, 1, 300, nil);
			end;

		WM_PAINT :
			begin
				BeginPaint(Dialog, ps);
				EndPaint(Dialog, ps);
			end;

		 WM_HSCROLL:
			 begin
					if HIWORD(lParam) = GetDlgItem(Dialog, 108) then begin
						GetTrackRange(HIWORD(lParam), iMin, iMax);
						GetClientRect(HIWORD(lParam), rc);

						case (wParam) of
								 SB_LINEDOWN:      dn :=  rc.right DIV 16 + 1;
								 SB_LINEUP:        dn := -rc.right DIV 16 + 1;
								 SB_PAGEDOWN:      dn :=  rc.right DIV 2  + 1;
								 SB_PAGEUP:        dn := -rc.right DIV 2  + 1;
								 SB_THUMBTRACK,
								 SB_THUMBPOSITION : begin
																			dn := LOWORD(lParam) - iPos;
																		end;
						else
																	 {MessageBeep(WORD(-1));}
																	 dn := 0;
						end;
						dn := ALIGNB(dn);
						dn := BOUND(iPos + dn, iMin, iMax) - iPos;
						if (dn <> 0) then	begin
								ScrollWindow(GetDlgItem(Dialog, 103), -dn, 0, nil, nil);
								SetTrackPos(HIWORD(lParam), iPos + dn, TRUE);
								iPos := GetTrackPos(HIWORD(lParam));
								UpdateWindow(GetDlgItem(Dialog, 103));
						end;
					end;
					if HIWORD(lParam) = GetDlgItem(Dialog, 109) then begin
						SetDlgItemInt(Dialog, 110, GetTrackPos(HIWORD(lParam)) * 10 + 20, FALSE);
					end;

					exit;
			 end;

		WM_MEASUREITEM :
			begin
				GetClientRect(GetDlgItem(Dialog, 103), rc);
				PMeasureItemStruct(lParam)^.itemWidth := rc.right;
				PMeasureItemStruct(lParam)^.itemHeight := rc.bottom;
			end;

		WM_ERASEBKGND :
			begin
				{exit;}
			end;

		WM_CTLCOLOR :
			begin
				hdcChild := HDC(wParam);
				hwndChild := HWND(LOWORD(lParam));
				nCtlType := integer(HIWORD(lParam));
				if hwndChild = GetDlgItem(Dialog, 103) then begin
					WavEditProc := BOOL(GetStockObject(NULL_BRUSH));
					exit;
				end;
			end;

		WM_TIMER :
			begin
				if (nFrom = nTo) AND
					 (pWaveFrom = pWaveTo) AND
					 (nFrom = 0) then begin
					dc := GetDC(GetDlgItem(Dialog, 103));
					SetWindowOrg(dc, GetTrackPos(GetDlgItem(Dialog, 108)), 0);
					GetClientRect(GetDlgItem(Dialog, 103), rc);
					DrawMarker(dc, GetScreenOfs(pWaves, pWaveFrom), rc.bottom - 1, 5, 5, dwRGB);
					if dwRGB = RGB(255, 0, 0) then begin
						dwRGB := RGB(255, 255, 0);
					end else begin
						dwRGB := RGB(255, 0, 0);
					end;
					ReleaseDC(GetDlgItem(Dialog, 103), dc);
				end;
			end;

		WM_DRAWITEM :
			begin
			if ((PDrawItemStruct(lParam)^.itemAction AND ODA_DRAWENTIRE) = ODA_DRAWENTIRE) then begin
				GetClientRect(GetDlgItem(Dialog, 103), rc);
				dc := PDrawItemStruct(lParam)^.hDC;
				pCurWave := pWaves;
				nOfs := 0;
				SetWindowOrg(dc, GetTrackPos(GetDlgItem(Dialog, 108)) - nOfs, 0);
				if nFrom + GetScreenOfs(pWaves, pWaveFrom) <=  nTo + GetScreenOfs(pWaves, pWaveTo) then begin
					SetRect(rcSel, GetTrackPos(GetDlgItem(Dialog, 108)) - nOfs, 0, nFrom + GetScreenOfs(pWaves, pWaveFrom) - 1, rc.bottom);
					FillRect(dc, rcSel, GetStockObject(BLACK_BRUSH));
					SetRect(rcSel, nFrom + GetScreenOfs(pWaves, pWaveFrom) + 1, 0, nTo + GetScreenOfs(pWaves, pWaveTo), rc.bottom);
					FillRect(dc, rcSel, GetStockObject(DKGRAY_BRUSH));
					SetRect(rcSel, nTo + GetScreenOfs(pWaves, pWaveTo) + 1, 0,
									GetTrackPos(GetDlgItem(Dialog, 108)) - nOfs + rc.right, rc.bottom);
					FillRect(dc, rcSel, GetStockObject(BLACK_BRUSH));
				end else begin
					SetRect(rcSel, GetTrackPos(GetDlgItem(Dialog, 108)) - nOfs, 0, nTo + GetScreenOfs(pWaves, pWaveTo) - 1, rc.bottom);
					FillRect(dc, rcSel, GetStockObject(BLACK_BRUSH));
					SetRect(rcSel, nTo + GetScreenOfs(pWaves, pWaveTo) + 1, 0, nFrom + GetScreenOfs(pWaves, pWaveFrom), rc.bottom);
					FillRect(dc, rcSel, GetStockObject(DKGRAY_BRUSH));
					SetRect(rcSel, nFrom + GetScreenOfs(pWaves, pWaveFrom) + 1, 0,
									GetTrackPos(GetDlgItem(Dialog, 108)) - nOfs + rc.right, rc.bottom);
					FillRect(dc, rcSel, GetStockObject(BLACK_BRUSH));
				end;
				DrawMarker(dc, 0, rc.bottom - 1, 0, 0, RGB(127, 0, 0));
				while pCurWave <> nil do begin
					SetWindowOrg(dc, GetTrackPos(GetDlgItem(Dialog, 108)) - nOfs, 0);
					nX := DrawPoints(dc, pCurWave, RGB(0, 255, 0));
					if (pWaveEdge = pCurWave) AND
						 (nEdge <> -1) then begin
						if nEdge >= nX then begin
							DrawMarker(dc, nX, rc.bottom - 1, 5, 0, RGB(255, 0, 0));
							DrawMarker(dc, nEdge, rc.bottom - 1, 0, 5, RGB(255, 0, 0));
						end else begin
							DrawMarker(dc, nEdge, rc.bottom - 1, 5, 0, RGB(255, 0, 0));
							DrawMarker(dc, nX, rc.bottom - 1, 0, 5, RGB(255, 0, 0));
						end;
					end else begin
						if (pCurWave^.bDummy) OR
							 (pCurWave^.pNext = nil) OR
							 ((pCurWave^.pNext <> nil) AND pCurWave^.pNext^.bDummy)	 then begin
							DrawMarker(dc, nX, rc.bottom - 1, 0, 0, RGB(127, 0, 0));
						end else begin
							DrawMarker(dc, nX, rc.bottom - 1, 5, 5, RGB(255, 0, 0));
						end;
					end;
					if pWaveFrom = pCurWave then begin
						if nFrom + GetScreenOfs(pWaves, pWaveFrom) <= nTo + GetScreenOfs(pWaves, pWaveTo) then begin
							DrawMarker(dc, nFrom, rc.bottom - 1, 5, 0, RGB(255, 255, 0));
						end else begin
							DrawMarker(dc, nFrom, rc.bottom - 1, 0, 5, RGB(255, 255, 0));
						end;
					end;
					if pWaveTo = pCurWave then begin
						if nFrom + GetScreenOfs(pWaves, pWaveFrom) <= nTo + GetScreenOfs(pWaves, pWaveTo) then begin
							DrawMarker(dc, nTo, rc.bottom - 1, 0, 5, RGB(255, 255, 0));
						end else begin
							DrawMarker(dc, nTo, rc.bottom - 1, 5, 0, RGB(255, 255, 0));
						end;
					end;
					inc(nOfs, nX);
					pCurWave := pCurWave^.pNext;
				end;
			end;
			end;

		WM_MOUSEMOVE :
			begin
				nMouseMode := MOUSE_NONE;
			end;

		WM_SETCURSOR :
			begin
				if (nMouseMode >= MOUSE_ONFROM) AND
					 (nMouseMode <= MOUSE_MOVEEDGE)then begin
					SetCursor(LoadCursor(0, IDC_SIZEWE));
					SetWindowLong(Dialog, DWL_MSGRESULT, MAKELONG(WORD(TRUE), 0));
					exit;
				end;
			end;

		UM_LBUTTONDOWN :
			case nMouseMode of

				MOUSE_ONEDGE :
					begin
						nMouseMode := MOUSE_MOVEEDGE;
						pt.x := LOWORD(lParam);
						pt.y := HIWORD(lParam);
						nEdge := pt.x + GetTrackPos(GetDlgItem(Dialog, 108)) - GetScreenOfs(pWaves, pWaveEdge);
					end;

				MOUSE_ONFROM : nMouseMode := MOUSE_MOVEFROM;
				MOUSE_ONTO : nMouseMode := MOUSE_MOVETO;

				MOUSE_NONE :
					begin
						nMouseMode := MOUSE_MOVETO;
						pt.x := LOWORD(lParam);
						pt.y := HIWORD(lParam);
						pCurWave := pWaves;
						while (pCurWave <> nil) AND
									(pt.x > GetScreenOfs(pWaves, pCurWave) - GetTrackPos(GetDlgItem(Dialog, 108))) do begin
							pWaveFrom := pCurWave;
							if wParam AND MK_SHIFT = 0 then begin
								nFrom := pt.x + GetTrackPos(GetDlgItem(Dialog, 108)) - GetScreenOfs(pWaves, pCurWave);
								dwFrom := DWORD(nFrom) *
													(pCurWave^.pInfo^.pFormat^.wf.nBlockAlign * pCurWave^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel);
							end else begin
								nFrom := 0;
								dwFrom := 0;
							end;
							pCurWave := pCurWave^.pNext;
						end;
						pWaveTo := pWaveFrom;
						if wParam AND MK_SHIFT = 0 then begin
							nTo := nFrom;
							dwTo := dwFrom;
						end else begin
							nTo := pWaveTo^.pData^.dwDataSize DIV
										(pWaveTo^.pInfo^.pFormat^.wf.nBlockAlign * pWaveTo^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel) - 1;
							dwTo := pWaveTo^.pData^.dwDataSize;
						end;
						InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);
					end;
			end;

		UM_MOUSEMOVE :
			case nMouseMode of
				MOUSE_ONEDGE,
				MOUSE_ONFROM,
				MOUSE_ONTO,
				MOUSE_NONE :
					begin
						pt.x := LOWORD(lParam);
						pt.y := HIWORD(lParam);
						pCurWave := pWaves;
						nMouseMode := MOUSE_NONE;
						while (pCurWave <> nil) do begin
							if  (NOT pCurWave^.bDummy) AND
									(pCurWave^.pNext <> nil) AND
									(NOT pCurWave^.pNext^.bDummy) AND
									(pt.x >= GetScreenOfs(pWaves, pCurWave^.pNext) - GetTrackPos(GetDlgItem(Dialog, 108)) - 5) AND
									(pt.x <= GetScreenOfs(pWaves, pCurWave^.pNext) - GetTrackPos(GetDlgItem(Dialog, 108)) + 5) then begin
									pWaveEdge := pCurWave;
									nMouseMode := MOUSE_ONEDGE;
									break;
							end;
							if  (pCurWave = pWaveFrom) AND
									(pt.x >= GetScreenOfs(pWaves, pCurWave) + nFrom - GetTrackPos(GetDlgItem(Dialog, 108)) - 5) AND
									(pt.x <= GetScreenOfs(pWaves, pCurWave) + nFrom - GetTrackPos(GetDlgItem(Dialog, 108)) + 5) then begin
									nMouseMode := MOUSE_ONFROM;
									break;
							end;
							if	(pCurWave = pWaveTo) AND
									(pt.x >= GetScreenOfs(pWaves, pCurWave) + nTo - GetTrackPos(GetDlgItem(Dialog, 108)) - 5) AND
									(pt.x <= GetScreenOfs(pWaves, pCurWave) + nTo - GetTrackPos(GetDlgItem(Dialog, 108)) + 5) then begin
									nMouseMode := MOUSE_ONTO;
									break;
							end;
							pCurWave := pCurWave^.pNext;
						end;
					end;

				MOUSE_MOVEEDGE :
					begin

						pt.x := LOWORD(lParam);
						pt.y := HIWORD(lParam);
						nEdge := pt.x + GetTrackPos(GetDlgItem(Dialog, 108)) - GetScreenOfs(pWaves, pWaveEdge);
						InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);
						exit;
					end;

				MOUSE_MOVEFROM :
					begin
						pt.x := LOWORD(lParam);
						pt.y := HIWORD(lParam);
						pCurWave := pWaves;
						while (pCurWave <> nil) AND
									(pt.x > GetScreenOfs(pWaves, pCurWave) - GetTrackPos(GetDlgItem(Dialog, 108))) do begin
							pWaveFrom := pCurWave;
							nFrom := pt.x + GetTrackPos(GetDlgItem(Dialog, 108)) - GetScreenOfs(pWaves, pCurWave);
							dwFrom := DWORD(nFrom) *
												(pCurWave^.pInfo^.pFormat^.wf.nBlockAlign * pCurWave^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel);
							pCurWave := pCurWave^.pNext;
						end;
						InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);
					end;

				MOUSE_MOVETO :
					begin
						pt.x := LOWORD(lParam);
						pt.y := HIWORD(lParam);
						pCurWave := pWaves;
						while (pCurWave <> nil) AND
									(pt.x > GetScreenOfs(pWaves, pCurWave) - GetTrackPos(GetDlgItem(Dialog, 108))) do begin
							pWaveTo := pCurWave;
							if wParam AND MK_SHIFT = 0 then begin
								nTo := pt.x + GetTrackPos(GetDlgItem(Dialog, 108)) - GetScreenOfs(pWaves, pCurWave);
								dwTo := DWORD(nTo) *
												(pCurWave^.pInfo^.pFormat^.wf.nBlockAlign * pCurWave^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel);
							end else begin
								nTo := pWaveTo^.pData^.dwDataSize DIV
											(pWaveTo^.pInfo^.pFormat^.wf.nBlockAlign * pWaveTo^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel) - 1;
								dwTo := pWaveTo^.pData^.dwDataSize;
							end;
							pCurWave := pCurWave^.pNext;
						end;;
						InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);
					end;
			end;

		UM_LBUTTONUP :
			begin
				case nMouseMode of

					MOUSE_MOVEEDGE :
					begin
						pCurWave := pWaveEdge;
						pNextWave := pWaveEdge^.pNext;
						if (pCurWave = nil) OR
							 (pNextWave = nil) then begin
							 MessageBox(GetActiveWindow, 'Invalid pWaveEdge.',
													 'MMWave', MB_OK OR MB_ICONEXCLAMATION);
							 exit;
						end;

						dwCurDataSize := DWORD(nEdge) *
												(pCurWave^.pInfo^.pFormat^.wf.nBlockAlign * pCurWave^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel);

						if dwCurDataSize < 0 then dwCurDataSize := 0;

						if pCurWave^.pData^.dwDataSize = dwCurDataSize then exit;

						if (pCurWave^.pData^.dwDataSize > dwCurDataSize) then begin
							dwRemoved := pCurWave^.pData^.dwDataSize - dwCurDataSize;
							dwNextDataSize := pNextWave^.pData^.dwDataSize + dwRemoved;
							hData := GlobalAlloc(GMEM_MOVEABLE, dwNextDataSize);
							if hData = 0 then begin
								MessageBox(GetActiveWindow, 'Failed to allocate next memory block.',
													 'MMWave', MB_OK OR MB_ICONEXCLAMATION);
								exit;
							end;
							pData := GlobalLock(hData);
							MemoryRead(pCurWave^.pData^.pData, dwCurDataSize, pData, dwRemoved);
							dwAdded := 0;
						end else begin
							dwAdded := dwCurDataSize - pCurWave^.pData^.dwDataSize;
							dwNextDataSize := pNextWave^.pData^.dwDataSize - dwAdded;
							if dwNextDataSize < 0 then begin
								dwNextDataSize := 0;
								dwAdded := pNextWave^.pData^.dwDataSize;
								dwCurDataSize := pCurWave^.pData^.dwDataSize + dwAdded;
							end;
							hData := GlobalAlloc(GMEM_MOVEABLE, dwNextDataSize);
							if hData = 0 then begin
								MessageBox(GetActiveWindow, 'Failed to allocate next memory block.',
													 'MMWave', MB_OK OR MB_ICONEXCLAMATION);
								exit;
							end;
							pData := GlobalLock(hData);
							dwRemoved := 0;
						end;

						GlobalUnlock(pCurWave^.pData^.hData);
						if pCurWave^.pData^.hData <> 0 then begin
							hReAlloc := GlobalReAlloc(pCurWave^.pData^.hData, dwCurDataSize, {GMEM_ZEROINIT OR GMEM_MOVEABLE OR GMEM_NODISCARD} 0);
						end else begin
							hReAlloc := GlobalAlloc(GMEM_MOVEABLE, dwCurDataSize);
						end;
						if hReAlloc <> 0 then begin
							pCurWave^.pData^.hData := hReAlloc;
						end else begin
							if dwCurDataSize = 0 then begin
								pCurWave^.pData^.hData := hReAlloc;
							end else begin
								MessageBox(GetActiveWindow, 'Failed to ReAllocate memory.',
													 'MMWave', MB_OK OR MB_ICONEXCLAMATION);
							end;
						end;
						pCurWave^.pData^.pData := GlobalLock(pCurWave^.pData^.hData);
						pCurWave^.pInfo^.dwDataSize := dwCurDataSize;
						pCurWave^.pData^.dwDataSize := dwCurDataSize;

						if dwRemoved > 0 then begin
							MemoryWrite(pData, dwRemoved, pNextWave^.pData^.pData, pNextWave^.pData^.dwDataSize);
						end else begin
							MemoryRead(pNextWave^.pData^.pData, dwAdded, pData, dwNextDataSize);
							MemoryWrite(pWaveEdge^.pData^.pData, pWaveEdge^.pData^.dwDataSize - dwAdded, pNextWave^.pData^.pData, dwAdded);
						end;
						GlobalUnlock(pNextWave^.pData^.hData);
						GlobalFree(pNextWave^.pData^.hData);
						pNextWave^.pData^.hData := hData;
						pNextWave^.pData^.pData := GlobalLock(hData);
						pNextWave^.pInfo^.dwDataSize := dwNextDataSize;
						pNextWave^.pData^.dwDataSize := dwNextDataSize;

						DisposePoints(pNextWave);
						DisposePoints(pCurWave);
						GetClientRect(GetDlgItem(Dialog, 103), rc);
						pNextWave^.pLstPoints := MakePointsList(pNextWave^.pInfo, pNextWave^.pData, rc.bottom, dwSamplePerPixel);
						pCurWave^.pLstPoints := MakePointsList(pCurWave^.pInfo, pCurWave^.pData, rc.bottom, dwSamplePerPixel);
						pNextWave^.bModify	 	:= TRUE;
						pCurWave^.bModify	 		:= TRUE;

						pWaveFrom := pNextWave;
						nFrom := 0;
						dwFrom := 0;

						pWaveTo := pNextWave;
						nTo := 0;
						dwTo := 0;

						pWaveEdge := nil;
						nEdge := -1;

						InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);

						nMouseMode := MOUSE_NONE;
					end;

					MOUSE_MOVEFROM,
					MOUSE_MOVETO :
						begin
							if nFrom + GetScreenOfs(pWaves, pWaveFrom) > nTo + GetScreenOfs(pWaves, pWaveTo) then begin
								pWaveSwap := pWaveFrom;
								nSwap := nFrom;
								dwSwap := dwFrom;
								pWaveFrom := pWaveTo;
								nFrom := nTo;
								dwFrom := dwTo;
								pWaveTo := pWaveSwap;
								nTo := nSwap;
								dwTo := dwSwap;
							end;
							nMouseMode := MOUSE_NONE;
						end;
				end;
			end;

		UM_LBUTTONDBLCLK :
			begin
				if wParam AND MK_SHIFT = 0 then begin
					{ sélectionner le son pointé }
					pt.x := LOWORD(lParam);
					pt.y := HIWORD(lParam);
					pCurWave := pWaves;
					while (pCurWave <> nil) AND
								(pt.x > GetScreenOfs(pWaves, pCurWave) - GetTrackPos(GetDlgItem(Dialog, 108))) do begin
						pWaveFrom := pCurWave;
						nFrom := 0;
						dwFrom := 0;
						pCurWave := pCurWave^.pNext;
					end;
					pWaveTo := pWaveFrom;
					nTo := pWaveTo^.pData^.dwDataSize DIV
								(pWaveTo^.pInfo^.pFormat^.wf.nBlockAlign * pWaveTo^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel) - 1;
					dwTo := pWaveTo^.pData^.dwDataSize;

				end else begin

					{ sélectionner tous les sons }
					nMouseMode := MOUSE_NONE;
					pt.x := LOWORD(lParam);
					pt.y := HIWORD(lParam);
					pCurWave := pWaves;
					pWaveFrom := pCurWave;
					nFrom := 0;
					dwFrom := 0;
					while (pCurWave <> nil) do begin
						pWaveTo := pCurWave;
						nTo := pWaveTo^.pData^.dwDataSize DIV
									(pWaveTo^.pInfo^.pFormat^.wf.nBlockAlign * pWaveTo^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel) - 1;
						dwTo := pWaveTo^.pData^.dwDataSize;
						pCurWave := pCurWave^.pNext;
					end;
				end;
				InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);
			end;

		wm_Command : begin
			case WParam of

				109 :
					begin
						if bPlaying then begin
							{SetDlgItemText(Dialog, 104, '>');}
							waveOutReset(hWavOut);
							bPlaying := FALSE;
							InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);
							exit;
						end;

						SetDlgItemText(Dialog, 104, '€');
						pCurWave := pWaves;
						while pCurWave^.pNext <> nil do begin
							pCurWave := pCurWave^.pNext;
						end;
						GetClientRect(GetDlgItem(Dialog, 103), rc);
						PlayWave(Dialog, pWaves,
										 pWaveFrom,
										 pWaveTo,
										 dwFrom,
										 dwTo,
										 rc.bottom, dwSamplePerPixel, GetTrackPos(GetDlgItem(Dialog, 109)) * 10 + 20);

						SetDlgItemText(Dialog, 104, '>');
					end;

				105 :
					begin
						if bPlaying then begin
							MessageBeep(WORD(-1));
							exit;
						end;

						if nFirst = 1 then exit;

						dec(nFirst);
						nLast := nFirst + 2;

						{ Dispose last wave }
						pCurWave := pWaves;
						while (pCurWave <> nil) AND
									(pCurWave^.pNext <> nil) AND
									(PWAVE(pCurWave^.pNext)^.pNext <> nil) do begin
							pCurWave := pCurWave^.pNext;
						end;
						if (pCurWave^.pNext <> nil) then begin
							DisposeWave(Dialog, dwSamplePerPixel, pCurWave^.pNext);
							pCurWave^.pNext := nil;
						end;

						GetQuestionRec(nFirst, 	tQuestion);
						pNewWave := New(PWAVE);
						if pNewWave <> nil then begin
							{ init item }
							pNewWave^.nNum		 		:= nFirst;
							pNewWave^.pszName 		:= StrNew(tQuestion.Nom);
							pNewWave^.pInfo				:= nil;
							pNewWave^.pData				:= nil;
							pNewWave^.pLstPoints 	:= nil;
							pNewWave^.pNext	 	 		:= nil;
							pNewWave^.bModify	 		:= FALSE;
							if (tQuestion.FichierQuestion[0] <> #0) AND
								 FileExist(tQuestion.FichierQuestion) then begin
								pNewWave^.pszFile 		:= StrNew(tQuestion.FichierQuestion);
								pNewWave^.bDummy	 		:= FALSE;
							end else begin
								pNewWave^.pszFile 		:= StrNew(szNOWAVEPATH);
								pNewWave^.bDummy	 		:= TRUE;
							end;

							{ charge info }
							if (pNewWave^.pszFile <> nil)	then begin
								pNewWave^.pInfo := LoadWaveInfo(pNewWave^.pszFile);
								if (pNewWave^.pInfo <> nil)	then begin
									pNewWave^.pData := LoadWaveData(pNewWave^.pszFile);
								end;
							end;

							pNewWave^.pNext := pWaves;
							pWaves := pNewWave;

							pWaveFrom := pNewWave;
							dwFrom := 0;
							nFrom := 0;
							pWaveTo := pNewWave;
							nTo := 0;
							dwTo := 0;
							UpdatePoints(Dialog, pWaves, dwMaxSize, dwTotSize, dwSamplePerPixel, nScrollDiv);
							nTo := pWaveTo^.pData^.dwDataSize DIV
										(pWaveTo^.pInfo^.pFormat^.wf.nBlockAlign * pWaveTo^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel) - 1;
							dwTo := pWaveto^.pData^.dwDataSize;
							InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);
							UpdateWindow(GetDlgItem(Dialog, 103));
						end;
					end;

				106 :
					begin
						if bPlaying then begin
							MessageBeep(WORD(-1));
							exit;
						end;

						if nLast = nCount then exit;

						inc(nLast);
						nFirst := nLast - 2;
						if nFirst < 1 then nFirst := 1;

						{ Dispose 1st wave }
						pNextWave := pWaves^.pNext;
						if (pWaves <> nil) then begin
							DisposeWave(Dialog, dwSamplePerPixel, pWaves);
						end;
						pWaves := pNextWave;

						GetQuestionRec(nLast, 	tQuestion);

						pNewWave := New(PWAVE);
						if pNewWave <> nil then begin
							{ init item }
							pNewWave^.nNum		 		:= nLast;
							pNewWave^.pszName 		:= StrNew(tQuestion.Nom);
							pNewWave^.pInfo				:= nil;
							pNewWave^.pData				:= nil;
							pNewWave^.pLstPoints 	:= nil;
							pNewWave^.pNext	 	 		:= nil;
							pNewWave^.bModify	 		:= FALSE;
							if (tQuestion.FichierQuestion[0] <> #0) AND
								 FileExist(tQuestion.FichierQuestion) then begin
								pNewWave^.pszFile 	:= StrNew(tQuestion.FichierQuestion);
								pNewWave^.bDummy		:= FALSE;
							end else begin
								pNewWave^.pszFile 	:= StrNew(szNOWAVEPATH);
								pNewWave^.bDummy		:= TRUE;
							end;

							{ charge info }
							if (pNewWave^.pszFile <> nil)	then begin
								pNewWave^.pInfo := LoadWaveInfo(pNewWave^.pszFile);
								if (pNewWave^.pInfo <> nil)	then begin
									pNewWave^.pData := LoadWaveData(pNewWave^.pszFile);
								end;
							end;

							pCurWave := pWaves;
							while (pCurWave <> nil) AND (pCurWave^.pNext <> nil) do begin
								pCurWave := pCurWave^.pNext;
							end;
							if (pCurWave <> nil) AND (pCurWave^.pNext = nil) then begin
								pCurWave^.pNext := pNewWave;
							end;
							pWaveFrom := pNewWave;
							dwFrom := 0;
							nFrom := 0;
							pWaveTo := pNewWave;
							nTo := 0;
							dwTo := 0;
							UpdatePoints(Dialog, pWaves, dwMaxSize, dwTotSize, dwSamplePerPixel, nScrollDiv);
							nTo := pWaveTo^.pData^.dwDataSize DIV
										(pWaveTo^.pInfo^.pFormat^.wf.nBlockAlign * pWaveTo^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel) - 1;
							dwTo := pWaveto^.pData^.dwDataSize;

							InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);
							UpdateWindow(GetDlgItem(Dialog, 103));
						end;
					end;

				{ New }
				6016 :
					begin
						pCurWave := pWaveFrom;
						if (pCurWave = nil) then begin
							 exit;
						end;

						dwCurDataSize := DWORD(nTo) *
														 (pCurWave^.pInfo^.pFormat^.wf.nBlockAlign * pCurWave^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel);

						if dwCurDataSize <= 0 then exit;

						if pCurWave^.pData^.dwDataSize = dwCurDataSize then exit;

						GetQuestionRec(pCurWave^.nNum, tQuestion);
						pNewWave := New(PWAVE);
						if pNewWave <> nil then begin
							pNewWave^.nNum		 		:= pCurWave^.nNum + 1;
							pNewWave^.pszName 		:= StrNew(tQuestion.Nom);
							pNewWave^.pInfo				:= LoadWaveInfo(pCurWave^.pszFile);
							pNewWave^.pData				:= New(PWAVEDATA);
							pNewWave^.pLstPoints 	:= nil;
							pNewWave^.pNext	 	 		:= nil;
							pNewWave^.bModify	 		:= TRUE;
							NewQuestionFile(tQuestion.FichierQuestion, pNewWave^.nNum);
							pNewWave^.pszFile 		:= StrNew(tQuestion.FichierQuestion);
							pNewWave^.pData^.pszFile := StrNew(tQuestion.FichierQuestion);
							pNewWave^.bDummy			:= FALSE;
						end else begin
							MessageBox(GetActiveWindow, 'Failed to allocate PWAVE.',
												 'MMWave', MB_OK OR MB_ICONEXCLAMATION);
							exit;
						end;

						PasteQuestionRec(pNewWave^.nNum, tQuestion);
						InsertSequenceProp(hListBar,idl_ListeQ, pNewWave^.nNum - 1, tQuestion);
						InsertSequenceProp(hLeconProc,idl_ListeQ, pNewWave^.nNum - 1, tQuestion);

						dwRemoved := pCurWave^.pData^.dwDataSize - dwCurDataSize;
						pNewWave^.pData^.hData := GlobalAlloc(GMEM_MOVEABLE, dwRemoved);
						if pNewWave^.pData^.hData = 0 then begin
							MessageBox(GetActiveWindow, 'Failed to allocate memory for new Wave.',
												 'MMWave', MB_OK OR MB_ICONEXCLAMATION);
							exit;
						end;
						pNewWave^.pData^.pData := GlobalLock(pNewWave^.pData^.hData);
						MemoryRead(pCurWave^.pData^.pData, dwCurDataSize, pNewWave^.pData^.pData, dwRemoved);

						GlobalUnlock(pCurWave^.pData^.hData);
						hReAlloc := GlobalReAlloc(pCurWave^.pData^.hData, dwCurDataSize, 0);
						if hReAlloc <> 0 then begin
							pCurWave^.pData^.hData := hReAlloc;
						end else begin
							MessageBox(GetActiveWindow, 'Failed to ReAllocate memory.',
												 'MMWave', MB_OK OR MB_ICONEXCLAMATION);
						end;
						pCurWave^.pData^.pData := GlobalLock(pCurWave^.pData^.hData);
						pCurWave^.pInfo^.dwDataSize := dwCurDataSize;
						pCurWave^.pData^.dwDataSize := dwCurDataSize;
						pNewWave^.pInfo^.dwDataSize := dwRemoved;
						pNewWave^.pData^.dwDataSize := dwRemoved;

						DisposePoints(pCurWave);
						GetClientRect(GetDlgItem(Dialog, 103), rc);
						pCurWave^.pLstPoints := MakePointsList(pCurWave^.pInfo, pCurWave^.pData, rc.bottom, dwSamplePerPixel);
						pCurWave^.bModify	 		:= TRUE;
						pNewWave^.pLstPoints := MakePointsList(pNewWave^.pInfo, pNewWave^.pData, rc.bottom, dwSamplePerPixel);

						{ insert in list }
						pNewWave^.pNext := pCurWave^.pNext;
						pCurWave^.pNext := pNewWave;

						SaveWave(pNewWave);

						pCurWave := pNewWave^.pNext;
						while pCurWave <> nil do begin
							inc(pCurWave^.nNum);
							pCurWave := pCurWave^.pNext;
						end;

						if (pWaveTo <> pWaveFrom) OR
							 ((pWaveTo = pWaveFrom) AND (nFrom <> nTo)) then begin
							pWaveTo := pWaveFrom;
							nTo := nFrom;
							dwTo := dwFrom;
							InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);
							PostMessage(Dialog, Message, wParam, lParam);
							exit;
						end;

						pWaveFrom := pNewWave;
						nFrom := 0;
						dwFrom := 0;
						pWaveTo := pNewWave;
						nTo := pWaveTo^.pData^.dwDataSize DIV
									(pWaveTo^.pInfo^.pFormat^.wf.nBlockAlign * pWaveTo^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel) - 1;
						dwTo := pWaveTo^.pData^.dwDataSize;

						InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);
					end;

				{ Del }
				6015 :
					begin
						if (pWaveFrom = nil) OR
							 (pWaveTo = nil) then exit;

						{ Del Edge ... }
						if (nFrom = nTo) AND
							 (pWaveFrom = pWaveTo) AND
							 (nFrom = 0) AND
							 (pWaveEdge <> nil) then begin
							nMouseMode :=	MOUSE_MOVEEDGE;
							nEdge := 32767;
							PostMessage(Dialog, UM_LBUTTONUP, 0, 0);
							exit;
						end;

						{ Del content ... }
						pCurWave := pWaveFrom;
						if (pWaveFrom <> pWaveTo) then begin
							pWaveTo := pWaveFrom;
							dwTo := pCurWave^.pData^.dwDataSize;
						end;
						dwRemoved := dwTo - dwFrom;
						if pCurWave^.pData^.dwDataSize > dwRemoved then begin
							if dwTo < pCurWave^.pData^.dwDataSize then begin
								hData := GlobalAlloc(GMEM_MOVEABLE, pCurWave^.pData^.dwDataSize - dwTo);
								pData := GlobalLock(hData);
								MemoryRead(pCurWave^.pData^.pData, dwTo, pData, pCurWave^.pData^.dwDataSize - dwTo);
								pCurWave^.pData^.hData := GlobalReAlloc(pCurWave^.pData^.hData, pCurWave^.pData^.dwDataSize - dwRemoved, 0);
								pCurWave^.pData^.pData := GlobalLock(pCurWave^.pData^.hData);
								MemoryWrite(pCurWave^.pData^.pData, dwFrom, pData, pCurWave^.pData^.dwDataSize - dwTo);
								GlobalUnlock(hData);
								GlobalFree(hData);
							end else begin
								pCurWave^.pData^.hData := GlobalReAlloc(pCurWave^.pData^.hData, pCurWave^.pData^.dwDataSize - dwRemoved, 0);
								pCurWave^.pData^.pData := GlobalLock(pCurWave^.pData^.hData);
							end;
						end else begin
							GlobalUnlock(pCurWave^.pData^.hData);
							GlobalFree(pCurWave^.pData^.hData);
							pCurWave^.pData^.hData := 0;
							pCurWave^.pData^.pData := nil;
						end;
						pCurWave^.pInfo^.dwDatasize := pCurWave^.pData^.dwDatasize - dwRemoved;
						pCurWave^.pData^.dwDatasize := pCurWave^.pData^.dwDatasize - dwRemoved;
						pCurWave^.bModify := TRUE;
						UpdatePoints(Dialog, pWaves, dwMaxSize, dwTotSize, dwSamplePerPixel, nScrollDiv);
						nFrom := dwFrom DIV
									(pWaveFrom^.pInfo^.pFormat^.wf.nBlockAlign * pWaveFrom^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel) - 1;
						pWaveTo := pWaveFrom;
						dwTo := dwFrom;
						nTo := nFrom;
						InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);
					end;

				{ Cut }
				6011 :
					begin
						SendMessage(Dialog, WM_COMMAND, 6012, 0);
						SendMessage(Dialog, WM_COMMAND, 6015, 0);
					end;

				{ Copy }
				6012 :
					begin
						if (pWaveFrom = nil) OR
							 (pWaveTo = nil) OR
							 ((pWaveFrom = pWaveTo) AND (nFrom = nTo)) then exit;

						if (pWaveFrom = pWaveTo) then begin
							pCurWave := pWaveFrom;
							dwCurDataSize := DWORD(nFrom) *
															 (pCurWave^.pInfo^.pFormat^.wf.nBlockAlign * pCurWave^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel);
							dwRemoved := DWORD(nTo - nFrom) *
															 (pCurWave^.pInfo^.pFormat^.wf.nBlockAlign * pCurWave^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel);
							hData := GlobalAlloc(GMEM_MOVEABLE, dwRemoved);
							pData := GlobalLock(hData);
							MemoryRead(pCurWave^.pData^.pData, dwCurDataSize, pData, dwRemoved);
							GlobalUnlock(hData);
						end else begin
							pCurWave := pWaveFrom;
							dwCurDataSize := DWORD(nFrom) *
															 (pCurWave^.pInfo^.pFormat^.wf.nBlockAlign * pCurWave^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel);
							dwRemoved := pCurWave^.pData^.dwDataSize - dwCurDataSize;
							hData := GlobalAlloc(GMEM_MOVEABLE, dwRemoved);
							pData := GlobalLock(hData);
							MemoryRead(pCurWave^.pData^.pData, dwCurDataSize, pData, dwRemoved);
							GlobalUnlock(hData);
							pCurWave := pCurWave^.pNext;
							while pCurWave <> pWaveTo do begin
								hData := GlobalReAlloc(hData, dwRemoved + pCurWave^.pData^.dwDataSize, 0);
								MemoryWrite(pData, dwRemoved, pCurWave^.pData^.pData, pCurWave^.pData^.dwDataSize);
								inc(dwRemoved, pCurWave^.pData^.dwDataSize);
								pCurWave := pCurWave^.pNext;
							end;
							dwCurDataSize := DWORD(nTo) *
															 (pCurWave^.pInfo^.pFormat^.wf.nBlockAlign * pCurWave^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel);
							hData := GlobalReAlloc(hData, dwRemoved + dwCurDataSize, 0);
							MemoryWrite(pData, dwRemoved, pCurWave^.pData^.pData, dwCurDataSize);
							inc(dwRemoved, dwCurDataSize);
						end;

						if OpenClipboard(Dialog) then begin
							EmptyClipboard;
							SetClipboardData(CF_OWNERDISPLAY, hData);
							CloseClipboard;
						end;
					end;

				{ Paste }
				6013 :
					begin
						if (pWaveFrom = nil) OR
							 (pWaveTo = nil) then exit;

						hClip := 0;
						if OpenClipboard(Dialog) then begin
							hClip := GetClipboardData(CF_OWNERDISPLAY);
							CloseClipboard;
						end;
						if hClip = 0 then exit;
						pClip := GlobalLock(hClip);

						if (pWaveFrom = pWaveTo) then begin
							pCurWave := pWaveFrom;
							dwRemoved := DWORD(nTo - nFrom) *
													 (pCurWave^.pInfo^.pFormat^.wf.nBlockAlign * pCurWave^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel);
							dwAdded := GlobalSize(hClip);
							if pCurWave^.pData^.hData <> 0 then begin
								GlobalUnlock(pCurWave^.pData^.hData);
								pCurWave^.pData^.hData := GlobalReAlloc(pCurWave^.pData^.hData,
																												pCurWave^.pData^.dwDatasize - dwRemoved + dwAdded, 0);
								pCurWave^.pData^.pData := GlobalLock(pCurWave^.pData^.hData);
							end else begin
								pCurWave^.pData^.hData := GlobalAlloc(GMEM_MOVEABLE,
																											pCurWave^.pData^.dwDatasize - dwRemoved + dwAdded);
								pCurWave^.pData^.pData := GlobalLock(pCurWave^.pData^.hData);
							end;
							hData := GlobalAlloc(GMEM_MOVEABLE, pCurWave^.pData^.dwDatasize - dwTo);
							pData := GlobalLock(hData);
							MemoryRead(pCurWave^.pData^.pData, dwFrom + dwRemoved, pData, pCurWave^.pData^.dwDatasize - dwTo);
							MemoryWrite(pCurWave^.pData^.pData, dwFrom + dwAdded, pData, pCurWave^.pData^.dwDatasize - dwTo);
							GlobalUnlock(hData);
							GlobalFree(hData);
							pCurWave^.pInfo^.dwDatasize := pCurWave^.pData^.dwDatasize - dwRemoved + dwAdded;
							pCurWave^.pData^.dwDatasize := pCurWave^.pData^.dwDatasize - dwRemoved + dwAdded;
							pCurWave^.bModify := TRUE;
							MemoryWrite(pCurWave^.pData^.pData, dwFrom, pClip, dwAdded);
							UpdatePoints(Dialog, pWaves, dwMaxSize, dwTotSize, dwSamplePerPixel, nScrollDiv);
							nFrom := dwFrom DIV
										(pWaveTo^.pInfo^.pFormat^.wf.nBlockAlign * pWaveTo^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel) - 1;
							dwTo := dwFrom + dwAdded;
							nTo := dwTo DIV
										(pWaveTo^.pInfo^.pFormat^.wf.nBlockAlign * pWaveTo^.pInfo^.pFormat^.wf.nChannels * dwSamplePerPixel) - 1;
							InvalidateRect(GetDlgItem(Dialog, 103), nil, TRUE);
						end else begin
							MessageBeep(WORD(-1));
						end;
						GlobalUnlock(hClip);
					end;

				206 :
					begin
					end;

				6000 :
					begin

						{ Stop SubClassing de Ctl 101 pour recevoir les WM_xSCROLL }
						SetWindowLong(GetDlgItem(Dialog, 103), GWL_WNDPROC, LongInt(lpOldSubClsProc));
						//FreeProcInstance(lpSubClsProc);
						KillTimer(Dialog, 1);

						tLecon := tOldLecon;

						pCurWave := pWaves;
						while pCurWave <> nil do begin

							pNextWave := pCurWave^.pNext;

							DisposeWave(Dialog, dwSamplePerPixel, pCurWave);

							pCurWave := pNextWave;
						end;
						pWaves := nil;

						EndDialog(Dialog, -1);
						WavEditProc := TRUE;
						Exit;
					end;

			end;

		end;
	end;
	WavEditProc := False;
end;

end.
