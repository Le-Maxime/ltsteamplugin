# PowerShell Installer for LuaTools Steam Plugin
$ErrorActionPreference = 'Stop'

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   LuaTools Steam Plugin Installer & Updater " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 1. Detect Steam Installation Path
Write-Host "Detecting Steam installation path..." -ForegroundColor Gray
$SteamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue).SteamPath
if (-not $SteamPath) {
    $SteamPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
}
if (-not $SteamPath) {
    $SteamPath = "C:\Program Files (x86)\Steam"
}

# Normalize path separators
$SteamPath = $SteamPath.Replace('/', '\')
Write-Host "Steam Path Detected: $SteamPath" -ForegroundColor Green

# 2. Define plugin path
$PluginDir = Join-Path $SteamPath "millennium\plugins\luatools"
Write-Host "Target Plugin Directory: $PluginDir" -ForegroundColor Gray

# Create directories if needed
if (-not (Test-Path $PluginDir)) {
    New-Item -ItemType Directory -Force -Path $PluginDir | Out-Null
    Write-Host "Created plugin directory." -ForegroundColor Green
} else {
    Write-Host "Plugin directory already exists. Overwriting existing installation..." -ForegroundColor Yellow
}

# 3. Download Latest Release
$DownloadUrl = "https://github.com/Le-Maxime/ltsteamplugin/releases/latest/download/ltsteamplugin.zip"
$TempZip = [System.IO.Path]::GetTempFileName() + ".zip"

Write-Host "Downloading latest release from GitHub..." -ForegroundColor Cyan
try {
    # Ensure TLS 1.2 is enabled
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempZip -UserAgent "LuaTools-Installer" -UseBasicParsing
    Write-Host "Download complete." -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to download plugin from GitHub. Please check your internet connection." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if (Test-Path $TempZip) { Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue }
    try { Read-Host "Press Enter to exit" } catch {}
    exit 1
}

# 4. Extract Archive
Write-Host "Extracting files to target directory..." -ForegroundColor Cyan
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($TempZip)
    foreach ($entry in $zip.Entries) {
        $target = Join-Path $PluginDir $entry.FullName
        $dir = [System.IO.Path]::GetDirectoryName($target)
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }
        if ($entry.Name -ne '') {
            # Extract and overwrite if exists
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $target, $true)
        }
    }
    $zip.Dispose()
    Write-Host "Extraction complete." -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to extract plugin archive." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if (Test-Path $TempZip) { Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue }
    try { Read-Host "Press Enter to exit" } catch {}
    exit 1
}

# 5. Cleanup
if (Test-Path $TempZip) {
    Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue
}

Write-Host "`nLuaTools Steam Plugin installed successfully!" -ForegroundColor Green
Write-Host "Please restart Steam to load the plugin." -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan
try { Read-Host "Press Enter to exit" } catch {}
