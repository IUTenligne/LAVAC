unit PerMonitorApi;

interface

const
   Process_DPI_Unaware = 0;
   Process_System_DPI_Aware = 1;    // Old windows 8.0
   Process_Per_Monitor_DPI_Aware = 2; // Windows 8.1

function SystemCanSupportPerMonitorDpi(AutoEnable: Boolean): Boolean; // New Windows 8.1 dpi awareness available?

function SystemCanSupportOldDpiAwareness(AutoEnable: Boolean): Boolean; // Windows Vista/ Windows 7 Global System DPI functional level.

var
   _RequestedLevelOfAwareness:LongInt;
   _ProcessDpiAwarenessValue:LongInt;

implementation

uses
   SysUtils,
   Windows;

type
   TGetProcessDPIAwarenessProc = function(const hprocess: THandle; var ProcessDpiAwareness: LongInt): HRESULT; stdcall;
   TSetProcessDPIAwarenessProc = function(const ProcessDpiAwareness: LongInt): HRESULT; stdcall;

const
   E_ACCESSDENIED = $80070005;



function _GetProcessDpiAwareness(AutoEnable: Boolean): LongInt;
var
   hprocess: THandle;
   HRESULT: DWORD;
   BAwareness: Integer;
   GetProcessDPIAwareness: TGetProcessDPIAwarenessProc;
   LibHandle: THandle;
   PID: DWORD;

   function ManifestOverride: Boolean;
   var
      HRESULT: DWORD;
      SetProcessDPIAwareness: TSetProcessDPIAwarenessProc;
   begin
      Result := False;
      SetProcessDPIAwareness := TSetProcessDPIAwarenessProc(GetProcAddress(LibHandle, 'SetProcessDpiAwareness'));
      if Assigned(SetProcessDPIAwareness) and (_RequestedLevelOfAwareness>=0) then
      begin
         HRESULT := SetProcessDPIAwareness(_RequestedLevelOfAwareness ); // If we do this we don't need the manifest change.
         Result := (HRESULT = 0) or (HRESULT = E_ACCESSDENIED)
         // if Result = 80070005 then ACESS IS DENIED, means already set.
      end
   end;

begin
   Result := _ProcessDpiAwarenessValue;
   if (Result = -1) then
   begin
      BAwareness := 3;
      LibHandle := LoadLibrary('shcore.dll');
      if LibHandle <> 0 then
      begin
         if (not AutoEnable) or ManifestOverride then
         begin
            // This supercedes the Vista era IsProcessDPIAware api, and is available in Windows 8.0 and 8.1,although only
            // windows 8.1 and later will return a per-monitor-dpi-aware result.
            GetProcessDPIAwareness := TGetProcessDPIAwarenessProc(GetProcAddress(LibHandle, 'GetProcessDpiAwareness'));
            if Assigned(GetProcessDPIAwareness) then
            begin
               PID := Windows.GetCurrentProcessId;
               hprocess := OpenProcess(PROCESS_ALL_ACCESS, False, PID);
               if hprocess > 0 then
               begin
                  HRESULT := GetProcessDPIAwareness(hprocess, BAwareness);
                  if HRESULT = 0 then
                     Result := BAwareness;
               end;
            end;
         end;
      end;
   end;
end;

// If this returns true, this is a windows 8.1 system that has Per Monitor DPI Awareness enabled
// at a system level.
function SystemCanSupportPerMonitorDpi(AutoEnable: Boolean): Boolean;
begin
   if AutoEnable then
   begin
    _RequestedLevelOfAwareness := Process_Per_Monitor_DPI_Aware;
    _ProcessDpiAwarenessValue := -1;
   end;
   Result := _GetProcessDpiAwareness(AutoEnable) = Process_Per_Monitor_DPI_Aware;
end;


// If this returns true, This is either a Windows 7 machine, or a Windows 8 machine, or a
// Windows 8.1 machine where the Per-DPI Monitor Awareness feature has been disabled.
function SystemCanSupportOldDpiAwareness(AutoEnable: Boolean): Boolean;
begin
   if AutoEnable then
   begin
     _RequestedLevelOfAwareness := Process_System_DPI_Aware; //Process_Per_Monitor_DPI_Aware;
     _ProcessDpiAwarenessValue := -1;
   end;

   Result := _GetProcessDpiAwareness(AutoEnable) = Process_System_DPI_Aware;
end;


initialization
   _ProcessDpiAwarenessValue := -1;// not yet determined.
   _RequestedLevelOfAwareness := -1;

end.
