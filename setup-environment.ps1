# ============================================
# Script: Setup Environment Variables
# Purpose: Set permanent environment variables to use E drive for cache and temp
# Run this script ONCE with Administrator privileges
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SETUP ENVIRONMENT VARIABLES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "WARNING: Script is not running with Administrator privileges" -ForegroundColor Yellow
    Write-Host "Some system environment variables may not be set." -ForegroundColor Yellow
    Write-Host "To set all variables, please:" -ForegroundColor Yellow
    Write-Host "1. Open PowerShell as Administrator" -ForegroundColor Yellow
    Write-Host "2. Run this script again" -ForegroundColor Yellow
    Write-Host ""
    
    $continue = Read-Host "Do you want to continue with User privileges only? (Y/N)"
    if ($continue -ne 'Y' -and $continue -ne 'y') {
        Write-Host "Script cancelled." -ForegroundColor Red
        exit
    }
}

# Create necessary directories on E drive
Write-Host "Creating directories on E drive..." -ForegroundColor Yellow

$directories = @(
    "E:\temp",
    "E:\.npm-cache",
    "E:\.pub-cache",
    "E:\.gradle",
    "E:\.android",
    "E:\.m2"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "  Already exists: $dir" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Setting environment variables..." -ForegroundColor Yellow

# Set environment variables for User (no Admin required)
Write-Host ""
Write-Host "  [USER SCOPE]" -ForegroundColor Cyan

# TEMP and TMP
[System.Environment]::SetEnvironmentVariable('TEMP', 'E:\temp', 'User')
[System.Environment]::SetEnvironmentVariable('TMP', 'E:\temp', 'User')
Write-Host "  TEMP = E:\temp" -ForegroundColor Green
Write-Host "  TMP = E:\temp" -ForegroundColor Green

# npm cache
[System.Environment]::SetEnvironmentVariable('npm_config_cache', 'E:\.npm-cache', 'User')
Write-Host "  npm_config_cache = E:\.npm-cache" -ForegroundColor Green

# Flutter/Dart pub cache
[System.Environment]::SetEnvironmentVariable('PUB_CACHE', 'E:\.pub-cache', 'User')
Write-Host "  PUB_CACHE = E:\.pub-cache" -ForegroundColor Green

# Gradle (for Android)
[System.Environment]::SetEnvironmentVariable('GRADLE_USER_HOME', 'E:\.gradle', 'User')
Write-Host "  GRADLE_USER_HOME = E:\.gradle" -ForegroundColor Green

# Android SDK
[System.Environment]::SetEnvironmentVariable('ANDROID_USER_HOME', 'E:\.android', 'User')
Write-Host "  ANDROID_USER_HOME = E:\.android" -ForegroundColor Green

# Maven (for Java)
[System.Environment]::SetEnvironmentVariable('MAVEN_OPTS', '-Dmaven.repo.local=E:\.m2\repository', 'User')
Write-Host "  MAVEN_OPTS = -Dmaven.repo.local=E:\.m2\repository" -ForegroundColor Green

# Set environment variables for Machine (requires Admin)
if ($isAdmin) {
    Write-Host ""
    Write-Host "  [MACHINE SCOPE - Requires Admin]" -ForegroundColor Cyan
    
    try {
        [System.Environment]::SetEnvironmentVariable('TEMP', 'E:\temp', 'Machine')
        [System.Environment]::SetEnvironmentVariable('TMP', 'E:\temp', 'Machine')
        Write-Host "  TEMP (Machine) = E:\temp" -ForegroundColor Green
        Write-Host "  TMP (Machine) = E:\temp" -ForegroundColor Green
    } catch {
        Write-Host "  Cannot set Machine variables: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  COMPLETED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Environment variables have been set permanently:" -ForegroundColor Yellow
Write-Host "   TEMP, TMP -> E:\temp" -ForegroundColor White
Write-Host "   npm_config_cache -> E:\.npm-cache" -ForegroundColor White
Write-Host "   PUB_CACHE -> E:\.pub-cache" -ForegroundColor White
Write-Host "   GRADLE_USER_HOME -> E:\.gradle" -ForegroundColor White
Write-Host "   ANDROID_USER_HOME -> E:\.android" -ForegroundColor White
Write-Host "   MAVEN_OPTS -> E:\.m2\repository" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "   1. Close ALL open terminals/PowerShell windows" -ForegroundColor White
Write-Host "   2. Close VS Code (if open)" -ForegroundColor White
Write-Host "   3. Open new terminal/VS Code" -ForegroundColor White
Write-Host "   4. Then you can run 'npm start' or 'flutter run' normally" -ForegroundColor White
Write-Host "   5. NO NEED to run start-backend.ps1 or start-frontend.ps1 anymore!" -ForegroundColor White
Write-Host ""
Write-Host "To verify environment variables, run:" -ForegroundColor Cyan
Write-Host "   Get-ChildItem Env: | Where-Object { `$_.Name -match 'TEMP|TMP|npm|PUB|GRADLE|ANDROID|MAVEN' }" -ForegroundColor Gray
Write-Host ""

# Ask if user wants to clean up old cache on C drive
Write-Host "Do you want to DELETE old cache on C drive to free up space? (Y/N)" -ForegroundColor Yellow
$cleanup = Read-Host

if ($cleanup -eq 'Y' -or $cleanup -eq 'y') {
    Write-Host ""
    Write-Host "Cleaning up old cache on C drive..." -ForegroundColor Yellow
    
    # Delete npm cache
    if (Test-Path "C:\Users\$env:USERNAME\AppData\Local\npm-cache") {
        Remove-Item -Recurse -Force "C:\Users\$env:USERNAME\AppData\Local\npm-cache" -ErrorAction SilentlyContinue
        Write-Host "  Deleted old npm cache" -ForegroundColor Green
    }
    
    # Delete pub cache
    if (Test-Path "C:\Users\$env:USERNAME\AppData\Local\Pub\Cache") {
        Remove-Item -Recurse -Force "C:\Users\$env:USERNAME\AppData\Local\Pub\Cache" -ErrorAction SilentlyContinue
        Write-Host "  Deleted old Flutter pub cache" -ForegroundColor Green
    }
    
    # Delete temp files
    if (Test-Path "C:\Users\$env:USERNAME\AppData\Local\Temp") {
        Remove-Item -Recurse -Force "C:\Users\$env:USERNAME\AppData\Local\Temp\*" -ErrorAction SilentlyContinue
        Write-Host "  Deleted old temp files" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Cleanup completed!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
