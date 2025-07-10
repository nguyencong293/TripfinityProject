# frontend/Dockerfile
# Build stage - Node 20.x to match npm 10.9.2
FROM node:20-alpine as build
WORKDIR /app
# Copy and install deps
COPY package.json package-lock.json ./
RUN npm ci
# Copy code & build
COPY . .
RUN npm run build

# Production stage
FROM nginx:1.25-alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]