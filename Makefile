# BotAlerte - Makefile pour installation et gestion
.PHONY: help install install-dev install-quick test run clean setup

# Variables
PYTHON := python3
PIP := $(PYTHON) -m pip
VENV := venv
REQUIREMENTS := requirements.txt

# Couleurs pour l'affichage
GREEN := \033[0;32m
BLUE := \033[0;34m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Afficher cette aide
	@echo "$(BLUE)🤖 BotAlerte - Commandes disponibles$(NC)"
	@echo "======================================"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Exemples d'utilisation :$(NC)"
	@echo "  make install        # Installation complète"
	@echo "  make install-quick  # Sans Selenium"
	@echo "  make run           # Lancer le bot"
	@echo "  make test          # Tester la configuration"

install: ## Installation complète avec Selenium
	@echo "$(BLUE)🚀 Installation complète de BotAlerte$(NC)"
	@echo "======================================="
	@./install.sh || (echo "$(RED)❌ Script install.sh non trouvé, installation manuelle...$(NC)" && $(MAKE) install-manual)

install-quick: ## Installation rapide sans Selenium
	@echo "$(BLUE)⚡ Installation rapide (sans Selenium)$(NC)"
	@echo "======================================="
	@./install.sh -q || (echo "$(RED)❌ Script install.sh non trouvé, installation manuelle...$(NC)" && $(MAKE) install-manual-quick)

install-dev: ## Installation avec environnement virtuel
	@echo "$(BLUE)🔧 Installation développeur (avec venv)$(NC)"
	@echo "========================================="
	@./install.sh -v || (echo "$(RED)❌ Script install.sh non trouvé, installation manuelle...$(NC)" && $(MAKE) install-manual-venv)

install-manual: ## Installation manuelle complète
	@echo "$(BLUE)📦 Installation manuelle$(NC)"
	@$(MAKE) check-python
	@$(MAKE) install-deps
	@$(MAKE) setup-dirs
	@echo "$(GREEN)✅ Installation manuelle terminée$(NC)"

install-manual-quick: ## Installation manuelle sans Selenium
	@echo "$(BLUE)📦 Installation manuelle rapide$(NC)"
	@$(MAKE) check-python
	@$(PIP) install requests beautifulsoup4 schedule lxml
	@$(MAKE) setup-dirs
	@echo "$(GREEN)✅ Installation manuelle rapide terminée$(NC)"

install-manual-venv: ## Installation manuelle avec environnement virtuel
	@echo "$(BLUE)📦 Installation manuelle avec venv$(NC)"
	@$(MAKE) check-python
	@$(PYTHON) -m venv $(VENV)
	@. $(VENV)/bin/activate && $(PIP) install --upgrade pip
	@. $(VENV)/bin/activate && $(MAKE) install-deps
	@$(MAKE) setup-dirs
	@echo "$(GREEN)✅ Installation avec venv terminée$(NC)"
	@echo "$(YELLOW)💡 Activez l'environnement : source $(VENV)/bin/activate$(NC)"

check-python: ## Vérifier la version de Python
	@echo "$(BLUE)🐍 Vérification de Python...$(NC)"
	@$(PYTHON) --version || (echo "$(RED)❌ Python 3 non trouvé$(NC)" && exit 1)
	@echo "$(GREEN)✅ Python OK$(NC)"

install-deps: ## Installer les dépendances Python
	@echo "$(BLUE)📋 Installation des dépendances...$(NC)"
	@$(PIP) install --upgrade pip
	@if [ -f $(REQUIREMENTS) ]; then \
		$(PIP) install -r $(REQUIREMENTS); \
	else \
		echo "$(YELLOW)⚠️ requirements.txt non trouvé, installation manuelle...$(NC)"; \
		$(PIP) install requests beautifulsoup4 schedule lxml selenium webdriver-manager; \
	fi
	@echo "$(GREEN)✅ Dépendances installées$(NC)"

setup-dirs: ## Créer les répertoires nécessaires
	@echo "$(BLUE)📁 Création des répertoires...$(NC)"
	@mkdir -p logs
	@chmod +x start_bot.sh || true
	@chmod +x install.sh || true
	@echo "$(GREEN)✅ Répertoires créés$(NC)"

test: ## Tester l'installation et la configuration
	@echo "$(BLUE)🧪 Test de l'installation$(NC)"
	@$(PYTHON) -c "import requests, bs4, schedule, lxml; print('✅ Dépendances de base OK')" || (echo "$(RED)❌ Dépendances manquantes$(NC)" && exit 1)
	@$(PYTHON) -c "import selenium; print('✅ Selenium OK')" || echo "$(YELLOW)⚠️ Selenium non disponible$(NC)"
	@if [ -f "config.json" ] && [ -f "universal_monitor.py" ]; then \
		echo "$(GREEN)✅ Fichiers du bot détectés$(NC)"; \
	else \
		echo "$(YELLOW)⚠️ Fichiers du bot non trouvés$(NC)"; \
	fi
	@if [ -f "config.json" ]; then \
		$(PYTHON) test_universal.py config.json || echo "$(YELLOW)⚠️ Configurez config.json avant de tester$(NC)"; \
	fi

run: ## Lancer le bot
	@echo "$(BLUE)🤖 Lancement du bot$(NC)"
	@if [ -f "start_bot.sh" ]; then \
		./start_bot.sh; \
	else \
		$(PYTHON) universal_monitor.py config.json; \
	fi

setup: ## Configuration initiale interactive
	@echo "$(BLUE)⚙️ Configuration initiale$(NC)"
	@if [ -f "setup_email.py" ]; then \
		$(PYTHON) setup_email.py; \
	else \
		echo "$(YELLOW)⚠️ setup_email.py non trouvé$(NC)"; \
		echo "Modifiez manuellement config.json"; \
	fi

clean: ## Nettoyer les fichiers temporaires
	@echo "$(BLUE)🧹 Nettoyage$(NC)"
	@rm -rf __pycache__/
	@rm -rf *.pyc
	@rm -rf logs/*.log
	@rm -rf .pytest_cache/
	@echo "$(GREEN)✅ Nettoyage terminé$(NC)"

clean-all: clean ## Nettoyage complet (inclut venv)
	@echo "$(BLUE)🧹 Nettoyage complet$(NC)"
	@rm -rf $(VENV)/
	@echo "$(GREEN)✅ Nettoyage complet terminé$(NC)"

status: ## Afficher le statut du système
	@echo "$(BLUE)📊 Statut du système$(NC)"
	@echo "====================="
	@echo "Python: $$($(PYTHON) --version 2>/dev/null || echo 'Non installé')"
	@echo "Pip: $$($(PIP) --version 2>/dev/null || echo 'Non installé')"
	@echo "Chrome: $$(google-chrome --version 2>/dev/null || chromium --version 2>/dev/null || echo 'Non installé')"
	@echo ""
	@echo "Fichiers projet:"
	@echo "- config.json: $$([ -f config.json ] && echo '✅' || echo '❌')"
	@echo "- universal_monitor.py: $$([ -f universal_monitor.py ] && echo '✅' || echo '❌')"
	@echo "- requirements.txt: $$([ -f requirements.txt ] && echo '✅' || echo '❌')"
	@echo "- start_bot.sh: $$([ -f start_bot.sh ] && echo '✅' || echo '❌')"
	@echo ""
	@echo "Répertoires:"
	@echo "- logs/: $$([ -d logs ] && echo '✅' || echo '❌')"
	@echo "- venv/: $$([ -d venv ] && echo '✅' || echo '❌')"

update: ## Mettre à jour les dépendances
	@echo "$(BLUE)🔄 Mise à jour des dépendances$(NC)"
	@$(PIP) install --upgrade pip
	@$(PIP) install --upgrade -r $(REQUIREMENTS)
	@echo "$(GREEN)✅ Mise à jour terminée$(NC)"

# Cible par défaut
.DEFAULT_GOAL := help