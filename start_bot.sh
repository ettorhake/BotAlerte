#!/bin/bash

# BotAlerte - Script de démarrage Linux/Mac
# Équivalent de start_bot.bat pour les systèmes Unix

# Variables globales
PYTHON_CMD="python3"
PIP_CMD="pip3"
VENV_DIR="venv"
USE_VENV=false

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

# Fonction pour vérifier la version Python (sans dépendances externes)
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
    local python_version
    
    # Essayer python3 d'abord
    if python_version=$(check_python_version "python3"); then
        PYTHON_CMD="python3"
        echo -e "${GREEN}${CHECK} Python $python_version détecté avec python3 (compatible)${NC}"
    # Puis essayer python
    elif python_version=$(check_python_version "python"); then
        PYTHON_CMD="python"
        echo -e "${GREEN}${CHECK} Python $python_version détecté avec python (compatible)${NC}"
    else
        echo -e "${RED}${WARNING} Python 3.7+ non trouvé${NC}"
        echo -e "${INFO} Veuillez installer Python 3.7+ avant de continuer"
        echo ""
        echo "Ubuntu/Debian: sudo apt install python3 python3-pip"
        echo "CentOS/RHEL:   sudo yum install python3 python3-pip"
        echo "MacOS:         brew install python3"
        echo "Ou utilisez:   ./install.sh"
        echo ""
        exit 1
    fi
    
    echo -e "${GREEN}${CHECK} Python $python_version détecté${NC}"
}

# Fonction pour créer un environnement virtuel
create_venv() {
    echo -e "${INFO} Création d'un environnement virtuel Python..."
    
    if ! $PYTHON_CMD -m venv "$VENV_DIR"; then
        echo -e "${RED}${WARNING} Impossible de créer l'environnement virtuel${NC}"
        echo -e "${INFO} Installation de python3-venv..."
        
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install python3-venv python3-full -y
        elif command -v yum &> /dev/null; then
            sudo yum install python3-venv -y
        else
            echo -e "${RED}Veuillez installer python3-venv manuellement${NC}"
            return 1
        fi
        
        # Réessayer
        if ! $PYTHON_CMD -m venv "$VENV_DIR"; then
            echo -e "${RED}${WARNING} Échec de création de l'environnement virtuel${NC}"
            return 1
        fi
    fi
    
    echo -e "${GREEN}${CHECK} Environnement virtuel créé${NC}"
    return 0
}

