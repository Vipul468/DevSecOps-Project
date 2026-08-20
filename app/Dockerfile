# ---------- Stage 1: build the React (Vite) Amazon Prime clone ----------
FROM node:18-alpine AS build
WORKDIR /app

# install deps first (better layer caching)
COPY package*.json ./
RUN npm ci

# build-time API key for the clone (TMDB). Passed via --build-arg.
ARG TMDB_V3_API_KEY
ENV VITE_API_KEY=$TMDB_V3_API_KEY

COPY . .
RUN npm run build

# ---------- Stage 2: serve the static build with nginx ----------
FROM nginx:stable-alpine AS runtime
# SPA routing: fall back to index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost/ || exit 1
CMD ["nginx", "-g", "daemon off;"]
