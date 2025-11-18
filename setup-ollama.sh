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
    CONTAINER_CMD="podman"
    COMPOSE_SUBCMD="compose"
elif command -v docker compose &> /dev/null; then
    CONTAINER_CMD="docker"
    COMPOSE_SUBCMD="compose"
    print_warning "Utilisation de docker au lieu de podman"
else
    print_error "Ni podman compose ni docker compose ne sont disponibles !"
    exit 1
fi

print_status "Configuration d'Ollama pour la gestion d'emails d'assistance..."

# Vérifier qu'Ollama est démarré
print_status "Vérification du statut d'Ollama..."
if ! $CONTAINER_CMD $COMPOSE_SUBCMD ps | grep ollama | grep -q "Up"; then
    print_error "Le conteneur Ollama n'est pas démarré !"
    print_status "Démarrez d'abord l'environnement avec : ./start.sh"
    exit 1
fi

print_success "Ollama est prêt !"

# Modèles recommandés pour l'assistance utilisateur
MODELS="qwen2.5:0.5b|qwen2.5:3b-instruct-q4_K_M|nomic-embed-text|granite3.2-vision:2b"
MODEL_DESCRIPTIONS="Tres léger, rapide, français correct et optimisé CPU|Moyennement léger, rapide, français correct et optimisé CPU|Spécialement conçu pour l'embedding, très rapide sur CPU|Excellent pour l'extraction de documents"

echo ""
print_status "Installation des modèles :"

# Afficher la liste des modèles
model_count=1
IFS='|'
set -- $MODELS
for model in "$@"; do
    description=$(echo "$MODEL_DESCRIPTIONS" | cut -d'|' -f$model_count)
    echo "$model_count. $model ($description)"
    model_count=$((model_count + 1))
done
unset IFS

echo ""
print_warning "⚠️  L'installation peut prendre plusieurs minutes selon votre connexion internet"
echo ""

# Installation de tous les modèles
FAILED_MODELS=""
SUCCESSFUL_MODELS=""
model_num=0
total_models=$(echo "$MODELS" | tr '|' '\n' | wc -l)

IFS='|'
set -- $MODELS
for MODEL in "$@"; do
    model_num=$((model_num + 1))
    print_status "Installation du modèle $MODEL ($model_num/$total_models)..."
    
    if $CONTAINER_CMD $COMPOSE_SUBCMD exec ollama ollama pull "$MODEL"; then
        print_success "Modèle $MODEL installé avec succès !"
        if [ -z "$SUCCESSFUL_MODELS" ]; then
            SUCCESSFUL_MODELS="$MODEL"
        else
            SUCCESSFUL_MODELS="$SUCCESSFUL_MODELS|$MODEL"
        fi
    else
        print_error "Erreur lors de l'installation du modèle $MODEL"
        if [ -z "$FAILED_MODELS" ]; then
            FAILED_MODELS="$MODEL"
        else
            FAILED_MODELS="$FAILED_MODELS|$MODEL"
        fi
    fi
    echo ""
done
unset IFS

# Résumé de l'installation
echo ""
print_status "Résumé de l'installation :"

if [ -n "$SUCCESSFUL_MODELS" ]; then
    successful_count=$(echo "$SUCCESSFUL_MODELS" | tr '|' '\n' | wc -l)
    print_success "Modèles installés avec succès ($successful_count) :"
    IFS='|'
    set -- $SUCCESSFUL_MODELS
    for model in "$@"; do
        echo "  ✅ $model"
    done
    unset IFS
fi

if [ -n "$FAILED_MODELS" ]; then
    failed_count=$(echo "$FAILED_MODELS" | tr '|' '\n' | wc -l)
    print_warning "Modèles ayant échoué ($failed_count) :"
    IFS='|'
    set -- $FAILED_MODELS
    for model in "$@"; do
        echo "  ❌ $model"
    done
    unset IFS
fi

echo ""
if [ -n "$SUCCESSFUL_MODELS" ]; then
    # Test avec le premier modèle installé
    TEST_MODEL=$(echo "$SUCCESSFUL_MODELS" | cut -d'|' -f1)
    print_status "Test du modèle $TEST_MODEL..."
    $CONTAINER_CMD $COMPOSE_SUBCMD exec ollama ollama run "$TEST_MODEL" "Bonjour, peux-tu m'aider dans mon travail ?"
    
    echo ""
    print_success "Configuration Ollama terminée !"
    print_status "Modèles disponibles sur http://localhost:11435"
    print_status "URL API Ollama : http://ollama:11434 (depuis n8n)"
else
    print_error "Aucun modèle n'a pu être installé !"
    exit 1
fi
