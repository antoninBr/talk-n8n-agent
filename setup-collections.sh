#!/bin/bash

# Setup script pour les workflows avec IA et Qdrant
echo "🚀 Configuration de l'environnement des workflows avec IA..."

# Créer les collections Qdrant nécessaires
echo "📊 Configuration des collections Qdrant..."

# Attendre que Qdrant soit prêt
echo "⏳ Attente du démarrage de Qdrant..."
until curl -f http://localhost:6333/ >/dev/null 2>&1; do
    echo "   Attente de Qdrant (http://localhost:6333)..."
    sleep 5
done

echo "✅ Qdrant est prêt"

# Créer la collection pour les documents
echo "📋 Création de la collection 'documents'..."
curl -X PUT "http://localhost:6333/collections/documents" \
  -H "Content-Type: application/json" \
  -d '{
    "vectors": {
      "size": 768,
      "distance": "Cosine"
    },
    "optimizers_config": {
      "default_segment_number": 2
    },
    "replication_factor": 1
  }'
echo ""
echo "✅ Collection 'documents' créée"

# Vérifier les collections
echo "🔍 Vérification des collections..."
curl -s http://localhost:6333/collections | jq '.'

echo ""
echo "✅ Setup terminé avec succès !"
echo ""
echo "📝 Prochaines étapes :"
echo "   1. Importer vos workflows dans n8n"
echo "   2. Configurer vos credentials Qdrant et Ollama"
echo "   3. Indexer vos premiers documents, tickets, règles d'import"
echo ""
echo "🌐 URLs importantes :"
echo "   • n8n: http://localhost:5678"
echo "   • Qdrant: http://localhost:6333"
echo "   • Ollama: http://localhost:11434"