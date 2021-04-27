# https://devblogs.microsoft.com/scripting/use-the-powershell-registry-provider-to-simplify-registry-access/

# In Powershell, all function definitions must be at the top in order to be loaded into memory before running the main script.

Write-Output "Run As Administrator"
# https://stackoverflow.com/a/31602095/1628707
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }


# http://community.idera.com/powershell/powertips/b/tips/posts/refreshing-icon-cache
function Update-ExplorerIcon {
  [CmdletBinding()]
  param()

  $code = @'
private static readonly IntPtr HWND_BROADCAST = new IntPtr(0xffff); 
private const int WM_SETTINGCHANGE = 0x1a; 
private const int SMTO_ABORTIFHUNG = 0x0002; 
 

[System.Runtime.InteropServices.DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
 static extern bool SendNotifyMessage(IntPtr hWnd, uint Msg, UIntPtr wParam,
   IntPtr lParam);

[System.Runtime.InteropServices.DllImport("user32.dll", SetLastError = true)] 
  private static extern IntPtr SendMessageTimeout ( IntPtr hWnd, int Msg, IntPtr wParam, string lParam, uint fuFlags, uint uTimeout, IntPtr lpdwResult ); 
 
 
[System.Runtime.InteropServices.DllImport("Shell32.dll")] 
private static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);


public static void Refresh()  {
    SHChangeNotify(0x8000000, 0x1000, IntPtr.Zero, IntPtr.Zero);
    SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, IntPtr.Zero, null, SMTO_ABORTIFHUNG, 100, IntPtr.Zero); 
}
'@

  Add-Type -MemberDefinition $code -Namespace MyWinAPI -Name Explorer 
  [MyWinAPI.Explorer]::Refresh()

}


######################  MAIN ###################

# Script developed by Charles L Flatt
# https://www.softwaremeadows.com
# MIT License

$ErrorActionPreference = "Stop"
$currentFolder = Get-Location 

# This is the new "standard" path
$basePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\resources\app\resources\win32\"

If (-Not (Test-Path $basePath))
{
    # This is the old path
    $basePath = "$env:ProgramFiles\Microsoft VS Code\resources\app\resources\win32\"
}

Write-Output ""
Write-Output "Starting"

$sourcePath = $PSScriptRoot
if (!$sourcePath) {
    $sourcePath = $psISE.CurrentFile.FullPath
}
Write-Output "Copying orange icons from "
Write-Output "$sourcePath"
Write-Output "to"
Write-Output "$basePath"

$iconFile = Join-Path $basePath  "code_file.ico"
Write-Output "iconFile $iconFile"
# Get path if debugging in ISE

Copy-Item -Path @(Join-Path $sourcePath *) -Include *.png,*.ico -Destination $basePath

Write-Output "Setting Registry..."
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
Write-Output "Setting HKCR"
Set-Location HKCR:
Set-ItemProperty -LiteralPath "HKCR:\*\shell\VSCode" -Name Icon -Value $iconFile
Set-ItemProperty -Path HKCR:\Directory\Background\shell\VSCode -Name Icon -Value $iconFile
Set-ItemProperty -Path HKCR:\Directory\shell\VSCode -Name Icon -Value $iconFile
Set-ItemProperty -Path HKCR:\Drive\shell\VSCode -Name Icon -Value $iconFile

Write-Output "Setting HKCU"
Set-Location HKCU:
Set-ItemProperty -LiteralPath "HKCU:\SOFTWARE\Classes\*\shell\VSCode" -Name Icon -Value $iconFile 
Set-ItemProperty -Path HKCU:\SOFTWARE\Classes\Directory\Background\shell\VSCode -Name Icon -Value $iconFile
Set-ItemProperty -Path HKCU:\SOFTWARE\Classes\Directory\shell\VSCode -Name Icon -Value $iconFile
Set-ItemProperty -Path HKCU:\SOFTWARE\Classes\Drive\shell\VSCode -Name Icon -Value $iconFile

# Uncomment for "system" installs
# Write-Output "Setting HKLM"
# Set-Location HKLM:
# Set-ItemProperty -LiteralPath "HKLM:\SOFTWARE\Classes\*\shell\VSCode" -Name Icon -Value $iconFile 
# Set-ItemProperty -Path HKLM:\SOFTWARE\Classes\Directory\Background\shell\VSCode -Name Icon -Value $iconFile
# Set-ItemProperty -Path HKLM:\SOFTWARE\Classes\Directory\shell\VSCode -Name Icon -Value $iconFile
# Set-ItemProperty -Path HKLM:\SOFTWARE\Classes\Drive\shell\VSCode -Name Icon -Value $iconFile

Set-Location C:
Remove-PSDrive -Name HKCR 


$shortcut = Read-Host "Create a shortcut? (y/N)"
if ($shortcut -eq 'y')
{
    Write-Output "Creating shortcut in Desktop"
    $TargetFile = $basePath + "..\..\..\..\code.exe"
    $ShortcutFile = "$env:UserProfile\Desktop\VS Code.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.IconLocation = $iconFile
    $Shortcut.Save()
}

# refresh icon cache
Write-Output("Attempting to refresh icon cache")
Update-ExplorerIcon
Set-Location $currentFolder
Write-Output "Finished. Press <Enter> to exit."
Pause
