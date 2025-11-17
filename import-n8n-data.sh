#!/bin/bash

# Script d'import manuel des workflows et credentials n8n
set -e

# Définition des couleurs
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

echo "🔄 Import manuel des workflows et credentials n8n..."

# Vérifier si podman compose est disponible
if command -v podman &> /dev/null; then
    COMPOSE_CMD="podman compose"
elif command -v docker &> /dev/null; then
    COMPOSE_CMD="docker compose"
    print_warning "Utilisation de docker au lieu de podman"
else
    print_error "Ni podman compose ni docker compose ne sont disponibles !"
    exit 1
fi

# Fonction pour importer les credentials
import_credentials() {
    echo "📋 Import des credentials..."
    if [ -d "./credentials" ] && [ "$(ls -A ./credentials)" ]; then
        echo "  📂 Import du répertoire credentials"
        $COMPOSE_CMD exec n8n n8n import:credentials --separate --input="/import/credentials" || echo "    ⚠️  Erreur lors de l'import des credentials"
        print_success "✅ Import des credentials terminé"
    else
        echo "ℹ️  Aucun credential à importer"
    fi
}

# Fonction pour importer les workflows
import_workflows() {
    echo "🔄 Import des workflows..."
    if [ -d "./workflows" ] && [ "$(ls -A ./workflows)" ]; then
        echo "  📂 Import du répertoire workflows (avec activation automatique)"
        $COMPOSE_CMD exec n8n n8n import:workflow --separate --active --input="/import/workflows" || echo "    ⚠️  Erreur lors de l'import des workflows"
        print_success "✅ Import des workflows terminé et activés"
    else
        echo "ℹ️  Aucun workflow à importer"
    fi
}


# Vérifier que n8n est en cours d'exécution
if ! $COMPOSE_CMD ps | grep -q "n8n.*Up"; then
    print_warning "❌ n8n n'est pas en cours d'exécution. Démarrez d'abord les services avec:"
    echo "   $COMPOSE_CMD up -d"
    exit 1
fi

# Import des credentials
import_credentials

# Import des workflows (avec activation automatique)
import_workflows

echo "🎉 Import manuel terminé!"
echo "💡 Conseil: Vous pouvez maintenant accéder à n8n sur http://localhost:5678"
echo "🚀 Les workflows ont été importés et activés automatiquement"
