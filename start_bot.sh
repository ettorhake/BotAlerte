#!/bin/bash

# BotAlerte - Script de démarrage Linux/Mac
# Équivalent de start_bot.bat pour les systèmes Unix

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Émojis
ROBOT="🤖"
ROCKET="🚀"
TEST="🧪"
EMAIL="📧"
GEAR="⚙️"
LIST="📋"
SEARCH="🔍"
EXIT="❌"
CHECK="✅"
WARNING="⚠️"
INFO="💡"

# Fonction pour afficher le header
show_header() {
    clear
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}   ${ROBOT} BOT DE SURVEILLANCE UNIVERSEL${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# Fonction pour vérifier Python
check_python() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}${WARNING} Python 3 n'est pas installé${NC}"
        echo -e "${INFO} Veuillez installer Python 3.7+ avant de continuer"
        echo ""
        echo "Ubuntu/Debian: sudo apt install python3 python3-pip"
        echo "CentOS/RHEL:   sudo yum install python3 python3-pip"
        echo "MacOS:         brew install python3"
        echo ""
        exit 1
    fi
    
    # Vérifier la version de Python
    python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    if [[ $(echo "$python_version >= 3.7" | bc -l) -eq 0 ]]; then
        echo -e "${RED}${WARNING} Python $python_version détecté. Version 3.7+ requise${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}${CHECK} Python $python_version détecté${NC}"
}

# Fonction pour installer les dépendances
install_dependencies() {
    echo -e "${BLUE}📦 Installation des dépendances Python...${NC}"
    echo ""
    
    # Vérifier si pip est installé
    if ! command -v pip3 &> /dev/null; then
        echo -e "${RED}${WARNING} pip3 n'est pas installé${NC}"
        echo -e "${INFO} Installation de pip3..."
        
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install python3-pip -y
        elif command -v yum &> /dev/null; then
            sudo yum install python3-pip -y
        elif command -v brew &> /dev/null; then
            echo -e "${INFO} pip3 devrait être disponible avec Python3 via Homebrew"
        else
            echo -e "${RED}Impossible d'installer pip3 automatiquement${NC}"
            echo "Veuillez l'installer manuellement"
            exit 1
        fi
    fi
    
    # Installation des dépendances
    echo -e "${INFO} Installation des paquets Python..."
    if pip3 install -r requirements.txt; then
        echo -e "${GREEN}${CHECK} Dépendances installées avec succès${NC}"
    else
        echo -e "${RED}${WARNING} Erreur lors de l'installation des dépendances${NC}"
        echo -e "${INFO} Essayez: pip3 install --user -r requirements.txt"
        exit 1
    fi
    
    # Installation optionnelle de Selenium/ChromeDriver
    echo ""
    echo -e "${YELLOW}${INFO} Installation optionnelle de ChromeDriver pour JavaScript...${NC}"
    read -p "Installer ChromeDriver pour les sites JavaScript? (y/N): " install_chrome
    
    if [[ $install_chrome =~ ^[Yy]$ ]]; then
        echo -e "${INFO} Installation de webdriver-manager..."
        pip3 install webdriver-manager
        
        # Tenter d'installer Chrome si pas présent
        if ! command -v google-chrome &> /dev/null && ! command -v chromium-browser &> /dev/null; then
            echo -e "${YELLOW}${WARNING} Chrome/Chromium non détecté${NC}"
            echo -e "${INFO} Installation recommandée:"
            echo ""
            echo "Ubuntu/Debian:"
            echo "  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -"
            echo "  sudo sh -c 'echo \"deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main\" >> /etc/apt/sources.list.d/google-chrome.list'"
            echo "  sudo apt update && sudo apt install google-chrome-stable"
            echo ""
            echo "CentOS/RHEL:"
            echo "  sudo yum install chromium"
            echo ""
            echo "MacOS:"
            echo "  brew install --cask google-chrome"
            echo ""
        else
            echo -e "${GREEN}${CHECK} Chrome/Chromium détecté${NC}"
        fi
    fi
    
    echo ""
    echo -e "${GREEN}${CHECK} Installation terminée${NC}"
    sleep 2
}

# Fonction pour vérifier les dépendances
check_dependencies() {
    echo -e "${INFO} Vérification des dépendances..."
    
    missing_deps=()
    
    if ! python3 -c "import requests" 2>/dev/null; then
        missing_deps+=("requests")
    fi
    
    if ! python3 -c "import bs4" 2>/dev/null; then
        missing_deps+=("beautifulsoup4")
    fi
    
    if ! python3 -c "import schedule" 2>/dev/null; then
        missing_deps+=("schedule")
    fi
    
    if ! python3 -c "import lxml" 2>/dev/null; then
        missing_deps+=("lxml")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}${WARNING} Dépendances manquantes: ${missing_deps[*]}${NC}"
        echo ""
        echo -e "${INFO} Installation automatique des dépendances..."
        install_dependencies
    else
        echo -e "${GREEN}${CHECK} Toutes les dépendances sont installées${NC}"
    fi
}

# Fonction pour le menu principal
show_menu() {
    echo "Choisissez une option:"
    echo ""
    echo -e "${GREEN}[1]${NC} ${ROCKET} Démarrer le bot (surveillance continue)"
    echo -e "${BLUE}[2]${NC} ${TEST} Tester la configuration"
    echo -e "${CYAN}[3]${NC} ${EMAIL} Configurer l'email"
    echo -e "${YELLOW}[4]${NC} ${GEAR} Créer une nouvelle configuration"
    echo -e "${BLUE}[5]${NC} ${LIST} Voir les configurations existantes"
    echo -e "${CYAN}[6]${NC} ${SEARCH} Test manuel de recherche"
    echo -e "${YELLOW}[7]${NC} 📦 Installer/Vérifier les dépendances"
    echo -e "${GREEN}[8]${NC} 🔄 Redémarrer en arrière-plan (daemon)"
    echo -e "${RED}[9]${NC} ${EXIT} Quitter"
    echo ""
    read -p "Votre choix (1-9): " choice
}

