
{************************************************}
{   Programme Lavac_ut                           }

{   Projet LAVAC                                 }

{  (c) 1992-94 C Puissance 3 Informatique        }
{              MORGAN MULTIMEDIA                 }

{  par Guillaume de Bailliencourt                }

{  02/02/1994                                    }

{************************************************}

{$Define _NTUTOR}
{$Define _LAVAC_UT_}

program LAVAC_UT;

uses Windows, Dos, SysUtils,
		 CommDlg, mmsystem, VFW, Strings, {toolhelp,}
		 LZExpand,
		 {BWCC,}     {-- Pour les fonctions Borland --}
		 MMLAVAC,  {-- Pour les fonctions propres à LAVAC --}
		 MMDIADIR, {--pour le dialogue--}
		 MMDIB,    {-- Pour les fonctions Multimédia --}
		 MMSTRING,
		 MMMCI,  {-- Pour les fonctions propres aux commandes LAVAC/MCI --}
		 MMWAVE,
                 {$IFDEF _TUTOR}
		 UQcmLavc, {-- Interface Lavac et QCM Object --}
		 UOleInit, {-- Initialisation OLE et flux --}
		 UQcmType, {-- Constantes QCM --}
		 UQcmWin,
		 UQcmRep,
		 UTutDlg,
                 {$ENDIF}
		 mmDrwDib,
		 MCIWnd,
		 CTL3D,
		 MMLic,
		 licData,
		 lavacini,
		 ShellApi,
		 MultiSel,

		 mmHelper,

		 RichEdit
		 ,MMDEBUG,xmlparser, PerMonitorApi
		 ;

