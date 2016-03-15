{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{                                                }
{   Unité UQcmWin                                }
{                                                }
{   Projet LAVAC                                 }
{                                                }
{  (c) 1992-94 C Puissance 3 Informatique        }
{              MORGAN MULTIMEDIA                 }
{                                                }
{  par Stéphane SAUREL                           }
{                                                }
{  23/03/1994                                    }
{                                                }
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{ Cette unité contient les objects qui héritent de TWindow est qui sont   }
{ utilisés dans la fenêtre "Propositions de réponses". Il s'agit donc des }
{ fenêtre réponses et leurs ancêtres communs.                             }
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}


UNIT UQcmWin;

{$IFOPT A+}
	 {A-}
	{$DEFINE _ALIGN_ON}
{$ENDIF}
{+R+}

INTERFACE

USES WinTypes, WinProcs, Win31, mmSystem,
		 WinCrt, WinDos, Strings, {BWCC,}                        {Windows}
		 Objects, OWindows, ODialogs, Ole, ShellApi,   {OWL(ShellApi : pour OLE)}
		 mmLavac, mmString, UqcmType, uQcmRep,                 {Lavac et QCM}
		 MCIWnd,
		 mmMci, mmFile, UTutDlg, CommDlg, Ctl3D, mmDib, mmDrwDib, RichEdit{,
		 FontUtil}
		 {$IFDEF _DEBUG}
		 ,MMDEBUG
		 {$ENDIF};
CONST

		UM_NOTIFY				= WM_USER + 1000;
		UM_CTLCOLOR			= WM_USER + 1001;
		UM_MOVETO				= WM_USER + 1002;
		MT_FIRST				= 1;
		MT_LAST					= 2;
		MT_NEXT					= 3;
		MT_PREVIOUS			= 4;
		RESETDUMMYPROC	= WORD(-1);

TYPE

		PAppClient = ^TAppClient;
		PAppStream = ^TAppStream;
		PMoveWindow = ^TMoveWindow;

		{Fenêtre contenant tous les objets réponses }
		PQcmWin = ^TQcmWin;
		TQcmWin = Object(TWindow)
						bCreateMode  : Boolean;
						bChangeZOrder: Boolean;
						bSizable		 : Boolean;
						bGrid				 : Boolean;
						bModif			 : Boolean;
						bRepeatQ     : Boolean;
						bAllForTrue  : Boolean;
						bPlaying     : Boolean;
						bAutoSel     : Boolean;
						bSmartResult : Boolean;
						bKeepAnswer  : Boolean;
						bShowBar		 : Boolean;
						bOn20				 : Boolean;
						szVersion		 : Array[0..15] of char;
						wMode        : Word;
						nbRep, nRepSon, nTemps, nTime, nNiveauPlay, nLastPlay : Integer;
						nMaxi,
						nMini,
						{nQuestions,}
						nIdQuest,
						nNoElev : Integer;
						nColonne     : Integer;
						nLigne       : Integer;
						nColorLine   : LongInt;
						HWndParent   : HWnd;
						HWndLigne    : HWnd;
						HWndLTime    : HWnd; {Handle du borshade pour echelle de temps}
            HCursorHand  : HCursor;
{						szNomFichier : PChar;}
						szLineTexte  : Array[0..511] Of Char;
						szFichierQ,
						szLessonRet  : szLongName;
						ClientDoc    : LHClientDoc;
						lpReponse    : PMoveWindow;
						lpCollecSon  : PCollection; {collection des réponses son : ordre
																				 de lecture}
						lpColBranch  : PCollection; {collection des réponses hors images}
						lpRepCollection : PRepCollection; {Collection des réponses de l'élève}
						pLstLessonCalled : PCollection;{collection des leçons à brancher}
						szCoord      : Array[0..511] Of Char;
						Constructor Init(AParent : PWindow; APath : PChar; AMake :
															Word; AMere : HWnd);

						PROCEDURE DebugLessonCalled(psz : PCHAR);
						PROCEDURE Debug(psz : PCHAR);

						Procedure SetupWindow; Virtual;
						Procedure Enable(bFlag : BOOL); Virtual;
						Function  GetClassName : PChar; Virtual;
						Procedure GetWindowClass(Var AWindowClass : TWndClass);Virtual;
						PROCEDURE Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct); virtual;
						PROCEDURE WMEraseBkGnd(Var Msg : TMessage);virtual WM_EraseBkGnd;
						Procedure WMPalChanged(Var Msg : TMessage);Virtual WM_PALETTECHANGED;
						Procedure WMQueryNewPal(Var Msg : TMessage);Virtual WM_QUERYNEWPALETTE;
						Function  HasABitmap   : Boolean;
						procedure CopyLinkedFiles(PathFrom : szLongName; nItem : integer);
						Procedure WMSize(Var Msg : TMessage); Virtual WM_SIZE;
						Procedure WMSetCursor(Var Msg : TMessage);Virtual WM_FIRST+WM_SETCURSOR;
						Procedure WMLButtonDown(Var Msg : TMessage); Virtual WM_LBUTTONDOWN;
						Procedure WMTimer(Var Msg : TMessage);Virtual WM_TIMER;
						Procedure GetMaxXY(Var APoint : TPoint);
						Procedure UMMoveChild(Var Msg : TMessage); Virtual UM_MOVECHILD;
						Procedure CreerRep(AType : Word; ATexte : PChar);
						Function  GetInsertObjet(Var AServeur : szLongName) : Integer;
						Function  GetPrendreObjet(Var AServeur : szLongName) : Integer;
						Procedure UMSuppr(Var Msg : TMessage); Virtual UM_SUPPR;
						Procedure Supprimer(P : PMoveWindow);
						Procedure UMOptions(Var Msg : TMessage); Virtual UM_SETOPTIONS;
						Procedure SelectWindow(lpWindow : PMoveWindow);
						Procedure UMChangePos(Var Msg : TMessage); Virtual UM_CHANGEPOS;
						Procedure UMLoadQcm(Var Msg : TMessage); Virtual UM_LOADQCM;
						Procedure UMSaveQcm(Var Msg : TMessage); Virtual UM_SAVEQCM;
						Procedure UMMakeDummy(Var Msg : TMessage); Virtual UM_MakeDummy;
						Procedure UMMakeHyperLink(Var Msg : TMessage); Virtual UM_MakeHyperLink;
						Procedure UMMakeClipWin(Var Msg : TMessage); Virtual UM_MakeClipWin;
						Procedure UpdateLineTexte(AnIndex : Integer);
						Procedure SetSoundOrder;
						Procedure UMPlayQcm(Var Msg : TMessage);Virtual UM_PLAYQCM;
						Procedure SetQcmCheck;
						Procedure SetReponsesElev;
						Procedure GetMinMaxPoints(Var TheMin : Integer;Var TheMax : Integer);
						Procedure UMSuite(Var Msg : TMessage); Virtual UM_SUITE;
						Procedure AnalyseQcm;
						Procedure AppelLecon;
						Procedure UMResetSel(Var Msg : TMessage);Virtual UM_RESETSEL;
						Procedure UMRetour(Var Msg : TMessage);Virtual UM_RETOUR;
						Procedure ClearDocument;
						Procedure UpdateDocument;
						Procedure DoneDocument;
						Procedure DummyValidate;
						Procedure PosValidate;
						Procedure ColBranchValidate;
						Procedure CollecSonValidate;
						Procedure OleValidate;
						Procedure ErrorMessage(AWindow : HWnd; IdMessage : Word);
						Function  CanClose : Boolean; Virtual;
						Destructor Done; Virtual;
						End;

		TAppClient = Record
							 OleClient : TOleClient;
							 ObjectWindow : PMoveWindow;
							 End;

		TAppStream = Record
							 OleStream : TOleStream;
							 OwlStream : PStream;
							 End;

		TQcmFileHeader = Array [0..7] Of Char;

		{ Fenêtre ancêtre de tous les éléments composant les réponses :
		dispose des fonction de déplacement et resizing }
		TMoveWindow = Object(TWindow)
								szLinkedFile : szLongName;
								bCreateFromFile,
								bQueryBounds,
								bLoadSound,
								bBorder, bLoaded : Boolean;
								wTypeRep : Word;
								nOrder : Integer;
								AppClient : TAppClient;
								lpParentWin : PQcmWin;
								OleObject : POleObject;
								Constructor Init(AParent : PQcmWin; Atexte : PChar; AX, AY : Integer);
								Constructor Load(Var S : TStream);
								Function  OleSaveToFile(FileName : PChar) : Integer;
								Procedure OleAlign; Virtual;
								Procedure SetupWindow; Virtual;
								Function  GetClassName : PChar; Virtual;
								Procedure GetWindowClass(Var AWindowClass : TWndClass);Virtual;
								Procedure Store(Var S : TStream); Virtual ;
								Procedure OleError(pszErrTitle : PChar; OleStatus : TOleStatus);
								function  Check(pszErrTitle : Pchar; OleStatus : TOleStatus) : TOleStatus;
								Procedure Update;
								Function  InitOleObject : Boolean;
								Procedure OpenObject(wVerb : Word);
								Procedure CloseObject;
								procedure Delete;
								PROCEDURE Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct); virtual;
								PROCEDURE ShowHandle(PaintDC : hDC); virtual;
								PROCEDURE UpdateHandle; virtual;
								Procedure WMEraseBkGnd(Var Msg : TMessage); virtual WM_ERASEBKGND;
								Procedure WMActivate(Var Msg : TMessage);Virtual WM_FIRST+WM_ACTIVATE;
								Procedure WMNCHitTest(Var Msg : TMessage);Virtual WM_FIRST+WM_NCHITTEST;
								Procedure WMNCLButtonDown(Var Msg : TMessage); Virtual WM_FIRST + WM_NCLBUTTONDOWN;
								Procedure WMNCMouseMove(Var Msg : TMessage); Virtual WM_FIRST + WM_NCMOUSEMOVE;
								Procedure WMNCLButtonUp(Var Msg : TMessage); Virtual WM_FIRST + WM_NCLBUTTONUP;
								Procedure WMNCLButtonDblClk(Var Msg : TMessage); Virtual WM_NCLBUTTONDBLCLK;
								Procedure WMGetMinMaxInfo(Var Msg : TMessage); Virtual WM_FIRST + WM_GETMINMAXINFO;
								Procedure WMLButtonDown(Var Msg : TMessage); Virtual WM_FIRST + WM_LBUTTONDOWN;
								Procedure WMMove(Var Msg : TMessage); Virtual WM_FIRST + WM_MOVE;
								Procedure WMWindowPosChanging(Var Msg : TMessage);Virtual WM_WINDOWPOSCHANGING;
								Procedure WMSize(Var Msg : TMessage); Virtual WM_FIRST + WM_SIZE;
								Procedure UMSaveToFile(Var Msg : TMessage); Virtual UM_SAVETOFILE;
								Procedure UMOleValidate(Var Msg : TMessage); Virtual UM_OLEVALIDATE;
								Procedure BringToFront;
								Procedure GetBounds(Var r : TRect);
								Procedure SetBounds(Var rNew : TRect);
								Procedure SetTypeRep; Virtual;
								Procedure SetLineTexte; Virtual;
								Destructor Done; Virtual;
								End;

type

		{ CheckBox dont toute la gestion est renvoyée à la fenêtre parent}
		PQcmStatic = ^TQcmStatic;
		TQcmStatic = Object(TStatic)
							constructor Init(AParent: PWindowsObject; AnID: Integer; ATitle: PChar; X,Y,W,H: Integer;
																ATextLen: word);
							constructor Load(var S: TStream);
							procedure Store(var S: TStream); virtual;
							Procedure DblClick(Var Msg : TMessage);Virtual wm_LButtonDBLCLK;
							Procedure WMMouseMove(Var Msg : TMessage); Virtual WM_FIRST + WM_MOUSEMOVE;
							Procedure WMLButtonUp(Var Msg : TMessage); Virtual WM_LBUTTONUP;
							Procedure WMLButtonDown(Var Msg : TMessage); Virtual WM_LBUTTONDOWN;
							End;

		{ Fenêtre avec les procedure des gestion des réponses}
		PReponseWin = ^TReponseWin;
		TReponseWin = Object(TMoveWindow)
								hFnt      : HFONT;
								hLogFnt   : TLogFont;
								FrColRef  : TColorRef;
								BkColRef  : TColorRef;
								hBkBrush  : HBRUSH;
								lpCtl			: PControl;
								bAutoRet,
								bTrig,
								bChecked,
								bCheckVisible,
								bChkChange,
								bCurseurMain    : Boolean;
								nValeur,
								nOrdBranch      : Integer;
								szLessonToCall  : szLongName;
								lpszScript			: PCHAR;
								lpSelSeqInLessonToCall : PStrCollection;
								Constructor Init(AParent : PQcmWin; ATexte : PChar; AX, AY : Integer);
								constructor Load(var S: TStream);
								procedure 	Store(var S: TStream); virtual;
								Procedure   SetupWindow; Virtual;
								Function    GetClassName : PChar; Virtual;
								Procedure   GetWindowClass(Var AWindowClass : TWndClass);Virtual;
								Procedure   Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct); Virtual;
								Procedure   SetCheck(CheckFlag : Word);
								Function    GetCheck : Word; Virtual;
								Procedure   SetLineTexte; Virtual;
								procedure		WMCtlColor(Var Msg : TMessage); virtual WM_CTLCOLOR;
								Procedure   WMLButtonDown(Var Msg : TMessage); Virtual WM_LBUTTONDOWN;
								Procedure   WMLButtonUp(Var Msg : TMessage); Virtual WM_FIRST + WM_LBUTTONUP;
								Procedure   WMLButtonDblClk(Var Msg : TMessage); Virtual WM_LBUTTONDBLCLK;
								Procedure   WMSetCursor(Var Msg : TMessage);Virtual WM_FIRST+WM_SETCURSOR;
								Procedure   WMActivate( var Msg: TMessage); virtual wm_First +wm_Activate;
								Procedure   UpdateBrOrder(SelfOrder : Integer);
								Destructor  Done; Virtual;
								End;

		PDummyReponseWin = ^TDummyReponseWin;
		TDummyReponseWin = Object(TReponseWin)
											 end;

		{ Fenêtre utilisée comme zone sensible sur une Bitmap}
		PRepClipWin = ^TRepClipWin;
		TRepClipWin = Object(TReponseWin)
								Constructor Init(AParent : PQcmWin; AnId : Integer; Atexte : PChar; AX, AY : Integer);
								Constructor Load(Var S : TStream);
								Procedure SetupWindow; Virtual;
								Procedure Store(Var S : TSTream); Virtual;
								Function GetClassName : PChar; Virtual;
								Procedure GetWindowClass(Var AWindowClass : TWndClass); Virtual;
								Procedure Paint(PaintDC: hDC; Var PaintInfo : TPaintStruct); Virtual;
								Procedure WMSize(Var Msg : TMessage);Virtual WM_FIRST+WM_SIZE;
								Procedure SetTypeRep; Virtual;
								Procedure SetLineTexte; Virtual;
								Destructor Done; Virtual;
								End;

		{ Fenêtre avec bouton son et check box}
		PRepSonWin = ^TRepSonWin;
		TRepSonWin = Object(TReponseWin)
							 bRepeatSon : Boolean;
							 szTexte : Array[0..255] Of Char;
							 lpButton : pButton;
							 lpQcmStatic : PQcmStatic;
							 Constructor Init(AParent : PQcmWin; ATexte : PChar; AX, AY : Integer);
							 Constructor Load(Var S : TStream);
							 Procedure Store(Var S : TStream); Virtual;
							 Procedure SetupWindow; Virtual;
							 Function GetClassName : PChar; Virtual;
							 Procedure Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct); Virtual;
							 Procedure WMSize(Var Msg : TMessage); Virtual WM_Size;
							 Procedure WMLButtonDblClk(Var Msg : TMessage);Virtual WM_LBUTTONDBLCLK;
							 Procedure UpdateOrder(SelfOrder : Integer; ChangeVal : Boolean);
							 Procedure JouerSon(Var Msg : TMessage); Virtual ID_FIRST + IDB_JOUERSON;
							 Procedure SetTypeRep; Virtual;
							 Procedure SetLineTexte; Virtual;
							 Destructor Done; Virtual;
							 End;

		PDummyRepSonWin = ^TDummyRepSonWin;
		TDummyRepSonWin = Object(TRepSonWin)
											end;

		{ Fenêtre trou }
		PHole = ^THole;
		THole = Object(TReponseWin)
								Constructor Init(AParent : PQcmWin; Atexte : PChar; AX, AY : Integer);
								Constructor Load(Var S : TStream);
								Procedure SetupWindow; Virtual;
								Procedure Store(Var S : TSTream); Virtual;
								Function GetClassName : PChar; Virtual;
								Procedure SetTypeRep; Virtual;
								Procedure SetLineTexte; Virtual;
								Destructor Done; Virtual;
								End;

		{ Fenêtre MCI }
		PMCIWin = ^TMCIWin;
		TMCIWin = Object(TReponseWin)
								hMCIWin : HWND;
								Constructor Init(AParent : PQcmWin; Atexte : PChar; AX, AY : Integer);
								Constructor Load(Var S : TStream);
								Procedure SetupWindow; Virtual;
								Procedure WMSize(Var Msg : TMessage); Virtual WM_SIZE;
								Procedure Store(Var S : TSTream); Virtual;
								Function GetClassName : PChar; Virtual;
								Procedure SetTypeRep; Virtual;
								Procedure SetLineTexte; Virtual;
								Procedure procMAKEMCIWIN(Var Msg : TMessage); Virtual UM_MAKEMCIWIN;
								Procedure procMCIWNDM_NOTIFYSIZE(Var Msg : TMessage);Virtual MCIWNDM_NOTIFYSIZE;
								Destructor Done; Virtual;
								End;

		{ Edit pour TRepTexteWin avec seulement la ScrollBar Verticale }
		PDummy 	= ^TDummy;
		PDummyRec	= ^TDummyRec;
		TDummyRec	= record
								rc					: TRECT;
								rc2					: TRECT;
								rc3					: TRECT;
								rcParent		: TRECT;
								nFirstLine	: integer;
								nLastLine		: integer;
								s,
								e,
								nHeight			: integer;
								szDummyID		: array[0..255] of char;
								lpDummy			: PDummy;
							end;

		TDummy	= Object(THole)
								szID			: array[0..255] of char;
								szText		: array[0..255] of char;
								lpAnswers	: PStrCollection;
								bValid		: BOOL;
								constructor Init(AParent : PQcmWin; pID, pText : PChar);
								constructor Load(var S: TStream);
								procedure 	Store(var S: TStream); virtual;
								destructor 	Done; Virtual;
								Procedure   SetTypeRep; Virtual;
								Procedure		SetLineTexte; Virtual;
								Function    GetCheck : Word; Virtual;
								procedure 	WMLButtonDblClk(Var Msg : TMessage); virtual WM_FIRST + WM_LButtonDblClk;
							End;

		PHyperLink 	= ^THyperLink;
		THyperLink	= Object(TDummy)
								constructor Init(AParent : PQcmWin; pID, pText : PChar);
								constructor Load(var S: TStream);
								procedure 	Store(var S: TStream); virtual;
								destructor 	Done; Virtual;
								Procedure   SetTypeRep; Virtual;
								Procedure		SetLineTexte; Virtual;
								Function    GetCheck : Word; Virtual;
								{Procedure   WMLButtonDown(Var Msg : TMessage); Virtual WM_LBUTTONDOWN;}
								procedure 	WMLButtonDblClk(Var Msg : TMessage); virtual WM_FIRST + WM_LButtonDblClk;
							End;

		PDummies 	= ^TDummies;
		TDummies	= Object(TCollection)
								constructor Init(ALimit, ADelta: Integer);
								constructor Load(var S: TStream);
								procedure Store(var S: TStream); virtual;
								destructor Done; Virtual;
								End;


		PEditDummy = ^TEditDummy;
		TEditDummy = Object(TEdit)
								 CurDummy : TDummyRec;
								 Constructor Init(AParent : PMoveWindow; Dummy : TDummyRec);
								 Procedure WMKILLFOCUS(Var Msg : TMessage);Virtual WM_FIRST + WM_KILLFOCUS;
								 Procedure WMKeyDown(Var Msg : TMessage);Virtual WM_FIRST+WM_KeyDown;
								 Procedure WMChar(Var Msg : TMessage);Virtual WM_FIRST+WM_CHAR;
								 End;

		TEnumDummyProc = function(hWin : HWND; Dummy : TDummyRec; wParam : WORD; lParam : DWORD) : Boolean;

		PEditTexte = ^TEditTexte;
		TEditTexte = Object(TEdit)
							 {lpDummies	: PDummies;}
							 Constructor Init(AParent : PMoveWindow; AnId : Integer; ATexte  : PChar;
													 X, Y, W, H, ATextLen : Integer; Multiline : Boolean);
							 constructor Load(var S: TStream);
							 procedure Store(var S: TStream); virtual;
							 Destructor Done; Virtual;
							 Procedure SetupWindow; Virtual;
							 Function  GetClassName : PChar;Virtual;
							 Procedure ProcessScroll;
							 function IsDummyHere(lpDummy : PDummy) : Boolean;
							 Procedure NewDummy;
							 Procedure NewHyperLink;
							 Procedure RemoveDummy(lpDummy : PDummy);
							 Procedure CreateEditDummy(Dummy : TDummyRec);
							 Procedure EnumDummy(EnumDummyProc : TEnumDummyProc; wParam : WORD; lParam : DWORD; var DummyRet : TDummyRec);
							 Procedure Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct); Virtual;
							 Procedure WMNCHitTest(Var Msg : TMessage);Virtual WM_FIRST+WM_NCHITTEST;
							 Procedure WMPAINT(Var Msg : TMessage);Virtual WM_FIRST+WM_PAINT;
							 Procedure UMNotify(Var Msg : TMessage);Virtual UM_NOTIFY;
							 Procedure WMVSCROLL(Var Msg : TMessage);Virtual WM_FIRST+WM_VSCROLL;
							 Procedure UMCTLCOLOR(Var Msg : TMessage);Virtual UM_CTLCOLOR;
							 Procedure UMMoveTo(Var Msg : TMessage);Virtual UM_MOVETO;
							 Procedure WMChar(Var Msg : TMessage);Virtual WM_FIRST+WM_CHAR;
							 Procedure WMSize(Var Msg : TMessage);Virtual WM_FIRST+WM_SIZE;
							 Procedure WMLButtonDown(Var Msg : TMessage); Virtual WM_FIRST + WM_LBUTTONDOWN;
							 Procedure WMLButtonUp(Var Msg : TMessage); Virtual WM_FIRST + WM_LBUTTONUP;
							 Procedure WMLButtonDblClk(Var Msg : TMessage);Virtual WM_FIRST+WM_LBUTTONDBLCLK;
							 Procedure WMSetCursor(Var Msg : TMessage);Virtual WM_FIRST+WM_SETCURSOR;
							 End;

		{ Fenêtre avec case à cocher et Edit multiligne}
		PRepTexteWin = ^TRepTexteWin;
		TRepTexteWin = Object(TReponseWin)
								 lpszTexte : PChar;
								 lpEdit : PEditTexte;
								 Constructor Init(Aparent : PQcmWin; Atexte : Pchar; AX, AY : Integer);
								 Constructor Load(Var S : TStream);
								 Procedure Store(Var S : TStream); Virtual;
								 Procedure LoadFileTxt(AFile : PChar);
								 Procedure SetupWindow; Virtual;
								 Procedure Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct);Virtual;
								 Procedure WMSize(Var Msg : TMessage); Virtual WM_Size;
								 procedure WMCtlColor(Var Msg : TMessage); virtual WM_CTLCOLOR;
								 Procedure WMLButtonDown(Var Msg : TMessage); Virtual WM_FIRST + WM_LBUTTONDOWN;
								 Procedure WMCommand(Var Msg : TMessage);Virtual WM_FIRST + WM_COMMAND;
								 Procedure SetTypeRep; Virtual;
								 Procedure SetLineTexte; Virtual;
								 Destructor Done; Virtual;
								 End;

		{ Fenêtre où s'affiche une image, peut être parent d'objets réponses}
		PBitmapWin = ^TBitmapWin;
		TBitmapWin = Object(TMoveWindow)
							 di	: TDIBINFO;
							 hdib	: THANDLE;
							 bTailleAdapt, bScroll : Boolean;
							 lpRepClip : PRepClipWin;
							 Constructor Init(AParent : PQcmWin; ATexte : PChar; AX, AY : Integer);
							 Constructor Load(Var S : TStream);
							 Procedure SetupWindow;Virtual;
							 Procedure Store(Var S : TStream); Virtual ;
							 Procedure WMWindowPosChanging(Var Msg : TMessage);Virtual WM_WINDOWPOSCHANGING;
							 Procedure WMSize(Var Msg : TMessage); Virtual WM_SIZE;
							 Procedure WMPalChanged(Var Msg : TMessage);Virtual WM_PALETTECHANGED;
							 Procedure WMQueryNewPal(Var Msg : TMessage);Virtual WM_QUERYNEWPALETTE;
							 Procedure Paint(dc : hDC; Var PaintInfo : TPaintStruct); Virtual;
							 Procedure WMLButtonDblClk(Var Msg : TMessage);Virtual WM_LBUTTONDBLCLK;
							 Procedure OleGetBounds(Var ARect : TRect);
							 Procedure SetScrollBar;
							 Procedure SetTypeRep; Virtual;
							 Procedure SetLineTexte; Virtual;
							 Destructor Done; Virtual;
							 End;

		PObjetWin  = ^TObjetWin;
		TObjetWin  = Object(TReponseWin)
							 nVerbs : Integer;
							 lpButton : array[0..3] of pButton;
							 Constructor Init(AParent : PQcmWin; ATexte : PChar; AX, AY, AVerbs : Integer;FromFile : Boolean);
							 Constructor Load(Var S : TStream);
							 Procedure   Store(Var S : TStream);Virtual;
							 Procedure SetupWindow;Virtual;
							 Procedure Play(wVerb : WORD); Virtual;
							 Procedure Play0(Var Msg : TMessage); Virtual ID_FIRST + 200;
							 Procedure Play1(Var Msg : TMessage); Virtual ID_FIRST + 201;
							 Procedure Play2(Var Msg : TMessage); Virtual ID_FIRST + 202;
							 Procedure Play3(Var Msg : TMessage); Virtual ID_FIRST + 203;
							 Procedure Paint(PaintDC : Hdc;Var PaintInfo : TPaintStruct);Virtual;
							 Procedure WMPalChanged(Var Msg : TMessage);Virtual WM_PALETTECHANGED;
							 Procedure WMQueryNewPal(Var Msg : TMessage);Virtual WM_QUERYNEWPALETTE;
							 Procedure SetTypeRep; Virtual;
							 Procedure SetLineTexte; Virtual;
							 Destructor Done;Virtual;
							 End;


CONST
		 NULLRECT  : TRECT =(left : 0; top : 0; right : 0; bottom : 0);
		 QcmFileHeader : TQcmFileHeader = 'QCM 4.30';

		 {Register types pour sauvegardes en flux}
		 RMoveWindow : TStreamRec =(
								 ObjType : 999;
								 VmtLink : Ofs(TypeOf(TMoveWindow)^);
								 Load  : @TMoveWindow.Load;
								 Store : @TMoveWindow.Store);
		 RBitmapWin : TStreamRec =(
								 ObjType : 998;
								 VmtLink : Ofs(TypeOf(TBitmapWin)^);
								 Load  : @TBitmapWin.Load;
								 Store : @TBitmapWin.Store);
		 RRepClipWin : TStreamRec =(
									 ObjType : 997;
									 VmtLink : Ofs(TypeOf(TRepClipWin)^);
									 Load : @TRepClipWin.Load;
									 Store : @TRepClipWin.Store);
		 RQcmStatic : TStreamRec =(
								 ObjType : 996;
								 VmtLink : Ofs(TypeOf(TQcmStatic)^);
								 Load : @TQcmStatic.Load;
								 Store : @TQcmStatic.Store);
		 RRepSonWin : TStreamRec =(
									ObjType : 995;
									VmtLink : Ofs(TypeOf(TRepSonWin)^);
									Load : @TRepSonWin.Load;
									Store : @TRepSonWin.Store);
		 REditTexte : TStreamRec =(
									ObjType : 994;
									VmtLink : Ofs(TypeOf(TEditTexte)^);
									Load : @TEditTexte.Load;
									Store : @TEditTexte.Store);
		 RRepTexteWin : TStreamRec =(
										ObjType : 993;
										VmtLink : Ofs(TypeOf(TRepTexteWin)^);
										Load : @TRepTexteWin.load;
										Store : @TRepTexteWin.Store);

		 RObjetWin    : TStreamRec =(
									ObjType : 988;
									VmtLink : Ofs(TypeOf(TObjetWin)^);
									Load  : @TObjetWin.Load;
									Store : @TObjetWin.Store);

		 RReponseWin  : TStreamRec =(
									ObjType : 987;
									VmtLink : Ofs(TypeOf(TReponseWin)^);
									Load  : @TReponseWin.Load;
									Store : @TReponseWin.Store);

		 RHole			  : TStreamRec =(
									ObjType : 1000;
									VmtLink : Ofs(TypeOf(THole)^);
									Load  : @THole.Load;
									Store : @THole.Store);

		 RDummy			  : TStreamRec =(
									ObjType : 1001;
									VmtLink : Ofs(TypeOf(TDummy)^);
									Load  : @TDummy.Load;
									Store : @TDummy.Store);

		 RDummies		  : TStreamRec =(
									ObjType : 1002;
									VmtLink : Ofs(TypeOf(TDummies)^);
									Load  : @TDummies.Load;
									Store : @TDummies.Store);

		 RHyperLink  : TStreamRec =(
									ObjType : 1003;
									VmtLink : Ofs(TypeOf(THyperLink)^);
									Load  : @THyperLink.Load;
									Store : @THyperLink.Store);

		 RMCIWin  : TStreamRec =(
									ObjType : 1004;
									VmtLink : Ofs(TypeOf(TMCIWin)^);
									Load  : @TMCIWin.Load;
									Store : @TMCIWin.Store);
CONST

		 {Register types pour sauvegardes en flux}
		 RStrCollec : TStreamRec =(
									ObjType : 992;
									VmtLink : Ofs(TypeOf(TStrCollection)^);
									Load : @TStrCollection.Load;
									Store : @TStrCollection.Store);

		 RReponseEl : TStreamRec =(
									ObjType : 991;
									VmtLink : Ofs(TypeOf(TReponseElev)^);
									Load : @TReponseElev.Load;
									Store : @TReponseElev.Store);

		 RProposition : TStreamRec =(
									ObjType : 990;
									VmtLink : Ofs(TypeOf(TProposition)^);
									Load : @TProposition.Load;
									Store : @TProposition.Store);

		 RRepCollec   : TStreamRec =(
									ObjType : 989;
									VmtLink : Ofs(TypeOf(TRepCollection)^);
									Load : @TRepCollection.Load;
									Store : @TRepCollection.Store);

