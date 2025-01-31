# Step 1: Build the Vite app
FROM node:18 AS build-stage

WORKDIR /app

# Copy package files separately for better caching
COPY package.json package-lock.json ./
RUN npm ci --omit=dev  # Faster, ensures lockfile consistency

COPY . . 
RUN npm run build

# Step 2: Serve the app with Nginx
FROM nginx:stable-alpine AS production-stage

# Remove default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy the build files from the build stage to Nginx
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Set permissions
RUN chmod -R 755 /usr/share/nginx/html && chown -R nginx:nginx /usr/share/nginx/html

# Expose ports for ECS to route traffic
EXPOSE 80

# Health check for ECS
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost || exit 1

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
