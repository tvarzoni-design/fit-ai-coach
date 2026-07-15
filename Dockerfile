# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

COPY backend/package.json backend/package-lock.json* ./
RUN npm ci

COPY backend/ .
RUN npm run build

# Production stage
FROM node:20-alpine AS production

WORKDIR /app

RUN apk add --no-cache dumb-init

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

RUN npm prune --omit=dev

ENV NODE_ENV=production

EXPOSE 3000

USER node

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/main"]
