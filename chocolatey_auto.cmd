@echo off
setlocal EnableExtensions

set "FALHAS=0"
set "LOGDIR=%ProgramData%\SenhorContabil\Logs"
set "LOG=%LOGDIR%\Chocolatey-Install.log"

if not exist "%LOGDIR%" mkdir "%LOGDIR%"

echo ==================================================
echo  INSTALACAO DE PROGRAMAS - SENHOR CONTABIL
echo ==================================================
echo [%date% %time%] Inicio da instalacao > "%LOG%"

REM Instala o Chocolatey
echo.
echo [ETAPA] Instalando Chocolatey...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"

set "CHOCO=%ProgramData%\chocolatey\bin\choco.exe"

if not exist "%CHOCO%" (
    echo [ERRO] Chocolatey nao foi instalado.
    echo [%date% %time%] ERRO: Chocolatey nao foi instalado.>> "%LOG%"
    exit /b 1
)

call :Instalar "RustDesk" rustdesk.install
call :Instalar "WinRAR" winrar
call :Instalar "Google Chrome" googlechrome
call :Instalar "KeePass 2" keepass
call :Instalar "Google Drive" googledrive
call :Instalar ".NET 10 SDK" dotnet-10.0-sdk
call :Instalar "Amazon Corretto 8 JRE" corretto8jre
call :Instalar "Notepad++" notepadplusplus
call :Instalar "Visual C++ Redistributables" vcredist-all
call :Instalar "OnlyOffice" onlyoffice

echo.
echo ==================================================
if %FALHAS% GTR 0 (
    echo [FINALIZADO COM %FALHAS% ERRO(S)]
    echo [%date% %time%] Finalizado com %FALHAS% erro(s).>> "%LOG%"
) else (
    echo [FINALIZADO COM SUCESSO]
    echo [%date% %time%] Finalizado com sucesso.>> "%LOG%"
)
echo Log: %LOG%
echo ==================================================

exit /b %FALHAS%

:Instalar
echo.
echo [INSTALANDO] %~1
echo [%date% %time%] Instalando: %~1>> "%LOG%"

"%CHOCO%" install %~2 -y --accept-license

if errorlevel 1 (
    echo [ERRO] Falha ao instalar: %~1
    echo [%date% %time%] ERRO: %~1>> "%LOG%"
    set /a FALHAS+=1
) else (
    echo [OK] Instalado com sucesso: %~1
    echo [%date% %time%] OK: %~1>> "%LOG%"
)

exit /b