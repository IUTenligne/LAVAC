############################################################################################
#      NSIS Installation Script created by NSIS Quick Setup Script Generator v1.09.18
#               Entirely Edited with NullSoft Scriptable Installation System                
#              by Vlasis K. Barkas aka Red Wine red_wine@freemail.gr Sep 2006               
############################################################################################

!define APP_NAME "LAVAC64"
!define COMP_NAME "IUT en ligne"
;!define WEB_SITE "http://www.iutenligne.net/m"
!define VERSION "4.0.3.9"
!define COPYRIGHT "IUTenLigne © 2015"
!define DESCRIPTION "Application"
!define INSTALLER_NAME "C:\LAVAC32\Install\Output\LAVAC64\LAVAC64.exe"
!define MAIN_APP_EXE "LAVAC_ET.EXE"
!define INSTALL_TYPE "SetShellVarContext current"
!define REG_ROOT "HKCU"
!define REG_APP_PATH "Software\Microsoft\Windows\CurrentVersion\App Paths\${MAIN_APP_EXE}"
!define UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

######################################################################

VIProductVersion  "${VERSION}"
VIAddVersionKey "ProductName"  "${APP_NAME}"
VIAddVersionKey "CompanyName"  "${COMP_NAME}"
VIAddVersionKey "LegalCopyright"  "${COPYRIGHT}"
VIAddVersionKey "FileDescription"  "${DESCRIPTION}"
VIAddVersionKey "FileVersion"  "${VERSION}"

######################################################################

SetCompressor ZLIB
Name "${APP_NAME}"
Caption "${APP_NAME}"
OutFile "${INSTALLER_NAME}"
BrandingText "${APP_NAME}"
XPStyle on
InstallDirRegKey "${REG_ROOT}" "${REG_APP_PATH}" ""
InstallDir "C:\LAVAC"

######################################################################

!include "MUI.nsh"

!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING

!define MUI_LANGDLL_REGISTRY_ROOT "${REG_ROOT}"
!define MUI_LANGDLL_REGISTRY_KEY "${UNINSTALL_PATH}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

!insertmacro MUI_PAGE_WELCOME

!ifdef LICENSE_TXT
!insertmacro MUI_PAGE_LICENSE "${LICENSE_TXT}"
!endif

!insertmacro MUI_PAGE_DIRECTORY

!ifdef REG_START_MENU
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "LAVAC64"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${REG_ROOT}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${UNINSTALL_PATH}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${REG_START_MENU}"
!insertmacro MUI_PAGE_STARTMENU Application $SM_Folder
!endif

!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM

!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "French"

!insertmacro MUI_RESERVEFILE_LANGDLL

######################################################################

Function .onInit
!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

######################################################################
Var VS2010SetupError

Section "VS2010 Install" SEC_VS2010
 
 SectionIn RO
 
 SetOutPath "$TEMP"
 File "vcredist_x86.exe"
 DetailPrint "Running VS2010 Setup..."
 ExecWait '"$TEMP\vcredist_x86.exe" /q:a /c:"VCREDI~1.EXE /q:a /c:""msiexec /i vcredist.msi /qb!"" "' $VS2010SetupError
 DetailPrint "Finished VS2010 Setup"
 
 Delete "$TEMP\vcredist_x86.exe"
 
SectionEnd

