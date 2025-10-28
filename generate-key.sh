#!/bin/bash

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_status "Génération d'une nouvelle clé de chiffrement pour n8n..."

# Générer une clé de 32 bytes en base64
NEW_KEY=$(openssl rand -base64 32)

if [ $? -eq 0 ]; then
    echo ""
    print_success "Nouvelle clé de chiffrement générée :"
    echo ""
    echo "N8N_ENCRYPTION_KEY=$NEW_KEY"
    echo ""
    print_warning "⚠️  IMPORTANT : Copiez cette clé dans votre fichier .env"
    print_warning "⚠️  Si vous changez cette clé après avoir créé des credentials,"
    print_warning "⚠️  vous perdrez l'accès à tous vos credentials existants !"
    echo ""
    print_status "Pour mettre à jour automatiquement le fichier .env :"
    echo "sed -i 's/^N8N_ENCRYPTION_KEY=.*/N8N_ENCRYPTION_KEY=$NEW_KEY/' .env"
else
    print_error "Erreur lors de la génération de la clé"
    exit 1
fi
