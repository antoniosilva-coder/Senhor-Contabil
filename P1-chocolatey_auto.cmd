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
call :InstalarGoogleDrive
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
set "CHOCO_EXIT=%ERRORLEVEL%"

if not "%CHOCO_EXIT%"=="0" (
    echo [ERRO] Falha ao instalar: %~1 ^(codigo %CHOCO_EXIT%^)
    echo [%date% %time%] ERRO: %~1 - codigo %CHOCO_EXIT%>> "%LOG%"
    set /a FALHAS+=1
) else (
    echo [OK] Instalado com sucesso: %~1
    echo [%date% %time%] OK: %~1>> "%LOG%"
)

exit /b

:InstalarGoogleDrive
echo.
echo [INSTALANDO] Google Drive
echo [%date% %time%] Instalando: Google Drive>> "%LOG%"

set "GDRIVE=%TEMP%\GoogleDriveSetup.exe"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; Invoke-WebRequest -UseBasicParsing -Uri 'https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe' -OutFile '%GDRIVE%'; $sig=Get-AuthenticodeSignature '%GDRIVE%'; if ($sig.Status -ne 'Valid' -or $sig.SignerCertificate.Subject -notmatch 'Google LLC') { throw 'Assinatura digital do Google Drive invalida' }"
set "GDRIVE_DOWNLOAD_EXIT=%ERRORLEVEL%"

if not "%GDRIVE_DOWNLOAD_EXIT%"=="0" (
    echo [ERRO] Falha ao baixar ou validar o Google Drive ^(codigo %GDRIVE_DOWNLOAD_EXIT%^)
    echo [%date% %time%] ERRO: Google Drive - download ou assinatura invalida - codigo %GDRIVE_DOWNLOAD_EXIT%>> "%LOG%"
    if exist "%GDRIVE%" del /q "%GDRIVE%" >nul 2>&1
    set /a FALHAS+=1
    exit /b
)

start "" /wait "%GDRIVE%" --silent --desktop_shortcut --skip_launch_new
set "GDRIVE_INSTALL_EXIT=%ERRORLEVEL%"

if exist "%GDRIVE%" del /q "%GDRIVE%" >nul 2>&1

if not "%GDRIVE_INSTALL_EXIT%"=="0" if not "%GDRIVE_INSTALL_EXIT%"=="3010" (
    echo [ERRO] Falha ao instalar: Google Drive ^(codigo %GDRIVE_INSTALL_EXIT%^)
    echo [%date% %time%] ERRO: Google Drive - codigo %GDRIVE_INSTALL_EXIT%>> "%LOG%"
    set /a FALHAS+=1
) else (
    echo [OK] Instalado com sucesso: Google Drive
    echo [%date% %time%] OK: Google Drive>> "%LOG%"
)

exit /b
