@echo off
title MEMEBOUNCE (Native Godot)
cd /d "%~dp0"
echo Launching MEMEBOUNCE with Godot 4.7.2 native engine...
start "" "C:\Users\Administrator\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe" --path "%~dp0..\source\decompiled_full"