Section -MainProgram
${INSTALL_TYPE}
SetOverwrite ifnewer
SetOutPath "$INSTDIR"
File "C:\LAVAC\About box Lavac.txt"
File "C:\LAVAC\Anglais Méthodologie pour l'étudiant 2012-2013.doc"
File "C:\LAVAC\LAVAC.INI"
File "C:\LAVAC\Lavac.LIC"
SetOutPath "$INSTDIR\xml"
File "C:\LAVAC\xml\lessons.xml"
SetOutPath "$INSTDIR\Téléchargement des cours"
File "C:\LAVAC\Téléchargement des cours\Téléchargement et installation.rtf"
SetOutPath "$INSTDIR\Textes"
File "C:\LAVAC\Textes\Info.rtf"
File "C:\LAVAC\Textes\notes.rtf"
File "C:\LAVAC\Textes\RTF.NEW"
SetOutPath "$INSTDIR\Sons"
File "C:\LAVAC\Sons\11025_16.NEW"
File "C:\LAVAC\Sons\11025_8.NEW"
File "C:\LAVAC\Sons\22050_16.NEW"
File "C:\LAVAC\Sons\22050_8.NEW"
File "C:\LAVAC\Sons\44100_16.NEW"
File "C:\LAVAC\Sons\44100_8.NEW"
File "C:\LAVAC\Sons\Info.rtf"
SetOutPath "$INSTDIR\SAUVELEV"
File "C:\LAVAC\SAUVELEV\Info.rtf"
File "C:\LAVAC\SAUVELEV\Sauvegarde de votre travail.doc"
SetOutPath "$INSTDIR\Ressources\VIDEO"
SetOutPath "$INSTDIR\Prof"
File "C:\LAVAC\Prof\DILATATO.VAL"
File "C:\LAVAC\Prof\ETUDIANT.LST"
File "C:\LAVAC\Prof\Info.rtf"
SetOutPath "$INSTDIR\LECONS"
File "C:\LAVAC\LECONS\Info.rtf"
SetOutPath "$INSTDIR\Images"
File "C:\LAVAC\Images\BITMAP.NEW"
File "C:\LAVAC\Images\Info.rtf"
File "C:\LAVAC\Images\VIDEO.NEW"
SetOutPath "$INSTDIR\ico"
File "C:\LAVAC\ico\BMP7000.ico"
File "C:\LAVAC\ico\BMP7027.ico"
File "C:\LAVAC\ico\BMP7028.ico"
File "C:\LAVAC\ico\BMP7029.ico"
File "C:\LAVAC\ico\BMP7030.ico"
File "C:\LAVAC\ico\BMP7031.ico"
File "C:\LAVAC\ico\BMP7032.ico"
File "C:\LAVAC\ico\BMP7033.ico"
File "C:\LAVAC\ico\Custom-Icon-Design-Pretty-Office-6-Logout.ico"
File "C:\LAVAC\ico\GREEN.ico"
File "C:\LAVAC\ico\GREY.ico"
File "C:\LAVAC\ico\Hopstarter-Soft-Scraps-Document.ico"
File "C:\LAVAC\ico\Hopstarter-Soft-Scraps-Edit-Document.ico"
File "C:\LAVAC\ico\Icons8-Ios7-Media-Controls-High-Volume - Green.ico"
File "C:\LAVAC\ico\Icons8-Ios7-Media-Controls-High-Volume - Red.ico"
File "C:\LAVAC\ico\Icons8-Ios7-Very-Basic-Settings-Filled.ico"
File "C:\LAVAC\ico\LAVAC64.ico"
File "C:\LAVAC\ico\LISTEN.ico"
File "C:\LAVAC\ico\LISTEN_GREEN.ico"
File "C:\LAVAC\ico\LISTEN_GREEN_RED.ico"
File "C:\LAVAC\ico\LISTEN_RED.ico"
File "C:\LAVAC\ico\MugenB16-Microphones-Mic-2.ico"
File "C:\LAVAC\ico\Oxygen-Icons.org-Oxygen-Actions-media-playback-pause.ico"
File "C:\LAVAC\ico\Oxygen-Icons.org-Oxygen-Actions-media-playback-start.ico"
File "C:\LAVAC\ico\RED.ico"
File "C:\LAVAC\ico\YELLOW.ico"
SetOutPath "$INSTDIR\tmp\LECONS"
File "C:\LAVAC\tmp\LECONS\LECONS.LST"
SetOutPath "$INSTDIR\SFX"
File "C:\LAVAC\SFX\config.txt"
File "C:\LAVAC\SFX\7zsd_All.sfx"
SetOutPath "$INSTDIR\EXE"
File "C:\LAVAC\EXE\LAVAC_ET.EXE"
File "C:\LAVAC\EXE\LAVAC_UT.EXE"
File "C:\LAVAC\EXE\LICENCE.DLL"
File "C:\LAVAC\EXE\WINCONST.DLL"
File "C:\LAVAC\EXE\xmlparser.dll"
SetOutPath "$INSTDIR\AIDE"
File "C:\LAVAC\AIDE\Aide.rtf"
SectionEnd