VAR
	 nCXBorder, nCYBorder : Integer;
	 {DragPoint : TPoint;
	 DragRect  : TRect;}
	 PixPerInch : TPoint; {Résolution du DC écran}
	 MainQcmWin : PQcmWin;
	 OleClientVTbl : TOleClientVTbl;
	 OleStreamVTbl : TOleStreamVTbl;
	 CFOwnerLink, CFObjectLink, CFNative, CFPicture : Word;{Regitres presse papier}
	 WinToolsHandle : HWnd; {Handle de la fenêtre Wintools : acces nécessaire
													pour modifier l'état de ses boutons radio}

function ClientCallBack(Client: POleClient; Notification: TOle_Notification;
												OleObject: POleObject): Integer; export;

procedure InvalidateRect(Wnd: HWnd; Rect: PRect; Erase: Bool);

IMPLEMENTATION

{************************************************************************}
{**    SE : Fait le lien avec l'appel par OleClient.DLL avec l'objet   **}
{**         Ole de l'application client.                               **}
{**    SI : Applelle ObjectWindow (= PMoveWindow) Changed.             **}
{************************************************************************}

function ClientCallBack(Client: POleClient; Notification: TOle_Notification;
												OleObject: POleObject): Integer;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+1, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	ClientCallBack := integer(FALSE);

	case Notification of
		OLE_CLOSED:     {Server closed for an embedded object.}
			begin
				PAppClient(Client)^.ObjectWindow^.bQueryBounds := FALSE;
				PostMessage(PAppClient(Client)^.ObjectWindow^.HWindow, UM_OLEVALIDATE, 0, 0);
				MainQcmWin^.Enable(TRUE);
			end;

		OLE_CHANGED,
		OLE_RENAMED,   {Server renamed a link file.}
		OLE_SAVED :
			with PAppClient(Client)^.ObjectWindow^ do begin
				if bQueryBounds then begin
					OleAlign;
				end;
				PostMessage(HWindow, UM_SAVETOFILE, 0, 0);
			end;

		OLE_RELEASE:
			begin
			end;

		OLE_QUERY_RETRY:
			begin
			end;

		OLE_QUERY_PAINT:
			begin
				ClientCallBack := integer(TRUE);
			end;
	end;
end;

procedure InvalidateRect(Wnd: HWnd; Rect: PRect; Erase: Bool);
{var szCaption : array[0..255] of char;}
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+2, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	{GetWindowText(Wnd, szCaption, SizeOf(szCaption));
	WriteLn(szCaption, ' ', LongInt(Rect), ' ', Erase);
	if GetParent(Wnd) <> MainQcmWin^.HWindow then begin
	MessageBeep(WORD(-1));
	end;}

	{if IsWindow(Wnd) then }WinProcs.InvalidateRect(Wnd, Rect, Erase);
end;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
---------------------------------TQcmWin------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

CONSTRUCTOR TQcmWin.Init(AParent : PWindow; APath : PChar; AMake : Word; AMere : HWnd);
VAR
   wrect : TRect;
	 DC : hDC;
BEGIN
		 Inherited Init(AParent, 'Espace QCM');
		 HwndParent := AMere;
{     szNomFichier := StrNew(APath);}
		 wMode := AMake;
		 bModif := FALSE;
		 bGrid := TRUE;
		 bChangeZOrder := FALSE;
		 bSizable := FALSE;
		 bRepeatQ := TRUE;
		 bAllForTrue := TRUE;
     bPlaying := FALSE;
		 bAutoSel := FALSE;
		 bSmartResult := FALSE;
		 gbSmartResult := bSmartResult;
		 bKeepAnswer  := FALSE;
		 bShowBar			:= TRUE;
		 bOn20			:= FALSE;
		 GetClientRect(HWndParent, wrect);
     {Dimension de la zone client de la fenêtre parent}
     With Attr Do With wrect Do
          Begin
					Style := WS_CHILD Or WS_VISIBLE {OR WS_CLIPCHILDREN};
					x := 0;
          y := 0;
					w := Right;
          {LINE_HIGH = hauteur de la ligne de statut}
					H := Bottom;
          End;
     nbrep    := 0;
     nRepSon  := 0;
		 nColorLine := 0;
		 nTemps   := -1;
     nTime    := 0;
		 nColonne := PAS_GRILLE;
		 nLigne   := PAS_GRILLE;

		 OleRegisterClientDoc('Lavac', 'Tuteur', 0, ClientDoc);
		 MainQcmWin := @Self;
		 lpReponse := Nil;
     {Initialisation de la résolution de l'écran}
		 DC := GetDC(HWndParent);
		 PixPerInch.X := GetDeviceCaps(DC, LogPixelSX);
		 PixPerInch.Y := GetDeviceCaps(DC, LogPixelSY);
		 ReleaseDC(HWndParent, DC);
		 StrCopy(szLineTexte, '');
		 StrCopy(szFichierQ, '');
		 StrCopy(szCoord, '');
		 lpCollecSon := New(PCollection, Init(10, 5));
		 lpColBranch := New(PCollection, Init(10, 5));
		 lpRepCollection := New(PRepCollection, Init(10, 5));
		 pLstLessonCalled := New(PCollection, Init(10, 5));
		 Scroller := New(PScroller, Init(@Self, 15, 15, 1000, 1000));
		 HCursorHand := LoadCursor(hInstRes, 'CURSEUR_MAIN');
END;

PROCEDURE TQcmWin.SetupWindow;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+3, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited SetupWindow;
		 SetTimer(HWindow, ID_TIMER, 1000, Nil);
		 SetScrollPos(HWindow, SB_HORZ, 0, FALSE);
		 SetScrollPos(HWindow, SB_VERT, 0, FALSE);
END;

PROCEDURE TQcmWin.Enable(bFlag : BOOL);
var hWin,
		hChild : HWND;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+4, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	EnableWindow(window, bFlag);
	hWin := GetWindow(GetParent(HWindow), GW_CHILD);
	while hWin <> 0 do begin
		EnableWindow(hWin, bFlag);
		hChild := GetWindow(hWin, GW_CHILD);
		while hChild <> 0 do begin
			EnableWindow(hChild, bFlag);
			hChild := GetWindow(hChild, GW_HWNDNEXT);
		end;
		hWin := GetWindow(hWin, GW_HWNDNEXT);
	end;
END;

FUNCTION TQcmWin.GetClassName : PChar;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+5, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 GetClassName := 'CQcmWin';
END;

PROCEDURE TQcmWin.GetWindowClass(Var AWindowClass : TWndClass);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+6, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TWindow.GetWindowClass(AWindowClass);
		 With AWindowClass Do	Begin
				hBrBackground := GetStockObject(LTGRAY_BRUSH){COLOR_BACKGROUND + 1};
		 End;
END;

PROCEDURE TQcmWin.Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+7, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 Inherited Paint(PaintDC, PaintInfo);
	 If wMode <> M_MAKE Then PostMessage(hQCMProc, WM_PAINT, 0, 0);
END;

PROCEDURE TQcmWin.WMEraseBkGnd(Var Msg : TMessage);{WM_EraseBkGnd}
var dc : HDC;
		r  : TRECT;
		x,y : integer;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+8, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	DefWndProc(Msg);
	If wMode <> M_MAKE Then exit;

	dc := HDC(Msg.wParam);
	GetWindowRect(HWindow, r);
	MapWindowPoints(0, HWindow, r, 2);
	y := r.top;
	while y <= r.bottom do begin
		x := r.left;
		while x <= r.right do begin
			MoveTo(dc, x, y);
			LineTo(dc, x + 1, y + 1);
			inc(x, PAS_GRILLE);
		end;
		inc(y, PAS_GRILLE);
	end;
	Msg.Result := -1;
end;

PROCEDURE TQcmWin.WMPalChanged(Var Msg : TMessage);
					Procedure SendMess(P : PMoveWindow);Far;
					Begin

						if (P^.wTypeRep = CT_BITMAP) then begin
							if PBitmapWin(P)^.di.hdd <> 0 then SendMessage(P^.HWindow, Msg.Message, Msg.wParam, Msg.lParam);
						end;
						if (P^.wTypeRep = CT_AUTRE) then begin
							SendMessage(P^.HWindow, Msg.Message, Msg.wParam, Msg.lParam);
						end;
					End;
BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+9, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 { envoie à tous les enfants }
	 ForEach(@SendMess);
END;

PROCEDURE TQcmWin.WMQueryNewPal(Var Msg : TMessage);
var pFirst : PMoveWindow;

				 function Scan(P : PMoveWindow): boolean ;Far;
				 Begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+10, 0, 0, 0, nil, TRUE);
	{$ENDIF}

							Scan := P^.wTypeRep = CT_BITMAP;
				 End;

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+11, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	{ envoie a l'enfant qui à le focus }
	pFirst := PMoveWindow(FirstThat(@Scan));
	if (pFirst <> nil) AND
		 (PBitmapWin(pFirst)^.di.hdd <> 0) then begin
		SendMessage(pFirst^.HWindow, Msg.Message, Msg.wParam, Msg.lParam);
	end;
END;

FUNCTION TQcmWin.HasABitmap : Boolean;

				 Procedure Scanrep(P : PMoveWindow);Far;
				 Begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+12, 0, 0, 0, nil, TRUE);
	{$ENDIF}

							If P^.wTypeRep = CT_BITMAP THEN HasABitMap := TRUE;
				 End;

BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+13, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 HasABitmap := FALSE;
		 ForEach(@ScanRep);
end;

procedure TQcmWin.CopyLinkedFiles(PathFrom : szLongName; nItem : integer);

				 Procedure CopyLinkedFile(P : PMoveWindow);Far;
				 var
						szPathFile : array[0..255] of char;
						Dir				: array[0..fsDirectory] of Char;
						Name			: array[0..fsFileName] of Char;
						Ext				: array[0..fsExtension] of Char;
				 Begin

						If (P^.szLinkedFile[0] <> #0) AND
							 ((P^.wTypeRep = CT_BITMAP) OR
								(P^.wTypeRep = CT_MCIWIN) OR
								(P^.wTypeRep = CT_SON)) then begin
							FileSplit(P^.szLinkedFile, Dir, Name, Ext);
							StrCopy(szPathFile, PathFrom);
							StrCat(szPathFile, '\');
							StrCat(szPathFile, Name);
							StrCat(szPathFile, Ext);
							CopyInCurLesson(szPathFile,  QCM0000, nItem);
							StrCopy(P^.szLinkedFile, szPathFile);
						end;
				 End;

BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+14, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	ForEach(@CopyLinkedFile);
end;

PROCEDURE TQcmWin.WMSize(Var Msg : TMessage);
VAR
	 wRect, wToolsRect : TRect;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+15, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		Inherited WMSize(Msg);
END;

PROCEDURE TQcmWin.WMSetCursor(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+16, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	DefWndProc(Msg);
END;

PROCEDURE TQcmWin.WMLButtonDown(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+17, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		{Permet de désélectionner la fenêtre fille sélectionnée}
		StrCopy(szLineTexte, '');
		StrCopy(szCoord, '');
		MainQcmWin^.SelectWindow(Nil);
		DefWndProc(Msg);
END;

PROCEDURE TQcmWin.WMTimer(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+18, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inc(nTime);
		 If bPlaying And (nTemps > 0) Then Begin
				InvalidateRect(HWndLTime, nil, TRUE);
				If(nTime > nTemps) Then Begin
					SndPlaySound(nil, SND_ASYNC);
					SendMessage(HWindow, UM_SUITE, 0, 0);
				End;
		 End;
END;

PROCEDURE TQcmWin.GetMaxXY(Var APoint : TPoint);
VAR
   wRect : TRect;
   DC : hDC;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+19, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 DC := GetDC(HWndParent);
		 APoint.X := GetDeviceCaps(DC, HORZRES);
		 GetWindowRect(HwndLigne, wRect);
		 APoint.Y := GetDeviceCaps(DC, VERTRES) - GetSystemMetrics(SM_CYCAPTION)
                 - wRect.Bottom + wRect.Top;
		 ReleaseDC(HWndParent, DC);
END;

PROCEDURE TQcmWin.UMMoveChild(Var Msg : TMessage);
VAR
	 cRect  : TRect;
	 nX, nY : Integer;
	 negX, negY : Boolean;

					Procedure GetMaxCoord(P : PWindowsObject);Far;
					Var
						 pwType : Word;
					Begin

								pwType :=(PMoveWindow(P))^.wTypeRep;
								If (pwType = CT_BITMAP) Or
									 (pwType = CT_SON) Or
									 {(pwType = CT_MCIWIN) Or}
									 (pwType = CT_TEXTE) Or
									 (pwType = CT_AUTRE) Then begin
									 With(PMoveWindow(P))^.Attr Do Begin
												If X > nX Then nX := X;
												If Y > nY Then nY := Y;
												If X < 0  Then negX := TRUE;
												If Y < 0  Then negY := TRUE;
												If(H < 0)  OR
													(W < 0)  Then begin
													{MoveWindow((PMoveWindow(P))^.HWindow, 0, 0, 100, 100, TRUE);}
													SetWindowPos((PMoveWindow(P))^.HWindow, 0, 0, 0, 100, 100, SWP_NOZORDER OR SWP_NOACTIVATE);
												end;
									 End;
								end;
					End;

BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+20, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 If wMode <> M_MAKE Then Exit;
		 Exit;
		 {####pas de scrollbars pour le moment }
		 nX := 0;
		 nY := 0;
		 negX := FALSE;
		 negY := FALSE;
		 ForEach(@GetMaxCoord);
		 GetClientRect(HWindow, cRect);
		 If((nX > cRect.Right) Or negX) Then Begin
				ShowScrollBar(HWindow, SB_HORZ, TRUE);
				Scroller^.HasHScrollBar := TRUE;
		 End Else Begin
				 ShowScrollBar(HWindow, SB_HORZ, FALSE);
				 Scroller^.HasHScrollBar := FALSE;
		 End;
		 If((nY > cRect.Bottom) Or negY)  Then Begin
				ShowScrollBar(HWindow, SB_VERT, TRUE);
				Scroller^.HasVScrollBar := TRUE;
		 End Else Begin
				 ShowScrollBar(HWindow, SB_VERT, FALSE);
				 Scroller^.HasVScrollBar := FALSE;
		 End;
END;

PROCEDURE TQcmWin.CreerRep(AType : Word; ATexte : PChar);
VAR
	 nX, nY    : Integer;
	 nRetour   : Integer;
	 nVerbes   : Integer;
	 cRect   : TRect;
	 lpSizeDlg : PSetSizeDlg;
	 szServeur, szObjet : szLongName;
	 pNew  			: PWINDOWSOBJECT;
	 lpOldReponse	: PMoveWindow;

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+21, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inc(nbrep);
		 OpenClipBoard(HWindow);
		 lpOldReponse := lpReponse;
		 if lpReponse <> nil then begin
			 nLigne := lpReponse^.Attr.Y + lpReponse^.Attr.H + PAS_GRILLE;
			 nColonne := lpReponse^.Attr.X;
		 end;
		 nY := nLigne;
		 nX := nColonne;
		 GetClientRect(HWindow, cRect);
		 If nX > cRect.Right Then nX := cRect.Right - PAS_GRILLE;
		 If nY > cRect.Bottom Then nY := cRect.Bottom - PAS_GRILLE;
		 Case AType Of

					CT_HOLE    :
							begin
								SelectWindow(PHole(Application^.MakeWindow(New(PHole, Init
								(@Self, ATexte, nX, nY)))));
							end;

					CT_TEXTE  :
						 begin
							 pNew := New(PRepTexteWin, Init(@Self, ATexte, nX, nY));
							 if pNew <> nil then begin
								 pNew := Application^.MakeWindow(pNew);
								 if pNew <> nil then begin
									SelectWindow(PRepTexteWin(pNew));
								 end else begin
									 WinProcs.MessageBox(GetActiveWindow, 'Unable to make object''s window.',
																							 'CT_TEXTE Error', MB_OK OR MB_ICONEXCLAMATION);
								 end;
							 end else begin
								 WinProcs.MessageBox(GetActiveWindow, 'Unable to create object.',
																						 'CT_TEXTE Error', MB_OK OR MB_ICONEXCLAMATION);
							 end;
						 end;

					CT_SON    :
							begin
								SelectWindow(PRepSonWin(Application^.MakeWindow(New(PRepSonWin, Init
								(@Self, ATexte, nX, nY)))));
							end;

					CT_MCIWIN    :
							begin
								SelectWindow(PMCIWin(Application^.MakeWindow(New(PMCIWin, Init
								(@Self, ATexte, nX, nY)))));
							end;

					CT_BITMAP :
							Begin
								 nRetour := ID_OK;
								 If StrLen(ATexte) <= 1 Then Begin
										lpSizeDlg := New(PSetSizeDlg, Init(Parent));
										nRetour  := Application^.ExecDialog(lpSizeDlg);
								 End;
								 If nRetour = ID_OK Then Begin
									 SelectWindow(PBitmapWin(Application^.MakeWindow(New(PBitmapWin, Init
										(@Self, ATexte, nX, nY)))));
								 End;
							End;

					CT_CLIP    :
							begin
								if lpReponse^.wTypeRep = CT_BITMAP then begin
									SelectWindow(PRepClipWin(Application^.MakeWindow(New(PRepClipWin, Init
									(PQcmWin(PBitmapWin(lpReponse)), 1, ATexte, 0, 0)))));
								end else begin
									if lpReponse^.wTypeRep = CT_CLIP then begin
										SelectWindow(PRepClipWin(Application^.MakeWindow(New(PRepClipWin, Init
										(PQcmWin(PBitmapWin(lpReponse^.Parent)), 1, ATexte, 0, 0)))));
									end;
								end;
							end;

					CT_AUTRE :
							If StrComp(ATexte, 'Prendre') <> 0 Then Begin
								nVerbes := GetInsertObjet(szServeur);
								If  nVerbes > 0  Then SelectWindow(PObjetWin(Application^.MakeWindow(New(PObjetWin, Init
										(@Self, szServeur, nX, nY, nVerbes, FALSE)))));
							End Else Begin
								nVerbes := GetPrendreObjet(szServeur);
								If  nVerbes > 0  Then SelectWindow(PObjetWin(Application^.MakeWindow(New(PObjetWin, Init
										(@Self, szServeur, nX, nY, nVerbes, TRUE)))));
							End;
		 End;

		 if lpReponse <> nil then begin
			 if AType <> CT_CLIP then begin
				 If lpReponse^.Attr.Y + lpReponse^.Attr.H > Attr.H Then Begin
					 nLigne := PAS_GRILLE;
					 Inc(nColonne, ((lpReponse^.Attr.W DIV PAS_GRILLE) + 1) * PAS_GRILLE);
					 If lpReponse^.Attr.X + lpReponse^.Attr.W > Attr.W Then Begin
						 nColonne := PAS_GRILLE;
					 end;
					 SetWindowPos(lpReponse^.HWindow, 0, nColonne, nLigne, 0, 0,
												SWP_NOZORDER OR SWP_NOSIZE OR SWP_NOACTIVATE);
				 end;
				 Inc(nLigne, ((lpReponse^.Attr.H DIV PAS_GRILLE) + 1) * PAS_GRILLE);
			 end else begin
			 end;
			 lpReponse^.BringToFront;
		 end;

		 CloseClipBoard;
END;

FUNCTION TQcmWin.GetInsertObjet(VAR AServeur : szLongName) : Integer;
VAR
	 dlgInsert : PInsertDlg;
	 ABuffer : TTrInsert;
	 szKeyName, buf : Array[0..300] Of Char;
	 szValue, szObjet : Array[0..63] Of Char;
	 lRet, lSize : LongInt;
	 i, nVerb : Integer;
	 Key1, Key2 : HKey;

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+22, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 GetInsertObjet := 0;
		 With ABuffer Do Begin
				 ObjetsColl := New(PStrCollection, Init(10, 5));
				 lRet := ERROR_SUCCESS;
				 i := 0;
				 While lRet = ERROR_SUCCESS Do Begin
					 lRet := RegEnumKey(HKEY_CLASSES_ROOT, i, szKeyName, SizeOf(szKeyName));
					 If lRet = ERROR_SUCCESS Then Begin
							 RegOpenKey(HKEY_CLASSES_ROOT, szKeyName, Key1);
							 If RegOpenKey(Key1, 'protocol\stdFileEditing\verb', Key2) = ERROR_SUCCESS Then Begin
										lSize := SizeOf(szValue);
										RegQueryValue(HKEY_CLASSES_ROOT, szKeyName, szValue, lSize);
										{Ajout dans la liste ole}
										ObjetsColl^.Insert(StrNew(szValue));
									End;
					 End;
					 Inc(i);
				 End;
				 ObjetSel := 0;
		 End;
		dlgInsert := New(PInsertDlg, Init(Parent , 'INSEREOBJET'));
		dlgInsert^.TransferBuffer := @ABuffer;
		If Application^.ExecDialog(dlgInsert) = ID_OK Then Begin
			 StrCopy(szObjet, ABuffer.ObjetsColl^.At(ABuffer.ObjetSel));
			 lRet := ERROR_SUCCESS;
				 i := 0;
				 While lRet = ERROR_SUCCESS Do Begin
					 lRet := RegEnumKey(HKEY_CLASSES_ROOT, i, szKeyName, SizeOf(szKeyName));
					 If lRet = ERROR_SUCCESS Then Begin
							 RegOpenKey(HKEY_CLASSES_ROOT, szKeyName, Key1);
							 If RegOpenKey(Key1, 'protocol\stdFileEditing\verb', Key2) =
									ERROR_SUCCESS Then Begin
											lSize := SizeOf(szValue);
											RegQueryValue(HKEY_CLASSES_ROOT, szKeyName, szValue, lSize);
											If StrComp(szValue, szObjet) = 0 Then Begin
													StrCopy(AServeur, szKeyName);
													lRet := 2;
													If RegOpenKey(Key1, 'protocol\stdFileEditing\verb\1', Key2) = ERROR_SUCCESS Then
														 nVerb := 2 Else nVerb := 1
                      End;
                  End;
           End;
					 Inc(i);
         End;
       GetInsertObjet := nVerb;
    End Else GetInsertObjet := 0;
END;

FUNCTION TQcmWin.GetPrendreObjet(Var AServeur : szLongName) : Integer;
VAR
	 lRet, lSize : LongInt;
	 i, nVerb, nIndex : Integer;
	 Key1, Key2 : HKey;
	 ServerColl : PStrCollection;
	 nSearch : Integer;
	 szFilter : Array[0..2048] Of Char;
	 OpenFN : TOpenFileName;
	 nSize  : Integer;
	 szKeyName, buf : Array[0..300] Of Char;
	 szValue, szObjet,
	 FileName, ElementName : szLongName;

										Procedure Recherche(P : PChar);Far;
                    Begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+23, 0, 0, 0, nil, TRUE);
	{$ENDIF}

												If StrIComp(P, szValue) = 0 Then
													 nSearch := ServerColl^.IndexOf(P);
										End;

BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+24, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		GetPrendreObjet := 0;
		lRet := ERROR_SUCCESS;
		i := 0;
		ServerColl := New(PStrCollection, Init(10, 5));
		While lRet = ERROR_SUCCESS Do Begin
				lRet := RegEnumKey(HKEY_CLASSES_ROOT, i, szKeyName, SizeOf(szKeyName));
						If lRet = ERROR_SUCCESS Then Begin
							 RegOpenKey(HKEY_CLASSES_ROOT, szKeyName, Key1);
							 If RegOpenKey(Key1, 'protocol\stdFileEditing\verb', Key2) =
									ERROR_SUCCESS Then Begin
											ServerColl^.Insert(StrNew(szKeyName));
									End;
						 End;
				Inc(i);
		End;

		lRet := ERROR_SUCCESS;
		i := 0;
		nSize := 0;
		FillChar(szFilter, SizeOf(szFilter), #0);
		While lRet = ERROR_SUCCESS Do Begin
				lRet := RegEnumKey(HKEY_CLASSES_ROOT, i, szKeyName, SizeOf(szKeyName));
						 If lRet = ERROR_SUCCESS Then Begin
							 lSize := SizeOf(szValue);
							 RegQueryValue(HKEY_CLASSES_ROOT, szKeyName, szValue, lSize);
							 nSearch := -1;
							 ServerColl^.ForEach(@Recherche);
							 If(nSearch > -1) And (szKeyName[0] = '.') Then Begin
									StrCopy(szValue, '*');
									StrCat(szValue, szKeyName);
									StrCat(szValue, ' ');
									StrCat(szValue, ServerColl^.At(nSearch));

									StrCopy(@szFilter[nSize], szValue);
									Inc(nSize, StrLen(szValue)+1);
									StrCopy(@szFilter[nSize], '*');
									Inc(nSize, 1);
									StrCopy(@szFilter[nSize], szKeyName);
									Inc(nSize, StrLen(szKeyName)+1);

							 End;
						 End;
				Inc(i);
    End;
		StrCopy(Filename, '');
		StrCopy(ElementName, '');
    FillChar(OpenFN, SizeOf(TOpenFileName), #0);
    With OpenFN Do Begin
				 hInstance     := HInstance;
				 hwndOwner     := GetActiveWindow;
         lpstrDefExt   := szKeyName;
         lpstrFile     := ElementName;
         lpstrFilter   := szFilter;
				 lpstrFileTitle:= nil;     {Title not needed right now ... use full path }
				 flags         := ofn_FileMustExist;
         lStructSize   := SizeOf(TOpenFileName);
         nFilterIndex  := 1;       {Use first Filter String in lpstrFilter}
				 nMaxFile      := SizeOf(FileName);
				 Flags         := Flags OR OFN_HIDEREADONLY;
		End;
		If GetOpenFileName(OpenFN) Then Begin
			 StrCopy(Aserveur, OpenFN.lpstrFile);
			 GetPrendreObjet := 2;
		End;
END;

PROCEDURE TQcmWin.UMSuppr(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+25, 0, 0, 0, nil, TRUE);
	{$ENDIF}
	if msg.lParam = 0 then begin
		If lpReponse <> Nil Then Supprimer(lpReponse);
	end else begin
		Supprimer(PMoveWindow(msg.lParam));
	end;
END;

function DeleteDummy(hWin : HWND; Dummy : TDummyRec; wParam : WORD; lParam : DWORD) : Boolean;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+26, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	{####If MainQcmWin^.lpColBranch^.IndexOf(Dummy.lpDummy) > -1 Then Begin
		 Writeln('lpColBranch Delete ', Dummy.lpDummy^.nOrdBranch, Dummy.lpDummy^.GetClassName);
		 MainQcmWin^.lpColBranch^.Delete(Dummy.lpDummy);
		 MainQcmWin^.nBRep := MainQcmWin^.lpColBranch^.Count;
	End;}
	Dummy.lpDummy^.Delete;
	Dummy.lpDummy := nil;
	DeleteDummy := TRUE;
end;

PROCEDURE TQcmWin.Supprimer(P : PMoveWindow);

var Dummy 	: TDummyRec;

					Procedure Eliminer(aP : PMoveWindow); Far;
					Begin

							 If aP <> Nil Then Begin
									{####If lpColBranch^.IndexOf(aP) > -1 Then Begin
										 lpColBranch^.Delete(aP);
										 Writeln('lpColBranch Delete ', aP^.GetClassName);
										 nBRep := lpColBranch^.Count;
									End;}
									aP^.Delete;
							 End;
					End;

BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+27, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 If P^.wTypeRep = CT_TEXTE Then begin
				PRepTexteWin(P)^.lpEdit^.EnumDummy(DeleteDummy, 0, 0, Dummy);
		 End;

		 If P^.wTypeRep = CT_BITMAP Then begin
				P^.ForEach(@Eliminer);
		 End;

		 Eliminer(P);

		 StrCopy(szLineTexte, '');
		 StrCopy(szCoord, '');
END;

PROCEDURE TQcmWin.UMOptions(Var Msg : TMessage);
VAR
	 nRet : Integer;
	 aTrSetOptions : TtrSetOptions;
	 lpSetOptionsDlg : PSetOptionsDlg;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+28, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 if lpReponse <> nil then begin
			SendMessage(lpReponse^.HWindow, WM_LBUTTONDBLCLK, 0, 0);
	 end else begin
		 With aTrSetOptions Do Begin
					If bRepeatQ Then nTrRepeat := 1 Else nTrRepeat := 0;
					If bShowBar Then nTrShowBar := 1 Else nTrShowBar := 0;
					If bOn20 Then nTrOn20 := 1 Else nTrOn20 := 0;
					If bAllForTrue Then Begin
						 nTrTout := 1;
						 nTrUne := 0;
					End Else Begin
							nTrTout := 0;
							nTrUne := 1;
					End;
		 End;
		 lpSetOptionsDlg := New(PSetOptionsDlg, Init(Parent, nTemps));
		 lpSetOptionsDlg^.TransferBuffer := @aTrSetOptions;
		 nRet := Application^.ExecDialog(lpSetOptionsDlg);
		 If nRet = ID_OK Then Begin
				 nTemps := lpSetOptionsDlg^.nDlgVal;
				 With aTrSetOptions Do Begin
							If nTrRepeat = 1 Then bRepeatQ := TRUE Else bRepeatQ := FALSE;
							If nTrShowBar = 1 Then bShowBar := TRUE Else bShowBar := FALSE;
							If nTrOn20 = 1 Then bOn20 := TRUE Else bOn20 := FALSE;
							If nTrTout = 1 Then bAllForTrue := TRUE Else bAllForTrue := FALSE;
				 End;
		 End;
	 End;
END;

PROCEDURE TQcmWin.SelectWindow(lpWindow : PMoveWindow);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+29, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 If lpReponse <> lpWindow Then Begin
				{Désélectionne celle qui est active}
				If lpReponse <> Nil Then lpReponse^.UpdateHandle;
				lpReponse := lpWindow;
				{Sélectionne celle qui appelle cette méthode en passant son HWnd}
				If lpReponse <> Nil Then lpReponse^.UpdateHandle;
		 End;
		 UpdateLineTexte(-1);

		 if bWin95 then begin
			 if (lpReponse <> nil) AND
					(lpReponse^.wTypeRep <> CT_BITMAP) then begin
				 ActivateKeyboardFromCharset(PREPONSEWIN(lpReponse)^.hLogFnt.lfCharset);
			 end;
		 end;

END;

PROCEDURE TQcmWin.UMChangePos(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+30, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		If lpReponse <> Nil Then Begin
			Case Msg.wParam Of
				IDB_TOP :
					begin
						bChangeZOrder := TRUE;
						SetWindowPos(lpReponse^.HWindow, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE OR SWP_NOACTIVATE);
					end;

				IDB_BOTTOM :
					begin
						bChangeZOrder := TRUE;
						SetWindowPos(lpReponse^.HWindow, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE OR SWP_NOACTIVATE);
					end;
				End;
		END;
END;

PROCEDURE TQcmWin.UMLoadQcm(Var Msg : TMessage);
VAR
	 oldCursor : HCursor;
	 header : TQcmFileHeader;
	 nMin, nMax, nNote : Integer;
	 S : TBufStream;

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+31, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 { Efface l'ancien de la mémoire}
		 {#### il faudra un Flag bModif et sauver si besoin est }
		 {If (wMode = M_MAKE) AND bModif Then UMSaveQCM(Msg);}

		 ClearDocument;

		 SetCapture(HWindow);
		 oldCursor := SetCursor(LoadCursor(0, idc_Wait));
		 nColorLine := RGB(128, 0, 0);
		 UpdateLineTexte(IDM_LOADLINE);

		 {lire le Header du QCM }
		 S.Init(szFichierQ, STOPENREAD, BUFFER_SIZE);
		 If S.Status = 0 Then Begin
				S.Read(Header, SizeOf(TQcmFileHeader));
				StrLCopy(szVersion, Header, SizeOf(TQcmFileHeader));
				S.Read(bShowBar, SizeOf(bShowBar));
				if ((szVersion[4] > '4') AND (szVersion[4] <= '9'))OR
					 ((szVersion[4] = '4') AND (szVersion[6] >= '2') AND (szVersion[6] <= '9')) then begin
					S.Read(bOn20, SizeOf(bOn20));
				end;
				S.Read(bSmartResult, SizeOf(bSmartResult));
				gbSmartResult := bSmartResult;
				S.Read(bKeepAnswer, SizeOf(bKeepAnswer));
				S.Read(nMin, SizeOf(nMin));
				S.Read(nMax, SizeOf(nMax));
				S.Read(bRepeatQ, SizeOf(bRepeatQ));
				S.Read(bAllForTrue, SizeOf(bAllForTrue));
				S.Read(nTemps, SizeOf(nTemps));
				EnableAutoCreate;
				GetChildren(S);
				If (S.Status = 0) And CreateChildren Then Begin
					UpdateDocument;
				End Else begin
					ErrorMessage(HWindow, IDM_STREAMERROR);
					UpdateDocument;
				end;
		 End;
		 S.Done;
		 bModif := FALSE;

		 SetCursor(oldCursor);
		 nColorLine := 0;
		 UpdateLineTexte(IDM_FIN);
		 ReleaseCapture;

		 {####If ((Not bItsACall) Or (nLastPlay = 1) ) then} begin
				with lpRepCollection^ do begin
					PostMessage(HWndLigne, UM_SETNOTE, Word(Somme), MakeLong(Word(Min), Word(Max)));
				end;
		 end;
END;

PROCEDURE TQcmWin.OleValidate;
					Procedure Validate(P : PMoveWindow);Far;
					Begin
						SelectWindow(P);
						{ Validation OLE }
						if (P^.wTypeRep = CT_AUTRE) then begin
							SendMessage(P^.HWindow, UM_OLEVALIDATE, 0, 0);
						end;
					End;
begin
		 ForEach(@Validate);
end;

PROCEDURE TQcmWin.ColBranchValidate;
var	 bFixed : Boolean;
					Procedure FixColBranch(P : PReponseWin);Far;
					Begin
						if TypeOf(P^) = TypeOf(TDummyReponseWin) then begin
							lpColBranch^.Free(P);
							bFixed := TRUE;
						end;
					End;

					Procedure SetnOrder(P : PReponseWin); Far;
					Begin
						 P^.nOrdBranch := lpColBranch^.IndexOf(P);
					End;
begin
		 bFixed := TRUE;
		 while bFixed do begin
			 bFixed := FALSE;
			 lpColBranch^.ForEach(@FixColBranch);
		 end;
		 lpColBranch^.ForEach(@SetnOrder);
end;

PROCEDURE TQcmWin.CollecSonValidate;
var	 bFixed : Boolean;
					Procedure FixCollecSon(P : PRepSonWin);Far;
					Begin
						if TypeOf(P^) = TypeOf(TDummyRepSonWin) then begin
							lpCollecSon^.Free(P);
						end;
					End;

					Procedure SetnOrderLect(P : PMoveWindow); Far;
					Begin
							 P^.nOrder :=lpCollecSon^.IndexOf(P) + 1;
					End;
begin
		 bFixed := TRUE;
		 while bFixed do begin
			 bFixed := FALSE;
			 lpCollecSon^.ForEach(@FixCollecSon);
		 end;
		 lpCollecSon^.ForEach(@SetnOrderLect);
end;

PROCEDURE TQcmWin.DummyValidate;
var	i : integer;
		pMoveWin : PMoveWindow;

begin
	i := 0;
	while i < lpColBranch^.Count do	begin
		pMoveWin := lpColBranch^.At(i);
		If (pMoveWin^.wTypeRep = CT_DUMMY) OR
			 (pMoveWin^.wTypeRep = CT_HYPERLINK) Then begin
			if (pMoveWin^.Parent = nil) OR
					NOT PRepTexteWin(pMoveWin^.Parent)^.lpEdit^.IsDummyHere(PDUMMY(pMoveWin)) then begin
					Supprimer(pMoveWin);
					MessageBeep(WORD(-1));
			end else begin
				inc(i);
			end;
		end else begin
			inc(i);
		end;
	end;
end;

PROCEDURE TQcmWin.PosValidate;
var	i : integer;
		pMoveWin : PMoveWindow;

begin
	i := 0;
	while i < lpColBranch^.Count do	begin
		pMoveWin := lpColBranch^.At(i);
		If (pMoveWin^.wTypeRep <> CT_DUMMY) AND
			 (pMoveWin^.wTypeRep <> CT_HYPERLINK) Then begin
			if (pMoveWin^.Parent = nil) OR
				 (pMoveWin^.Attr.W = 0) OR
				 (pMoveWin^.Attr.H = 0)	OR
				 (pMoveWin^.Attr.X > PWindow(pMoveWin^.Parent)^.Attr.W) OR
				 (pMoveWin^.Attr.Y > PWindow(pMoveWin^.Parent)^.Attr.H) then begin
					Supprimer(pMoveWin);
					MessageBeep(WORD(-1));
			end else begin
				inc(i);
			end;
		end else begin
			inc(i);
		end;
	end;
end;

PROCEDURE TQcmWin.UMSaveQcm(Var Msg : TMessage);
VAR
	 S : TBufStream;
	 oldCursor : hCursor;
	 nMin, nMax : Integer;
	 szMess : szLongName;

BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+32, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 { Valider chaque Objet }
		 DummyValidate;
		 PosValidate;
		 ColBranchValidate;
		 CollecSonValidate;
		 OleValidate;

		 SelectWindow(Nil);
		 nColorLine := RGB(128, 0, 0);
		 oldCursor := SetCursor(LoadCursor(0, idc_Wait));
		 UpdateLineTexte(IDM_SAVELINE);
		 S.Init(szFichierQ, stCreate, BUFFER_SIZE);
		 If S.Status = 0 Then Begin {Pas d'erreur}
				S.Write(QcmFileHeader, SizeOf(TQcmFileHeader));
				S.Write(bShowBar, SizeOf(bShowBar));
				S.Write(bOn20, SizeOf(bOn20));
				S.Write(bSmartResult, SizeOf(bSmartResult));
				S.Write(bKeepAnswer, SizeOf(bKeepAnswer));
				GetMinMaxPoints(nMin, nMax);
				S.Write(nMin, SizeOf(nMin));
				S.Write(nMax, SizeOf(nMax));
				S.Write(bRepeatQ, SizeOf(bRepeatQ));
				S.Write(bAllForTrue, SizeOf(bAllForTrue));
				S.Write(nTemps, SizeOf(nTemps));
				PutChildren(S);
				If S.Status = 0 Then Begin {Sauvegarde correcte}
					 if OleSavedClientDoc(ClientDoc) <> OLE_OK then begin
							ErrorMessage(HWindow, IDM_STREAMERROR);
							wvsPrintF(szMess, '%i', s.Status);
							WinProcs.MessageBox(0, szMess, 'OLE Save error', 0);
					 end;
				End Else Begin
						ErrorMessage(HWindow, IDM_STREAMERROR);
						case s.Status of
							stError				: StrCopy(szMess, 'Access error');
							stInitError		: StrCopy(szMess, 'Cannot initialize stream');
							stReadError		: StrCopy(szMess, 'Read beyond end of stream');
							stWriteError	: StrCopy(szMess, 'Cannot expand stream');
							stGetError		: StrCopy(szMess, 'Get of unregistered object type');
							stPutError		: StrCopy(szMess, 'Put of unregistered object type');
						else
							wvsPrintF(szMess, 'Unknown error %i', s.Status);
						end;
						case s.ErrorInfo of
							stError	: StrCat(szMess, ' : DOS or EMS error code; if available');
							stInitError	: StrCat(szMess, ' : DOS or EMS error code; if available');
							stReadError	: StrCat(szMess, ' : DOS or EMS error code; if available');
							stWriteError : StrCat(szMess, ' : DOS or EMS error code; if available');
							stGetError	: StrCat(szMess, ' : Object type ID of unregistered object type');
							stPutError	: StrCat(szMess, ' : VMT data segment offset of unregistered object type');
						end;
						WinProcs.MessageBox(0, szMess, 'Save error on PutChildren(S)', 0);
				End;
		 S.Done;
		 End Else Begin
				ErrorMessage(HWindow, IDM_STREAMERROR);
				case s.Status of
					stError				: StrCopy(szMess, 'Access error');
					stInitError		: StrCopy(szMess, 'Cannot initialize stream');
					stReadError		: StrCopy(szMess, 'Read beyond end of stream');
					stWriteError	: StrCopy(szMess, 'Cannot expand stream');
					stGetError		: StrCopy(szMess, 'Get of unregistered object type');
					stPutError		: StrCopy(szMess, 'Put of unregistered object type');
				else
					wvsPrintF(szMess, 'Unknown error %i', s.Status);
				end;
				case s.ErrorInfo of
					stError	: StrCat(szMess, ' : DOS or EMS error code; if available');
					stInitError	: StrCat(szMess, ' : DOS or EMS error code; if available');
					stReadError	: StrCat(szMess, ' : DOS or EMS error code; if available');
					stWriteError : StrCat(szMess, ' : DOS or EMS error code; if available');
					stGetError	: StrCat(szMess, ' : Object type ID of unregistered object type');
					stPutError	: StrCat(szMess, ' : VMT data segment offset of unregistered object type');
				end;
				WinProcs.MessageBox(0, szMess, 'Save error on S.Init', 0);
		 End;
		 nColorLine := 0;
		 UpdateLineTexte(IDM_FIN);
		 SetCursor(oldCursor);
END;

PROCEDURE TQcmWin.UMMakeDummy(Var Msg : TMessage);
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+33, 0, 0, 0, nil, TRUE);
	{$ENDIF}


	if lpReponse = nil then begin
		CreerRep(CT_HOLE, '');
		exit;
	end;

	if lpReponse^.wTypeRep = CT_TEXTE then begin
		PRepTexteWin(lpReponse)^.lpEdit^.NewDummy;
	end;

end;

PROCEDURE TQcmWin.UMMakeClipWin(Var Msg : TMessage);
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+34, 0, 0, 0, nil, TRUE);
	{$ENDIF}


	if lpReponse <> nil then begin
		CreerRep(CT_CLIP, '');
	end;

end;

PROCEDURE TQcmWin.UMMakeHyperLink(Var Msg : TMessage);
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+33, 0, 0, 0, nil, TRUE);
	{$ENDIF}


	if lpReponse = nil then begin
		CreerRep(CT_HOLE, '');
		exit;
	end;

	if lpReponse^.wTypeRep = CT_TEXTE then begin
		PRepTexteWin(lpReponse)^.lpEdit^.NewHyperLink;
	end;

end;

Procedure TQcmWin.UpdateLineTexte(AnIndex : Integer);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+35, 0, 0, 0, nil, TRUE);
	{$ENDIF}

     {Mise à jour de la ligne d'état : SetLine texte met à jour la varialble
		 szLineTexte}
		 StrCopy(szLineTexte, '');
		 If lpReponse <> NIL Then lpReponse^.SetLineTexte;
		 If AnIndex <> -1 Then Begin
				LoadString(hInstRes, AnIndex, szLineTexte, MAX_STRLOAD)
		 End Else Begin
				 StrCat(szLineTexte, szCoord);
		 End;
		 SendMessage(WintoolsHandle, UM_ECRSTL, 0, nColorLine);
END;

PROCEDURE TQcmWin.SetSoundOrder;
					Procedure SetSound(P : PMoveWindow);Far;
					Begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+36, 0, 0, 0, nil, TRUE);
	{$ENDIF}

							 If P^.wTypeRep = CT_SON Then Begin
									(PRepSonWin(P))^.UpdateOrder(P^.nOrder, FALSE);
							 End;
					End;
BEGIN
	 lpColBranch^.ForEach(@SetSound);
END;

PROCEDURE TQcmWin.UMPlayQcm(Var Msg : TMessage);
VAR
	 lpReqQcm : PReqQcm;
	 PeekMsg	: TMSG;
	 szMciStr : TMCISTR;
	 nCmd			: integer;

					Procedure PlaySound(P : PRepSonWin);Far;
					Var
						HData : THandle;
						lp : Pointer;
					Begin

						if P^.OleObject <> nil then begin
							 OleGetData(P^.OleObject, CFNative, HData);
							 lp := GlobalLock(HData);
							 SndPlaySound(PChar(lp),SND_SYNC Or SND_MEMORY);
							 GlobalUnlock(HData);
						end else begin
							 wvsprintf(szMciStr, 'CALL USER GETDC %u', P^.lpButton^.HWindow);
							 InsMciQueueString(szMciStr, nCmd);
							 inc(nCmd);
							 StrCopy(szMciStr, 'LET $HANDLE0 = $RETURN');
							 InsMciQueueString(szMciStr, nCmd);
							 inc(nCmd);
							 StrCopy(szMciStr, 'CALL GDI PATBLT $HANDLE0 4 4 18 18 PATINVERT');
							 InsMciQueueString(szMciStr, nCmd);
							 inc(nCmd);
							 StrCopy(szMciStr, 'OPEN ');
							 StrCat(szMciStr, P^.szLinkedFile);
							 StrCat(szMciStr, ' ALIAS SON NOTIFY');
							 InsMciQueueString(szMciStr, nCmd);
							 inc(nCmd);
							 StrCopy(szMciStr, 'PLAY SON NOTIFY');
							 InsMciQueueString(szMciStr, nCmd);
							 inc(nCmd);
							 StrCopy(szMciStr, 'CLOSE SON NOTIFY');
							 InsMciQueueString(szMciStr, nCmd);
							 inc(nCmd);
							 StrCopy(szMciStr, 'CALL GDI PATBLT $HANDLE0 4 4 18 18 PATINVERT');
							 InsMciQueueString(szMciStr, nCmd);
							 inc(nCmd);
							 wvsprintf(szMciStr, 'CALL USER RELEASEDC %u $HANDLE0', P^.lpButton^.HWindow);
							 InsMciQueueString(szMciStr, nCmd);
							 inc(nCmd);
							 {SndPlaySound(P^.szLinkedFile, SND_SYNC);}
						end;
					end;
BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+37, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		lpReqQcm := PReqQcm(Msg.lParam);
		If wMode = M_TUTOR Then begin
			nNoElev := lpReqQcm^.nElev;
			gnNoElev := nNoElev;
		end;

		{If StrComp(szFichierQ, lpReqQcm^.Path) <> 0 Then Begin
			 StrCopy(szFichierQ, lpReqQcm^.Path);
			 SendMessage(HWindow, UM_LOADQCM, 0, 0);
		End;}

		{#### tester si pas en mémoire avant de charger }
		StrCopy(szFichierQ, lpReqQcm^.Path);
		SendMessage(HWindow, UM_LOADQCM, 0, 0);

		If nTemps > 0 Then begin
			ShowWindow(HWndLTime, SW_SHOW);
		end Else begin
			ShowWindow(HWndLTime, SW_HIDE);
		end;

		bPlaying := TRUE;
		nTime := 0;
		nIdQuest := Msg.wParam - 1;
		If (wMode = M_ELEV) Then SetQcmCheck;
		If (wMode = M_TUTOR) Then SetReponsesElev;

		While PeekMessage(PeekMsg, 0, 0, 0, PM_REMOVE) do begin
			TranslateMessage(PeekMsg);
			DispatchMessage(PeekMsg);
		end;

		{ met à jours le nom de le leçon de retour }
		if pLstLessonCalled^.Count > 1 then begin
			 i := 0;
			 repeat
				 inc(i);
				 StrCopy(szLessonRet, (PLessonCalledItem(pLstLessonCalled^.At(i))^.szLecon));
			 until (PLessonCalledItem(pLstLessonCalled^.At(i))^.lpSelection^.Count > 0) OR
						 (i = pLstLessonCalled^.Count - 1);
				SetDlgItemText(hBoutonsProc, 607, szLessonRet);
		end;

		If (wMode <> M_TUTOR) then begin
			 nCmd := 0;
			 SetSoundOrder;
			 If lpCollecSon^.Count > 0 then begin
					lpCollecSon^.ForEach(@PlaySound);
			 end;
			 if NOT lpReqQcm^.bNotify then begin
					StrCopy(szMciStr, 'STOP');
					InsMciQueueString(szMciStr, nCmd);
			 end;
			 PostMessage(hMciQueueProc, mm_MciNotify, 0, 0);
		End;
END;

PROCEDURE TQcmWin.SetQcmCheck;
VAR
	 lpRep : PReponseElev;
	 nIndex :Integer;
	 szLessonName : szLongName;

					Procedure CheckRep(P : PProposition); Far;
					Var
						 nIdx : Integer;
					Begin

						 nIdx := lpRep^.lpPropositions^.IndexOf(P);
						 If(nIdx >= lpColBranch^.Count) Or (nIdx < 0) Then Exit;

						 if (NOT bKeepAnswer) AND
								(NOT PlayingR) then begin
									P^.bCochee := FALSE;
						 end;

						 if (P^.wType = CT_DUMMY) OR
								(P^.wType = CT_HYPERLINK) then begin
								StrCopy(PDummy(lpColBranch^.At(nIdx))^.szText, P^.szText);
						 end;

						 If P^.bCochee Then
							 (PReponseWin(lpColBranch^.At(nIdx)))^.SetCheck(1)
						 Else
							 (PReponseWin(lpColBranch^.At(nIdx)))^.SetCheck(0);
					End;
BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+38, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 {retrouve la leçon  sélectionnée.}
		 GetDlgItemText(hLeconProc,idl_Lecon, szLessonName, SizeOf(szLessonName));

		 nIndex := lpRepCollection^.GetPhaseIndex(nIdQuest, szLessonName);
		 If nIndex > -1 Then Begin
				lpRep := lpRepCollection^.At(nIndex);
				lpRep^.lpPropositions^.ForEach(@CheckRep);
		 End;
END;

PROCEDURE TQcmWin.SetReponsesElev;
VAR
	 szPathStream : szLongName;
	 szIntermed   : szLongName;
	 szLessonName	: szLongName;
	 S : TBufStream;
	 lpRep : PReponseElev;
	 theEtudiant : TypeEtudiant;
	 nIndex : Integer;
	 nIdx : Integer;
					Procedure CheckReps(P : PProposition); Far;
					Begin

							 nIdx := lpRep^.lpPropositions^.IndexOf(P);

							 If (nIdx >= lpColBranch^.Count) Or (nIdx < 0) Then begin
								 Exit;
							 end;

							 if (P^.wType = CT_DUMMY) OR
									(P^.wType = CT_HYPERLINK) then begin
									StrCopy(PDummy(lpColBranch^.At(nIdx))^.szText, P^.szText);
							 end;

							 If P^.bCochee Then begin
								(PReponseWin(lpColBranch^.At(nIdx)))^.SetCheck(1);
							 end Else begin
								(PReponseWin(lpColBranch^.At(nIdx)))^.SetCheck(0);
							 end;
					End;
BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+39, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 If lpRepCollection^.Count > 0 Then Dispose(lpRepCollection, Done);
		 StrCopy(szPathStream, PathEleves);
		 GetEtudiantRec(nNoElev, TheEtudiant);
		 GetDosName(szIntermed, TheEtudiant.Nom);
		 {StrCat(szPathStream, ELEV);
		 StrPCopy(szIntermed, IntToStr(nNoElev));}
		 StrCat(szPathStream, szIntermed);
		 StrCat(szPathStream, '\repelev.stm');
		 S.Init(szPathStream, STOPENREAD, BUFFER_SIZE);
		 If S.Status = 0 Then Begin
				 wMode := M_ELEV;
				 lpRepCollection := PRepCollection(S.Get);

				 {retrouve la leçon  sélectionnée.}
				 GetDlgItemText(hLeconProc,idl_Lecon, szLessonName, SizeOf(szLessonName));

				 nIndex  := lpRepCollection^.GetPhaseIndex(nIdQuest, szLessonName);
				 If nIndex > -1 Then Begin
						lpRep := lpRepCollection^.At(nIndex);
						lpRep^.lpPropositions^.ForEach(@CheckReps);
				 End;
				 wMode := M_TUTOR;
		 End;
		 S.Done;
		 GetEtudiantRec(nNoElev, theEtudiant);
		 {####If ((Not bItsACall) Or (nLastPlay =1)) Then} begin
				with theEtudiant do begin
					PostMessage(HWndLigne, UM_SETNOTE, Word(Score), MakeLong(Word(MinPoints), Word(MaxPoints)));
				end;
		 end;
END;

PROCEDURE TQcmWin.GetMinMaxPoints(Var TheMin : Integer; Var TheMax : Integer);
					Procedure GetPoints(P : PMoveWindow); Far;
					Var
						 TheRep : PReponseWin;
					Begin


							 If P^.wTypeRep <> CT_BITMAP Then Begin
									TheRep := PReponseWin(P);
									If TheRep^.nValeur > 0 Then Inc(TheMax, TheRep^.nValeur);
									If TheRep^.nValeur < 0 Then Inc(TheMin, TheRep^.nValeur);
							 End;
					End;
BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+40, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TheMin := 0;
		 TheMax := 0;
		 lpColBranch^.ForEach(@GetPoints);
END;

PROCEDURE TQcmWin.UMSuite(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+41, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 SndPlaySound(nil, SND_ASYNC);
		 Case wMode  Of
					M_ELEV : If nColorLine = 0 Then Begin
											bPlaying := FALSE;
											AnalyseQcm;
											ShowWindow(hQcmProc, SW_HIDE);
											SendMessage(hQcmProc, WM_PAINT, 0, 0);
											PostMessage(hMciQueueProc, mm_MciNotify,0,0);
									 End;

					{M_VISU : Begin
									 ShowWindow(hQcmProc, SW_HIDE);
								End;}

					M_TUTOR : If nColorLine = 0 Then Begin
											 bPlaying := FALSE;
											 ShowWindow(hQcmProc, SW_HIDE);
											 UpdateWindow(hQcmProc);
											 PostMessage(hMciQueueProc,mm_MciNotify,0,0);
											 SendMessage(HWndParent, UM_SUITE, 0, 0);
										End;
		 End;
		 {### remise à jours de la palette de l'image }
		 PostMessage(hGraphiqueProc, WM_QUERYNEWPALETTE, 0, 0);
END;

PROCEDURE TQcmWin.AnalyseQcm;
VAR
	 pStart,
	 pEnd			: PCHAR;
	 nIns			: integer;
	 bTrouve,
	 bOneJust,
	 bOneBad,
	 bAllJust,
	 bAutoRet,
	 bRepeat : Boolean;
	 nValQuestion    : Integer;
	 nAppels, nNiv   : Integer;
	 nSel, i, j,
	 nIndex 				: Integer;
	 nNegatif       : Integer;
	 szLessonName : szLongName;
	 szPhase      : szLongName;
	 szMessage    : szLongName;
	 pSels    : ^TSelBuff;
	 lpRepElev : PReponseElev;
	 lpListSel : PStrSelCollect;
	 idBut		 : WORD;
	 lIndexSearch	: longint;

					Procedure ScanRep(P : PReponseWin); Far;
					Begin

							Debug('ScanRep :');
							Debug(P^.szLessonToCall);
							 {Insertion dans la liste de l'objet réponse élève
							 de la proposition de réponse avec son état cochée, valeur,...}
							 With lpRepElev^ Do Begin
										if (P^.wTypeRep = CT_DUMMY) OR
											 (P^.wTypeRep = CT_HYPERLINK)	then begin
											lpPropositions^.Insert(New(PProposition, Init(
														P^.nOrdBranch, P^.wTypeRep, P^.nValeur, P^.GetCheck = 1, PDummy(P)^.szText)));

										end else begin
											lpPropositions^.Insert(New(PProposition, Init(
														P^.nOrdBranch, P^.wTypeRep, P^.nValeur, P^.GetCheck = 1, '')));
										end;
										{Si elle est cochée, incrémenation du résultat}
										If  P^.GetCheck = 1 Then Begin
											 Inc(nResultat, P^.nValeur);
										End;
							 End;

							 { Insérer le script Objet Tuteur }
							 if P^.lpszScript <> nil then begin
								 If((P^.GetCheck = 1) And (P^.nValeur <= 0)) Or
									 ((P^.GetCheck = 0) And (P^.nValeur > 0)) Then Begin
									 pStart := P^.lpszScript;
									 pEnd := StrPos(pStart, #13);
									 while pEnd <> nil do begin
											pEnd[0] := #0;
											InsMciQueueString(pStart, nIns);
											Inc(nIns);
											pStart := @pEnd[2];
											pEnd := StrPos(pStart, #13);
									 end;
									 InsMciQueueString(pStart, nIns);
								 end;
							 end;

							 {S'il y a des branchements, insertion dans la file d'attente
								et insertion dans l'ordre des branchements}
							 If P^.lpSelSeqInLessonToCall^.Count > 0 Then
								{####WinProcs.MessageBox(GetActiveWindow, 'nAppels = ', nAppels, ' ', P^.szLessonToCall, ' Sel : ',
								P^.lpSelSeqInLessonToCall^.Count);
								WinProcs.MessageBox(GetActiveWindow, 'GetCheck : ', P^.GetCheck, '; Val : ', P^.nValeur);}
								If((P^.GetCheck = 1) And (P^.nValeur <= 0)) Or
									((P^.GetCheck = 0) And (P^.nValeur > 0)) Then Begin
										If nAppels > 0 Then begin
											pLstLessonCalled^.AtInsert(nAppels, New(PLessonCalledItem,
											Init(0, idBut, P^.szLessonToCall, P^.lpSelSeqInLessonToCall, P^.bAutoRet)));
											Debug('pLstLessonCalled^.AtInsert(nAppels) :');
											Debug(P^.szLessonToCall);
										end Else begin
											pLstLessonCalled^.AtInsert(0, New(PLessonCalledItem,
											Init(0, idBut, P^.szLessonToCall, P^.lpSelSeqInLessonToCall, P^.bAutoRet)));
											Debug('pLstLessonCalled^.AtInsert(0) :');
											Debug(P^.szLessonToCall);
										end;
										Inc(nAppels);
									{lIndexSearch := SendDlgItemMessage(hLeconProc, idl_Lecon, CB_FINDSTRINGEXACT, 0, LongInt(@P^.szLessonToCall));
									If lIndexSearch <> CB_ERR Then Begin
									end else begin
										 WinProcs.MessageBox(GetActiveWindow, 'Leçon introuvable, branchement non valide.',
																				 P^.szLessonToCall, MB_OK OR MB_ICONEXCLAMATION);
									end;}
							 End;

							 {Mise à jour des bool pour les tests de répétition de la question}
							 If ((P^.GetCheck = 1) And (P^.nValeur <= 0)) Then begin
									{Il y a au moins une réponse fausse}
									bOneBad := TRUE;
							 end Else begin
									If ((P^.GetCheck = 1) And (P^.nValeur > 0)) Then begin
										{Il y a au moins une réponse juste}
										bOneJust := TRUE;
									end;
							 end;

							 If ((P^.GetCheck = 1) And (P^.nValeur <= 0)) OR
									((P^.GetCheck = 0) And(P^.nValeur > 0)) Then begin
									bAllJust := FALSE;
							 end;

							 If((P^.GetCheck = 1) And (P^.nValeur < 0)) Then begin
									Inc(nNegatif, P^.nValeur);
							 end;
					End;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+42, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Debug('');
		 Debug('********************');
		 DebugLessonCalled('Début AnalyseQCM');

		 { si pas enregistrement on sort }
		 if NOT RecordingR then Exit;

		 nIns := 0;

		 if RecordingR then begin
			idBut := idb_RecordR;
		 end else begin
			 if PlayingQ then begin
				 if PlayingR then begin
					idBut := idb_PlayQR;
				 end else begin
					idBut := idb_PlayQ;
				 end;
			 end else begin
				 if PlayingR then begin
					idBut := idb_PlayR;
				 end else begin
					idBut := 0;
				 end;
			 end;
		 end;

		 bOneJust := FALSE;
		 bOneBad  := FALSE;
		 bAllJust := TRUE;
		 nValQuestion := 0;
		 nAppels      := 0;
		 nNegatif 		:= 0;
		 If pLstLessonCalled^.Count <= 0 Then Begin
				nNiveauPlay := 0;
				bItsACall := FALSE;
				Debug('bItsACall := FALSE nNiveauPlay := 0');
		 End;

		 {retrouve la leçon  sélectionnée.}
		 GetDlgItemText(hLeconProc,idl_Lecon, szLessonName, SizeOf(szLessonName));

		 {objet réponse élève temporaire}
		 lpRepElev    := New(PReponseElev, Init(nIdQuest, szLessonName));

		 {lpColBranch est la collection des propositions de réponses(n'inclue
		 pas les images). Pour chaque réponse on controle si elle a été coché
		 et dans ce cas on incrémente les résultat, et on sauve les réponses de
		 l'élève dans la collection de l'objet temporaire. Ceci pour chaque réponse
		 dans la méthode Scanrep}
		 lpColBranch^.ForEach(@Scanrep);

		 {Insertion dans la collection des réponses de l'élève. Newrep copie l'objet
		 lpRepElev, ce qui me permet de le détruire ensuite}
		 {####If (Not bItsACall) Or (nLastPlay = 1) Then}
		 begin
			 lpRepCollection^.NewRep(nIdQuest, lpRepElev);
		 end;

		 Dispose(lpRepElev, Done);

		 {####If (Not bItsACall) Or (nLastPlay = 1) Then}
		 Begin
				{Mise à jour des résultats dans le fichier étudiant}
				GetEtudiantRec(nNoElev, tEtudiant);
				with lpRepCollection^ do begin
					tEtudiant.Score := Somme;
					tEtudiant.MaxPoints := Max;
					tEtudiant.MinPoints := Min;
				end;
				SetEtudiantRec(nNoElev, tEtudiant);
		 End;

		 { Options : répétition de la question si la réponse
			est fausse : bRepeatQ. La réponse est juste si tout est juste(bAllForTrue)
			ou si seulement une réponse est juste(Not bAllForTrue)}

		 {Si répétition de la question lorsque la reponse est fausse }
		 If bRepeatQ Then Begin
				{ si la réponse est juste si tous les items est juste }
				If bAllForTrue Then begin
					{ on répète si tout n'est pas juste }
					bRepeat := NOT bAllJust;
				{ si la réponse est juste si au moins un item est juste }
				end Else begin
					If bOneBad Then begin
						{ on répète si un item est faux }
						bRepeat := True;
					end Else begin
						{ on répète si un item n'est pas juste (est faux) }
						bRepeat := Not bOneJust;
					end;
				end;
		 {Si pas répétition de la question lorsque la reponse est fausse }
		 End Else begin
				{ on ne répète pas }
				bRepeat := FALSE;
		 end;

		 {On détermine ici le message à afficher en fonction de la réponse}
		 { si on doit répéter et qu'il n'y a plus ou pas d'appel à effectuer }
		 If bRepeat And (nAppels = 0) Then Begin
				{WinProcs.MessageBox(HWindow, mmLoadString(hInstRes, STR_INCORRECT), '', 0);}
				{ on redessine }
				{#####InvalidateRect(hWindow, 0, 0, 0, nil, TRUE);}
		 End;

		 { si on doit répéter et qu'il y a un ou des appels à effectuer }
		 If bRepeat And (nAppels > 0) Then Begin
				{If nNegatif < 0 Then WinProcs.MessageBox(HWindow, mmLoadString(hInstRes, STR_APPEL), '', 0);}
				{ on cache la fenêtre tuteur }
				{#####ShowWindow(hQcmProc, SW_HIDE);}
		 End;

		{ Sauvegarde à la fin de l'insertion de létat de la sélection avant le
		branchement}
	 { si on doit répéter ou qu'il y a un ou des appels à effectuer }
		If bRepeat OR (nAppels > 0) Then Begin

				{retrouve la leçon  sélectionnée.}
				GetDlgItemText(hLeconProc, idl_Lecon, szLessonName, SizeOf(szLessonName));

			 {Collection temporaire pour récupérer la sélection de séquences}
			 lpListSel := New(PStrSelCollect, Init(5, 5));

			 {nSel := nombre d'items sélectionnés}
			 nSel := SendDlgItemMessage(hLeconProc, idl_ListeQ, LB_GETSELCOUNT, 0, 0);
			 If nSel > 0 Then Begin
					{pSels : Tableau d'entiers}
					GetMem(pSels, nSel*SizeOf(Integer));

					{remplissage de pSels}
					nSel := SendDlgItemMessage(hLeconProc, idl_ListeQ, LB_GETSELITEMS, nSel, LongInt(pSels));

					{Génération de la collection de chaines de caractères}
					For i := nSel DownTo 1 Do Begin
							wvsPrintF(szPhase, '%i', pSels^[i]);
							lpListSel^.Insert(StrNew(szPhase));
					End;
					FreeMem(pSels, nSel*SizeOf(Integer));

				 {Désélectionne avant appel}
				 SendDlgItemMessage(hLeconProc, idl_ListeQ, LB_SETSEL, WORD(FALSE), MAKELONG(WORD(-1), 0));
				 nSel := SendDlgItemMessage(hLeconProc, idl_ListeQ, LB_GETSELCOUNT, 0, 0);
				 if nSel > 0 then begin
					Debug('###ERREUR nSel > 0 !!!!');
				 end else begin
					Debug('nSel = 0 ....');
				 end;

			 End;

			 {Vu que l'état de la sélection est capturé alors que la phase qui
				vient d'être jouée est encore sélectionnée, il faut la supprimer
				de la sélection si on ne veut pas qu'elle soit rejouée.}
			 If(lpListSel^.Count > 0) And (Not bRepeat) Then begin
					lpListSel^.AtFree(0);
					Debug('lpListSel^.AtFree(0)');
			 end;

				{Si la leçon n'est pas dans la liste, je l'insère. Si on ne fait pas
				 ce test on aura plusieurs retours sur la leçon}
				{je recherche ici si l'état de cette leçon a été déjà sauvegardé}
				bTrouve := FALSE;
				For i := 0 To pLstLessonCalled^.Count - 1 Do Begin
					If (StrComp((PLessonCalledItem(pLstLessonCalled^.At(i))^.szLecon), szLessonName) = 0)	then begin
						if (PLessonCalledItem(pLstLessonCalled^.At(i))^.nNiveau = 1)	Then Begin
							 bAutoRet := PLessonCalledItem(pLstLessonCalled^.At(i))^.bAutoRet;
							 nNiv := PLessonCalledItem(pLstLessonCalled^.At(i))^.nNiveau;
							 bTrouve := TRUE;
							 nIndex := i;
						end else begin
							if PLessonCalledItem(pLstLessonCalled^.At(i))^.lpSelection^.Count = lpListSel^.Count then begin
								bTrouve := TRUE;
								for j := 0 to PLessonCalledItem(pLstLessonCalled^.At(i))^.lpSelection^.Count - 1 do begin
									if StrComp(PCHAR(PLessonCalledItem(pLstLessonCalled^.At(i))^.lpSelection^.At(j)),
													lpListSel^.At(j)) <> 0 then begin
										bTrouve := FALSE;
									end;
								end;
								if bTrouve then begin
									 bAutoRet := PLessonCalledItem(pLstLessonCalled^.At(i))^.bAutoRet;
									 nNiv := PLessonCalledItem(pLstLessonCalled^.At(i))^.nNiveau;
									 nIndex := i;
								end;
							end;
						end;
					End;
				End;


			 {Insertion dans la file d'attente des branchements}
			 Inc(nNiveauPlay);
			 If bTrouve Then begin
				 nAppels := nIndex;
			 end Else begin
				 nNiv := nNiveauPlay;
			 end;

			 {####WinProcs.MessageBox(GetActiveWindow, 'nAppels = ', nAppels, ' ', szLessonName);}
			 {####WinProcs.MessageBox(GetActiveWindow, 'lpListSel^.Count ', lpListSel^.Count);}
			 If (lpListSel^.Count > 0) Then Begin
				 pLstLessonCalled^.AtInsert(nAppels,
					New(PLessonCalledItem, Init(nNiv, idBut, szLessonName, lpListSel, bAutoRet)));
					Debug('Retour : pLstLessonCalled^.AtInsert(...,lpListSel, ...)');
			 end else begin
				 pLstLessonCalled^.AtInsert(nAppels,
					 New(PLessonCalledItem, Init(nNiv, idBut, szLessonName, Nil, bAutoRet)));
					Debug('Retour : pLstLessonCalled^.AtInsert(...,nil, ...)');
			 end;

			 If bTrouve Then begin
				pLstLessonCalled^.AtFree(nAppels + 1);
				Debug('pLstLessonCalled^.AtFree(nAppels + 1)');
				{####WinProcs.MessageBox(GetActiveWindow, 'pLstLessonCalled^.AtFree(nAppels + 1)');}
			 end;

			{Destruction de la collection temporaire}
			 If lpListSel <> nil Then begin
					Dispose(lpListSel, Done);
			 end;

			 if pLstLessonCalled^.Count > 1 then begin
				 i := 0;
				 repeat
					 inc(i);
					 StrCopy(szLessonRet, (PLessonCalledItem(pLstLessonCalled^.At(i))^.szLecon));
				 until (PLessonCalledItem(pLstLessonCalled^.At(i))^.lpSelection^.Count > 0) OR
							 (i = pLstLessonCalled^.Count - 1);
			 end;

		End;

		 DebugLessonCalled('Fin AnalyseQCM');

END;

Procedure SimuleStop;
Begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+43, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 { stoppe tout }
		 StopMciQueue;
		 SetFocus(GetDlgItem(hBoutonsProc,idb_Enregistre));
		 ShowWindow(hQcmProc, SW_HIDE);
End;

PROCEDURE TQcmWin.AppelLecon;

const nFirst : integer = -1;
			nLast	 : integer = -1;
		 lpPrevAppelObj : PLessonCalledItem = nil;
VAR
	 lpLessonCalledItem : PLessonCalledItem;
	 lIndexSearch : LongInt;
	 PeekMsg	: TMSG;
	 szCur		: szLONGNAME;
	 idBut		: WORD;
	 nSel			: Integer;
	 pSels    : ^TSelBuff;
	 szPhase  : szLongName;
	 bBadCall : boolean;

					Procedure SelectItem(P : PChar);Far;
						var 	nIndex, res : Integer;
					Begin

							 {Sélectionne la question de la liste dont le N° d'item est passé par P}
							 Val(P, nIndex, res);
							 if nFirst = -1 then begin
								 nFirst := nIndex;
								 nLast  := nIndex;
							 end else begin
								 if nIndex = nFirst + 1 then begin
									 nLast := nIndex;
								 end else begin
									 SendDlgItemMessage(hLeconProc, idl_ListeQ, LB_SELITEMRANGE, Word(TRUE), MakeLong(nFirst, nLast));
									 nFirst := nIndex;
									 nLast  := nIndex;
								 end;
							 end;
					End;

					function Exist(P : PChar) : Boolean; Far;
					Begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+44, 0, 0, 0, nil, TRUE);
	{$ENDIF}

						Exist := StrComp(P, szPhase) = 0;
					End;

BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+45, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 DebugLessonCalled('Début AppelLecon');

		 { Sauvegarde le mode en cours }
		 if RecordingR then begin
			idBut := idb_RecordR;
		 end else begin
			 if PlayingQ then begin
				 if PlayingR then begin
					idBut := idb_PlayQR;
				 end else begin
					idBut := idb_PlayQ;
				 end;
			 end else begin
				 if PlayingR then begin
					idBut := idb_PlayR;
				 end else begin
					idBut := 0;
					idBut := idb_RecordR;
				 end;
			 end;
		 end;

		 { Force Mode Record }
		 {Attention à UM_RETOUR !!!}
		 {##################}
		 idBut := idb_RecordR;

		 { pointe sur l'appel en cours }
		 lpLessonCalledItem := nil;
		 If (pLstLessonCalled^.Count > 0) Then Begin
			 lpLessonCalledItem := PLessonCalledItem(pLstLessonCalled^.At(0));
			 Debug('Nombre d''appels > 0');
		 End else begin
			 Debug('Plus d''appels');
		 end;

		 { si pas d'appel en cours, on sort }
		 if lpLessonCalledItem = nil then begin
				 Debug('pLstLessonCalled^.Count = 0, lpLessonCalledItem := nil, plus d''appels à faire...');
				{Si la file d'attente est vide ... }
				bItsACall := FALSE;
				nNiveauPlay := 0;
				PostMessage(hMciQueueProc, mm_MciNotify, 0, 0);
				lpPrevAppelObj := nil;
				Exit; { ... on ne va pas plus loin }
		 End Else begin
				bItsACall := TRUE;
		 end;

		 { Vérifie que les séquence de lpSelection sont toujours valides }
		 nSel := SendDlgItemMessage(hLeconProc, idl_ListeQ, LB_GETSELCOUNT, 0, 0);
		 If bItsACall AND
				(lpLessonCalledItem <> nil) AND
				(lpLessonCalledItem^.lpSelection <> nil) Then begin
			 Debug('ItsACall & lpLessonCalledItem <> nil & lpSelection <> nil');
			 If (lpLessonCalledItem^.lpSelection^.Count < nSel) Then begin
				 Debug('lpSelection^.Count < LB_GETSELCOUNT, on ajoute les séquences à lpSelection...');
				 {pSels : Tableau d'entiers}
				 GetMem(pSels, nSel*SizeOf(Integer));

				 {remplissage de pSels}
				 nSel := SendDlgItemMessage(hLeconProc, idl_ListeQ, LB_GETSELITEMS, nSel, LongInt(pSels));

				 {Génération de la collection de chaines de caractères}
				 For i := nSel DownTo 1 Do Begin
					 wvsPrintF(szPhase, '%i', pSels^[i]);
					 if lpLessonCalledItem^.lpSelection^.Count = 0 then begin
						 lpLessonCalledItem^.lpSelection^.Insert(StrNew(szPhase));
					 end else begin
						 if lpLessonCalledItem^.lpSelection^.FirstThat(@Exist) = nil then begin
							 lpLessonCalledItem^.lpSelection^.AtInsert(0, StrNew(szPhase));
						 end;
					 end;
				 End;
				 {####If (lpLessonCalledItem^.lpSelection^.Count > 0) Then begin
					 WinProcs.MessageBox(GetActiveWindow, 'Lecon ', lpLessonCalledItem^.szLecon, ' ',
					 PChar(lpLessonCalledItem^.lpSelection^.At(0)));
					end else begin
					 WinProcs.MessageBox(GetActiveWindow, 'Lecon ', lpLessonCalledItem^.szLecon, ' nil');
				 end;}
				 FreeMem(pSels, nSel*SizeOf(Integer));
			 end else begin
				 Debug('lpSelection^.Count >= LB_GETSELCOUNT, on passe...');
			 end;
		 end else begin
			 Debug('!ItsACall | !lpLessonCalledItem <> nil | !lpSelection <> nil');
		 end;

		 { supprime l'appel en cours si plus de séquences à jouer }
		 If (lpLessonCalledItem <> nil) AND
				(lpLessonCalledItem^.lpSelection <> nil) AND
				(lpLessonCalledItem^.lpSelection^.Count = 0) AND
				(lpLessonCalledItem^.bAutoRet) Then begin
			 pLstLessonCalled^.AtFree(0);
			 Debug('lpSelection^.Count = 0, pLstLessonCalled^.AtFree(0)');
		 end else begin
			 Debug('lpSelection^.Count > 0');
		 end;

		 { Remet à jour l'appel en cours }
		 lpLessonCalledItem := nil;
		 If (pLstLessonCalled^.Count > 0) Then Begin
			 lpLessonCalledItem := PLessonCalledItem(pLstLessonCalled^.At(0));
			 Debug('pLstLessonCalled^.Count > 0');
		 End;

		 { si pas d'appel en cours, on sort }
		 if lpLessonCalledItem = nil then begin
				 Debug('pLstLessonCalled^.Count = 0, lpLessonCalledItem := nil, plus d''appels à faire...');
				{Si la file d'attente est vide ... }
				bItsACall := FALSE;
				nNiveauPlay := 0;
				PostMessage(hMciQueueProc, mm_MciNotify, 0, 0);
				lpPrevAppelObj := nil;
				Exit; { ... on ne va pas plus loin }
		 End Else begin
				bItsACall := TRUE;
		 end;

		 { Si leçon en cours <> de leçon précédemmant appelée }
		 if	(lpLessonCalledItem <> lpPrevAppelObj) OR
				(lpLessonCalledItem^.nNiveau > 0) then begin
			 Debug('lpLessonCalledItem <> lpPrevAppelObj');

			 {Vidange de la file d'attente du moteur MCI (Vidange tous les 5000!}
			 if RecordingR OR
					PlayingQ OR
					PlayingR Then begin
				 Debug('SimuleStop...');
				 SimuleStop;
			 end;

			 {récupération de la première leçon dans la file d'attente branchements,
				lpLessonCalledItem est déjà allouè, ne pas le détruire }
			 if lpLessonCalledItem <> nil then
					With lpLessonCalledItem^ Do Begin

					{Si Leçon déjà charger ne pas la recharger ... }
					bBadCall := FALSE;
					GetDlgItemText(hLeconProc, idl_Lecon, szCur, SizeOf(szCur));
					if StrComp(szLecon, szCur) <> 0 then begin
						Debug('Charger la bonne leçon...');
						{Sélectionne la leçon}
						lIndexSearch := SendDlgItemMessage(hLeconProc, idl_Lecon, CB_FINDSTRINGEXACT, 0, LongInt(@szLecon));
						If lIndexSearch <> CB_ERR Then Begin
						{changement de leçon}
							if hListBar <> 0 then SendDlgItemMessage(hListBar, idl_Lecon, CB_SETCURSEL, WORD(lIndexSearch), 0);
							SendDlgItemMessage(hLeconProc, idl_Lecon, CB_SETCURSEL, WORD(lIndexSearch), 0);
							bAutoSel := TRUE;
							{ Notifie du changement de leçon sans jouer la première séquence }
							if hListBar <> 0 then SendMessage(hListBar, WM_COMMAND, idl_Lecon, MakeLong(0, CBN_SELCHANGE));
							SendMessage(hLeconProc, WM_COMMAND, idl_Lecon, MakeLong(GetDlgItem(hLeconProc, idl_Lecon), CBN_SELCHANGE));
						end else begin
							WinProcs.MessageBox(GetActiveWindow, 'Leçon introuvable, branchement non valide.',
																	 szLecon, MB_OK OR MB_ICONEXCLAMATION);
							bBadCall := TRUE;
						end;
					end else begin
						Debug('Leçon déjà charger ne pas la recharger...');
					End;

					{Sélectionne les phases sauvée dans lpSelection}
					if NOT bBadCall AND (lpSelection <> nil) then begin
						nFirst := -1;
						nLast	 := -1;
						lpSelection^.ForEach(@SelectItem);
						if (nFirst > -1) AND (nLast > -1) then
							SendDlgItemMessage(hLeconProc, idl_ListeQ, LB_SELITEMRANGE, Word(TRUE), MakeLong(nFirst, nLast));
						Debug('Sélectionne les phases sauvée dans lpSelection');
					end else begin
						Debug('Aucune les phases sauvée dans lpSelection ( = nil)');
					end;

					{ On reprend son souffle... }
					 While PeekMessage(PeekMsg, 0, 0, 0, PM_REMOVE) do begin
						 TranslateMessage(PeekMsg);
						 DispatchMessage(PeekMsg);
					 end;
					 { ... c'est reparti }

					nLastPlay := nNiveau;
					bAutoSel := FALSE;
			 End;

			If pLstLessonCalled^.Count > 1 Then Begin
				 i := 0;
				 repeat
					 inc(i);
					 StrCopy(szLessonRet, (PLessonCalledItem(pLstLessonCalled^.At(i))^.szLecon));
				 until (PLessonCalledItem(pLstLessonCalled^.At(i))^.lpSelection^.Count > 0) OR
							 (i = pLstLessonCalled^.Count - 1);
					SetDlgItemText(hBoutonsProc, 607, szLessonRet);
					{SetWindowPos(GetDlgItem(hBoutonsProc, idb_Retour), 0, 0, 0, 0, 0, SWP_NOSIZE Or SWP_NOMOVE);}
					ShowWindow(GetDlgItem(hBoutonsProc, idb_Retour), SW_SHOW);
					ShowWindow(GetDlgItem(hBoutonsProc, idb_Quit), SW_HIDE);
					Debug('pLstLessonCalled^.Count > 1, montrer "Retour"');
			 End Else Begin
					{SetWindowPos(GetDlgItem(hBoutonsProc, idb_Quit), 0, 0, 0, 0, 0, SWP_NOSIZE Or SWP_NOMOVE);}
					ShowWindow(GetDlgItem(hBoutonsProc, idb_Quit), SW_SHOW);
					ShowWindow(GetDlgItem(hBoutonsProc, idb_Retour), SW_HIDE);
					SetDlgItemText(hBoutonsProc,607, mmLoadString(hInstRes, STR_QUITTER));
					Debug('pLstLessonCalled^.Count <= 1, montrer "Quitter"');
			 End;

			 { On reprend son souffle... }
			 While PeekMessage(PeekMsg, 0, 0, 0, PM_REMOVE) do begin
				 TranslateMessage(PeekMsg);
				 DispatchMessage(PeekMsg);
			 end;
			 { ... c'est reparti }

			 {Donne l'ordre de jouer}
			 if NOT RecordingR AND
					NOT PlayingQ AND
					NOT PlayingR AND
					NOT Pause Then begin
						Debug('Donne l''ordre de jouer, WM_COMMAND, idBut...');
						PostMessage(hBoutonsProc, WM_COMMAND, idBut, 0);
			 end;


		 end else begin
				{ on ne change pas de leçon }
				PostMessage(hMciQueueProc, mm_MciNotify, 0, 0);
				Debug('lpLessonCalledItem = lpPrevAppelObj, on ne change pas de leçon, mm_MciNotify');
		 end;

		 {Supprime le branchement de la liste si la sélection est vide, sinon,
			supprime le premier élément de la sélection}
		 If lpLessonCalledItem <> nil Then Begin
			 Debug('lpLessonCalledItem <> nil, lpPrevAppelObj := lpLessonCalledItem');
			 lpPrevAppelObj := lpLessonCalledItem;
			 If lpLessonCalledItem^.nNiveau > 0 Then begin
					Debug('nNiveau > 0, pLstLessonCalled^.ATFree(0)');
					pLstLessonCalled^.ATFree(0);
					{WinProcs.MessageBox(GetActiveWindow, 'pLstLessonCalled^.AtFree(0) sur nNiveau = 1');}
			 end else begin
					if lpLessonCalledItem^.lpSelection <> nil then begin
						If (lpLessonCalledItem^.lpSelection^.Count > 0) Then begin
							Debug('lpSelection^.Count > 0, lpSelection^.ATFree(0)');
							lpLessonCalledItem^.lpSelection^.AtFree(0);
						end;
					end;
			 end;
		 End;
		 {#### rétabli le curseur ici ... lopin trouvé ou issbloc...}
		 SetCursor(LoadCursor(0, idc_Arrow));

		 DebugLessonCalled('Fin AppelLecon');
END;

PROCEDURE TQcmWin.DebugLessonCalled(psz : PCHAR);
const
		i			: integer = 0;
		p			: PCHAR = nil;
		j			: integer = 0;



begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+46, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	{$IFNDEF _DEBUG}
		exit;
	{$ELSE}

		for i := 0 to pLstLessonCalled^.Count - 1 do begin
			p := @PLessonCalledItem(pLstLessonCalled^.At(i))^.szLecon;
			AddDebugText(DBG_TUTOR, '%d : %s', @i, TRUE);
			AddDebugText(DBG_TUTOR, ' Mode : %d', @PLessonCalledItem(pLstLessonCalled^.At(i))^.wMode, TRUE);
			AddDebugText(DBG_TUTOR, ' Niveau : %d', @PLessonCalledItem(pLstLessonCalled^.At(i))^.nNiveau, TRUE);
			AddDebugText(DBG_TUTOR, ' Selection : ', nil, TRUE);
			for j := 0 to PLessonCalledItem(pLstLessonCalled^.At(i))^.lpSelection^.Count - 1 do begin
				p := PLessonCalledItem(pLstLessonCalled^.At(i))^.lpSelection^.At(j);
				AddDebugText(DBG_TUTOR, '%s, ', @p, FALSE);
			end;
			AddDebugText(DBG_TUTOR, 'fin.', nil, TRUE);
		end;

	{$ENDIF}
END;

PROCEDURE TQcmWin.Debug(psz : PCHAR);

begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+47, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	{$IFNDEF _DEBUG}
		exit;
	{$ELSE}
		AddDebugText(DBG_TUTOR, psz, nil, TRUE);
	{$ENDIF}
END;

PROCEDURE TQcmWin.UMResetSel(Var Msg : TMessage);
var	lpLessonCalledItem : PLessonCalledItem;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+48, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	DebugLessonCalled('Début UMResetSel');
	If pLstLessonCalled^.Count > 0 Then begin
		lpLessonCalledItem := PLessonCalledItem(pLstLessonCalled^.At(0));
		if (lpLessonCalledItem <> nil) AND
			 (lpLessonCalledItem^.lpSelection <> nil) then begin
				while (lpLessonCalledItem^.lpSelection^.Count > 0) do begin
				 lpLessonCalledItem^.lpSelection^.AtFree(0);
				end;
		end;
	end;
	DebugLessonCalled('Fin UMResetSel');
end;

PROCEDURE TQcmWin.UMRetour(Var Msg : TMessage);
var	lpLessonCalledItem : PLessonCalledItem;
		dwRet		: DWORD;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+49, 0, 0, 0, nil, TRUE);
	{$ENDIF}


		 DebugLessonCalled('Début UMRetour');

		 bItsARet := TRUE;
		 SimuleStop;
		 { si on est dans un appel leçons }
		 If pLstLessonCalled^.Count > 0 Then begin
			 { si le niveau* de la leçon courante** appellée est 0 }
			 { 	*la première leçon appellante à le niveau 1,
					 les autres le niveau 0.}
			 { **la leçon courante est la première de la liste,
					 la première leçon appelée est la dernière de la liste,
					 on dépile par le haut.}
			 If (PLessonCalledItem(pLstLessonCalled^.At(0)))^.nNiveau = 0 Then begin
				 pLstLessonCalled^.AtFree(0);
				 {lpLessonCalledItem := PLessonCalledItem(pLstLessonCalled^.At(0));
				 if (lpLessonCalledItem <> nil) AND
						(lpLessonCalledItem^.lpSelection <> nil) then begin
						while (lpLessonCalledItem^.lpSelection^.Count > 0) do begin
						 lpLessonCalledItem^.lpSelection^.AtFree(0);
						end;
				 end;}
			 end;
		 end;
		 bItsARet := FALSE;
		 dwRet := SendDlgItemMessage(hLeconProc, idl_ListeQ, LB_GETCOUNT, 0, 0) - 1;
		 SendDlgItemMessage(hLeconProc, idl_ListeQ, LB_SELITEMRANGE, WORD(FALSE), MakeLong(WORD(0), WORD(dwRet)));

		 DebugLessonCalled('Fin UMRetour');

		 AppelLecon;

END;

PROCEDURE TQcmWin.ClearDocument;

					Procedure SupprObjet(TheObjetToSuppr : PMoveWindow);Far;
					Begin
						 Supprimer(TheObjetToSuppr);
					End;
BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+50, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 SendMessage(WintoolsHandle, UM_RESETOBJLIST, 0, 0);
		 if IsWindowVisible(HWindow) then ShowWindow(HWindow, SW_HIDE);
		 ForEach(@SupprObjet);
		 while lpColBranch^.Count > 0 do begin
			 lpColBranch^.AtFree(0)
		 end;
		 nBRep := 0;
		 NRepSon  := 0;
		 lpCollecSon^.Pack;
		 lpColBranch^.Pack;
END;

PROCEDURE TQcmWin.UpdateDocument;
					Procedure UpdateObject(P : PMoveWindow); Far;
					Begin
							 P^.Update;
					End;

					Procedure ValidateObject(P : PMoveWindow); Far;
					Begin
	if TypeOf(P^) =	TypeOf(TMoveWindow) then
		StrCopy(MainQcmWin^.szLineTexte, 'TMoveWindow')
	else if TypeOf(P^) = TypeOf(TBitmapWin) then
		StrCopy(MainQcmWin^.szLineTexte, 'Image')
	else if TypeOf(P^) = TypeOf(TRepClipWin) then
		wvsprintf(MainQcmWin^.szLineTexte, '%i-Zone', PReponseWin(P)^.nOrdBranch)
	else if TypeOf(P^) = TypeOf(TQcmStatic) then
		StrCopy(MainQcmWin^.szLineTexte, 'TQcmStatic')
	else if TypeOf(P^) = TypeOf(TRepSonWin) then
		wvsprintf(MainQcmWin^.szLineTexte, '%i-Son', PReponseWin(P)^.nOrdBranch)
	else if TypeOf(P^) = TypeOf(TDummyRepSonWin) then
		wvsprintf(MainQcmWin^.szLineTexte, '%i-Dummy Son', PReponseWin(P)^.nOrdBranch)
	else if TypeOf(P^) = TypeOf(TEditTexte) then
		StrCopy(MainQcmWin^.szLineTexte, 'TEditTexte')
	else if TypeOf(P^) = TypeOf(TRepTexteWin) then
		wvsprintf(MainQcmWin^.szLineTexte, '%i-Texte', PReponseWin(P)^.nOrdBranch)
	else if TypeOf(P^) = TypeOf(TObjetWin) then
		wvsprintf(MainQcmWin^.szLineTexte, '%i-Ole', PReponseWin(P)^.nOrdBranch)
	else if TypeOf(P^) = TypeOf(TReponseWin) then
		StrCopy(MainQcmWin^.szLineTexte, 'TReponseWin')
	else if TypeOf(P^) = TypeOf(TDummyReponseWin) then
		StrCopy(MainQcmWin^.szLineTexte, 'TDummyReponseWin')
	else if TypeOf(P^) = TypeOf(TDummy) then
		wvsprintf(MainQcmWin^.szLineTexte, '%i-Trou', PReponseWin(P)^.nOrdBranch)
	else if TypeOf(P^) = TypeOf(THole) then
		wvsprintf(MainQcmWin^.szLineTexte, '%i-THole', PReponseWin(P)^.nOrdBranch)
	else if TypeOf(P^) = TypeOf(TDummies) then
		StrCopy(MainQcmWin^.szLineTexte, 'TDummies')
	else if TypeOf(P^) = TypeOf(THyperLink) then
		wvsprintf(MainQcmWin^.szLineTexte, '%i-Hyper Lien', PReponseWin(P)^.nOrdBranch)
	else StrCopy(MainQcmWin^.szLineTexte, '<Inconnu>');
	SendMessage(WintoolsHandle, UM_ADDOBJLIST, 0, longint(P));
					End;
BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+51, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 {Mise à jour de tous les objets OLE de la fenêtre}
		 ForEach(@UpdateObject);
		 lpColBranch^.ForEach(@ValidateObject);
		 SendMessage(GetParent(HWindow), WM_SIZE, 0, 0);
		 if NOT IsWindowVisible(HWindow) then begin
				ShowWindow(HWindow, SW_SHOW);
		 end;
END;

PROCEDURE TQcmWin.ErrorMessage(AWindow : HWnd; IdMessage : WOrd);
VAR
	 szMessTexte, szMessTitre : TStr256;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+52, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 LoadString(hInstRes, IdMessage, szMessTexte, MAX_STRLOAD);
		 LoadString(hInstRes, IDM_TITRE, szMessTitre, MAX_STRLOAD);
		 WinProcs.MessageBox(AWindow, szMessTexte, szMessTitre, MB_ICONSTOP Or MB_OK);
END;

PROCEDURE TQcmWin.DoneDocument;
					Procedure FreeObjectWindow(P : PMoveWindow); Far;
					Begin
							 if p <> nil then p^.Free;
					End;
BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+53, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 ForEach(@FreeObjectWindow);
		 {####Check(OleRevokeClientDoc(ClientDoc));}
		 OleRevokeClientDoc(ClientDoc);
END;

FUNCTION TQcmWin.CanClose : Boolean;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+54, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 SndPlaySound(Nil, SND_ASYNC);
		 If(nColorLine = 0) Then Begin
        CanClose := TRUE;
     End Else CanClose := FALSE;
END;

DESTRUCTOR TQcmWin.Done;
BEGIN
		 If lpRepCollection <> Nil Then Dispose(lpRepCollection, Done);
		 If pLstLessonCalled    <> Nil Then Dispose(pLstLessonCalled, Done);
		 KillTimer(HWindow, ID_TIMER);
		 DoneDocument;
		 lpColBranch^.DeleteAll;
		 If lpColBranch <> Nil Then begin
			 Dispose(lpColBranch, Done);
			 lpColBranch := nil;
		 end;
		 If lpCollecSon <> Nil Then begin
			 Dispose(lpCollecSon, Done);
			 lpCollecSon := nil;
		 end;
{     StrDispose(szNomFichier);}
		 TWindow.Done;
END;


{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{~~~~~~~~~~~~~~~~~~~~~Implémentation de TMoveWindow~~~~~~~~~~~~~~~~~~~~~~~}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

CONSTRUCTOR TMoveWindow.Init(AParent : PQcmWin; ATexte : PChar; AX, AY : Integer);
BEGIN
		 TWindow.Init(AParent, Atexte);
		 StrCopy(szLinkedFile, '');
		 With Attr Do begin
					x := (AX DIV PAS_GRILLE) * PAS_GRILLE;
					y := (AY DIV PAS_GRILLE) * PAS_GRILLE;
					w := 320;
					h := 240;
					Style := WS_CHILD OR WS_VISIBLE OR WS_CLIPSIBLINGS{OR WS_CLIPCHILDREN};
		End;
		 OleObject := nil;
		 bCreateFromFile := FALSE;
		 bQueryBounds := FALSE;
		 if (MainQcmWin^.lpReponse <> nil) AND
				(MainQcmWin^.lpReponse^.wTypeRep <> CT_BITMAP) then begin
			 bBorder := MainQcmWin^.lpReponse^.bBorder;
		 end else begin
			 bBorder := FALSE;
		 end;
		 If bBorder Then begin
				Attr.Style := Attr.Style OR WS_BORDER;
		 end else begin
				Attr.Style := Attr.Style AND NOT WS_BORDER;
		 end;
		 bLoaded := FALSE;
		 lpParentWin := AParent;
END;

CONSTRUCTOR TMoveWindow.Load(Var S : TStream);
VAR
	 AppStream	: TAppStream;
	 szNotOle   : Array[0..6] of char;
	 NotOlePos	: Longint;
	 Dir				: array[0..fsDirectory] of Char;
	 Name				: array[0..fsFileName] of Char;
	 Ext				: array[0..fsExtension] of Char;

BEGIN
		 bCreateFromFile := FALSE;
		 bQueryBounds := FALSE;
		 bLoaded := FALSE;
		 TWindow.load(S);
	 { recalcule la position de la fenêtre TWindow.Store Stocke les coordonnées client...}
		 StrCopy(szLinkedFile, '');
		 OleObject := nil;
		 NotOlePos := S.GetPos;
		 S.Read(szNotOle, 6);
		 szNotOle[6] := #0;
		 if StrComp(szNotOle, 'NOTOLE') = 0 then begin
			 S.Read(szLinkedFile, SizeOf(szLinkedFile));
			 { si la lecon a changer, met à jours le chemin }
			 if StrLComp(tLecon.PathLecon, szLinkedFile, StrLen(tLecon.PathLecon)) <> 0 then begin
				 FileSplit(szLinkedFile, Dir, Name, Ext);
				 StrECopy(StrECopy(StrECopy(StrECopy(szLinkedFile, tLecon.PathLecon), '\'), Name), Ext);
			 end;
		 end else begin
			 S.Seek(NotOlePos);
			 AppStream.OleStream.lpsTbl := @OleStreamVTbl;
			 AppStream.OwlStream := @S;
			 Check('OleLoadFromStream',  OleLoadFromStream(@AppStream.OleStream, OleProtocol,
						 @AppClient.OleClient, MainQcmWin^.ClientDoc, OleObjectName,
						 OleObject));
		 end;
		 S.Read(bBorder, SizeOf(bBorder));
		 If bBorder Then begin
				Attr.Style := Attr.Style OR WS_BORDER;
		 end else begin
				Attr.Style := Attr.Style AND NOT WS_BORDER;
		 end;
		 Attr.Style := Attr.Style OR WS_VISIBLE;
END;

PROCEDURE TMoveWindow.Store(Var S : TStream);
CONST	 NOTOLE : Array[0..5] of char =	'NOTOLE';
VAR
	 AppStream : TAppStream;
	 hData 			: THandle;
	 lp 				: Pointer;
	 hNewData 	: THandle;
	 lpNew			: Pointer;
	 i,
	 p1, p2, p3 : PCHAR;
	 szNewFile  : szLongName;

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+55, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TWindow.Store(S);

		 if (szLinkedFile[0] <> #0) then begin
			 S.Write(NOTOLE, 6);
			 S.Write(szLinkedFile, SizeOf(szLinkedFile));

		 end else begin

			 AppStream.OleStream.lpsTbl := @OleStreamVTbl;
			 AppStream.OWlStream := @S;

			 if OleObject <> nil then begin

				 { Recopie le fichier lié à l'objet OLE de classe MPlayer dans le répertoire de la leçon
					et met à jour le lien dans l'objet OLE}
				 {OleGetData(OleObject, CFOwnerLink, hData);
				 if hData <> 0 then begin
						WriteLn('CFOwnerLink : ', hData);
					 lp := GlobalLock(hData);
					 if (StrIComp(PChar(lp), 'mplayer') = 0) then begin
						 GlobalUnlock(hData);
						 OleGetData(OleObject, CFNative, hData);
						 WriteLn('CFNative : ', hData);
						 if hData <> 0 then begin
							 lp := GlobalLock(hData);
							 p1 := PChar(lp);
							 p2 := PChar(@p1[StrLen(p1) + 1]);
							 p3 := PChar(@p2[StrLen(p2) + 1]);
							 WriteLn(p1, ', ', p2, ', ', p3);
							 if NOT IsInCurLesson(p2) then begin
								 StrCopy(szNewFile, p2);
								 if CopyInCurLesson(szNewFile, QCM0000, 0) then begin
									 hNewData := GlobalAlloc(GMEM_SHARE OR GMEM_ZEROINIT, StrLen(p1) + StrLen(szNewFile) + StrLen(p2) + 4);
									 lpNew := GlobalLock(hNewData);
									 StrCopy(PCHAR(lpNew), p1);
									 StrCopy(PCHAR(@PCHAR(lpNew)[StrLen(p1) + 1]), szNewFile);
									 StrCopy(PCHAR(@PCHAR(lpNew)[StrLen(p1) + StrLen(szNewFile) + 2]), p3);
									 GlobalUnlock(hNewData);
									 OleSetData(OleObject, CFNative, hNewData);
								 end;
							 end;
						 end;
					 end;
					 GlobalUnlock(hData);
				 end;}

				 Check('OleSaveToStream', OleSaveToStream(OleObject, @AppStream.OleStream));

			 end else begin
				 WinProcs.MessageBox(GetActiveWindow, 'Erreur OleObject = nil...', '', 0);
			 end;
		 end;
		 S.Write(bBorder, SizeOf(bBorder));

END;

Procedure TMoveWindow.UMOleValidate(Var Msg : TMessage);
VAR
	 res  	  : TOleStatus;
	 Hdata  	: THandle;
	 pSelf		: PMoveWindow;

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+56, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 if OleObject <> nil then begin
		 res := Check('OleGetData', OleGetData(OleObject, CFNATIVE, Hdata));
	 end else begin
		 WinProcs.MessageBox(GetActiveWindow, 'Objet Ole inexistant', 'OLE Validation', MB_OK OR MB_APPLMODAL);
		 res := Succ(Ole_OK);
	 end;
	 if res <> Ole_OK then begin
		 pSelf := PMoveWindow(@Self);
		 MainQcmWin^.Supprimer(pSelf);
	 end;
END;

Procedure TMoveWindow.UMSaveToFile(Var Msg : TMessage);
var nRet		: integer;
		PeekMsg	: TMSG;
		hData   : THANDLE;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+57, 0, 0, 0, nil, TRUE);
	{$ENDIF}


	{if (OleObject <> nil) AND
		 (OleQueryOpen(OleObject) <> OLE_OK) Then begin
		MessageBox(GetActiveWindow, 'Erreur', 'Création Objet OLE', MB_OK);
	end;}

	if (wTypeRep = CT_BITMAP) then begin
		if szLinkedFile[0] = #0 then begin
			NewQcmBmpFile(szLinkedFile, 0);
		end;
	end;
	if (wTypeRep = CT_SON) then begin
		if szLinkedFile[0] = #0 then begin
			NewQcmWavFile(szLinkedFile, 0);
		end;
	end;
	if szLinkedFile[0] <> #0 then begin
		{ termine la tâche Ole en cours }
		while OleQueryReleaseStatus(OleObject) = OLE_BUSY do begin
			if GetMessage(PeekMsg, 0, 0, 0) then begin
				TranslateMessage(PeekMsg);
				DispatchMessage(PeekMsg);
			end;
		end;
		nRet := OleSaveToFile(szLinkedFile);
		if nRet = -1 then begin
			While PeekMessage(PeekMsg, 0, 0, 0, PM_REMOVE) do begin
				TranslateMessage(PeekMsg);
				DispatchMessage(PeekMsg);
			end;
			nRet := OleSaveToFile(szLinkedFile);
		end;
		while nRet = -1 do begin
			nRet := WinProcs.MessageBox(Window,
												 'Impossible de sauver le fichier',
												 'Erreur',
												 MB_RETRYCANCEL OR MB_ICONQUESTION OR MB_APPLMODAL);
			if nRet = IDCANCEL then begin
				nRet := 0;
			end else begin
				nRet := OleSaveToFile(szLinkedFile);
			end;
		end;
		{ invalide l'image modifiée }
		if (wTypeRep = CT_BITMAP) then begin
			if PBitmapWin(@Self)^.hdib <> 0 then ReleaseBitmap(PBitmapWin(@Self)^.hdib);
			if PBitmapWin(@Self)^.di.hdd <> 0 then DrawDibClose(PBitmapWin(@Self)^.di.hdd);
			PBitmapWin(@Self)^.hdib := 0;
			PBitmapWin(@Self)^.di.hdib := 0;
			PBitmapWin(@Self)^.di.hdd := 0;
			SendMessage(PBitmapWin(@Self)^.HWindow, WM_QUERYNEWPALETTE, 0, 0);
		end;
	end;
end;

Function TMoveWindow.OleSaveToFile(FileName : PChar) : Integer;
VAR
	 res  	  : TOleStatus;
	 Hdata  	: THandle;
	 FP				: Integer;

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+58, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 OleSaveToFile := -1;

	 if OleObject = nil then exit;

	 res := Check('OleGetData', OleGetData(OleObject, CFNATIVE, Hdata));
	 if res <> Ole_OK then Exit;

	 FP := _lcreat(FileName, 0);
	 if FP = -1 then Exit;
	 OleSaveToFile := HugeIO(_lwrite, FP, GlobalLock(HData), GlobalSize(HData)) - 1;
	 GlobalUnlock(HData);
	 _lclose(FP);
END;

PROCEDURE TMoveWindow.OleAlign;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+59, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		if OleObject = nil then exit;

		if (wTypeRep = CT_BITMAP) OR
			 (wTypeRep = CT_AUTRE) then begin
			if OleQueryBounds(OleObject, rect) = OLE_OK then begin
				 Attr.W := MulDiv(rect.Right, PixPerInch.X, 2540);
				 Attr.H := MulDiv(-rect.Bottom, PixPerInch.Y, 2540);
				 if wTypeRep = CT_AUTRE then begin
						inc(Attr.W, PAS_GRILLE * 6);
						inc(Attr.H, PAS_GRILLE * 2);
				 end;
				 if wTypeRep = CT_BITMAP then begin
						inc(Attr.H, PAS_GRILLE);
						inc(Attr.W, PAS_GRILLE);
				 end;
				 SetWindowPos(HWindow, 0, 0, 0, Attr.W, Attr.H,
					SWP_NOZORDER OR SWP_NOMOVE OR SWP_NOACTIVATE);
			end else begin
				 Attr.W := 94;
				 Attr.H := 94;
				 if wTypeRep = CT_AUTRE then begin
						inc(Attr.W, PAS_GRILLE * 6);
						inc(Attr.H, PAS_GRILLE * 2);
				 end;
				 SetWindowPos(HWindow, 0, 0, 0, Attr.W, Attr.H,
					SWP_NOZORDER OR SWP_NOMOVE OR SWP_NOACTIVATE);
			end;
		end;
END;
procedure TMoveWindow.OleError(pszErrTitle : PChar; OleStatus : TOleStatus);
const

pszOleErr : array[0..56] of PChar = (
'Function operated correctly',
'Command has been initiated, client must wait for release. keep dispatching messages till ole_RELEASE in callback',
'Tried to execute a method while another method is in progress.',
'Ole APIs are called in real mode',
'Could not alloc or lock memory',
'(TOleStream) stream error',
'Non static object expected',
'Critical data missing',
'Error while drawing',
'Invalid metafile',
'Client chose to abort metafile drawing',
'Failed to get/set clipboard data',
'Requested format is not available',
'Not a valid object',
'Invalid option (link update / render)',
'Invalid protocol',
'One of the pointers is invalid',
'Objects are not equal',
'Invalid handle encountered',
'Some general error',
'Invalid class',
'Command syntax is invalid',
'Data format is not supported',
'Invalid color palette',
'Not a linked object',
'Client doc contains objects.',
'Incorrect buffer size passed to the api that places some string in caller''s buffer',
'Drive letter in doc name is invalid',
'Failed to establish connection to a network share on which the document is located',
'Invalid name (doc name, object name), etc.. passed to the APIs',
'Server failed to load template',
'Server failed to create new doc',
'Server failed to create embedded instance',
'Server failed to open document, possible invalid link',
'Object is not open for editing',
'Failed to launch server',
'Failed to communicate with server',
'Error in termination',
'Error in execute',
'Error in show',
'Error in sending do verb, or invalid verb',
'Item could be missing',
'Item could be missing or server doesn''t this format.',
'Server doesn''t support rename',
'Failure of poking native data to server',
'Server failed to render native data',
'Server failed to render presentation data',
'Trying to block a blocked server or trying to revoke a blocked server or document',
'Server is not registered in regestration data base',
'Trying to register same doc multiple times',
'Server or client task is invalid',
'Object is out of date',
'Embed doc''s client doesn''t accept  updates',
'error while trying to update',
'Server app doesn''t understand the format given to its SetData method',
'trying to load a static object created on another Operating System Following are warnings',
'Caller must delete the data when done with it.');

{pszOleMeth : array[0..21] of PChar = (
'No method active',
'Object delete',
'PasteLink (auto reconnect)',
'Paste (and update) ',
'Show',
'Run',
'Activate',
'Update',
'Close',
'Reconnect',
'Setting update options',
'Server is being unlaunched',
'LoadFromStream (auto reconnect)',
'OleSetData',
'OleRequestData',
'Other misc async operations',
'Create',
'CreatefromTemplate',
'CreateLinkFromFile',
'CopyFromLink (auto reconnect)',
'CreateFromFile',
'CreateInvisible');
var szErrMsg : array[0..255]of char;}

begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+60, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	if OleStatus = 1000 then OleStatus := 56;
	{StrCopy(szErrMsg, pszOleMeth[OleQueryReleaseMethod(OleObject)]);
	StrCat(szErrMsg, ' : ');
	StrCat(szErrMsg, pszOleErr[OleStatus]);
	WinProcs.MessageBox(window, szErrMsg, pszErrTitle, MB_APPLMODAL OR MB_ICONSTOP);}
	MessageBeep(MB_ICONSTOP);
	WinProcs.MessageBox(window, pszOleErr[OleStatus], pszErrTitle, MB_APPLMODAL OR MB_ICONSTOP);
end;

PROCEDURE TMoveWindow.SetupWindow;
var r,
		rWin : TRECT;

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+61, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	TWindow.SetupWindow;

	if bCreateFromFile then begin
		{if IsVideoFile(Attr.Title) OR
			 IsSoundFile(Attr.Title) then begin
			CopyInCurLesson(Attr.Title, QCM0000, 0);
			Check('OleCreateFromFile', OleCreateFromFile(OleProtocol, @AppClient.OleClient, 'mplayer', Attr.Title,
						lpParentWin^.ClientDoc, OleObjectName, OleObject, olerender_Draw , 0));
			MessageBox(0, '', '', 0);
		end else begin
			Check('OleCreateFromFile', OleCreateFromFile(OleProtocol, @AppClient.OleClient, Nil, Attr.Title,
						lpParentWin^.ClientDoc, OleObjectName, OleObject, olerender_Draw , 0));
		end;}
			Check('OleCreateFromFile', OleCreateFromFile(OleProtocol, @AppClient.OleClient, Nil, Attr.Title,
						lpParentWin^.ClientDoc, OleObjectName, OleObject, olerender_Draw , 0));

		bCreateFromFile := FALSE;
		OleAlign;
	end;

	bLoaded := TRUE;
END;

FUNCTION TMoveWindow.GetClassName : PChar;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+62, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 GetClassName := 'CMoveWindow';
END;

PROCEDURE TMoveWindow.GetWindowClass(Var AWindowClass : TWndClass);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+63, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TWindow.GetWindowClass(AWindowClass);
		 With AWindowClass Do
					Begin
					{Réponse au bouble click possible par ce style}
					hBrBackground := GetStockObject(NULL_BRUSH);{COLOR_ACTIVECAPTION + 1;}
					Style := Style Or CS_DBLCLKS;
					End;
END;

function TMoveWindow.Check(pszErrTitle : PChar; OleStatus : TOleStatus) : TOleStatus;
VAR
	 M		: TMsg;
	 nRet	: integer;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+64, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 If (OleStatus = ole_Wait_For_Release) then begin
				Repeat
					OleStatus := OleQueryReleaseStatus(OleObject);
					if (OleStatus = ole_Busy) then begin
						 if GetMessage(M, 0, 0, 0) Then Begin
								If (M.Message = WM_QUIT) then begin
									nRet := WinProcs.MessageBox(Window,
													'Processus OLE en cours, voulez vous vraiment quitter l''application ?',
													'Attention',
													 MB_YESNO OR MB_ICONQUESTION OR MB_APPLMODAL);
									if (nRet = IDYES) then begin
										Break;
									end;
								end;
								TranslateMessage(M);
								DispatchMessage(M);
						 end;
					end;
				Until (OleStatus <> ole_Busy);
		 end else begin
			 if (OleStatus <> OLE_OK) then begin
					MainQcmWin^.Enable(TRUE);
					OleError(pszErrTitle, OleStatus);
					Check := OleStatus;
					Exit;
			 end;
		 end;
		 if OleStatus <> OLE_OK then begin
				MainQcmWin^.Enable(TRUE);
				WinProcs.MessageBox(GetActiveWindow, 'La transaction OLE a échouée.', 'OLE', MB_APPLMODAL);
				OleError(pszErrTitle, OleStatus);
		 end;
		 Check := OleStatus;
END;

PROCEDURE TMoveWindow.Update;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+65, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	if OleObject <> nil then Check('OleUpdate', OleUpdate(OleObject));
END;

FUNCTION TMoveWindow.InitOleObject : Boolean;
VAR
	 OldCursor : hCursor;
	 szClassOle : PChar;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+66, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 InitOleObject := FALSE;
		 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
		 AppClient.OleClient.lpvtbl := @OleClientVTbl;
		 AppClient.ObjectWindow := @Self;
		 OleObject := nil;
		 If Attr.Title[0] <> ' ' Then Begin
				bCreateFromFile := TRUE;
				InitOleObject := TRUE;
		 End Else InitOleObject := FALSE;
		 SetCursor(OldCursor);
END;

PROCEDURE TMoveWindow.OpenObject(wVerb : Word);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+67, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	if OleObject <> nil then Check('OleActivate', OleActivate(OleObject, wVerb, TRUE, TRUE, 0, Nil));
END;

PROCEDURE TMoveWindow.CloseObject;
var PeekMsg : TMSG;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+68, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	If (OleObject <> nil ) AND
		 (OleQueryOpen(OleObject) = OLE_OK) Then begin
		if GetMessage(PeekMsg, 0, 0, 0) then begin
			TranslateMessage(PeekMsg);
			DispatchMessage(PeekMsg);
		end;
		Check('OleClose', OleClose(OleObject));
	end;
END;

PROCEDURE TMoveWindow.Delete;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+69, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 {Permet de s'assurer que la fenêtre de l'objet n'est pas sélectionnée}
		 MainQcmWin^.SelectWindow(Nil);
		 CloseObject;
	 {WinProcs.MessageBox(GetActiveWindow,'TMoveWindow.Delete Close Object', '', MB_APPLMODAL);}
		 if OleObject <> nil then Check('OleDelete', OleDelete(OleObject));
		 OleObject := Nil;
	 {WinProcs.MessageBox(GetActiveWindow,'TMoveWindow.Delete OleDelete Object', '', MB_APPLMODAL);}
		 Free;
	 {WinProcs.MessageBox(GetActiveWindow,'TMoveWindow.Delete Free', '', MB_APPLMODAL);}
END;

PROCEDURE TMoveWindow.WMEraseBkGnd(Var Msg : TMessage);{WM_EraseBkGnd}
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+70, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Msg.Result := -1;
	DefWndProc(Msg);
end;

PROCEDURE TMoveWindow.WMNCLButtonDown(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+71, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	DefWndProc(Msg);
	SendMessage(HWindow, WM_LButtonDown, 0, Msg.lParam);
END;

PROCEDURE TMoveWindow.WMNCMouseMove(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+72, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	DefWndProc(Msg);
	SendMessage(HWindow, WM_MouseMove, 0, Msg.lParam);
END;

PROCEDURE TMoveWindow.WMNCLButtonUp(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+73, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	DefWndProc(Msg);
	SendMessage(HWindow, WM_LButtonUp, 0, Msg.lParam);
END;

PROCEDURE TMoveWindow.WMNCLButtonDblClk(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+74, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	DefWndProc(Msg);
	SendMessage(HWindow, WM_LButtonDblClk, 0, Msg.lParam);
END;

Procedure TMoveWindow.WMNCHitTest(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+75, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	if MainQcmWin^.wMode = M_MAKE then begin

		Msg.Result := MMLavac.ProcessHitTest(HWindow, Msg.message, Msg.wParam, Msg.lParam);

	end else begin

		DefWndProc(Msg);

	end;
END;

PROCEDURE TMoveWindow.WMActivate(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+76, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 DefWndProc(Msg);
END;

PROCEDURE TMoveWindow.WMGetMinMaxInfo(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+77, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 PMinMaxInfo(Msg.lParam)^.ptMaxSize.X 		 := GetSystemMetrics(SM_CXFULLSCREEN);
		 PMinMaxInfo(Msg.lParam)^.ptMaxSize.Y 		 := GetSystemMetrics(SM_CYFULLSCREEN);
		 PMinMaxInfo(Msg.lParam)^.ptMaxPosition.X  := GetSystemMetrics(SM_CXFULLSCREEN);
		 PMinMaxInfo(Msg.lParam)^.ptMaxPosition.Y  := GetSystemMetrics(SM_CYFULLSCREEN);
		 PMinMaxInfo(Msg.lParam)^.ptMaxTrackSize.X := GetSystemMetrics(SM_CXFULLSCREEN);
		 PMinMaxInfo(Msg.lParam)^.ptMaxTrackSize.Y := GetSystemMetrics(SM_CYFULLSCREEN);
		 PMinMaxInfo(Msg.lParam)^.ptMinTrackSize.X := 24;
		 PMinMaxInfo(Msg.lParam)^.ptMinTrackSize.Y := 24;
END;

PROCEDURE TMoveWindow.Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+78, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 Inherited Paint(PaintDC, PaintInfo);
END;

PROCEDURE TMoveWindow.ShowHandle(PaintDC : hDC);
var rc	: TRECT;
		i   : integer;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+79, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 if (MainQcmWin^.wMode = M_MAKE) AND
			(MainQcmWin^.lpReponse = @Self) then begin
			MMLavac.ShowHandle(PaintDC, HWindow);
	 end;
END;

function FindDummyByObj(hWin : HWND; Dummy : TDummyRec; wParam : WORD; lParam : DWORD) : Boolean; far;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+80, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	FindDummyByObj := Dummy.lpDummy = PDummy(lParam);
end;

PROCEDURE TMoveWindow.UpdateHandle;
var Dummy	: TDummyRec;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+81, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 if (MainQcmWin^.wMode = M_MAKE) AND
			(MainQcmWin^.lpReponse = @Self) then begin

		 if (MainQcmWin^.lpReponse^.wTypeRep = CT_DUMMY) OR
				(MainQcmWin^.lpReponse^.wTypeRep = CT_HYPERLINK) then begin
			 PRepTexteWin(MainQcmWin^.lpReponse^.Parent)^.lpEdit^.EnumDummy(FindDummyByObj, 0, DWORD(MainQcmWin^.lpReponse), Dummy);
			 if Dummy.lpDummy <> nil then begin
				 InvalidateRect(PRepTexteWin(MainQcmWin^.lpReponse^.Parent)^.lpEdit^.HWindow, @Dummy.rc, TRUE);
				 InvalidateRect(PRepTexteWin(MainQcmWin^.lpReponse^.Parent)^.lpEdit^.HWindow, @Dummy.rc2, TRUE);
				 InvalidateRect(PRepTexteWin(MainQcmWin^.lpReponse^.Parent)^.lpEdit^.HWindow, @Dummy.rc3, TRUE);
			 end;
		 end else begin
			 MMLavac.UpdateHandle(HWindow);
		 end;
	 end;
END;

PROCEDURE TMoveWindow.WMLButtonDown(Var Msg : TMessage); {WM_LButtonDown}
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+82, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 MainQcmWin^.SelectWindow(@self);
	 If bLoaded Then SetTypeRep;
	 MainQcmWin^.UpdateLineTexte(-1);
	 SendMessage(HWindow, WM_QUERYNEWPALETTE, 0, 0);
END;

PROCEDURE TMoveWindow.WMMove(Var Msg : TMessage);
VAR
	 UpdateRect : TRECT;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+83, 0, 0, 0, nil, TRUE);
	{$ENDIF}


	Inherited WMMove(Msg);

	If (wTypeRep = CT_CLIP) AND (MainQcmWin^.wMode = M_MAKE) then begin
		GetWindowRect(HWindow, UpdateRect);
		MapWindowPoints(HWND_DESKTOP, Parent^.HWindow, UpdateRect, 2);
		InvalidateRect(Parent^.HWindow, @UpdateRect, FALSE);
	end;

	SendMessage(MainQcmWin^.HWindow, UM_MOVECHILD, HWindow, MakeLong(Word(Attr.X),Word(Attr.Y)));
END;

PROCEDURE TMoveWindow.WMWindowPosChanging(Var Msg : TMessage); {WM_WINDOWPOSCHANGING TWINDOWPOS}
var r 	 : TRECT;
		hWin : HWND;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+84, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	if (MainQcmWin^.wMode = M_MAKE) AND
		 (wTypeRep <> CT_CLIP) then begin
		if MainQcmWin^.bGrid then begin
			PWINDOWPOS(Msg.lParam)^.x := (PWINDOWPOS(Msg.lParam)^.x + PAS_GRILLE DIV 2)
																	 DIV PAS_GRILLE * PAS_GRILLE;
			PWINDOWPOS(Msg.lParam)^.y := (PWINDOWPOS(Msg.lParam)^.y + PAS_GRILLE DIV 2)
																	 DIV PAS_GRILLE * PAS_GRILLE;
			PWINDOWPOS(Msg.lParam)^.cx := (PWINDOWPOS(Msg.lParam)^.cx) DIV PAS_GRILLE * PAS_GRILLE;
			PWINDOWPOS(Msg.lParam)^.cy := (PWINDOWPOS(Msg.lParam)^.cy) DIV PAS_GRILLE * PAS_GRILLE;
		end;
		if MainQcmWin^.bChangeZOrder then begin
			MainQcmWin^.bChangeZOrder := FALSE;
		end else begin
			hWin := GetWindow(HWindow, GW_HWNDPREV);
			if hWin <> 0 then begin
				 PWINDOWPOS(Msg.lParam)^.hWndInsertAfter := hWin;
			end;
		end;
	end;
	GetClientRect(Parent^.HWindow, r);
	if (PWINDOWPOS(Msg.lParam)^.x > r.right) OR
		 (PWINDOWPOS(Msg.lParam)^.y > r.bottom) then begin
		PWINDOWPOS(Msg.lParam)^.x := r.right - 20;
		PWINDOWPOS(Msg.lParam)^.y := r.bottom - 20;
		{####WriteLn(HWindow, ' cx ', PWINDOWPOS(Msg.lParam)^.cx,
										 ' cy ', PWINDOWPOS(Msg.lParam)^.cy,
										 ' x ', PWINDOWPOS(Msg.lParam)^.x,
										 ' y ', PWINDOWPOS(Msg.lParam)^.y);
		WriteLn(Parent^.HWindow, 'Parent rect ', r.left, ' ', r.top, ' ', r.right, ' ', r.bottom);}
		MessageBeep(WORD(-1));
	end;
	PWINDOWPOS(Msg.lParam)^.flags := PWINDOWPOS(Msg.lParam)^.flags OR SWP_NOACTIVATE;
	DefWndProc(Msg);
end;

PROCEDURE TMoveWindow.WMSize(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+85, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		Inherited WMSize(Msg);
		MainQcmWin^.UpdateLineTexte(-1);
END;

PROCEDURE TMoveWindow.BringToFront	;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+86, 0, 0, 0, nil, TRUE);
	{$ENDIF}

     {Place la fenêtre en premier plan}
		 MainQcmWin^.bChangeZOrder := TRUE;
		 SetWindowPos(HWindow, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE OR SWP_NOSIZE OR SWP_NOACTIVATE);
		 {SWP_NOMOVE : ignore les paramètre X et Y,
     SWP_NOSIZE : ignore les paramètres cX et CY. Voilà pourquoi ces
		 paramètres sont à 0}
END;

PROCEDURE TMoveWindow.GetBounds(Var R : TRect);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+87, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 {retourne les coordonnées de la fenêtre dans les coordonnées de la mère}
		 GetWindowRect(HWindow, R);
		 ScreenToClient(Parent^.HWindow, PPoint(@R.Left)^);
		 ScreenToClient(Parent^.HWindow, PPoint(@R.Right)^);
END;

PROCEDURE TMoveWindow.SetBounds(Var rNew : TRect);
VAR
	 rCur 	: TRect;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+88, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 GetBounds(rCur);
		 if	(rNew.left <> rCur.left) OR
				(rNew.top <> rCur.top) OR
				(rNew.right <> rCur.right) OR
				(rNew.bottom <> rCur.bottom) then begin
			 SetWindowPos(HWindow, 0, rNew.Left, rNew.Top, rNew.Right - rNew.Left, rNew.Bottom - rNew.Top,
					SWP_NOZORDER OR SWP_NOACTIVATE OR SWP_NOREDRAW);
		 end;
END;

PROCEDURE TMoveWindow.SetTypeRep;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+89, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 {Met à jour le boutons radio correspondant au type de fenêtre
     Procedure surchargée pour chaque type descendant}
END;

PROCEDURE TMoveWindow.SetLineTexte;
CONST
	 szCo : szLongName = '';
	 cRect : TRect =();
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+90, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 GetClientRect(HWindow, cRect);
		 wvsPrintF(MainQcmWin^.szCoord, ' X : %i  ', Attr.X);
		 wvsPrintF(szCo, 'Y : %i  ', Attr.Y);
		 StrCat(MainQcmWin^.szCoord, szCo);
		 wvsPrintF(szCo, 'L : %i  ', cRect.Right);
		 StrCat(MainQcmWin^.szCoord, szCo);
		 wvsPrintF(szCo, 'H : %i  ', cRect.Bottom);
		 StrCat(MainQcmWin^.szCoord, szCo);
END;

DESTRUCTOR TMoveWindow.Done;
BEGIN
		CloseObject;
		if OleObject <> nil then Check('OleRelease', OleRelease(OleObject));
		OleObject := Nil;
		Inherited Done;
	 {WinProcs.MessageBox(GetActiveWindow,'TMoveWindow.Done', '', MB_APPLMODAL);}
END;


{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{------------------------ Implémentation de TQcmStatic ---------------------}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

constructor TQcmStatic.Init(AParent: PWindowsObject; AnID: Integer; ATitle: PChar; X,Y,W,H: Integer;
																ATextLen: word);
begin
	X := (X DIV PAS_GRILLE) * PAS_GRILLE;
	Y := (Y DIV PAS_GRILLE) * PAS_GRILLE;
	W := (W DIV PAS_GRILLE) * PAS_GRILLE;
	H := (H DIV PAS_GRILLE) * PAS_GRILLE;
	Inherited Init(AParent, AnID, ATitle, X, Y, W, H, ATextLen);
end;

constructor TQcmStatic.Load(var S: TStream);
begin
	Inherited Load(S);
end;

procedure TQcmStatic.Store(var S: TStream);
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+91, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited Store(S);
end;

PROCEDURE TQcmStatic.DblClick(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+92, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 SendMessage(Parent^.HWindow, wm_LButtonDblClk, Msg.wParam, Msg.lParam);
END;

PROCEDURE TQcmStatic.WMMouseMove(Var Msg : TMessage);
VAR
 wx, wy : Integer;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+93, 0, 0, 0, nil, TRUE);
	{$ENDIF}

     With Msg Do Begin
					wx := LoWord(lParam) + Attr.X;
					wy := HiWord(lParam) + Attr.Y;
					lParam := MakeLong(Word(wx), Word(wy));
		 End;
		 SendMessage(Parent^.HWindow, wm_MouseMove, Msg.wParam, Msg.lParam);
END;

PROCEDURE TQcmStatic.WMLButtonUp(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+94, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 SendMessage(Parent^.HWindow, WM_LBUTTONUP, Msg.wParam, Msg.lParam);
END;

PROCEDURE TQcmStatic.WMLButtonDown(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+95, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 ClientToScreen(HWindow, PPoint(@Msg.lParam)^);
		 ScreenToClient(Parent^.HWindow, PPoint(@Msg.lParam)^);
		 SendMessage(Parent^.HWindow, WM_LBUTTONDOWN, Msg.wParam, Msg.lParam);
END;


{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{------------------------ Gestion de Buffsave --------------------}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

function PushBuff(pBuff : PBuffSave; pVal : Pointer; nSize : integer) : BOOL;
const nStart : integer = 0;
			BUFFHDR : Array[0..2] of char = 'QCM';
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+96, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 PushBuff := FALSE;
		 if pBuff = nil then begin
			 WinProcs.MessageBox(0, 'PushBuff Error', 'Invalid buffer.', 0);
			 exit;
		 end;
		 if nSize = -1 then begin
				nStart := 0;
				nSize := SizeOf(BUFFHDR);
				pVal := @BUFFHDR;
		 end;
		 if pVal = nil then begin
			 WinProcs.MessageBox(0, 'PushBuff Error', 'Invalid value.', 0);
			 exit;
		 end;
		 if nStart + nSize <= SizeOf(TBuffSave) then begin
			 Move(pVal^, pBuff^[nStart], nSize);
			 inc(nStart, nSize);
		 end else begin
			 WinProcs.MessageBox(0, 'PushBuff Error', 'Buffer overflow.', 0);
			 exit;
		 end;
		 PushBuff := TRUE;
end;

function PopBuff(pBuff : PBuffSave; pVal : Pointer; nSize : integer) : BOOL;
const nStart : integer = 0;
			BUFFHDR : Array[0..2] of char = 'QCM';
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+97, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 PopBuff := FALSE;
		 if pBuff = nil then begin
			 WinProcs.MessageBox(0, 'PopBuff Error', 'Invalid buffer.', 0);
			 exit;
		 end;
		 if nSize = -1 then begin
				nStart := 0;
				if(pBuff^[0] = BUFFHDR[0]) AND
					(pBuff^[1] = BUFFHDR[1]) AND
					(pBuff^[2] = BUFFHDR[2]) then begin
					PopBuff := TRUE;
					inc(nStart, SizeOf(BUFFHDR));
				end;
				exit;
		 end;
		 if pVal = nil then begin
			 WinProcs.MessageBox(0, 'PopBuff Error', 'Invalid value.', 0);
			 exit;
		 end;
		 if nStart + nSize <= SizeOf(TBuffSave) then begin
			 Move(pBuff^[nStart], pVal^, nSize);
			 inc(nStart, nSize);
		 end else begin
			 WinProcs.MessageBox(0, 'PopBuff Error', 'Buffer overflow.', 0);
			 exit;
		 end;
		 PopBuff := TRUE;
end;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{------------------------ Implémentation de TReponseWin -------------------}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

CONSTRUCTOR TReponseWin.Init(AParent : PQcmWin; Atexte : PChar; AX, AY : Integer);
BEGIN
		 lpszScript := nil;
		 wTypeRep := WORD(-1);
		 TMoveWindow.Init(AParent, Atexte, AX, AY);
		 if (MainQcmWin^.lpReponse <> nil) AND
				(MainQcmWin^.lpReponse^.wTypeRep <> CT_BITMAP) then begin
			 nValeur := PReponseWin(MainQcmWin^.lpReponse)^.nValeur;
			 bAutoRet := PReponseWin(MainQcmWin^.lpReponse)^.bAutoRet;
			 bTrig := PReponseWin(MainQcmWin^.lpReponse)^.bTrig;
			 bCurseurMain := PReponseWin(MainQcmWin^.lpReponse)^.bCurseurMain;
			 bCheckVisible := PReponseWin(MainQcmWin^.lpReponse)^.bCheckVisible;
			 StrCopy(szLessonToCall, PReponseWin(MainQcmWin^.lpReponse)^.szLessonToCall);
			 if PReponseWin(MainQcmWin^.lpReponse)^.lpszScript <> nil then begin
				 lpszScript := StrNew(PReponseWin(MainQcmWin^.lpReponse)^.lpszScript);
			 end;
			 lpSelSeqInLessonToCall := New(PStrCollection, Init(5, 10));
			 lpSelSeqInLessonToCall^.Duplicates := TRUE;
			 for i := 0 to PReponseWin(MainQcmWin^.lpReponse)^.lpSelSeqInLessonToCall^.count -1 do begin
				 lpSelSeqInLessonToCall^.Insert(StrNew(PReponseWin(MainQcmWin^.lpReponse)^.lpSelSeqInLessonToCall^.At(i)));
			 end;
		 end else begin
			 nValeur := 0;
			 bAutoRet := TRUE;
			 bTrig := FALSE;
			 bCurseurMain := FALSE;
			 bCheckVisible := TRUE;
			 StrCopy(szLessonToCall, '<Aucune>');
			 lpszScript := nil;
			 lpSelSeqInLessonToCall := New(PStrCollection, Init(5, 10));
			 lpSelSeqInLessonToCall^.Duplicates := TRUE;
		 end;
		 bChecked :=FALSE;
		 nOrdBranch := MainQcmWin^.lpColBranch^.Count;
		 lpCtl := nil;
		 if (MainQcmWin^.lpReponse <> nil) AND
				(MainQcmWin^.lpReponse^.wTypeRep <> CT_BITMAP) then begin
			 hLogFnt := PReponseWin(MainQcmWin^.lpReponse)^.hLogFnt;
		 end else with hLogFnt do begin
			 lfHeight:= -11;
			 lfWidth:= 0;
			 lfEscapement:= 0;
			 lfOrientation:= 0;
			 lfWeight:= 700;
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
		 hFnt := CreateFontIndirect(hLogFnt);
		 if (MainQcmWin^.lpReponse <> nil) AND
				(MainQcmWin^.lpReponse^.wTypeRep <> CT_BITMAP) then begin
			 FrColRef := PReponseWin(MainQcmWin^.lpReponse)^.FrColRef;
			 BkColRef := PReponseWin(MainQcmWin^.lpReponse)^.BkColRef;
		 end else begin
			 FrColRef := RGB(0, 0, 0);
			 BkColRef := RGB(192, 192, 192);
		 end;
		 hBkBrush := CreateSolidBrush(BkColRef);
END;

CONSTRUCTOR TReponseWin.Load(Var S : TStream);
VAR
		BuffSave : TBuffSave;
BEGIN
		 wTypeRep := WORD(-1);
		 with hLogFnt do begin
			 lfHeight:= -11;
			 lfWidth:= 0;
			 lfEscapement:= 0;
			 lfOrientation:= 0;
			 lfWeight:= 700;
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
		 FrColRef := RGB(0, 0, 0);
		 BkColRef := RGB(192, 192, 192);
		 S.Read(BuffSave, SizeOf(TBuffSave));
		 if PopBuff(@BuffSave, nil, -1) then begin
				PopBuff(@BuffSave, @hLogFnt, SizeOf(TLOGFONT));
				PopBuff(@BuffSave, @FrColRef, SizeOf(TCOLORREF));
				PopBuff(@BuffSave, @BkColRef, SizeOf(TCOLORREF));
				if (MainQcmWin^.szVersion[4] >= '4') AND
					 (MainQcmWin^.szVersion[4] <= '9') then begin
					PopBuff(@BuffSave, @bTrig, SizeOf(Boolean));
					if (MainQcmWin^.szVersion[6] >= '1') AND
						 (MainQcmWin^.szVersion[6] <= '9') then begin
						PopBuff(@BuffSave, @bAutoRet, SizeOf(Boolean));
					end else begin
						bAutoRet := TRUE;
					end;
				end else begin
					bTrig := FALSE;
					bAutoRet := TRUE;
				end;
		 end;
		 hFnt := CreateFontIndirect(hLogFnt);
		 hBkBrush := CreateSolidBrush(BkColRef);
		 If bBorder Then begin
				Attr.Style := Attr.Style OR WS_BORDER;
		 end else begin
				Attr.Style := Attr.Style AND NOT WS_BORDER;
		 end;
			if ((MainQcmWin^.szVersion[4] > '4') AND
					(MainQcmWin^.szVersion[4] <= '9')) OR
				 ((MainQcmWin^.szVersion[4] = '4') AND
					(MainQcmWin^.szVersion[6] >= '3') AND
					(MainQcmWin^.szVersion[6] <= '9')) then begin
				lpszScript := S.StrRead;
			end else begin
				lpszScript := nil;
			end;
END;

PROCEDURE TReponseWin.Store(Var S : TStream);
VAR
	 BuffSave : TBuffSave;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+98, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 if PushBuff(@BuffSave, nil, -1) then begin
				PushBuff(@BuffSave, @hLogFnt, SizeOf(TLOGFONT));
				PushBuff(@BuffSave, @FrColRef, SizeOf(TCOLORREF));
				PushBuff(@BuffSave, @BkColRef, SizeOf(TCOLORREF));
				PushBuff(@BuffSave, @bTrig, SizeOf(Boolean));
				PushBuff(@BuffSave, @bAutoRet, SizeOf(Boolean));
		 end;
		 S.Write(BuffSave, SizeOf(TBuffSave));
		 S.StrWrite(lpszScript);
END;

PROCEDURE TReponseWin.WMActivate( var Msg: TMessage);
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+99, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	MessageBeep(WORD(-1));
end;

PROCEDURE TReponseWin.SetupWindow;
var rc : TRECT;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+100, 0, 0, 0, nil, TRUE);
	{$ENDIF}


		Inherited SetupWindow;

		If MainQcmWin^.wMode >= M_ELEV Then bChecked := FALSE;

		while nOrdBranch >= MainQcmWin^.lpColBranch^.Count do begin
			{ insertion bidon pour avoir le bon nombre d'items }
			{ #### à revoir }
			MainQcmWin^.lpColBranch^.Insert(New(PDummyReponseWin, Init(nil, '', 0, 0)));
		end;
		MainQcmWin^.lpColBranch^.AtFree(nOrdBranch);
		MainQcmWin^.lpColBranch^.AtInsert(nOrdBranch, @Self);

		 {If nOrdBranch > MainQcmWin^.lpColBranch^.Count Then begin
				MainQcmWin^.lpColBranch^.Insert(@Self);
				MessageBeep(WORD(-1));
		 end else begin
				MainQcmWin^.lpColBranch^.AtInsert(nOrdBranch, @Self);
		 end;}

END;

FUNCTION TReponseWin.GetClassName : PChar;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+101, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 GetClassName := 'CReponseWin';
END;

PROCEDURE TReponseWin.GetWindowClass(Var AWindowClass : TWndClass);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+102, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TMoveWindow.GetWindowClass(AWindowClass);
		 With AWindowClass Do Begin
					hBrBackground := GetStockObject(NULL_BRUSH){hBkBrush};{COLOR_BACKGROUND + 1;}
		 End;
END;

PROCEDURE TReponseWin.Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct);
VAR
	 OldBmp, hBmp : hBitmap;
	 BmpDC 				: hDC;
	 r						: TRECT;

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+103, 0, 0, 0, nil, TRUE);
	{$ENDIF}


		 if wTypeRep = CT_DUMMY then Exit;
		 if wTypeRep = CT_HYPERLINK then Exit;

		 Inherited Paint(PaintDC, PaintInfo);
		 {Couleur de fond sauf si CT_CLIP}
		 GetClientRect(HWindow, r);
		 if (wTypeRep <> CT_CLIP) then FillRect(PaintDC, r, hBkBrush);
		 if bCheckVisible Then Begin

				{Dessin de la case à cocher}
				If(MainQcmWin^.wMode = M_MAKE) And (nValeur > 0) Then
						hBmp := LoadBitmap(hInstRes, 'CHECK_GREEN');

				If(MainQcmWin^.wMode = M_MAKE) And (nValeur < 0) Then
						hBmp := LoadBitmap(hInstRes, 'CHECK_RED');

				If(MainQcmWin^.wMode = M_MAKE) And (nValeur = 0) Then
						hBmp := LoadBitmap(hInstRes, 'UNCHECKED');

				If(MainQcmWin^.wMode >= M_ELEV) And (Not bChecked) Then
						hBmp := LoadBitmap(hInstRes, 'UNCHECKED');

				If(MainQcmWin^.wMode >= M_ELEV) And bChecked Then
						hBmp := LoadBitmap(hInstRes, 'CHECK_BLACK');

				BmpDC := CreateCompatibleDC(PaintDC);
				OldBmp := SelectObject(BmpDC, hBmp);
				BitBlt(PaintDC, 0 + PAS_GRILLE, 0 + PAS_GRILLE, 16 + PAS_GRILLE, 16 + PAS_GRILLE, BmpDC, 0, 0, SrcCopy);
				SelectObject(BmpDC, OldBmp);
				DeleteDC(BmpDC);
				DeleteObject(hBmp);
		 End;
		 Inherited ShowHandle(PaintDC);
END;

PROCEDURE TReponseWin.SetCheck(CheckFlag : Word);
VAR
	 oldChk : Boolean;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+104, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 {####
		 if (CheckFlag = 1) AND
				 NOT bCheckVisible AND
				 NOT bTrig then begin
			 CheckFlag := 0;
		 end;
		 ####}

		 oldChk := bChecked;
		 Case CheckFlag Of
					0 : bChecked := FALSE;
					1 : bChecked := TRUE;
		 End;
		 If oldChk <> bChecked Then bChkChange := TRUE;
		 {#### Invalider seulement le check ... }
		 if HWindow <> 0 then InvalidateRect(HWindow, nil, TRUE);
END;

FUNCTION TReponseWin.GetCheck : Word;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+105, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 If bChecked Then GetCheck := 1 Else GetCheck := 0;
END;

PROCEDURE TReponseWin.SetLineTexte;

const
	 i : Integer = 0;
	 j : Integer = 0;

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+106, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited SetLineTexte;
		 i := nOrdBranch + 1;
		 j := MainQcmWin^.lpColBranch^.Count;
		wvsPrintF(MainQcmWin^.szLineTexte, 'Réponse N° : %i / %i', i);
END;

Procedure TReponseWin.WMCtlColor(Var Msg : TMessage); {WM_CTLCOLOR}
var
	hdcChild  : HDC;
	hwndChild : HWND;
	nCtlType  : integer;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+107, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	hdcChild := HDC(Msg.wParam);
	hwndChild := HWND(LOWORD(Msg.lParam));
	nCtlType := integer(HIWORD(Msg.lParam));
	Msg.Result := 0;
	if(nCtlType = CTLCOLOR_STATIC) OR
		(nCtlType = CTLCOLOR_EDIT) then begin
		SetTextColor(hdcChild, FrColRef);
		SetBkColor(hdcChild, BkColRef);
		if(nCtlType = CTLCOLOR_STATIC)then begin
			Msg.Result := GetStockObject(NULL_BRUSH);
		end else begin
			Msg.Result := hBkBrush;
		end;
	end;
end;

PROCEDURE TReponseWin.WMLButtonDown(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+108, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 If MainQcmWin^.wMode = M_MAKE then begin
			 Inherited WMLButtonDown(Msg);
		 end else begin
			 If (MainQcmWin^.wMode <> M_TUTOR) AND
					 RecordingR Then begin
				 If bChecked AND NOT bTrig Then begin
					 SetCheck(0);
				 end Else begin
					 SetCheck(1);
				 end;
			 end;
		 end;
END;

PROCEDURE TReponseWin.WMLButtonUp(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+109, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	if bTrig then begin
		PostMessage(MainQcmWin^.HWindow, UM_SUITE, 0, 0);
	end;
END;

PROCEDURE TReponseWin.WMLButtonDblClk(Var Msg : TMessage);
VAR szOrdre : Array[0..4] Of Char;
		dlgSetObj  : PSetObjDlg;
		nRet,
		code,
		nOrdre : Integer;
		r : TRECT;
		lStyle : Longint;
CONST bInDblClk : boolean = FALSE;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+110, 0, 0, 0, nil, TRUE);
	{$ENDIF}


		 If (MainQcmWin^.wMode >= M_ELEV) AND
				(MainQcmWin^.wMode < M_TUTOR) AND
				 RecordingR Then Begin
				If bChecked Then SetCheck(0) Else SetCheck(1);
				Exit;
		 End;
		 If(MainQcmWin^.wMode >= M_ELEV) Then Exit;

		 {*** test réentrance ***}
		 If(bInDblClk) Then Exit;
		 bInDblClk := TRUE;

		 dlgSetObj := New(PSetObjDlg, Init(MainQcmWin^.Parent, 'SETOBJECT', lpSelSeqInLessonToCall));
		 With dlgSetObj^.Data Do Begin
				 Str(nValeur, szValeur); {Valeur de la réponse}
				 GetWindowText(hWindow, szTitle, SizeOf(szTitle));
				 If bBorder Then nBordure := 1  {Etat de la checkbox bordure visible}
						Else nBordure := 0;
				 If bCheckVisible Then nCase := 1 Else nCase := 0;
				 If bAutoRet Then nAutoRet := 1 Else nAutoRet := 0;
				 If bTrig Then nTrig := 1 Else nTrig := 0;
				 If bCurseurMain Then Begin
						nFleche  := 0;
						nMain    := 1;
				 End Else Begin
						 nFleche  := 1;
						 nMain    := 0;
				 End;
				 {Collection pour remplir la combo des leçons}
				 lpLessons:= New(PStrCollection, Init(10, 5));
				 FillCollecLecon(lpLessons);
				 StrCopy(szSelLess, szLessonToCall);
				 GetMem(pScript, 32767);
				 StrCopy(pScript, '// Script Objet Tuteur.');
				 if lpszScript <> nil then begin
					 StrCopy(pScript, lpszScript);
				 end;
				 {Collection pour remplir la combobox des priorités d'appels}
				 lpPrior := New(PStrCollection, Init(10, 5));
				 For i := 1 To MainQcmWin^.lpColBranch^.Count Do Begin
						 wvsPrintF(szOrdre, '%i', i);
						 lpPrior^.Insert(StrNew(szOrdre));
				 End;
				 nOrdre := nOrdBranch + 1;
				 wvsPrintF(szSelPrio, '%i', nOrdre);
				 LogFont := hLogFnt;
				 FrColorRef := FrColRef;
				 BkColorRef := BkColRef;
		 End;
		 nRet := Application^.ExecDialog(dlgSetObj);
		 bInDblClk := FALSE;
		 If nRet = 1 Then Begin
				With dlgSetObj^.data Do Begin
						Val(szValeur, nValeur, code);
						if wTypeRep = CT_CLIP then begin
							SetWindowText(hWindow, szTitle);
							StrDispose(Attr.Title);
							Attr.Title := StrNew(szTitle);
						end;

						lStyle := GetWindowLong(HWindow, GWL_STYLE);
						If nBordure = 1 then begin
							bBorder := TRUE;
							lStyle := lStyle OR WS_BORDER;
						end else begin
							bBorder := FALSE;
							lStyle := lStyle AND NOT WS_BORDER;
						end;

						SetWindowLong(HWindow, GWL_STYLE, lStyle);
						SetWindowPos(HWindow, 0, 0, 0, 0, 0, SWP_DRAWFRAME OR SWP_NOMOVE OR SWP_NOSIZE OR SWP_NOZORDER);

						If nCase = 1 Then bCheckVisible := TRUE Else bCheckVisible := FALSE;
						bAutoRet := nAutoRet = 1;
						bTrig := nTrig = 1;
						SendMessage(HWindow, WM_SIZE, 0, MakeLong(Attr.W, Attr.H));
						If nFleche = 1 Then bCurseurMain := FALSE Else bCurseurMain := TRUE;
						If nValeur > 0 Then SetCheck(1) Else SetCheck(0);
						StrCopy(szLessonToCall, szSelLess);
						if lpszScript <> nil then begin
							StrDispose(lpszScript);
							lpszScript := nil;
						end;
						if pScript <> nil then begin
							lpszScript := StrNew(pScript);
							FreeMem(pScript, 32767);
							pScript := nil;
						end;
						Val(szSelPrio, nOrdre, code);
						Dec(nOrdre);
						UpdateBrOrder(nOrdre);
						BkColRef := BkColorRef;
						if(hBkBrush <> 0) then begin
							deleteObject(hBkBrush);
							hBkBrush := CreateSolidBrush(BkColRef);
						end;
						FrColRef := FrColorRef;
						hLogFnt := LogFont;
						if(hFnt <> 0) then begin
							deleteObject(hFnt);
							hFnt := CreateFontIndirect(hLogFnt);
							if (lpCtl <> nil) then begin
								SendMessage(lpCtl^.HWindow, WM_SETFONT, hFnt, 0);
							end;
						end;
						{GetWindowRect(HWindow, r);
						MapWindowPoints(HWND_DESKTOP, Parent^.HWindow, r, 2);
						if bBorder then InflateRect(r, 1, 1);
						InvalidateRect(Parent^.HWindow, @r, TRUE);}
				End;
		 End;
	 MainQcmWin^.UpdateLineTexte(-1);
END;

PROCEDURE TReponseWin.WMSetCursor(Var Msg : TMessage);
VAR
	 pt : TPoint;
	 cRect : TRect;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+111, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 GetCursorPos(pt);
		 GetClientRect(HWindow, cRect);
		 ClientToScreen(HWindow, PPoint(@cRect.Left)^);
		 ClientToScreen(HWindow, PPoint(@cRect.Right)^);

		 If PtInRect(cRect, pt) Then Begin
			 if (Msg.lParamLo = HTCAPTION) OR
					(Msg.lParamLo = HTCLIENT) then begin
				 If bCurseurMain Then
					SetCursor(MainQcmWin^.HCursorHand)
				 Else
					SetCursor(LoadCursor(0, IDC_ARROW));
			 end else begin
				 DefWndProc(Msg);
			 end;
		 End Else begin
			 DefWndProc(Msg);
		 end;
END;

PROCEDURE TReponseWin.UpdateBrOrder(SelfOrder : Integer);
					Procedure SetnOrder(P : PReponseWin); Far;
					Begin
						 P^.nOrdBranch := MainQcmWin^.lpColBranch^.IndexOf(P);
					End;
BEGIN
	if (SelfOrder >= 0) AND
		 (SelfOrder <= MainQcmWin^.lpColBranch^.count) then begin
		MainQcmWin^.lpColBranch^.Delete(@Self);
		MainQcmWin^.lpColBranch^.AtInsert(SelfOrder, @Self);
		MainQcmWin^.lpColBranch^.ForEach(@SetnOrder);
	end;
END;

DESTRUCTOR TReponseWin.Done;
BEGIN
		 If (MainQcmWin^.lpColBranch <> nil) AND
				(MainQcmWin^.lpColBranch^.IndexOf(@Self) > -1) Then Begin
			 MainQcmWin^.lpColBranch^.Delete(@Self);
			 MainQcmWin^.nBRep := MainQcmWin^.lpColBranch^.Count;
		 End;
		 if hFnt <> 0 then DeleteObject(hFnt);
		 if(hBkBrush <> 0) then deleteObject(hBkBrush);
		 Dispose(lpSelSeqInLessonToCall, Done);
		 if lpszScript <> nil then begin
				StrDispose(lpszScript);
				lpszScript := nil;
		 end;
		 Inherited Done;
END;

{ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ }
{------------------------ Implémentation de TRepClipWin ---------------------}
{ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ }

CONSTRUCTOR TRepClipWin.Init(AParent : PQcmWin; AnId : Integer; Atexte : PChar; AX, AY : Integer);
BEGIN
		 TReponseWin.Init(AParent, Atexte, AX, AY);
		 wTypeRep := CT_CLIP;
		 With Attr Do Begin
					dec(X);
					dec(Y);
					W := (70 DIV PAS_GRILLE) * PAS_GRILLE;
					H := (70 DIV PAS_GRILLE) * PAS_GRILLE;
					Style := Style OR WS_CLIPSIBLINGS;
		 End;
		 bChecked := FALSE;
END;

CONSTRUCTOR TRepClipWin.Load(Var S : TStream);
VAR
	 ABool : Boolean;
BEGIN
		 lpCtl := nil;
		 bCreateFromFile := FALSE;
		 bQueryBounds := FALSE;
		 TWindow.load(S);
		 OleObject := nil;
		 S.Read(bBorder, SizeOf(bBorder));
		 S.Read(bCurseurMain, SizeOf(bCurseurMain));
		 S.Read(nValeur, SizeOf(nValeur));
		 S.Read(nOrdBranch, SizeOf(nOrdBranch));
		 S.Read(bCheckVisible, SizeOf(bCheckVisible));
		 S.Read(szLessonToCall, SizeOf(szLessonToCall));
		 lpSelSeqInLessonToCall := PStrCollection(S.Get);
		 TReponseWin.load(S);
		 wTypeRep := CT_CLIP;
		 bLoaded := TRUE;
		 bChecked := FALSE;
		 Attr.Style := Attr.Style Or WS_VISIBLE;
END;

PROCEDURE TRepClipWin.SetupWindow;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+113, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited SetupWindow;
     bChkChange := FALSE;
END;

PROCEDURE TRepClipWin.Store(Var S : TStream);
VAR
	 Rect : TRect;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+114, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TWindow.Store(S);
		 S.Write(bBorder, SizeOf(bBorder));
		 S.Write(bCurseurMain, SizeOf(bCurseurMain));
		 S.Write(nValeur, SizeOf(nValeur));
		 S.Write(nOrdBranch, SizeOf(nOrdBranch));
		 S.Write(bCheckVisible, SizeOf(bCheckVisible));
		 S.Write(szLessonToCall, SizeOf(szLessonToCall));
		 S.Put(lpSelSeqInLessonToCall);
		 TReponseWin.Store(S);
END;

FUNCTION TRepClipWin.GetClassName : PChar;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+115, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 GetClassName := 'CRepClip';
END;

PROCEDURE TRepClipWIn.GetWindowClass(Var AWindowClass : TWndClass);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+116, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TReponseWin.GetWindowClass(AWindowClass);
		 With AWindowClass Do Begin
				hbrBackGround := GetStockObject(NULL_BRUSH);
		 End;
END;

PROCEDURE TRepClipWin.Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct);
VAR
	 WRect : TRect;
	 wOldTxtAlg	: WORD;
	 hOldFnt		: HFONT;
	 nOldBkMode	: integer;
	 OldColRef	: TCOLORREF;

CONST
	 nBORDER = 8;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+117, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 If MainQcmWin^.wMode = M_MAKE Then Begin
				 GetClientRect(HWindow, wRect);
				 PatBlt(PaintDC, wRect.left, wRect.top, wRect.Right - wRect.left, wRect.Bottom - wRect.top, PATINVERT);
				 InflateRect(wRect, - nBORDER, - nBORDER);
				 PatBlt(PaintDC, wRect.left, wRect.top, wRect.Right - wRect.left, wRect.Bottom - wRect.top, PATINVERT);
		 end else begin
				 GetClientRect(HWindow, wRect);
				 InflateRect(wRect, - nBORDER, - nBORDER);
		 end;

		 if (Attr.Title <> nil) AND
				(Attr.Title[0] <> #0) then begin
			 wOldTxtAlg := SetTextAlign(PaintDC, TA_CENTER OR TA_TOP OR TA_NOUPDATECP);
			 OldColRef := SetTextColor(PaintDC, FrColRef);
			 nOldBkMode := SetBkMode(PaintDC, TRANSPARENT);
			 hOldFnt := SelectObject(PaintDC, hFnt);

			 ExtTextOut(PaintDC,
								 wRect.left + (wRect.right - wRect.left) DIV 2,
								 wRect.top,
								 ETO_CLIPPED,
								 @wRect,
								 Attr.Title,
								 StrLen(Attr.Title),
								 nil);

			 SelectObject(PaintDC, hOldFnt);
			 SetTextColor(PaintDC, OldColRef);
			 SetBkMode(PaintDC, nOldBkMode);
			 SetTextAlign(PaintDC, wOldTxtAlg);
		 end;

		 If MainQcmWin^.wMode >= M_ELEV Then Begin
				 GetClientRect(HWindow, wRect);
						If bChkChange Then Begin
							 PatBlt(PaintDC, wRect.left, wRect.top, wRect.Right - wRect.left, wRect.Bottom - wRect.top, PATINVERT);
							 InflateRect(wRect, - nBORDER, - nBORDER);
							 PatBlt(PaintDC, wRect.left, wRect.top, wRect.Right - wRect.left, wRect.Bottom - wRect.top, PATINVERT);
							 bChkChange := FALSE;
						End Else begin
							If bChecked Then begin
							 PatBlt(PaintDC, wRect.left, wRect.top, wRect.Right - wRect.left, wRect.Bottom - wRect.top, PATINVERT);
							 InflateRect(wRect, - nBORDER, - nBORDER);
							 PatBlt(PaintDC, wRect.left, wRect.top, wRect.Right - wRect.left, wRect.Bottom - wRect.top, PATINVERT);
							end;
						end;
		 End;
		 Inherited Paint(PaintDC, PaintInfo);
		 Inherited ShowHandle(PaintDC);
END;

PROCEDURE TRepClipWin.WMSize(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+118, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 Inherited WMSize(Msg);
END;

PROCEDURE TRepClipWin.SetTypeRep;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+119, 0, 0, 0, nil, TRUE);
	{$ENDIF}

     {Coche le bouton radio "Image"}
		 SendMessage(WinToolsHandle, UM_SETTYPEREP, CT_BITMAP, 0);
END;

PROCEDURE TRepClipWin.SetLineTexte;
const
	 szValeur : szLongName = '';
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+120, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited SetLineTexte;
		 wvsPrintF(szValeur, ' - Zone sensible - Valeur : %i points', nValeur);
		 StrCat(MainQcmWin^.szLineTexte, szValeur);
END;

DESTRUCTOR TRepClipWin.Done;
BEGIN
		 Inherited Done;
END;

{ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ }
{------------------------ Implémentation de THole ---------------------------}
{ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ }

CONSTRUCTOR THole.Init(AParent : PQcmWin; Atexte : PChar; AX, AY : Integer);
BEGIN
		 Inherited Init(AParent, Atexte, AX, AY);
		 wTypeRep := CT_HOLE;
		 With Attr Do Begin
					dec(X);
					dec(Y);
					W := (70 DIV PAS_GRILLE) * PAS_GRILLE;
					H := (70 DIV PAS_GRILLE) * PAS_GRILLE;
					Style := Style OR WS_CLIPSIBLINGS;
		 End;
		 bChecked := FALSE;
END;

CONSTRUCTOR THole.Load(Var S : TStream);
BEGIN
		 lpCtl := nil;
		 bCreateFromFile := FALSE;
		 bQueryBounds := FALSE;
		 TWindow.load(S);
		 OleObject := nil;
		 S.Read(bBorder, SizeOf(bBorder));
		 S.Read(bCurseurMain, SizeOf(bCurseurMain));
		 S.Read(nValeur, SizeOf(nValeur));
		 S.Read(nOrdBranch, SizeOf(nOrdBranch));
		 S.Read(bCheckVisible, SizeOf(bCheckVisible));
		 S.Read(szLessonToCall, SizeOf(szLessonToCall));
		 lpSelSeqInLessonToCall := PStrCollection(S.Get);
		 TReponseWin.load(S);
		 wTypeRep := CT_HOLE;
		 bLoaded := TRUE;
		 bChecked := FALSE;
		 Attr.Style := Attr.Style Or WS_VISIBLE;
END;

PROCEDURE THole.SetupWindow;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+121, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited SetupWindow;
		 bChkChange := FALSE;
END;

PROCEDURE THole.Store(Var S : TStream);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+122, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TWindow.Store(S);
		 S.Write(bBorder, SizeOf(bBorder));
		 S.Write(bCurseurMain, SizeOf(bCurseurMain));
		 S.Write(nValeur, SizeOf(nValeur));
		 S.Write(nOrdBranch, SizeOf(nOrdBranch));
		 S.Write(bCheckVisible, SizeOf(bCheckVisible));
		 S.Write(szLessonToCall, SizeOf(szLessonToCall));
		 S.Put(lpSelSeqInLessonToCall);
		 TReponseWin.Store(S);
END;

FUNCTION THole.GetClassName : PChar;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+123, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 GetClassName := 'CHole';
END;

PROCEDURE THole.SetTypeRep;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+124, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 SendMessage(WinToolsHandle, UM_SETTYPEREP, CT_HOLE, 0);
END;

PROCEDURE THole.SetLineTexte;
CONST
	 szValeur : szLongName = '';
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+125, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited SetLineTexte;
		 wvsPrintF(szValeur, ' - Trou - Valeur : %i points', nValeur);
		 StrCat(MainQcmWin^.szLineTexte, szValeur);
END;

DESTRUCTOR THole.Done;
BEGIN
		 Inherited Done;
END;

{ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ }
{ ----------------------- Implémentation de TMCIWin ------------------------ }
{ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ }

CONSTRUCTOR TMCIWin.Init(AParent : PQcmWin; Atexte : PChar; AX, AY : Integer);
BEGIN
		 hMCIWin := THANDLE(-1); {force redimensionnement de la fenêtre/taille de la vidéo}
		 StrCopy(szLinkedFile, ATexte);
		 CopyInCurLesson(szLinkedFile,  QCM0000, 0);
		 Inherited Init(AParent, szLinkedFile, AX, AY);
		 StrCopy(szLinkedFile, Attr.Title); { NE PAS ENLEVER CAR szLinkedFile est réinitilisé par Inherited Init ...}
		 Attr.Style := Attr.Style OR WS_CLIPCHILDREN;
		 wTypeRep := CT_MCIWIN;
		 bChecked := FALSE;
END;

CONSTRUCTOR TMCIWin.Load(Var S : TStream);
var
						Dir				: array[0..fsDirectory] of Char;
						Name			: array[0..fsFileName] of Char;
						Ext				: array[0..fsExtension] of Char;
BEGIN
		 lpCtl := nil;
		 bCreateFromFile := FALSE;
		 bQueryBounds := FALSE;
		 TWindow.load(S);
		 OleObject := nil;
		 S.Read(bBorder, SizeOf(bBorder));
		 S.Read(bCurseurMain, SizeOf(bCurseurMain));
		 S.Read(nValeur, SizeOf(nValeur));
		 S.Read(nOrdBranch, SizeOf(nOrdBranch));
		 S.Read(bCheckVisible, SizeOf(bCheckVisible));
		 S.Read(szLessonToCall, SizeOf(szLessonToCall));
		 lpSelSeqInLessonToCall := PStrCollection(S.Get);
		 TReponseWin.load(S);
		 S.Read(szLinkedFile, SizeOf(szLinkedFile));
		 { si la lecon a changer, met à jours le chemin }
		 if StrLComp(tLecon.PathLecon, szLinkedFile, StrLen(tLecon.PathLecon)) <> 0 then begin
			 FileSplit(szLinkedFile, Dir, Name, Ext);
			 StrECopy(StrECopy(StrECopy(StrECopy(szLinkedFile, tLecon.PathLecon), '\'), Name), Ext);
		 end;
		 SetCaption(szLinkedFile);
		 wTypeRep := CT_MCIWIN;
		 bLoaded := TRUE;
		 bChecked := FALSE;
		 Attr.Style := Attr.Style Or WS_VISIBLE;
		 Attr.Style := Attr.Style OR WS_CLIPCHILDREN;
		 hMCIWin := 0;
END;

PROCEDURE TMCIWin.Store(Var S : TStream);
BEGIN
		 TWindow.Store(S);
		 S.Write(bBorder, SizeOf(bBorder));
		 S.Write(bCurseurMain, SizeOf(bCurseurMain));
		 S.Write(nValeur, SizeOf(nValeur));
		 S.Write(nOrdBranch, SizeOf(nOrdBranch));
		 S.Write(bCheckVisible, SizeOf(bCheckVisible));
		 S.Write(szLessonToCall, SizeOf(szLessonToCall));
		 S.Put(lpSelSeqInLessonToCall);
		 TReponseWin.Store(S);
		 S.Write(szLinkedFile, SizeOf(szLinkedFile));
END;

PROCEDURE TMCIWin.WMSize(Var Msg : TMessage);
VAR
	 cRect : TRect;
BEGIN
		 Inherited WMSize(Msg);
		 GetClientRect(HWindow, cRect);
		 if hMCIWin <> 0 then begin
				SetWindowPos(hMCIWin, HWND_TOP, 32, 8, cRect.Right - 40, cRect.Bottom - 16, {SWP_NOACTIVATE OR} SWP_NOZORDER);
		 end;
END;

Procedure TMCIWin.procMCIWNDM_NOTIFYSIZE(Var Msg : TMessage);
var rc : TRECT;
begin
			{si redimensionnement de la fenêtre/taille de la vidéo forcé hMCIWin = THANDLE(-1)}
			if hMCIWin <> 0 then begin
				GetWindowRect(Msg.wParam, rc);
				With Attr Do Begin
						W := rc.right - rc.left + 40;
						H := rc.bottom - rc.top + 16;
						SetWindowPos(HWindow, 0, 0, 0, W, H, SWP_NOZORDER OR SWP_NOMOVE);
				End;
			end;
end;

Procedure TMCIWin.procMAKEMCIWIN(Var Msg : TMessage);
VAR
	 cRect : TRect;
begin
		if MainQcmWin^.wMode = M_MAKE then begin
			hMCIWin := MCIWndCreate(Attr.Title,
															WS_VISIBLE OR
															WS_CHILD OR
															MCIWNDF_NOTIFYSIZE OR
															{MCIWNDF_NOERRORDLG OR}
															{MCIWNDF_NOMENU OR}
															MCIWNDF_NOOPEN OR
															{ $0080,}
															$0000,
															hInstance, HWindow);
		end else begin
			hMCIWin := MCIWndCreate(Attr.Title,
															WS_VISIBLE OR
															WS_CHILD OR
															MCIWNDF_NOERRORDLG OR
															MCIWNDF_NOMENU OR
															MCIWNDF_NOOPEN OR
															$0080,
															hInstance, HWindow);
		end;
		SetWindowPos(hMCIWin, HWND_TOP, 32, 8, Attr.W - 40, Attr.H - 16,  0 OR SWP_NOZORDER);
end;

PROCEDURE TMCIWin.SetupWindow;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+121, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited SetupWindow;
	bChkChange := FALSE;

	if (hMCIWin = 0) OR (hMCIWin = THANDLE(-1)) then begin
		PostMessage(HWindow, UM_MAKEMCIWIN, 0, 0);
	end;

END;

FUNCTION TMCIWin.GetClassName : PChar;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+123, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 GetClassName := 'CMCIWin';
END;

PROCEDURE TMCIWin.SetTypeRep;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+124, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 SendMessage(WinToolsHandle, UM_SETTYPEREP, CT_HOLE, 0);
END;

PROCEDURE TMCIWin.SetLineTexte;
CONST
	 szValeur : szLongName = '';
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+125, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited SetLineTexte;
		 wvsPrintF(szValeur, ' - Video - Valeur : %i points', nValeur);
		 StrCat(MainQcmWin^.szLineTexte, szValeur);
END;

DESTRUCTOR TMCIWin.Done;
BEGIN

	if hMCIWin <> 0 then begin
		DestroyWindow(hMCIWin);
		hMCIWin := 0;
	end;

	Inherited Done;

END;
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{------------------------ Implémentation de TRepSonWin --------------------}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

CONSTRUCTOR TRepSonWin.Init(AParent : PQcmWin; ATexte : PChar; AX, AY : Integer);
BEGIN
		 bLoadSound := FALSE;
		 TReponseWin.Init(AParent, Atexte, AX, AY);
		 wTypeRep := CT_SON;
		 If Attr.Title[0] <> 'X' Then Begin
			 If NOT InitOleObject Then begin
					MainQcmWin^.Enable(FALSE);
					Check('OleCreate', OleCreate(OleProtocol, @AppClient.OleClient, 'SoundRec',
					MainQcmWin^.ClientDoc, OleObjectName, OleObject, olerender_Draw , 0));
					bQueryBounds := TRUE;
			 end;
		 end;
		 With Attr Do Begin
					if (MainQcmWin^.lpReponse <> nil) AND
						 (MainQcmWin^.lpReponse^.wTypeRep <> CT_BITMAP) then begin
						W := MainQcmWin^.lpReponse^.Attr.W;
						H := MainQcmWin^.lpReponse^.Attr.H;
					end else begin
						W := (200 DIV PAS_GRILLE) * PAS_GRILLE;
						H := (64 DIV PAS_GRILLE) * PAS_GRILLE;
					end;
					lpButton := New(pButton, Init(@Self, IDB_JOUERSON, 's', 10,(H Div 2) - 12, 26, 26, FALSE));
					lpQcmStatic := New(PQcmStatic, Init(@Self, 113, Atexte, 60,(H Div 2), W, H, 255));
					lpCtl := lpQcmStatic;
		 End;
		 bRepeatSon := TRUE;
		 bChecked := FALSE;
		 StrCopy(szTexte, 'Réponse son');
		 nOrder := MainQcmWin^.nRepSon + 1;

END;

CONSTRUCTOR TRepSonWin.Load(Var S : TStream);
BEGIN
		 bLoadSound := TRUE;
		 AppClient.OleClient.lpvtbl := @OleClientVTbl;
		 AppClient.ObjectWindow := @Self;
		 TMoveWindow.Load(S);
		 S.Read(bRepeatSon, SizeOf(bRepeatSon));
		 S.Read(bCheckVisible, SizeOf(bCheckVisible));
		 S.Read(bCurseurMain, SizeOf(bCurseurMain));
		 S.Read(nValeur, SizeOf(nValeur));
		 S.Read(NOrdBranch, SizeOf(nOrdBranch));
		 S.Read(szTexte, SizeOf(szTexte));
		 S.Read(nOrder, SizeOf(nOrder));
		 S.Read(szLessonToCall, SizeOf(szLessonToCall));
		 lpSelSeqInLessonToCall := PStrCollection(S.Get);
		 TReponseWin.load(S);
		 wTypeRep := CT_SON;
		 lpButton := pButton(At(1));
		 lpQcmStatic := PQcmStatic(At(2));
		 lpCtl := lpQcmStatic;
END;

PROCEDURE TRepSonWin.Store(Var S : TStream);
VAR
	 wRect : TRect;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+126, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TMoveWindow.Store(S);
		 S.Write(bRepeatSon, SizeOf(bRepeatSon));
		 S.Write(bCheckVisible, SizeOf(bCheckVisible));
		 S.Write(bCurseurMain, SizeOf(bCurseurMain));
		 S.Write(nValeur, SizeOf(nValeur));
		 S.Write(NOrdBranch, SizeOf(nOrdBranch));
		 S.Write(szTexte, SizeOf(szTexte));
		 S.Write(nOrder, SizeOf(nOrder));
		 S.Write(szLessonToCall, SizeOf(szLessonToCall));
		 S.Put(lpSelSeqInLessonToCall);
		 TReponseWin.Store(S);
END;

PROCEDURE TRepSonWin.SetupWindow;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+127, 0, 0, 0, nil, TRUE);
	{$ENDIF}


		 Inherited SetupWindow;

		 if(hFnt <> 0) AND(lpQcmStatic <> nil) then begin
				SendMessage(lpQcmStatic^.HWindow, WM_SETFONT, hFnt, 0);
		 end;

		 if bLoadSound then begin
			 while nOrder - 1 >= MainQcmWin^.lpCollecSon^.Count do begin
				 { insertion bidon pour avoir le bon nombre d'items }
				 MainQcmWin^.lpCollecSon^.Insert(New(PDummyRepSonWin, Init(nil, 'X', 0, 0)));
			 end;
			 MainQcmWin^.lpCollecSon^.AtFree(nOrder - 1);
			 bLoadSound := FALSE;
		 end;
		 if nOrder - 1 < 0 then nOrder := 1;
		 if nOrder - 1 > MainQcmWin^.lpCollecSon^.Count then nOrder := MainQcmWin^.lpCollecSon^.Count + 1;
		 {WriteLn(nOrder - 1 ,' ', MainQcmWin^.lpCollecSon^.Count);
		 MessageBox(0,'','',0);}
		 MainQcmWin^.lpCollecSon^.AtInsert((nOrder - 1), @Self);

		 Inc(MainQcmWin^.nRepSon);
		 If Not bRepeatSon Then EnableWindow(lpButton^.HWindow, FALSE);
		 SetDlgItemText(HWindow, 113, szTexte);
END;

FUNCTION TRepSonWin.GetClassName : PChar;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+128, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 GetClassName := 'CRepSonWin';
END;

PROCEDURE TRepSonWin.Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct);
VAR
	 OldBmp, hBmp : hBitmap;
	 BmpDC : hDC;
	 cRect : TRect;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+129, 0, 0, 0, nil, TRUE);
	{$ENDIF}


		 TMoveWindow.Paint(PaintDC, PaintInfo);
		 {Couleur de fond}
		 GetClientRect(HWindow, cRect);
		 FillRect(PaintDC, cRect, hBkBrush);
		 If bCheckVisible Then Begin
				{Paint différent de TReponseWin.Paint car la case à cocher
				doit être centrée verticalement}
				If(MainQcmWin^.wMode = M_MAKE) And(nValeur > 0) Then
						hBmp := LoadBitmap(hInstRes, 'CHECK_GREEN');
				If(MainQcmWin^.wMode = M_MAKE) And(nValeur < 0) Then
						hBmp := LoadBitmap(hInstRes, 'CHECK_RED');
				If(MainQcmWin^.wMode = M_MAKE) And(nValeur = 0) Then
						hBmp := LoadBitmap(hInstRes, 'UNCHECKED');
				If(MainQcmWin^.wMode >= M_ELEV) And(Not bChecked) Then
						hBmp := LoadBitmap(hInstRes, 'UNCHECKED');
				If(MainQcmWin^.wMode >= M_ELEV) And bChecked Then
						hBmp := LoadBitmap(hInstRes, 'CHECK_BLACK');
				GetClientRect(HWindow, cRect);
				BmpDC := CreateCompatibleDC(PaintDC);
				OldBmp := SelectObject(BmpDC, hBmp);
				BitBlt(PaintDC, 40,(cRect.Bottom Div 2) - 7, 16, 16, BmpDC, 0, 0, SrcCopy);
				SelectObject(BmpDC, OldBmp);
				DeleteDC(BmpDC);
				DeleteObject(hBmp);
		 End;
		 Inherited ShowHandle(PaintDC);
END;

PROCEDURE TRepSonWin.WMSize(Var Msg : TMessage);
VAR
	 cRect : TRect;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+130, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited WMSize(Msg);
		 GetClientRect(HWindow, cRect);
		 SetWindowPos(lpQcmStatic^.HWindow, HWND_TOP, 60,(cRect.Bottom Div 2)-6, cRect.Right, cRect.Bottom, SWP_NOACTIVATE);
		 SetWindowPos(lpButton^.HWindow, HWND_TOP, 10,(cRect.Bottom Div 2) - 12, 26, 26, SWP_NOACTIVATE);
END;

PROCEDURE TRepSonWin.WMLButtonDblClk(Var Msg : TMessage);
VAR
   dlgSetSon : PSetSoundDlg;
	 nRet, code, nOrdre : Integer;
	 szOrdre : Array[0..4] Of Char;
	 lStyle	 : longint;
CONST bInDblClk : boolean = FALSE;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+131, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 If(MainQcmWin^.wMode >= M_ELEV) And(MainQcmWin^.wMode < M_TUTOR) AND
					 RecordingR Then Begin
				If bChecked Then SetCheck(0) Else SetCheck(1);
				Exit;
     End;
		 If(MainQcmWin^.wMode >= M_ELEV) Then Exit;

     {*** test réentrance ***}
		 If(bInDblClk) Then Exit;
		 bInDblClk := TRUE;

		 dlgSetSon := New(PSetSoundDlg, Init(MainQcmWin^.Parent, 'SETSOUND', lpSelSeqInLessonToCall));
			With dlgSetSon^.DataSnd Do Begin
				 Str(nValeur, szValeur); {Valeur de la réponse}
				 GetWindowText(hWindow, szTitle, SizeOf(szTitle));
				 If bBorder Then nBordure := 1  {Etat de la checkbox bordure visible}
            Else nBordure := 0;
				 If bCheckVisible Then nCase := 1 Else nCase := 0;
				 If bAutoRet Then nAutoRet := 1 Else nAutoRet := 0;
				 If bTrig Then nTrig := 1 Else nTrig := 0;
				 If bCurseurMain Then Begin
						nFleche  := 0;
						nMain    := 1;
         End Else Begin
             nFleche  := 1;
						 nMain    := 0;
				 End;
				 {Collection pour remplir la combo des leçons}
				 lpLessons:= New(PStrCollection, Init(10, 5));
				 FillCollecLecon(lpLessons);
				 StrCopy(szSelLess, szLessonToCall);
				 {Collection pour remplir la combobox des priorités d'appels}
				 lpPrior := New(PStrCollection, Init(10, 5));
				 For i := 1 To MainQcmWin^.lpColBranch^.Count Do Begin
						 wvsPrintF(szOrdre, '%i', i);
						 lpPrior^.Insert(StrNew(szOrdre));
         End;
				 nOrdre := nOrdBranch + 1;
				 wvsPrintF(szSelPrio, '%i', nOrdre);
				 {Collection pour remplir la combo des ordres de lectures}
				 GetDlgItemText(HWindow, 113, szEditTxt, 63);
				 If bRepeatSon Then nRepet := 1 Else nRepet := 0;
				 lpLecture := New(PstrCollection, Init(10, 5));
				 For i := 1 To MainqcmWin^.lpCollecSon^.Count Do Begin
						 wvsPrintF(szOrdre, '%i', i);
						 lpLecture^.Insert(StrNew(szOrdre));
				 End;
				 wvsPrintF(szSelLect, '%i', nOrder);
		 End;
		 with dlgSetSon^.Data do begin
				 GetMem(pScript, 32767);
				 StrCopy(pScript, '// Script Objet Tuteur.');
				 if lpszScript <> nil then begin
					 StrCopy(pScript, lpszScript);
				 end;
				 BkColorRef := BkColRef;
				 FrColorRef := FrColRef;
				 LogFont := hLogFnt;
		 end;
		 nRet := Application^.ExecDialog(dlgSetSon);
		 bInDblClk := FALSE;
		 If nRet = 1 Then Begin
				With dlgSetSon^.DataSnd Do Begin
						Val(szValeur, nValeur, code);
						SetWindowText(hWindow, szTitle);

						lStyle := GetWindowLong(HWindow, GWL_STYLE);
						If nBordure = 1 then begin
							bBorder := TRUE;
							lStyle := lStyle OR WS_BORDER;
						end else begin
							bBorder := FALSE;
							lStyle := lStyle AND NOT WS_BORDER;
						end;

						SetWindowLong(HWindow, GWL_STYLE, lStyle);
						SetWindowPos(HWindow, 0, 0, 0, 0, 0, SWP_DRAWFRAME OR SWP_NOMOVE OR SWP_NOSIZE OR SWP_NOZORDER);

						If nCase = 1 Then bCheckVisible := TRUE Else bCheckVisible := FALSE;
						bAutoRet := nAutoRet = 1;
						bTrig := nTrig = 1;
						If nFleche = 1 Then bCurseurMain := FALSE
							 Else bCurseurMain := TRUE;
						If nValeur > 0 Then SetCheck(1) Else SetCheck(0);
						StrCopy(szLessonToCall, szSelLess);
						Val(szSelPrio, nOrdre, code);
						Dec(nOrdre);
						UpdateBrOrder(nOrdre);
						SetDlgItemText(HWindow, 113, szEditTxt);
						StrCopy(szTexte, szEditTxt);
						If nRepet = 1 Then Begin {Mise à jour de la répétition auto}
								bRepeatSon := TRUE;
								EnableWindow(lpButton^.HWindow, TRUE);
						End Else Begin
								 bRepeatSon := FALSE;
								 EnableWindow(lpButton^.HWindow, FALSE);
						End;
						Val(szSelLect, nOrdre, code);
						UpdateOrder(nOrdre, TRUE);
						If nValeur > 0 Then SetCheck(1) Else SetCheck(0);
				End;
				with dlgSetSon^.Data do begin
						if lpszScript <> nil then begin
							StrDispose(lpszScript);
							lpszScript := nil;
						end;
						if pScript <> nil then begin
							lpszScript := StrNew(pScript);
							FreeMem(pScript, 32767);
							pScript := nil;
						end;
						BkColRef := BkColorRef;
						if(hBkBrush <> 0) then begin
							deleteObject(hBkBrush);
							hBkBrush := CreateSolidBrush(BkColRef);
						end;
						FrColRef := FrColorRef;
						hLogFnt := LogFont;
						if(hFnt <> 0) then begin
							deleteObject(hFnt);
							hFnt := CreateFontIndirect(hLogFnt);
							if (lpCtl <> nil) then begin
								SendMessage(lpCtl^.HWindow, WM_SETFONT, hFnt, 0);
							end;
						end;
				end;
		 End;
	 MainQcmWin^.UpdateLineTexte(-1);
END;

PROCEDURE TRepSonWin.UpdateOrder(SelfOrder : Integer; ChangeVal : Boolean);
					Procedure SetnOrderLect(P : PMoveWindow); Far;
					Begin
							 P^.nOrder :=(MainQcmWin^.lpCollecSon^.IndexOf(P)) + 1;
					End;
BEGIN
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+132, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 MainQcmWin^.lpCollecSon^.Delete(@Self);
		 MainQcmWin^.lpCollecSon^.AtInsert((SelfOrder - 1), @Self);
		 If ChangeVal Then MainQcmWin^.lpCollecSon^.ForEach(@SetnOrderLect);
END;

PROCEDURE TRepSonWin.JouerSon(Var Msg : TMessage);
VAR
	 bResult : Boolean;
	 Mesg : TMsg;
	 HData : THandle;
	 P : Pointer;
CONST Me : PRepSonWin = nil;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+133, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 if NOT SndPlaySound(nil, SND_ASYNC Or SND_NOSTOP) AND(Me = @Self) then begin
				 {j'était en train de jouer, je stoppe...}
				 {sauf si autre son...}
				 SndPlaySound(nil, SND_ASYNC);
		 end else begin
				 {je n'était en train de jouer ou ce n'est lpus moi, je joue...}
				 if OleObject <> nil then begin
					 Check('OleGetData', OleGetData(OleObject, CFNative, HData));
					 P := GlobalLock(HData);
					 SndPlaySound(PChar(P),SND_ASYNC Or SND_MEMORY);
					 GlobalUnlock(HData);
				 end else begin
					 SndPlaySound(szLinkedFile, SND_ASYNC);
				 end;
		 end;
		 Me := @Self;
END;

PROCEDURE TRepSonWin.SetTypeRep;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+134, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 SendMessage(WinToolsHandle, UM_SETTYPEREP, CT_SON, 0);
END;

PROCEDURE TRepSonWin.SetLineTexte;
const
	 szValeur : szLongName = '';
	 szLigne : Array[0..30] Of Char = '';
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+135, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited SetLineTexte;
		 wvsPrintF(szValeur, ' - Son - Valeur : %i points, ', nValeur);
		 wvsPrintF(szLigne, ' ordre de lecture : %i', nOrder);
		 StrCat(MainQcmWin^.szLineTexte, szValeur);
		 StrCat(MainQcmWin^.szLineTexte, szLigne);
		 StrCat(MainQcmWin^.szLineTexte, ' - Lien : ');
		 StrCat(MainQcmWin^.szLineTexte, szLinkedFile);
END;

DESTRUCTOR TRepSonWin.Done;
					Procedure SetnOrderLect(P : PMoveWindow); Far;
					Begin
							 P^.nOrder :=(MainQcmWin^.lpCollecSon^.IndexOf(P)) + 1;
					End;
BEGIN
		 With MainQcmWin^.lpCollecSon^ Do begin
				If IndexOf(@Self) > - 1 Then begin
					Delete(@Self); {Delete que s'il est dans la collection}
					ForEach(@SetnOrderLect);
				end;
		 end;
		 Dec(MainQcmWin^.nRepSon);
		 Dispose(lpButton, Done);
		 Dispose(lpQcmStatic, Done);
		 TReponseWin.Done;
END;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{------------------------ Implémentation de TEditTexte --------------------}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

CONSTRUCTOR TEditTexte.Init(AParent : PMoveWindow; AnId : Integer; ATexte  : PChar;
														 X, Y, W, H, ATextLen : Integer; Multiline : Boolean);
BEGIN
		 X := (X DIV PAS_GRILLE) * PAS_GRILLE;
		 Y := (Y DIV PAS_GRILLE) * PAS_GRILLE;
		 W := (W DIV PAS_GRILLE) * PAS_GRILLE;
		 H := (H DIV PAS_GRILLE) * PAS_GRILLE;

		 TEdit.Init(AParent, AnId, ATexte, X, Y, W, H, ATextLen, Multiline);

		 With Attr Do Begin
					Style := Style
									 AND NOT WS_HSCROLL
									 AND NOT WS_VSCROLL
									 AND NOT ES_AUTOHSCROLL
									 AND NOT WS_BORDER;

					Style := Style OR ES_NOHIDESEL;
		 End;

		 {lpDummies := New(PDummies, Init(10, 5));}
END;

CONSTRUCTOR TEditTexte.Load(Var S : TStream);
BEGIN
	Inherited Load(S);
	if Attr.Style AND ES_NOHIDESEL = ES_NOHIDESEL then begin
		{lpDummies := PDummies(S.Get);}
	end;
END;

PROCEDURE TEditTexte.Store(Var S : TStream);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+136, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited Store(S);
	if Attr.Style AND ES_NOHIDESEL = ES_NOHIDESEL then begin
		{S.Put(lpDummies);}
	end;
END;

DESTRUCTOR TEditTexte.Done;
begin
	Inherited Done;
	{Dispose(lpDummies, done);}
end;

FUNCTION TEditTexte.GetClassName : PChar;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+137, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 GetClassName := 'EDIT';
END;

PROCEDURE TEditTexte.WMNCHitTest(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+138, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 DefWndProc(Msg);
END;

PROCEDURE TEditTexte.SetupWindow;
var Dummy : TDummyRec;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+139, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited SetupWindow;
	If MainQcmWin^.wMode >= M_ELEV Then Attr.Style := Attr.Style OR ES_READONLY;
	ProcessScroll;
	{SendMessage(Hwindow, EM_FMTLINES, WORD(FALSE), 0);}
END;

PROCEDURE TEditTexte.ProcessScroll;
VAR
	 nLineHeight : Integer;
	 nNumLines   : Integer;
	 nEditHeight : Integer;
	 lStyle      : LongInt;
	 cRect       : TRect;
	 txtDC       : hDC;
	 AMetrics    : TTextMetric;

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+140, 0, 0, 0, nil, TRUE);
	{$ENDIF}


		 {Récupération des données de dimensions de texte}
		 txtDC := GetDC(HWindow);
		 GetTextMetrics(txtDC, AMetrics);
		 ReleaseDC(HWindow, txtDC);
		 With AMetrics Do nLineHeight :=tmHeight + tmExternalLeading;
		 SendMessage(HWindow, EM_GETRECT, 0, LongInt(@cRect));
		 nNumLines := GetNumLines;
		 lStyle := GetWindowLong(HWindow, GWL_STYLE);
		 nEditHeight := cRect.Bottom - cRect.Top;
		 If nEditHeight >= nNumLines * nLineHeight Then Begin
				Scroll(0, - GetNumLines);
				lStyle := lStyle AND NOT WS_VSCROLL;
				ShowScrollBar(HWindow, SB_VERT, FALSE);
		 End Else Begin
				 lStyle := lStyle Or WS_VSCROLL;
				 ShowScrollBar(HWindow, SB_VERT, TRUE);
		 End;
		 SetWindowLong(HWindow, GWL_STYLE, lStyle);
		 UpdateWindow(HWindow);

END;

procedure TEditTexte.EnumDummy(EnumDummyProc : TEnumDummyProc; wParam : WORD; lParam : DWORD; var DummyRet : TDummyRec);
VAR
		pLine,
		pKey,
		pNextKey 		: PChar;
		cOldChar		: Char;
		nFirstLine	: integer;
		ncLine			: integer;
		cb					: longint;
		pt1,
		pt2					: TSIZE;
		hOldFnt			: HFONT;
		dc 					: HDC;
		Dummy				: TDummyRec;

const
		nTabStop		: integer = 0;
		nIn					: integer = 0;

	function Matches(p : PDummy) : Boolean; far;
	begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+141, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		Matches := ((TypeOf(p^) = TypeOf(TDummy)) OR (TypeOf(p^) = TypeOf(THyperLink))) AND
							 (StrComp(p^.szID, Dummy.szDummyID) = 0);
	end;

BEGIN


	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+142, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	inc(nIn);

	{if nIn > 1 then MessageBeep(WORD(-1));}

	begin

		FillChar(DummyRet, SizeOf(DummyRet), 0);

		dc := GetDC(HWindow);
		hOldFnt := SelectObject(dc, PRepTexteWin(Parent)^.hFnt);

		nFirstLine := SendMessage(HWindow, EM_GETFIRSTVISIBLELINE, 0, 0);
		ncLine := SendMessage(HWindow, EM_GETLINECOUNT, 0, 0) - 1;
		SendMessage(HWindow, EM_GETRECT, 0, longint(@Dummy.rcParent));

		Dummy.nLastLine := 0;

		GetMem(pLine, 1024);
		if pLine = nil then WinProcs.MessageBox(GetActiveWindow, 'Err Alloc pLine', '', 0);

		pLine[0] := CHAR(LOBYTE(1024));
		pLine[1] := CHAR(HIBYTE(1024));
		cb := SendMessage(HWindow, EM_GETLINE, Dummy.nLastLine, longint(pLine));
		if cb < 0 then cb := 0;
		pLine[cb] := #0;

		repeat

			{ détecte le début de la chaine }
			pKey := StrScan(pLine, '{');
			while pKey <> nil do begin

				Dummy.s := SendMessage(HWindow, EM_LINEINDEX, Dummy.nLastLine, 0) + pKey - pLine;

				{ marque le début de la chaine }
				pKey[0] := #0;

				{ mesure la chaine}
				if pLine[0] <> #0 then begin
					longint(pt1) := GetTabbedTextExtent(dc, pLine, StrLen(pLine), 0, nTabStop);
					{GetTextExtentABCPoint(dc, pLine, StrLen(pLine), @pt1.cx);}
					LPtoDP(dc, pt1, 1);
				end else begin
					longint(pt1) := GetTabbedTextExtent(dc, '{', 1, 0, nTabStop);
					{GetTextExtentABCPoint(dc, '{', 1, @pt1.cx);}
					LPtoDP(dc, pt1, 1);
					pt1.cx := 0;
				end;

				{ restaure le début de la chaine }
				pKey[0] := '{';

				{ calcule le rect }
				Dummy.rc.left := pt1.cx;
				Dummy.rc.top := (Dummy.nLastLine - nFirstLine) * pt1.cy;
				Dummy.rc.right := Dummy.rcParent.right;
				Dummy.rc.bottom := Dummy.rc.top + pt1.cy;
				Dummy.nFirstLine := Dummy.nLastLine;
				Dummy.nHeight := pt1.cy;
				SetRect(Dummy.rc2, 0, 0, 0, 0);
				SetRect(Dummy.rc3, 0, 0, 0, 0);

				{ détecte la fin de la chaine }
				{ si pas de fin, test si début d'une autre }
				pNextKey := StrScan(pKey, '}');
				if pNextKey = nil then begin
					inc(pKey);
					pNextKey := StrScan(pKey, '{');
					dec(pKey);
				end;

				if pNextKey <> nil then begin

					{ marque la fin de la chaine }
					cOldChar := pNextKey[1];
					pNextKey[1] := #0;

					{ mesure la chaine}
					longint(pt2) := GetTabbedTextExtent(dc, pKey, StrLen(pKey), 0, nTabStop);
					{GetTextExtentABCPoint(dc, pKey, StrLen(pKey), @pt2.cx);}
					LPtoDP(dc, pt2, 1);

					{Calcul le rect }
					Dummy.rc.right := pt1.cx + pt2.cx;

					{ restaure la fin de la chaine }
					pNextKey[1] := cOldChar;

					{ récup ID }
					cOldChar := pNextKey[0];
					pNextKey[0] := #0;
					StrCopy(Dummy.szDummyID, @pKey[1]);
					pNextKey[0] := cOldChar;

				end else begin

					{ récup ID }
					StrCopy(Dummy.szDummyID, @pKey[1]);

					{ mesure la chaine}
					longint(pt2) := GetTabbedTextExtent(dc, pKey, StrLen(pKey), 0, nTabStop);
					{GetTextExtentABCPoint(dc, pKey, StrLen(pKey), @pt2.cx);}
					LPtoDP(dc, pt2, 1);

					repeat
						{ lit la ligne suivante }
						inc(Dummy.nLastLine);
						pLine[0] := CHAR(LOBYTE(1024));
						pLine[1] := CHAR(HIBYTE(1024));
						cb := SendMessage(HWindow, EM_GETLINE, Dummy.nLastLine, longint(pLine));
						if cb < 0 then cb := 0;
						pLine[cb] := #0;

						{ détecte la fin de la chaine }
						{ si pas de fin, test si début d'une autre }
						pNextKey := StrScan(pLine, '}');
						if pNextKey = nil then begin
							pNextKey := StrScan(pLine, '{');
						end;

						if pNextKey = nil then begin
							{ récup ID }
							if StrLen(Dummy.szDummyID) + StrLen(pLine) < 256 then begin
								StrCat(Dummy.szDummyID, pLine);
							end else begin
								WinProcs.MessageBox(GetActiveWindow, 'Dummy.szID is full !!!', '', 0);
							end;

							Dummy.rc2.left		:= Dummy.rcParent.left;
							Dummy.rc2.top			:= Dummy.rc.bottom;
							Dummy.rc2.right		:= Dummy.rcParent.right;
							Dummy.rc2.bottom	:= (Dummy.nLastLine - nFirstLine) * pt1.cy + pt1.cy;

						end;

					until (pNextKey <> nil) OR (Dummy.nLastLine > ncLine);

					if pNextKey <> nil then begin

						{ marque la fin de la chaine }
						cOldChar := pNextKey[1];
						pNextKey[1] := #0;

						{ mesure la chaine}
						longint(pt2) := GetTabbedTextExtent(dc, pLine, StrLen(pLine), 0, nTabStop);
						{GetTextExtentABCPoint(dc, pKey, StrLen(pKey), @pt2.cx);}
						LPtoDP(dc, pt2, 1);

						{ restaure la fin de la chaine }
						pNextKey[1] := cOldChar;

						{ récup ID }
						cOldChar := pNextKey[0];
						pNextKey[0] := #0;
						if StrLen(Dummy.szDummyID) + StrLen(pLine) < 256 then begin
							StrCat(Dummy.szDummyID, pLine);
						end else begin
							WinProcs.MessageBox(GetActiveWindow, 'Dummy.szID is full !!!', '', 0);
						end;
						pNextKey[0] := cOldChar;

						Dummy.rc3.left		:= Dummy.rcParent.left;

						if Dummy.rc2.bottom - Dummy.rc2.top <> 0 then begin
							Dummy.rc3.top		:= Dummy.rc2.bottom;
						end else begin
							Dummy.rc3.top		:= Dummy.rc.bottom;
						end;

						Dummy.rc3.right		:= pt2.cx;
						Dummy.rc3.bottom	:= Dummy.rc3.top + pt2.cy;

					end else begin
						WinProcs.MessageBox(GetActiveWindow, 'Dummy is not closed !!!', '', 0);
						SetRect(Dummy.rc2, 0, 0, 0, 0);
						SetRect(Dummy.rc3, 0, 0, 0, 0);
					end;

				end;

				Dummy.e := Dummy.s + StrLen(Dummy.szDummyID) + 2;

				{ connecte l'objet Dummy associé }
				{ Dummy.lpDummy := lpDummies^.FirstThat(@Matches); }
				Dummy.lpDummy := PDummy(Parent^.FirstThat(@Matches));

				{ appelle la Dummy Proc }
				if Dummy.lpDummy <> nil then begin
					Dummy.lpDummy^.bValid := TRUE;
					if EnumDummyProc(HWindow, Dummy, wParam, lParam) then begin
						{ Si Dummy Proc rend TRUE stocke Dummy pour retour EnumDummy }
						DummyRet := Dummy;
					end;
				end;

				{ détecte le début de la chaine suivante }
				inc(pKey);
				pKey := StrPos(pKey, '{');
			end;

			{ lit la ligne suivante }
			inc(Dummy.nLastLine);
			pLine[0] := CHAR(LOBYTE(1024));
			pLine[1] := CHAR(HIBYTE(1024));
			cb := SendMessage(HWindow, EM_GETLINE, Dummy.nLastLine, longint(pLine));
			if cb < 0 then cb := 0;
			pLine[cb] := #0;

		until (Dummy.nLastLine > ncLine);
		FreeMem(pLine, 1024);

		SelectObject(dc, hOldFnt);
		ReleaseDC(HWindow, dc);

		Dummy := DummyRet;
	end;
	dec(nIn);
END;

PROCEDURE TEditTexte.Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+143, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited Paint(PaintDC, PaintInfo);
END;

PROCEDURE TEditTexte.WMPaint(Var Msg : TMessage);
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+144, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited WMPaint(Msg);
end;

PROCEDURE TEditTexte.WMSize(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+145, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		Inherited WMSize(Msg);
		ProcessScroll;
END;

PROCEDURE TEditTexte.WMChar(Var Msg : TMessage);

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+146, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	If MainQcmWin^.wMode < M_ELEV Then DefWndProc(Msg);

	ProcessScroll;
END;

function LastDummy(hWin : HWND; Dummy : TDummyRec; wParam : WORD; lParam : DWORD) : Boolean;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+147, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	LastDummy := TRUE;
end;

function FirstDummy(hWin : HWND; Dummy : TDummyRec; wParam : WORD; lParam : DWORD) : Boolean;
const bFirst : boolean = TRUE;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+148, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	if wParam = RESETDUMMYPROC then begin
		bFirst := TRUE;
		FirstDummy := FALSE;
	end else begin
		FirstDummy := bFirst;
		bFirst := FALSE;
	end;
end;

function NextDummy(hWin : HWND; Dummy : TDummyRec; wParam : WORD; lParam : DWORD) : Boolean;
const bOnMe : boolean = FALSE;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+149, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	if wParam = RESETDUMMYPROC then begin
		bOnMe := FALSE;
		NextDummy := FALSE;
	end else begin
		NextDummy := bOnMe;
		bOnMe := StrComp(Dummy.szDummyID, PChar(lParam)) = 0;
	end;
end;

function PrevDummy(hWin : HWND; Dummy : TDummyRec; wParam : WORD; lParam : DWORD) : Boolean;
const bNotOnMe : boolean = TRUE;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+150, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	if wParam = RESETDUMMYPROC then begin
		bNotOnMe := TRUE;
		PrevDummy := FALSE;
	end else begin
		if bNotOnMe then bNotOnMe := StrComp(Dummy.szDummyID, PChar(lParam)) <> 0;
		PrevDummy := bNotOnMe;
	end;
end;

PROCEDURE TEditTexte.WMVSCROLL(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+151, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	if GetFocus <> HWindow then Focus;
	Inherited WMVSCROLL(Msg);
END;

PROCEDURE TEditTexte.UMNotify(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+152, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	case Msg.LParamHi of
		EN_CHANGE		: begin
										{PaintDummy;}
									end;
		EN_HSCROLL,
		EN_VSCROLL	: begin
										{if GetFocus <> HWindow then Focus;}
									end;
	end;
END;

function DrawDummy(hWin : HWND; Dummy : TDummyRec; wParam : WORD; lParam : DWORD) : Boolean;
var hBr					: HBRUSH;
		wOldTxtAlg	: WORD;
		rcTest			: TRECT;
		hOldFnt			: HFONT;
		dc					: HDC;
		nOldBkMode	: integer;
		crOldTxtColor	: TCOLORREF;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+153, 0, 0, 0, nil, TRUE);
	{$ENDIF}


	dc := HDC(wParam);

	if (IntersectRect(rcTest, Dummy.rc, Dummy.rcParent) <> 0) OR
		 (IntersectRect(rcTest, Dummy.rc2, Dummy.rcParent) <> 0) OR
		 (IntersectRect(rcTest, Dummy.rc3, Dummy.rcParent) <> 0)	then begin


		if PDummy(MainQcmWin^.lpReponse) = Dummy.lpDummy then begin
			hBr := GetStockObject(DKGRAY_BRUSH);
			crOldTxtColor := SetTextColor(dc, RGB(255, 255, 255));
		end else begin
			if (Dummy.lpDummy^.wTypeRep = CT_DUMMY)then begin
				hBr := GetStockObject(WHITE_BRUSH);
				crOldTxtColor := SetTextColor(dc, RGB(0, 0, 0));
			end else begin
				hBr := Dummy.lpDummy^.hBkBrush;
				crOldTxtColor := SetTextColor(dc, Dummy.lpDummy^.FrColRef);
			end;
		end;

		HideCaret(LOWORD(lParam));

		if IntersectRect(rcTest, Dummy.rc, Dummy.rcParent) <> 0 then begin
			FillRect(dc, rcTest, hBr);

			wOldTxtAlg := SetTextAlign(dc, TA_CENTER OR TA_TOP OR TA_NOUPDATECP);
			nOldBkMode := SetBkMode(dc, TRANSPARENT);
			hOldFnt := SelectObject(dc, SendMessage(hWin, WM_GETFONT, 0, 0));

			if Dummy.lpDummy <> nil then begin

				if (Dummy.lpDummy^.wTypeRep = CT_DUMMY)then begin
					ExtTextOut(dc,
										 Dummy.rc.left + (Dummy.rc.right - Dummy.rc.left) DIV 2,
										 Dummy.rc.top,
										 ETO_CLIPPED,
										 @Dummy.rc,
										 Dummy.lpDummy^.szText,
										 StrLen(Dummy.lpDummy^.szText),
										 nil);
				end else begin
					ExtTextOut(dc,
										 Dummy.rc.left + (Dummy.rc.right - Dummy.rc.left) DIV 2,
										 Dummy.rc.top,
										 ETO_CLIPPED,
										 @Dummy.rc,
										 Dummy.lpDummy^.lpAnswers^.At(0),
										 StrLen(Dummy.lpDummy^.lpAnswers^.At(0)),
										 nil);
				end;

			end;

			SelectObject(dc, hOldFnt);
			SetBkMode(dc, nOldBkMode);
			SetTextAlign(dc, wOldTxtAlg);
		end;
		if IntersectRect(rcTest, Dummy.rc2, Dummy.rcParent) <> 0 then begin
			FillRect(dc, rcTest, hBr);
		end;
		if IntersectRect(rcTest, Dummy.rc3, Dummy.rcParent) <> 0 then begin
			FillRect(dc, rcTest, hBr);
		end;

		ShowCaret(LOWORD(lParam));

		if IntersectRect(rcTest, Dummy.rc, Dummy.rcParent) <> 0 then begin
			ExcludeClipRect(dc,
											Dummy.rc.left,
											Dummy.rc.top,
											Dummy.rc.right,
											Dummy.rc.bottom);
		end;
		if IntersectRect(rcTest, Dummy.rc2, Dummy.rcParent) <> 0 then begin
			ExcludeClipRect(dc,
											Dummy.rc2.left,
											Dummy.rc2.top,
											Dummy.rc2.right,
											Dummy.rc2.bottom);
		end;
		if IntersectRect(rcTest, Dummy.rc3, Dummy.rcParent) <> 0 then begin
			ExcludeClipRect(dc,
											Dummy.rc3.left,
											Dummy.rc3.top,
											Dummy.rc3.right,
											Dummy.rc3.bottom);
		end;

		SetTextColor(dc, crOldTxtColor);
	end;
	DrawDummy := FALSE;
end;

PROCEDURE TEditTexte.UMCtlColor(Var Msg : TMessage);
var Dummy : TDummyRec;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+154, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	EnumDummy(DrawDummy, Msg.wParam, Msg.lParam, Dummy);
	DefWndProc(Msg);
END;

PROCEDURE TEditTexte.UMMoveTo(var Msg : TMessage);
var Dummy			: TDummyRec;
		rcTest		: TRECT;
		ichStart,
		ichEnd		: integer;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+155, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	case Msg.wParam of

		MT_FIRST :
			begin
				{ Reset FirstDummy Proc };
				FirstDummy(0, Dummy, RESETDUMMYPROC, 0);
				{ Find First }
				EnumDummy(FirstDummy, 0, Msg.lParam, Dummy);
			end;

		MT_NEXT :
			begin
				{ Reset NextDummy Proc };
				NextDummy(0, Dummy, RESETDUMMYPROC, 0);
				{ Find Next }
				EnumDummy(NextDummy, 0, Msg.lParam, Dummy);
			end;

		MT_PREVIOUS :
			begin
				{ Reset PrevDummy Proc };
				PrevDummy(0, Dummy, RESETDUMMYPROC, 0);
				{ Find Previous }
				EnumDummy(PrevDummy, 0, Msg.lParam, Dummy);
			end;

		MT_LAST :
			begin
				{ Find Last }
				EnumDummy(LastDummy, 0, Msg.lParam, Dummy);
			end;

	end;

	{ Dummy trouvé ? }
	if Dummy.szDummyID[0] <> #0 then begin
		{ Dummy visible ? }
		if IntersectRect(rcTest, Dummy.rc, Dummy.rcParent) <> 0 then begin
			if (Dummy.lpDummy^.wTypeRep = CT_DUMMY)then begin
				Focus;
				CreateEditDummy(Dummy);
			end else begin
				Dummy.lpDummy^.Focus;
			end;
		end else begin
			{ rend Dummy visible et reposte le message }
			ichStart := SendMessage(HWindow, EM_LINEINDEX, Dummy.nFirstLine, 0);
			ichEnd := SendMessage(HWindow, EM_LINEINDEX, Dummy.nLastLine, 0);
			{SendMessage(HWindow, EM_SETSEL, 0, MAKELONG( ichStart, ichEnd));}
			SendMessage(HWindow, EM_SETSEL, 0, MAKELONG( ichStart, ichStart));
			PostMessage(HWindow, Msg.Message, Msg.wParam, Msg.lParam);
		end;
	end;

END;

function FindDummyByPos(hWin : HWND; Dummy : TDummyRec; wParam : WORD; lParam : DWORD) : Boolean; far;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+156, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	FindDummyByPos := PtInRect(Dummy.rc, TPOINT(lParam)) OR
										PtInRect(Dummy.rc2, TPOINT(lParam)) OR
										PtInRect(Dummy.rc3, TPOINT(lParam));
end;

PROCEDURE TEditTexte.WMLButtonDown(Var Msg : TMessage);
var DummyRet : TDummyRec;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+157, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	{ click sur dummy ? }
	EnumDummy(FindDummyByPos, 0, Msg.LParam, DummyRet);
	if DummyRet.szDummyID[0] <> #0 then begin
		{ click sur dummy ! }
		If MainQcmWin^.wMode >= M_ELEV then begin
			if (DummyRet.lpDummy^.wTypeRep = CT_DUMMY)then begin
				Focus;
				CreateEditDummy(DummyRet);
			end else begin
				DummyRet.lpDummy^.Focus;
				DummyRet.lpDummy^.bChecked := TRUE;
				SendMessage(DummyRet.lpDummy^.HWindow, WM_LBUTTONDOWN, Msg.wParam, 0);
				{SendMessage(DummyRet.lpDummy^.HWindow, WM_LBUTTONUP, Msg.wParam, 0);}
			end;
		end else begin
			MainQcmWin^.SelectWindow(DummyRet.lpDummy);
		end;
	end else begin
		MainQcmWin^.SelectWindow(PMoveWindow(Parent));
		DefWndProc(Msg);
	end;
END;

PROCEDURE TEditTexte.WMLButtonUp(Var Msg : TMessage);
var DummyRet : TDummyRec;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+158, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	{ click sur dummy ? }
	EnumDummy(FindDummyByPos, 0, Msg.LParam, DummyRet);
	if DummyRet.szDummyID[0] <> #0 then begin
		{ click sur dummy ! }
		If MainQcmWin^.wMode >= M_ELEV then begin
			if (DummyRet.lpDummy^.wTypeRep = CT_HYPERLINK)then begin
				SendMessage(DummyRet.lpDummy^.HWindow, WM_LBUTTONUP, Msg.wParam, 0);
				exit;
			end;
		end;
	end;

	SendMessage(Parent^.HWindow, WM_LBUTTONUP, Msg.wParam, Msg.lParam);
	DefWndProc(Msg);
	Focus;

	If MainQcmWin^.wMode >= M_ELEV Then
	 SendMessage(Parent^.HWindow, WM_LBUTTONDOWN, Msg.wParam, Msg.lParam);

END;

PROCEDURE TEditTexte.WMLButtonDblClk(Var Msg : TMessage);
var DummyRet : TDummyRec;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+159, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	{ click sur dummy ? }
	EnumDummy(FindDummyByPos, 0, Msg.LParam, DummyRet);
	if DummyRet.szDummyID[0] <> #0 then begin
			{ click sur dummy ! ouvrir fenêtre d'édition }
			If MainQcmWin^.wMode >= M_ELEV then begin
				if (DummyRet.lpDummy^.wTypeRep = CT_DUMMY)then begin
					Focus;
					CreateEditDummy(DummyRet);
				end else begin
					DummyRet.lpDummy^.Focus;
				end;
			end else begin
				SendMessage(DummyRet.lpDummy^.HWindow, WM_LButtonDblClk, Msg.wParam, Msg.lParam);
			end;
	end else begin
		SendMessage(Parent^.HWindow, Msg.Message, Msg.wParam, Msg.lParam);
	end;
END;

function FindDummyByID(hWin : HWND; Dummy : TDummyRec; wParam : WORD; lParam : DWORD) : Boolean; far;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+160, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	FindDummyByID := StrComp(Dummy.szDummyID, PChar(lParam)) = 0;
end;

PROCEDURE TEditTexte.NewDummy;
var p				: PDUMMY;
		Max,
		id,
		errPos,
		c,
		s,
		e			  : integer;
		szID	  : array[0..255]of char;
		szText  : array[0..255]of char;
		dc			: HDC;
		ptText,
		ptID		: TSIZE;
		hOldFnt	: HFONT;
		psz			: PCHAR;
		OldC		: CHAR;

const
		nTabStop : integer = 0;

	Procedure Count(p : PDummy); far;
	begin

		if ((TypeOf(p^) = TypeOf(TDummy)) OR
				(TypeOf(p^) = TypeOf(THyperLink))) then begin
			inc(c);
			psz := StrPos(p^.szID, '.');
			if psz <> nil then begin
				OldC := psz^;
				psz^ := #0;
			end;
			Val(p^.szID, id, errPos);
			if errPos = 0 then begin
				if Max < id then Max := id;
			end;
			if psz <> nil then begin
				psz^ := OldC;
			end;
		end;
	end;

begin
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+161, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	{ récup texte selectioné }
	GetSelection(s, e);

	GetSubText(szText, s, s + 1);
	while (szText[0] = ' ') AND
				(s < e) do begin
		inc(s);
		GetSubText(szText, s, s + 1);
	end;

	GetSubText(szText, e - 1, e);
	while (szText[0] = ' ') AND
				(e > s) do begin
		dec(e);
		GetSubText(szText, e - 1, e);
	end;

	if s = e then exit;

	if NOT SetSelection(s, e) then exit;

	GetSubText(szText, s, e);

	{ calcul nouvel ID }
	Max := 0;
	c := 0;
	PRepTexteWin(Parent)^.ForEach(@Count);
	if c < Max then c := Max + 1;
	wvsprintf(szID, '{%d', c);

	{ Ajuste taille ID à la taille du texte selectionné }
	dc := GetDC(HWindow);
	hOldFnt := SelectObject(dc, PRepTexteWin(Parent)^.hFnt);
	longint(ptText) := GetTabbedTextExtent(dc, szText, StrLen(szText), 0, nTabStop);
	repeat
		longint(ptID) := GetTabbedTextExtent(dc, szID, StrLen(szID), 0, nTabStop) +
										 GetTabbedTextExtent(dc, '}', 1, 0, nTabStop);
		if ptText.cx > ptID.cx then StrCat(szID, '.');
	until ptText.cx <= ptID.cx;
	SelectObject(dc, hOldFnt);
	ReleaseDC(HWindow, dc);

	{ Insert le nouvel objet Dummy dans la liste des Dummies }
	p := New(PDummy, Init(PQCMWin(Parent), PChar(@szID[1]), ''));
	Application^.MakeWindow(p);
	p^.lpAnswers^.Insert(StrNew(szText));
	{lpDummies^.Insert(p);}
	StrCat(szID, '}');

	{ Insert l'ID dans l'Edit }
	Insert(szID);

	MainQcmWin^.SelectWindow(p);

end;

PROCEDURE TEditTexte.NewHyperLink;
var p				: PDUMMY;
		Max,
		id,
		errPos,
		c,
		s,
		e			  : integer;
		szID	  : array[0..255]of char;
		szText  : array[0..255]of char;
		dc			: HDC;
		ptText,
		ptID		: TSIZE;
		hOldFnt	: HFONT;
		psz			: PCHAR;
		OldC		: CHAR;

const
		nTabStop : integer = 0;

	Procedure Count(p : PDummy); far;
	begin

		if (TypeOf(p^) = TypeOf(TDummy)) OR
			 (TypeOf(p^) = TypeOf(THyperLink)) then begin
			inc(c);
			psz := StrPos(p^.szID, '.');
			if psz <> nil then begin
				OldC := psz^;
				psz^ := #0;
			end;
			Val(p^.szID, id, errPos);
			if errPos = 0 then begin
				if Max < id then Max := id;
			end;
			if psz <> nil then begin
				psz^ := OldC;
			end;
		end;
	end;

begin
	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+161, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	{ récup texte selectioné }
	GetSelection(s, e);

	GetSubText(szText, s, s + 1);
	while (szText[0] = ' ') AND
				(s < e) do begin
		inc(s);
		GetSubText(szText, s, s + 1);
	end;

	GetSubText(szText, e - 1, e);
	while (szText[0] = ' ') AND
				(e > s) do begin
		dec(e);
		GetSubText(szText, e - 1, e);
	end;

	if s = e then exit;

	if NOT SetSelection(s, e) then exit;

	GetSubText(szText, s, e);

	{ calcul nouvel ID }
	Max := 0;
	c := 0;
	PRepTexteWin(Parent)^.ForEach(@Count);
	if c < Max then c := Max + 1;
	wvsprintf(szID, '{%d', c);

	{ Ajuste taille ID à la taille du texte selectionné }
	dc := GetDC(HWindow);
	hOldFnt := SelectObject(dc, PRepTexteWin(Parent)^.hFnt);
	longint(ptText) := GetTabbedTextExtent(dc, szText, StrLen(szText), 0, nTabStop);
	repeat
		longint(ptID) := GetTabbedTextExtent(dc, szID, StrLen(szID), 0, nTabStop) +
										 GetTabbedTextExtent(dc, '}', 1, 0, nTabStop);
		if ptText.cx > ptID.cx then StrCat(szID, '.');
	until ptText.cx <= ptID.cx;
	SelectObject(dc, hOldFnt);
	ReleaseDC(HWindow, dc);

	{ Insert le nouvel objet Dummy dans la liste des Dummies }
	p := New(PHyperLink, Init(PQCMWin(Parent), PChar(@szID[1]), ''));
	Application^.MakeWindow(p);
	p^.lpAnswers^.Insert(StrNew(szText));
	{lpDummies^.Insert(p);}
	StrCat(szID, '}');

	{ Insert l'ID dans l'Edit }
	Insert(szID);

	MainQcmWin^.SelectWindow(p);

end;

function TEditTexte.IsDummyHere(lpDummy : PDummy) : Boolean;
var Dummy		: TDummyRec;
begin
	Dummy.lpDummy := nil;
	EnumDummy(FindDummyByID, 0, DWORD(@lpDummy^.szID), Dummy);
	IsDummyHere := Dummy.lpDummy <> nil;
end;

PROCEDURE TEditTexte.RemoveDummy(lpDummy : PDummy);
var Dummy		: TDummyRec;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+162, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Dummy.lpDummy := nil;
	EnumDummy(FindDummyByID, 0, DWORD(@lpDummy^.szID), Dummy);
	if Dummy.lpDummy <> nil then begin
		SetSelection(Dummy.s, Dummy.e);
		if lpDummy^.lpAnswers^.count > 0 then begin
			Insert(lpDummy^.lpAnswers^.At(0));
			SetSelection(Dummy.s, Dummy.s + StrLen(lpDummy^.lpAnswers^.At(0)));
		end else begin
			Insert('');
		end;
	end;
	PostMessage(PRepTexteWin(Parent)^.Hwindow, WM_LButtonDown, 0, MakeLong(WORD(-1), WORD(-1)));
end;

PROCEDURE TEditTexte.CreateEditDummy(Dummy : TDummyRec);
var	pEditDum : PEditDummy;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+163, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	pEditDum := New(PEditDummy,
									Init(@Self,
											 Dummy));
	Application^.MakeWindow(pEditDum);
	SendMessage(pEditDum^.HWindow, WM_SETFONT, PRepTexteWin(Parent)^.hFnt, MAKELONG(WORD(TRUE), 0));

	if bWin95 then begin
		ActivateKeyboardFromCharset(PRepTexteWin(Parent)^.hLogFnt.lfCharset);
	end;

	{ donner focus fenêtre d'édition  N.B. sur KillFocus fenêtre détruite }
	pEditDum^.Focus;
end;

PROCEDURE TEditTexte.WMSetCursor(Var Msg : TMessage);
VAR
	 pt 			: TPoint;
	 cRect 		: TRect;
	 DummyRet : TDummyRec;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+164, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		GetCursorPos(pt);
		ScreenToClient(HWindow, pt);
		GetClientRect(HWindow, cRect);

		{ sur dummy ? }
		EnumDummy(FindDummyByPos, 0, DWORD(pt), DummyRet);
		if DummyRet.szDummyID[0] <> #0 then begin
			{ sur dummy ! }
			If MainQcmWin^.wMode = M_MAKE then begin
				SetCursor(MainQcmWin^.HCursorHand);
			end else begin
				SetCursor(MainQcmWin^.HCursorHand);
			end;
		end else begin

		 If PtInRect(cRect, pt) Then Begin
				If MainQcmWin^.wMode = M_MAKE Then begin
					SetCursor(LoadCursor(0, IDC_IBEAM));
				end Else begin
					DefWndProc(Msg);
				end;
		 End Else begin
				DefWndProc(Msg);
		 end;

		end;
END;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{------------------------ Implémentation de THyperLink ------------------------}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
constructor THyperLink.Init(AParent : PQcmWin; pID, pText : PChar);
begin

	Inherited Init(AParent, pID, pText);
	wTypeRep := CT_HYPERLINK;
	FrColRef := RGB(0, 0, 127);
	bAutoRet := TRUE;
	bTrig := TRUE;

end;

CONSTRUCTOR THyperLink.Load(Var S : TStream);
BEGIN
	Inherited Load(S);
	wTypeRep := CT_HYPERLINK;
END;

PROCEDURE THyperLink.Store(Var S : TStream);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+165, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited Store(S);
END;

destructor THyperLink.Done;
begin
	Inherited Done;
end;

PROCEDURE THyperLink.SetTypeRep;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+166, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	SendMessage(WinToolsHandle, UM_SETTYPEREP, CT_HYPERLINK, 0);
END;

PROCEDURE THyperLink.SetLineTexte;
CONST
	 szValeur : szLongName = '';
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+167, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TReponseWin.SetLineTexte;
		 wvsPrintF(szValeur, ' - Hyper Lien - Valeur : %i points', nValeur);
		 StrCat(MainQcmWin^.szLineTexte, szValeur);
END;

FUNCTION THyperLink.GetCheck : Word;
var i			 		: integer;
		bMatch		: BOOL;
		p					: PCHAR;

begin

	If bChecked Then GetCheck := 1 Else GetCheck := 0;

END;

{PROCEDURE THyperLink.WMLButtonDown(Var Msg : TMessage);
BEGIN
END;}

PROCEDURE THyperLink.WMLButtonDblClk(Var Msg : TMessage);
VAR szOrdre : Array[0..4] Of Char;
		dlgSetObj  : PSetDummyDlg;
		nRet, code, nOrdre : Integer;
		r : TRECT;
		lStyle : Longint;
CONST bInDblClk : boolean = FALSE;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+169, 0, 0, 0, nil, TRUE);
	{$ENDIF}


		 If (MainQcmWin^.wMode >= M_ELEV) AND
				(MainQcmWin^.wMode < M_TUTOR) AND
				 RecordingR Then Begin
				If bChecked Then SetCheck(0) Else SetCheck(1);
				Exit;
		 End;

		 If(MainQcmWin^.wMode >= M_ELEV) Then Exit;

		 {*** test réentrance ***}
		 If(bInDblClk) Then Exit;
		 bInDblClk := TRUE;

		 dlgSetObj := New(PSetDummyDlg, Init(MainQcmWin^.Parent, 'SETHYPERLINK', lpSelSeqInLessonToCall));
		 dlgSetObj^.DataDummy.lpAnswers := lpAnswers;
		 With dlgSetObj^.DataDummy Do Begin
				 Str(nValeur, szValeur); {Valeur de la réponse}
				 GetWindowText(hWindow, szTitle, SizeOf(szTitle));
				 If bBorder Then nBordure := 1  {Etat de la checkbox bordure visible}
						Else nBordure := 0;
				 If bCheckVisible Then nCase := 1 Else nCase := 0;
				 If bAutoRet Then nAutoRet := 1 Else nAutoRet := 0;
				 If bTrig Then nTrig := 1 Else nTrig := 0;
				 If bCurseurMain Then Begin
						nFleche  := 0;
						nMain    := 1;
				 End Else Begin
						 nFleche  := 1;
						 nMain    := 0;
				 End;
				 {Collection pour remplir la combo des leçons}
				 lpLessons:= New(PStrCollection, Init(10, 5));
				 FillCollecLecon(lpLessons);
				 StrCopy(szSelLess, szLessonToCall);
				 {Collection pour remplir la combobox des priorités d'appels}
				 lpPrior := New(PStrCollection, Init(10, 5));
				 For i := 1 To MainQcmWin^.lpColBranch^.Count Do Begin
						 wvsPrintF(szOrdre, '%i', i);
						 lpPrior^.Insert(StrNew(szOrdre));
				 End;
				 nOrdre := nOrdBranch + 1;
				 wvsPrintF(szSelPrio, '%i', nOrdre);
		 End;
		 with dlgSetObj^.Data do begin
				 GetMem(pScript, 32767);
				 StrCopy(pScript, '// Script Objet Tuteur.');
				 if lpszScript <> nil then begin
					 StrCopy(pScript, lpszScript);
				 end;
				 BkColorRef := BkColRef;
				 FrColorRef := FrColRef;
				 LogFont := hLogFnt;
		 end;
		 nRet := Application^.ExecDialog(dlgSetObj);
		 bInDblClk := FALSE;
		 If nRet = 1 Then Begin
				With dlgSetObj^.DataDummy Do Begin
						Val(szValeur, nValeur, code);
						SetWindowText(hWindow, szTitle);

						lStyle := GetWindowLong(HWindow, GWL_STYLE);
						If nBordure = 1 then begin
							bBorder := TRUE;
							lStyle := lStyle OR WS_BORDER;
						end else begin
							bBorder := FALSE;
							lStyle := lStyle AND NOT WS_BORDER;
						end;

						SetWindowLong(HWindow, GWL_STYLE, lStyle);
						SetWindowPos(HWindow, 0, 0, 0, 0, 0, SWP_DRAWFRAME OR SWP_NOMOVE OR SWP_NOSIZE OR SWP_NOZORDER);

						If nCase = 1 Then bCheckVisible := TRUE Else bCheckVisible := FALSE;
						bAutoRet := nAutoRet = 1;
						bTrig := nTrig = 1;
						SendMessage(HWindow, WM_SIZE, 0, MakeLong(Attr.W, Attr.H));
						If nFleche = 1 Then bCurseurMain := FALSE Else bCurseurMain := TRUE;
						If nValeur > 0 Then SetCheck(1) Else SetCheck(0);
						StrCopy(szLessonToCall, szSelLess);
						Val(szSelPrio, nOrdre, code);
						Dec(nOrdre);
						UpdateBrOrder(nOrdre);
				End;
				with dlgSetObj^.Data do begin
					 if lpszScript <> nil then begin
						 StrDispose(lpszScript);
						 lpszScript := nil;
					 end;
					 if pScript <> nil then begin
						 lpszScript := StrNew(pScript);
						 FreeMem(pScript, 32767);
						 pScript := nil;
					 end;
						BkColRef := BkColorRef;
						if(hBkBrush <> 0) then begin
							deleteObject(hBkBrush);
							hBkBrush := CreateSolidBrush(BkColRef);
						end;
						FrColRef := FrColorRef;
						hLogFnt := LogFont;
						if(hFnt <> 0) then begin
							deleteObject(hFnt);
							hFnt := CreateFontIndirect(hLogFnt);
							if (lpCtl <> nil) then begin
								SendMessage(lpCtl^.HWindow, WM_SETFONT, hFnt, 0);
							end;
						end;
			 end;
		 End;
	 MainQcmWin^.UpdateLineTexte(-1);
END;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{------------------------ Implémentation de TDummy ------------------------}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
constructor TDummy.Init(AParent : PQcmWin; pID, pText : PChar);
begin

	Inherited Init(AParent, '', 0, 0);
	wTypeRep := CT_DUMMY;

	lpAnswers	:= New(PStrCollection, Init(10, 5));

	Attr.X := 0;
	Attr.Y := 0;
	Attr.W := 0;
	Attr.H := 0;
	bCheckVisible := FALSE;
	bChecked := FALSE;

	StrCopy(szID, pID);
	StrCopy(szText, pText);
	bValid := FALSE;
end;

CONSTRUCTOR TDummy.Load(Var S : TStream);
BEGIN
	Inherited Load(S);
	wTypeRep := CT_DUMMY;

	Attr.X := 0;
	Attr.Y := 0;
	Attr.W := 0;
	Attr.H := 0;

	S.Read(szID, SizeOf(szID));
	S.Read(szText, SizeOf(szText));
	szText[0] := #0;

	lpAnswers	:= PStrCollection(S.Get);
	bValid := FALSE;
END;

PROCEDURE TDummy.Store(Var S : TStream);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+165, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited Store(S);

	S.Write(szID, SizeOf(szID));
	S.Write(szText, SizeOf(szText));

	S.Put(lpAnswers);
END;

destructor TDummy.Done;
begin
	PRepTexteWin(Parent)^.lpEdit^.RemoveDummy(@Self);
	Dispose(lpAnswers, done);
	Inherited Done;
end;

PROCEDURE TDummy.SetTypeRep;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+166, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 SendMessage(WinToolsHandle, UM_SETTYPEREP, CT_DUMMY, 0);
END;

PROCEDURE TDummy.SetLineTexte;
CONST
	 szValeur : szLongName = '';
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+167, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TReponseWin.SetLineTexte;
		 wvsPrintF(szValeur, ' - Trou de texte - Valeur : %i points', nValeur);
		 StrCat(MainQcmWin^.szLineTexte, szValeur);
END;

FUNCTION TDummy.GetCheck : Word;
var i			 		: integer;
		bMatch		: BOOL;
		p					: PCHAR;

	function Matches(p : PChar) : Boolean; far;
	begin

		Matches := StrIComp(p, szText) = 0;
	end;

begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+168, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	{ supprime les espaces en trop }
	p := StrPos(szText, '  ');
	while p <> nil do begin
		StrCopy(p, PCHAR(@p[1]));
		p := StrPos(szText, '  ');
	end;
	p := PCHAR(@szText[0]);
	while p[0] = ' ' do begin
		StrCopy(p, PCHAR(@p[1]));
	end;
	if p[0] <> #0 then begin
		while p[StrLen(p) - 1] = ' ' do begin
			p[StrLen(p) - 1] := #0;
		end;
	end;

	bChecked := lpAnswers^.FirstThat(@Matches) <> nil;

	if nValeur <= 0 then begin
		bChecked := NOT bChecked;
	end;

	If bChecked Then GetCheck := 1 Else GetCheck := 0;

END;

PROCEDURE TDummy.WMLButtonDblClk(Var Msg : TMessage);
VAR szOrdre : Array[0..4] Of Char;
		dlgSetObj  : PSetDummyDlg;
		nRet, code, nOrdre : Integer;
		r : TRECT;
		lStyle : Longint;
CONST bInDblClk : boolean = FALSE;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+169, 0, 0, 0, nil, TRUE);
	{$ENDIF}


		 If (MainQcmWin^.wMode >= M_ELEV) AND
				(MainQcmWin^.wMode < M_TUTOR) AND
				 RecordingR Then Begin
				If bChecked Then SetCheck(0) Else SetCheck(1);
				Exit;
		 End;

		 If(MainQcmWin^.wMode >= M_ELEV) Then Exit;

		 {*** test réentrance ***}
		 If(bInDblClk) Then Exit;
		 bInDblClk := TRUE;

		 dlgSetObj := New(PSetDummyDlg, Init(MainQcmWin^.Parent, 'SETDUMMY', lpSelSeqInLessonToCall));
		 dlgSetObj^.DataDummy.lpAnswers := lpAnswers;
		 With dlgSetObj^.DataDummy Do Begin
				 Str(nValeur, szValeur); {Valeur de la réponse}
				 GetWindowText(hWindow, szTitle, SizeOf(szTitle));
				 If bBorder Then nBordure := 1  {Etat de la checkbox bordure visible}
						Else nBordure := 0;
				 If bCheckVisible Then nCase := 1 Else nCase := 0;
				 If bAutoRet Then nAutoRet := 1 Else nAutoRet := 0;
				 If bTrig Then nTrig := 1 Else nTrig := 0;
				 If bCurseurMain Then Begin
						nFleche  := 0;
						nMain    := 1;
				 End Else Begin
						 nFleche  := 1;
						 nMain    := 0;
				 End;
				 {Collection pour remplir la combo des leçons}
				 lpLessons:= New(PStrCollection, Init(10, 5));
				 FillCollecLecon(lpLessons);
				 StrCopy(szSelLess, szLessonToCall);
				 {Collection pour remplir la combobox des priorités d'appels}
				 lpPrior := New(PStrCollection, Init(10, 5));
				 For i := 1 To MainQcmWin^.lpColBranch^.Count Do Begin
						 wvsPrintF(szOrdre, '%i', i);
						 lpPrior^.Insert(StrNew(szOrdre));
				 End;
				 nOrdre := nOrdBranch + 1;
				 wvsPrintF(szSelPrio, '%i', nOrdre);
		 End;
		 with dlgSetObj^.Data do begin
				 BkColorRef := BkColRef;
				 FrColorRef := FrColRef;
				 LogFont := hLogFnt;
		 end;
		 nRet := Application^.ExecDialog(dlgSetObj);
		 bInDblClk := FALSE;
		 If nRet = 1 Then Begin
				With dlgSetObj^.DataDummy Do Begin
						Val(szValeur, nValeur, code);
						SetWindowText(hWindow, szTitle);

						lStyle := GetWindowLong(HWindow, GWL_STYLE);
						If nBordure = 1 then begin
							bBorder := TRUE;
							lStyle := lStyle OR WS_BORDER;
						end else begin
							bBorder := FALSE;
							lStyle := lStyle AND NOT WS_BORDER;
						end;

						SetWindowLong(HWindow, GWL_STYLE, lStyle);
						SetWindowPos(HWindow, 0, 0, 0, 0, 0, SWP_DRAWFRAME OR SWP_NOMOVE OR SWP_NOSIZE OR SWP_NOZORDER);

						If nCase = 1 Then bCheckVisible := TRUE Else bCheckVisible := FALSE;
						bAutoRet := nAutoRet = 1;
						bTrig := nTrig = 1;
						SendMessage(HWindow, WM_SIZE, 0, MakeLong(Attr.W, Attr.H));
						If nFleche = 1 Then bCurseurMain := FALSE Else bCurseurMain := TRUE;
						If nValeur > 0 Then SetCheck(1) Else SetCheck(0);
						StrCopy(szLessonToCall, szSelLess);
						Val(szSelPrio, nOrdre, code);
						Dec(nOrdre);
						UpdateBrOrder(nOrdre);
				End;
		 End;
	 MainQcmWin^.UpdateLineTexte(-1);
END;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{------------------------ Implémentation de TDummies-----------------------}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
constructor TDummies.Init(ALimit, ADelta: Integer);
begin
	Inherited Init(ALimit, ADelta);
end;

CONSTRUCTOR TDummies.Load(Var S : TStream);
BEGIN
	Inherited Load(S);
END;

PROCEDURE TDummies.Store(Var S : TStream);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+170, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited Store(S);
END;

destructor TDummies.Done;
begin
	Inherited Done;
end;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{------------------------ Implémentation de TEditDummy --------------------}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

CONSTRUCTOR TEditDummy.Init(AParent : PMoveWindow; Dummy : TDummyRec);
var szText	: array[0..255] of char;
BEGIN
		 if Dummy.lpDummy <> nil then begin
				StrCopy(szText, Dummy.lpDummy^.szText);
		 end else begin
				szText[0] := #0;
		 end;

		 TEdit.Init(AParent,
								Dummy.rc.left + Dummy.rc.top,
								szText,
								Dummy.rc.left,
								Dummy.rc.top,
								Dummy.rc.right - Dummy.rc.left,
								Dummy.rc.bottom - Dummy.rc.top,
								MAXCAR_EDIT, FALSE);

		 CurDummy := Dummy;
		 With Attr Do Begin
					Style :=	WS_CHILD OR
										WS_VISIBLE OR
										ES_AUTOHSCROLL;
		 End;
END;

PROCEDURE TEditDummy.WMKillFocus(Var Msg : TMessage);
var hParent	: HWND;
		Dummy		: TDummyRec;

begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+171, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited WMKillFocus(Msg);

	if CurDummy.lpDummy <> nil then begin
		GetText(CurDummy.lpDummy^.szText, SizeOf(CurDummy.lpDummy^.szText));
	end;

	{ stocke le parent }
	hParent := PEditTexte(Parent)^.HWindow;

	{ prend la nouvelle position du Dummy }
	PEditTexte(Parent)^.EnumDummy(FindDummyByID, 0, DWORD(@CurDummy.szDummyID), Dummy);

	{ détruit le Dummy }
	Dispose(PEditDummy(@Self), done);

	{ redessine à l'ancienne et à la nouvelle position si le Dummy à bougé }
	InflateRect(CurDummy.rc, 1, 1);
	InvalidateRect(hParent, @CurDummy.rc, TRUE);
	InflateRect(Dummy.rc, 1, 1);
	if NOT EqualRect(CurDummy.rc, Dummy.rc) then begin
		InvalidateRect(hParent, @Dummy.rc, TRUE);
	end;
	UpdateWindow(hParent);

	if NOT IsRectEmpty(CurDummy.rc2) then begin
		InflateRect(CurDummy.rc2, 1, 1);
		InvalidateRect(hParent, @CurDummy.rc2, TRUE);
		InflateRect(Dummy.rc2, 1, 1);
		if NOT EqualRect(CurDummy.rc2, Dummy.rc2) then begin
			InvalidateRect(hParent, @Dummy.rc2, TRUE);
		end;
		UpdateWindow(hParent);
	end;

	if NOT IsRectEmpty(CurDummy.rc3) then begin
		InflateRect(CurDummy.rc3, 1, 1);
		InvalidateRect(hParent, @CurDummy.rc3, TRUE);
		InflateRect(Dummy.rc3, 1, 1);
		if NOT EqualRect(CurDummy.rc3, Dummy.rc3) then begin
			InvalidateRect(hParent, @Dummy.rc3, TRUE);
		end;
		UpdateWindow(hParent);
	end;

end;

PROCEDURE TEditDummy.WMKeyDown(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+172, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	case Msg.wParam of

		VK_HOME :
			begin
				if GetKeyState(VK_CONTROL) AND $8000 = $8000 then
					SendMessage(PEditTexte(Parent)^.HWindow, UM_MOVETO, MT_FIRST, longint(@CurDummy.szDummyID))
				else
					Inherited WMKeyDown(Msg);
			end;

		VK_END :
			begin
				if GetKeyState(VK_CONTROL) AND $8000 = $8000 then
					SendMessage(PEditTexte(Parent)^.HWindow, UM_MOVETO, MT_LAST, longint(@CurDummy.szDummyID))
				else
					Inherited WMKeyDown(Msg);
			end;

	else
		Inherited WMKeyDown(Msg);
	end;
END;

PROCEDURE TEditDummy.WMChar(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+173, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	case Msg.wParam of

		VK_RETURN :
			begin
				SendMessage(PEditTexte(Parent)^.HWindow, UM_MOVETO, MT_NEXT, longint(@CurDummy.szDummyID));
			end;

		VK_TAB :
			begin
				if GetKeyState(VK_SHIFT) AND $8000 = $8000 then
					SendMessage(PEditTexte(Parent)^.HWindow, UM_MOVETO, MT_PREVIOUS, longint(@CurDummy.szDummyID))
				else
					SendMessage(PEditTexte(Parent)^.HWindow, UM_MOVETO, MT_NEXT, longint(@CurDummy.szDummyID));
			end;

	else
		Inherited WMChar(Msg);
	end;
END;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{------------------------ Implémentation de TReptexteWin ------------------}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

CONSTRUCTOR TRepTexteWin.Init(Aparent : PQcmWin; Atexte : Pchar; AX, AY : Integer);
BEGIN
		 TReponseWin.Init(AParent, Atexte, AX, AY);
		 wTypeRep := CT_TEXTE;
		 With Attr Do Begin
					if (MainQcmWin^.lpReponse <> nil) AND
						 (MainQcmWin^.lpReponse^.wTypeRep <> CT_BITMAP) then begin
						W := MainQcmWin^.lpReponse^.Attr.W;
						H := MainQcmWin^.lpReponse^.Attr.H;
					end else begin
						W := (200 DIV PAS_GRILLE) * PAS_GRILLE;
						H := (64 DIV PAS_GRILLE) * PAS_GRILLE;
					end;
					lpEdit := New(PEditTexte, Init(@Self, 2, '',18 + PAS_GRILLE, 0 + PAS_GRILLE,
																				 W-18 - PAS_GRILLE * 2, H - PAS_GRILLE * 2, MAXCAR_EDIT, True));
					lpCtl := lpEdit;
		 End;
		 If Attr.Title[0] <> ' ' Then LoadFileTxt(Attr.Title) Else lpszTexte := Nil;
		 bChecked := FALSE;
END;

CONSTRUCTOR TRepTexteWin.Load(Var S : TStream);
BEGIN
		 bCreateFromFile := FALSE;
		 bQueryBounds := FALSE;
		 TWindow.load(S); { N.B. Charge aussi les enfants, donc lpEdit^ }
		 S.Read(bBorder, SizeOf(bBorder));
		 S.Read(bCheckVisible, SizeOf(bCheckVisible));
		 S.Read(bCurseurMain, SizeOf(bCurseurMain));
		 OleObject := Nil;
		 S.Read(nValeur, SizeOf(nValeur));
		 S.Read(NOrdBranch, SizeOf(nOrdBranch));
		 S.Read(szLessonToCall, SizeOf(szLessonToCall));
		 lpszTexte := S.StrRead;
		 lpSelSeqInLessonToCall := PStrCollection(S.Get);
		 TReponseWin.load(S);
		 wTypeRep := CT_TEXTE;
		 lpEdit := PEditTexte(At(1));
		 lpCtl := lpEdit;
		 {Initialisation du pointeur lpEdit
		 sur la première et la seule fenêtre fille créée par Load et appel à
		 GetChildren dans la fenêtre MainQcmWin}
END;

PROCEDURE TRepTexteWin.Store(Var S : TStream);
VAR
	 hBufferTexte : THandle;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+174, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TWindow.Store(S); { N.B. Sauve aussi les enfants, donc lpEdit^ }
		 S.Write(bBorder, SizeOf(bBorder));
		 S.Write(bCheckVisible, SizeOf(bCheckVisible));
		 S.Write(bCurseurMain, SizeOf(bCurseurMain));
		 S.Write(nValeur, SizeOf(nValeur));
		 S.Write(NOrdBranch, SizeOf(nOrdBranch));
		 S.Write(szLessonToCall, SizeOf(szLessonToCall));
		 {Avant de stocker lpszTexte dans S il faut récupérer le texte
		 dans lpEdit, et pour cela il faut faire une allocation dans le tas}
		 hBufferTexte := GlobalAlloc(GPTR, lpEdit^.GetTextLen + 1);
		 If hBufferTexte <> 0 Then Begin
				lpszTexte := GlobalLock(hBufferTexte);
				lpEdit^.GetText(lpszTexte, MaxInt);
		 End Else Begin
				 lpszTexte := Nil;
				 MainQcmWin^.ErrorMessage(HWindow, IDM_GLOBALALLOC);
		 End;
		 S.StrWrite(lpszTexte);
		 S.Put(lpSelSeqInLessonToCall);
		 TReponseWin.Store(S);
		 If hBufferTexte <> 0 Then Begin
        GlobalUnlock(hBufferTexte);
        GlobalFree(hBufferTexte);
		 End;
END;

PROCEDURE TRepTexteWin.SetupWindow;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+175, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited SetupWindow;

		 if(hFnt <> 0) AND(lpEdit <> nil) then begin
				SendMessage(lpEdit^.HWindow, WM_SETFONT, hFnt, 0);
		 end;
		 If lpszTexte <> Nil Then Begin
				{lpszTexte a été initialisé par le constructeur Init
				ou bien par le constructeur Load}
				lpEdit^.SetText(lpszTexte);
				lpEdit^.ProcessScroll;
				StrDispose(lpszTexte);
		 End;
END;

PROCEDURE TRepTexteWin.LoadFileTxt(AFile : PChar);
VAR
	 f : File;
	 wFileSize : Word;
	 hBufferTexte : THANDLE;
	 lpszBufferTexte :PChar;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+176, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 {$i-}
				Assign(f, AFile);
        FileMode := OF_SHARE_DENY_NONE OR OF_READ;
				reset(f,1);
        {$i+}
        If IOResult = 0 Then Begin
           wFileSize := FileSize(f);
					 If wFileSize > MaxInt Then MainQcmWin^.ErrorMessage(HWindow, IDM_TEXTLOAD);
           hBufferTexte := GlobalAlloc(GPTR, wFileSize + 1);
           If hBufferTexte <> 0 Then Begin
             lpszBufferTexte := GlobalLock(hBufferTexte);
						 {$i-}
						 BlockRead(f, lpszBufferTexte^, wFileSize);
             {$i+}
						 If IOResult = 0 Then Begin
               lpszBufferTexte[wFileSize + 1] := #0;
							 lpszTexte := StrNew(lpszBufferTexte);
             End;
             GlobalUnlock(hBufferTexte);
             GlobalFree(hBufferTexte);
           End Else Begin
							 lpszTexte := Nil;
							 MainQcmWin^.ErrorMessage(HWindow, IDM_GLOBALALLOC);
					 End;
        End;
        {$i-}
				Close(f);
        FileMode := OF_SHARE_DENY_NONE OR OF_READWRITE;
        {$i+}
				If IOResult <> 0 Then;
END;

PROCEDURE TRepTexteWin.Paint(PaintDC : hDC; Var PaintInfo : TPaintStruct);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+177, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited Paint(PaintDC, PaintInfo);
		 Inherited ShowHandle(PaintDC);
END;

Procedure TRepTexteWin.WMCtlColor(Var Msg : TMessage); {WM_CTLCOLOR}
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+178, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited WMCtlColor(Msg);
	SendMessage(Msg.LParamLo, UM_CTLCOLOR, Msg.WParam, Msg.LParam);
end;

PROCEDURE TRepTexteWin.WMCommand(Var Msg : TMessage);
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+179, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited WMCommand(Msg);
	SendMessage(Msg.LParamLo, UM_NOTIFY, Msg.WParam, Msg.LParam);
end;

PROCEDURE TRepTexteWin.WMSize(Var Msg : TMessage);
VAR
	 cRect : TRect;
	 nRetrait : Integer;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+180, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited WMSize(Msg);
		 GetClientRect(HWindow, cRect);
		 nRetrait := 0;
		 While nRetrait < 18 Do Inc(nRetrait, PAS_GRILLE);
		 SetWindowPos(lpEdit^.HWindow, 0, nRetrait + PAS_GRILLE, PAS_GRILLE,
									cRect.Right-nRetrait - PAS_GRILLE * 2, cRect.Bottom - PAS_GRILLE * 2, SWP_NOACTIVATE Or SWP_NOZORDER);
		 UpdateWindow(HWindow);
		 DefWndProc(Msg);
END;

PROCEDURE TRepTexteWin.WMLButtonDown(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+181, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 SendMessage(lpEdit^.HWindow, WM_KILLFOCUS, HWindow, 0);
		 Inherited WMLButtonDown(Msg);
END;

PROCEDURE TRepTexteWin.SetTypeRep;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+182, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 SendMessage(WinToolsHandle, UM_SETTYPEREP, CT_TEXTE, 0);
END;

PROCEDURE TRepTexteWin.SetLineTexte;
CONST
	 szValeur : szLongName = '';
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+183, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited SetLineTexte;
		 wvsPrintF(szValeur, ' - Texte - Valeur : %i points', nValeur);
		 StrCat(MainQcmWin^.szLineTexte, szValeur);
END;

DESTRUCTOR TRepTexteWin.Done;
BEGIN
		 Dispose(lpEdit, Done);
		 TReponseWin.Done;
END;



{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{-------------------------Implémentation de TBitmapWin---------------------}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

CONSTRUCTOR TBitmapWin.Init(AParent : PQcmWin; ATexte : PChar; AX, AY : Integer);
VAR
	 rect   : TRect;
	 nCode  : Integer;
	 cX, cY : Integer;
	 szWidth, szHeight : szLongName;
BEGIN
		 TMoveWindow.Init(AParent, ATexte, AX, AY );
		 wTypeRep := CT_BITMAP;
		 If Not InitOleObject Then Begin
				MainQcmWin^.Enable(FALSE);
				Check('OleCreate', OleCreate(OleProtocol, @AppClient.OleClient, 'PBrush',
												MainQcmWin^.ClientDoc, OleObjectName, OleObject, olerender_Draw , CF_DIB));
				bQueryBounds := TRUE;
				With Attr Do Begin
						 GetProfileString('Paintbrush', 'width', '320', szWidth, SizeOf(szLongName));
						 GetProfileString('Paintbrush', 'height', '240', szHeight, SizeOf(szLongName));
						 Val(szwidth, W, nCode);
						 If nCode <> 0 Then W := 320;
						 Val(szHeight, H, nCode);
						 If nCode <> 0 Then H := 240;
						 W := 0;
						 H := 0;
				End;
		 End Else Begin
				{ L'objet OLE doit se créer dans un fenêtre, en attendant que la fenêtre soit créer...}
				With Attr Do Begin
						 W := 100;
						 H := 100;
						 dec(X);
						 dec(Y);
						 W := (W DIV PAS_GRILLE) * PAS_GRILLE;
						 H := (H DIV PAS_GRILLE) * PAS_GRILLE;
				End;
		 End;
		 With Attr Do Begin
					Scroller := New(PScroller, Init(@Self, 5, 5, W, H));
		 End;
		 bTailleAdapt := TRUE;
		 bScroll := FALSE;

		 hdib := 0;
		 di.hdib := 0;
		 di.hdd := 0;
		 StrCopy(di.achFileName, '');
END;

CONSTRUCTOR TBitmapWin.Load(Var S : TStream);
VAR
		BuffSave : TBuffSave;
		ptDummy	 : TPOINT;
BEGIN
		 AppClient.OleClient.lpvtbl := @OleClientVTbl;
		 AppClient.ObjectWindow := @Self;
		 hdib := 0;
		 di.hdib := 0;
		 di.hdd := 0;
		 StrCopy(di.achFileName, '');
		 TMoveWindow.Load(S);
		 wTypeRep := CT_BITMAP;
		 S.Read(bTailleAdapt, SizeOf(bTailleAdapt));
		 S.Read(ptDummy, SizeOf(ptDummy));
		 S.Read(BuffSave, SizeOf(TBuffSave));
		 Attr.Style := Attr.Style Or WS_VISIBLE;
END;

PROCEDURE TBitmapWin.SetupWindow;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+184, 0, 0, 0, nil, TRUE);
	{$ENDIF}

 Inherited SetupWindow;
END;

PROCEDURE TBitmapWin.Store(Var S : TStream);
VAR
	wRect			: TRect;
	BuffSave	: TBuffSave;
	ptDummy		: TPOINT;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+185, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 ptDummy.x := 3;
		 ptDummy.y := 0;
		 TMoveWindow.Store(S);
		 S.Write(bTailleAdapt, SizeOf(bTailleAdapt));
		 S.Write(ptDummy, SizeOf(ptDummy));
		 S.Write(BuffSave, SizeOf(TBuffSave));
END;

PROCEDURE TBitmapWin.WMPalChanged(Var Msg : TMessage);
var dc		: HDC;
		wRet	: WORD;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+186, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	if (di.hdd = 0) OR (di.bi.biBitCount < 8) then Exit;

	dc := GetDC(di.hwin);
	wRet := DrawDibRealize(di.hdd, dc, TRUE);
	if wRet <> 0 then	InvalidateRect(di.hwin, nil, TRUE);
	ReleaseDC(di.hwin, dc);

	Msg.Result := wRet;
END;

PROCEDURE TBitmapWin.WMQueryNewPal(Var Msg : TMessage);
var dc		: HDC;
		wRet	: WORD;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+187, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	if (di.hdd = 0) OR (di.bi.biBitCount < 8) then Exit;

	dc := GetDC(di.hwin);
	wRet := DrawDibRealize(di.hdd, dc, FALSE);
	if wRet <> 0 then	InvalidateRect(di.hwin, nil, TRUE);
	ReleaseDC(di.hwin, dc);

	Msg.Result := wRet;

END;

PROCEDURE TBitmapWin.Paint(dc : hDC; Var PaintInfo : TPaintStruct);
VAR
	 r		            : TRect;

BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+188, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited Paint(dc, PaintInfo);
		 {Couleur de fond}

		 {####GetClientRect(HWindow, r);
		 FillRect(dc, r, hBkBrush);}

		 if bTailleAdapt then begin
			 di.iZoom := 0;
		 end else begin
			 di.iZoom := ZOOM;
		 end;

		 if di.hdib = 0 then begin
			 GetClientRect(HWindow, rect);
			 di.hwin := hWindow;
			 di.hpar := hWindow;
			 di.hdib := 0;
			 di.havi := 0;
			 di.len := 0;
			 StrCopy(di.achFileName, szLinkedFile);
			 LoadBitmapFile(di.achFileName, hdib);
			 DrawDibClose(di.hdd);
			 InitDib(di, hDIB, TRUE);
			 SendMessage(MainQcmWin^.HWindow, WM_QUERYNEWPALETTE, 0, 0);
		 end;

		 if (di.hdib <> 0) then begin
				SetWindowOrg(dc,GetScrollPos(di.hwin,SB_HORZ),GetScrollPos(di.hwin,SB_VERT));
				if NOT BOOL(DrawDibDraw(di.hdd, dc,
																di.rcDraw.left,
																di.rcDraw.top,
																di.rcDraw.right -di.rcDraw.left,
																di.rcDraw.bottom-di.rcDraw.top,
																di.lpbi, nil,
																di.rcSource.left,
																di.rcSource.top,
																di.rcSource.right -di.rcSource.left,
																di.rcSource.bottom-di.rcSource.top,
																DDF_BACKGROUNDPAL)) then
				begin
					WinProcs.MessageBox(window, 'Unable to draw DIB.', 'DrawDib', MB_APPLMODAL OR MB_ICONSTOP);
					FillRect(dc, di.rcDraw, GetStockObject(DKGRAY_BRUSH));
				end;
		 end else begin
				GetClientRect(di.hwin, r);
				FillRect(dc, r, GetStockObject(DKGRAY_BRUSH));
		 end;
		 Inherited ShowHandle(dc);
END;

PROCEDURE TBitmapWin.WMLButtonDblClk(Var Msg : TMessage);
VAR
	 DlgSetBitmap : PSetBmpDlg;
	 nInsertion : Integer;
	 nRet : Integer;
	 nX, nY, nDiv : Integer;
	 nCol, nLign : Integer;
	 cRect : TRect;
	 aTrSetBmp : TtrSetBmp;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+189, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 If MainQcmWin^.wMode >= M_ELEV Then Exit;
		 With aTrSetBmp Do Begin
					If bTailleAdapt Then nTrAdapt := 1 Else nTrAdapt := 0;
		 End;
		 DlgSetBitmap := New(PSetBmpDlg, Init(MainQcmWin^.Parent));
		 DlgSetBitmap^.TransferBuffer := @aTrSetBmp;
		 nRet := Application^.ExecDialog(DlgSetBitmap);

		 nInsertion := DlgSetBitmap^.nDlgVal;
		 If nRet = 1 Then Begin
				nLign := 1;
				nCol  := 1;
				For i := 1 To nInsertion Do If i <= 20 Then Begin
						nY := 5 + 20*nLign;
						nX := 5 + 20*nCol;
						If Attr.H > 31 Then nDiv :=(nY Div(Attr.H -30)) Else nDiv :=1;
						If nDiv > 0 Then Begin
							 nLign := 0;
							 Inc(nCol);
						End;
						Inc(nLign);
						lpRepClip := New(PRepClipWin, Init(@Self, 1, '', nX, nY));
						if lpRepClip <> nil then Application^.MakeWindow(lpRepClip);
				End;
				If aTrSetBmp.nTrAdapt = 1 Then Begin
					 Scroller^.ScrollTo(0, 0);
					 bTailleAdapt := TRUE;
					 ShowScrollBar(HWindow, SB_BOTH, FALSE);
					 bScroll := FALSE;
				End Else Begin
						bTailleAdapt := FALSE;
						SetScrollBar;
				End;
				GetClientRect(HWindow, cRect);
				SendMessage(HWindow, WM_SIZE, 0, MakeLong(cRect.Right, cRect.Bottom));
				{#### ??? ...}
				InvalidateRect(HWindow, nil, TRUE);

		 End;
		 MainQcmWin^.UpdateLineTexte(-1);
END;

PROCEDURE TBitmapWin.WMWindowPosChanging(Var Msg : TMessage); {WM_WINDOWPOSCHANGING TWINDOWPOS}
var rOld	: TRECT;
		nOldW,
		nOldH,
		nNewW,
		nNewH	: integer;

					Procedure Resize(lpChild : PRepClipWin);Far;
					Var nX, nY, nW, nH : Integer;
					Begin

							 {Procedure de resize d'une fenêtre Clip région}
							 With lpChild^.Attr Do Begin
										nX := MulDiv(X, nNewW, nOldW);
										nY := MulDiv(Y, nNewH, nOldH);
										nW := MulDiv(W, nNewW, nOldW);
										nH := MulDiv(H, nNewH, nOldH);
										SetWindowPos(lpChild^.HWindow, 0, nX, nY, nW, nH, SWP_NOACTIVATE OR SWP_NOZORDER);
										X := nX;
										Y := nY;
										W := nW;
										H := nH;
							 End;
					End;
begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+190, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited WMWindowPosChanging(Msg);

	if BOOL(PWINDOWPOS(Msg.lParam)^.flags AND SWP_NOSIZE) then Exit;

	GetWindowRect(HWindow, rOld);
	MapWindowPoints(HWND_DESKTOP, Parent^.HWindow, rOld, 2);
	If bTailleAdapt Then Begin
			ShowScrollBar(HWindow, SB_BOTH, FALSE);
			bScroll := FALSE;
			nNewW := PWINDOWPOS(Msg.lParam)^.cx;
			nNewH := PWINDOWPOS(Msg.lParam)^.cy;
			nOldW := rOld.right - rOld.left;
			nOldH := rOld.bottom - rOld.top;
	End Else Begin
		 SetScrollBar;
	End;
	if bTailleAdapt AND
		 ((nNewH <> nOldH) OR (nNewW <> nOldW))	AND
		 (nNewW <> 0) then begin
		ForEach(@Resize);
	end;
end;

PROCEDURE TBitmapWin.WMSIZE(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+191, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Inherited WMSize(Msg);
	MainQcmWin^.UpdateLineTexte(-1);
	SizeWindowToImage(di);
END;

PROCEDURE TBitmapWin.OleGetBounds(Var ARect : TRect);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+192, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 {Récupération des dimensions oleObject}
		 if OleObject <> nil then begin
			 OleQueryBounds(OleObject, ARect);
			 With ARect Do Begin
					{Conversion en systemme de coord pixel}
					Right := MulDiv(Right, PixPerInch.X, 2540);
					Bottom := MulDiv(- Bottom, PixPerInch.Y, 2540);
			 End;
		 end else begin
				ARect.left := 0;
				ARect.top := 0;
				ARect.right := 100;
				ARect.bottom := 100; {Dummy}
		 end;
END;

PROCEDURE TBitmapWin.SetScrollBar;
VAR
   cRect, oleRect : TRect;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+193, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 {####}
		 exit;

		 GetClientRect(HWindow, cRect);
		 If bScroll Then With cRect Do Begin
				Right := Right + GetSystemMetrics(SM_CXVSCROLL);
				Bottom := Bottom  + GetSystemMetrics(sm_CYHSCROLL);
		 End;
		 OleGetBounds(oleRect);
		 If(oleRect.Right > cRect.Right) Or(oleRect.Bottom > cRect.Bottom) Then Begin
				ShowScrollBar(HWindow, SB_BOTH, TRUE);
				Scroller^.HasHScrollBar := TRUE;
				Scroller^.HasVScrollBar := TRUE;
				bScroll := TRUE;
		 End Else Begin
				 Scroller^.ScrollTo(0, 0);
				 ShowScrollBar(HWindow, SB_BOTH, FALSE);
				 bScroll := FALSE;
		 End;
END;

PROCEDURE TBitmapWin.SetTypeRep;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+194, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	 SendMessage(WinToolsHandle, UM_SETTYPEREP, CT_BITMAP, 0);
END;

PROCEDURE TBitmapWin.SetLineTexte;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+195, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TMoveWindow.SetLineTexte;
		 If bTailleAdapt Then StrCopy(MainQcmWin^.szLineTexte, '- Image - Taille adaptée')
		 Else StrCopy(MainQcmWin^.szLineTexte, '- Image - Taille d''origine');
		 StrCat(MainQcmWin^.szLineTexte, ' - Lien : ');
		 StrCat(MainQcmWin^.szLineTexte, szLinkedFile);
END;

DESTRUCTOR TBitmapWin.Done;
					Procedure FreeRepClip(P : PRepClipWin); Far;
					Begin

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+196, 0, 0, 0, nil, TRUE);
	{$ENDIF}

							 if P <> nil then P^.Free;
					End;
BEGIN
		 ReleaseBitmap(hdib);
		 DrawDibClose(di.hdd);
		 hdib := 0;
		 di.hdib := 0;
		 di.hdd := 0;
		 ForEach(@FreeRepClip);
     Inherited Done;
END;


{-------------------------------------------------------------------------}
{--                   Implementation de TObjetWin                       --}
{-------------------------------------------------------------------------}

CONSTRUCTOR TObjetWin.Init(AParent : PQcmWin; ATexte : PChar; AX, AY, AVerbs : Integer;FromFile : Boolean);
VAR
	 oRect : TRect;
	 i		 : integer;
BEGIN
		 TReponseWin.Init(AParent, ATexte, AX, AY );
		 wTypeRep := CT_AUTRE;
		 nVerbs := AVerbs;
		 AppClient.OleClient.lpvtbl := @OleClientVTbl;
		 AppClient.ObjectWindow := @Self;
		 If Not FromFile Then begin
				MainQcmWin^.Enable(FALSE);
				Check('OleCreate', OleCreate(OleProtocol, @AppClient.OleClient,
							 ATexte, MainQcmWin^.ClientDoc, OleObjectName, OleObject, olerender_draw , 0));
		 end Else begin
			 bCreateFromFile := TRUE;
		 end;
		 bQueryBounds := TRUE;
		 With Attr Do Begin
					W := PAS_GRILLE * 3;
					H := PAS_GRILLE * 4;
					dec(X);
					dec(Y);
					W := (W DIV PAS_GRILLE) * PAS_GRILLE + 2;
					H := (H DIV PAS_GRILLE) * PAS_GRILLE + 2;
					If nVerbs > 1 Then lpButton[0] := New(pButton, Init(@Self, 200, '>', PAS_GRILLE - 1 ,17 + PAS_GRILLE , 16, 16, FALSE));
					{for i := 0 to nVerbs - 1 do begin
						lpButton[i] := New(pButton, Init(@Self, 200 + i, 's', PAS_GRILLE - 1 ,17 * (i + 1) + PAS_GRILLE , 16, 16, FALSE));
					end;}
		 End;
		 bChecked := FALSE;
END;

CONSTRUCTOR TObjetWin.Load(Var S : TStream);
BEGIN
		 AppClient.OleClient.lpvtbl := @OleClientVTbl;
		 AppClient.ObjectWindow := @Self;

		 TMoveWindow.Load(S);
		 wTypeRep := CT_AUTRE;
		 lpCtl := nil;
		 S.Read(bCheckVisible, SizeOf(bCheckVisible));
		 S.Read(bCurseurMain, SizeOf(bCurseurMain));
		 S.Read(nValeur, SizeOf(nValeur));
		 S.Read(nVerbs, SizeOf(nVerbs));
		 S.Read(nOrdBranch, SizeOf(nOrdBranch));
		 S.Read(szLessonToCall, SizeOf(szLessonToCall));
		 lpSelSeqInLessonToCall := PStrCollection(S.Get);
		 TReponseWin.load(S);
		 If nVerbs > 1 Then lpButton[0] := pButton(At(1));
		 {for i := 0 to nVerbs - 1 do begin
				lpButton[i] := pButton(At(i + 1));
		 end;}
END;

PROCEDURE TObjetWin.SetupWindow;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+197, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited SetupWindow;
END;

PROCEDURE TObjetWin.Store(Var S : TStream);
VAR
	 wRect : TRect;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+198, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 TMoveWindow.Store(S);
		 S.Write(bCheckVisible, SizeOf(bCheckVisible));
		 S.Write(bCurseurMain, SizeOf(bCurseurMain));
		 S.Write(nValeur, SizeOf(nValeur));
		 S.Write(nVerbs, SizeOf(nVerbs));
		 S.Write(nOrdBranch, SizeOf(nOrdBranch));
		 S.Write(szLessonToCall, SizeOf(szLessonToCall));
		 S.Put(lpSelSeqInLessonToCall);
		 TReponseWin.Store(S);
END;

PROCEDURE TObjetWin.Play(wVerb : WORD);
VAR
   cRect : TRect;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+199, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 If OleObject <> Nil Then Begin
				 GetClientRect(HWindow, cRect);
				 InflateRect(cRect, -PAS_GRILLE, -PAS_GRILLE);
				 If nVerbs > 1 then begin
						inc(cRect.Left,PAS_GRILLE * 3);
				 end else begin
					 If bCheckVisible Then begin
							inc(cRect.Left,PAS_GRILLE * 3);
					 end;
				 end;
				 Check('OleActivate', OleActivate(OleObject, wVerb, TRUE, TRUE, HWindow, @cRect));
		 End;
END;

PROCEDURE TObjetWin.Play0(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+200, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Play(Msg.wParam - 200);
END;

PROCEDURE TObjetWin.Play1(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+201, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Play(Msg.wParam - 200);
END;

PROCEDURE TObjetWin.Play2(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+202, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Play(Msg.wParam - 200);
END;

PROCEDURE TObjetWin.Play3(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+203, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	Play(Msg.wParam - 200);
END;

PROCEDURE TObjetWin.WMPalChanged(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+204, 0, 0, 0, nil, TRUE);
	{$ENDIF}

	InvalidateRect(HWindow, nil, FALSE);
END;

PROCEDURE TObjetWin.WMQueryNewPal(Var Msg : TMessage);
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+205, 0, 0, 0, nil, TRUE);
	{$ENDIF}

END;

PROCEDURE TObjetWin.Paint(PaintDC : Hdc; Var PaintInfo : TPaintStruct);
VAR
	 cRect 					: TRect;
	 OldStrechMode 	: Integer;
	 OldBmp, hBmp 	: hBitmap;
	 BmpDC 					: hDC;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+206, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited Paint(PaintDC, PaintInfo);
		 GetClientRect(HWindow, cRect);
		 InflateRect(cRect, -PAS_GRILLE, -PAS_GRILLE);
		 If nVerbs > 1 then begin
				inc(cRect.Left,PAS_GRILLE * 3);
		 end else begin
			 If bCheckVisible Then begin
					inc(cRect.Left,PAS_GRILLE * 3);
			 end;
		 end;
		 OldStrechMode := SetStretchBltMode(PaintDC, STRETCH_DELETESCANS);
		 {####if OleObject <> nil then Check('OleDraw',  OleDraw(OleObject, PaintDC, crect, crect, 0));}
		 if OleObject <> nil then OleDraw(OleObject, PaintDC, crect, crect, 0);
		 SetStretchBltMode(PaintDC, OldStrechMode);
		 Inherited ShowHandle(PaintDC);
END;

PROCEDURE TObjetWin.SetTypeRep;
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+207, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 SendMessage(WinToolsHandle, UM_SETTYPEREP, CT_AUTRE, 0);
END;

PROCEDURE TObjetWin.SetLineTexte;
CONST
	 szValeur : szLongName = '';
BEGIN

	{$IFDEF _DEBUG}
	AddDebugFunction(FUNC_QCMWIN, nFUNC_QCMWIN+208, 0, 0, 0, nil, TRUE);
	{$ENDIF}

		 Inherited SetLineTexte;
		 wvsPrintF(szValeur, ' - Valeur : %i points', nValeur);
		 StrCat(MainQcmWin^.szLineTexte, szValeur);
END;


DESTRUCTOR TObjetWin.Done;
BEGIN
		 If nVerbs > 1 Then Dispose(lpButton[0], Done);
		 {for i := 0 to nVerbs - 1 do begin
				Dispose(lpButton[i], Done);
		 end;}
		 Inherited Done;
END;

BEGIN

		 {Pour la sauvegarde des fenêtres en flux}
		 RegisterOWindows;
		 {Pour la sauvegarde des contrôles en flux}
		 RegisterODialogs;
		 bItsARet := FALSE;
END.
{$R-}
{$IFDEF _ALIGN_ON}
	{$A+}
	{$UNDEF _ALIGN_ON}
{$ENDIF}
