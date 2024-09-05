# Stage 0: Setup Nodejs and pnpm
FROM node:20 AS setup
RUN node -v ; npm -v
RUN npm i -g pnpm@9.0.0
RUN pnpm -v

# Stage 1: Base build stage
FROM setup AS base
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# # Stage 2: format stage
# FROM base AS format
# RUN pnpm install --lockfile-only
# RUN npm run format

# # Stage 3: Build stage
# FROM base AS build
# RUN npm run build

# Stage 4: Cleanup and Exit
FROM base AS cleanup
WORKDIR /app
COPY package*.json ./
RUN pnpm cleanup --force; pnpm update 
RUN echo "Dockerfile Passed. "

# Stage 5: Production stage
FROM node:20 AS production
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY package*.json ./
RUN pnpm install --lockfile-only
EXPOSE 8080
CMD ["npm", "run", "dev"]
