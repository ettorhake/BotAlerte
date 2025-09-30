#!/bin/bash

# Script de test pour vérifier la compatibilité Python
# Test sans utiliser bc et avec gestion des versions Python

echo "🧪 Test de compatibilité Python"
echo "==============================="
echo ""

# Test de la fonction check_python_version
check_python_version() {
    local python_cmd="$1"
    
    if ! command -v "$python_cmd" &> /dev/null; then
        return 1
    fi
    
    # Obtenir version major.minor
    local version_output
    version_output=$($python_cmd -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Extraire major et minor
    local major_version=$(echo "$version_output" | cut -d'.' -f1)
    local minor_version=$(echo "$version_output" | cut -d'.' -f2)
    
    # Vérifier si >= 3.7
    if [[ $major_version -gt 3 ]] || [[ $major_version -eq 3 && $minor_version -ge 7 ]]; then
        echo "$version_output"
        return 0
    else
        return 1
    fi
}

# Test des différentes commandes Python
echo "🔍 Recherche des versions Python disponibles..."
echo ""

PYTHON_CMD=""
python_version=""

# Essayer python3 d'abord
if python_version=$(check_python_version "python3"); then
    PYTHON_CMD="python3"
    echo "✅ Python $python_version détecté avec 'python3' (compatible)"
# Puis essayer python
elif python_version=$(check_python_version "python"); then
    PYTHON_CMD="python"
    echo "✅ Python $python_version détecté avec 'python' (compatible)"
else
    echo "❌ Python 3.7+ non trouvé"
    echo ""
    echo "Versions Python trouvées :"
    
    # Essayer de montrer les versions disponibles
    if command -v python3 &> /dev/null; then
        python3_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "erreur")
        echo "  - python3: $python3_version"
    else
        echo "  - python3: non trouvé"
    fi
    
    if command -v python &> /dev/null; then
        python_version_alt=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "erreur")
        echo "  - python: $python_version_alt"
    else
        echo "  - python: non trouvé"
    fi
    
    exit 1
fi

echo ""

# Test des dépendances
echo "📦 Test des dépendances..."
echo ""

missing_deps=()

if ! $PYTHON_CMD -c "import requests" 2>/dev/null; then
    missing_deps+=("requests")
fi

if ! $PYTHON_CMD -c "import bs4" 2>/dev/null; then
    missing_deps+=("beautifulsoup4")
fi

if ! $PYTHON_CMD -c "import schedule" 2>/dev/null; then
    missing_deps+=("schedule")
fi

if ! $PYTHON_CMD -c "import lxml" 2>/dev/null; then
    missing_deps+=("lxml")
fi

# Test Selenium (optionnel)
selenium_available=false
if $PYTHON_CMD -c "import selenium" 2>/dev/null; then
    selenium_available=true
    echo "✅ selenium - disponible"
else
    echo "⚠️ selenium - non disponible (optionnel)"
fi

if $PYTHON_CMD -c "from selenium import webdriver" 2>/dev/null; then
    echo "✅ selenium.webdriver - disponible"
else
    echo "⚠️ selenium.webdriver - non disponible (optionnel)"
fi

if $PYTHON_CMD -c "from webdriver_manager.chrome import ChromeDriverManager" 2>/dev/null; then
    echo "✅ webdriver-manager - disponible"
else
    echo "⚠️ webdriver-manager - non disponible (optionnel)"
fi

echo ""

# Résumé
if [ ${#missing_deps[@]} -eq 0 ]; then
    echo "🎉 Toutes les dépendances de base sont installées !"
    echo ""
    echo "Configuration détectée :"
    echo "  - Commande Python: $PYTHON_CMD"
    echo "  - Version: $python_version"
    echo "  - Selenium: $([ "$selenium_available" = true ] && echo "✅ disponible" || echo "❌ non disponible")"
    echo ""
    echo "✅ Le bot devrait fonctionner correctement"
else
    echo "❌ Dépendances manquantes: ${missing_deps[*]}"
    echo ""
    echo "Pour installer les dépendances manquantes :"
    echo "  pip install ${missing_deps[*]}"
    echo ""
    echo "Ou utilisez le script d'installation :"
    echo "  ./install.sh"
fi

echo ""
echo "🔧 Pour tester la configuration complète :"
echo "  $PYTHON_CMD test_universal.py config.json"