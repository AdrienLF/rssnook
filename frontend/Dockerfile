FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:22-alpine

WORKDIR /app

COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json /app/package-lock.json ./
RUN npm ci --omit=dev && \
    chown -R node:node /app

USER node

EXPOSE 3000
ENV NODE_ENV=production
CMD ["node", "build"]
