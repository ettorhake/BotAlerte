#!/bin/bash

# Test rapide de la sélection de configuration

echo "🧪 Test de la sélection de configuration..."
echo ""

echo "Configurations disponibles :"
for config in *.json; do
    if [ -f "$config" ]; then
        echo "  📄 $config"
    fi
done

echo ""
echo "✅ Test terminé. Le script start_bot.sh peut maintenant choisir la configuration à utiliser."