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

print_status "Arrêt des services n8n..."

# Arrêter les services
$COMPOSE_CMD stop

if [ $? -eq 0 ]; then
    print_success "Services arrêtés avec succès !"
    echo ""
    print_status "État des services :"
    $COMPOSE_CMD ps
    echo ""
    print_status "Pour redémarrer : ./start.sh"
    print_warning "Pour supprimer complètement (avec les données) : $COMPOSE_CMD down -v"
else
    print_error "Erreur lors de l'arrêt des services !"
    exit 1
fi
