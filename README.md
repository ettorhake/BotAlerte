# 🤖 BotAlerte - Bot d'alerte automatique 🚀

Pour une installation automatique avec toutes les dépendances :

**Linux/Mac :**
```bash
git clone https://github.com/ettorhake/BotAlerte.git
cd BotAlerte
chmod +x install.sh
./install.sh
```

**Windows :**
```cmd
git clone https://github.com/ettorhake/BotAlerte.git
cd BotAlerte
install.bat
```

**Ou avec PowerShell :**
```powershell
.\install.ps1
```

## Installation manuelle

### 1. Prérequis
```bash
# Python 3.7 ou plus récent
python --version

# Git (pour cloner le projet)
git --version
```

### 2. Cloner le projet
```bashe Universel

![Version](https://img.shields.io/badge/version-2.0-blue.svg)
![Python](https://img.shields.io/badge/python-3.7%2B-blue.svg)
![Selenium](https://img.shields.io/badge/selenium-support-green.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

Un bot de surveillance universel pour surveiller l'apparition de produits sur des sites web avec support JavaScript/Selenium.

## ✨ Fonctionnalités

- 🌐 **Multi-sites** : Surveillance simultanée de plusieurs sites web
- 🔍 **Multi-mots-clés** : Recherche de plusieurs termes par site
- 🧠 **JavaScript intelligent** : Support des sites avec contenu dynamique (Selenium)
- 📧 **Alertes email** : Notifications instantanées des nouveaux produits
- ⚙️ **Configuration JSON** : Configuration simple et flexible
- 🔒 **Sécurisé** : Gestion sécurisée des identifiants email
- 🎯 **Filtrage précis** : Recherche stricte dans les titres des produits
- 🚫 **Termes exclus** : Filtrage automatique des produits indésirables
- 🔄 **Anti-doublons** : Évite les alertes répétées
- 📊 **Logs détaillés** : Suivi complet de l'activité

## 🚀 Installation

### 1. Prérequis
```bash
# Python 3.7 ou plus récent
python --version

