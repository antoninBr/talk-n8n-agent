#!/bin/bash

# Couleurs pour l'affichage
RED='\033[0;31m'
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier si podman compose est disponible
if command -v podman compose &> /dev/null; then
    COMPOSE_CMD="podman compose"
elif command -v docker compose &> /dev/null; then
    COMPOSE_CMD="docker compose"
    print_warning "Utilisation de docker compose au lieu de podman compose"
else
    print_error "Ni podman compose ni docker compose ne sont disponibles !"
    exit 1
fi

print_warning "⚠️  ATTENTION: Ce script va supprimer tous les conteneurs et réseaux n8n"
print_warning "⚠️  Les volumes (données) seront préservés"
echo ""
read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Annulation..."
    exit 0
fi

print_status "Arrêt et suppression des conteneurs..."
$COMPOSE_CMD down

print_status "Nettoyage des réseaux orphelins..."
if command -v podman &> /dev/null; then
    podman network prune -f
else
    docker network prune -f
fi

print_status "Nettoyage des conteneurs arrêtés..."
if command -v podman &> /dev/null; then
    podman container prune -f
else
    docker container prune -f
fi

print_success "Nettoyage terminé !"
print_status "Vous pouvez maintenant redémarrer avec : ./start.sh"
