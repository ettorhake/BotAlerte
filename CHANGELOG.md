# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-01-XX

### Ajouté
- **Support JavaScript/Selenium** : Surveillance des sites avec contenu dynamique
- **Installation automatique** : Scripts d'installation pour Linux, Mac et Windows
  - `install.sh` - Installation automatique Linux/Mac avec détection d'OS
  - `install.ps1` - Installation PowerShell Windows
  - `install.bat` - Installation Batch Windows
  - `Makefile` - Commandes make pour les développeurs
- **Interface utilisateur améliorée** :
  - `start_bot.sh` - Menu interactif Linux/Mac avec mode daemon
  - Menus colorés avec émojis et indicateurs de statut
  - Support des arguments CLI
- **Configuration universelle** : Système JSON pour surveiller plusieurs sites
- **Filtrage précis** : Recherche stricte par mots-clés dans les titres uniquement
- **Recherche globale DOM** : Fallback pour les sélecteurs CSS échoués
- **Système de logs complet** : Logging détaillé avec rotation
- **Prévention des doublons** : Système de cache pour éviter les alertes répétées
- **Documentation complète** : README détaillé avec guides d'installation

### Modifié
- **Architecture modulaire** : Refactorisation complète du code
- **Configuration générique** : Suppression de toutes les données personnelles
- **Gestion d'erreurs robuste** : Meilleure résilience aux pannes réseau
- **Performance optimisée** : Utilisation conditionnelle de Selenium
- **Compatibilité étendue** : Support multi-plateforme (Windows, Linux, Mac)

### Sécurité
- **Données sensibles** : Suppression complète des informations personnelles
- **Configuration externe** : Séparation des credentials du code source
- **Validation des entrées** : Vérification des paramètres de configuration

## [1.0.0] - 2024-01-XX

### Ajouté
- Version initiale du bot de surveillance
- Surveillance basique avec requests et BeautifulSoup
- Configuration par mots-clés
- Notifications par email
- Surveillance périodique avec schedule

### Fonctionnalités de base
- Parsing HTML statique
- Recherche par sélecteurs CSS
- Alertes email simples
- Configuration manuelle

---

## Types de modifications

- **Ajouté** : nouvelles fonctionnalités
- **Modifié** : modifications de fonctionnalités existantes
- **Déprécié** : fonctionnalités bientôt supprimées
- **Supprimé** : fonctionnalités supprimées
- **Corrigé** : corrections de bugs
- **Sécurité** : corrections de vulnérabilités