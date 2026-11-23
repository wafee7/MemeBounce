@echo off
title Launching MEMEBOUNCE...
cd /d "%~dp0"
echo ===================================================
echo     MEMEBOUNCE
echo     Featuring: Froggy, Bunny, Mushroom & Detective!
echo ===================================================
start "" "C:\Users\Administrator\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe" --path "%~dp0source\decompiled_full"
