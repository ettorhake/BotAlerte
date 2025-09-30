#!/bin/bash

# BotAlerte - Installation avec environnement virtuel
# Solution pour les systèmes avec "externally-managed-environment"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables
VENV_DIR="venv"
PYTHON_CMD="python3"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   🤖 INSTALLATION BOTALERTE (VENV)${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Fonction pour vérifier Python
check_python() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}❌ Python 3 non trouvé${NC}"
        echo -e "${BLUE}💡 Installation de Python 3...${NC}"
        
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install python3 python3-pip python3-venv python3-full -y
        elif command -v yum &> /dev/null; then
            sudo yum install python3 python3-pip python3-venv -y
        else
            echo -e "${RED}❌ Gestionnaire de paquets non supporté${NC}"
            echo "Veuillez installer Python 3 manuellement"
            exit 1
        fi
    fi
    
    local version=$($PYTHON_CMD --version 2>&1 | grep -oP '\d+\.\d+')
    echo -e "${GREEN}✅ Python $version détecté${NC}"
}

# Fonction pour créer l'environnement virtuel
create_venv() {
    echo -e "${BLUE}📦 Création de l'environnement virtuel...${NC}"
    
    if [ -d "$VENV_DIR" ]; then
        echo -e "${YELLOW}⚠️ Environnement virtuel existe déjà${NC}"
        read -p "Supprimer et recréer? (y/N): " recreate
        if [[ $recreate =~ ^[Yy]$ ]]; then
            rm -rf "$VENV_DIR"
        else
            echo -e "${GREEN}✅ Utilisation de l'environnement existant${NC}"
            return 0
        fi
    fi
    
    if ! $PYTHON_CMD -m venv "$VENV_DIR"; then
        echo -e "${RED}❌ Impossible de créer l'environnement virtuel${NC}"
        echo -e "${BLUE}💡 Installation des dépendances manquantes...${NC}"
        
        if command -v apt &> /dev/null; then
            sudo apt install python3-venv python3-full -y
        elif command -v yum &> /dev/null; then
            sudo yum install python3-venv -y
        fi
        
        # Réessayer
        if ! $PYTHON_CMD -m venv "$VENV_DIR"; then
            echo -e "${RED}❌ Échec de création de l'environnement virtuel${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✅ Environnement virtuel créé${NC}"
}

# Fonction pour installer les dépendances
install_deps() {
    echo -e "${BLUE}📦 Installation des dépendances...${NC}"
    
    # Activer l'environnement virtuel
    source "$VENV_DIR/bin/activate"
    
    # Mettre à jour pip
    pip install --upgrade pip
    
    # Installer les dépendances
    if pip install -r requirements.txt; then
        echo -e "${GREEN}✅ Dépendances installées avec succès${NC}"
    else
        echo -e "${RED}❌ Erreur lors de l'installation${NC}"
        exit 1
    fi
    
    # Installation optionnelle de Chrome/Selenium
    echo ""
    echo -e "${YELLOW}💡 Support JavaScript/Selenium (optionnel)${NC}"
    read -p "Installer le support pour les sites JavaScript? (y/N): " install_chrome
    
    if [[ $install_chrome =~ ^[Yy]$ ]]; then
        pip install selenium webdriver-manager
        echo -e "${GREEN}✅ Support JavaScript installé${NC}"
        
        # Vérifier Chrome
        if ! command -v google-chrome &> /dev/null && ! command -v chromium-browser &> /dev/null; then
            echo -e "${YELLOW}⚠️ Chrome/Chromium non détecté${NC}"
            echo -e "${BLUE}💡 Installation recommandée:${NC}"
            echo "Ubuntu/Debian: sudo apt install chromium-browser"
            echo "Ou téléchargez Chrome: https://www.google.com/chrome/"
        fi
    fi
    
    deactivate
}

# Fonction pour créer un script de lancement
create_launcher() {
    echo -e "${BLUE}🚀 Création du script de lancement...${NC}"
    
    cat > start_with_venv.sh << 'EOF'
#!/bin/bash

# BotAlerte - Lancement avec environnement virtuel
cd "$(dirname "$0")"

VENV_DIR="venv"

if [ ! -d "$VENV_DIR" ]; then
    echo "❌ Environnement virtuel non trouvé"
    echo "💡 Exécutez: ./install_venv.sh"
    exit 1
fi

echo "🚀 Activation de l'environnement virtuel..."
source "$VENV_DIR/bin/activate"

echo "🤖 Démarrage du bot..."
python universal_monitor.py

deactivate
EOF
    
    chmod +x start_with_venv.sh
    echo -e "${GREEN}✅ Script start_with_venv.sh créé${NC}"
}

# Fonction pour tester l'installation
test_installation() {
    echo -e "${BLUE}🧪 Test de l'installation...${NC}"
    
    source "$VENV_DIR/bin/activate"
    
    # Tester les imports
    if python -c "import requests, bs4, schedule, lxml" 2>/dev/null; then
        echo -e "${GREEN}✅ Toutes les dépendances sont installées${NC}"
    else
        echo -e "${RED}❌ Problème avec les dépendances${NC}"
        deactivate
        exit 1
    fi
    
    # Tester le script principal
    if [ -f "test_universal.py" ] && [ -f "config.json" ]; then
        echo -e "${BLUE}🧪 Test de configuration...${NC}"
        python test_universal.py config.json
    fi
    
    deactivate
}

# Script principal
main() {
    cd "$(dirname "$0")"
    
    echo -e "${BLUE}💡 Cette installation utilise un environnement virtuel Python${NC}"
    echo -e "${BLUE}💡 Solution pour les systèmes 'externally-managed-environment'${NC}"
    echo ""
    
    # Étapes d'installation
    check_python
    create_venv
    install_deps
    create_launcher
    test_installation
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   ✅ INSTALLATION TERMINÉE${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}💡 Comment utiliser:${NC}"
    echo "1. Configuration email: source venv/bin/activate && python setup_email.py"
    echo "2. Test: source venv/bin/activate && python test_universal.py config.json"
    echo "3. Lancement: ./start_with_venv.sh"
    echo "4. Ou manuel: source venv/bin/activate && python universal_monitor.py"
    echo ""
    echo -e "${YELLOW}📁 L'environnement virtuel est dans le dossier: $VENV_DIR${NC}"
    echo -e "${YELLOW}🔧 Pour activer manuellement: source $VENV_DIR/bin/activate${NC}"
    echo ""
}

# Lancer l'installation
main "$@"