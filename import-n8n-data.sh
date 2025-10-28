#!/bin/bash

# Script d'import manuel des workflows et credentials n8n
set -e

echo "🔄 Import manuel des workflows et credentials n8n..."

# Fonction pour importer les credentials
import_credentials() {
    echo "📋 Import des credentials..."
    if [ -d "./credentials" ] && [ "$(ls -A ./credentials)" ]; then
        echo "  � Import du répertoire credentials"
        podman compose exec n8n n8n import:credentials --separate --input="/import/credentials" || echo "    ⚠️  Erreur lors de l'import des credentials"
        echo "✅ Import des credentials terminé"
    else
        echo "ℹ️  Aucun credential à importer"
    fi
}

# Fonction pour importer les workflows
import_workflows() {
    echo "🔄 Import des workflows..."
    if [ -d "./workflows" ] && [ "$(ls -A ./workflows)" ]; then
        echo "  � Import du répertoire workflows"
        podman compose exec n8n n8n import:workflow --separate --input="/import/workflows" || echo "    ⚠️  Erreur lors de l'import des workflows"
        echo "✅ Import des workflows terminé"
    else
        echo "ℹ️  Aucun workflow à importer"
    fi
}

# Vérifier que n8n est en cours d'exécution
if ! podman compose ps | grep -q "n8n.*Up"; then
    echo "❌ n8n n'est pas en cours d'exécution. Démarrez d'abord les services avec:"
    echo "   podman compose up -d"
    exit 1
fi

# Import des credentials
import_credentials

# Import des workflows
import_workflows

echo "🎉 Import manuel terminé!"
echo "💡 Conseil: Vous pouvez maintenant accéder à n8n sur http://localhost:5678"
