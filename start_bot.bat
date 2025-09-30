@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title Bot de Surveillance Universel
color 0A

echo.
echo ========================================
echo    🤖 BOT DE SURVEILLANCE UNIVERSEL
echo ========================================
echo.

cd /d "%~dp0"

:MENU
echo Choisissez une option:
echo.
echo [1] 🚀 Démarrer le bot (surveillance continue)
echo [2] 🧪 Tester la configuration
echo [3] 📧 Configurer l'email
echo [4] ⚙️  Créer une nouvelle configuration
echo [5] 📋 Voir les configurations existantes
echo [6] 🔍 Test manuel de recherche
echo [7] ❌ Quitter
echo.
set /p choice="Votre choix (1-7): "

if "%choice%"=="1" goto START_BOT
if "%choice%"=="2" goto TEST_CONFIG
if "%choice%"=="3" goto SETUP_EMAIL
if "%choice%"=="4" goto CREATE_CONFIG
if "%choice%"=="5" goto LIST_CONFIGS
if "%choice%"=="6" goto MANUAL_TEST
if "%choice%"=="7" goto EXIT

echo Choix invalide, essayez encore.
goto MENU

:START_BOT
echo.
echo 🚀 Démarrage du bot de surveillance...
echo.
call :SELECT_CONFIG
if "%selected_config%"=="" goto MENU
echo 💡 Configuration: %selected_config%
echo ⏹️  Appuyez sur Ctrl+C pour arrêter
echo.
python universal_monitor.py "%selected_config%"
goto MENU

:TEST_CONFIG
echo.
echo 🧪 Test de la configuration...
echo.
call :SELECT_CONFIG
if "%selected_config%"=="" goto MENU
echo 💡 Test de: %selected_config%
echo.
python test_universal.py "%selected_config%"
echo.
pause
goto MENU

:SETUP_EMAIL
echo.
echo 📧 Configuration de l'email...
python setup_email.py
echo.
pause
goto MENU

:CREATE_CONFIG
echo.
echo ⚙️  Création d'une nouvelle configuration...
python config_generator.py
echo.
pause
goto MENU

:LIST_CONFIGS
echo.
echo 📋 Configurations disponibles:
echo.
for %%f in (*.json) do (
    echo 📄 %%f
    rem Essayer d'extraire le nom du monitor (simplifié)
    findstr /C:"monitor_name" "%%f" >nul 2>&1
    if not errorlevel 1 (
        for /f "tokens=2 delims=:" %%a in ('findstr /C:"monitor_name" "%%f"') do (
            set monitor_name=%%a
            set monitor_name=!monitor_name:"=!
            set monitor_name=!monitor_name: =!
            set monitor_name=!monitor_name:,=!
            if not "!monitor_name!"=="" echo    📋 !monitor_name!
        )
    )
    echo.
)
pause
goto MENU

:MANUAL_TEST
echo.
echo 🔍 Test manuel de recherche...
echo.
call :SELECT_CONFIG
if "%selected_config%"=="" goto MENU
echo � Test manuel avec: %selected_config%
echo.
python test_universal.py "%selected_config%"
echo.
pause
goto MENU

:SELECT_CONFIG
set selected_config=
echo 📋 Configurations disponibles:
echo.
set /a count=0
for %%f in (*.json) do (
    set /a count+=1
    echo [!count!] 📄 %%f
    set config!count!=%%f
)
echo.
if %count%==0 (
    echo ❌ Aucune configuration trouvée
    echo 💡 Créez d'abord une configuration (option 4)
    pause
    exit /b
)
echo [0] 🔙 Retour au menu
echo.
set /p choice="Choisissez une configuration (0-%count%) ou Entrée pour config.json: "

if "%choice%"=="" (
    if exist "config.json" (
        set selected_config=config.json
        exit /b
    ) else (
        echo ❌ config.json non trouvé
        pause
        exit /b
    )
)

if "%choice%"=="0" exit /b

if %choice% geq 1 if %choice% leq %count% (
    call set selected_config=%%config%choice%%%
    exit /b
)

echo ❌ Choix invalide
pause
exit /b

:EXIT
echo.
echo 👋 Au revoir !
timeout /t 2 >nul
exit