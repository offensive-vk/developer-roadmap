# Stage 0: Setup Node.js and pnpm
FROM node:20 AS setup
RUN node -v && npm -v
RUN npm install -g pnpm@9.0.0
RUN pnpm -v

# Stage 1: Base build stage
FROM setup AS base
WORKDIR /app
COPY package*.json pnpm-lock.yaml ./
RUN pnpm install

# Stage 2: Format stage
# FROM base AS format
# RUN npm run format
# RUN npm run test:e2e

# Stage 3: Build stage
FROM base AS build
COPY . .
RUN npm run build

# Stage 4: Cleanup stage (optional)
FROM base AS cleanup
RUN pnpm prune --prod  # Only keep production dependencies

# Stage 5: Production stage
FROM node:20 AS production
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY package*.json pnpm-lock.yaml ./
RUN pnpm install --prod --lockfile-only
EXPOSE 8080
CMD ["npm","start"]