######################################################################

Section -Icons_Reg
SetOutPath "$INSTDIR"
WriteUninstaller "$INSTDIR\uninstall.exe"

!ifdef REG_START_MENU
!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
CreateDirectory "$SMPROGRAMS\$SM_Folder"
CreateShortCut "$SMPROGRAMS\$SM_Folder\${APP_NAME}.lnk" "$INSTDIR\EXE\${MAIN_APP_EXE}"
CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\EXE\${MAIN_APP_EXE}"
!ifdef WEB_SITE
WriteIniStr "$INSTDIR\${APP_NAME} website.url" "InternetShortcut" "URL" "${WEB_SITE}"
CreateShortCut "$SMPROGRAMS\$SM_Folder\${APP_NAME} Website.lnk" "$INSTDIR\${APP_NAME} website.url"
!endif
!insertmacro MUI_STARTMENU_WRITE_END
!endif

!ifndef REG_START_MENU
CreateDirectory "$SMPROGRAMS\LAVAC64"
CreateShortCut "$SMPROGRAMS\LAVAC64\${APP_NAME}.lnk" "$INSTDIR\EXE\${MAIN_APP_EXE}"
CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\EXE\${MAIN_APP_EXE}"
!ifdef WEB_SITE
WriteIniStr "$INSTDIR\${APP_NAME} website.url" "InternetShortcut" "URL" "${WEB_SITE}"
CreateShortCut "$SMPROGRAMS\LAVAC64\${APP_NAME} Website.lnk" "$INSTDIR\${APP_NAME} website.url"
!endif
!endif

WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "" "$INSTDIR\${MAIN_APP_EXE}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayName" "${APP_NAME}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "UninstallString" "$INSTDIR\uninstall.exe"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayIcon" "$INSTDIR\EXE\${MAIN_APP_EXE}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayVersion" "${VERSION}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "Publisher" "${COMP_NAME}"

!ifdef WEB_SITE
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "URLInfoAbout" "${WEB_SITE}"
!endif

WriteIniStr 'LAVAC.INI' 'DIRECTORIES' 'SERVER' 'C:\'
WriteIniStr 'LAVAC.INI' 'DIRECTORIES' 'FLOPPY' 'C:\LAVAC\SAUVELEV'
WriteIniStr 'LAVAC.INI' 'DIRECTORIES' 'DYNAPATH' 'FALSE'
WriteIniStr 'LAVAC.INI' 'DIRECTORIES' 'DILATATO' '1'

WriteIniStr 'LAVAC.INI' 'OPTIONS' 'largelist' '1'

WriteIniStr 'LAVAC.INI' 'WAVE' 'BITS' '16'
WriteIniStr 'LAVAC.INI' 'WAVE' 'FREQ' '22050'
WriteIniStr 'LAVAC.INI' 'WAVE' 'BLOCK' '11025'
WriteIniStr 'LAVAC.INI' 'WAVE' 'SBP_PORT' 'FFFF'

WriteIniStr 'LAVAC.INI' 'VIDEO' 'EXT' '.AVI;*.AVS;*.MPG;*.FLI;*.FLC;*.MOV;*.WMV'
WriteIniStr 'LAVAC.INI' 'VIDEO' 'LOCAL' 'TRUE'
WriteIniStr 'LAVAC.INI' 'VIDEO' 'TAILLE' '2048'
WriteIniStr 'LAVAC.INI' 'VIDEO' 'DEFEXT' 'AVI'
WriteIniStr 'LAVAC.INI' 'VIDEO' 'EDITOR' 'VIDCAP.EXE'

WriteIniStr 'LAVAC.INI' 'NETWORK' 'DILATATO' '1'
WriteIniStr 'LAVAC.INI' 'NETWORK' 'NETBIOS' 'TRUE'
WriteIniStr 'LAVAC.INI' 'NETWORK' 'STATION' '1'

