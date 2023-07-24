FROM node:18-alpine AS base

FROM base AS deps
RUN apk add --no-cache libc6-compat
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY /with-jest-app/package.json ./
COPY /with-jest-app/package-lock.json ./
RUN npm ci

FROM base AS builder
WORKDIR /usr/src/app
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM base AS runner
WORKDIR usr/src/app
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
COPY --from=builder /usr/src/app/public ./public
COPY --from=builder --chown=nextjs:nodejs /usr/src/app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /usr/src/app/.next/static ./.next/static
USER nextjs
EXPOSE 3000
ENV PORT 3000
CMD ["node", "server.js"]