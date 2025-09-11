# Use the official Flutter image as base
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the application code
COPY . .

# Build the Flutter web app
RUN flutter build web --release --web-renderer html

# Use nginx to serve the Flutter web app
FROM nginx:alpine

# Copy the built Flutter web app to nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 8282
EXPOSE 8282

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
