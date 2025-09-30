# Guide de démarrage rapide 🚀

## Installation en 30 secondes

### Linux/Mac
```bash
git clone https://github.com/ettorhake/BotAlerte.git
cd BotAlerte
chmod +x install.sh && ./install.sh
```

### Windows
```cmd
git clone https://github.com/ettorhake/BotAlerte.git
cd BotAlerte
install.bat
```

## Configuration rapide

### 1. Email (obligatoire)
```bash
python setup_email.py
```

### 2. Ajouter un site à surveiller
Éditez `config.json` :
```json
{
  "sites": [
    {
      "name": "Mon site",
      "url": "https://example.com/produit",
      "selectors": {
        "title": "h1.title",
        "price": ".price",
        "availability": ".stock"
      },
      "keywords": ["produit", "mot-clé"],
      "use_selenium": false
    }
  ]
}
```

### 3. Tester
```bash
python test_universal.py config.json
```

### 4. Lancer
```bash
# Linux/Mac
./start_bot.sh

# Windows
start_bot.bat
```

## Exemples de configuration

### Site e-commerce classique
```json
{
  "name": "Amazon Produit",
  "url": "https://amazon.fr/dp/PRODUIT-ID",
  "selectors": {
    "title": "#productTitle",
    "price": ".a-price-whole",
    "availability": "#availability span"
  },
  "keywords": ["disponible", "en stock"],
  "use_selenium": false
}
```

### Site avec JavaScript
```json
{
  "name": "Site JS",
  "url": "https://site-moderne.com/produit",
  "selectors": {
    "title": "[data-testid='product-title']",
    "price": "[data-testid='price']",
    "availability": ".availability-status"
  },
  "keywords": ["disponible"],
  "use_selenium": true
}
```

## Commandes utiles

### Linux/Mac avec Makefile
```bash
make help        # Voir toutes les commandes
make install     # Installation complète
make test        # Tester la config
make run         # Lancer le bot
make status      # Statut du système
```

### Interface interactive
```bash
# Linux/Mac
./start_bot.sh

# Windows
start_bot.bat
```

Options disponibles :
- 🔍 **Tester** : Vérifier la configuration
- 🤖 **Lancer** : Démarrer la surveillance
- ⚙️ **Configurer** : Modifier les paramètres
- 📊 **Logs** : Voir l'activité
- 🔄 **Daemon** : Mode arrière-plan (Linux/Mac)

## Résolution de problèmes

### ❌ Python non trouvé ou version incorrecte
```bash
# Test de compatibilité
./test_compatibility.sh

# Linux/Mac
sudo apt install python3 python3-pip  # Ubuntu
brew install python3                   # Mac

# Windows
# Télécharger depuis python.org
# Le bot supporte Python 3.7+ (incluant 3.11+)
```

### ❌ Chrome non trouvé
```bash
# Linux
sudo apt install google-chrome-stable

# Mac
brew install --cask google-chrome

# Windows
# Télécharger depuis google.com/chrome
```

### ❌ Pas de produits trouvés
1. Vérifiez l'URL (accessible ?)
2. Testez les sélecteurs CSS dans le navigateur
3. Activez Selenium si le site utilise JavaScript
4. Vérifiez les mots-clés

### ❌ Erreur email
1. Vérifiez les paramètres SMTP
2. Activez "Applications moins sécurisées" (Gmail)
3. Utilisez un mot de passe d'application

## Support

- 📖 **Documentation complète** : [README.md](README.md)
- 🐛 **Signaler un bug** : [Issues GitHub](https://github.com/ettorhake/BotAlerte/issues)
- 💡 **Demander une fonctionnalité** : [Issues GitHub](https://github.com/ettorhake/BotAlerte/issues)
- 🤝 **Contribuer** : [CONTRIBUTING.md](CONTRIBUTING.md)

## Conseils pro

### 🎯 Sélecteurs CSS efficaces
- Préférez les ID : `#product-title`
- Utilisez les classes : `.price-current`
- Évitez les sélecteurs trop spécifiques
- Testez dans la console du navigateur : `document.querySelector('.price')`

### ⚡ Performance
- Utilisez `use_selenium: false` quand possible
- Ajustez `check_interval` selon vos besoins
- Groupez les sites similaires

### 🔒 Sécurité
- Ne commitez jamais `config.json` avec vos vraies données
- Utilisez des mots de passe d'application pour Gmail
- Gardez votre configuration privée

---

**Bon monitoring ! 🤖📊**