# Git (pour cloner le projet)
git --version
```

### 2. Cloner le projet
```bash
git clone https://github.com/ettorhake/BotAlerte.git
cd BotAlerte
```

### 3. Installer les dépendances
```bash
pip install -r requirements.txt
```

### 4. (Optionnel) Support JavaScript/Selenium
Pour surveiller les sites avec contenu JavaScript :
```bash
# Installer Chrome/Chromium
# Télécharger ChromeDriver depuis https://chromedriver.chromium.org/
# Ou utiliser le gestionnaire automatique
pip install webdriver-manager
```

## ⚡ Démarrage rapide

### 1. Configuration email
```bash
python setup_email.py
```
**Important :** Utilisez un [mot de passe d'application Gmail](https://support.google.com/accounts/answer/185833?hl=fr), pas votre mot de passe principal !

### 2. Configuration de surveillance
Modifiez `config.json` :
```json
{
  "websites": [
    {
      "name": "Mon Site",
      "url": "https://example.com/products",
      "search_terms": ["mot-clé-1", "mot-clé-2"]
    }
  ],
  "email_settings": {
    "recipient_emails": ["votre-email@example.com"]
  }
}
```

### 3. Test
```bash
python test_universal.py config.json
```

### 4. Lancement
```bash
python universal_monitor.py config.json
```

**Sur Windows :** Double-cliquez sur `start_bot.bat`

## 📖 Configuration

### Structure du fichier `config.json`

```json
{
  "monitor_name": "Nom de votre surveillance",
  "description": "Description de ce que vous surveillez",
  
  "websites": [
    {
      "name": "Nom du site",
      "url": "https://site-web.com/recherche",
      "enabled": true,
      "search_terms": ["terme1", "terme2"],
      "selectors": {
        "product_containers": [".product", ".item"],
        "title": ["h2", ".title"],
        "price": [".price"],
        "link": ["a[href]"]
      }
    }
  ],
  
  "email_settings": {
    "sender_email": "expediteur@gmail.com",
    "recipient_emails": ["destinataire@example.com"],
    "smtp_server": "smtp.gmail.com",
    "smtp_port": 587
  },
  
  "monitoring_settings": {
    "check_interval_hours": 2,
    "max_products_per_alert": 10,
    "avoid_duplicates": true
  },
  
  "advanced_settings": {
    "use_selenium": false,
    "selenium_wait_seconds": 10,
    "exclude_terms": ["défectueux", "cassé"]
  }
}
```

### Options JavaScript/Selenium

Pour les sites avec contenu dynamique :
```json
{
  "advanced_settings": {
    "use_selenium": true,
    "selenium_wait_seconds": 15,
    "selenium_headless": true
  }
}
```

## 📁 Exemples

### Matériel audio
```bash
cp examples/audio_equipment.json my_audio_config.json
python universal_monitor.py my_audio_config.json
```

### Site avec JavaScript
```bash
cp examples/javascript_site.json my_js_config.json
python universal_monitor.py my_js_config.json
```

## 🛠️ Utilisation avancée

### Génération de configuration
```bash
python config_generator.py
```

### Surveillance en arrière-plan (Linux/Mac)
```bash
nohup python universal_monitor.py config.json &
```

### Surveillance en arrière-plan (Windows)
```bash
start /B python universal_monitor.py config.json
```

## 🐛 Dépannage

### Aucun produit trouvé
1. Vérifiez l'URL du site
2. Testez les sélecteurs CSS
3. Activez Selenium si le site utilise JavaScript
4. Consultez les logs pour plus de détails

### Erreurs email
1. Vérifiez vos identifiants Gmail
2. Utilisez un mot de passe d'application
3. Activez l'authentification à deux facteurs

### Sites JavaScript
1. Activez `"use_selenium": true`
2. Augmentez `selenium_wait_seconds`
3. Vérifiez que ChromeDriver est installé

### Problèmes de compatibilité Python
1. **Erreur `bc: command not found`** : Les scripts ont été corrigés pour ne plus utiliser `bc`
2. **Python 3.11+ non reconnu** : Toutes les versions Python 3.7+ sont maintenant supportées
3. **Erreur "externally-managed-environment"** : Utilisez l'installation avec environnement virtuel
4. Testez la compatibilité : `./test_compatibility.sh`

### Environnement Python externally-managed (Ubuntu 22.04+, Debian 12+)
Si vous obtenez l'erreur "externally-managed-environment" :

**Solution automatique :**
```bash
chmod +x install_venv.sh
./install_venv.sh
```

**Ou manuellement :**
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python universal_monitor.py
```

**Lancement avec environnement virtuel :**
```bash
./start_with_venv.sh
# Ou manuellement:
source venv/bin/activate && python universal_monitor.py
```

### Script de test de compatibilité
```bash
# Linux/Mac
chmod +x test_compatibility.sh
./test_compatibility.sh

# Windows (Git Bash/WSL)
bash test_compatibility.sh
```

## 🤝 Contribution

Les contributions sont les bienvenues ! 

1. Fork le projet
2. Créez votre branche (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commitez vos changements (`git commit -am 'Ajout nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## ⚠️ Avertissement

- Respectez les conditions d'utilisation des sites web surveillés
- Utilisez des délais raisonnables entre les requêtes
- Ce bot est à des fins éducatives et personnelles
- L'auteur n'est pas responsable de l'utilisation qui en est faite

## 🙏 Remerciements

- [BeautifulSoup](https://www.crummy.com/software/BeautifulSoup/) pour le parsing HTML
- [Selenium](https://selenium.dev/) pour le support JavaScript
- [Requests](https://requests.readthedocs.io/) pour les requêtes HTTP

---

**Créé avec ❤️ pour la communauté**
