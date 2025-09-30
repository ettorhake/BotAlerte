#!/usr/bin/env python3
"""
Générateur de configuration pour le bot de surveillance universel
"""

import json
import os
from typing import Dict, List, Optional

class ConfigGenerator:
    def __init__(self):
        self.config = {
            "monitor_name": "",
            "description": "",
            "websites": [],
            "email_settings": {
                "sender_email": "",
                "sender_password": "",
                "recipient_emails": [],
                "smtp_server": "smtp.gmail.com",
                "smtp_port": 587
            },
            "monitoring_settings": {
                "check_interval_hours": 24,
                "max_products_per_alert": 10,
                "avoid_duplicates": True,
                "log_level": "INFO",
                "timeout_seconds": 30,
                "retry_attempts": 3,
                "retry_delay_seconds": 5
            },
            "advanced_settings": {
                "use_proxy": False,
                "proxy_url": "",
                "rotate_user_agents": True,
                "respect_robots_txt": True,
                "min_delay_between_sites": 10,
                "exclude_terms": []
            }
        }
    
    def interactive_setup(self):
        """Configuration interactive"""
        print("🔧 GÉNÉRATEUR DE CONFIGURATION - BOT UNIVERSEL")
        print("=" * 50)
        
        # Informations générales
        self.config["monitor_name"] = input("📝 Nom de votre surveillance: ") or "Mon Bot de Surveillance"
        self.config["description"] = input("📄 Description (optionnel): ") or ""
        
        # Configuration email
        print("\n📧 CONFIGURATION EMAIL")
        print("-" * 25)
        self.config["email_settings"]["sender_email"] = input("📮 Votre email Gmail (expéditeur): ")
        
        recipients = input("📨 Email(s) destinataire(s) (séparés par des virgules): ")
        self.config["email_settings"]["recipient_emails"] = [email.strip() for email in recipients.split(",")]
        
        # Sites web à surveiller
        print("\n🌐 SITES WEB À SURVEILLER")
        print("-" * 30)
        
        while True:
            website = self.configure_website()
            if website:
                self.config["websites"].append(website)
                
            more = input("\n➕ Ajouter un autre site ? (o/N): ").lower()
            if more not in ['o', 'oui', 'y', 'yes']:
                break
        
        # Paramètres de surveillance
        print("\n⏰ PARAMÈTRES DE SURVEILLANCE")
        print("-" * 35)
        
        interval = input("🕐 Intervalle de vérification en heures (défaut: 24): ")
        if interval.isdigit():
            self.config["monitoring_settings"]["check_interval_hours"] = int(interval)
        
        # Termes à exclure
        exclude = input("🚫 Termes à exclure (séparés par des virgules): ")
        if exclude:
            self.config["advanced_settings"]["exclude_terms"] = [term.strip() for term in exclude.split(",")]
        
        return self.config
    
    def configure_website(self) -> Optional[Dict]:
        """Configure un site web"""
        print("\n🔍 NOUVEAU SITE WEB")
        print("-" * 20)
        
        name = input("📛 Nom du site: ")
        if not name:
            return None
            
        url = input("🔗 URL à surveiller: ")
        if not url:
            return None
        
        search_terms_input = input("🎯 Termes à rechercher (séparés par des virgules): ")
        search_terms = [term.strip() for term in search_terms_input.split(",") if term.strip()]
        
        if not search_terms:
            print("⚠️ Aucun terme de recherche spécifié")
            return None
        
        website = {
            "name": name,
            "url": url,
            "enabled": True,
            "search_terms": search_terms,
            "selectors": self.get_default_selectors(),
            "custom_headers": {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            }
        }
        
        # Options avancées
        advanced = input("🔧 Configurer les sélecteurs CSS ? (o/N): ").lower()
        if advanced in ['o', 'oui', 'y', 'yes']:
            website["selectors"] = self.configure_selectors()
        
        return website
    
    def get_default_selectors(self) -> Dict[str, List[str]]:
        """Retourne les sélecteurs CSS par défaut"""
        return {
            "product_containers": [
                ".product-item", ".product-card", ".item", "[class*='product']",
                ".listing-item", ".grid-item", "[data-qa-id='aditem']",
                ".ad-item", ".annonce", ".listing"
            ],
            "title": [
                "h1", "h2", "h3", ".title", ".name", "[class*='title']",
                "[class*='name']", "[data-qa-id='aditem_title']"
            ],
            "price": [
                ".price", "[class*='price']", ".cost", "[class*='cost']",
                "[data-qa-id='aditem_price']", ".prix"
            ],
            "link": ["a[href]"],
            "description": [
                ".description", ".desc", "[class*='description']",
                ".item-description", ".ad-description"
            ]
        }
    
    def configure_selectors(self) -> Dict[str, List[str]]:
        """Configuration avancée des sélecteurs CSS"""
        print("\n🎯 CONFIGURATION DES SÉLECTEURS CSS")
        print("💡 Laissez vide pour utiliser les valeurs par défaut")
        print("-" * 45)
        
        selectors = self.get_default_selectors()
        
        for key, default_values in selectors.items():
            current_default = ", ".join(default_values[:3]) + "..."
            print(f"\n{key.replace('_', ' ').title()}:")
            print(f"Défaut: {current_default}")
            
            custom = input(f"Sélecteurs personnalisés (séparés par des virgules): ")
            if custom:
                selectors[key] = [s.strip() for s in custom.split(",") if s.strip()]
        
        return selectors
    
    def save_config(self, filename: str):
        """Sauvegarde la configuration"""
        try:
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(self.config, f, ensure_ascii=False, indent=2)
            print(f"✅ Configuration sauvegardée dans {filename}")
            return True
        except Exception as e:
            print(f"❌ Erreur lors de la sauvegarde: {e}")
            return False
    
    def generate_from_template(self, template_type: str):
        """Génère une configuration à partir d'un template"""
        templates = {
            "ecommerce": {
                "monitor_name": "Surveillance E-commerce",
                "description": "Surveillance de produits sur sites de vente",
                "websites": [{
                    "name": "Site E-commerce",
                    "url": "https://example.com/products",
                    "enabled": True,
                    "search_terms": ["produit recherché"],
                    "selectors": {
                        "product_containers": [".product", ".item"],
                        "title": ["h2", ".product-title"],
                        "price": [".price", ".cost"],
                        "link": ["a[href]"]
                    }
                }]
            },
            "classified_ads": {
                "monitor_name": "Surveillance Petites Annonces",
                "description": "Surveillance de petites annonces",
                "websites": [{
                    "name": "Site de petites annonces",
                    "url": "https://example.com/ads",
                    "enabled": True,
                    "search_terms": ["objet recherché"],
                    "selectors": {
                        "product_containers": [".ad-item", "[data-qa-id='aditem']"],
                        "title": [".ad-title", "h3"],
                        "price": [".price", ".prix"],
                        "link": ["a[href]"]
                    }
                }]
            },
            "marketplace": {
                "monitor_name": "Surveillance Marketplace",
                "description": "Surveillance de marketplace en ligne",
                "websites": [{
                    "name": "Marketplace",
                    "url": "https://example.com/marketplace",
                    "enabled": True,
                    "search_terms": ["article recherché"],
                    "selectors": {
                        "product_containers": [".listing", ".market-item"],
                        "title": [".listing-title", "h4"],
                        "price": [".price-display", ".price"],
                        "link": ["a[href]"]
                    }
                }]
            }
        }
        
        if template_type in templates:
            template = templates[template_type]
            self.config.update(template)
            return True
        return False

