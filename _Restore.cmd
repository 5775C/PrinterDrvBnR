@echo off
pushd %~dp0
setlocal EnableDelayedExpansion

:: when folder name include [X], skip

for /f "tokens=* usebackq" %%a in (`dir /b /s _SilentInstall.cmd^|find /v "[X]"`) do (
    pushd "%%~dpa"
    call "%%a"
)

