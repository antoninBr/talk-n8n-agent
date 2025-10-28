#!/bin/bash
# Script de génération de certificat SSL auto-signé
# Valide pour localhost

set -e

CERT_DIR="./ssl"
DAYS_VALID=365

echo "🔐 Génération d'un certificat SSL auto-signé..."

# Créer le répertoire SSL s'il n'existe pas
mkdir -p "$CERT_DIR"

# Générer la clé privée et le certificat
openssl req -x509 -nodes -days $DAYS_VALID -newkey rsa:2048 \
    -keyout "$CERT_DIR/privkey.pem" \
    -out "$CERT_DIR/fullchain.pem" \
    -subj "/C=FR/ST=IDF/L=Paris/O=antothefit/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1"

# Générer également les paramètres Diffie-Hellman pour plus de sécurité
echo "🔒 Génération des paramètres Diffie-Hellman (peut prendre quelques minutes)..."
openssl dhparam -out "$CERT_DIR/dhparam.pem" 2048

# Définir les permissions appropriées
chmod 600 "$CERT_DIR/privkey.pem"
chmod 644 "$CERT_DIR/fullchain.pem"
chmod 644 "$CERT_DIR/dhparam.pem"

echo "✅ Certificat SSL auto-signé généré avec succès dans $CERT_DIR/"
echo ""
echo "📋 Fichiers créés :"
echo "   - $CERT_DIR/privkey.pem (clé privée)"
echo "   - $CERT_DIR/fullchain.pem (certificat)"
echo "   - $CERT_DIR/dhparam.pem (paramètres DH)"
echo ""
echo "🌐 Domaines couverts :"
echo "   - localhost / *.localhost"
echo "   - 127.0.0.1"
echo ""
echo "⚠️  ATTENTION : Ce certificat est auto-signé et causera des avertissements de sécurité dans le navigateur."
echo "    Vous devrez accepter l'exception de sécurité lors de la première visite."
echo ""
echo "🚀 Vous pouvez maintenant démarrer nginx avec : podman compose up -d nginx"
