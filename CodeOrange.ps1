# In Powershell, all function definitions must be at the top in order to be loaded into memory before running the main script.


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


# This is the new "standard" path
$basePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\resources\app\resources\win32\"

If (-Not (Test-Path $basePath))
{
    # This is the old path
    $basePath = "$env:ProgramFiles\Microsoft VS Code\resources\app\resources\win32\"
}

Write-Output ""
Write-Output "Starting"
Write-Output "VS Code Path: $basePath"

Write-Output "Copying orange icons"
$iconFile = Join-Path $basePath  "code_file.ico"
Copy-Item -Path @(Join-Path $PSScriptRoot *) -Include *.png,*.ico -Destination $basePath

Write-Output "Setting Registry..."
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
Set-ItemProperty -LiteralPath "HKCR:\*\shell\VSCode" -Name Icon -Value $iconFile
Set-ItemProperty -Path HKCR:\Directory\Background\shell\VSCode -Name Icon -Value $iconFile
Set-ItemProperty -Path HKCR:\Drive\shell\VSCode -Name Icon -Value $iconFile
Set-ItemProperty -Path HKCU:\Software\Classes\Directory\shell\VSCode -Name Icon -Value $iconFile
Remove-PSDrive -Name HKCR 

$shortcut = Read-Host "Create a shortcut? (y/N)"
if ($shortcut -eq 'y' -or $shortcut -eq 'Y')
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

Write-Output "Finished. Press <Enter> to exit."
Pause