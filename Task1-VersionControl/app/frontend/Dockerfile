# Step 1: Build the Vite app
FROM node:18 AS build-stage

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install

COPY . . 
RUN npm run build

# Step 2: Serve the app with Nginx
FROM nginx:stable-alpine AS production-stage

# Copy the build files from the build stage to Nginx
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Set permissions
RUN chmod -R 755 /usr/share/nginx/html && chown -R nginx:nginx /usr/share/nginx/html

# Expose ports for ALB to route traffic
EXPOSE 80 443

# Health check endpoint for ECS
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost || exit 1

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
