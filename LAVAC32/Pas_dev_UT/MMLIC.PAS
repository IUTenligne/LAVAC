{*-----------------------------------------------------------------------
|	MMLIC.DLL
|
|	Adds 3d effects to Windows controls
|
|	See MMLIC.doc for info
|
-----------------------------------------------------------------------*}
UNIT MMLIC;

INTERFACE

USES Windows, licData;

function licRequest(hWin : HWND; pszPath : PChar) : Bool;
function licGetNumStud(hWin : HWND; pszPath : PChar) : integer;
function licVerify(hWin : HWND; pszPath : PChar) : Bool;
function licGetCode(hWin : HWND; pszPath : PChar; n : integer) : PChar;
function licGetText(hWin : HWND; pszPath : PChar) : PChar;
function licFormatText(hWin : HWND; pszPath, pszCot, pszSep : PChar) : PChar;
function licSetLang(szLang : PCHAR) : PCHAR;
procedure licSetType(nType : TAPPTYPE);
procedure licSetNum(nNum : integer);
function licEnum(EnumProc : TENUMPROC; pszPath : PChar) : integer;
function licGetPCCode(hWin : HWND; pszPath : PChar; n : integer) : PChar;

IMPLEMENTATION

function licRequest(hWin : HWND; pszPath : PChar) : Bool;		external 'licence' index 1;
function licGetNumStud(hWin : HWND; pszPath : PChar) : integer;	external 'licence' index 2;
function licVerify(hWin : HWND; pszPath : PChar) : Bool; 		external 'licence' index 3;
function licGetCode(hWin : HWND; pszPath : PChar; n : integer) : PChar;		external 'licence' index 4;
function licGetText(hWin : HWND; pszPath : PChar) : PChar;		external 'licence' index 5;
function licFormatText(hWin : HWND; pszPath, pszCot, pszSep : PChar) : PChar;	external 'licence' index 6;
function licSetLang(szLang : PCHAR) : PChar;		external 'licence' index 7;
procedure licSetType(nType : TAPPTYPE);		external 'licence' index 10;
procedure licSetNum(nNum : integer);		external 'licence' index 11;
function licEnum(EnumProc : TENUMPROC; pszPath : PChar) : integer;		external 'licence' index 13;
function licGetPCCode(hWin : HWND; pszPath : PChar; n : integer) : PChar;		external 'licence' index 14;

end.
