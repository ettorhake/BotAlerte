@echo off
chcp 65001 > nul
title BotAlerte - Installation automatique

echo.
echo 🤖 BotAlerte - Installation automatique Windows
echo ==============================================
echo.

:: Vérifier les droits administrateur
net session >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ Droits administrateur détectés
) else (
    echo ⚠️ Droits administrateur non détectés
    echo Certaines installations peuvent échouer
)
echo.

:: Vérifier Python
echo 🐍 Vérification de Python 3...
python --version >nul 2>&1
if %errorLevel% == 0 (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo ✅ Python %PYTHON_VERSION% trouvé
    goto :install_deps
)

python3 --version >nul 2>&1
if %errorLevel% == 0 (
    for /f "tokens=2" %%i in ('python3 --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo ✅ Python %PYTHON_VERSION% trouvé
    set PYTHON_CMD=python3
    goto :install_deps
)

echo ❌ Python 3.7+ non détecté
echo.
echo Options d'installation Python :
echo 1. Téléchargement automatique (recommandé)
echo 2. Microsoft Store
echo 3. Installation manuelle
echo.
set /p install_choice="Choisissez (1-3) [1]: "
if "%install_choice%"=="" set install_choice=1

if "%install_choice%"=="1" goto :install_python_auto
if "%install_choice%"=="2" goto :install_python_store
if "%install_choice%"=="3" goto :install_python_manual

:install_python_auto
echo 🌐 Téléchargement de Python...
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.9.18/python-3.9.18-amd64.exe' -OutFile '%TEMP%\python-installer.exe'"
if %errorLevel% neq 0 (
    echo ❌ Échec du téléchargement
    goto :install_python_manual
)

echo 🔧 Installation de Python...
"%TEMP%\python-installer.exe" /quiet InstallAllUsers=1 PrependPath=1
del "%TEMP%\python-installer.exe"

:: Actualiser PATH
call refreshenv.cmd >nul 2>&1

echo ✅ Python installé
echo.
goto :verify_python

:install_python_store
echo 🏪 Ouverture du Microsoft Store...
start ms-windows-store://pdp/?productid=9NRWMJP3717K
echo Installez Python depuis le Store puis relancez ce script
pause
exit /b 1

:install_python_manual
echo 🌐 Ouverture de python.org...
start https://www.python.org/downloads/
echo Téléchargez et installez Python puis relancez ce script
pause
exit /b 1

:verify_python
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ Python toujours non détecté après installation
    echo Redémarrez votre terminal ou ordinateur
    pause
    exit /b 1
)

:install_deps
if not defined PYTHON_CMD set PYTHON_CMD=python

echo.
echo Options d'installation :
echo 1. Installation complète (recommandée)
echo 2. Installation sans Selenium
echo 3. Installation avec environnement virtuel
echo.
set /p dep_choice="Choisissez (1-3) [1]: "
if "%dep_choice%"=="" set dep_choice=1

:: Installation Selenium si nécessaire
if "%dep_choice%"=="2" goto :install_python_deps

echo 🌐 Vérification de Google Chrome...
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
    echo ✅ Google Chrome trouvé
    goto :install_python_deps
)
if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
    echo ✅ Google Chrome trouvé
    goto :install_python_deps
)
if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
    echo ✅ Google Chrome trouvé
    goto :install_python_deps
)

echo ⚠️ Google Chrome non trouvé
echo.
echo Options Chrome :
echo 1. Télécharger automatiquement
echo 2. Installation manuelle
echo 3. Continuer sans Chrome
echo.
set /p chrome_choice="Choisissez (1-3) [1]: "
if "%chrome_choice%"=="" set chrome_choice=1

if "%chrome_choice%"=="1" (
    echo 🌐 Téléchargement de Chrome...
    powershell -Command "Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile '%TEMP%\chrome_installer.exe'"
    if %errorLevel% == 0 (
        echo 🔧 Installation de Chrome...
        "%TEMP%\chrome_installer.exe" /silent /install
        del "%TEMP%\chrome_installer.exe"
        echo ✅ Chrome installé
    ) else (
        echo ⚠️ Échec du téléchargement Chrome
    )
)

if "%chrome_choice%"=="2" (
    echo 🌐 Ouverture de google.com/chrome...
    start https://www.google.com/chrome/
    echo Installez Chrome puis appuyez sur une touche
    pause
)

:install_python_deps
echo.
echo 📦 Installation des dépendances Python...

:: Environnement virtuel si demandé
if "%dep_choice%"=="3" (
    echo 🔧 Création d'un environnement virtuel...
    %PYTHON_CMD% -m venv venv
    call venv\Scripts\activate.bat
    echo ✅ Environnement virtuel activé
    echo 💡 Pour réactiver : venv\Scripts\activate.bat
    echo.
)

:: Mise à jour de pip
echo 📈 Mise à jour de pip...
%PYTHON_CMD% -m pip install --upgrade pip

:: Installation des dépendances
if exist "requirements.txt" (
    echo 📋 Installation depuis requirements.txt...
    %PYTHON_CMD% -m pip install -r requirements.txt
) else (
    echo ⚠️ requirements.txt non trouvé, installation manuelle...
    %PYTHON_CMD% -m pip install requests beautifulsoup4 schedule lxml selenium webdriver-manager
)

echo ✅ Dépendances Python installées

:test_installation
echo.
echo 🧪 Test de l'installation...

%PYTHON_CMD% -c "import requests, bs4, schedule, lxml; print('✅ Dépendances de base OK'); import selenium; print('✅ Selenium OK'); print('✅ Installation validée')" 2>nul
if %errorLevel% neq 0 (
    echo ❌ Erreur lors du test
    pause
    exit /b 1
)

:: Vérifier les fichiers
if exist "config.json" if exist "universal_monitor.py" (
    echo ✅ Fichiers du bot détectés
) else (
    echo ⚠️ Fichiers du bot non trouvés
)

:initial_setup
echo.
echo ⚙️ Configuration initiale...

:: Créer le répertoire de logs
if not exist "logs" mkdir logs
echo ✅ Répertoire de logs créé

echo.
echo 🎉 Installation terminée avec succès !
echo.
echo 📋 Prochaines étapes :
echo 1. Configurez votre email : python setup_email.py
echo 2. Modifiez config.json avec vos sites à surveiller
echo 3. Testez : python test_universal.py config.json
echo 4. Lancez : start_bot.bat
echo.
echo 💡 Ou utilisez le menu interactif : start_bot.bat
echo.

pause