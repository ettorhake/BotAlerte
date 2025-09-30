#!/usr/bin/env python3
"""
Configuration de l'email pour le bot de surveillance universel
"""

import json
import getpass
import os
from pathlib import Path

def setup_email_config():
    """Configure l'email dans le fichier de configuration"""
    
    print("🔧 CONFIGURATION EMAIL POUR LE BOT UNIVERSEL")
    print("=" * 50)
    
    # Charger la configuration existante
    config_file = "config.json"
    if not os.path.exists(config_file):
        print(f"❌ Fichier {config_file} introuvable")
        return
    
    with open(config_file, 'r', encoding='utf-8') as f:
        config = json.load(f)
    
    print(f"📋 Configuration actuelle: {config['monitor_name']}")
    print()
    
    # Configuration email
    print("📧 Configuration de l'email expéditeur:")
    print("💡 Utilisez votre email Gmail et un mot de passe d'application")
    print("   (Pas votre mot de passe principal)")
    print()
    
    sender_email = input("Email expéditeur (Gmail recommandé): ").strip()
    if not sender_email:
        print("❌ Email requis")
        return
    
    sender_password = getpass.getpass("Mot de passe d'application: ").strip()
    if not sender_password:
        print("❌ Mot de passe requis")
        return
    
    # Mettre à jour la configuration
    config['email_settings']['sender_email'] = sender_email
    config['email_settings']['sender_password'] = sender_password
    
    # Sauvegarder
    with open(config_file, 'w', encoding='utf-8') as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    
    print("✅ Configuration email mise à jour")
    
    # Test optionnel
    test = input("\n🧪 Tester l'envoi d'email maintenant ? (y/N): ").strip().lower()
    if test == 'y' or test == 'yes':
        test_email(config)

def test_email(config):
    """Teste l'envoi d'email"""
    import smtplib
    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart
    
    print("\n📧 Test d'envoi d'email...")
    
    try:
        # Configuration
        smtp_server = config['email_settings']['smtp_server']
        smtp_port = config['email_settings']['smtp_port']
        sender_email = config['email_settings']['sender_email']
        sender_password = config['email_settings']['sender_password']
        recipient_email = config['email_settings']['recipient_emails'][0]
        
        # Créer le message
        msg = MIMEMultipart()
        msg['From'] = sender_email
        msg['To'] = recipient_email
        msg['Subject'] = "🧪 Test Bot Universel - Configuration Email"
        
        body = f"""
        Félicitations ! 🎉
        
        Votre bot de surveillance universel est maintenant configuré et prêt !
        
        Configuration testée:
        • Email expéditeur: {sender_email}
        • Email destinataire: {recipient_email}
        • Serveur SMTP: {smtp_server}:{smtp_port}
        
        Le bot peut maintenant surveiller:
        """
        
        for website in config['websites']:
            if website['enabled']:
                body += f"\n        • {website['name']}: {', '.join(website['search_terms'])}"
        
        body += f"""
        
        Fréquence de vérification: {config['check_interval_hours']}h
        
        Bot de Surveillance Universel v2.0
        """
        
        msg.attach(MIMEText(body, 'plain', 'utf-8'))
        
        # Envoyer
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(sender_email, sender_password)
        text = msg.as_string()
        server.sendmail(sender_email, recipient_email, text)
        server.quit()
        
        print("✅ Email de test envoyé avec succès !")
        print(f"📨 Vérifiez votre boîte mail: {recipient_email}")
        
    except Exception as e:
        print(f"❌ Erreur lors de l'envoi: {e}")
        print("💡 Vérifiez:")
        print("   • Votre email et mot de passe d'application")
        print("   • La connexion internet")
        print("   • Les paramètres Gmail (authentification à deux facteurs activée)")

def show_gmail_help():
    """Affiche l'aide pour configurer Gmail"""
    print("\n📱 AIDE: Comment créer un mot de passe d'application Gmail")
    print("=" * 55)
    print("1. Activez l'authentification à deux facteurs sur votre compte Google")
    print("2. Allez dans les paramètres de votre compte Google")
    print("3. Sécurité → Mots de passe d'application")
    print("4. Créez un nouveau mot de passe d'application pour 'Autre'")
    print("5. Utilisez ce mot de passe (16 caractères) ici")
    print()
    print("🔗 URL directe: https://myaccount.google.com/apppasswords")
    print()

if __name__ == "__main__":
    print("🔧 ASSISTANT DE CONFIGURATION EMAIL")
    print("=" * 40)
    
    choice = input("Choisissez une option:\n1. Configurer l'email\n2. Aide Gmail\nChoix (1-2): ").strip()
    
    if choice == "1":
        setup_email_config()
    elif choice == "2":
        show_gmail_help()
        input("\nAppuyez sur Entrée pour continuer...")
        setup_email_config()
    else:
        print("❌ Choix invalide")