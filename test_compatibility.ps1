# Script de test de compatibilité Python pour Windows
# Équivalent PowerShell de test_compatibility.sh

param()

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

function Test-PythonVersion {
    param([string]$PythonCommand)
    
    try {
        $version = & $PythonCommand -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $parts = $version.Split('.')
            $major = [int]$parts[0]
            $minor = [int]$parts[1]
            
            if ($major -gt 3 -or ($major -eq 3 -and $minor -ge 7)) {
                return $version
            }
        }
    } catch {
        return $null
    }
    return $null
}

Write-Host ""
Write-Info "🧪 Test de compatibilité Python Windows"
Write-Host "========================================"
Write-Host ""

# Test des différentes commandes Python
Write-Info "🔍 Recherche des versions Python disponibles..."
Write-Host ""

$PythonCmd = ""
$PythonVersion = ""

# Essayer python d'abord
if ($version = Test-PythonVersion "python") {
    $PythonCmd = "python"
    Write-Success "✅ Python $version détecté avec 'python' (compatible)"
}
# Puis essayer python3
elseif ($version = Test-PythonVersion "python3") {
    $PythonCmd = "python3"
    Write-Success "✅ Python $version détecté avec 'python3' (compatible)"
}
else {
    Write-Error "❌ Python 3.7+ non trouvé"
    Write-Host ""
    Write-Host "Versions Python trouvées :"
    
    # Essayer de montrer les versions disponibles
    try {
        $pythonVersion = & python --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  - python: $pythonVersion"
        } else {
            Write-Host "  - python: non trouvé"
        }
    } catch {
        Write-Host "  - python: non trouvé"
    }
    
    try {
        $python3Version = & python3 --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  - python3: $python3Version"
        } else {
            Write-Host "  - python3: non trouvé"
        }
    } catch {
        Write-Host "  - python3: non trouvé"
    }
    
    Write-Host ""
    Write-Host "Pour installer Python :"
    Write-Host "1. Téléchargez depuis https://www.python.org/downloads/"
    Write-Host "2. Ou utilisez: .\install.ps1"
    Write-Host "3. Ou via Microsoft Store: Python 3.x"
    
    exit 1
}

$PythonVersion = $version
Write-Host ""

# Test des dépendances
Write-Info "📦 Test des dépendances..."
Write-Host ""

$missingDeps = @()

try {
    & $PythonCmd -c "import requests" 2>$null
    if ($LASTEXITCODE -ne 0) { $missingDeps += "requests" }
} catch { $missingDeps += "requests" }

try {
    & $PythonCmd -c "import bs4" 2>$null
    if ($LASTEXITCODE -ne 0) { $missingDeps += "beautifulsoup4" }
} catch { $missingDeps += "beautifulsoup4" }

try {
    & $PythonCmd -c "import schedule" 2>$null
    if ($LASTEXITCODE -ne 0) { $missingDeps += "schedule" }
} catch { $missingDeps += "schedule" }

try {
    & $PythonCmd -c "import lxml" 2>$null
    if ($LASTEXITCODE -ne 0) { $missingDeps += "lxml" }
} catch { $missingDeps += "lxml" }

# Test Selenium (optionnel)
$seleniumAvailable = $false
try {
    & $PythonCmd -c "import selenium" 2>$null
    if ($LASTEXITCODE -eq 0) {
        $seleniumAvailable = $true
        Write-Success "✅ selenium - disponible"
    } else {
        Write-Warning "⚠️ selenium - non disponible (optionnel)"
    }
} catch {
    Write-Warning "⚠️ selenium - non disponible (optionnel)"
}

try {
    & $PythonCmd -c "from selenium import webdriver" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ selenium.webdriver - disponible"
    } else {
        Write-Warning "⚠️ selenium.webdriver - non disponible (optionnel)"
    }
} catch {
    Write-Warning "⚠️ selenium.webdriver - non disponible (optionnel)"
}

try {
    & $PythonCmd -c "from webdriver_manager.chrome import ChromeDriverManager" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ webdriver-manager - disponible"
    } else {
        Write-Warning "⚠️ webdriver-manager - non disponible (optionnel)"
    }
} catch {
    Write-Warning "⚠️ webdriver-manager - non disponible (optionnel)"
}

Write-Host ""

# Résumé
if ($missingDeps.Count -eq 0) {
    Write-Success "🎉 Toutes les dépendances de base sont installées !"
    Write-Host ""
    Write-Host "Configuration détectée :"
    Write-Host "  - Commande Python: $PythonCmd"
    Write-Host "  - Version: $PythonVersion"
    Write-Host "  - Selenium: $(if ($seleniumAvailable) { '✅ disponible' } else { '❌ non disponible' })"
    Write-Host ""
    Write-Success "✅ Le bot devrait fonctionner correctement"
} else {
    Write-Error "❌ Dépendances manquantes: $($missingDeps -join ', ')"
    Write-Host ""
    Write-Host "Pour installer les dépendances manquantes :"
    Write-Host "  pip install $($missingDeps -join ' ')"
    Write-Host ""
    Write-Host "Ou utilisez le script d'installation :"
    Write-Host "  .\install.ps1"
}

Write-Host ""
Write-Info "🔧 Pour tester la configuration complète :"
Write-Host "  $PythonCmd test_universal.py config.json"
Write-Host ""