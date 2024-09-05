# Stage 1: Base build stage
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN pnpm install
COPY . .

# Stage 2: Test stage
FROM base AS test
RUN pnpm install --lockfile-only
RUN npm run test

# Stage 3: Build stage
FROM base AS build
RUN pnpm run build

# Stage 4: Production stage
FROM node:20-alpine AS production
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY package*.json ./
RUN pnpm install --lockfile-only
EXPOSE 8080
CMD ["npm", "run", "dev"]