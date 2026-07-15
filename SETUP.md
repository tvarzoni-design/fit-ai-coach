# FIT AI COACH - Guia de Configuracao de Servicos

## Configuracao Obrigatoria

### 1. OpenAI (Coach IA)
1. Acesse: https://platform.openai.com/api-keys
2. Crie uma API Key
3. Adicione no `.env`:
```
OPENAI_API_KEY=sk-sua-chave-aqui
```

### 2. Firebase (Push Notifications)
1. Acesse: https://console.firebase.google.com/
2. Crie um projeto "fit-ai-coach"
3. Adicione um app Android (package: `com.fitaicoach.fit_ai_coach`)
4. Baixe `google-services.json` e coloque em `mobile/android/app/`
5. Vá em Project Settings > Service Accounts > Generate new private key
6. Adicione no `.env`:
```
FIREBASE_PROJECT_ID=seu-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nSUA_CHAVE_AQUI\n-----END PRIVATE KEY-----"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@seu-project-id.iam.gserviceaccount.com
```

### 3. Stripe (Pagamentos)
1. Acesse: https://dashboard.stripe.com/apikeys
2. Copie a Secret Key
3. No Stripe Dashboard, crie 2 products:
   - "Premium Mensal" (recurring, R$29.90/mes)
   - "Premium Anual" (recurring, R$199.90/ano)
4. Copie os Price IDs e adicione no `.env`:
```
STRIPE_SECRET_KEY=sk_test_sua-chave-aqui
STRIPE_WEBHOOK_SECRET=whsec_seu-webhook-secret
```
5. Atualize os `stripePriceId` no arquivo `subscriptions.service.ts`

### 4. AWS S3 (Upload de Imagens) - OPCIONAL
1. Crie um bucket S3: `fit-ai-coach-storage`
2. Configure CORS no bucket:
```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["GET", "POST", "PUT", "DELETE"],
    "AllowedOrigins": ["*"],
    "ExposeHeaders": []
  }
]
```
3. Crie um IAM User com acesso ao S3
4. Adicione no `.env`:
```
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=sua-access-key
AWS_SECRET_ACCESS_KEY=sua-secret-key
AWS_S3_BUCKET=fit-ai-coach-storage
```

## Inicio Rápido (sem servicos externos)

O app funciona sem servicos externos com as seguintes limitacoes:
- **OpenAI**: Coach IA usa respostas inteligentes pre-definidas
- **Firebase**: Push notifications desabilitadas
- **Stripe**: Assinaturas funcionam mas pagamentos nao sao processados
- **AWS**: Upload de imagens desabilitado

Para iniciar sem configurar nada:
```bash
cd backend
npm run build
node dist/main.js
```

## Docker Compose (com WSL2)
```bash
docker-compose up -d
```
Isso inicia: PostgreSQL, Redis, Backend, Admin Panel
