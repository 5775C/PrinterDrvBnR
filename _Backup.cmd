@echo off
pushd %~dp0
setlocal EnableDelayedExpansion
::Don't close when error occur (debug only)

::if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )

:: Export when ping test success only? 
SET PingSuccessOnly=0

set TmpStr=cd
for /f "tokens=1,2,3,4,* delims=, usebackq" %%a in (`wmic printer get name^, drivername^, portname^, status /format:csv`) do (
   set DefualtPrinter=0
   set PortCheck=0
   set OutputDir=0
   set drvinf=
   set infpath=
   set PrnName=%%c
   set Driver=%%b
   set Port=%%d
   set Port=!Port: =!
   set Port=!Port:IP_=!
   set Port=!Port:IP=!
   set Port=!Port:_=.!
   echo !port!|find "."&&set "PortCheck=1"
   echo !port!|find /i "USB"&&set "PortCheck=1"
   echo !Driver!|find /i "Microsoft"&&set "PortCheck=0"
   IF "!PortCheck!" EQU "1" for /F "skip=2 delims=" %%i in ('reg query "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" /v Device') do echo %%i|find /i "!PrnName!">nul&&set DefualtPrinter=1
   IF "!PortCheck!" EQU "1" IF "!DefualtPrinter!" EQU "0" ping !port! -n 1|findstr TTL&&set "OutputDir=%CD%\!Driver!-!Port!" 
   IF "!PortCheck!" EQU "1" IF "!DefualtPrinter!" EQU "0" ping !port! -n 1|findstr TTL||set "OutputDir=%CD%\_[X]!Driver!-!Port!"
   IF "!PortCheck!" EQU "1" IF "!DefualtPrinter!" EQU "1" ping !port! -n 1|findstr TTL&&set "OutputDir=%CD%\_[¡î]!Driver!-!Port!" 
   IF "!PortCheck!" EQU "1" IF "!DefualtPrinter!" EQU "1" ping !port! -n 1|findstr TTL||set "OutputDir=%CD%\_[¡î][X]!Driver!-!Port!"
   IF "!PingSuccessOnly!" EQU "1" IF "!OutputDir!" EQU "%CD%\_[X]!Driver!-!Port!" set PortCheck=0
   IF "!PingSuccessOnly!" EQU "1" IF "!OutputDir!" EQU "%CD%\_[¡î][X][!Driver!-!Port!" set PortCheck=0
   IF "!PortCheck!" EQU "1" for /f "tokens=* usebackq skip=3" %%z in (`powershell -command ^"get-printerdriver ""!Driver!"""^^|select Infpath"`) DO (
       SET "infpath=%%~dpz"
       set "infpath=!infpath:~0,-1!"
       SET "DrvInf=%%~nxz"
   )
   IF "!PortCheck!" EQU "1" ROBOCOPY /E "!infpath!" "!OutputDir!"
   IF "!PortCheck!" EQU "1" ECHO CSCRIPT "C:\Windows\System32\Printing_Admin_Scripts\ko-KR\prnport.vbs" -a -r IP_!PORT! -h !PORT! -md -o raw -y public -i 1 -n 9100>>"!OutputDir!\_SilentInstall.CMD"
   IF "!DefualtPrinter!" EQU "0" IF "!PortCheck!" EQU "1" ECHO printui.exe /if /b "!PrnName!" /f "%%!TmpStr!%%\!DrvInf!" /r "IP_!PORT!" /m "!Driver!">>"!OutputDir!\_SilentInstall.CMD"
   IF "!DefualtPrinter!" EQU "1" IF "!PortCheck!" EQU "1" ECHO printui.exe /if /b "!PrnName!" /f "%%!TmpStr!%%\!DrvInf!" /r "IP_!PORT!" /m "!Driver!" /y>>"!OutputDir!\_SilentInstall.CMD"
)

