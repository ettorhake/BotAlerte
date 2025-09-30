#!/usr/bin/env python3
"""
Script de test pour le bot de surveillance universel
"""

import sys
import os
import json
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from universal_monitor import UniversalWebMonitor
import logging

# Configuration du logging pour les tests
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def test_config_loading(config_file: str = 'config.json'):
    """Test le chargement de la configuration"""
    print(f"🔧 Test de chargement de la configuration: {config_file}")
    
    try:
        if not os.path.exists(config_file):
            print(f"❌ Fichier {config_file} non trouvé")
            return False
            
        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        print("✅ Configuration chargée avec succès")
        print(f"   Nom: {config.get('monitor_name', 'Sans nom')}")
        print(f"   Sites activés: {len([s for s in config['websites'] if s.get('enabled', True)])}")
        print(f"   Total sites: {len(config['websites'])}")
        
        # Vérifier les sites activés
        for site in config['websites']:
            if site.get('enabled', True):
                terms = ', '.join(site['search_terms'])
                print(f"   • {site['name']}: [{terms}]")
        
        return True
        
    except json.JSONDecodeError as e:
        print(f"❌ Erreur de format JSON: {e}")
        return False
    except Exception as e:
        print(f"❌ Erreur lors du chargement: {e}")
        return False

def test_website_access(config_file: str = 'config.json'):
    """Test l'accès aux sites web configurés"""
    print(f"\n🌐 Test d'accès aux sites web")
    
    try:
        monitor = UniversalWebMonitor(config_file)
        
        enabled_sites = [site for site in monitor.config['websites'] if site.get('enabled', True)]
        success_count = 0
        
        for site in enabled_sites:
            print(f"\n🔍 Test de {site['name']}...")
            print(f"   URL: {site['url']}")
            
            soup = monitor.fetch_page(site)
            if soup:
                print("   ✅ Accès réussi")
                print(f"   📊 Taille: {len(str(soup))} caractères")
                success_count += 1
            else:
                print("   ❌ Accès échoué")
        
        print(f"\n📊 Résultat: {success_count}/{len(enabled_sites)} sites accessibles")
        return success_count == len(enabled_sites)
        
    except Exception as e:
        print(f"❌ Erreur lors du test d'accès: {e}")
        return False

def test_search_functionality(config_file: str = 'config.json'):
    """Test la fonctionnalité de recherche"""
    print(f"\n🔍 Test de la fonctionnalité de recherche")
    
    try:
        monitor = UniversalWebMonitor(config_file)
        
        enabled_sites = [site for site in monitor.config['websites'] if site.get('enabled', True)]
        
        for site in enabled_sites:
            print(f"\n🎯 Test de recherche sur {site['name']}...")
            print(f"   Termes: {', '.join(site['search_terms'])}")
            
            soup = monitor.fetch_page(site)
            if not soup:
                print("   ⚠️ Site inaccessible, test ignoré")
                continue
            
            products = monitor.search_products(soup, site)
            print(f"   📦 Produits trouvés: {len(products)}")
            
            if products:
                print("   📋 Exemples de produits:")
                for i, product in enumerate(products[:3], 1):
                    title = product['title'][:50] + "..." if len(product['title']) > 50 else product['title']
                    print(f"   {i}. {title}")
                    if product.get('price'):
                        print(f"      💰 Prix: {product['price']}")
                    if product.get('link'):
                        print(f"      🔗 Lien: {product['link'][:60]}...")
        
        return True
        
    except Exception as e:
        print(f"❌ Erreur lors du test de recherche: {e}")
        return False

def test_email_config(config_file: str = 'config.json'):
    """Test la configuration email"""
    print(f"\n📧 Test de la configuration email")
    
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        email_settings = config['email_settings']
        
        if not email_settings['sender_email']:
            sender_email = os.getenv('SENDER_EMAIL', '')
            if not sender_email:
                print("❌ Adresse email expéditeur non configurée")
                print("   💡 Configurez SENDER_EMAIL ou modifiez config.json")
                return False
            else:
                print(f"✅ Email expéditeur (env): {sender_email}")
        else:
            print(f"✅ Email expéditeur (config): {email_settings['sender_email']}")
        
        if not email_settings['sender_password']:
            sender_password = os.getenv('SENDER_PASSWORD', '')
            if not sender_password:
                print("❌ Mot de passe email non configuré")
                print("   💡 Configurez SENDER_PASSWORD ou modifiez config.json")
                return False
            else:
                print("✅ Mot de passe email configuré (env)")
        else:
            print("✅ Mot de passe email configuré (config)")
        
        recipients = email_settings['recipient_emails']
        print(f"✅ Destinataires: {len(recipients)}")
        for recipient in recipients:
            print(f"   • {recipient}")
        
        return True
        
    except Exception as e:
        print(f"❌ Erreur lors du test email: {e}")
        return False