# Fonction pour démarrer le bot
start_bot() {
    echo ""
    echo -e "${GREEN}${ROCKET} Démarrage du bot de surveillance...${NC}"
    echo -e "${INFO} Appuyez sur Ctrl+C pour arrêter${NC}"
    echo ""
    python3 universal_monitor.py
}

# Fonction pour tester la configuration
test_config() {
    echo ""
    echo -e "${BLUE}${TEST} Test de la configuration...${NC}"
    python3 test_universal.py config.json
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour configurer l'email
setup_email() {
    echo ""
    echo -e "${CYAN}${EMAIL} Configuration de l'email...${NC}"
    python3 setup_email.py
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour créer une configuration
create_config() {
    echo ""
    echo -e "${YELLOW}${GEAR} Création d'une nouvelle configuration...${NC}"
    python3 config_generator.py
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour lister les configurations
list_configs() {
    echo ""
    echo -e "${BLUE}${LIST} Configurations disponibles:${NC}"
    echo ""
    for config in *.json; do
        if [ -f "$config" ]; then
            echo -e "${GREEN}📄${NC} $config"
        fi
    done
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour test manuel
manual_test() {
    echo ""
    read -p "Fichier de configuration (config.json): " config_file
    config_file=${config_file:-config.json}
    echo ""
    echo -e "${CYAN}${SEARCH} Test manuel avec $config_file...${NC}"
    python3 test_universal.py "$config_file"
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour démarrer en arrière-plan
start_daemon() {
    echo ""
    echo -e "${GREEN}🔄 Démarrage du bot en arrière-plan...${NC}"
    echo ""
    
    # Vérifier si le bot tourne déjà
    if pgrep -f "universal_monitor.py" > /dev/null; then
        echo -e "${YELLOW}${WARNING} Le bot semble déjà en cours d'exécution${NC}"
        echo ""
        echo "Processus détectés:"
        pgrep -f "universal_monitor.py" | while read pid; do
            echo "  PID: $pid"
        done
        echo ""
        read -p "Arrêter les processus existants? (y/N): " kill_existing
        
        if [[ $kill_existing =~ ^[Yy]$ ]]; then
            pkill -f "universal_monitor.py"
            echo -e "${GREEN}${CHECK} Processus arrêtés${NC}"
            sleep 2
        else
            echo "Retour au menu..."
            sleep 2
            return
        fi
    fi
    
    # Démarrer en arrière-plan
    echo -e "${INFO} Démarrage en mode daemon..."
    nohup python3 universal_monitor.py > bot.log 2>&1 &
    bot_pid=$!
    
    echo -e "${GREEN}${CHECK} Bot démarré en arrière-plan${NC}"
    echo "  PID: $bot_pid"
    echo "  Logs: tail -f bot.log"
    echo "  Arrêt: kill $bot_pid"
    echo ""
    
    # Créer un script d'arrêt
    cat > stop_bot.sh << EOF
#!/bin/bash
echo "Arrêt du bot de surveillance..."
if kill $bot_pid 2>/dev/null; then
    echo "Bot arrêté (PID: $bot_pid)"
else
    echo "Impossible d'arrêter le bot avec PID $bot_pid"
    echo "Tentative d'arrêt de tous les processus du bot..."
    pkill -f "universal_monitor.py"
fi
EOF
    chmod +x stop_bot.sh
    
    echo -e "${INFO} Script d'arrêt créé: ./stop_bot.sh${NC}"
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# Script principal
main() {
    # Aller dans le répertoire du script
    cd "$(dirname "$0")"
    
    show_header
    
    # Vérifier Python
    check_python
    
    # Vérifier les dépendances
    check_dependencies
    
    # Boucle principale du menu
    while true; do
        show_header
        show_menu
        
        case $choice in
            1) start_bot ;;
            2) test_config ;;
            3) setup_email ;;
            4) create_config ;;
            5) list_configs ;;
            6) manual_test ;;
            7) install_dependencies ;;
            8) start_daemon ;;
            9) 
                echo ""
                echo -e "${GREEN}👋 Au revoir !${NC}"
                sleep 1
                exit 0
                ;;
            *)
                echo -e "${RED}Choix invalide, essayez encore.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Fonction d'aide
show_help() {
    echo "BotAlerte - Bot de Surveillance Universel"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Afficher cette aide"
    echo "  -i, --install  Installer les dépendances uniquement"
    echo "  -t, --test     Tester la configuration"
    echo "  -d, --daemon   Démarrer en arrière-plan"
    echo "  -s, --stop     Arrêter le daemon"
    echo ""
    echo "Sans option: afficher le menu interactif"
}

# Gestion des arguments de ligne de commande
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -i|--install)
        check_python
        install_dependencies
        exit 0
        ;;
    -t|--test)
        check_python
        check_dependencies
        test_config
        exit 0
        ;;
    -d|--daemon)
        check_python
        check_dependencies
        start_daemon
        exit 0
        ;;
    -s|--stop)
        echo "Arrêt du bot..."
        pkill -f "universal_monitor.py" && echo "Bot arrêté" || echo "Aucun bot en cours d'exécution"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        echo "Option inconnue: $1"
        echo "Utilisez -h pour l'aide"
        exit 1
        ;;
esac