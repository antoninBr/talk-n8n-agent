# Message utilisateur
Question: {{ $json.chatInput }}

# Contexte utile
- Session: {{ $json.metadata.sessionId }}
- Modèle: {{ $json.metadata.llmModel }}

Réponds à la question en suivant le system prompt.