# ---------- Stage 1: Build dependencies ----------
FROM node:20-alpine AS builder

WORKDIR /app

COPY app/package.json app/package-lock.json* ./
RUN npm install --omit=dev

COPY app/src ./src

# ---------- Stage 2: Production image ----------
FROM node:20-alpine AS production

WORKDIR /app

# Run as non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY app/package.json ./

ENV NODE_ENV=production
ENV PORT=80

EXPOSE 80

USER appuser

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:80/health || exit 1

CMD ["node", "src/index.js"]
