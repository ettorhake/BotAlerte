@echo off
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
echo ⏹️  Appuyez sur Ctrl+C pour arrêter
echo.
python universal_monitor.py
goto MENU

:TEST_CONFIG
echo.
echo 🧪 Test de la configuration...
python test_universal.py config.json
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
)
echo.
pause
goto MENU

:MANUAL_TEST
echo.
set /p config_file="Fichier de configuration (config.json): "
if "%config_file%"=="" set config_file=config.json
echo.
echo 🔍 Test manuel avec %config_file%...
python test_universal.py "%config_file%"
echo.
pause
goto MENU

:EXIT
echo.
echo 👋 Au revoir !
timeout /t 2 >nul
exit