# Fonction pour activer l'environnement virtuel
activate_venv() {
    if [ -f "$VENV_DIR/bin/activate" ]; then
        source "$VENV_DIR/bin/activate"
        PYTHON_CMD="$VENV_DIR/bin/python"
        PIP_CMD="$VENV_DIR/bin/pip"
        USE_VENV=true
        echo -e "${GREEN}${CHECK} Environnement virtuel activé${NC}"
        return 0
    else
        echo -e "${RED}${WARNING} Environnement virtuel non trouvé${NC}"
        return 1
    fi
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
            sudo apt update && sudo apt install python3-pip python3-venv python3-full -y
        elif command -v yum &> /dev/null; then
            sudo yum install python3-pip python3-venv -y
        elif command -v brew &> /dev/null; then
            echo -e "${INFO} pip3 devrait être disponible avec Python3 via Homebrew"
        else
            echo -e "${RED}Impossible d'installer pip3 automatiquement${NC}"
            echo "Veuillez l'installer manuellement"
            exit 1
        fi
    fi
    
    # Tentative d'installation directe d'abord
    echo -e "${INFO} Installation des paquets Python..."
    if $PIP_CMD install -r requirements.txt 2>/dev/null; then
        echo -e "${GREEN}${CHECK} Dépendances installées avec succès${NC}"
    else
        echo -e "${YELLOW}${WARNING} Installation système échouée (environnement géré)${NC}"
        echo -e "${INFO} Tentative avec --user...${NC}"
        
        # Essayer avec --user
        if $PIP_CMD install --user -r requirements.txt 2>/dev/null; then
            echo -e "${GREEN}${CHECK} Dépendances installées avec --user${NC}"
        else
            echo -e "${YELLOW}${WARNING} Installation --user impossible${NC}"
            echo -e "${INFO} Création d'un environnement virtuel...${NC}"
            
            # Créer et utiliser un environnement virtuel
            if create_venv && activate_venv; then
                echo -e "${INFO} Installation dans l'environnement virtuel...${NC}"
                if $PIP_CMD install -r requirements.txt; then
                    echo -e "${GREEN}${CHECK} Dépendances installées dans l'environnement virtuel${NC}"
                    echo -e "${INFO} L'environnement virtuel sera utilisé automatiquement${NC}"
                else
                    echo -e "${RED}${WARNING} Échec d'installation dans l'environnement virtuel${NC}"
                    exit 1
                fi
            else
                echo -e "${RED}${WARNING} Impossible de créer l'environnement virtuel${NC}"
                echo -e "${INFO} Solutions manuelles:${NC}"
                echo "1. sudo apt install python3-full python3-venv"
                echo "2. python3 -m venv venv && source venv/bin/activate"
                echo "3. pip install -r requirements.txt"
                echo "4. Ou utilisez: pip3 install --break-system-packages -r requirements.txt"
                exit 1
            fi
        fi
    fi
    
    # Installation optionnelle de Selenium/ChromeDriver
    echo ""
    echo -e "${YELLOW}${INFO} Installation optionnelle de ChromeDriver pour JavaScript...${NC}"
    read -p "Installer ChromeDriver pour les sites JavaScript? (y/N): " install_chrome
    
    if [[ $install_chrome =~ ^[Yy]$ ]]; then
        echo -e "${INFO} Installation de webdriver-manager..."
        $PIP_CMD install webdriver-manager
        
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

# Fonction pour vérifier et configurer l'environnement Python
setup_python_environment() {
    # Vérifier si un environnement virtuel existe et l'activer
    if [ -d "$VENV_DIR" ] && [ -f "$VENV_DIR/bin/activate" ]; then
        echo -e "${INFO} Environnement virtuel détecté, activation...${NC}"
        activate_venv
    fi
}

# Fonction pour vérifier les dépendances
check_dependencies() {
    echo -e "${INFO} Vérification des dépendances...${NC}"
    
    # Configurer l'environnement Python (venv si disponible)
    setup_python_environment
    
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
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}${WARNING} Dépendances manquantes: ${missing_deps[*]}${NC}"
        echo ""
        echo -e "${INFO} Installation automatique des dépendances...${NC}"
        install_dependencies
    else
        echo -e "${GREEN}${CHECK} Toutes les dépendances sont installées${NC}"
        if [ "$USE_VENV" = true ]; then
            echo -e "${INFO} Utilisation de l'environnement virtuel: $VENV_DIR${NC}"
        fi
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
    setup_python_environment
    $PYTHON_CMD universal_monitor.py
}

# Fonction pour tester la configuration
test_config() {
    echo ""
    echo -e "${BLUE}${TEST} Test de la configuration...${NC}"
    setup_python_environment
    $PYTHON_CMD test_universal.py config.json
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour configurer l'email
setup_email() {
    echo ""
    echo -e "${BLUE}${GEAR} Configuration de l'email...${NC}"
    $PYTHON_CMD setup_email.py
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour créer une configuration
create_config() {
    echo ""
    echo -e "${YELLOW}${GEAR} Création d'une nouvelle configuration...${NC}"
    $PYTHON_CMD config_generator.py
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
    setup_python_environment
    $PYTHON_CMD test_universal.py "$config_file"
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
    setup_python_environment
    nohup $PYTHON_CMD universal_monitor.py > bot.log 2>&1 &
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