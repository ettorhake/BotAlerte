#!/usr/bin/env python3
"""
Universal Web Monitor Bot
Bot de surveillance web universel configurable pour surveiller 
n'importe quel site avec n'importe quels mots-clés.

Auteur: Assistant IA
Version: 2.0 - Universal Edition
"""

import requests
from bs4 import BeautifulSoup
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import schedule
import time
import logging
from datetime import datetime
import os
import json

# Import optionnel de Selenium pour le contenu JavaScript
try:
    from selenium import webdriver
    from selenium.webdriver.chrome.options import Options
    from selenium.webdriver.common.by import By
    from selenium.webdriver.support.ui import WebDriverWait
    from selenium.webdriver.support import expected_conditions as EC
    from selenium.common.exceptions import TimeoutException, WebDriverException
    SELENIUM_AVAILABLE = True
except ImportError:
    SELENIUM_AVAILABLE = False
from typing import List, Dict, Optional, Any
import sys
import random
import re
from urllib.parse import urljoin, urlparse
import hashlib

class UniversalWebMonitor:
    def __init__(self, config_file: str = 'config.json'):
        """Initialise le moniteur avec un fichier de configuration"""
        self.config = self.load_config(config_file)
        self.session = requests.Session()
        self.detected_products = self.load_detected_products()
        self.setup_logging()
        self.setup_session()
        
    def load_config(self, config_file: str) -> Dict[str, Any]:
        """Charge la configuration depuis un fichier JSON"""
        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                config = json.load(f)
            
            # Compléter avec les variables d'environnement si disponibles
            if not config['email_settings']['sender_email']:
                config['email_settings']['sender_email'] = os.getenv('SENDER_EMAIL', '')
            if not config['email_settings']['sender_password']:
                config['email_settings']['sender_password'] = os.getenv('SENDER_PASSWORD', '')
                
            return config
        except FileNotFoundError:
            logging.error(f"Fichier de configuration {config_file} non trouvé")
            sys.exit(1)
        except json.JSONDecodeError as e:
            logging.error(f"Erreur de parsing JSON dans {config_file}: {e}")
            sys.exit(1)
            
    def setup_logging(self):
        """Configure le système de logging"""
        log_level = getattr(logging, self.config['monitoring_settings']['log_level'])
        
        logging.basicConfig(
            level=log_level,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('universal_monitor.log', encoding='utf-8'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger(__name__)
        
        # Configuration Selenium
        self.use_selenium = (
            SELENIUM_AVAILABLE and 
            self.config.get('advanced_settings', {}).get('use_selenium', False)
        )
        
        if self.use_selenium:
            self.logger.info("🚀 Mode Selenium activé pour le contenu JavaScript")
        elif not SELENIUM_AVAILABLE and self.config.get('advanced_settings', {}).get('use_selenium', False):
            self.logger.warning("⚠️ Selenium demandé mais non disponible, utilisation de requests")
        
    def setup_session(self):
        """Configure la session HTTP"""
        # Headers par défaut
        default_headers = {
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        }
        
        self.session.headers.update(default_headers)
        
        # Configuration proxy si activé
        if self.config['advanced_settings']['use_proxy'] and self.config['advanced_settings']['proxy_url']:
            self.session.proxies = {
                'http': self.config['advanced_settings']['proxy_url'],
                'https': self.config['advanced_settings']['proxy_url']
            }
            
    def get_random_user_agent(self) -> str:
        """Retourne un User-Agent aléatoire si activé"""
        if not self.config['advanced_settings']['rotate_user_agents']:
            return "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            
        user_agents = [
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/91.0.864.59"
        ]
        return random.choice(user_agents)
    
    def fetch_page_selenium(self, url: str, site_name: str) -> Optional[BeautifulSoup]:
        """Récupère le contenu avec Selenium (JavaScript activé)"""
        try:
            # Configuration Chrome
            chrome_options = Options()
            
            if self.config.get('advanced_settings', {}).get('selenium_headless', True):
                chrome_options.add_argument('--headless')
            
            chrome_options.add_argument('--no-sandbox')
            chrome_options.add_argument('--disable-dev-shm-usage')
            chrome_options.add_argument('--disable-gpu')
            chrome_options.add_argument('--window-size=1920,1080')
            chrome_options.add_argument('--disable-blink-features=AutomationControlled')
            chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
            chrome_options.add_experimental_option('useAutomationExtension', False)
            
            # User Agent
            if self.config['advanced_settings']['rotate_user_agents']:
                user_agent = self.get_random_user_agent()
            else:
                user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            chrome_options.add_argument(f'--user-agent={user_agent}')
            
            driver = webdriver.Chrome(options=chrome_options)
            
            try:
                self.logger.info(f"🌐 Chargement Selenium de {site_name}: {url}")
                driver.get(url)
                
                # Attendre le chargement initial
                time.sleep(3)
                
                # Attendre que les éléments se chargent
                wait_seconds = self.config.get('advanced_settings', {}).get('selenium_wait_seconds', 10)
                try:
                    WebDriverWait(driver, wait_seconds).until(
                        lambda d: len(d.find_elements(By.CSS_SELECTOR, 
                            'div, article, li, section, [class*="product"], [class*="item"]'
                        )) > 5
                    )
                    self.logger.debug("✅ Éléments DOM chargés")
                except TimeoutException:
                    self.logger.warning("⏰ Timeout lors de l'attente des éléments DOM")
                
                # Scroll pour déclencher le lazy loading
                driver.execute_script("window.scrollTo(0, document.body.scrollHeight/3);")
                time.sleep(1)
                driver.execute_script("window.scrollTo(0, document.body.scrollHeight/2);")
                time.sleep(1)
                driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
                time.sleep(2)
                
                # Récupérer le HTML final
                html_content = driver.page_source
                soup = BeautifulSoup(html_content, 'html.parser')
                
                self.logger.info(f"Page {site_name} récupérée avec Selenium ({len(html_content)} bytes)")
                return soup
                
            finally:
                driver.quit()
                
        except WebDriverException as e:
            self.logger.error(f"❌ Erreur Selenium pour {site_name}: {e}")
            self.logger.info("🔄 Retour au mode requests classique")
            return None
        except Exception as e:
            self.logger.error(f"❌ Erreur inattendue Selenium pour {site_name}: {e}")
            return None
        
    def load_detected_products(self) -> Dict[str, List[str]]:
        """Charge la liste des produits déjà détectés par site"""
        try:
            if os.path.exists('detected_products.json'):
                with open('detected_products.json', 'r', encoding='utf-8') as f:
                    return json.load(f)
        except Exception as e:
            self.logger.error(f"Erreur lors du chargement des produits détectés: {e}")
        return {}
        
    def save_detected_products(self):
        """Sauvegarde la liste des produits détectés"""
        try:
            with open('detected_products.json', 'w', encoding='utf-8') as f:
                json.dump(self.detected_products, f, ensure_ascii=False, indent=2)
        except Exception as e:
            self.logger.error(f"Erreur lors de la sauvegarde: {e}")
            
    def generate_product_hash(self, product: Dict[str, str]) -> str:
        """Génère un hash unique pour un produit"""
        unique_string = f"{product.get('title', '')}{product.get('price', '')}{product.get('link', '')}"
        return hashlib.md5(unique_string.encode()).hexdigest()
        
    def fetch_page(self, website: Dict[str, Any]) -> Optional[BeautifulSoup]:
        """Récupère et parse une page web"""
        url = website['url']
        site_name = website['name']
        
        # Essayer d'abord avec Selenium si configuré
        if self.use_selenium:
            soup = self.fetch_page_selenium(url, site_name)
            if soup is not None:
                return soup
            # Si Selenium échoue, on continue avec requests
        
        try:
            self.logger.info(f"📄 Récupération requests de {site_name}: {url}")
            
            # Headers personnalisés pour ce site
            headers = {}
            if 'custom_headers' in website:
                headers.update(website['custom_headers'])
            if self.config['advanced_settings']['rotate_user_agents']:
                headers['User-Agent'] = self.get_random_user_agent()
                
            # Effectuer la requête avec retry
            for attempt in range(self.config['monitoring_settings']['retry_attempts']):
                try:
                    response = self.session.get(
                        url,
                        headers=headers,
                        timeout=self.config['monitoring_settings']['timeout_seconds']
                    )
                    response.raise_for_status()
                    break
                except requests.exceptions.RequestException as e:
                    if attempt == self.config['monitoring_settings']['retry_attempts'] - 1:
                        raise e
                    self.logger.warning(f"Tentative {attempt + 1} échouée, retry dans {self.config['monitoring_settings']['retry_delay_seconds']}s")
                    time.sleep(self.config['monitoring_settings']['retry_delay_seconds'])
            
            soup = BeautifulSoup(response.content, 'html.parser')
            self.logger.info(f"Page {site_name} récupérée avec succès ({len(response.content)} bytes)")
            return soup
            
        except requests.exceptions.RequestException as e:
            self.logger.error(f"Erreur lors de la récupération de {site_name}: {e}")
            return None
        except Exception as e:
            self.logger.error(f"Erreur inattendue pour {site_name}: {e}")
            return None
            
    def search_products(self, soup: BeautifulSoup, website: Dict[str, Any]) -> List[Dict[str, str]]:
        """Recherche les produits correspondants aux termes de recherche"""
        found_products = []
        search_terms = [term.lower() for term in website['search_terms']]
        exclude_terms = [term.lower() for term in self.config['advanced_settings']['exclude_terms']]
        selectors = website['selectors']
        
        try:
            # Recherche des conteneurs de produits
            product_elements = []
            for selector in selectors['product_containers']:
                elements = soup.select(selector)
                if elements:
                    product_elements.extend(elements)
                    self.logger.debug(f"Trouvé {len(elements)} éléments avec '{selector}'")
            
            # Si aucun conteneur spécifique trouvé, recherche globale dans le DOM
            if not product_elements:
                self.logger.info("Aucun conteneur spécifique trouvé, recherche globale dans le DOM")
                text_content = soup.get_text().lower()
                
                # Vérifier si au moins un terme de recherche est présent
                found_terms = []
                for search_term in search_terms:
                    if search_term in text_content:
                        found_terms.append(search_term)
                        self.logger.info(f"Terme '{search_term}' trouvé dans le contenu global")
                
                if found_terms:
                    # Méthode 1: Recherche dans les liens avec texte contenant le terme
                    links = soup.find_all('a', href=True)
                    for link in links:
                        link_text = link.get_text().lower()
                        if any(term in link_text for term in search_terms):
                            # Prendre l'élément parent le plus approprié (div, li, article, etc.)
                            parent = link.parent
                            while parent and parent.name in ['span', 'strong', 'em', 'b', 'i']:
                                parent = parent.parent
                            product_elements.append(parent if parent else link)
                    
                    # Méthode 2: Recherche dans tous les éléments texte contenant le terme
                    if not product_elements:
                        all_elements = soup.find_all(text=True)
                        for text_node in all_elements:
                            if any(term in text_node.lower() for term in search_terms):
                                element = text_node.parent
                                # Remonter jusqu'à un élément conteneur significatif
                                while element and element.name in ['span', 'strong', 'em', 'b', 'i', 'small']:
                                    element = element.parent
                                if element and element not in product_elements:
                                    product_elements.append(element)
                    
                    # Méthode 3: Recherche par attributs (title, alt, data-*, etc.)
                    if not product_elements:
                        for search_term in found_terms:
                            # Recherche dans les attributs title, alt, data-*
                            elements_with_attrs = soup.find_all(attrs=lambda x: x and any(
                                search_term in str(v).lower() for v in x.values() if v
                            ))
                            for elem in elements_with_attrs:
                                if elem not in product_elements:
                                    product_elements.append(elem)
                    
                    self.logger.info(f"Recherche globale: {len(product_elements)} éléments trouvés avec les termes {found_terms}")
                
                # Si toujours rien trouvé, créer un produit générique pour signaler la présence
                if found_terms and not product_elements:
                    self.logger.info("Création d'un produit générique pour signaler la présence du terme")
                    # Créer un élément fictif pour signaler qu'on a trouvé le terme quelque part
                    generic_product = soup.new_tag('div')
                    generic_product.string = f"Produit trouvé contenant: {', '.join(found_terms)}"
                    product_elements.append(generic_product)
            
            # Analyser chaque élément trouvé
            for element in product_elements:
                try:
                    element_text = element.get_text().lower()
                    
                    # Extraire d'abord les informations du produit
                    product_info = self.extract_product_info(element, selectors, website['url'])
                    if not product_info or not product_info['title']:
                        continue
                    
                    # Filtrage STRICT : vérifier que le terme recherché est dans le TITRE uniquement
                    title_lower = product_info['title'].lower()
                    
                    # Vérifier si le titre contient un terme recherché
                    if not any(term in title_lower for term in search_terms):
                        self.logger.debug(f"Produit exclu: '{product_info['title'][:50]}...' ne contient aucun terme recherché dans le titre")
                        continue
                        
                    # Vérifier si le titre contient un terme exclu
                    if any(exclude_term in title_lower for exclude_term in exclude_terms):
                        self.logger.debug(f"Produit exclu car le titre contient un terme banni: '{product_info['title'][:50]}...'")
                        continue
                    
                    found_products.append(product_info)
                        
                except Exception as e:
                    self.logger.debug(f"Erreur lors de l'analyse d'un élément: {e}")
                    continue
            
            self.logger.info(f"Trouvé {len(found_products)} produits correspondants")
            return found_products
            
        except Exception as e:
            self.logger.error(f"Erreur lors de la recherche de produits: {e}")
            return []
            
    def extract_product_info(self, element, selectors: Dict[str, List[str]], base_url: str) -> Optional[Dict[str, str]]:
        """Extrait les informations d'un produit depuis un élément HTML"""
        try:
            product_info = {
                'title': '',
                'price': '',
                'link': '',
                'description': '',
                'image': ''
            }
            
            # Extraction du titre
            for selector in selectors['title']:
                title_elem = element.select_one(selector)
                if title_elem:
                    product_info['title'] = title_elem.get_text().strip()
                    break
            
            # Si pas de titre spécifique, utiliser le texte de l'élément (tronqué)
            if not product_info['title']:
                full_text = element.get_text().strip()
                # Pour la recherche globale, essayer d'extraire une phrase pertinente
                if len(full_text) > 100:
                    # Chercher la première phrase contenant un terme de recherche
                    sentences = full_text.split('.')
                    for sentence in sentences:
                        if any(term in sentence.lower() for term in [t.lower() for t in element.get('data-search-terms', [])]):
                            product_info['title'] = sentence.strip()[:100]
                            break
                    if not product_info['title']:
                        product_info['title'] = full_text[:100] + "..." if len(full_text) > 100 else full_text
                else:
                    product_info['title'] = full_text
            
            # Extraction du prix
            for selector in selectors['price']:
                price_elem = element.select_one(selector)
                if price_elem:
                    product_info['price'] = price_elem.get_text().strip()
                    break
            
            # Extraction du lien
            for selector in selectors['link']:
                link_elem = element.select_one(selector)
                if link_elem and link_elem.get('href'):
                    href = link_elem['href']
                    product_info['link'] = urljoin(base_url, href)
                    break
            
            # Extraction de la description
            for selector in selectors.get('description', []):
                desc_elem = element.select_one(selector)
                if desc_elem:
                    product_info['description'] = desc_elem.get_text().strip()[:200]
                    break
            
            # Si pas de description spécifique, utiliser le texte de l'élément
            if not product_info['description']:
                product_info['description'] = element.get_text().strip()[:200]
            
            # Extraction de l'image (optionnel)
            img_elem = element.select_one('img')
            if img_elem and img_elem.get('src'):
                product_info['image'] = urljoin(base_url, img_elem['src'])
            
            return product_info if product_info['title'] else None
            
        except Exception as e:
            self.logger.debug(f"Erreur lors de l'extraction des infos produit: {e}")
            return None
            
    def send_email_alert(self, products_by_site: Dict[str, List[Dict[str, str]]]):
        """Envoie une alerte email pour tous les produits trouvés"""
        email_settings = self.config['email_settings']
        
        if not email_settings['sender_email'] or not email_settings['sender_password']:
            self.logger.info("📧 Configuration email non définie - pas d'envoi d'email")
            return True  # Ne pas considérer comme une erreur
            
        try:
            total_products = sum(len(products) for products in products_by_site.values())
            
            # Création du message
            msg = MIMEMultipart()
            msg['From'] = email_settings['sender_email']
            msg['To'] = ', '.join(email_settings['recipient_emails'])
            
            # Sujet personnalisé
            all_terms = set()
            for website in self.config['websites']:
                if website['enabled']:
                    all_terms.update(website['search_terms'])
            
            subject = f"🔍 ALERTE PRODUITS DÉTECTÉS ! ({total_products} produit(s) sur {len(products_by_site)} site(s))"
            msg['Subject'] = subject
            
            # Corps du message
            body = self.generate_email_body(products_by_site)
            msg.attach(MIMEText(body, 'plain', 'utf-8'))
            
            # Envoi de l'email
            server = smtplib.SMTP(email_settings['smtp_server'], email_settings['smtp_port'])
            server.starttls()
            server.login(email_settings['sender_email'], email_settings['sender_password'])
            
            for recipient in email_settings['recipient_emails']:
                server.sendmail(email_settings['sender_email'], recipient, msg.as_string())
            
            server.quit()
            
            self.logger.info(f"Email d'alerte envoyé à {len(email_settings['recipient_emails'])} destinataire(s)")
            return True
            
        except Exception as e:
            self.logger.error(f"Erreur lors de l'envoi de l'email: {e}")
            return False
            
    def generate_email_body(self, products_by_site: Dict[str, List[Dict[str, str]]]) -> str:
        """Génère le corps de l'email d'alerte"""
        total_products = sum(len(products) for products in products_by_site.values())
        
        body = f"""
🎯 ALERTE DE SURVEILLANCE WEB UNIVERSELLE
════════════════════════════════════════════════════════════════════════════════

Excellente nouvelle ! Le bot de surveillance a détecté {total_products} produit(s) correspondant à vos critères !

"""
        
        site_counter = 1
        for site_name, products in products_by_site.items():
            body += f"""
🌐 SITE {site_counter}: {site_name.upper()}
{'─' * 80}
{len(products)} produit(s) trouvé(s)

"""
            
            for i, product in enumerate(products, 1):
                body += f"""
PRODUIT {i}:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Titre: {product['title']}
💰 Prix: {product.get('price', 'Non spécifié')}
🔗 Lien: {product.get('link', 'Non disponible')}
📄 Description: {product.get('description', 'Aucune description')[:150]}...

"""
            site_counter += 1
        
        body += f"""
⚡ Dépêchez-vous, les bonnes affaires partent vite !

📊 RÉSUMÉ:
────────────────────────────────────────────────────────────────────────────────
• Total de produits trouvés: {total_products}
• Nombre de sites surveillés: {len(products_by_site)}
• Détection effectuée le: {datetime.now().strftime('%d/%m/%Y à %H:%M:%S')}

🔍 SITES SURVEILLÉS:
"""
        
        for website in self.config['websites']:
            if website['enabled']:
                body += f"• {website['name']}: {website['url']}\n"
                body += f"  Termes recherchés: {', '.join(website['search_terms'])}\n"
        
        body += f"""

Bonne chasse aux bonnes affaires ! 🎯

────────────────────────────────────────────────────────────────────────────────
Bot de surveillance web universel - Version 2.0
Configuration: {self.config.get('monitor_name', 'Configuration personnalisée')}
"""
        
        return body
        
    def check_all_websites(self):
        """Fonction principale de vérification de tous les sites"""
        self.logger.info("=" * 80)
        self.logger.info(f"🚀 DÉBUT DE LA SURVEILLANCE UNIVERSELLE - {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")
        self.logger.info(f"📋 Configuration: {self.config.get('monitor_name', 'Sans nom')}")
        
        new_products_by_site = {}
        
        try:
            enabled_websites = [site for site in self.config['websites'] if site['enabled']]
            self.logger.info(f"🌐 Surveillance de {len(enabled_websites)} site(s)")
            
            for website in enabled_websites:
                site_name = website['name']
                self.logger.info(f"🔍 Vérification de {site_name}...")
                
                try:
                    # Récupération de la page
                    soup = self.fetch_page(website)
                    if not soup:
                        self.logger.warning(f"⚠️ Impossible de récupérer {site_name}")
                        continue
                    
                    # Recherche des produits
                    found_products = self.search_products(soup, website)
                    
                    if found_products:
                        # Vérifier les nouveaux produits
                        site_key = f"{site_name}_{website['url']}"
                        if site_key not in self.detected_products:
                            self.detected_products[site_key] = []
                        
                        new_products = []
                        for product in found_products:
                            product_hash = self.generate_product_hash(product)
                            
                            if (not self.config['monitoring_settings']['avoid_duplicates'] or 
                                product_hash not in self.detected_products[site_key]):
                                
                                new_products.append(product)
                                self.detected_products[site_key].append(product_hash)
                                self.logger.info(f"✨ Nouveau produit: {product['title'][:50]}...")
                        
                        if new_products:
                            new_products_by_site[site_name] = new_products
                            self.logger.info(f"🎯 {len(new_products)} nouveau(x) produit(s) sur {site_name}")
                        else:
                            self.logger.info(f"ℹ️ Produits déjà connus sur {site_name}")
                    else:
                        self.logger.info(f"😴 Aucun produit trouvé sur {site_name}")
                
                except Exception as e:
                    self.logger.error(f"❌ Erreur lors de la vérification de {site_name}: {e}")
                
                # Délai entre les sites
                if len(enabled_websites) > 1:
                    delay = self.config['advanced_settings']['min_delay_between_sites']
                    if delay > 0:
                        self.logger.debug(f"⏱️ Attente {delay}s avant le site suivant")
                        time.sleep(delay)
            
            # Envoi des alertes si nouveaux produits
            if new_products_by_site:
                total_new = sum(len(products) for products in new_products_by_site.values())
                self.logger.info(f"🚨 ALERTE: {total_new} nouveau(x) produit(s) détecté(s) !")
                
                if self.send_email_alert(new_products_by_site):
                    self.save_detected_products()
                    self.logger.info("✅ Alerte envoyée et produits sauvegardés")
                else:
                    self.logger.error("❌ Échec de l'envoi d'alerte")
            else:
                self.logger.info("😴 Aucun nouveau produit détecté")
                
        except Exception as e:
            self.logger.error(f"❌ Erreur critique lors de la surveillance: {e}")
        
        self.logger.info(f"🏁 FIN DE LA SURVEILLANCE - {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")
        self.logger.info("=" * 80)
        
    def run_scheduler(self):
        """Lance le planificateur de surveillance"""
        monitor_name = self.config.get('monitor_name', 'Moniteur Universel')
        interval = self.config['monitoring_settings']['check_interval_hours']
        
        self.logger.info(f"🚀 DÉMARRAGE DU {monitor_name.upper()}")
        self.logger.info(f"📧 Destinataires: {', '.join(self.config['email_settings']['recipient_emails'])}")
        self.logger.info(f"🌐 Sites surveillés: {len([s for s in self.config['websites'] if s['enabled']])}")
        self.logger.info(f"⏰ Intervalle: {interval}h")
        
        # Afficher les sites surveillés
        for website in self.config['websites']:
            if website['enabled']:
                terms = ', '.join(website['search_terms'])
                self.logger.info(f"  • {website['name']}: [{terms}]")
        
        # Planifier la surveillance
        schedule.every(interval).hours.do(self.check_all_websites)
        
        # Première vérification immédiate
        self.logger.info("🔍 Lancement de la première vérification...")
        self.check_all_websites()
        
        # Boucle principale
        self.logger.info("🔄 Bot en cours d'exécution... (Ctrl+C pour arrêter)")
        try:
            while True:
                schedule.run_pending()
                time.sleep(60)
        except KeyboardInterrupt:
            self.logger.info("🛑 Arrêt du bot demandé par l'utilisateur")
        except Exception as e:
            self.logger.error(f"❌ Erreur dans la boucle principale: {e}")

def main():
    """Fonction principale"""
    config_file = sys.argv[1] if len(sys.argv) > 1 else 'config.json'
    
    if not os.path.exists(config_file):
        print(f"❌ Fichier de configuration {config_file} non trouvé")
        print("💡 Utilisez: python universal_monitor.py [config_file]")
        print("📝 Exemple: python universal_monitor.py woodbrass_digitakt.json")
        return
    
    try:
        monitor = UniversalWebMonitor(config_file)
        monitor.run_scheduler()
    except Exception as e:
        print(f"❌ Erreur critique: {e}")
        logging.error(f"Erreur critique: {e}")

if __name__ == "__main__":
    main()