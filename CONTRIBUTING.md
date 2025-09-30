# Guide de contribution

Merci de votre intérêt pour contribuer à BotAlerte ! Ce guide vous aidera à comprendre comment participer au développement du projet.

## Comment contribuer

### 🐛 Signaler un bug

1. Vérifiez d'abord que le bug n'est pas déjà signalé dans les [Issues](https://github.com/ettorhake/BotAlerte/issues)
2. Créez une nouvelle issue avec le template "Bug Report"
3. Incluez :
   - Description détaillée du problème
   - Étapes pour reproduire
   - Version de Python et OS utilisés
   - Logs d'erreur si disponibles

### 💡 Proposer une nouvelle fonctionnalité

1. Ouvrez une issue avec le template "Feature Request"
2. Décrivez clairement :
   - Le problème que cela résoudrait
   - La solution proposée
   - Des alternatives considérées

### 🔧 Contribuer au code

1. **Fork** le repository
2. **Clone** votre fork :
   ```bash
   git clone https://github.com/votre-username/BotAlerte.git
   cd BotAlerte
   ```

3. **Créez une branche** pour votre contribution :
   ```bash
   git checkout -b feature/ma-nouvelle-fonctionnalite
   # ou
   git checkout -b fix/correction-bug
   ```

4. **Installez les dépendances de développement** :
   ```bash
   # Installation complète
   ./install.sh
   
   # Ou avec environnement virtuel
   make install-dev
   ```

5. **Développez votre fonctionnalité** :
   - Suivez les conventions de code Python (PEP 8)
   - Ajoutez des tests si applicable
   - Mettez à jour la documentation

6. **Testez vos modifications** :
   ```bash
   # Test de base
   make test
   
   # Test avec une configuration
   python test_universal.py config.json
   ```

7. **Committez vos changements** :
   ```bash
   git add .
   git commit -m "feat: ajouter surveillance des API REST"
   # ou
   git commit -m "fix: corriger le parsing des prix"
   ```

8. **Poussez votre branche** :
   ```bash
   git push origin feature/ma-nouvelle-fonctionnalite
   ```

9. **Créez une Pull Request** sur GitHub

## Standards de développement

### Convention de nommage des commits

Utilisez le format [Conventional Commits](https://www.conventionalcommits.org/) :

- `feat:` - Nouvelle fonctionnalité
- `fix:` - Correction de bug
- `docs:` - Documentation uniquement
- `style:` - Formatage, pas de changement de code
- `refactor:` - Refactorisation du code
- `test:` - Ajout ou modification de tests
- `chore:` - Maintenance, dépendances

Exemples :
```
feat: ajouter support pour les API GraphQL
fix: corriger l'encoding des emails avec accents
docs: améliorer le guide d'installation
refactor: optimiser la gestion des sélecteurs CSS
```

### Style de code

- **Python** : Suivre PEP 8
- **Longueur de ligne** : 88 caractères (Black formatter)
- **Imports** : Organisés selon PEP 8
- **Docstrings** : Format Google style

### Structure des fichiers

```
BotAlerte/
├── universal_monitor.py    # Code principal
├── config.json            # Configuration générique
├── setup_email.py          # Configuration email
├── test_universal.py       # Tests
├── requirements.txt        # Dépendances Python
├── install.sh             # Installation Linux/Mac
├── install.ps1            # Installation Windows PowerShell
├── install.bat            # Installation Windows Batch
├── start_bot.sh           # Interface Linux/Mac
├── start_bot.bat          # Interface Windows
├── Makefile              # Commandes développeur
├── logs/                 # Répertoire de logs
├── examples/             # Configurations d'exemple
└── docs/                 # Documentation supplémentaire
```

## Types de contributions recherchées

### 🎯 Priorité haute
- **Nouveaux parsers** : Support pour plus de sites e-commerce
- **Notifications** : Discord, Telegram, Slack, etc.
- **Interface web** : Dashboard de gestion
- **Tests automatisés** : Améliorer la couverture de tests

### 🔍 Priorité moyenne
- **Performance** : Optimisations et mise en cache
- **Configuration** : Interface graphique de configuration
- **Monitoring** : Métriques et monitoring du bot
- **Internationalisation** : Support multilingue

### 💡 Idées bienvenues
- **API REST** : Contrôle du bot via API
- **Base de données** : Historique des prix
- **Machine Learning** : Détection intelligente de produits
- **Mobile** : Application mobile

## Configuration de développement

### Environnement recommandé

```bash
# Cloner le projet
git clone https://github.com/ettorhake/BotAlerte.git
cd BotAlerte

# Installation avec environnement virtuel
make install-dev

# Activer l'environnement
source venv/bin/activate

# Tester l'installation
make test
```

### Outils utiles

- **Black** : Formatage automatique du code
- **Flake8** : Linting Python
- **pytest** : Framework de tests
- **pre-commit** : Hooks Git pour qualité du code

## Tests

### Tests existants

```bash
# Test de base
python test_universal.py config.json

# Test avec différentes configurations
python test_universal.py examples/audio_equipment.json
python test_universal.py examples/javascript_site.json
```

### Écrire de nouveaux tests

Ajoutez vos tests dans `test_universal.py` ou créez de nouveaux fichiers :

```python
def test_nouvelle_fonctionnalite():
    """Test de la nouvelle fonctionnalité."""
    # Votre test ici
    assert True
```

## Documentation

### README

Mettez à jour le README.md si votre contribution :
- Ajoute de nouvelles dépendances
- Change la configuration
- Ajoute de nouvelles fonctionnalités

### Code

Documentez votre code avec des docstrings :

```python
def nouvelle_fonction(param1: str, param2: int) -> bool:
    """
    Description de la fonction.
    
    Args:
        param1: Description du paramètre 1
        param2: Description du paramètre 2
        
    Returns:
        Description de la valeur de retour
    """
    return True
```

## Processus de review

1. **Vérification automatique** : Tests et linting
2. **Review code** : Examen par les mainteneurs
3. **Tests manuels** : Validation fonctionnelle
4. **Merge** : Intégration dans la branche principale

## Questions ?

- **Issues** : Pour les bugs et demandes de fonctionnalités
- **Discussions** : Pour les questions générales
- **Email** : contact@botale(rte.dev (si configuré)

## Code de conduite

Ce projet suit le [Contributor Covenant](https://www.contributor-covenant.org/). En participant, vous acceptez de respecter ce code.

---

**Merci de contribuer à BotAlerte ! 🤖✨**