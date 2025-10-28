# 🎤 Talk n8n Agent - IA locales ou distantes, outils, et un chef d'orchestre nommé n8n

Démo et présentation sur l'orchestration d'agents IA avec n8n.

## 📝 À propos

Cette démonstration illustre comment créer un assistant IA intelligent en orchestrant des modèles locaux et distants avec n8n, incluant :

- 🤖 **Chat assistant** avec streaming en temps réel
- 📚 **Système RAG** (Retrieval-Augmented Generation) avec Qdrant
- 🔧 **Interface d'administration** pour la gestion des données
- 🐋 **Stack complète dockerisée** pour un déploiement facile

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Chat Web UI   │    │      n8n        │    │    Qdrant       │
│   (Nginx:8080)  │◄──►│   (Port 5678)   │◄──►│  Vector Store   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                       ┌─────────────────┐
                       │   PostgreSQL    │
                       │   (Stockage)    │
                       └─────────────────┘
                                │
                       ┌─────────────────┐
                       │     Ollama      │
                       │  (IA locale)    │
                       └─────────────────┘
```

## 🚀 Démarrage rapide

### Prérequis

- Docker & Docker Compose
- 8 Go de RAM minimum (recommandé: 16 Go)
- 10 Go d'espace disque libre

### 1. Cloner et configurer

```bash
git clone https://github.com/antoninBr/talk-n8n-agent.git
cd talk-n8n-agent

# Générer les clés et configuration
./generate-key.sh
```

### 2. Lancer la stack complète

```bash
# Démarrage automatique avec script
./start.sh

# OU démarrage manuel
docker compose up -d
```

### 3. Accéder aux services

- **🎨 Chat Assistant** : http://localhost:8443 ou http://localhost:8080
- **⚙️ Interface n8n** : http://localhost:5678
- **📊 Qdrant** : http://localhost:6333
- **📊 Ollama** : http://localhost:11435

### 4. Import des workflows (optionnel)

```bash
# Importer les workflows n8n préconfigurés
./import-n8n-data.sh
```

## 📁 Structure du projet

```
├── 📱 chat_app/              # Interface web du chat assistant
├── 📊 docs/                  # Slides de présentation (Reveal.js)
├── 🗃️ vector-store-qdrant/   # Configuration Qdrant
├── 🔧 workflows/             # Workflows n8n
├── 🔑 credentials/           # Credentials n8n (Ollama, Qdrant)
├── 🐋 docker-compose.yml     # Stack complète
└── 📜                        # start.sh, stop.sh, clean.sh...
```

## 🎯 Fonctionnalités démontrées

### 💬 Assistant Chat
- Streaming en temps réel
- Gestion de sessions
- Choix du modèle IA (local/distant)
- Interface moderne et responsive

### 🧠 Système RAG
- **Upload de documents** : PDF, TXT
- **Web scraping** : Extraction automatique de contenu web
- **Base vectorielle** : Stockage et recherche sémantique avec Qdrant
- **Collections management** : Interface de gestion des données

### 🔧 Administration
- Monitoring des collections Qdrant
- Gestion des documents indexés
- Interface d'administration intégrée

## 🎤 Slides de présentation

Les slides sont disponibles dans le dossier `/docs` et utilisent Reveal.js.

**Sujet** : "IA locales ou distantes, outils, et un chef d'orchestre nommé n8n"

**Contenu** :
- Introduction aux agents IA
- Orchestration avec n8n
- Démonstration live du système RAG
- Bonnes pratiques et retours d'expérience

## ⚙️ Configuration avancée

### Variables d'environnement

Copiez `.env.example` vers `.env` et ajustez :

```bash
# Base de données
POSTGRES_DB=n8n
POSTGRES_USER=n8n
POSTGRES_PASSWORD=n8n

# n8n
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=admin

# Qdrant
QDRANT_API_KEY=your-api-key-here
```

### Modèles IA supportés

- **Local** : Ollama (llama2, mistral, codellama...)
- **Distant** : OpenAI GPT, Anthropic Claude, etc.

## 🛠️ Scripts utiles

```bash
# Démarrer la stack
./start.sh

# Arrêter la stack
./stop.sh

# Nettoyer complètement (attention: supprime les données)
./clean.sh

# Configurer les collections Qdrant
./setup-collections.sh

# Configurer Ollama avec modèles
./setup-ollama.sh
```

## 📚 Documentation détaillée

- **Chat App** : Voir [chat_app/README.md](./chat_app/README.md)
- **Workflows n8n** : Documentation dans l'interface n8n
- **Configuration Qdrant** : [vector-store-qdrant/](./vector-store-qdrant/)

## 🐛 Dépannage

### Services qui ne démarrent pas
```bash
# Vérifier les logs
docker compose logs

# Redémarrer un service spécifique
docker compose restart n8n
```

### Problèmes de mémoire
- Ollama nécessite minimum 4 Go de RAM
- Ajustez les modèles selon votre configuration

### Port déjà utilisé
```bash
# Changer les ports dans docker-compose.yml
# Par défaut: 8080 et 8443 (chat), 5678 (n8n), 11435 (slides)
```

## 🤝 Contribution

Cette démo est conçue pour être éducative et facilement adaptable. N'hésitez pas à :

- Forker le projet
- Adapter les workflows à vos besoins
- Contribuer aux améliorations

## 📄 Licence

MIT License - Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

**Présenté à Codeurs en Seine 2025**  
Par [Antonin Brugnot](https://github.com/antoninBr)  

🔗 **Liens utiles** :
- [n8n Documentation](https://docs.n8n.io/)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [Ollama Models](https://ollama.ai/library)