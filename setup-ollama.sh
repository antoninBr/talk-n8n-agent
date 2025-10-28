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
if command -v podman &> /dev/null; then
    COMPOSE_CMD="podman compose"
elif command -v docker &> /dev/null; then
    COMPOSE_CMD="docker compose"
    print_warning "Utilisation de docker au lieu de podman"
else
    print_error "Ni podman compose ni docker compose ne sont disponibles !"
    exit 1
fi

print_status "Configuration d'Ollama pour la gestion d'emails d'assistance..."

# Vérifier qu'Ollama est démarré
print_status "Vérification du statut d'Ollama..."
if ! $COMPOSE_CMD ps | grep ollama | grep -q "Up"; then
    print_error "Le conteneur Ollama n'est pas démarré !"
    print_status "Démarrez d'abord l'environnement avec : ./start.sh"
    exit 1
fi

print_success "Ollama est prêt !"

# Modèles recommandés pour l'assistance utilisateur
echo ""
print_status "Modèles recommandés pour la gestion d'emails d'assistance :"
echo "1. qwen2.5:3b: (Léger, rapide, français correct)"
echo "2. nomic-embed-text (Spécialement conçu pour l'embedding, très rapide sur CPU)"
echo "3. granite3.2-vision:2b (Excellent pour 'extraction de documents)"
echo ""

read -p "Quel modèle voulez-vous installer ? (1-3, défaut: 1) " choice
choice=${choice:-1}

case $choice in
    1)
        MODEL="qwen2.5:3b"
        ;;
    2)
        MODEL="nomic-embed-text"
        ;;
    3)
        MODEL="granite3.2-vision:2b"
        ;;
    *)
        print_warning "Choix invalide, utilisation du modèle par défaut"
        MODEL="qwen2.5:3b"
        ;;
esac

print_status "Installation du modèle $MODEL..."
print_warning "⚠️  Cela peut prendre plusieurs minutes selon votre connexion internet"

if $COMPOSE_CMD exec ollama ollama pull $MODEL; then
    print_success "Modèle $MODEL installé avec succès !"

    echo ""
    print_status "Test du modèle..."
    $COMPOSE_CMD exec ollama ollama run $MODEL "Bonjour, peux-tu m'aider à rédiger une réponse professionnelle pour un email d'assistance ?"
    
    echo ""
    print_success "Configuration Ollama terminée !"
    print_status "Le modèle $MODEL est maintenant disponible sur http://localhost:11435"
    print_status "URL API Ollama : http://ollama:11434 (depuis n8n)"
    
else
    print_error "Erreur lors de l'installation du modèle $MODEL"
    exit 1
fi
