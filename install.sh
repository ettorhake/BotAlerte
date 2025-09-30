#!/bin/bash

# BotAlerte - Script d'installation rapide Linux/Mac
# Installation automatique des dépendances et configuration

set -e  # Arrêter en cas d'erreur

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🤖 BotAlerte - Installation automatique${NC}"
echo "========================================"
echo ""

# Fonction pour détecter l'OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            OS="ubuntu"
        elif command -v yum &> /dev/null; then
            OS="centos"
        elif command -v pacman &> /dev/null; then
            OS="arch"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
    
    echo -e "${GREEN}✅ OS détecté: $OS${NC}"
}

# Installation de Python
install_python() {
    echo -e "${BLUE}🐍 Vérification de Python 3...${NC}"
    
    if command -v python3 &> /dev/null; then
        python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        echo -e "${GREEN}✅ Python $python_version déjà installé${NC}"
        return
    fi
    
    echo -e "${YELLOW}📦 Installation de Python 3...${NC}"
    
    case $OS in
        "ubuntu")
            sudo apt update
            sudo apt install -y python3 python3-pip python3-venv bc
            ;;
        "centos")
            sudo yum install -y python3 python3-pip bc
            ;;
        "arch")
            sudo pacman -S python python-pip bc
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                brew install python3
            else
                echo -e "${RED}❌ Homebrew non trouvé. Installez Python 3 manuellement.${NC}"
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}❌ OS non supporté pour l'installation automatique${NC}"
            echo "Veuillez installer Python 3.7+ manuellement"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Python 3 installé${NC}"
}

# Installation des dépendances système pour Selenium
install_selenium_deps() {
    echo -e "${BLUE}🌐 Installation des dépendances Selenium...${NC}"
    
    case $OS in
        "ubuntu")
            # Dépendances pour Chrome/Chromium
            sudo apt install -y wget gnupg software-properties-common
            
            # Installation de Chrome
            if ! command -v google-chrome &> /dev/null; then
                echo -e "${YELLOW}📦 Installation de Google Chrome...${NC}"
                wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
                echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
                sudo apt update
                sudo apt install -y google-chrome-stable
            fi
            ;;
        "centos")
            sudo yum install -y chromium
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                if ! command -v google-chrome &> /dev/null; then
                    echo -e "${YELLOW}📦 Installation de Google Chrome...${NC}"
                    brew install --cask google-chrome
                fi
            fi
            ;;
    esac
    
    echo -e "${GREEN}✅ Dépendances Selenium prêtes${NC}"
}

# Installation des paquets Python
install_python_deps() {
    echo -e "${BLUE}📦 Installation des dépendances Python...${NC}"
    
    # Créer un environnement virtuel (optionnel mais recommandé)
    if [ "$1" = "--venv" ]; then
        echo -e "${YELLOW}🔧 Création d'un environnement virtuel...${NC}"
        python3 -m venv venv
        source venv/bin/activate
        echo -e "${GREEN}✅ Environnement virtuel activé${NC}"
        echo -e "${BLUE}💡 Pour réactiver: source venv/bin/activate${NC}"
    fi
    
    # Mise à jour de pip
    python3 -m pip install --upgrade pip
    
    # Installation des dépendances
    if [ -f "requirements.txt" ]; then
        python3 -m pip install -r requirements.txt
        echo -e "${GREEN}✅ Dépendances Python installées${NC}"
    else
        echo -e "${YELLOW}⚠️ requirements.txt non trouvé, installation manuelle...${NC}"
        python3 -m pip install requests beautifulsoup4 schedule lxml selenium webdriver-manager
        echo -e "${GREEN}✅ Dépendances de base installées${NC}"
    fi
}

# Test de l'installation
test_installation() {
    echo -e "${BLUE}🧪 Test de l'installation...${NC}"
    
    # Test des imports Python
    python3 -c "
import requests, bs4, schedule, lxml
print('✅ Dépendances de base OK')

try:
    import selenium
    from selenium import webdriver
    print('✅ Selenium OK')
except ImportError:
    print('⚠️ Selenium non disponible')
    
print('✅ Installation validée')
" || {
        echo -e "${RED}❌ Erreur lors du test${NC}"
        exit 1
    }
    
    # Test de la configuration
    if [ -f "config.json" ] && [ -f "universal_monitor.py" ]; then
        echo -e "${GREEN}✅ Fichiers du bot détectés${NC}"
    else
        echo -e "${YELLOW}⚠️ Fichiers du bot non trouvés${NC}"
    fi
}

# Configuration initiale
initial_setup() {
    echo -e "${BLUE}⚙️ Configuration initiale...${NC}"
    
    # Rendre les scripts exécutables
    chmod +x start_bot.sh
    echo -e "${GREEN}✅ Scripts rendus exécutables${NC}"
    
    # Créer le répertoire de logs
    mkdir -p logs
    echo -e "${GREEN}✅ Répertoire de logs créé${NC}"
    
    echo ""
    echo -e "${GREEN}🎉 Installation terminée avec succès !${NC}"
    echo ""
    echo -e "${BLUE}📋 Prochaines étapes :${NC}"
    echo "1. Configurez votre email : python3 setup_email.py"
    echo "2. Modifiez config.json avec vos sites à surveiller"
    echo "3. Testez : python3 test_universal.py config.json"
    echo "4. Lancez : ./start_bot.sh"
    echo ""
    echo -e "${YELLOW}💡 Ou utilisez le menu interactif : ./start_bot.sh${NC}"
}

# Main
main() {
    detect_os
    echo ""
    
    # Options d'installation
    echo "Options d'installation :"
    echo "1. Installation complète (recommandée)"
    echo "2. Installation sans Selenium"
    echo "3. Installation avec environnement virtuel"
    echo ""
    read -p "Choisissez (1-3) [1]: " install_option
    install_option=${install_option:-1}
    
    echo ""
    
    # Installation de Python
    install_python
    
    # Installation Selenium si demandé
    if [ "$install_option" = "1" ] || [ "$install_option" = "3" ]; then
        install_selenium_deps
    fi
    
    # Installation des dépendances Python
    if [ "$install_option" = "3" ]; then
        install_python_deps --venv
    else
        install_python_deps
    fi
    
    # Test et configuration
    test_installation
    initial_setup
}

# Aide
show_help() {
    echo "BotAlerte - Installation automatique"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Afficher cette aide"
    echo "  -q, --quick    Installation rapide sans Selenium"
    echo "  -v, --venv     Installation avec environnement virtuel"
    echo ""
}

# Gestion des arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -q|--quick)
        detect_os
        install_python
        install_python_deps
        test_installation
        initial_setup
        ;;
    -v|--venv)
        detect_os
        install_python
        install_selenium_deps
        install_python_deps --venv
        test_installation
        initial_setup
        ;;
    "")
        main
        ;;
    *)
        echo "Option inconnue: $1"
        show_help
        exit 1
        ;;
esac