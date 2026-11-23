@echo off
title RE:BOUND (Web Browser Version)
cd /d "%~dp0"
echo ===================================================
echo   Starting RE:BOUND Web Game Server...
echo ===================================================
echo Opening http://localhost:8080/index.html in browser...
start "" "http://localhost:8080/index.html"
python -m http.server 8080