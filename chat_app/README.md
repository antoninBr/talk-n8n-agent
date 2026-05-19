# Le Cabinet de Dobby - Interface de Chat

Page web autoportée pour l'assistant IA via n8n, avec une DA Harry Potter et des notifications Hermione.

## 🎨 Caractéristiques

- **Design Harry Potter** : interface parchemin, dorures et panneaux thématiques
- **Mode plein écran** : Expérience utilisateur immersive
- **Paramètres dynamiques** : Extraction depuis l'URL
- **Streaming activé** : Réponses en temps réel
- **Dobby comme agent de chat** : messages d'accueil et ton de l'assistant adaptés
- **Notifications Hermione** : conseils récupérés depuis un endpoint dédié
- **Menu d'administration** : Accès rapide aux outils de gestion
- **Nginx intégré** : Serveur web + reverse proxy vers n8n
- **Fichiers partagés** : thème et helpers centralisés dans [common.css](./common.css) et [common.js](./common.js)

## 🚀 Utilisation

### Démarrage complet (avec Docker Compose)

```bash
# Depuis la racine du projet
docker compose up -d

# Attendre quelques secondes puis ouvrir :
firefox https://localhost:8443
```

Le chat est maintenant accessible sur **https://localhost:8443** (port 8443).

### Utilisation de base

Ouvrez simplement dans votre navigateur :

```bash
firefox https://localhost:8443
# ou
google-chrome https://localhost:8443
```

### Avec paramètres personnalisés

#### Session ID personnalisée

```
https://localhost:8443?sessionId=ma_session_123
```

#### Choix du modèle LLM

```
https://localhost:8443?model=local
```

```
https://localhost:8443?model=lavoisier
```

#### Combinaison de paramètres

```
https://localhost:8443?sessionId=session_abc&model=local
```

## 🏗️ Architecture

Le frontend est servi par Nginx qui agit aussi comme reverse proxy :

```
Navigateur → Nginx:8443 → [Fichiers HTML/CSS/JS]
                      → [Proxy /webhook/*] → n8n:5678
```

### Configuration Nginx

Le fichier `nginx.conf` dans ce dossier configure :
- **Serveur de fichiers** : Sert tous les fichiers HTML/CSS/JS
- **Reverse proxy** : Redirige `/webhook/*` vers `http://n8n:5678/webhook/*`
- **Streaming** : Support des réponses en temps réel
- **CORS** : Headers configurés pour permettre les appels cross-origin
- **Health check** : Endpoint `/health` pour monitoring

## 📋 Paramètres URL disponibles

| Paramètre | Description | Exemple | Par défaut |
|-----------|-------------|---------|------------|
| `sessionId` | Identifiant unique de session | `sess_abc123` | Généré automatiquement |
| `model` | Modèle LLM à utiliser | `local`, `lavoisier` | `local` |

## 🔧 Configuration

### Menu d'administration

L'interface inclut un menu d'administration flottant (icône ⚙️ en haut à droite) avec :

#### Section Gestion RAG
- **Upload de documents** : Téléchargement de documents pour l'IA (fonctionnalité principale)
- **Web scraping** : Extraction de contenu web
- **Collections Qdrant** : Gestion de la base de données vectorielle

#### Accès n8n
- Lien direct vers l'interface n8n d'administration

### Modifier l'URL du webhook

L'URL du webhook est maintenant automatique et utilise `window.location.origin` :

```javascript
// Dans index.html (ligne ~128)
webhookUrl: window.location.origin + '/webhook/665869c3-d79b-49e2-82b0-ef445d02126b/chat',
```

Cela fonctionne automatiquement en :
- **Développement** : `https://localhost:8443/webhook/...`

Si vous devez changer l'ID du webhook, modifiez uniquement la partie après `/webhook/`.

### Personnaliser les couleurs

Les variables CSS sont définies dans [common.css](./common.css). Exemples :

```css
--hp-gold: #d6b36a;
--hp-burgundy: #5c1c12;
--hp-ink: #2f2016;
```

### Modifier les messages initiaux

Messages d'accueil actuels :

