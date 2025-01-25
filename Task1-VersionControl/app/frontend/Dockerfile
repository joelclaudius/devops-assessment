# Step 1: Build the Vite app
FROM node:18 AS build-stage

WORKDIR /app
COPY . . 
RUN npm install
RUN npm run build

# Step 2: Serve the app with Nginx
FROM nginx:alpine AS production-stage

# Install Certbot and Nginx dependencies for SSL
RUN apk add --no-cache certbot nginx certbot-nginx

# Copy the build files from the build stage to Nginx
COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy SSL certificates into the container (Ensure this path matches your certs location)
COPY ./certs /etc/letsencrypt

# Expose ports 80 and 443 for HTTP and HTTPS
EXPOSE 80 443

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