WriteIniStr 'LAVAC.INI' 'IMAGE' 'EXT' '.BMP;*.DIB'
WriteIniStr 'LAVAC.INI' 'IMAGE' 'DEFEXT' 'BMP'
WriteIniStr 'LAVAC.INI' 'IMAGE' 'EDITOR' 'C:\LAVAC\MSPAINT.EXE'

WriteIniStr 'LAVAC.INI' 'SOUND' 'EXT' '.WAV'
WriteIniStr 'LAVAC.INI' 'SOUND' 'DEFEXT' 'WAV'
WriteIniStr 'LAVAC.INI' 'SOUND' 'EDITOR' 'C:\LAVAC\SndRec32.EXE'

WriteIniStr 'LAVAC.INI' 'TEXT' 'EXT' '.TXT;*.RTF'
WriteIniStr 'LAVAC.INI' 'TEXT' 'DEFEXT' 'RTF'
WriteIniStr 'LAVAC.INI' 'TEXT' 'EDITOR' 'C:\LAVAC\WORDPAD.EXE'

WriteIniStr 'LAVAC.INI' 'Creator' 'Width' '365'

WriteIniStr 'LAVAC.INI' 'LAVAC64' 'LINE_1' 'Antoine TOMA'
WriteIniStr 'LAVAC.INI' 'LAVAC64' 'LINE_2' 'Toulouse'
WriteIniStr 'LAVAC.INI' 'LAVAC64' 'LINE_3' 'lavac@iutenligne.net'
WriteIniStr 'LAVAC.INI' 'LAVAC64' 'LESSON_DESC_URL' 'http://oai.iutenligne.net/ori-oai/OAIHandler?verb=ListRecords&metadataPrefix=lom&set=domaine:26568'
WriteIniStr 'LAVAC.INI' 'LAVAC64' 'LESSON_DESC_PATH' 'C:\LAVAC\xml\lessons.xml'
WriteIniStr 'LAVAC.INI' 'LAVAC64' 'VLC_PATH' 'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe'
WriteIniStr 'LAVAC.INI' 'LAVAC64' 'WRITER_PATH' 'C:\Program Files (x86)\OpenOffice 4\program\swriter.exe'
WriteIniStr 'LAVAC.INI' 'LAVAC64' 'NOTES_TEMPLATE' 'C:\LAVAC\Textes\notes.rtf'
WriteIniStr 'LAVAC.INI' 'LAVAC64' 'NAME' ''

SectionEnd

######################################################################