```javascript
initialMessages: [
	'Dobby vous souhaite la bienvenue dans le cabinet enchanté.',
	'Parlez à Dobby comme à votre elfe de maison: il fouillera grimoires, notes et archives pour vous répondre.'
],
```

### Changer la langue

Ligne ~136 :

```javascript
defaultLanguage: 'fr',
```

## 📦 Métadonnées envoyées au webhook

Le chat envoie automatiquement ces métadonnées :

```javascript
{
	sessionId: "sess_1234567890_123",  // Depuis URL ou généré
	llmModel: "local",                // Depuis URL ou "lavoisier"
	userAgent: "Mozilla/5.0...",       // Navigateur de l'utilisateur
	timestamp: "2025-10-21T10:30:00.000Z"  // Date/heure
}
```

Ces métadonnées sont accessibles dans votre workflow n8n.

## 🎯 Intégration avec n8n

Dans votre workflow n8n, vous pouvez accéder aux métadonnées :

```javascript
// Node "Chat Trigger"
const sessionId = $json.metadata.sessionId;
const model = $json.metadata.llmModel;
const userMessage = $json.chatInput;

// Utiliser le modèle choisi
if (model === 'local') {
	// Logique pour le traitement local
} else if (model === 'lavoisier') {
	// Logique pour l'envoi vers Lavoisier
}
```

## 🔍 Débogage

Ouvrez la console du navigateur (F12) pour voir les logs :

```
🔧 Configuration du chat: {
  sessionId: "sess_1234567890_123",
	llmModel: "lavoisier",
  url: "file:///.../index.html?sessionId=..."
}
```

## 📚 Ressources

- [Documentation @n8n/chat](https://www.npmjs.com/package/@n8n/chat)
- [n8n Documentation](https://docs.n8n.io/)
- [Guide CSS Variables](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties)

## 🛠️ Structure du fichier

Le fichier `index.html` reste autoporté pour la logique métier, mais il s'appuie désormais sur des fichiers communs :

1. **HTML structure** : Minimal, uniquement l'essentiel
2. **CSS partagé** : [common.css](./common.css) pour le thème et les composants communs
3. **JavaScript partagé** : [common.js](./common.js) pour les helpers, le sélecteur de modèle et Hermione

## 🔐 Sécurité

⚠️ **Notes importantes** :

- Le `sessionId` est visible dans l'URL (pas de données sensibles)
- En production, utilisez HTTPS
- Les logs de débogage doivent être retirés en production
- Validez les paramètres côté serveur (n8n)

## 📝 Exemples d'usage

### Support client standard

```
https://localhost:8443?sessionId=sess_45678
```

### Test avec modèle spécifique

```
https://localhost:8443?sessionId=test_dev&model=local
```

### Session utilisateur authentifié

```
https://localhost:8443?sessionId=user_${userId}&model=lavoisier
```

## 🎨 Personnalisation avancée

### Ajouter un nouveau paramètre URL

1. Extraire le paramètre :
```javascript
const monParam = getQueryParam('monParam') || 'valeur_defaut';
```

2. L'ajouter aux métadonnées :
```javascript
metadata: {
	sessionId: sessionId,
	llmModel: llmModel,
	monParam: monParam,
	// ...
}
```

### Modifier le style des messages

Ajustez les variables CSS :

```css
--chat--message--bot--background: #ffffff;
--chat--message--bot--color: #2d2d2d;
--chat--message--user--background: #007acc;
--chat--message--user--color: #ffffff;
```

## 🐛 Problèmes courants

### Le chat ne s'affiche pas

- Vérifiez que l'URL du webhook est correcte
- Vérifiez la console pour les erreurs
- Assurez-vous que n8n est démarré

### Les paramètres URL ne fonctionnent pas

- Vérifiez l'orthographe : `?sessionId=...` (sensible à la casse)
- Utilisez `&` pour séparer les paramètres : `?sessionId=abc&model=gpt`

### Le style n'est pas cohérent

- Vérifiez les variables CSS dans [common.css](./common.css)
- Assurez-vous que toutes les couleurs utilisent la palette moderne
- Videz le cache du navigateur après modification du CSS

