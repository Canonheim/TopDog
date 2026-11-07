@echo off
setlocal
rem ============================================================
rem  Top Your Pals depot upload. Lifted from Golemheim's (see
rem  docs/PROVENANCE.md). Run this YOURSELF: steamcmd asks for your
rem  Steamworks login, password and Steam Guard code. Uploads land as
rem  builds on the partner site; going live is a manual click there.
rem
rem  SET THESE once the Steamworks app exists (Parker makes it: the
rem  Steam Direct fee). Until then this refuses to run: 480 is Valve's
rem  shared dev app and can't take uploads.
rem ============================================================
set "APPID=0"
set "DEPOTID=0"
cd /d "%~dp0"
if "%APPID%"=="0" (
    echo [!] No app ID yet. Make the Steamworks app, then set APPID and
    echo     DEPOTID at the top of this file ^(the depot is usually APPID+1^)
    echo     and put the same APPID in net\net.gd STEAM_APP_ID.
    goto :fail
)

set "BUILDS=..\..\builds"
set "STAGE=%BUILDS%\steam_content"
if not exist "%BUILDS%\TopYourPals.exe" (
    echo [!] builds\TopYourPals.exe not found - export the Windows Desktop preset ^(release^) first.
    goto :fail
)
if not exist "%BUILDS%\libgodotsteam.windows.template_release.x86_64.dll" (
    echo [!] The RELEASE GodotSteam DLL is missing beside the exe - the last export was DEBUG.
    goto :fail
)

rem ---- stage exactly what ships (THE FILE-LIST LAW: a DLL not listed here
rem ---- ships missing, silently) ----------------------------------------
if exist "%STAGE%" rd /s /q "%STAGE%"
mkdir "%STAGE%"
copy /b /y "%BUILDS%\TopYourPals.exe" "%STAGE%\" >nul || goto :copyfail
copy /b /y "%BUILDS%\steam_api64.dll" "%STAGE%\" >nul || goto :copyfail
copy /b /y "%BUILDS%\libgodotsteam.windows.template_release.x86_64.dll" "%STAGE%\" >nul || goto :copyfail
echo [ok] staged builds\steam_content

if not exist "steamcmd\steamcmd.exe" (
    echo [..] steamcmd not found - downloading from Valve ^(~5 MB^)...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "Invoke-WebRequest 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip' -OutFile 'steamcmd.zip'; Expand-Archive 'steamcmd.zip' 'steamcmd' -Force; Remove-Item 'steamcmd.zip'" || goto :fail
)
if not exist "steamcmd\.gdignore" type nul > "steamcmd\.gdignore"

powershell -NoProfile -Command "(Get-Content 'app_build_template.vdf') -replace 'APPID','%APPID%' -replace 'DEPOTID','%DEPOTID%' | Set-Content 'app_build.vdf'"
set /p STEAMUSER=Steamworks login name:
if "%STEAMUSER%"=="" goto :fail
steamcmd\steamcmd.exe +login "%STEAMUSER%" +run_app_build "%~dp0app_build.vdf" +quit
if errorlevel 1 goto :fail
echo.
echo [ok] Build uploaded. Partner site ^> SteamPipe ^> Builds ^> set it live on a branch.
pause
exit /b 0

:copyfail
echo [!] copy into steam_content failed
:fail
echo.
pause
exit /b 1