def main():
    generator = ConfigGenerator()
    
    print("🔧 GÉNÉRATEUR DE CONFIGURATION")
    print("=" * 40)
    print("1. Configuration interactive complète")
    print("2. Template E-commerce")
    print("3. Template Petites annonces") 
    print("4. Template Marketplace")
    print("0. Quitter")
    
    choice = input("\nChoisissez une option (1-4): ")
    
    if choice == "1":
        config = generator.interactive_setup()
    elif choice == "2":
        generator.generate_from_template("ecommerce")
        config = generator.config
    elif choice == "3":
        generator.generate_from_template("classified_ads")
        config = generator.config
    elif choice == "4":
        generator.generate_from_template("marketplace")
        config = generator.config
    else:
        print("Au revoir !")
        return
    
    # Sauvegarde
    filename = input("\n💾 Nom du fichier de configuration (défaut: ma_config.json): ") or "ma_config.json"
    if not filename.endswith('.json'):
        filename += '.json'
    
    if generator.save_config(filename):
        print("\n🎉 Configuration créée avec succès !")
        print(f"\nPour utiliser cette configuration :")
        print(f"python universal_monitor.py {filename}")
        
        # Afficher un résumé
        print(f"\n📋 RÉSUMÉ DE LA CONFIGURATION:")
        print(f"• Nom: {config['monitor_name']}")
        print(f"• Sites surveillés: {len(config['websites'])}")
        
        for site in config['websites']:
            terms = ', '.join(site['search_terms'])
            print(f"  - {site['name']}: [{terms}]")
        
        print(f"• Destinataires: {len(config['email_settings']['recipient_emails'])}")
        print(f"• Intervalle: {config['monitoring_settings']['check_interval_hours']}h")
        
        if not config['email_settings']['sender_email']:
            print("\n⚠️  N'oubliez pas de configurer vos identifiants email !")

if __name__ == "__main__":
    main()