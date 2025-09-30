# BotAlerte - Script d'installation Windows PowerShell
# Installation automatique des dépendances et configuration

param(
    [switch]$Quick,
    [switch]$Help,
    [switch]$Venv
)

# Couleurs PowerShell
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green $args }
function Write-Warning { Write-ColorOutput Yellow $args }
function Write-Error { Write-ColorOutput Red $args }
function Write-Info { Write-ColorOutput Blue $args }

function Show-Help {
    Write-Host ""
    Write-Host "BotAlerte - Installation automatique Windows" -ForegroundColor Blue
    Write-Host "==========================================="
    Write-Host ""
    Write-Host "Usage: .\install.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Help      Afficher cette aide"
    Write-Host "  -Quick     Installation rapide sans Selenium"
    Write-Host "  -Venv      Installation avec environnement virtuel"
    Write-Host ""
    Write-Host "Exemples:"
    Write-Host "  .\install.ps1              # Installation complète"
    Write-Host "  .\install.ps1 -Quick       # Sans Selenium"
    Write-Host "  .\install.ps1 -Venv        # Avec environnement virtuel"
    Write-Host ""
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Python {
    Write-Info "🐍 Vérification de Python 3..."
    
    # Vérifier si Python est déjà installé
    try {
        $pythonVersion = python --version 2>$null
        if ($pythonVersion -match "Python 3\.([7-9]|\d{2})") {
            Write-Success "✅ $pythonVersion déjà installé"
            return $true
        }
    } catch {}
    
    # Vérifier python3
    try {
        $pythonVersion = python3 --version 2>$null
        if ($pythonVersion -match "Python 3\.([7-9]|\d{2})") {
            Write-Success "✅ $pythonVersion déjà installé"
            # Créer un alias python si nécessaire
            if (!(Get-Command python -ErrorAction SilentlyContinue)) {
                Write-Warning "💡 Création d'un alias 'python' pour 'python3'"
                Set-Alias -Name python -Value python3 -Scope Global
            }
            return $true
        }
    } catch {}
    
    Write-Warning "📦 Python 3.7+ non trouvé, installation requise..."
    Write-Host ""
    Write-Host "Options d'installation Python :"
    Write-Host "1. Téléchargement automatique depuis python.org (recommandé)"
    Write-Host "2. Installation via Microsoft Store"
    Write-Host "3. Installation manuelle"
    Write-Host ""
    
    $choice = Read-Host "Choisissez (1-3) [1]"
    if ([string]::IsNullOrEmpty($choice)) { $choice = "1" }
    
    switch ($choice) {
        "1" {
            Write-Info "🌐 Téléchargement de Python depuis python.org..."
            $pythonUrl = "https://www.python.org/ftp/python/3.9.18/python-3.9.18-amd64.exe"
            $pythonInstaller = "$env:TEMP\python-installer.exe"
            
            try {
                Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller
                Write-Info "🔧 Installation de Python..."
                Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
                Remove-Item $pythonInstaller -Force
                
                # Actualiser PATH
                $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
                
                Write-Success "✅ Python installé avec succès"
                return $true
            } catch {
                Write-Error "❌ Échec du téléchargement/installation automatique"
                return $false
            }
        }
        "2" {
            Write-Info "🏪 Ouverture du Microsoft Store..."
            Start-Process "ms-windows-store://pdp/?productid=9NRWMJP3717K"
            Write-Warning "Installez Python depuis le Store puis relancez ce script"
            return $false
        }
        "3" {
            Write-Info "🌐 Ouverture de python.org..."
            Start-Process "https://www.python.org/downloads/"
            Write-Warning "Téléchargez et installez Python puis relancez ce script"
            return $false
        }
        default {
            Write-Error "❌ Choix invalide"
            return $false
        }
    }
}

function Install-SeleniumDeps {
    Write-Info "🌐 Installation des dépendances Selenium..."
    
    # Vérifier Chrome
    $chromeLocations = @(
        "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe"
    )
    
    $chromeFound = $false
    foreach ($location in $chromeLocations) {
        if (Test-Path $location) {
            Write-Success "✅ Google Chrome trouvé : $location"
            $chromeFound = $true
            break
        }
    }
    
    if (-not $chromeFound) {
        Write-Warning "⚠️ Google Chrome non trouvé"
        Write-Host ""
        Write-Host "Options pour Chrome :"
        Write-Host "1. Télécharger et installer automatiquement"
        Write-Host "2. Installation manuelle"
        Write-Host "3. Continuer sans Chrome (peut causer des erreurs)"
        Write-Host ""
        
        $choice = Read-Host "Choisissez (1-3) [1]"
        if ([string]::IsNullOrEmpty($choice)) { $choice = "1" }
        
        switch ($choice) {
            "1" {
                Write-Info "🌐 Téléchargement de Chrome..."
                $chromeUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
                $chromeInstaller = "$env:TEMP\chrome_installer.exe"
                
                try {
                    Invoke-WebRequest -Uri $chromeUrl -OutFile $chromeInstaller
                    Write-Info "🔧 Installation de Chrome..."
                    Start-Process -FilePath $chromeInstaller -ArgumentList "/silent /install" -Wait
                    Remove-Item $chromeInstaller -Force
                    Write-Success "✅ Chrome installé"
                } catch {
                    Write-Warning "⚠️ Échec de l'installation automatique de Chrome"
                }
            }
            "2" {
                Write-Info "🌐 Ouverture de google.com/chrome..."
                Start-Process "https://www.google.com/chrome/"
                Read-Host "Installez Chrome puis appuyez sur Entrée"
            }
            "3" {
                Write-Warning "⚠️ Continuons sans Chrome..."
            }
        }
    }
    
    Write-Success "✅ Dépendances Selenium vérifiées"
}

function Install-PythonDeps {
    param([switch]$UseVenv)
    
    Write-Info "📦 Installation des dépendances Python..."
    
    # Environnement virtuel si demandé
    if ($UseVenv) {
        Write-Info "🔧 Création d'un environnement virtuel..."
        python -m venv venv
        
        # Activer l'environnement virtuel
        & ".\venv\Scripts\Activate.ps1"
        Write-Success "✅ Environnement virtuel activé"
        Write-Info "💡 Pour réactiver : .\venv\Scripts\Activate.ps1"
    }
    
    # Mise à jour de pip
    Write-Info "📈 Mise à jour de pip..."
    python -m pip install --upgrade pip
    
    # Installation des dépendances
    if (Test-Path "requirements.txt") {
        Write-Info "📋 Installation depuis requirements.txt..."
        python -m pip install -r requirements.txt
        Write-Success "✅ Dépendances Python installées"
    } else {
        Write-Warning "⚠️ requirements.txt non trouvé, installation manuelle..."
        python -m pip install requests beautifulsoup4 schedule lxml selenium webdriver-manager
        Write-Success "✅ Dépendances de base installées"
    }
}

function Test-Installation {
    Write-Info "🧪 Test de l'installation..."
    
    # Test des imports Python
    $testScript = @"
try:
    import requests, bs4, schedule, lxml
    print('✅ Dépendances de base OK')
    
    try:
        import selenium
        from selenium import webdriver
        print('✅ Selenium OK')
    except ImportError:
        print('⚠️ Selenium non disponible')
        
    print('✅ Installation validée')
except Exception as e:
    print(f'❌ Erreur: {e}')
    exit(1)
"@
    
    try {
        $result = python -c $testScript
        Write-Host $result
    } catch {
        Write-Error "❌ Erreur lors du test"
        return $false
    }
    
    # Test des fichiers
    if ((Test-Path "config.json") -and (Test-Path "universal_monitor.py")) {
        Write-Success "✅ Fichiers du bot détectés"
    } else {
        Write-Warning "⚠️ Fichiers du bot non trouvés"
    }
    
    return $true
}

function Initialize-Setup {
    Write-Info "⚙️ Configuration initiale..."
    
    # Créer le répertoire de logs
    if (!(Test-Path "logs")) {
        New-Item -ItemType Directory -Name "logs" | Out-Null
        Write-Success "✅ Répertoire de logs créé"
    }
    
    Write-Host ""
    Write-Success "🎉 Installation terminée avec succès !"
    Write-Host ""
    Write-Info "📋 Prochaines étapes :"
    Write-Host "1. Configurez votre email : python setup_email.py"
    Write-Host "2. Modifiez config.json avec vos sites à surveiller"
    Write-Host "3. Testez : python test_universal.py config.json"
    Write-Host "4. Lancez : .\start_bot.bat"
    Write-Host ""
    Write-Warning "💡 Ou utilisez le menu interactif : .\start_bot.bat"
}

function Main {
    Write-Host ""
    Write-Info "🤖 BotAlerte - Installation automatique Windows"
    Write-Host "=============================================="
    Write-Host ""
    
    # Vérifier les permissions administrateur pour certaines installations
    if (!(Test-Administrator)) {
        Write-Warning "⚠️ Droits administrateur non détectés"
        Write-Host "Certaines installations peuvent échouer sans droits admin"
        Write-Host ""
    }
    
    if (-not $Quick -and -not $Venv) {
        Write-Host "Options d'installation :"
        Write-Host "1. Installation complète (recommandée)"
        Write-Host "2. Installation sans Selenium"
        Write-Host "3. Installation avec environnement virtuel"
        Write-Host ""
        $choice = Read-Host "Choisissez (1-3) [1]"
        if ([string]::IsNullOrEmpty($choice)) { $choice = "1" }
        
        switch ($choice) {
            "2" { $Quick = $true }
            "3" { $Venv = $true }
            default { }  # Installation complète par défaut
        }
    }
    
    Write-Host ""
    
    # Installation de Python
    if (!(Install-Python)) {
        Write-Error "❌ Installation de Python échouée"
        return
    }
    
    # Installation Selenium si demandé
    if (-not $Quick) {
        Install-SeleniumDeps
    }
    
    # Installation des dépendances Python
    if ($Venv) {
        Install-PythonDeps -UseVenv
    } else {
        Install-PythonDeps
    }
    
    # Test et configuration
    if (Test-Installation) {
        Initialize-Setup
    } else {
        Write-Error "❌ Test d'installation échoué"
    }
}

# Traitement des arguments
if ($Help) {
    Show-Help
    exit 0
}

if ($Quick) {
    Write-Host ""
    Write-Info "🚀 Installation rapide sans Selenium"
    Write-Host "===================================="
    Write-Host ""
    
    if (Install-Python) {
        Install-PythonDeps
        if (Test-Installation) {
            Initialize-Setup
        }
    }
    exit 0
}

if ($Venv) {
    Write-Host ""
    Write-Info "🔧 Installation avec environnement virtuel"
    Write-Host "=========================================="
    Write-Host ""
    
    if (Install-Python) {
        Install-SeleniumDeps
        Install-PythonDeps -UseVenv
        if (Test-Installation) {
            Initialize-Setup
        }
    }
    exit 0
}

# Installation par défaut
Main