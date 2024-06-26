<#
 # Script that fixes winget not loading
 # 02/29/2024 Johan Cho
 # powershell winget-fix.ps1
 #>

function Install-Winget {
    <#
    .SYNOPSIS
        Updates/installs winget.
    .DESCRIPTION
        Updates/installs winget.
    .EXAMPLE
        Update-Winget
    .OUTPUTS
        System.null
    #>

    Write-Host "Installing winget..." -ForegroundColor Green
    $outFile = "$env:temp\WinGet.msixbundle"
    if (!(Test-Path $outFile)) {
        Remove-Item $outFile -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Downloading winget..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $outFile
    try {
        Add-AppxPackage $outFile -ErrorAction Stop
    }
    catch {
        Write-Host "Failed to install winget" -ForegroundColor Red
        Install-MSXML
        Write-Host "trying to install winget again..." -ForegroundColor Green
        Add-AppxPackage $outFile
    }
    Write-Host "Finished" -ForegroundColor Green
}

function Install-MSXML {
    <#
    .SYNOPSIS
        Installs Microsoft UI XAML.
    .DESCRIPTION
        Installs Microsoft UI XAML.
    .EXAMPLE
        Install-MSXML
    .OUTPUTS
        System.null
    #>

    Write-Host "Trying to install Microsoft.UI.Xaml package..." -ForegroundColor Yellow
    $zipPath = "$env:temp\microsoft.ui.xaml.zip"
    if (!(Test-Path $zipPath)) {
        Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml" -OutFile $zipPath
    }
    Expand-Archive $zipPath -DestinationPath $zipPath.TrimEnd(".zip") -Force
    Add-AppxPackage $(Get-ChildItem -Path "$($zipPath.TrimEnd(".zip"))\tools\AppX\x64\Release\" -Filter "*.appx")[0].FullName -ErrorAction Stop
    Remove-Item -Path $zipPath.TrimEnd(".zip") -Recurse -Force
    Remove-Item -Path $zipPath -Force
    Write-Host "Microsoft.UI.Xaml package install finished" -ForegroundColor Green
}

Install-Winget
