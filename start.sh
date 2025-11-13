#!/bin/bash

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
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

# Options
IMPORT_DATA=false
INIT_COLLECTIONS=false
SETUP_OLLAMA=false

# Parse des arguments
while [ $# -gt 0 ]; do
    case $1 in
        --import)
            IMPORT_DATA=true
            shift
            ;;
        --init-collections)
            INIT_COLLECTIONS=true
            shift
            ;;
        --setup-ollama)
            SETUP_OLLAMA=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --import            Import automatiquement les workflows et credentials après le démarrage"
            echo "  --init-collections  Initialiser les collections après le démarrage"
            echo "  --setup-ollama      Installer automatiquement les modèles Ollama recommandés"
            echo "  -h, --help          Affiche cette aide"
            exit 0
            ;;
        *)
            print_error "Option inconnue: $1"
            echo "Utilisez -h ou --help pour voir les options disponibles"
            exit 1
            ;;
    esac
done

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier que le fichier .env existe
if [ ! -f ".env" ]; then
    print_error "Le fichier .env n'existe pas !"
    exit 1
fi

# Vérifier si podman-compose est disponible
if command -v podman compose &> /dev/null; then
    COMPOSE_CMD="podman compose"
elif command -v docker compose &> /dev/null; then
    COMPOSE_CMD="docker compose"
    print_warning "Utilisation de docker compose au lieu de podman compose"
else
    print_error "Ni podman compose ni docker compose ne sont disponibles !"
    exit 1
fi

print_status "Utilisation de : $COMPOSE_CMD"

# Vérifier les mots de passe par défaut
if grep -q "changeme123!" .env; then
    print_warning "⚠️  Vous utilisez encore des mots de passe par défaut !"
    print_warning "⚠️  Veuillez modifier le fichier .env avant de continuer"
    echo ""
    echo "Mots de passe à changer :"
    echo "- POSTGRES_PASSWORD"
    echo "- POSTGRES_NON_ROOT_PASSWORD"
    echo "- N8N_ENCRYPTION_KEY"
    echo ""
    read -p "Voulez-vous continuer quand même ? (y/N) " -r REPLY
    echo
    if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]; then
        exit 1
    fi
fi

print_status "Démarrage des services n8n avec PostgreSQL..."

# Démarrer les services
$COMPOSE_CMD up -d

if [ $? -eq 0 ]; then
    print_success "Services démarrés avec succès !"
    echo ""
    print_status "Vérification de l'état des services..."
    $COMPOSE_CMD ps
    echo ""
    print_status "n8n sera accessible sur : http://localhost:5678"
    print_status "Ollama sera accessible sur : http://localhost:11435"
    print_status "Dashboard Qdrant sera accessible sur : http://localhost:6333/dashboard#/"
    print_status "Chat sera disponible  sur : https://localhost:8443"
    print_status "MCP Server playwright sera disponible  sur : http://localhost:3333"
    print_status "Attendez quelques secondes pour que tous les services soient complètement démarrés"
    echo ""
    
    # Import automatique des données si demandé
    if [ "$IMPORT_DATA" = true ]; then
        print_status "Import automatique des workflows et credentials..."
        sleep 10  # Attendre que n8n soit complètement démarré
        
        if [ -f "./import-n8n-data.sh" ]; then
            ./import-n8n-data.sh
        else
            print_warning "Script d'import non trouvé, import manuel nécessaire"
        fi
    else
        print_status "💡 Pour importer vos workflows et credentials automatiquement: ./start.sh --import"
        print_status "💡 Pour importer manuellement plus tard: ./import-n8n-data.sh"
    fi

    # Initialisation des collections si demandé
    if [ "$INIT_COLLECTIONS" = true ]; then
        print_status "Initialisation des collections..."
        if [ -f "./setup-collections.sh" ]; then
            ./setup-collections.sh
        else
            print_warning "Script d'initialisation des collections non trouvé, initialisation manuelle nécessaire"
        fi
    fi

    # Configuration d'Ollama si demandé
    if [ "$SETUP_OLLAMA" = true ]; then
        print_status "Configuration automatique d'Ollama..."
        sleep 15  # Attendre qu'Ollama soit complètement démarré
        
        if [ -f "./setup-ollama.sh" ]; then
            ./setup-ollama.sh
        else
            print_warning "Script de configuration Ollama non trouvé, configuration manuelle nécessaire"
        fi
    fi
    
    echo ""
    if [ "$SETUP_OLLAMA" != true ]; then
        print_status "💡 Pour configurer Ollama automatiquement: ./start.sh --setup-ollama"
        print_status "💡 Pour configurer Ollama manuellement: ./setup-ollama.sh"
    fi
    print_status "Pour voir les logs n8n : $COMPOSE_CMD logs -f n8n"
    print_status "Pour arrêter : $COMPOSE_CMD stop"
else
    print_error "Erreur lors du démarrage des services !"
    exit 1
fi