{-- Pour l'utilisation des ressources --}
//{$R ..\Res_Dev\LAVACNT32.RES}
{$R ..\Res_Dev\LAVAC_UT_32x64.RES}

var
  szMisFormat: array[0..255] of char;
  szFormat: array[0..255] of char;
  szText: array[0..255] of char;

  stWindowRect: Windows.TRECT;

const
  AppName = 'Lavac_Ut';

const
  PathServeur1: szLongName = 'F:\' + #0;
const
  PathLavac1: szLongName = 'F:\LAVAC\' + #0;
const
  PathLecons1: szLongName = 'F:\LAVAC\LECONS\' + #0;

const
  PathServeur2: szLongName = 'C:\' + #0;
const
  PathLavac2: szLongName = 'C:\LAVAC\' + #0;
const
  PathLecons2: szLongName = 'C:\LAVAC\LECONS\' + #0;

var
  tLecon1, tLecon2: typeLecon;
  tQuestion1, tQuestion2: typeQuestion;
  noLecon1, noLecon2: longint;
  Path: array[0..fsPathName] of char;
  Dir: array[0..fsDirectory] of char;
  Name: array[0..fsFileName] of char;
  Ext: array[0..fsExtension] of char;

const
  MAXLISTSEL = 1024;
  bAlwaysReplace: BOOL = False;

var
  nListSel: array[1..MAXLISTSEL] of integer;
  noSel, nbSel: longint;


const
  ActivWin: integer = 1;

var
  lpThermo: TFarProc;
  hThermo: hWnd;
  szThermo: szLongName;
  nbDisk: integer;
  TotalSize: longint;

  procedure DosCopy(pszFiles, pszFrom, pszTo: PChar);
  var
    DirInfo: TSearchRec;
    szFrom, szTo: array[0..255] of char;
  begin

    StrCopy(szFrom, pszFrom);
    StrCat(szFrom, '\');
    StrCat(szFrom, pszFiles);
    {####}
    // fixed
    szFrom[0] := PathLavac1[0];
    DosError := FindFirst(szFrom, faArchive, DirInfo);
    while DosError = 0 do
    begin
      StrCopy(szFrom, pszFrom);
      StrCat(szFrom, '\');
      StrCat(szFrom, PChar(DirInfo.Name));
      StrCopy(szTo, pszTo);
      StrCat(szTo, '\');
      StrCat(szTo, PChar(DirInfo.Name));
      CopyFile(szFrom, szTo);
      DosError := FindNext(DirInfo);
    end;
    FindClose(DirInfo);
  end;

  function GetCurLbItemData(Dialog: HWND; id: word): integer;
  begin
    GetCurLbItemData := -1;
    dwReturn := SendDlgItemMessage(Dialog, id, LB_GETCARETINDEX,
      0, longint(0));
    if (dwReturn <> LB_ERR) and (dwReturn <>
      LB_ERRSPACE) then
    begin
      GetCurLbItemData :=
        SendDlgItemMessage(Dialog, id, LB_GETITEMDATA, word(dwReturn), longint(0));
    end;
  end;

  function GetLbItemData(Dialog: HWND; id, no: word): integer;
  begin
    GetLbItemData :=
      SendDlgItemMessage(Dialog, id, LB_GETITEMDATA, no, longint(0));
  end;

  {*************************************************************}

  function AttenteProc(hDlg: HWnd; Message, wParam: Dword; LParam: longint): Bool;
  stdcall;

    {*************************************************************}

  begin
    AttenteProc := True;
    case Message of
      WM_INITDIALOG:
      begin
        CenterDialog(hDlg);
      end;
      WM_COMMAND:
        if LOWORD(wParam) = idCancel then
        begin
          ReleaseCapture;
          EnableWindow(Window, True);
          EnableWindow(hLeconProc, True);
          EnableWindow(hBoutonsProc, True);
          DestroyWindow(hDlg);
          hThermo := 0;
        end;
    end;
    AttenteProc := False;
  end;

  function AddToList(Dialog: HWnd; id: word; pszRec: PChar; noRec: longint): DWORD;
  var
    dwRet: DWORD;
  begin
    dwRet := SendDlgItemMessage(Dialog, id, LB_ADDSTRING, 0, DWORD(pszRec));
    if (dwRet <> LB_ERR) and (dwRet <> LB_ERRSPACE) then
    begin
      SendDlgItemMessage(Dialog, id, LB_SETITEMDATA, word(dwRet), noRec);
    end;
    AddToList := dwRet;
  end;

  {*************************************************************}

//function AfficheListeLecon(Dialog: HWnd; id: word; PathFichier: szLongName; bVerif: BOOL): Bool;
function AfficheListeLecon(Dialog: HWnd; id: word; PathFichier: PChar; bVerif: BOOL): Bool;

    {*************************************************************}
  var
    fLecon: FileOfLecon;
    tLecon: TypeLecon;
    dwRet: DWORD;
    i: longint;
    szErr: array[0..255] of char;
    Dir: array[0..fsDirectory] of char;
    Name: array[0..fsFileName] of char;
    Ext: array[0..fsExtension] of char;
    Drive: array[0..1] of char;

  begin
    SendDlgItemMessage(Dialog, id, LB_RESETCONTENT, 0, 0);
    Drive[0] := PathFichier[0];
    Drive[1] := #0;
    FileMode := OF_SHARE_DENY_NONE or OF_READ;
    Assign(fLecon, PChar(PathFichier));
        {$i-}
    reset(fLecon);
        {$i+}
    if IOResult <> 0 then
    begin
      StrCopy(szErr, 'Le fichier ');
      StrCat(szErr, PathFichier);
      StrCat(szErr, ' n''existe pas, voulez-vous le créer ?');
      if MessageBox(Dialog, szErr, tLecon.Nom, MB_YESNO or
        MB_APPLMODAL) = idYes then
      begin
        InOutRes := 0;
        FileSplit(PathFichier, Dir, Name, Ext);
        if (Dir[StrLen(Dir) - 1] = '\') then
           Dir[StrLen(Dir) - 1] := #0;
        CreerRep(Dir);
        Assign(fLecon, PChar(PathFichier));
                        {$i-}
        rewrite(fLecon);
                        {$i+}
      end
      else
      begin
        InOutRes := -1;
      end;
    end;
    if IOResult = 0 then
    begin
      i := 0;
      while not EOF(fLecon) do
      begin
                        {$i-}
        Read(fLecon, tLecon);
                        {$i+}
        if IOResult = 0 then
        begin
          if tLecon.Nom[0] = #0 then
            StrCopy(tLecon.Nom, '<Sans Nom>');
          if StrLen(tLecon.PathLecon) >
            SizeOf(tLecon.PathLecon) - 1 then
          begin
            StrCopy(szErr,
              'Le chemin de cette leçon semble incorect : ');
            StrCat(szErr, tLecon.PathLecon);
            MessageBox(Dialog, szErr, tLecon.Nom, MB_OK);
            tLecon.PathLecon[0] := #0;
          end;
          StrCopy(PathFichier, tLecon.PathLecon);
          StrCat(PathFichier, '\QUESTION.LST');
          {####}
          PathFichier[0] := Drive[0];
          if not FileExist(PathFichier) then
          begin
            StrCopy(szErr,
              'Cette leçon semble ne pas exister, impossible de trouver : ');
            StrCat(szErr, PathFichier);
            if bVerif then
              MessageBox(Dialog, szErr, tLecon.Nom, MB_OK);
          end;
          dwRet :=
            SendDlgItemMessage(Dialog, id, LB_ADDSTRING, 0, DWORD(@tLecon.Nom));
          if (dwRet <> LB_ERR) and (dwRet <> LB_ERRSPACE) then
          begin
            SendDlgItemMessage(Dialog,
              id, LB_SETITEMDATA, word(dwRet), i);
          end;
        end;
        Inc(i);
      end;
                {$i-}
      Close(fLecon);
                {$i+}
      InOutRes := 0;
      FileMode := OF_SHARE_DENY_NONE or OF_READWRITE;
    end;
{  TypeLecon = record
                                                                         Nom       : szLongName;
                                                                         Createur  : szLongName;
                                                                         PathLecon : szLongName;
                                                                         Langue    : Integer;
                                                                         Syquest   : Bool;
                                                                         Serveur   : Bool;
                                                                         AVideo    : Boolean;
                                                                         Reserved  : ARRAY[0..254] of Byte;
                                                                 end;}
  end;

  function AfficheListeQuestion(Dialog: HWnd; id: word; PathFichier: szLongName): Bool;
  var
    fQuestion: FileOfQuestion;
    tQuestion: TypeQuestion;
    dwRet: DWORD;
  begin
    SendDlgItemMessage(Dialog, id, LB_RESETCONTENT, 0, 0);
    FileMode := OF_SHARE_DENY_NONE or OF_READ;
    Assign(fQUESTION, PChar(PathFichier));
        {$i-}
    reset(fQUESTION);
        {$i+}
    if IOResult = 0 then
    begin
                {$i-}
      while not EOF(fQUESTION) do
      begin
        Read(fQUESTION, tQUESTION);
        dwRet :=
          SendDlgItemMessage(Dialog, id, LB_ADDSTRING, 0, longint(@tQUESTION.Nom));
        if (dwRet <> LB_ERR) and (dwRet <> LB_ERRSPACE) then
        begin
        end;
      end;
      Close(fQUESTION);
    {$i+}
      InOutRes := 0;
    end;
    FileMode := OF_SHARE_DENY_NONE or OF_READWRITE;
  end;

  function VoirProc(Dialog: HWnd; Message, wParam: Dword;
    LParam: longint): Bool; stdcall;
  var
    szImage: szLongName;

  begin
    VoirProc := True;
    case Message of
      wm_InitDialog:
      begin
        CenterDialog(Dialog);
        StrCopy(PathFichier, tLecon.PathLecon);
        StrCat(PathFichier, '\QUESTION.LST');
        //MessageBox(GetDesktopWindow, PathFichier, 'VoirProc', MB_OK);
        {####}
        {PathFichier[0] := PathLavac1[0];}
        SetDlgItemText(Dialog, 112, tLecon.Nom);
        SetDlgItemText(Dialog, 113, tLecon.Createur);
        AfficheListeQuestion(Dialog, 102, PathFichier);
      end;

      wm_Command:
      begin
        case LOWORD(wParam) of
          IDOK:
          begin
            EndDialog(Dialog, 1);
          end;
        end;
      end;
    end;
    VoirProc := False;
  end;

  function OptionsProc(Dialog: HWnd; Message, wParam: Dword;
    LParam: longint): Bool; stdcall;
  begin
    OptionsProc := True;
    case Message of
      wm_InitDialog:
      begin
        CenterDialog(Dialog);
        if bAlwaysReplace then
          CheckDlgButton(Dialog, 101, 1);
      end;

      wm_Command:
      begin
        case LOWORD(wParam) of

          idOk:
          begin
            bAlwaysReplace :=
              IsDlgButtonChecked(Dialog, 101) = 1;
            EndDialog(Dialog, 1);
          end;

          idCancel:
          begin
            EndDialog(Dialog, 1);
          end;

        end;
      end;
    end;
    OptionsProc := False;
  end;

  procedure CreateLavacDir;
  begin
        {$I-}
    {StrCopy(Dir,PathServeur2);}
    StrCopy(Dir, PathLavac2);
    StrCat(Dir, '.');
    CreateDir(Dir);
  {StrCopy(Dir,PathServeur2);
  StrCat(Dir,PathLavac2);}
    StrCopy(Dir, PathLecons2);
    StrCat(Dir, '.');
    CreateDir(Dir);
    SetCurrentDirectory(Dir);
    CreerLecon;
  {$I+}
    if IOResult <> 0 then;
  end;

  function ThermoProc(Dialog: HWnd; Message, wParam: Dword;
    LParam: longint): Bool; stdcall;
  begin
    ThermoProc := True;
    case Message of
      wm_InitDialog:
      begin
        CenterDialog(Dialog);
      end;

      wm_MouseActivate:
      begin
        BringWindowToTop(Dialog);
      end;

      wm_Command:
        case LOWORD(wParam) of
          101:
          begin
          end;
        end;
    end;
    ThermoProc := False;
  end;

  function PrepareFiles(hDlg: HWND; wDrvTyp1, wDrvTyp2: word;
    PathLavac1
    : szLongName;
  var
    lSize: longint;
  var
    f
    : Text;
  var bMissFile: BOOL;
  var
    bPrepared: BOOL): BOOL;

  const
    lFileSize: longint = 0;
    nFiles: integer = 0;
    n: integer = 0;
    p: pointer = nil;
    szLessonToCall: array[0..255] of char = '';

  var
    tQ: TypeQuestion;
    {$IFDEF _TUTOR}
    header: TQcmFileHeader;
    S: TBufStream;
    {$ENDIF}
    nMin, nMax: integer;
    szFrom: szLongName;
    f2: Text;
    szTest: array[0..255] of char;
    fSize: longint;
    OldChar: char;

    function PrepareFile(pszFile: PChar; fSize: longint): BOOL;
    var
      DirInfo: TSearchRec;
      dwRet: DWORD;
    begin
      PrepareFile := False;
      if pszFile[0] <> #0 then
      begin
        DosError := FindFirst(pszFile, faArchive, DirInfo);
        if (DosError <> 0) and
          (wDrvTyp1 <> DRIVE_REMOVABLE) then
        begin
          OldChar := pszFile[StrLen(pszFile) - 1];
          pszFile[StrLen(pszFile) - 1] := '_';
          FindClose(DirInfo);
          DosError := FindFirst(pszFile, faArchive, DirInfo);
          if (DosError <> 0) then
          begin
            pszFile[StrLen(pszFile) - 1] := OldChar;
          end;
        end;
        if (DosError = 0) or
          (wDrvTyp1 = DRIVE_REMOVABLE) then
        begin
          if SendDlgItemMessage(hDlg,
            104, LB_FINDSTRINGEXACT, 0, longint(pszFile)) = LB_ERR then
          begin
            dwRet :=
              SendDlgItemMessage(hDlg, 104, LB_ADDSTRING, 0, longint(pszFile));
            if DosError <> 0 then
              DirInfo.Size := fSize;
            if (dwRet <> LB_ERR) and
              (dwRet <> LB_ERRSPACE) then
            begin
              SendDlgItemMessage(hDlg,
                104, LB_SETITEMDATA, word(dwRet), longint(DirInfo.Size));
              SendDlgItemMessage(hDlg,
                104, LB_SETCURSEL, word(dwRet), 0);
              lSize := lSize + DirInfo.Size;
              nFiles :=
                SendDlgItemMessage(hDlg, 104, LB_GETCOUNT, 0, 0);
              lFileSize := lSize;
              wvsprintf(szText,
                szFormat, @lFileSize);
              SetDlgItemText(hDlg,
                105, szText);
              UpdateWindow(
                GetDlgItem(hDlg, 104));
              UpdateWindow(
                GetDlgItem(hDlg, 105));
              if wDrvTyp2 =
                DRIVE_REMOVABLE then
              begin
                WriteLn(f, DirInfo.Name);
                WriteLn(f, DirInfo.Size);
              end;
              PrepareFile := True;
              if (DosError <> 0) and
                (wDrvTyp1 =
                DRIVE_REMOVABLE) then
              begin
                bMissFile := True;
              end
              else
              begin
                PrepareFile := False;
              end;
            end;
          end;
        end
        else
        begin
          if SendDlgItemMessage(hDlg,
            108, LB_FINDSTRINGEXACT, 0, longint(pszFile)) = LB_ERR then
          begin
            n := i;
            p := pszFile;
            wvsprintf(szText, '%d - %s', @n);
            dwRet :=
              SendDlgItemMessage(hDlg, 108, LB_ADDSTRING, 0, longint(@szText));
            nFiles :=
              SendDlgItemMessage(hDlg, 108, LB_GETCOUNT, 0, 0);
            wvsprintf(szText, szMisFormat, @nFiles);
            SetDlgItemText(hDlg, 109, szText);
            UpdateWindow(GetDlgItem(hDlg, 108));
            UpdateWindow(GetDlgItem(hDlg, 109));
          end;
        end;
        FindClose(DirInfo);
      end;
    end;

                {Procedure DispCall(p : PReponseWin);Far;
                Begin
                        if p^.szLessonToCall[0] <> #0 then WriteLn(PathLavac1, ' -> ', p^.szLessonToCall);
                        BringWindowToTop(FindWindow(nil, WinCrt.WindowTitle));
                End;}
  {$IFDEF _TUTOR}
    procedure TestLink(p: PMoveWindow); far;
    begin
      if (p^.szLinkedFile[0] <> #0) and
        ((p^.wTypeRep = CT_BITMAP) or
        (p^.wTypeRep = CT_SON)) then
      begin
        UpdatePath(p^.szLinkedFile, PathLavac1);
        PrepareFile(p^.szLinkedFile, 0);
      end;
    end;
  {$ENDIF}
  begin

    PrepareFiles := False;
    bPrepared := False;

    FileMode := OF_SHARE_DENY_NONE or OF_READ;
    if (wDrvTyp1 = DRIVE_REMOVABLE) then
    begin
      StrCopy(szFrom, tLecon1.PathLecon);
      StrCat(szFrom, '\Backup.inf');
      if FileExist(szFrom) then
      begin
        Assign(f2, PChar(szFrom));
        reset(f2);
        ReadLn(f2, szTest);
        ReadLn(f2, szTest);
        i := 1;
        while not EOF(f2) do
        begin
                                {$I-}
          ReadLn(f2, szTest);
          ReadLn(f2, fSize);
                                {$I+}
          if IOResult = 0 then
          begin
            StrCopy(szFrom, tLecon1.PathLecon);
            StrCat(szFrom, '\');
            StrCat(szFrom, szTest);
            PrepareFile(szFrom, fSize);
          end;
          Inc(i);
        end;
        Close(f2);
        bPrepared := True;
        exit;
      end;
    end;
    FileMode := OF_SHARE_DENY_NONE or OF_READWRITE;

    GetDlgItemText(hDlg, 105, szFormat, SIZEOF(szFormat));
    nFiles := 0;
    if GetDlgItemText(hDlg, 109, szMisFormat, SIZEOF(szMisFormat)) = 0 then
      StrCopy(szMisFormat, '%d');
    wvsprintf(szText, szMisFormat, @nFiles);
    SetDlgItemText(hDlg, 109, szText);

    i := 1;
    while GetQuestionRec(i, tQ) do
    begin

      FileMode := OF_SHARE_DENY_NONE or OF_READ;

      PrepareFile(tQ.FichierQuestion, 0);

      PrepareFile(tQ.FichierGraph, 0);

      if IsVideoFile(tQ.FichierGraph) and
        bVideoWave then
      begin
        tQ.FichierGraph[StrLen(tQ.FichierGraph) - 3] := 'W';
        tQ.FichierGraph[StrLen(tQ.FichierGraph) - 2] := 'A';
        tQ.FichierGraph[StrLen(tQ.FichierGraph) - 1] := 'V';
        PrepareFile(tQ.FichierGraph, 0);
      end;

      PrepareFile(tQ.FichierTexte, 0);

      PrepareFile(tQ.FichierQCM, 0);
 {$IFDEF _TUTOR}
      with MainQcmWin^ do
      begin
        S.Init(tQ.FichierQCM, STOPENREAD, BUFFER_SIZE);
        if S.Status = 0 then
        begin
          S.Read(Header, SizeOf(TQcmFileHeader));
          S.Read(bShowBar, SizeOf(bShowBar));
          S.Read(bSmartResult, SizeOf(bSmartResult));
          S.Read(bKeepAnswer, SizeOf(bKeepAnswer));
          S.Read(nMin, SizeOf(nMin));
          S.Read(nMax, SizeOf(nMax));
          S.Read(bRepeatQ, SizeOf(bRepeatQ));
          S.Read(bAllForTrue, SizeOf(bAllForTrue));
          S.Read(nTemps, SizeOf(nTemps));
          GetChildren(S);
          if S.Status = 0 then
          begin
            ForEach(@TestLink);
            {ForEach(@DispCall);}
          end;
        end;
        S.Done;
        ClearDocument;
      end;
 {$ENDIF}
      if tQ.FichierMCI[0] <> #0 then
      begin
        StrCopy(szFrom, tLecon1.PathLecon);
        StrCat(szFrom, '\');
        StrCat(szFrom, tQ.FichierMCI);
        StrCat(szFrom, '.CMD');
        PrepareFile(szFrom, 0);
      end;

      FileMode := OF_SHARE_DENY_NONE or OF_READWRITE;

      Inc(i);
    end;

                {StrCopy(szFrom, tLecon1.PathLecon);
                StrCat(szFrom, '\');
                StrCat(szFrom, 'QCM*.*');
                szFrom[0] := PathLavac1[0];
                FileMode := OF_SHARE_DENY_NONE OR OF_READ;
                FindFirst(szFrom, faArchive, DirInfo);
                while DosError = 0 do begin
                        inc(i);
                        StrCopy(szFrom, tLecon1.PathLecon);
                        StrCat(szFrom, '\');
                        StrCat(szFrom, DirInfo.name);
                        PrepareFile(szFrom, 0);
                        FindNext(DirInfo);
                end;}

    FileMode := OF_SHARE_DENY_NONE or OF_READWRITE;
    PrepareFiles := True;
  end;


  function CleanProc(hDlg: HWnd; Message, wParam: Dword; LParam: longint): Bool;
  stdcall;

  var
    bPrepared: Bool;
    bMissFile: Bool;
    wDrvTyp: word;
    f: Text;
    szLnkFormat: array[0..255] of char;
    szFormat: array[0..255] of char;
    szFrom: array[0..255] of char;
    dwRet: DWORD;
    DirInfo: TSearchRec;

  const
    lSize: longint = 0;
    nFiles: integer = 0;
    lLnkSize: longint = 0;
    nLnkFiles: integer = 0;
    nFndFiles: integer = 0;

  begin
    CleanProc := True;
    case Message of
      WM_INITDIALOG:
      begin
        CenterDialog(hDlg);

        SetWindowText(hDlg, tLecon1.Nom);

        GetDlgItemText(hDlg, 105, szLnkFormat,
          SIZEOF(szLnkFormat));
        GetDlgItemText(hDlg, 107, szFormat, SIZEOF(szFormat));
        lSize := 0;
        nFiles := 0;
        wvsprintf(szText, szFormat, @lSize);
        SetDlgItemText(hDlg, 107, szText);

        ShowWindow(hDlg, SW_SHOW);
        UpdateWindow(hDlg);

        tLecon.PathLecon := tLecon1.PathLecon;
        lLnkSize := 0;
        bMissFile := False;
        bPrepared := False;
        wDrvTyp :=
          GetDriveType(Ord(UpCase(tLecon1.PathLecon[0])) - Ord('A'));
        PrepareFiles(hDlg, wDrvTyp, word(-1),
          tLecon1.
          PathLecon,
          lLnkSize,
          f,
          bMissFile,
          bPrepared);
        nLnkFiles :=
          SendDlgItemMessage(hDlg, 104, LB_GETCOUNT, 0, 0);
        nFndFiles := 0;
        StrCat(szLnkFormat, ' (%d Ok)');

        lSize := 0;
        StrCopy(szFrom, tLecon1.PathLecon);
        StrCat(szFrom, '\');
        StrCat(szFrom, '*.*');
        szFrom[0] := PathLavac[0];
        FileMode := OF_SHARE_DENY_NONE or OF_READ;
        DosError := FindFirst(szFrom, faArchive, DirInfo);
        while DosError = 0 do
        begin
          StrCopy(szFrom, tLecon1.PathLecon);
          StrCat(szFrom, '\');
          StrCat(szFrom, PChar(DirInfo.Name));
          dwRet :=
            SendDlgItemMessage(hDlg, 104, LB_FINDSTRINGEXACT, 0, longint(@szFrom));
          if (dwRet = LB_ERR) and
            (StrIComp(PChar(DirInfo.Name),
            'QUESTION.LST') <> 0) then
          begin
            dwRet :=
              SendDlgItemMessage(hDlg, 106, LB_ADDSTRING, 0, longint(@szFrom));
            if (dwRet <> LB_ERR) and
              (dwRet <> LB_ERRSPACE) then
            begin
              SendDlgItemMessage(hDlg,
                106, LB_SETITEMDATA, word(dwRet), longint(DirInfo.Size));
              SendDlgItemMessage(hDlg,
                106, LB_SETCURSEL, word(dwRet), 0);
              lSize := lSize + DirInfo.Size;
              nFiles :=
                SendDlgItemMessage(hDlg, 106, LB_GETCOUNT, 0, 0);
              wvsprintf(szText,
                szFormat, @lSize);
              SetDlgItemText(hDlg,
                107, szText);
              UpdateWindow(
                GetDlgItem(hDlg, 106));
              UpdateWindow(
                GetDlgItem(hDlg, 107));
            end;
          end
          else
          begin
            SendDlgItemMessage(hDlg,
              104, LB_SETCURSEL, word(dwRet), 0);
            SendDlgItemMessage(hDlg,
              104, LB_DELETESTRING, word(dwRet), 0);
            wvsprintf(szText, szLnkFormat, @lLnkSize);
            SetDlgItemText(hDlg, 105, szText);
            Inc(nFndFiles);
          end;
          DosError := FindNext(DirInfo);
        end;
        FindClose(DirInfo);
      end;

      WM_COMMAND:
        case LOWORD(wParam) of
          6031:
          begin
            dwRet :=
              SendDlgItemMessage(hDlg, 106, LB_GETTEXT, 0, longint(@szFrom));
            while dwRet <> LB_ERR do
            begin
              SendDlgItemMessage(hDlg,
                106, LB_SETCURSEL, 0, 0);
              lSize :=
                lSize - SendDlgItemMessage(hDlg, 104, LB_GETITEMDATA, 0, 0);
              SendDlgItemMessage(hDlg,
                106, LB_DELETESTRING, 0, 0);
              nFiles :=
                SendDlgItemMessage(hDlg, 106, LB_GETCOUNT, 0, 0);
              wvsprintf(szText, szFormat, @lSize);
              SetDlgItemText(hDlg, 107, szText);
              UpdateWindow(GetDlgItem(hDlg, 106));
              UpdateWindow(GetDlgItem(hDlg, 107));
              {$I-}
              Assign(f, szFrom);
              erase(f);
              {$I+}
              if IORESULT <> 0 then;
              dwRet :=
                SendDlgItemMessage(hDlg, 106, LB_GETTEXT, 0, longint(@szFrom));
            end;
            EndDialog(hDlg, wParam);
          end;

          idCancel: EndDialog(hDlg, wParam);

        end;
    end;
    CleanProc := False;
  end;

  {***************************************************************************}

  function PrepareCopy(var tLecon1, tLecon2: typeLecon): Bool;

    {***************************************************************************}
  var
    DirInfo: TSearchRec;
    nDriveSize: longint;
    lSize: longint;
    lFree: longint;
    nSize, nFree: longint;
    szFrom: szLongName;
    TOF2: TOFSTRUCT;
    fDriveTst: integer;
    bPrepared: Bool;
    bMissFile: Bool;
    szTest: array[0..255] of char;
    wDrvTyp1, wDrvTyp2: word;
    f: Text;

  const
    lDriveSize: longint = 0;

  begin

    PrepareCopy := False;

    {--Source--}
    {#### Pas bon pour CDROM .... }
        {StrCopy(szFrom,tLecon1.PathLecon);
        StrCat(szFrom, '\drive.tst');
        fDriveTst := OpenFile(szFrom, TOF1, OF_CREATE);
        if fDriveTst = -1 then begin
                szFrom[0] := PathLavac1[0];
                fDriveTst := OpenFile(szFrom, TOF1, OF_CREATE);
                if fDriveTst = -1 then begin
                        MessageBox(Window, mmLoadString(hInstRes, ERR_SRCDISK), mmLoadString(hInstRes, ERR_ERR),
                                                                                         MB_OK OR MB_ICONSTOP OR MB_APPLMODAL);
                        Exit;
                end;
        end else begin
                        _lClose(fDriveTst);
                        OpenFile(szFrom, TOF1, OF_DELETE);
        end;}

    {####}
    tLecon1.PathLecon[0] := PathLavac1[0];
    StrCopy(szTest, tLecon1.PathLecon);
    StrCat(szTest, '\QUESTION.LST');
    FileMode := OF_SHARE_DENY_NONE or OF_READ;
    if not FileExist(szTest) then
    begin
      MessageBox(Window, mmLoadString(hInstRes, ERR_SRCDISK),
        mmLoadString(hInstRes, ERR_ERR),
        MB_OK
        or MB_ICONSTOP or MB_APPLMODAL);
      Exit;
    end;
    wDrvTyp1 := GetDriveType(Ord(UpCase(szTest[0])) - Ord('A'));
    FileMode := OF_SHARE_DENY_NONE or OF_READWRITE;

    {--Cible--}
    CreerRep(tLecon2.PathLecon);
    StrCopy(szFrom, tLecon2.PathLecon);
    StrCat(szFrom, '\Backup.inf');
    fDriveTst := OpenFile(szFrom, TOF2, OF_CREATE);
    if fDriveTst = -1 then
    begin
      MessageBox(Window, mmLoadString(hInstRes, ERR_DSTDISK),
        mmLoadString(hInstRes, ERR_ERR),
        MB_OK or
        MB_ICONSTOP or MB_APPLMODAL);
      Exit;
    end
    else
    begin
      _lClose(fDriveTst);
      OpenFile(szFrom, TOF2, OF_DELETE);
    end;
    wDrvTyp2 := GetDriveType(Ord(Upcase(szFrom[0])) - Ord('A'));
    if wDrvTyp2 = DRIVE_REMOVABLE then
    begin
      Assign(f, PChar(szFrom));
      rewrite(f);
      WriteLn(f, tLecon1.Nom);
      WriteLn(f, tLecon1.Createur);
    end;


    tLecon.PathLecon := tLecon1.PathLecon;
    i := 1;
    lSize := 0;
    lFree := 0;
    bMissFile := False;
    bPrepared := False;
    PrepareFiles(hThermo, wDrvTyp1, wDrvTyp2,
      tLecon1.PathLecon,
      lSize, f, bMissFile, bPrepared);

    if wDrvTyp2 = DRIVE_REMOVABLE then
    begin
      Close(f);
    end;

    StrCopy(szFrom, tLecon1.PathLecon);
    StrCat(szFrom, '\Question.lst');
    FileMode := OF_SHARE_DENY_NONE or OF_READ;
    DosError := FindFirst(szFrom, faArchive, DirInfo);
    if DosError = 0 then
      lSize := lSize + DirInfo.Size;
    FindClose(DirInfo);

    FileMode := OF_SHARE_DENY_NONE or OF_READWRITE;

    TotalSize := lSize;

    if bMissFile and not bPrepared then
      lSize := 0;

    nSize := lSize div 1024;

    lFree := DiskFree(Ord(UpCase(tLecon2.PathLecon[0])) - Ord('@'));
    if lFree < -1 then
      lFree := 2147483647;
    nFree := lFree div 1024;

    lDriveSize := DiskSize(Ord(UpCase(tLecon2.PathLecon[0])) - Ord('@'));
    if lDriveSize < -1 then
      lDriveSize := 2147483647;
    nDriveSize := lDriveSize div 1024;
    nbDisk := 0;
    if (lDriveSize > 0) and (lSize <> 0) then
    begin
      if (lSize > lFree) then
      begin
        nbDisk := ((lSize - lFree) div lDriveSize) + 1;
        if (lSize - lFree) mod lDriveSize <> 0 then
          Inc(nbDisk);
      end
      else
      begin
        nbDisk := 1;
      end;
    end;

    StrCopy(szFrom, tLecon1.PathLecon);
    szFrom[2] := #0;
    case wDrvTyp1 of
      DRIVE_REMOVABLE: StrCat(szFrom,
          mmLoadString(hInstRes, STR_REMOVABLE));
      DRIVE_FIXED: StrCat(szFrom,
          mmLoadString(hInstRes, STR_FIXED));
      DRIVE_REMOTE: StrCat(szFrom, '(Réseaux)');
      {mmLoadString(hInstRes, STR_REMOTE));}
      DRIVE_CDROM: StrCat(szFrom, '(CD-ROM)');
      {mmLoadString(hInstRes, STR_CDROM));}
    end;
    SetDlgItemText(hThermo, 1001, szFrom);

    if lSize <> 0 then
    begin
      wvsprintf(szMessage, mmLoadString(hInstRes, STR_KOTOTAL), @nSize);
      SetDlgItemText(hThermo, 1002, szMessage);
    end
    else
    begin
      SetDlgItemText(hThermo, 1002, mmLoadString(hInstRes, STR_NOTKOTOTAL));
    end;

    StrCopy(szFrom, tLecon2.PathLecon);
    szFrom[2] := #0;
    case wDrvTyp2 of
      DRIVE_REMOVABLE: StrCat(szFrom,
          mmLoadString(hInstRes, STR_REMOVABLE));
      DRIVE_FIXED: StrCat(szFrom,
          mmLoadString(hInstRes, STR_FIXED));
      DRIVE_REMOTE: StrCat(szFrom, '(Réseaux)');
      {mmLoadString(hInstRes, STR_REMOTE));}
      DRIVE_CDROM: StrCat(szFrom, '(CD-ROM)');
      {mmLoadString(hInstRes, STR_CDROM));}
    end;
    SetDlgItemText(hThermo, 2001, szFrom);

    if (wDrvTyp2 = DRIVE_REMOVABLE) and (lSize > lFree) then
    begin
      if (lSize <> 0) then
      begin
        wvsprintf(szFrom, '%d x ', @nbDisk);
        wvsprintf(szMessage, mmLoadString(hInstRes, STR_KO), @nDriveSize);
        StrCat(szFrom, szMessage);
        SetDlgItemText(hThermo, 2002, szFrom);
      end
      else
      begin
        wvsprintf(szFrom, mmLoadString(hInstRes, STR_NOTKO), @nDriveSize);
        SetDlgItemText(hThermo, 2002, szFrom);
      end;
    end
    else
    begin
      wvsprintf(szFrom, mmLoadString(hInstRes, STR_KOFREE), @nFree);
      SetDlgItemText(hThermo, 2002, szFrom);
    end;

    if (wDrvTyp1 <> DRIVE_REMOVABLE) and (wDrvTyp2 <>
      DRIVE_REMOVABLE) and (lFree < lSize) then
    begin
      MessageBox(Window, mmLoadString(hInstRes, ERR_SPCDISK),
        mmLoadString(hInstRes, ERR_ERR),
        MB_OK or
        MB_ICONSTOP or MB_APPLMODAL);
      Exit;
    end;

    PrepareCopy := True;
  end;

  {***************************************************************************}

  function CreateDestLesson(var tLecon1, tLecon2: typeLecon): Bool;

    {***************************************************************************}
  var
    PathFichierQuestion, szTemp: szLongName;
    MSG: TMSG;
    DirInfo: TSearchRec;
    LastDirInfo: TSearchRec;
    hWaitCursor, hArrowCursor: HCURSOR;
    lSize, lFree: longint;
  begin

    CreateDestLesson := False;

    {--pointeurs souris--}
    hWaitCursor := LoadCursor(0, IDC_WAIT);
    hArrowCursor := LoadCursor(0, IDC_ARROW);

    lFree := DiskFree(Ord(UpCase(tLecon2.PathLecon[0])) - Ord('@'));
    if lFree < -1 then
      lFree := 2147483647;
    StrCopy(PathFichierQuestion, tLecon1.PathLecon);
    StrCat(PathFichierQuestion, '\Question.lst');
    {####}
    PathFichierQuestion[0] := PathLavac1[0];
    DosError := FindFirst(PathFichierQuestion, faArchive, DirInfo);
    if DosError <> 0 then
    begin
      MessageBox(Window, mmLoadString(hInstRes, ERR_SRCLESSON),
        mmLoadString(hInstRes, ERR_ERR),
        MB_OK or
        MB_ICONSTOP or MB_APPLMODAL);
      Exit;
    end
    else
    begin
      lSize := DirInfo.Size + 1024; {--1 Ko en plus par sécurité--}
      if lFree < lSize then
      begin
        MessageBox(Window, mmLoadString(hInstRes, ERR_SPCDISK),
          mmLoadString(hInstRes, ERR_ERR),
          MB_OK or
          MB_ICONSTOP or MB_APPLMODAL);
        Exit;
      end;
    end;
    FindClose(DirInfo);

    {--créer le rep dest, s'y placer--}
    CreerRep(tLecon2.PathLecon);
    SetCurrentDirectory(tLecon2.PathLecon);

    {--créer le fichier Questions en local--}
        {$I-}
    Assign(fQuestion, 'Question.lst');
    rewrite(fQuestion);
    Close(fQuestion);
    GetfAttr(fQuestion, wReturn);
    SetfAttr(fQuestion, wReturn or faShare); {SHARE Flag}
        {$I+}
    if IOResult <> 0 then
    begin
      {####}
      MessageBox(Window, 'Unable to create local Question.lst',
        mmLoadString(hInstRes, ERR_ERR),
        MB_OK or
        MB_ICONSTOP or MB_APPLMODAL);
    end;

    tLecon.PathLecon := tLecon1.PathLecon;
    i := 1;
    while GetQuestionRec(i, tQuestion1) and (hThermo <> 0) do
    begin
      while PeekMessage(MSG, 0, 0, 0, PM_REMOVE) and (hThermo <> 0) do
      begin
        TranslateMessage(MSG);
        DispatchMessage(MSG);
        if GetCursor <> hWaitCursor then
          SetCursor(hWaitCursor);
      end;
      if GetCursor <> hWaitCursor then
        SetCursor(hWaitCursor);
      wvsprintf(szThermo, mmLoadString(hInstRes, STR_CREATELESSON), @i);
      SetDlgItemText(hThermo, 10000, szThermo);
      tLecon.PathLecon := tLecon2.PathLecon;
      tQuestion2 := tQuestion1;
      FileSplit(tQuestion1.FichierQuestion, Dir, Name, Ext);
      if Name[0] <> #0 then
      begin
        StrECopy(StrECopy(StrECopy(
          StrECopy(tQuestion2.FichierQuestion, tLecon2.PathLecon),
          '\'), Name), Ext);
      end;
      FileSplit(tQuestion1.FichierGraph, Dir, Name, Ext);
      if Name[0] <> #0 then
      begin
        StrECopy(StrECopy(StrECopy(
          StrECopy(tQuestion2.FichierGraph, tLecon2.PathLecon),
          '\'), Name), Ext);
      end;
      FileSplit(tQuestion1.FichierTexte, Dir, Name, Ext);
      if Name[0] <> #0 then
      begin
        StrECopy(StrECopy(StrECopy(
          StrECopy(tQuestion2.FichierTexte, tLecon2.PathLecon),
          '\'), Name), Ext);
      end;
      FileSplit(tQuestion1.FichierQCM, Dir, Name, Ext);
      if Name[0] <> #0 then
      begin
        StrECopy(StrECopy(StrECopy(StrECopy(tQuestion2.FichierQCM, tLecon2.PathLecon),
          '\'), Name), Ext);
      end;
      SetQuestionRec(i, tQuestion2);
      Inc(i);
      tLecon.PathLecon := tLecon1.PathLecon;
    end;

    {--copier le fichier Questions sur dest--}
    while PeekMessage(MSG, 0, 0, 0, PM_REMOVE) and (hThermo <> 0) do
    begin
      TranslateMessage(MSG);
      DispatchMessage(MSG);
      if GetCursor <> hWaitCursor then
        SetCursor(hWaitCursor);
    end;
    if hThermo <> 0 then
    begin
      if GetCursor <> hWaitCursor then
        SetCursor(hWaitCursor);
      StrCopy(PathFichierQuestion, tLecon2.PathLecon);
      StrCat(PathFichierQuestion, '\Question.lst');
      wvsprintf(szThermo, mmLoadString(hInstRes, STR_COPYLESSON), @i);
      SetDlgItemText(hThermo, 10000, szThermo);
      if GetDriveType(Ord(UpCase(PathFichierQuestion[0])) - Ord('A')) =
        DRIVE_REMOVABLE then
      begin
        CopyFile(PathFichierQuestion, 'C:\Question.tmp');
      end;
    end;

    CreateDestLesson := True;

  end;

  {***************************************************************************}

  function SetThermoPourcent(nPourcent: integer): Bool;

    {***************************************************************************}
  var
    hMyDC: HDC;
    hBar: HWND;
    Rect: Windows.TRECT;
    w: integer;
    szPourcent: szPName;
  begin
    if hThermo = 0 then
      exit;
    hBar := GetDlgItem(hThermo, 3001);

    hMyDC := 0; //GetDC(hBar);  crash !!!
    GetClientRect(hBar, Rect);
    wvsprintf(szPourcent, '%d', @nPourcent);
    StrCat(szPourcent, '%');
    SetWindowText(hBar, szPourcent);
    w := MulDiv(Rect.Right, nPourcent, 100) - 2;
    if w < 1 then
      w := 1;
    if w > Rect.Right then
      w := Rect.Right;
    if (hMyDC <> 0) then begin
      PatBlt(hMyDC, 1, 1, w, Rect.Bottom - 2, PATINVERT);
      ReleaseDC(hBar, hMyDC);
    end;
  end;

  {***************************************************************************}

  function StdCopyFile(Source, Dest: PChar; bFast: Bool): Bool;

    {***************************************************************************}

  var
    bRet, bComp: Bool;
    lSize, lFree: longint;
    DirInfo: TSearchRec;
    c: char;

  begin
    //MessageBox(GetDesktopwindow, Source, Dest, MB_OK);
    bRet := False;
    bComp := False;
    lFree := DiskFree(Ord(UpCase(Dest[0])) - Ord('@'));
    if lFree < -1 then
      lFree := 2147483647;
    DosError := FindFirst(Source, faArchive, DirInfo);
    if DosError <> 0 then
    begin
      c := Source[strLen(Source) - 1];
      Source[strLen(Source) - 1] := '_';
      FindClose(DirInfo);
      DosError := FindFirst(Source, faArchive, DirInfo);
      bComp := DosError = 0;
      if not bComp then
        Source[strLen(Source) - 1] := c;
    end;
    FindClose(DirInfo);
    //MessageBox(GetDesktopwindow, Source, Dest, MB_OK);
    if DosError <> 0 then
      CopyError := $0002
    else
    begin
      lSize := DirInfo.Size;
      if lFree < lSize then
      begin
        CopyError := LZERROR_WRITE;
      end
      else
      begin
        if bFast then
        begin
          if bComp then
            Dest[strLen(Dest) - 1] := '_';
          bRet := FastCopyFile(Source, Dest);
        end
        else
        begin
          bRet := CopyFile(Source, Dest);
        end;
      end;
    end;
    StdCopyFile := bRet;
    //MessageBox(GetDesktopwindow, Source, 'DONE !', MB_OK);
  end;

  {***************************************************************************}
  function CopyFileEx(Fichier1: PChar;
  var
    tLecon2: TypeLecon;
    bComp,
    bFast: Bool): Bool;
    {***************************************************************************}

  var
    Fichier2: szLongName;
    PathFichierQuestion: szLongName;
    MSG: TMSG;
    hWaitCursor, hArrowCursor: HCURSOR;
    ExitCopy: Bool;
    szMessage: szPName;
    nRetMesBox: integer;

  begin
    {--pointeurs souris--}
    hWaitCursor := LoadCursor(0, IDC_WAIT);
    hArrowCursor := LoadCursor(0, IDC_ARROW);

    ExitCopy := False;

    while PeekMessage(MSG, 0, 0, 0, PM_REMOVE) do
    begin
      TranslateMessage(MSG);
      DispatchMessage(MSG);
      if GetCursor <> hWaitCursor then
        SetCursor(hWaitCursor);
      if hThermo = 0 then
      begin
        ExitCopy := True;
        CopyFileEx := ExitCopy;
        Exit;
      end;
    end;
    if GetCursor <> hWaitCursor then
      SetCursor(hWaitCursor);

    {####}
    Fichier1[0] := PathLavac1[0];

    if bComp then
    begin
      Fichier1[StrLen(Fichier1) - 1] := '_';
    end;

    {--reconstruit le chemin et le nom du fichier cible--}
    FileSplit(Fichier1, Dir, Name, Ext);

    //MessageBox(GetDesktopwindow, Fichier1, Dir, MB_OK);
    //MessageBox(GetDesktopwindow, Name, Ext, MB_OK);

    if (Name[0] <> #0) and not ExitCopy then
    begin
      StrCopy(szThermo, mmLoadString(hInstRes, STR_COPYFILE));
      StrCat(szThermo, Name);
      StrCat(szThermo, Ext);
      SetDlgItemText(hThermo, 10000, szThermo);
      StrECopy(StrECopy(StrECopy(
        StrECopy(Fichier2, tLecon2.PathLecon),
        '\'), Name), Ext);

      {####WriteLn(Fichier1, '->', Fichier2);}

      {--tant que fichier pas copier et copie pas annulée--}
      while (hThermo <> 0) and not
        StdCopyFile(Fichier1,
          Fichier2, bFast) and not ExitCopy do
      begin

        case CopyError of
          $0002:
          begin
            StrCopy(szMessage,
              mmLoadString(hInstRes, STR_INSNEXTDISK));
          end;
          LZERROR_WRITE,
          LZERROR_BADOUTHANDLE:
          begin
            StrCopy(szMessage,
              mmLoadString(hInstRes, STR_INSERTDISK));
          end;
          else
            CopyErrorMessage(szMessage);
        end;
        SetCursor(hArrowCursor);
        StrCat(szMessage, mmLoadString(hInstRes, STR_CURFILE));
        StrCat(szMessage, Name);
        StrCat(szMessage, Ext);

        nRetMesBox :=
          MessageBox(Window, szMessage, '', MB_ABORTRETRYIGNORE or
          MB_ICONEXCLAMATION or MB_APPLMODAL or MB_DEFBUTTON2);
        BringWindowToTop(hThermo);
        SetCursor(hWaitCursor);
        ExitCopy :=
          (nRetMesBox = idCancel) or
          (nRetMesBox
          = idAbort) or
          (nRetMesBox = idNo);
        if (nRetMesBox = idIgnore) then
        begin
          CopyFileEx := ExitCopy;
          Exit;
        end;
        while PeekMessage(MSG, 0, 0, 0, PM_REMOVE) do
        begin
          TranslateMessage(MSG);
          DispatchMessage(MSG);
          if GetCursor <> hWaitCursor then
            SetCursor(hWaitCursor);
          if hThermo = 0 then
          begin
            ExitCopy := True;
            CopyFileEx := ExitCopy;
            Exit;
          end;
        end;
        StrCopy(PathFichierQuestion, tLecon2.PathLecon);
        StrCat(PathFichierQuestion, '\question.lst');
        if (not ExitCopy) and
          (GetDriveType(
          Ord(UpCase(PathFichierQuestion[0])) - Ord('A')) = DRIVE_REMOVABLE) then
        begin
          CopyFile(
            'C:\question.tmp', PathFichierQuestion);
        end;
      end;
    end;
    CopyFileEx := ExitCopy;
    //MessageBox(GetDesktopwindow, Fichier1, 'CopyFileEx DONE !!!', MB_OK);
  end;

  {***************************************************************************}

  function CopyAllFileEx(var tQuestion1, tQuestion2: TypeQuestion;
  var
    tLecon1, tLecon2: TypeLecon;
    bComp,
    bFast: Bool): Bool;
    {***************************************************************************}

  var
    MSG: TMSG;
    hWaitCursor, hArrowCursor: HCURSOR;
    ExitCopy: Bool;
    nPourcent: integer;
    szFrom: array[0..255] of char;

  const
    lSize: longint = 0;
    nFiles: integer = 0;
    DoneSize: longint = 0;

  begin

    {--pointeurs souris--}
    hWaitCursor := LoadCursor(0, IDC_WAIT);
    hArrowCursor := LoadCursor(0, IDC_ARROW);

    {--copier les fichiers sources vers dest--}
    while PeekMessage(MSG, 0, 0, 0, PM_REMOVE) and (hThermo <> 0) do
    begin
      TranslateMessage(MSG);
      DispatchMessage(MSG);
      if GetCursor <> hWaitCursor then
        SetCursor(hWaitCursor);
    end;

    if hThermo <> 0 then
    begin
      ExitCopy := False;
      DoneSize := 0;
      while not ExitCopy do
      begin
        ExitCopy :=
          SendDlgItemMessage(hThermo, 104, LB_GETCOUNT, 0, 0) = 0;
        if not ExitCopy then
        begin
          SendDlgItemMessage(hThermo, 104,
            LB_GETTEXT, 0, longint(@szFrom));
          {MessageBox(GetActiveWindow, szFrom, 'Copy', 0);}
          ExitCopy :=
            CopyFileEx(szFrom,
            tLecon2,
            bComp,
            bFast);
          //MessageBox(GetActiveWindow, szFrom, 'Copy', 0);
          lSize :=
            SendDlgItemMessage(hThermo, 104, LB_GETITEMDATA, 0, 0);
          Inc(DoneSize, lSize);
          if DoneSize < 21474836 then
          begin
            nPourcent :=
              integer(longint(DoneSize * 100) div TotalSize);
          end
          else
          begin
            nPourcent :=
              integer(longint(DoneSize) div (TotalSize div 100));
          end;
                                {if nPourcent > 100 then nPourcent := 100;
                                if nPourcent < 0 then nPourcent := 0;}
          SetThermoPourcent(nPourcent);
          //MessageBox(GetActiveWindow, szFrom, 'Copy2', 0);
          SendDlgItemMessage(hThermo, 104, LB_DELETESTRING, 0, 0);
          SendDlgItemMessage(hThermo, 104, LB_SETCURSEL, 0, 0);
          lSize := TotalSize - DoneSize;
          nFiles :=
            SendDlgItemMessage(hThermo, 104, LB_GETCOUNT, 0, 0);
          wvsprintf(szText, szFormat, @lSize);
          SetDlgItemText(hThermo, 105, szText);
          UpdateWindow(GetDlgItem(hThermo, 104));
          UpdateWindow(GetDlgItem(hThermo, 105));

        end;
      end;
    end;
  end;

  {***************************************************************************}

  function CompressFile(var tLecon1: TypeLecon): Bool;

    {***************************************************************************}

  var
    MSG: TMSG;
    DirInfo: TSearchRec;
    LastDirInfo: TSearchRec;
    NumTasks: word;
    hWaitCursor, hArrowCursor: HCURSOR;
    Dir, CommandLine: szLongName;
    bFirstFound: Bool;
    noFile, nPourcent: integer;
    nbCompFile: integer;

  begin

    {--pointeurs souris--}
    hWaitCursor := LoadCursor(0, IDC_WAIT);
    hArrowCursor := LoadCursor(0, IDC_ARROW);

    if GetCursor <> hWaitCursor then
      SetCursor(hWaitCursor);
    if hThermo <> 0 then
    begin
      StrCopy(Dir, tLecon1.PathLecon);
      StrCopy(CommandLine, Dir);
      StrCat(CommandLine, '\*.WAV');

      DosError := FindFirst(CommandLine, faArchive, DirInfo);
      if DosError = 0 then
      begin
        StrCopy(CommandLine, Dir);
        StrCat(CommandLine, '\');
        StrCat(CommandLine, PChar(DirInfo.Name));

        StrCopy(szThermo,
          {mmLoadString(hInstRes, STR_COMPRESSLESSON)}'Compression des fichiers sons, patientez ...');
        SetDlgItemText(hThermo, 10000, szThermo);

        {--identifier la tâche de lavac_ut--}
        NumTasks := 1; // FIX LAVAC32 GetNumTasks;
        ShellExecute(window, nil, 'WAVCOMP.EXE',
          CommandLine, Dir, SW_HIDE);
        {--tant que tâche compression pas finie ou pas d'annulation utilisateur--}
        repeat
          if PeekMessage(MSG, 0, 0, 0, PM_REMOVE) and
            (hThermo <> 0) then
          begin
            TranslateMessage(MSG);
            DispatchMessage(MSG);
          end;
        until (NumTasks = 1) or (hThermo = 0);
        // was GetNumTasks missing in Kernel32 FIX LAVAC32
      end;
      FindClose(DirInfo);

      StrCopy(Dir, tLecon1.PathLecon);
      StrCopy(CommandLine, Dir);
      StrCat(CommandLine, '\*.BMP');

      DosError := FindFirst(CommandLine, faArchive, DirInfo);
      if DosError = 0 then
      begin
        StrCopy(CommandLine, Dir);
        StrCat(CommandLine, '\');
        StrCat(CommandLine, PChar(DirInfo.Name));
        StrCat(CommandLine, ' /C');

        StrCopy(szThermo,
          {mmLoadString(hInstRes, STR_COMPRESSLESSON)}'Compression des fichiers images, patientez ...');
        SetDlgItemText(hThermo, 10000, szThermo);

        {--identifier la tâche de lavac_ut--}
        NumTasks := 1; // FIX LAVAC32 GetNumTasks;
        ShellExecute(window, nil, 'BMPCOMP.EXE',
          CommandLine, Dir, SW_HIDE);
        {--tant que tâche compression pas finie ou pas d'annulation utilisateur--}
        repeat
          if PeekMessage(MSG, 0, 0, 0, PM_REMOVE) and
            (hThermo <> 0) then
          begin
            TranslateMessage(MSG);
            DispatchMessage(MSG);
          end;
        until (NumTasks = 1) or (hThermo = 0); //FIX LAVAC32
      end;
    end;
    FindClose(DirInfo);
    if GetCursor <> hWaitCursor then
      SetCursor(hWaitCursor);
  end;

  {***************************************************************************}

  function DeCompressFile(var tLecon1: TypeLecon): Bool;

    {***************************************************************************}

  var
    MSG: TMSG;
    DirInfo: TSearchRec;
    LastDirInfo: TSearchRec;
    NumTasks: word;
    hWaitCursor, hArrowCursor: HCURSOR;
    Dir, CommandLine: szLongName;
    bFirstFound: Bool;
    noFile, nPourcent: integer;
    nbCompFile: integer;

  begin

    {--pointeurs souris--}
    hWaitCursor := LoadCursor(0, IDC_WAIT);
    hArrowCursor := LoadCursor(0, IDC_ARROW);

    if GetCursor <> hWaitCursor then
      SetCursor(hWaitCursor);
    if hThermo <> 0 then
    begin
      StrCopy(Dir, tLecon1.PathLecon);
      StrCopy(CommandLine, Dir);
      StrCat(CommandLine, '\*.WAV');

      DosError := FindFirst(CommandLine, faArchive, DirInfo);
      if DosError = 0 then
      begin
        StrCopy(CommandLine, Dir);
        StrCat(CommandLine, '\');
        StrCat(CommandLine, PChar(DirInfo.Name));

        StrCopy(szThermo,
          'Décompression des fichiers sons, patientez ...');
        SetDlgItemText(hThermo, 10000, szThermo);

        {--identifier la tâche de lavac_ut--}
        NumTasks := 1; // FIX LAVAC32 GetNumTasks;
        ShellExecute(window, nil, 'WAVCOMP.EXE',
          CommandLine, Dir, SW_HIDE);
        {--tant que tâche compression pas finie ou pas d'annulation utilisateur--}
        repeat
          if PeekMessage(MSG, 0, 0, 0, PM_REMOVE) and
            (hThermo <> 0) then
          begin
            TranslateMessage(MSG);
            DispatchMessage(MSG);
          end;
        until (NumTasks = 1) or (hThermo = 0); // FIX LAVAC32
      end;
      FindClose(DirInfo);

      StrCopy(Dir, tLecon1.PathLecon);
      StrCopy(CommandLine, Dir);
      StrCat(CommandLine, '\*.BMP');

      DosError := FindFirst(CommandLine, faArchive, DirInfo);
      if DosError = 0 then
      begin
        StrCopy(CommandLine, Dir);
        StrCat(CommandLine, '\');
        StrCat(CommandLine, PChar(DirInfo.Name));
        StrCat(CommandLine, ' /D');

        StrCopy(szThermo,
          'Décompression des fichiers images, patientez ...');
        SetDlgItemText(hThermo, 10000, szThermo);

        {--identifier la tâche de lavac_ut--}
        NumTasks := 1; // FIX LAVAC32 GetNumTasks;
        ShellExecute(window, nil, 'BMPCOMP.EXE',
          CommandLine, Dir, SW_HIDE);
        {--tant que tâche compression pas finie ou pas d'annulation utilisateur--}
        repeat
          if PeekMessage(MSG, 0, 0, 0, PM_REMOVE) and
            (hThermo <> 0) then
          begin
            TranslateMessage(MSG);
            DispatchMessage(MSG);
          end;
        until (NumTasks = 1) or (hThermo = 0); // FIX LAVAC32
      end;
    end;
    FindClose(DirInfo);
    if GetCursor <> hWaitCursor then
      SetCursor(hWaitCursor);
  end;
{***************************************************************************}

function DeleteFile(szFileName : PChar): Bool;

  {***************************************************************************}

var
  f: file;

begin
      {$I-}
      Assign(f, szFileName);
      erase(f);
      {$I+}
      DeleteFile := True
end;

function EraseLeconsLst(szFileName : PChar): Bool;
begin
{--ResetIOResult--}
InOutRes := 0;
{$i-}
Assign(fLecon, szFileName);
Reset(fLecon);
Truncate(fLecon);
Close(fLecon);
{$i+}
EraseLeconsLst := True;
end;

{***************************************************************************}

  function DeleteCompressFile(tLecon1: TypeLecon): Bool;

    {***************************************************************************}

  var
    DirInfo: TSearchRec;
    f: file;

  begin
    {détruire les fichiers compressés }
    StrCopy(szThermo, mmLoadString(hInstRes, STR_DELTEMP));
    SetDlgItemText(hThermo, 10000, szThermo);
    SetCurrentDirectory(tLecon1.PathLecon);
    {
    FindFirst('*.??_', faArchive, DirInfo);
    while DosError = 0 do
    begin
    {$I-}
      Assign(f, DirInfo.Name);
      erase(f);
    {$I+}
      FindNext(DirInfo);
    end;
    }
    If FindFirst('*.??_', faArchive, DirInfo)=0 then
    begin
      Repeat
        {$I-}
        Assign(f, DirInfo.Name);
        erase(f);
        {$I+}
      Until FindNext(DirInfo)<>0;
    end;
    FindClose(DirInfo);

  end;


  procedure DelLessonContent(tLecon1: typeLecon);
  var
    DirInfo: TSearchRec;
    f: file;
    Dir: array[0..79] of char;
    Drive: byte;

  begin
    SetCursor(LoadCursor(0, IDC_WAIT));
    SetCurrentDirectory(tLecon1.PathLecon);
    {
    if DosError = 0 then
    begin
      FindFirst('*.*', faArchive, DirInfo);
      while DosError = 0 do
      begin
      {$I-}
        Assign(f, DirInfo.Name);
        erase(f);
      {$I+}
        if IORESULT <> 0 then;
        FindNext(DirInfo);
      end;
      SetCurrentDirectory('..');
      RemoveDir(tLecon1.PathLecon);
    end;
    }

    If FindFirst('*.*', faArchive, DirInfo)=0 then
    begin
      Repeat
        {$I-}
        Assign(f, DirInfo.Name);
        erase(f);
        {$I+}
      Until FindNext(DirInfo)<>0;
      SetCurrentDirectory('..');
      //RemoveDir(tLecon1.PathLecon);
      //RemoveDirectory(tLecon1.PathLecon);
    end;
    FindClose(DirInfo);

    SetCursor(LoadCursor(0, IDC_ARROW));
  end;

  {***************************************************************************}

  procedure CopyLessonContent(tLecon1, tLecon2: typeLecon);

  {***************************************************************************}

  var
    ExitCopy: boolean;
    hWaitCursor, hOldCursor: HCURSOR;

  begin

    {--charge le thermomètre--}
    lpThermo := @AttenteProc; //MakeProcInstance(@AttenteProc, HInstance);
    hThermo := CreateDialog(hInstRes, 'ATTENTE_UT', Window, DLGPROC(lpThermo));
    SetWindowText(hThermo, mmLoadString(hInstRes, STR_WAITCOPY));

    {--change le pointeur souris, sauve l'ancien--}
    hWaitCursor := LoadCursor(0, IDC_WAIT);
    hOldCursor := SetCursor(hWaitCursor);

    {--Bloque les saisie sur fenêtres : --}
    EnableWindow(hLeconProc, False);
    EnableWindow(hBoutonsProc, False);
    EnableWindow(Window, False);

    {--données statistique de l'opération--}
    if PrepareCopy(tLecon1, tLecon2) then
    begin

      {--créer la leçopn destination--}
      if CreateDestLesson(tLecon1, tLecon2) then
      begin

        {--copier les fichiers sources vers dest--}
        {-- pas compressés et Fast --}
        CopyAllFileEx(tQuestion1, tQuestion2,
          tLecon1, tLecon2,
          False, True);
      end;
    end;

    {--leçon active--}
    tLecon.PathLecon := tLecon2.PathLecon;
    SetCursor(LoadCursor(0, IDC_ARROW));
    EnableWindow(Window, True);
    EnableWindow(hLeconProc, True);
    EnableWindow(hBoutonsProc, True);
    DestroyWindow(hThermo);
    //FreeProcInstance(lpThermo);
  end;

  {***************************************************************************}

  procedure DecompactLessonContent(tLecon1, tLecon2: typeLecon);

  {***************************************************************************}

  var
    ExitCopy: boolean;
    hWaitCursor, hOldCursor: HCURSOR;

  begin

    {--charge le thermomètre--}
    lpThermo := @AttenteProc; //MakeProcInstance(@AttenteProc, HInstance);
    hThermo := CreateDialog(hInstRes, 'ATTENTE_UT', Window, DLGPROC(lpThermo));
    SetWindowText(hThermo, mmLoadString(hInstRes, STR_WAITRESTORE));

    {--change le pointeur souris, sauve l'ancien--}
    hWaitCursor := LoadCursor(0, IDC_WAIT);
    hOldCursor := SetCursor(hWaitCursor);

    {--Bloque les saisie sur fenêtres : --}
    EnableWindow(hLeconProc, False);
    EnableWindow(hBoutonsProc, False);
    EnableWindow(Window, False);

    {--données statistique de l'opération--}
    if PrepareCopy(tLecon1, tLecon2) then
    begin

      {--créer la leçopn destination--}
      if CreateDestLesson(tLecon1, tLecon2) then
      begin

        {--copier les fichiers sources vers dest--}
        {-- pas compressés et pas fast = decomp --}
        CopyAllFileEx(tQuestion1, tQuestion2,
          tLecon1, tLecon2,
          False, False);
      end;
    end;

    {--leçon active--}
    tLecon.PathLecon := tLecon2.PathLecon;
    SetCursor(LoadCursor(0, IDC_ARROW));
    EnableWindow(Window, True);
    EnableWindow(hLeconProc, True);
    EnableWindow(hBoutonsProc, True);
    DestroyWindow(hThermo);
    //FreeProcInstance(lpThermo);
  end;

  {***************************************************************************}

  procedure DecompressLessonContent(tLecon1, tLecon2: typeLecon);

  {***************************************************************************}

  var
    ExitCopy: boolean;
    hWaitCursor, hOldCursor: HCURSOR;

  begin

    {--charge le thermomètre--}
    lpThermo := @AttenteProc; //MakeProcInstance(@AttenteProc, HInstance);
    hThermo := CreateDialog(hInstRes, 'ATTENTE_UT', Window, DLGPROC(lpThermo));
    SetWindowText(hThermo, mmLoadString(hInstRes, STR_WAITRESTORE));

    {--change le pointeur souris, sauve l'ancien--}
    hWaitCursor := LoadCursor(0, IDC_WAIT);
    hOldCursor := SetCursor(hWaitCursor);

    {--Bloque les saisie sur fenêtres : --}
    EnableWindow(hLeconProc, False);
    EnableWindow(hBoutonsProc, False);
    EnableWindow(Window, False);

    {--données statistique de l'opération--}
    if PrepareCopy(tLecon1, tLecon2) then
    begin

      {--créer la leçopn destination--}
      if CreateDestLesson(tLecon1, tLecon2) then
      begin

        {--copier les fichiers sources vers dest--}
        {-- pas compressés et pas fast = decomp --}
        CopyAllFileEx(tQuestion1, tQuestion2,
          tLecon1, tLecon2,
          False, False);

        {--decompresser les fichiers de la lecon cible--}
        DeCompressFile(tLecon2);
      end;
    end;

    {--leçon active--}
    tLecon.PathLecon := tLecon2.PathLecon;
    SetCursor(LoadCursor(0, IDC_ARROW));
    EnableWindow(Window, True);
    EnableWindow(hLeconProc, True);
    EnableWindow(hBoutonsProc, True);
    DestroyWindow(hThermo);
    //FreeProcInstance(lpThermo);
  end;

  {***************************************************************************}

  procedure CompactLessonContent(tLecon1, tLecon2: typeLecon);

  {***************************************************************************}

  var
    ExitCopy: boolean;
    hWaitCursor, hOldCursor: HCURSOR;


  begin

    {--charge le thermomètre--}
    lpThermo := @AttenteProc; //MakeProcInstance(@AttenteProc, HInstance);
    hThermo := CreateDialog(hInstRes, 'ATTENTE_UT', Window, DLGPROC(lpThermo));
    SetWindowText(hThermo, mmLoadString(hInstRes, STR_WAITBACKUP));

    {--change le pointeur souris, sauve l'ancien--}
    hWaitCursor := LoadCursor(0, IDC_WAIT);
    hOldCursor := SetCursor(hWaitCursor);

    {--Bloque les saisie sur fenêtres : --}
    EnableWindow(hLeconProc, False);
    EnableWindow(hBoutonsProc, False);
    EnableWindow(Window, False);

    {--données statistique de l'opération--}
    if PrepareCopy(tLecon1, tLecon2) then
    begin

      {--créer la leçopn destination--}
      if CreateDestLesson(tLecon1, tLecon2) then
      begin

        {--copier les fichiers sources vers dest--}
        {-- Pas compressés et Pas Fast --}
        CopyAllFileEx(tQuestion1, tQuestion2,
          tLecon1, tLecon2,
          False, False);

        {--compresser les fichiers de la lecon cible--}
        CompressFile(tLecon2);

        {--détruire les fichiers compressés sur rep source--}
        {DeleteCompressFile(tLecon1);}

      end;
    end;

    {--leçon active--}
    tLecon.PathLecon := tLecon2.PathLecon;
    SetCursor(LoadCursor(0, IDC_ARROW));
    EnableWindow(Window, True);
    EnableWindow(hLeconProc, True);
    EnableWindow(hBoutonsProc, True);
    DestroyWindow(hThermo);
    //FreeProcInstance(lpThermo);
  end;

function ShellExecAndWait(const FileName, Parameters, dir: string;
  CmdShow: Integer): Boolean;
var
  Sei: TShellExecuteInfo;
begin
  FillChar(Sei, SizeOf(Sei), #0);
  Sei.cbSize := SizeOf(Sei);
  Sei.fMask := SEE_MASK_DOENVSUBST or SEE_MASK_FLAG_NO_UI or SEE_MASK_NOCLOSEPROCESS;
  Sei.lpFile := PChar(FileName);
  Sei.lpParameters := PChar(Parameters);
  Sei.lpdirectory := PChar(dir);
  Sei.nShow := CmdShow;
  Result := ShellExecuteExA(@Sei);
  if Result then
  begin
    WaitForInputIdle(Sei.hProcess, INFINITE);
    WaitForSingleObject(Sei.hProcess, INFINITE);
    CloseHandle(Sei.hProcess);
  end;
end;

  {***************************************************************************}

  function BoutonsProc(Dialog: HWnd; Message, wParam: Dword;
    LParam: longint): Bool; stdcall;

    {***************************************************************************}

  var
    lpEnregistreProc: TFarProc;
    wReturn, noQuestion, nbQuestion: integer;
    OldNom: szLongName;
    POldNom: PChar;
    dwFind, dwRet: DWORD;
    nId, nDel: integer;
    szMessage: szPName;
    nRetMesBox: integer;
    tFindLecon, tDecompLecon: typeLecon;
    hBmp : THANDLE;
    pszFileName : PChar;
    szLeconLst : array[0..1024] of Char;
    pszCmdLineParams : PChar;

  begin
    BoutonsProc := True;
    case Message of
      wm_InitDialog:
      begin
        AdjustToDesktop(Dialog);
        hBmp := LoadImage(0, 'C:\LAVAC\ico\BMP7027.ico', IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR or LR_LOADFROMFILE);
        SendDlgItemMessage( Dialog, 6027, BM_SETIMAGE, IMAGE_ICON, hBmp );
        hBmp := LoadImage(0, 'C:\LAVAC\ico\BMP7028.ico', IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR or LR_LOADFROMFILE);
        SendDlgItemMessage( Dialog, 6028, BM_SETIMAGE, IMAGE_ICON, hBmp );
        hBmp := LoadImage(0, 'C:\LAVAC\ico\BMP7029.ico', IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR or LR_LOADFROMFILE);
        SendDlgItemMessage( Dialog, 6029, BM_SETIMAGE, IMAGE_ICON, hBmp );
        hBmp := LoadImage(0, 'C:\LAVAC\ico\BMP7030.ico', IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR or LR_LOADFROMFILE);
        SendDlgItemMessage( Dialog, 6030, BM_SETIMAGE, IMAGE_ICON, hBmp );
        hBmp := LoadImage(0, 'C:\LAVAC\ico\BMP7031.ico', IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR or LR_LOADFROMFILE);
        SendDlgItemMessage( Dialog, 6031, BM_SETIMAGE, IMAGE_ICON, hBmp );
        hBmp := LoadImage(0, 'C:\LAVAC\ico\BMP7032.ico', IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR or LR_LOADFROMFILE);
        SendDlgItemMessage( Dialog, 6032, BM_SETIMAGE, IMAGE_ICON, hBmp );
        hBmp := LoadImage(0, 'C:\LAVAC\ico\BMP7033.ico', IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR or LR_LOADFROMFILE);
        SendDlgItemMessage( Dialog, 6033, BM_SETIMAGE, IMAGE_ICON, hBmp );
        hBmp := LoadImage(0, 'C:\LAVAC\ico\BMP7000.ico', IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR or LR_LOADFROMFILE);
        SendDlgItemMessage( Dialog, 6008, BM_SETIMAGE, IMAGE_ICON, hBmp );

        pszCmdLineParams := StrTok(GetCommandLine, ' ');
        if (pszCmdLineParams <> nil) AND (StrLen(pszCmdLineParams) > 0) then begin
          //MessageBox(GetDesktopWindow, pszCmdLineParams, 'Command Line Params', MB_OK);
          PostMessage(Dialog, WM_COMMAND, 6034, 0);

        end;

      end;

      wm_MouseActivate:
      begin
        BringWindowToTop(Dialog);
      end;

      wm_Command:
        case LOWORD(wParam) of
          6032:
          begin
            lpEnregistreProc := @OptionsProc; //MakeProcInstance(@OptionsProc, HInstance);
            DialogBox(hInstRes, 'OPTIONS_UT', Dialog, DLGPROC(lpEnregistreProc));
            //FreeProcInstance(lpEnregistreProc);
          end;

          6027:
          begin
            SetCursor(LoadCursor(0, IDC_WAIT));
            if ActivWin = 1 then
            begin
              nId := idl_Lecon1;
              PathServeur := PathServeur1;
              PathLavac := PathLavac1;
              PathLecons := PathLecons1;
            end
            else
            begin
              nId := idl_Lecon2;
              PathServeur := PathServeur2;
              PathLavac := PathLavac2;
              PathLecons := PathLecons2;
            end;
            nbSel :=
              SendDlgItemMessage(hLeconProc, nId, LB_GETSELITEMS, MAXLISTSEL, longint(@nListSel));
            for noSel := 1 to nbSel do
            begin
              noLecon1 :=
                GetLbItemData(hLeconProc, nId, nListSel[noSel]) + 1;
              SendDlgItemMessage(
                hLeconProc, nId, LB_SETSEL, word(False), MakeLong(nListSel[noSel], 0));
              if GetLessonRec(noLecon1, tLecon1) then
              begin
                //lpThermo := MakeProcInstance(@CleanProc, HInstance);
                DialogBox(hInstRes,'CLEAN', Window, DLGPROC(@CleanProc));
                //FreeProcInstance(lpThermo);
              end;
            end;
          end;

          6028,
          6029,
          6030,
          6034:
          begin
            SetCursor(LoadCursor(0, IDC_WAIT));

            if LoWord(wParam) >= 6030 then begin

              if LoWord(wParam) = 6030 then begin
                pszFileName := GetFileName('Leçon Lavac SFX', 'EXE');

                StrCopy(LongPathFichier, 'x -oC:\Lavac\tmp\LECONS "');

                if pszFileName <> nil then begin
                  StrCat(LongPathFichier, pszFileName);
                  StrDispose(pszFileName);
                end else begin
                  StrCat(LongPathFichier, '');
                end;

                StrCat(LongPathFichier, '" -y');

                //MessageBox(GetdesktopWindow, LongPathFichier, 'ShellExecAndWait', MB_OK);

                //ShellExecAndWait('C:\LAVAC\EXE\7z.exe', LongPathFichier, 'C:\Lavac\tmp\LECONS\', SW_HIDE);
                ShellExecAndWait('C:\Program Files (x86)\7-Zip\7z.exe', LongPathFichier, 'C:\Lavac\tmp\LECONS\', SW_HIDE);
                //ShellExecute(window, nil, 'C:\Program Files (x86)\7-Zip\7z.exe', LongPathFichier, 'C:\Lavac\tmp\LECONS\', SW_SHOW);
              end else begin
                wParam := 6030;
              end;

              StrCopy(LongPathFichier, 'C:\Lavac\tmp\LECONS\LECONS.LST');
              if StrLen(LongPathFichier) > 0 then begin
                                FileSplit(LongPathFichier, Dir, Name, Ext);
                                if (StrComp(Ext, '.LST') = 0) and
                                  (
                                  StrComp(Name, 'LECONS') = 0) then
                                begin
                                  StrCopy(PathLecons1, Dir);

                                  if (Dir[StrLen(Dir) - 1] = '\') then
                                    Dir[StrLen(Dir) - 1] := #0;

                                  StrCopy(LongPathFichier, Dir);
                                  FileSplit(LongPathFichier, Dir, Name, Ext);
                                  StrCopy(PathLavac1, Dir);

                                  if (Dir[StrLen(Dir) - 1] = '\') then
                                    Dir[StrLen(Dir) - 1] := #0;

                                  StrCopy(LongPathFichier, Dir);
                                  FileSplit(LongPathFichier, Dir, Name, Ext);
                                  StrCopy(PathServeur1, Dir);

                                  StrCopy(LongPathFichier, PathLecons1);
                                  SetDlgItemText(hLeconProc, 111, LongPathFichier);
                                  SetDlgItemText(hLeconProc, 112, '');
                                  SetDlgItemText(hLeconProc, 113, '');
                                  StrCat(LongPathFichier, 'LECONS.LST');
                                  StrCopy(szLeconLst, LongPathFichier);
                                  AfficheListeLecon(hLeconProc, idl_Lecon1, LongPathFichier, False);
                                  SendDlgItemMessage(hLeconProc, idl_Lecon1, LB_SETSEL, WORD(True), 0);
                                  PathServeur := PathServeur1;
                                  PathLavac := PathLavac1;
                                  PathLecons := PathLecons1;
                                  GetLessonRec(1, tDecompLecon);
                                end;
                              end;
            end;

            if LoWord(wParam) = 6029 then begin
              StrCopy(LongPathFichier, 'C:\Lavac\tmp\LECONS\LECONS.LST');
              if StrLen(LongPathFichier) > 0 then begin
                                FileSplit(LongPathFichier, Dir, Name, Ext);
                                if (StrComp(Ext, '.LST') = 0) and (StrComp(Name, 'LECONS') = 0) then begin
                                  StrCopy(PathLecons2, Dir);

                                  if (Dir[StrLen(Dir) - 1] = '\') then
                                    Dir[StrLen(Dir) - 1] := #0;

                                  StrCopy(LongPathFichier, Dir);
                                  FileSplit(LongPathFichier, Dir, Name, Ext);
                                  StrCopy(PathLavac2, Dir);

                                  if (Dir[StrLen(Dir) - 1] = '\') then
                                    Dir[StrLen(Dir) - 1] := #0;

                                  StrCopy(LongPathFichier, Dir);
                                  FileSplit(LongPathFichier, Dir, Name, Ext);
                                  StrCopy(PathServeur2, Dir);

                                  StrCopy(LongPathFichier, PathLecons2);
                                  SetDlgItemText(hLeconProc, 211, LongPathFichier);
                                  SetDlgItemText(hLeconProc, 212, '');
                                  SetDlgItemText(hLeconProc, 213, '');
                                  StrCat(LongPathFichier, 'LECONS.LST');
                                  StrCopy(szLeconLst, LongPathFichier);
                                  AfficheListeLecon(hLeconProc, idl_Lecon2, LongPathFichier, False);
                                  //SendDlgItemMessage(hLeconProc, idl_Lecon2, LB_SETSEL, WORD(True), 0);
                                  //PathServeur := PathServeur2;
                                  //PathLavac := PathLavac2;
                                  //PathLecons := PathLecons2;
                                  //GetLessonRec(1, tDecompLecon);
                                end;
              end;
            end else begin
              StrCopy(LongPathFichier, PathLecons2);
              StrCat(LongPathFichier, 'LECONS.LST');
              AfficheListeLecon(hLeconProc, idl_Lecon2, LongPathFichier, False);
            end;

            nbSel :=
              SendDlgItemMessage(hLeconProc, idl_Lecon1, LB_GETSELITEMS, MAXLISTSEL,
              longint(@nListSel));
            while (nbSel > 0) and
              (nbSel <> LB_ERR) and
              (nbSel <> LB_ERRSPACE) do
            begin
              noLecon1 :=
                GetLbItemData(hLeconProc, idl_Lecon1, nListSel[1]) + 1;
              PathServeur := PathServeur1;
              PathLavac := PathLavac1;
              PathLecons := PathLecons1;

              if GetLessonRec(noLecon1, tLecon1) OR (LoWord(wParam) = 6030) then
              begin

                //case LoWord(wParam) of
                  { si déjà compressée, copier seulement }
                  {6029:
                    if tLecon1.Syquest then
                      wParam := 6028;
                  }
                  { si pas compressée, copier seulement }
                  {6030 : if NOT tLecon1.Syquest then wParam := 6028;}
                //end;

                nRetMesBox := idNo;
                dwFind :=
                  SendDlgItemMessage(hLeconProc, idl_Lecon2, LB_FINDSTRINGEXACT, 0,
                  longint(@tLecon1.Nom));
                if dwFind <> LB_ERR then
                begin
                  StrCopy(
                    szMessage, 'La Leçon ');
                  StrCat(
                    szMessage, tLecon1.Nom);
                  StrCat(
                    szMessage, ' existe déjà sur l''unité cible.' + #13 + #13 +
                    ' Voulez-vous remplacer la leçon de l''unité cible.');
                  if not
                    bAlwaysReplace then
                  begin
                    nRetMesBox :=
                      MessageBox(Window, szMessage, 'Question', MB_YESNO);

                  end
                  else
                  begin
                    nRetMesBox :=
                      idYes;
                  end;

                  if nRetMesBox = idNo then
                  begin
                    while
                      SendDlgItemMessage(hLeconProc, idl_Lecon2, LB_FINDSTRINGEXACT, 0,
                        longint(@tLecon1.Nom)) <> LB_ERR do
                    begin
                      StrCat(tLecon1.Nom, ' ''');
                    end;
                    noLecon2 :=
                      SendDlgItemMessage(hLeconProc, idl_Lecon2, LB_GETCOUNT, 0, longint(0)) + 1;
                  end
                  else
                  begin
                    noLecon2 :=
                      GetLbItemData(hLeconProc, idl_Lecon2, dwFind) + 1;
                    PathServeur :=
                      PathServeur2;
                    PathLavac :=
                      PathLavac2;
                    PathLecons :=
                      PathLecons2;
                    GetLessonRec(noLecon2, tFindLecon);
                  end;
                end
                else
                begin
                  noLecon2 :=
                    SendDlgItemMessage(hLeconProc, idl_Lecon2, LB_GETCOUNT, 0, longint(0)) + 1;
                end;
                PathServeur := PathServeur2;
                PathLavac := PathLavac2;
                PathLecons := PathLecons2;
                tLecon2 := tLecon1;
                CreateLavacDir;
                CreateNewLessonRep(
                  noLecon2, tLecon2);
                //case wParam of
                                                                {6029 : tLecon2.Syquest := TRUE; leçon compressée
                                                                6030 : tLecon2.Syquest := FALSE; leçon décompressée }
                //end;
                CheckDlgButton(
                  hLeconProc, 214, word(tLecon2.Syquest));
                if SetLessonRec(
                  noLecon2, tLecon2) then
                begin

                  {####}
                  tLecon2.PathLecon[0] :=
                    PathLavac2[0];
                  SetDlgItemText(
                    hLeconProc, 211, tLecon2.PathLecon);
                  SetDlgItemText(
                    hLeconProc, 212, tLecon2.Nom);
                  SetDlgItemText(
                    hLeconProc, 213, tLecon2.Createur);

                  SendDlgItemMessage(hLeconProc, idl_Lecon1, LB_SETSEL, word(False), MakeLong(nListSel[1], 0));
                  SendDlgItemMessage(hLeconProc, idl_Lecon1, LB_SETCARETINDEX, nListSel[1], longint(0));
                  SendMessage(
                    hLeconProc, WM_COMMAND, idl_Lecon1, MakeLong(GetDlgItem(hLeconProc, idl_Lecon1)
                    , LBN_SELCHANGE));

                  if nRetMesBox = idNo then
                  begin
                    dwRet :=
                      AddToList(hLeconProc, 202, tLecon2.Nom, noLecon2 - 1);
                    SendDlgItemMessage(
                      hLeconProc, idl_Lecon2, LB_SETSEL, word(True), MakeLong(dwRet, 0));
                    SendDlgItemMessage(
                      hLeconProc, idl_Lecon2, LB_SETCARETINDEX, dwRet, longint(0));
                    if
                    StrComp(tLecon1.PathLecon, tLecon2.PathLecon) = 0 then
                    begin
                      dwRet :=
                        SendDlgItemMessage(hLeconProc, idl_Lecon1, LB_GETCOUNT, 0, longint(0));
                      dwRet :=
                        AddToList(hLeconProc, 102, tLecon2.Nom, dwRet);
                    end;
                  end
                  else
                  begin
                    SendDlgItemMessage(
                      hLeconProc, idl_Lecon2, LB_SETSEL, word(True), MakeLong(dwFind, 0));
                    SendDlgItemMessage(
                      hLeconProc, idl_Lecon2, LB_SETCARETINDEX, dwFind, longint(0));
                  end;

                  case LoWord(wParam) of
                    6028:
                      CopyLessonContent(tLecon1, tLecon2);
                    6029:
                      CompactLessonContent(tLecon1, tLecon2);
                    6030:
                      if tLecon1.Syquest then
                      begin
                        DecompactLessonContent(
                          tLecon1, tLecon2);
                      end
                      else
                      begin
                        DecompressLessonContent(
                          tLecon1, tLecon2);
                      end;
                  end;

                  if nRetMesBox =
                    idYes then
                  begin
                    //MessageBox(GetdesktopWindow, 'DelLessonContent(tFindLecon);', 'DelLessonContent(tFindLecon);', MB_OK);
                    DelLessonContent(tFindLecon);
                  end;

                  if LoWord(wParam) = 6030 then begin
                    //MessageBox(GetdesktopWindow, tDecompLecon.Nom, szLeconLst, MB_OK);
                    DelLessonContent(tDecompLecon);
                    //RemoveDirectory(tDecompLecon.PathLecon);
                    EraseLeconsLst(szLeconLst);
                    AfficheListeLecon(hLeconProc, idl_Lecon1, szLeconLst, False);
                  end;

                  if LoWord(wParam) = 6029 then begin
                    //StrCopy(LongPathFichier, 'a -sfx7zsd_All.sfx "C:\Lavac\tmp\');
                    StrCopy(LongPathFichier, 'a "C:\Lavac\tmp\');
                    noLecon2 := 1;
                    PathServeur := PathServeur2;
                    PathLavac := PathLavac2;
                    PathLecons := PathLecons2;
                    GetLessonRec(noLecon2, tDecompLecon);
                    StrCat(LongPathFichier, tDecompLecon.Nom);
                    //StrCat(LongPathFichier, '.exe" -r C:\Lavac\tmp\LECONS\*.*');
                    StrCat(LongPathFichier, '.7z" -r C:\Lavac\tmp\LECONS\*.*');
                    //MessageBox(GetdesktopWindow, LongPathFichier, 'ShellExecAndWait', MB_OK);
                    ShellExecAndWait('C:\Program Files (x86)\7-Zip\7z.exe', LongPathFichier, 'C:\Lavac\tmp\', SW_HIDE);
                    DelLessonContent(tDecompLecon);
                    RemoveDirectory(tDecompLecon.PathLecon);
                    EraseLeconsLst(szLeconLst);
                    AfficheListeLecon(hLeconProc, idl_Lecon2, szLeconLst, False);

                    StrCopy(LongPathFichier, 'C:\LAVAC\tmp\');
                    StrCat(LongPathFichier, tDecompLecon.Nom);
                    StrCat(LongPathFichier, '.7z');
                    SetDlgItemText(hLeconProc, 211, LongPathFichier);
                    SetDlgItemText(hLeconProc, 212, '');
                    SetDlgItemText(hLeconProc, 213, '');

                    //StrCopy(LongPathFichier, '/c copy /b "C:\Program Files (x86)\7-Zip\7zsd_All.sfx" + C:\LAVAC\tmp\config.txt + "');
                    StrCopy(LongPathFichier, '/c copy /b C:\LAVAC\SFX\7zsd_All.sfx + C:\LAVAC\SFX\config.txt + "');
                    StrCat(LongPathFichier, tDecompLecon.Nom);
                    StrCat(LongPathFichier, '.7z" "');
                    StrCat(LongPathFichier, tDecompLecon.Nom);
                    StrCat(LongPathFichier, '.exe" ');
                    //MessageBox(GetdesktopWindow, LongPathFichier, 'ShellExecAndWait', MB_OK);
                    ShellExecAndWait('cmd', LongPathFichier, 'C:\Lavac\tmp\', SW_HIDE);

                    StrCopy(LongPathFichier, 'C:\LAVAC\tmp\');
                    StrCat(LongPathFichier, tDecompLecon.Nom);
                    StrCat(LongPathFichier, '.exe ');
                    SetDlgItemText(hLeconProc, 211, LongPathFichier);
                  end;


                  tLecon.PathLecon :=
                    tLecon2.PathLecon;

                end;
              end;
              nbSel :=
                SendDlgItemMessage(hLeconProc, idl_Lecon1, LB_GETSELITEMS, MAXLISTSEL,
                longint(@nListSel));
            end;
          end;

          6033:
          begin
            //lpEnregistreProc := MakeProcInstance(@VoirProc, HInstance);
            DialogBox(hInstRes,'VOIR_UT', Dialog, DLGPROC(@VoirProc));
            //FreeProcInstance(lpEnregistreProc);
          end;

          6031:
          begin
            SetCursor(LoadCursor(0, IDC_WAIT));
            if ActivWin = 1 then
            begin
              nId := idl_Lecon1;
              PathServeur := PathServeur1;
              PathLavac := PathLavac1;
              PathLecons := PathLecons1;
            end
            else
            begin
              nId := idl_Lecon2;
              PathServeur := PathServeur2;
              PathLavac := PathLavac2;
              PathLecons := PathLecons2;
            end;
            nbSel :=
              SendDlgItemMessage(hLeconProc, nId, LB_GETSELITEMS, MAXLISTSEL, longint(@nListSel));
            nDel := 0;
            {for noSel := 1 to nbSel do begin}
            noSel := 1;
            begin
              noLecon1 :=
                GetLbItemData(hLeconProc, nId, nListSel[noSel]) + 1 - nDel;
              SendDlgItemMessage(
                hLeconProc, nId, LB_SETSEL, word(False), MakeLong(nListSel[noSel], 0));
              if GetLessonRec(noLecon1, tLecon1) then
              begin
                StrCopy(szMessage,
                  mmLoadString(hInstRes, STR_DELLESSON));
                StrCat(szMessage, #13 + #13);
                StrCat(szMessage, tLecon1.Nom);
                StrCat(szMessage, #13 + #13);
                StrCat(szMessage,
                  tLecon1.PathLecon);
                if
                (MessageBox(Window,
                  szMessage,
                  mmLoadString(
                  hInstRes, STR_DEL),
                  MB_OKCANCEL
                  or
                  MB_ICONQUESTION) = idOk) then
                begin
                  if
                  tLecon1.Nom[0] <> #0 then
                    DelLessonContent(tLecon1);

                  // fixing
                  CutLessonRec(noLecon1, tLecon1);

                  Inc(nDel);
                end;
              end;
            end;
            if PathServeur1[0] = PathServeur2[0] then
            begin
                                                {StrCopy(PathFichier,PathServeur1);
                                                StrCat(PathFichier,PathLavac);}
              StrCopy(PathFichier, PathLecons1);
              SetDlgItemText(
                hLeconProc, 111, PathFichier);
              SetDlgItemText(hLeconProc, 112, '');
              SetDlgItemText(hLeconProc, 113, '');
              StrCat(PathFichier, 'LECONS.LST');
              AfficheListeLecon(
                hLeconProc, 102, PathFichier, True);
                                                {StrCopy(PathFichier,PathServeur2);
                                                StrCat(PathFichier,PathLavac);}
              StrCopy(PathFichier, PathLecons2);
              SetDlgItemText(
                hLeconProc, 211, PathFichier);
              SetDlgItemText(hLeconProc, 212, '');
              SetDlgItemText(hLeconProc, 213, '');
              StrCat(PathFichier, 'LECONS.LST');
              AfficheListeLecon(
                hLeconProc, 202, PathFichier, True);
            end
            else if ActivWin = 1 then
            begin
                                                {StrCopy(PathFichier,PathServeur1);
                                                StrCat(PathFichier,PathLavac);}
              StrCopy(PathFichier, PathLecons1);
              SetDlgItemText(
                hLeconProc, 111, PathFichier);
              SetDlgItemText(hLeconProc, 112, '');
              SetDlgItemText(hLeconProc, 113, '');
              StrCat(PathFichier, 'LECONS.LST');
              AfficheListeLecon(
                hLeconProc, 102, PathFichier, True);
            end
            else
            begin
                                                {StrCopy(PathFichier,PathServeur2);
                                                StrCat(PathFichier,PathLavac);}
              StrCopy(PathFichier, PathLecons2);
              SetDlgItemText(
                hLeconProc, 211, PathFichier);
              SetDlgItemText(hLeconProc, 212, '');
              SetDlgItemText(hLeconProc, 213, '');
              StrCat(PathFichier, 'LECONS.LST');
              AfficheListeLecon(
                hLeconProc, 202, PathFichier, True);
            end;
          end;

          106:
          begin
          end;


          idb_Quit:
          begin
            DestroyWindow(hSonProc);
            //FreeProcInstance(lpSonProc);
            DestroyWindow(hTexteProc);
            //FreeProcInstance(lpTexteProc);
            DestroyWindow(hGraphiqueProc);
            //FreeProcInstance(lpGraphiqueProc);
            DestroyWindow(hLeconProc);
            //FreeProcInstance(lpLeconProc);
            DestroyWindow(hBoutonsProc);
            //FreeProcInstance(lpBoutonsProc);
            DestroyWindow(hMessagesProc);
            //FreeProcInstance(lpMessagesProc);
            DestroyIcon(hLed_J);
            DestroyIcon(hLed_N);
            DestroyIcon(hLed_R);
            DestroyIcon(hLed_V);
            DestroyIcon(hLedC_J);
            DestroyIcon(hLedC_N);
            DestroyIcon(hLedC_R);
            DestroyIcon(hLedC_V);
            //WinCrt.DoneWinCrt;
            PostQuitMessage(0);
          end;
        end;
    end;
    BoutonsProc := False;
  end;

  function LeconProc(Dialog: HWnd; Message, wParam: Dword;
    LParam: longint): Bool; stdcall;
  var
    Dir: array[0..fsDirectory] of char;
    Name: array[0..fsFileName] of char;
    Ext: array[0..fsExtension] of char;
    szBmp: array[0..fsFileName] of char;
    szText: array[0..1] of char;
    item: word;
    action: word;
    state: word;
    i: integer;
    wTyp: word;
    wRet: word;
    r: Windows.TRECT;
    rTxt: Windows.TRECT;
    dc: HDC;
    OldPen: HPEN;
    OldBrush: HBRUSH;
    lg: longint;
    OldBmp, hBmp: hBitmap;
    BmpDC: hDC;
    psz, pszFile: PChar;

  begin
    LeconProc := True;
    case Message of
      wm_InitDialog:
      begin
        AdjustToDesktop(Dialog);
        GetClientRect(GetDlgItem(Dialog, 104), r);
        SendDlgItemMessage(Dialog, 104,
          //LB_SETCOLUMNWIDTH, 40, 0);
          LB_SETCOLUMNWIDTH, longint(r.right) div 8, 0);
        SendDlgItemMessage(Dialog, 104,
          //LB_SETITEMHEIGHT, 0, longint(16));
          LB_SETITEMHEIGHT, 0, longint(r.bottom));

        for i := 0 to 25 do
        begin
          wTyp := GetDriveType(i);
          szText[0] := Chr(i + Ord('A'));
          szText[1] := #0;
          if wTyp > 1 then
          begin
            wRet :=
              SendDlgItemMessage(Dialog, 104, LB_ADDSTRING, 0, longint(@szText));
            SendDlgItemMessage(
              Dialog, 104, LB_SETITEMDATA, wRet, longint(wTyp));
          end;
        end;
        SendDlgItemMessage(Dialog, 204,
          //LB_SETCOLUMNWIDTH, 40, 0);
          LB_SETCOLUMNWIDTH, longint(r.right) div 8, 0);
        SendDlgItemMessage(Dialog, 204,
          //LB_SETITEMHEIGHT, 0, longint(16));
          LB_SETITEMHEIGHT, 0, longint(r.bottom));
        for i := 0 to 25 do
        begin
          wTyp := GetDriveType(i);
          szText[0] := Chr(i + Ord('A'));
          szText[1] := #0;
          if wTyp > 1 then
          begin
            wRet :=
              SendDlgItemMessage(Dialog, 204, LB_ADDSTRING, 0, longint(@szText));
            SendDlgItemMessage(
              Dialog, 204, LB_SETITEMDATA, wRet, longint(wTyp));
          end;
        end;
      end;

{       TMeasureItemStruct = record
                CtlType: Word;
                CtlID: Word;
                itemID: Word;
                itemWidth: Word;
                itemHeight: Word;
                itemData: Longint;
        end;}

      WM_MEASUREITEM:
      begin
        GetClientRect(GetDlgItem(Dialog, 104), r);
        PMeasureItemStruct(lParam)^.itemWidth := r.right;
        PMeasureItemStruct(lParam)^.itemHeight :=
        //16;{####r.bottom;}
        r.bottom - r.top;
      end;

        {TDrawItemStruct = record
                CtlType: Word;
                CtlID: Word;
                itemID: Word;
                itemAction: Word;
                itemState: Word;
                hwndItem: HWnd;
                hDC: HDC;
                rcItem: TRect;
                itemData: Longint;
        end;}

      WM_DRAWITEM:
      begin
        dc := PDrawItemStruct(lParam)^.hDC;
        r := PDrawItemStruct(lParam)^.rcItem;
        item := PDrawItemStruct(lParam)^.itemID;
        action := PDrawItemStruct(lParam)^.itemAction;
        state := PDrawItemStruct(lParam)^.itemState;
        if boolean(action and ODA_SELECT) or
          boolean(action and ODA_DRAWENTIRE) then
        begin
          if boolean(state and ODS_SELECTED) then
          begin
            OldPen :=
              SelectObject(dc, CreatePen(PS_SOLID, 1, GetSysColor(COLOR_HIGHLIGHT)));
            OldBrush :=
              SelectObject(dc, CreateSolidBrush(GetSysColor(COLOR_HIGHLIGHT)));
            Rectangle(dc, r.left,
              r.top, r.right, r.bottom);
            SetBkColor(DC,
              GetSysColor(COLOR_HIGHLIGHT));
            SetTextColor(DC,
              GetSysColor(COLOR_HIGHLIGHTTEXT));
          end
          else
          begin
            OldPen :=
              SelectObject(dc, CreatePen(PS_SOLID, 1, GetSysColor(COLOR_WINDOW)));
            OldBrush :=
              SelectObject(dc, CreateSolidBrush(GetSysColor(COLOR_WINDOW)));
            Rectangle(dc, r.left,
              r.top, r.right, r.bottom);
            SetBkColor(DC,
              GetSysColor(COLOR_WINDOW));
            SetTextColor(DC,
              GetSysColor(COLOR_MENUTEXT));
          end;
          DeleteObject(SelectObject(dc, OldBrush));
          DeleteObject(SelectObject(dc, OldPen));
          lg :=
            SendMessage(PDrawItemStruct(lParam)^.hWndItem,
            LB_GETTEXT,
            item,
            longint(
            @szText));
          if lg > 0 then begin
            DrawText(dc, szText, lg, @rTxt, DT_CALCRECT OR DT_NOPREFIX OR DT_SINGLELINE);
            TextOut(dc, r.left + 26, r.top + ( (r.bottom - r.top) DIV 2 - abs(rTxt.bottom - rTxt.top) DIV 2) + 1, szText, lg);
          end;
          wTyp :=
            SendMessage(PDrawItemStruct(lParam)^.hWndItem,
            LB_GETITEMDATA,
            item,
            0);
          case wTyp of
            DRIVE_REMOVABLE:
              StrCopy(szBmp, 'REMOVABL');
            DRIVE_FIXED:
              StrCopy(szBmp, 'FIXEDDRV');
            DRIVE_REMOTE:
              StrCopy(szBmp, 'REMOTE');
            DRIVE_CDROM:
              StrCopy(szBmp, 'CDROM');
          end;
          hBmp := LoadBitmap(hInstRes, szBmp);
          BmpDC := CreateCompatibleDC(dc);
          OldBmp := SelectObject(BmpDC, hBmp);
          BitBlt(dc, r.left + 1,
            r.top + (r.bottom - r.top) DIV 2 - 8
            + 1,
            r.left
            + 23 + 1,
            r.top + (r.bottom - r.top) DIV 2 - 8
            + 14 + 1,
            BmpDC,
            0, 0, SrcCopy);
          SelectObject(BmpDC, OldBmp);
          DeleteDC(BmpDC);
          DeleteObject(hBmp);
        end;
      end;

      wm_MouseActivate:
      begin
        BringWindowToTop(Dialog);
      end;

      wm_Command:
        case LOWORD(wParam) of

          102:
          begin
            //case HiWord(LPARAM) of
            case HiWord(WPARAM) of
              LBN_SELCHANGE:
              begin
                {dwReturn :=  SendDlgItemMessage(Dialog,idl_Lecon2,LB_SETCARETINDEX,WORD(-1),LongInt(0));}
                dwReturn :=
                  GetCurLbItemData(Dialog, idl_Lecon1) + 1;
                PathServeur :=
                  PathServeur1;
                PathLavac :=
                  PathLavac1;
                PathLecons :=
                  PathLecons1;
                GetLessonRec(dwReturn, tLecon);
                {####}

                tLecon.PathLecon[0] := PathLavac1[0];

                SetDlgItemText(Dialog, 111, tLecon.PathLecon);
                SetDlgItemText(Dialog, 112, tLecon.Nom);
                SetDlgItemText(Dialog, 113, tLecon.Createur);
                CheckDlgButton(Dialog, 114, word(tLecon.Syquest));
                ActivWin := 1;
                ShowWindow(hDescWin, SW_HIDE);
              end;
            end;
          end;

          202:
          begin
            //case HiWord(LPARAM) of
            case HiWord(WPARAM) of
              LBN_SELCHANGE:
              begin
                {dwReturn :=  SendDlgItemMessage(Dialog,idl_Lecon1,LB_SETCARETINDEX,WORD(-1),LongInt(0));}
                dwReturn :=
                  GetCurLbItemData(Dialog, idl_Lecon2) + 1;
                PathServeur :=
                  PathServeur2;
                PathLavac := PathLavac2;
                PathLecons := PathLecons2;
                GetLessonRec(dwReturn, tLecon);
                {####}
                tLecon.PathLecon
                  [0]
                := PathLavac2[0];
                SetDlgItemText(Dialog, 211, tLecon.PathLecon);
                SetDlgItemText(Dialog, 212, tLecon.Nom);
                SetDlgItemText(Dialog, 213, tLecon.Createur);
                CheckDlgButton(Dialog, 214, word(tLecon.Syquest));
                ActivWin := 2;
                ShowWindow(hDescWin, SW_HIDE);
              end;
            end;
          end;

          112:
          begin
            //case HiWord(LPARAM) of
            case HiWord(WPARAM) of
              EN_CHANGE:
              begin
                LibelleChange := True;
              end;
              EN_KILLFOCUS:
                if LibelleChange then
                begin
                  dwReturn :=
                    GetCurLbItemData(Dialog, idl_Lecon1) + 1;
                  PathServeur := PathServeur1;
                  PathLavac := PathLavac1;
                  PathLecons := PathLecons1;
                  GetLessonRec(dwReturn, tLecon);
                  GetDlgItemText(Dialog, LOWORD(wParam), tLecon.Nom, SizeOf(tLecon.Nom));
                  SetLessonRec(dwReturn, tLecon);
                  LibelleChange :=
                    False;
                end;
            end;
          end;

          113:
          begin
            //case HiWord(LPARAM) of
            case HiWord(WPARAM) of
              EN_CHANGE:
              begin
                CreateurChange := True;
              end;
              EN_KILLFOCUS:
                if CreateurChange then
                begin
                  dwReturn :=
                    GetCurLbItemData(Dialog, idl_Lecon1) + 1;
                  PathServeur := PathServeur1;
                  PathLavac := PathLavac1;
                  PathLecons := PathLecons1;
                  GetLessonRec(dwReturn, tLecon);
                  GetDlgItemText(Dialog, LOWORD(wParam), tLecon.Createur, SizeOf(tLecon.Createur));
                  SetLessonRec(dwReturn, tLecon);
                  CreateurChange := False;
                end;
            end;
          end;

          212:
          begin
            //case HiWord(LPARAM) of
            case HiWord(WPARAM) of
              EN_CHANGE:
              begin
                LibelleChange := True;
              end;
              EN_KILLFOCUS:
                if LibelleChange then
                begin
                  dwReturn :=
                    GetCurLbItemData(Dialog, idl_Lecon2) + 1;
                  PathServeur := PathServeur2;
                  PathLavac := PathLavac2;
                  PathLecons := PathLecons2;
                  GetLessonRec(dwReturn, tLecon);
                  GetDlgItemText(Dialog, LOWORD(wParam), tLecon.Nom, SizeOf(tLecon.Nom));
                  SetLessonRec(dwReturn, tLecon);
                  LibelleChange := False;
                end;
            end;
          end;

          213:
          begin
            //case HiWord(LPARAM) of
            case HiWord(WPARAM) of
              EN_CHANGE:
              begin
                CreateurChange := True;
              end;
              EN_KILLFOCUS:
                if CreateurChange then
                begin
                  dwReturn :=
                    GetCurLbItemData(Dialog, idl_Lecon2) + 1;
                  PathServeur := PathServeur2;
                  PathLavac := PathLavac2;
                  PathLecons := PathLecons2;
                  GetLessonRec(dwReturn, tLecon);
                  GetDlgItemText(Dialog, LOWORD(wParam), tLecon.Createur, SizeOf(tLecon.Createur));
                  SetLessonRec(dwReturn, tLecon);
                  CreateurChange := False;
                end;
            end;
          end;

          104:
          begin
            //case HiWord(LPARAM) of
            case HiWord(WPARAM) of
              LBN_SELCHANGE:
              begin
                wRet :=
                  SendMessage(LoWord(LPARAM), LB_GETCURSEL, 0, 0);
                wRet :=
                  SendMessage(LoWord(LPARAM), LB_GETTEXT, wRet, longint(@szText));
                StrPCopy(PathServeur1, szText[0] + ':\');
                StrPCopy(PathLavac1, szText[0] + ':\LAVAC\');
                StrPCopy(PathLecons1, szText[0] + ':\LAVAC\LECONS\');
                StrCopy(PathFichier, PathLecons1);
                SetDlgItemText(Dialog, 111, PathFichier);
                SetDlgItemText(Dialog, 112, '');
                SetDlgItemText(Dialog, 113, '');
                StrCat(PathFichier, 'LECONS.LST');
                AfficheListeLecon(
                  Dialog, 102, PathFichier, True);
              end;
            end;
          end;


          204:
          begin
            //case HiWord(LPARAM) of
            case HiWord(WPARAM) of
              LBN_SELCHANGE:
              begin
                wRet :=
                  SendMessage(LoWord(LPARAM), LB_GETCURSEL, 0, 0);
                wRet :=
                  SendMessage(LoWord(LPARAM), LB_GETTEXT, wRet, longint(@szText));
                StrPCopy(PathServeur2, szText[0] + ':\');
                StrPCopy(PathLavac2, szText[0] + ':\LAVAC\');
                StrPCopy(PathLecons2, szText[0] + ':\LAVAC\LECONS\');
                StrCopy(PathFichier, PathLecons2);
                SetDlgItemText(Dialog, 211, PathFichier);
                SetDlgItemText(Dialog, 212, '');
                SetDlgItemText(Dialog, 213, '');
                StrCat(PathFichier, 'LECONS.LST');
                AfficheListeLecon(
                  Dialog, 202, PathFichier, True);
              end;
            end;
          end;

          172,
          272:
          begin
            if (LOWORD(wParam) = 172) then begin
              SetWindowPos(hDescWin,
                0,
                stWindowRect.left,
                stWindowRect.top - ((stWindowRect.bottom - stWindowRect.top) div 3),
                0,
                0,
                SWP_NOSIZE or SWP_NOZORDER or SWP_NOREDRAW);
              ShowWindow(hDescWin, SW_SHOW);
              wRet := SendDlgItemMessage(Dialog, 102, LB_GETCURSEL, 0, 0);
              SendDlgItemMessage(Dialog, 102, LB_GETTEXT, wRet, longint(@szText));
             end else begin
               SetWindowPos(hDescWin,
                 0,
                 stWindowRect.left + ((stWindowRect.right - stWindowRect.left) div 2),
                 stWindowRect.top - ((stWindowRect.bottom - stWindowRect.top) div 3),
                 0,
                 0,
                 SWP_NOSIZE or SWP_NOZORDER or SWP_NOREDRAW);
               ShowWindow(hDescWin, SW_SHOW);
               wRet := SendDlgItemMessage(Dialog, 202, LB_GETCURSEL, 0, 0);
               SendDlgItemMessage(Dialog, 202, LB_GETTEXT, wRet, longint(@szText));
             end;

            SetWindowText(hDescWin, szText);
             StrCopy(szXmlSearch, szText);
             psz := StrPos(szXmlSearch, 'VOA SE ');
             if (psz <> nil) then StrCopy(szXmlSearch, @psz[7]);
             //MessageBox(Window, szXmlSearch, 'szXmlSearch', MB_OK);
             //SetWindowText(hDescWin, szXmlSearch);
             if fnxmlparser(szXmlFile, szXmlSearch, szXmlTitle, szXmDescription, szXmlAuthor) <> 0 then begin
                //MessageBox(Window, szXmDescription, szXmlTitle, MB_OK);
                //MessageBox(Window, szXmlAuthor, 'Auteur', MB_OK);
                StrCopy(szDescWin, szXmlTitle);
                StrCat(szDescWin, #13 + #10 + #13 + #10);
                StrCat(szDescWin, szXmDescription);
                StrCat(szDescWin, #13 + #10 + #13 + #10);

                psz := StrPos(szXmlAuthor, 'FN:');
                if (psz <> nil) then StrCopy(szXmlAuthor, @psz[3]);
                psz := StrPos(szXmlAuthor, #10);
                psz[0] := #0;
                StrCat(szDescWin, 'Auteur : ');
                StrCat(szDescWin, szXmlAuthor);

                SetWindowText(hDescWin, szDescWin);
                szXmlTitle[0] := #0;
                szXmDescription[0] := #0;
                szXmlAuthor[0] := #0;
             end;
          end;

          171:
          begin
            //case HiWord(LPARAM) of
            case HiWord(WPARAM) of
              BN_CLICKED:
              begin
                pszFile :=
                  GetFileName(mmLoadString(hInstRes, STR_LST), 'LST');
                if pszFile <> nil then
                begin
                  StrCopy(
                    LongPathFichier, pszFile);
                  StrDispose(
                    pszFile);
                end
                else
                begin
                  StrCopy(
                    LongPathFichier, '');
                end;
                if
                StrLen(LongPathFichier) > 0 then
                begin
                  {fcExtension $0001 fcFileName $0002
                   fcDirectory $0004 fcWildcards $0008}
                  FileSplit(LongPathFichier, Dir, Name, Ext);
                  if (StrComp(Ext, '.LST') = 0) and
                    (
                    StrComp(Name, 'LECONS') = 0) then
                  begin
                    StrCopy(PathLecons1, Dir);

                    if (Dir[StrLen(Dir) - 1] = '\') then
                      Dir[StrLen(Dir) - 1] := #0;

                    StrCopy(LongPathFichier, Dir);
                    FileSplit(LongPathFichier, Dir, Name, Ext);
                    StrCopy(PathLavac1, Dir);

                    if (Dir[StrLen(Dir) - 1] = '\') then
                      Dir[StrLen(Dir) - 1] := #0;

                    StrCopy(LongPathFichier, Dir);
                    FileSplit(LongPathFichier, Dir, Name, Ext);
                    StrCopy(PathServeur1, Dir);

                    StrCopy(LongPathFichier, PathLecons1);
                    SetDlgItemText(Dialog, 111, LongPathFichier);
                    SetDlgItemText(
                      Dialog, 112, '');
                    SetDlgItemText(
                      Dialog, 113, '');
                    StrCat(
                      LongPathFichier, 'LECONS.LST');
                    AfficheListeLecon(
                      Dialog, 102, LongPathFichier, True);
                  end;
                end;
              end;
            end;
          end;

          271:
          begin
            //case HiWord(LPARAM) of
            case HiWord(WPARAM) of
              BN_CLICKED:
              begin
                pszFile :=
                  GetFileName(mmLoadString(hInstRes, STR_LST), 'LST');
                if
                pszFile <> nil then
                begin
                  StrCopy(
                    LongPathFichier, pszFile);
                  StrDispose(
                    pszFile);
                end
                else
                begin
                  StrCopy(
                    LongPathFichier, '');
                end;
                if
                StrLen(LongPathFichier) > 0 then
                begin
                                                                        {fcExtension $0001 fcFileName $0002
                                                                         fcDirectory $0004 fcWildcards $0008}
                  FileSplit(
                    LongPathFichier, Dir, Name, Ext);
                  if
                  (StrComp(Ext, '.LST') = 0) and
                    (
                    StrComp(Name, 'LECONS') = 0) then
                  begin
                    StrCopy(PathLecons2, Dir);

                    if (Dir[StrLen(Dir) - 1] = '\') then
                      Dir[StrLen(Dir) - 1] := #0;

                    StrCopy(LongPathFichier, Dir);
                    FileSplit(LongPathFichier, Dir, Name, Ext);
                    StrCopy(PathLavac2, Dir);

                    if (Dir[StrLen(Dir) - 1] = '\') then
                      Dir[StrLen(Dir) - 1] := #0;

                    StrCopy(
                      LongPathFichier, Dir);
                    FileSplit(
                      LongPathFichier, Dir, Name, Ext);
                    StrCopy(
                      PathServeur2, Dir);

                    StrCopy(
                      LongPathFichier, PathLecons2);
                    SetDlgItemText(
                      Dialog, 211, LongPathFichier);
                    SetDlgItemText(
                      Dialog, 212, '');
                    SetDlgItemText(
                      Dialog, 213, '');
                    StrCat(
                      LongPathFichier, 'LECONS.LST');
                    AfficheListeLecon(
                      Dialog, 202, LongPathFichier, True);
                  end;
                end;
              end;
            end;
          end;

        end;
    end;
    LeconProc := False;
  end;

  function WindowProc(Window: HWnd; Message, wParam: Dword;
    LParam: longint): longint; stdcall;
  var
    MSG: TMSG;
    f: file;
  begin
    WindowProc := 0;

    case Message of
      wm_Destroy:
      begin
        PostQuitMessage(0);
        Exit;
      end;
    end;
    WindowProc := DefWindowProc(Window, Message, wParam, LParam);
  end;

  procedure InitFirstInstance;
  var
    lpAboutProc: Pointer;
  begin
    ItWasBitmap := False;
    ItWasTexte := False;
    ItWasSon := False;
    ClosePosted := False;
    hLed_J := LoadIcon(hInstRes, 'LED_J');
    hLed_N := LoadIcon(hInstRes, 'LED_N');
    hLed_R := LoadIcon(hInstRes, 'LED_R');
    hLed_V := LoadIcon(hInstRes, 'LED_V');
    hLedC_J := LoadIcon(hInstRes, 'LEDC_J');
    hLedC_N := LoadIcon(hInstRes, 'LEDC_N');
    hLedC_R := LoadIcon(hInstRes, 'LEDC_R');
    hLedC_V := LoadIcon(hInstRes, 'LEDC_V');

    //lpBoutonsProc := MakeProcInstance(@BoutonsProc, hInstance);
    hBoutonsProc := CreateDialog(hInstRes, 'Boutons_UT', Window, DLGPROC(@BoutonsProc));

    //lpLeconProc := MakeProcInstance(@LeconProc, hInstance);
    hLeconProc := CreateDialog(hInstRes, 'Lecon_UT', Window, DLGPROC(@LeconProc));

    //lpAboutBoxProc := MakeProcInstance(@AboutBoxProc, HInstance);
    //DialogBox(hInstRes, 'ABOUTBOX_PRMKUT', Window, DLGPROC(@AboutBoxProc));
    //FreeProcInstance(lpAboutBoxProc);

  end;

  {QCM}
  {*************************************************************}
  {**                    Fonction  QcmProc                    **}
  {** SE: Gère les messages particuliers de la fenêtre QCM.   **}
  {** SI: En fonction des messages envoyés.                   **}
  {*************************************************************}
  function QcmProc(Dialog: HWnd; Message, WParam: Dword; LParam: longint): BOOL; stdcall;
  var
    AReqQcm: PReqText;
    r, rI, rT: Windows.TRECT;
    pt: Windows.TPOINT;
    szFormat, szLink, szLine: array[0..255] of
    char;
    pLink: PChar;

  begin
    QcmProc := True;
    case Message of
{$IFDEF _E0}{ Créateur... }
      WM_SETCURSOR:
        if MainQcmWin^.wMode <> M_MAKE then
        begin
          if LOWORD(lParam) =
            HTCAPTION then
          begin
            SetCursor(
              LoadCursor(0, IDC_SIZE));
            SetWindowLong(
              Dialog, DWL_MSGRESULT, MAKELONG(word(True), 0));
            exit;
          end;
        end;

      WM_NCHITTEST:
      begin
        if (MainQCMWin^.wMode <>
          M_MAKE) then
        begin
          SetWindowLong(
            Dialog, 0{DWL_MSGRESULT}, ProcessHitTest(Dialog, message, wParam, lParam));
        end
        else
        begin
          SetWindowLong(
            Dialog, 0{DWL_MSGRESULT}, HTCLIENT);
        end;
        exit;
      end;

      WM_MOUSEACTIVATE:
      begin
        CheckRadioButton(
          hListBar, 1200, 1206, 1204);
        PostMessage(Dialog,
          WM_USER, 0, 0);
      end;

      WM_USER:
      begin
        GetWindowText(Dialog,
          szFormat, SizeOf(szFormat));
        pLink := @MainQcmWin^.szFichierQ;
        wvsprintf(szLine,
          szFormat, pLink);
        SetDlgItemText(
          hStatusBar, 101, szLine);

        if hOldHandled <> hQCMProc then
        begin
          if hOldHandled <> 0 then
          begin
            SetWindowPos(
              hOldHandled, 0, 0, 0, 0, 0,
              SWP_DRAWFRAME
              or
              SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
            UpdateHandle(
              hOldHandled);
          end;
          UpdateHandle(hQCMProc);
          hOldHandled := hQCMProc;
        end;

      end;

      WM_PAINT:
      begin
        UpdateWindow(hBoutonsProc);
        UpdateWindow(hLeconProc);
        dc := BeginPaint(Dialog, ps);
        EndPaint(Dialog, ps);
        if
        (IsDlgButtonChecked(hListBar, 1204) = 1) and
          (MainQCMWin^.wMode <>
          M_MAKE) then
        begin
          dc :=
            GetWindowDC(Dialog);
          ShowHandle(dc, Dialog);
          ReleaseDC(Dialog, dc);
        end;
      end;
{$ELSE}{ Créateur... }
      WM_PAINT:
      begin
        UpdateWindow(hBoutonsProc);
        UpdateWindow(hLeconProc);
        dc := BeginPaint(Dialog, ps);
        EndPaint(Dialog, ps);
      end;
{$ENDIF}{ Créateur... }

      wm_InitDialog:
      begin
        PostMessage(Dialog,
          WM_MMPAINT, 0, 0);
      end;

      WM_MMPAINT:
      begin
        GetWindowRect(
          hGraphiqueProc, rI);
        MapWindowPoints(
          HWND_DESKTOP, GetParent(Dialog), rI, 2);
        GetWindowRect(hTexteProc, rT);
        MapWindowPoints(
          HWND_DESKTOP, GetParent(Dialog), rT, 2);
        SetWindowPos(Dialog,
          0, rI.left, rI.top, rI.right - rI.left, rT.bottom - rI.top, SWP_NOZORDER or
          SWP_NOREDRAW);
      end;

      WM_WINDOWPOSCHANGING: { TWINDOWPOS }
      begin
        UpdateHandle(Dialog);
        if IsZoomed(Dialog) then
        begin
          GetWindowRect(
            GetParent(Dialog), r);
          MapWindowPoints(0,
            Window, r, 2);
          PWINDOWPOS(lParam)^.x :=
            -GetSystemMetrics(SM_CXDLGFRAME);
          PWINDOWPOS(lParam)^.y :=
            -GetSystemMetrics(SM_CYDLGFRAME);
          PWINDOWPOS(lParam)^.cx :=
            r.right - r.left + 2 * GetSystemMetrics(SM_CXDLGFRAME) - 1;
          PWINDOWPOS(lParam)^.cy :=
            r.bottom - r.top + 2 * GetSystemMetrics(SM_CYDLGFRAME) - 1;
        end;
      end;

      WM_WINDOWPOSCHANGED: { TWINDOWPOS }
      begin
        UpdateHandle(Dialog);
      end;

      {$IFDEF _TUTOR}
      WM_MOVE:
        if (MainQcmWin <> nil) AND MainQcmWin^.bSizable then
        begin
          dwReturn :=
            SendDlgItemMessage(hListBar, idl_ListeQ, LB_GETCURSEL, 0, longint(0)) + 1;
          GetQuestionRec(
            dwReturn, tQuestion);
          GetWindowRect(
            hQcmProc, r);
          MapWindowPoints(0,
            GetParent(hQcmProc), r, 2);
          tQuestion.qX := r.left;
          tQuestion.qY := r.top;
          tQuestion.qW :=
            r.right - r.left;
          tQuestion.qH :=
            r.bottom - r.top;
          SetQuestionRec(
            dwReturn, tQuestion);
        end;

      WM_SIZE:
      begin
        SendMessage(lpQcmMkWin^.HWindow, WM_SIZE, wParam, lParam);
        { -- sauver la nouvelle position -- }
        PostMessage(Dialog,
          WM_MOVE, 0, 0);
      end;
      {$ENDIF}

      WM_GETMINMAXINFO:
      begin
        PMinMaxInfo(
          lParam)^.ptMinTrackSize.X := 300;
        PMinMaxInfo(
          lParam)^.ptMinTrackSize.Y := 100;
      end;

      {$IFDEF _TUTOR}

      UM_PLAYQCM:
      begin
        AReqQcm := PReqText(lParam);
        with AReqQcm^.Rect do
          MoveWindow(Dialog, Left, Top, Right, Bottom, True);
        SendMessage
        (MainQcmWin^.HWindow, UM_PLAYQCM, wParam, lParam);
      end;

      UM_ADDSEL:
      begin
        SendMessage
        (MainQcmWin^.HWindow, UM_ADDSEL, wParam, lParam);
      end;

      UM_APPEL:
      begin
        MainQcmWin^.AppelLecon;
      end;
      {$ENDIF}

                                        {####WM_SETFOCUS :
                                                SendMessage (MainQcmWin^.HWindow, WM_QUERY NEW PALETTE, 0, 0);}
    end;
    QcmProc := False; {DefWindowProc(Dialog, Message, WParam, LParam);}
  end;

  procedure WinMain;
  var
    Message: TMsg;
    stDeskRect: Windows.TRECT;
    stLeconRect: Windows.TRECT;
    stBoutonsRect: Windows.TRECT;
    szXmlUrl : array[0..1024] of char;
    hLogFnt :  Windows.TLOGFONT;
  const
    WindowClass: TWndClass = (
      style: 0;
      lpfnWndProc: WNDPROC(@WindowProc);
      cbClsExtra: 0;
      cbWndExtra: 0;
      hInstance: 0;
      hIcon: 0;
      hCursor: 0;
      hbrBackground: 0;
      lpszMenuName: nil;{AppName;}
      lpszClassName: AppName);
  begin
    if HPrevInst = 0 then
    begin
      WindowClass.hInstance := HInstance;
      WindowClass.hIcon := LoadIcon(hInstRes, AppName);
      WindowClass.hCursor := LoadCursor(0, idc_Arrow);
      WindowClass.hbrBackground := COLOR_APPWORKSPACE + 1;
      if not RegisterClass(WindowClass) = 0 then
        Halt(255);
    end;


    hInstRes := hInstance;

    Ctl3dRegister(hInstance);
    Ctl3dAutoSubclass(hInstance);

    GetWindowRect(GetDesktopWindow, stDeskRect);
    //stDeskRect.right := stDeskRect.right DIV 2;
    //stDeskRect.bottom := stDeskRect.bottom DIV 2;
    stDeskRect.right := stDeskRect.left + (stDeskRect.right - stDeskRect.left) DIV 2;
    stDeskRect.bottom := stDeskRect.top + (stDeskRect.bottom - stDeskRect.top) DIV 2;
    rcApp := stDeskRect;
    //rcApp.Right := rcApp.Right DIV 2;
    //rcApp.Right := 800;
    //rcApp.Bottom := 600;
    //stDeskRect := rcApp;
    Window := CreateWindow(AppName, 'Lavac Utilitaire',//AppName,
      //WS_OVERLAPPEDWINDOW,   //     Creates an overlapped window having the WS_OVERLAPPED,
      //WS_CAPTION OR WS_SYSMENU OR WS_THICKFRAME,
      WS_CAPTION OR WS_SYSMENU,
      //WS_MINIMIZEBOX, and WS_MAXIMIZEBOX styles.}
      //WS_OVERLAPPEDWINDOW OR WS_CLIPCHILDREN OR WS_CLIPSIBLINGS,
      0, 0, stDeskRect.right,
      stDeskRect.bottom, 0, 0,
      HInstance, nil);
    InitFirstInstance;

    SetWindowPos(hLeconProc,
      0,
      4,
      4,
      0,
      0,
      SWP_NOSIZE or SWP_NOZORDER or SWP_NOREDRAW);
    GetWindowRect(hLeconProc, stLeconRect);
    SetWindowPos(hBoutonsProc,
      0,
      4,
      stLeconRect.bottom - stLeconRect.top + 8,
      0,
      0,
      SWP_NOSIZE or SWP_NOZORDER or SWP_NOREDRAW);
    GetWindowRect(hBoutonsProc, stBoutonsRect);
    stWindowRect.Left := 0;
    stWindowRect.Top := 0;
    stWindowRect.Right := stBoutonsRect.right - stBoutonsRect.left + 8;
    stWindowRect.Bottom := stBoutonsRect.bottom - stLeconRect.top + 8;
    AdjustWindowRectEx(stWindowRect, GetWindowLong(Window, GWL_STYLE), boolean(GetMenu(Window)), GetWindowLong(Window, GWL_EXSTYLE));
    SetWindowPos(Window,
      0,
      stWindowRect.Left,
      stWindowRect.Right,
      stWindowRect.Right - stWindowRect.Left,
      stWindowRect.Bottom - stWindowRect.Top,
      SWP_NOZORDER or SWP_NOREDRAW);
    SetWindowPos(Window,
      0,
      0,
      0,
      0,
      0,
      SWP_NOSIZE or SWP_NOZORDER or SWP_NOREDRAW);
    GetWindowRect(GetDesktopWindow, rcApp);
    CenterDialog(Window);
    GetWindowRect(Window, stWindowRect);

    ShowWindow(Window, CmdShow);
    UpdateWindow(Window);

    {$IFDEF _TUTOR}
    QcmAppli.Init(AppName);
    InitOleAndStream;
    LPQcmProc := MakeProcInstance(@QcmProc, hInstance);
    { Créer la fenêtre QCM Lavac non visible au départ}
    hQcmProc := CreateDialog(hInstance, 'QCM_EL', Window, lpQcmProc);

    if lpQcmMkWin = nil then
      (New(PWinMk, Init(hQcmProc, 'QcmIF')))^.Create;
    {$ENDIF}

    GetPrivateProfileString('LAVAC64', 'LESSON_DESC_URL', 'http://oai.iutenligne.net/ori-oai/OAIHandler?verb=ListRecords&metadataPrefix=lom&set=domaine:26568', szXmlUrl, SizeOf(szXmlUrl), gszIni);
    GetPrivateProfileString('LAVAC64', 'LESSON_DESC_PATH', 'C:\LAVAC\xml\lessons.xml', szXmlFile, SizeOf(szXmlFile), gszIni);
    if Not FileExist(szXmlFile) then begin
       //MessageBox(Window, 'bip', 'xml', MB_OK OR MB_APPLMODAL OR MB_ICONSTOP);
       GetUrlContent(szXmlUrl, szXmlFile);
    end;
  	with hLogFnt do begin
	 lfHeight:= -11;
	 lfWidth:= 0;
	 lfEscapement:= 0;
	 lfOrientation:= 0;
	 lfWeight:= FW_BOLD {FW_NORMAL};
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
	hfnt := CreateFontIndirect(hLogFnt);

    hDescWin :=  CreateWindow(
    	'STATIC',
    	'',
    	WS_CHILD OR WS_POPUP OR WS_BORDER OR WS_THICKFRAME OR WS_SYSMENU, // OR WS_VISIBLE,
    	stWindowRect.left + ((stWindowRect.right - stWindowRect.left) div 2),
    	stWindowRect.top - ((stWindowRect.bottom - stWindowRect.top) div 3),
    	(stWindowRect.right - stWindowRect.left) div 2,
    	(stWindowRect.bottom - stWindowRect.top) div 3,
    	Window,
    	0,
    	HInstance,
    	nil);
    SendMessage(hDescWin, WM_SETFONT, hfnt, 0);

    while GetMessage(Message, 0, 0, 0) do
    begin
      if not ((hBoutonsProc <> 0) and IsDialogMessage(hBoutonsProc, Message)) and
        not ((hLeconProc <> 0) and
        IsDialogMessage(hLeconProc, Message)) and not
        ((hThermo <> 0) and IsDialogMessage(hThermo, Message)) then
      begin
        TranslateMessage(Message);
        DispatchMessage(Message);
      end;
    end;

    {$IFDEF _TUTOR}
    Dispose(lpQcmMkWin, done);
    DestroyWindow(hQcmProc);
    FreeProcInstance(lpQcmProc);
    FreeOleClientInstances;
    QcmAppli.Done;
    {$ENDIF}

    Ctl3dUnregister(hInstance);

    Halt(Message.wParam);
  end;

begin
  bDynaPath := True;
  //bDynaPath := False;
  if Not SystemCanSupportPerMonitorDpi(True) then
     SystemCanSupportOldDpiAwareness(True);
  WinMain;
end.