def test_file_permissions():
    """Test les permissions de fichiers"""
    print(f"\n📁 Test des permissions de fichiers")
    
    try:
        # Test d'écriture des logs
        with open('test_universal_monitor.log', 'w', encoding='utf-8') as f:
            f.write('test log')
        os.remove('test_universal_monitor.log')
        print("✅ Permissions log OK")
        
        # Test d'écriture JSON
        test_data = {"test": "data"}
        with open('test_detected_products.json', 'w', encoding='utf-8') as f:
            json.dump(test_data, f)
        os.remove('test_detected_products.json')
        print("✅ Permissions JSON OK")
        
        return True
        
    except Exception as e:
        print(f"❌ Erreur de permissions: {e}")
        return False

def run_demo_search(config_file: str = 'config.json'):
    """Exécute une recherche de démonstration"""
    print(f"\n🎬 DÉMONSTRATION DE RECHERCHE")
    print("=" * 50)
    
    try:
        monitor = UniversalWebMonitor(config_file)
        print(f"🚀 Lancement de la surveillance avec: {config_file}")
        monitor.check_all_websites()
        print("✅ Démonstration terminée")
        return True
        
    except Exception as e:
        print(f"❌ Erreur lors de la démonstration: {e}")
        return False

def main():
    """Fonction principale de test"""
    config_file = sys.argv[1] if len(sys.argv) > 1 else 'config.json'
    
    print("🧪 TESTS DU BOT DE SURVEILLANCE UNIVERSEL")
    print("=" * 60)
    print(f"📋 Configuration utilisée: {config_file}")
    print("=" * 60)
    
    if not os.path.exists(config_file):
        print(f"❌ Fichier de configuration {config_file} non trouvé")
        print("\n💡 Fichiers de configuration disponibles:")
        
        json_files = [f for f in os.listdir('.') if f.endswith('.json')]
        if json_files:
            for f in json_files:
                print(f"   • {f}")
        else:
            print("   Aucun fichier .json trouvé")
        
        print(f"\n🔧 Pour créer une configuration:")
        print(f"   python config_generator.py")
        return
    
    tests = [
        ("Chargement de la configuration", lambda: test_config_loading(config_file)),
        ("Accès aux sites web", lambda: test_website_access(config_file)),
        ("Fonctionnalité de recherche", lambda: test_search_functionality(config_file)),
        ("Configuration email", lambda: test_email_config(config_file)),
        ("Permissions de fichiers", test_file_permissions)
    ]
    
    results = []
    
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ Erreur dans le test '{test_name}': {e}")
            results.append((test_name, False))
    
    # Résumé des résultats
    print("\n" + "=" * 60)
    print("📊 RÉSUMÉ DES TESTS")
    print("=" * 60)
    
    passed = 0
    for test_name, result in results:
        status = "✅ PASSÉ" if result else "❌ ÉCHOUÉ"
        print(f"{status:12} | {test_name}")
        if result:
            passed += 1
    
    print(f"\nRésultat global: {passed}/{len(results)} tests réussis")
    
    if passed == len(results):
        print("\n🎉 Tous les tests sont passés ! Le bot est prêt à être utilisé.")
        
        # Proposer une démonstration
        demo = input("\n🎬 Voulez-vous lancer une démonstration de recherche ? (o/N): ").lower()
        if demo in ['o', 'oui', 'y', 'yes']:
            run_demo_search(config_file)
        
        print(f"\n🚀 Pour lancer le bot en continu:")
        print(f"   python universal_monitor.py {config_file}")
        
    else:
        print("\n⚠️  Certains tests ont échoué. Vérifiez la configuration.")
        
        if not any(result for name, result in results if "email" in name.lower()):
            print("\n💡 Pour configurer l'email :")
            print("   • Modifiez votre fichier de configuration")
            print("   • Ou utilisez les variables d'environnement SENDER_EMAIL et SENDER_PASSWORD")

if __name__ == "__main__":
    main()