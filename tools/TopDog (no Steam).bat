@echo off
rem Launches the game with Steam switched off (no lobby, no overlay). One experiment:
rem if the controller works here and not in the normal launch, Steam Input has it.
cd /d "%~dp0"
start "" "TopDog.exe" -- --no-steam
