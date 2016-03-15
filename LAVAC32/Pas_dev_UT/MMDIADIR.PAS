{************************************************}
{                                                }
{   Unité MMDIADIR                                }
{                                                }
{   Projet LAVAC                                 }
{                                                }
{  (c) 1992-94 C Puissance 3 Informatique        }
{              MORGAN MULTIMEDIA                 }
{                                                }
{  par Guillaume de Bailliencourt                }
{                                                }
{  10/05/1994                                    }
{                                                }
{************************************************}

unit MMDIADIR;

INTERFACE

USES Windows;

CONST	UM_DDSTART  	= WM_USER + 300; { tell to client start OK, chat is now possible }
			UM_DDSTOP   	= WM_USER + 301; { tell to client stop OK, no more chat now }
			UM_DDREQCHAT	= WM_USER + 302; { tell to client chat is requested }
			UM_DDACKCHAT	= WM_USER + 303; { tell to server ready to chat acknoledgement}
			UM_DDENDCHAT	= WM_USER + 304; { tell to client chat is just finished }

function ddStart(hWin : HWND) : THANDLE; far;
procedure ddStop(hDial : THANDLE); far;
procedure InitEtudiant(hDial : THANDLE; lpszNo : PCHAR); far;
procedure FinEtudiant; far;
procedure ddChatWith(hDial : THANDLE; lpszNo, lpszName : PChar); far;
function ddIsChating(hDial : THANDLE) : BOOL; far;

IMPLEMENTATION

function ddStart(hWin : HWND) : THANDLE; begin end;
procedure ddStop(hDial : THANDLE); begin end;
procedure InitEtudiant(hDial : THANDLE; lpszNo : PCHAR); begin end;
procedure FinEtudiant; begin end;
procedure ddChatWith(hDial : THANDLE; lpszNo, lpszName : PCHAR); begin end;
function ddIsChating(hDial : THANDLE) : BOOL; begin end;

end.