Section Uninstall
${INSTALL_TYPE}
Delete "$INSTDIR\About box Lavac.txt"
Delete "$INSTDIR\Anglais Méthodologie pour l'étudiant 2012-2013.doc"
Delete "$INSTDIR\LAVAC.INI"
Delete "$INSTDIR\Lavac.LIC"
Delete "$INSTDIR\xml\lessons.xml"
Delete "$INSTDIR\Téléchargement des cours\Téléchargement et installation.rtf"
Delete "$INSTDIR\Textes\Info.rtf"
Delete "$INSTDIR\Textes\notes.rtf"
Delete "$INSTDIR\Textes\RTF.NEW"
Delete "$INSTDIR\Sons\11025_16.NEW"
Delete "$INSTDIR\Sons\11025_8.NEW"
Delete "$INSTDIR\Sons\22050_16.NEW"
Delete "$INSTDIR\Sons\22050_8.NEW"
Delete "$INSTDIR\Sons\44100_16.NEW"
Delete "$INSTDIR\Sons\44100_8.NEW"
Delete "$INSTDIR\Sons\Info.rtf"
Delete "$INSTDIR\SAUVELEV\Info.rtf"
Delete "$INSTDIR\SAUVELEV\Sauvegarde de votre travail.doc"
Delete "$INSTDIR\Prof\DILATATO.VAL"
Delete "$INSTDIR\Prof\ETUDIANT.LST"
Delete "$INSTDIR\Prof\Info.rtf"
Delete "$INSTDIR\LECONS\Info.rtf"
Delete "$INSTDIR\Images\BITMAP.NEW"
Delete "$INSTDIR\Images\Info.rtf"
Delete "$INSTDIR\Images\VIDEO.NEW"
Delete "$INSTDIR\ico\Custom-Icon-Design-Pretty-Office-6-Logout.ico"
Delete "$INSTDIR\ico\GREEN.ico"
Delete "$INSTDIR\ico\GREY.ico"
Delete "$INSTDIR\ico\Hopstarter-Soft-Scraps-Document.ico"
Delete "$INSTDIR\ico\Hopstarter-Soft-Scraps-Edit-Document.ico"
Delete "$INSTDIR\ico\Icons8-Ios7-Media-Controls-High-Volume - Green.ico"
Delete "$INSTDIR\ico\Icons8-Ios7-Media-Controls-High-Volume - Red.ico"
Delete "$INSTDIR\ico\Icons8-Ios7-Very-Basic-Settings-Filled.ico"
Delete "$INSTDIR\ico\LAVAC64.ico"
Delete "$INSTDIR\ico\LISTEN.ico"
Delete "$INSTDIR\ico\LISTEN_GREEN.ico"
Delete "$INSTDIR\ico\LISTEN_GREEN_RED.ico"
Delete "$INSTDIR\ico\LISTEN_RED.ico"
Delete "$INSTDIR\ico\MugenB16-Microphones-Mic-2.ico"
Delete "$INSTDIR\ico\Oxygen-Icons.org-Oxygen-Actions-media-playback-pause.ico"
Delete "$INSTDIR\ico\Oxygen-Icons.org-Oxygen-Actions-media-playback-start.ico"
Delete "$INSTDIR\ico\RED.ico"
Delete "$INSTDIR\ico\YELLOW.ico"
Delete "$INSTDIR\ico\*.ico"
Delete "$INSTDIR\SFX\*.*"
Delete "$INSTDIR\EXE\LAVAC_ET.EXE"
Delete "$INSTDIR\EXE\LICENCE.DLL"
Delete "$INSTDIR\EXE\WINCONST.DLL"
Delete "$INSTDIR\EXE\xmlparser.dll"
Delete "$INSTDIR\AIDE\Aide.rtf"
 
RmDir "$INSTDIR\AIDE"
RmDir "$INSTDIR"
RmDir "$INSTDIR\ico"
RmDir "$INSTDIR\SFX"
RmDir "$INSTDIR\Images"
RmDir "$INSTDIR\LECONS\L0000006"
RmDir "$INSTDIR\LECONS\L0000007"
RmDir "$INSTDIR\LECONS\L0000008"
RmDir "$INSTDIR\LECONS\L0000009"
RmDir "$INSTDIR\LECONS\L0000010"
RmDir "$INSTDIR\LECONS\L0000011"
RmDir "$INSTDIR\LECONS\L0000012"
RmDir "$INSTDIR\LECONS"
RmDir "$INSTDIR\Prof"
RmDir "$INSTDIR\Ressources\VIDEO"
RmDir "$INSTDIR\SAUVELEV"
RmDir "$INSTDIR\Sons"
RmDir "$INSTDIR\Textes"
RmDir "$INSTDIR\Téléchargement des cours"
RmDir "$INSTDIR\xml"
 
Delete "$INSTDIR\uninstall.exe"
!ifdef WEB_SITE
Delete "$INSTDIR\${APP_NAME} website.url"
!endif

RmDir "$INSTDIR"

!ifdef REG_START_MENU
!insertmacro MUI_STARTMENU_GETFOLDER "Application" $SM_Folder
Delete "$SMPROGRAMS\$SM_Folder\${APP_NAME}.lnk"
!ifdef WEB_SITE
Delete "$SMPROGRAMS\$SM_Folder\${APP_NAME} Website.lnk"
!endif
Delete "$DESKTOP\${APP_NAME}.lnk"

RmDir "$SMPROGRAMS\$SM_Folder"
!endif

!ifndef REG_START_MENU
Delete "$SMPROGRAMS\LAVAC64\${APP_NAME}.lnk"
!ifdef WEB_SITE
Delete "$SMPROGRAMS\LAVAC64\${APP_NAME} Website.lnk"
!endif
Delete "$DESKTOP\${APP_NAME}.lnk"

RmDir "$SMPROGRAMS\LAVAC64"
!endif

DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}"
SectionEnd

######################################################################

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
FunctionEnd

######################################################################

