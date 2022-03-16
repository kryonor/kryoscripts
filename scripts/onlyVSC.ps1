$DEBUG = $False

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class EXT {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll", SetLastError=true)]
    public static extern IntPtr GetWindowThreadProcessId(IntPtr hWnd, out IntPtr lpdwProcessId);
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern int GetWindowText(IntPtr hWnd, String lpString, int nMaxCount);
}
"@

function Add-Log {
    param (
        [Diagnostics.Process]$proc,
        [IntPtr]$hWnd,
        [Int]$len
    )
    if ($DEBUG)
    {
        Write-Output $proc |
            Format-Table @{ Label="ProcessName"; Expression={$proc.Name} }, 
            @{ Label="ProcessID"; Expression={$proc.Id} }, 
            @{ Label="MainWindow"; Expression={$proc.MainWindowHandle} }, 
            @{ Label="ActiveWindow"; Expression={$hWnd} },
            @{ Label="Titlebar"; Expression={$len} }
    }
}

function Get-VSCRunningStatus {
    $codelst = Get-Process | Where-Object { $_.Name -eq "Code"}
    if ($null -eq $codelst) {
        return $False
    } else {
        return $True
    }
}
[IntPtr]$prevWin = 0x000

while ($(Get-VSCRunningStatus))
{
    [IntPTr]$fgPID  = 0x000
    [IntPtr]$fgWin  = [EXT]::GetForegroundWindow()
    [IntPtr]$fgTHID = [EXT]::GetWindowThreadProcessId($fgWin, [ref]$fgPID)

    [String]$fgText = ""
    [Int]$fgTextLen = [EXT]::GetWindowText($fgWin, [ref]$fgText, 255)

    [Diagnostics.Process]$fgProc = Get-Process -Id $fgPID

    Add-Log -proc $fgProc -hWnd $fgWin -len $fgTextLen

    if (($fgTextLen -eq 0) -or ($fgProc.Name -eq "SearchApp")) {
        Start-Sleep -Milliseconds 750
        continue
    }

    if (-not ($fgWin -eq $prevWin)) {
        if ($fgProc.Name -eq "Code") {
            <# NIRCMD #>
            Start-Process nircmd "sendkeypress rwin+d"
            Start-Sleep -Milliseconds 125
            [EXT]::ShowWindowAsync($fgWin, 3) | Out-Null
            
            <# EnumWindows TODO #>
        }
    }

    $prevWin = $fgWin
    if ($DEBUG) {Write-Output "prev+"}
    Start-Sleep -Milliseconds 1500
}
