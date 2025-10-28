# Assistant IA - Interface de Chat

Page web minimaliste et autoportée pour l'assistant IA via n8n, servie par Nginx.

## 🎨 Caractéristiques

- **Design moderne** : Interface épurée avec palette de couleurs contemporaine
- **Mode plein écran** : Expérience utilisateur immersive
- **Paramètres dynamiques** : Extraction depuis l'URL
- **Streaming activé** : Réponses en temps réel
- **Menu d'administration** : Accès rapide aux outils de gestion
- **Nginx intégré** : Serveur web + reverse proxy vers n8n

## 🚀 Utilisation

### Démarrage complet (avec Docker Compose)

```bash
# Depuis la racine du projet
docker compose up -d

# Attendre quelques secondes puis ouvrir :
firefox http://localhost:8080
```

Le chat est maintenant accessible sur **http://localhost:8080** (port 8080).

### Utilisation de base

Ouvrez simplement dans votre navigateur :

```bash
firefox http://localhost:8080
# ou
google-chrome http://localhost:8080
```

### Avec paramètres personnalisés

#### Session ID personnalisée

```
http://localhost:8080?sessionId=ma_session_123
```

#### Choix du modèle LLM

```
http://localhost:8080?model=openai
```

#### Combinaison de paramètres

```
http://localhost:8080?sessionId=session_abc&model=local
```

## 🏗️ Architecture

Le frontend est servi par Nginx qui agit aussi comme reverse proxy :

```
Navigateur → Nginx:8080 → [Fichiers HTML/CSS/JS]
                      → [Proxy /webhook/*] → n8n:5678
```

### Configuration Nginx

Le fichier `nginx.conf` dans ce dossier configure :
- **Serveur de fichiers** : Sert tous les fichiers HTML/CSS/JS
- **Reverse proxy** : Redirige `/webhook/*` vers `http://n8n:5678/webhook/*`
- **Streaming** : Support des réponses en temps réel
- **CORS** : Headers configurés pour permettre les appels cross-origin
- **Health check** : Endpoint `/health` pour monitoring

```

## 📋 Paramètres URL disponibles

| Paramètre | Description | Exemple | Par défaut |
|-----------|-------------|---------|------------|
| `sessionId` | Identifiant unique de session | `sess_abc123` | Généré automatiquement |
| `model` | Modèle LLM à utiliser | `local`, `openai` | `local` |

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
- **Développement** : `http://localhost:8443/webhook/...`

Si vous devez changer l'ID du webhook, modifiez uniquement la partie après `/webhook/`.

### Personnaliser les couleurs

Les variables CSS sont définies dans le bloc `:root`. Exemples :

```css
--chat--color--primary: #007acc;      /* Bleu moderne */
--chat--color--secondary: #2d2d2d;    /* Gris foncé moderne */
--chat--header--background: #2d2d2d;  /* Fond de l'en-tête */
```

### Modifier les messages initiaux

Messages d'accueil actuels :

```javascript
initialMessages: [
	'Bienvenue dans l\'assistant intelligent !',
	'Je suis là pour vous aider à répondre à vos questions et vous accompagner dans vos recherches.'
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
	llmModel: "gpt-4",                 // Depuis URL ou "default"
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
if (model === 'gpt-4') {
	// Logique pour GPT-4
} else if (model === 'claude-3') {
	// Logique pour Claude-3
}
```

## 🔍 Débogage

Ouvrez la console du navigateur (F12) pour voir les logs :

```
🔧 Configuration du chat: {
  sessionId: "sess_1234567890_123",
  llmModel: "gpt-4",
  url: "file:///.../index.html?sessionId=..."
}
```

## 📚 Ressources

- [Documentation @n8n/chat](https://www.npmjs.com/package/@n8n/chat)
- [n8n Documentation](https://docs.n8n.io/)
- [Guide CSS Variables](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties)

## 🛠️ Structure du fichier

Le fichier `index.html` est totalement autoporté et contient :

1. **HTML structure** : Minimal, uniquement l'essentiel
2. **CSS personnalisé** : 
   - Variables CSS pour un design moderne
   - Animations et transitions fluides
   - Menu d'administration intégré
3. **JavaScript** : 
   - Extraction des paramètres URL
   - Configuration du chat
   - Gestion du menu d'administration
   - Initialisation automatique

## 🔐 Sécurité

⚠️ **Notes importantes** :

- Le `sessionId` est visible dans l'URL (pas de données sensibles)
- En production, utilisez HTTPS
- Les logs de débogage doivent être retirés en production
- Validez les paramètres côté serveur (n8n)

## 📝 Exemples d'usage

### Support client standard

```
http://localhost:8080?sessionId=sess_45678
```

### Test avec modèle spécifique

```
http://localhost:8080?sessionId=test_dev&model=local
```

### Session utilisateur authentifié

```
http://localhost:8080?sessionId=user_${userId}&model=openai
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

- Vérifiez les variables CSS dans le bloc `:root`
- Assurez-vous que toutes les couleurs utilisent la palette moderne
- Videz le cache du navigateur après modification du CSS

---

**Version** : 2.0  
**Dernière mise à jour** : Octobre 2025  
**Changements majeurs** : 
- Design modernisé avec palette de couleurs contemporaine
- Menu d'administration intégré
- Suppression du branding spécifique
- Amélioration des animations et transitions
