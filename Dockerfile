# Stage 1 - Install dependencies and build the app
FROM debian:stable-slim AS build-env

# Install required packages
RUN apt-get update && apt-get install -y curl git wget unzip libglu1-mesa fonts-droid-fallback python3 \
    && apt-get clean

# Clone the Flutter repo (stable version)
RUN git clone -b stable https://github.com/flutter/flutter.git /usr/local/flutter
WORKDIR /usr/local/flutter
RUN git checkout ea121f8859

# Set Flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable Flutter Web
RUN flutter doctor -v
RUN flutter config --enable-web

# Set working directory
WORKDIR /app

# Copy only pubspec files to cache dependencies
COPY pubspec.yaml pubspec.lock ./

# Get dependencies early (clean environment)
RUN flutter pub get

# Now copy the rest of the source files
COPY . .

# Build the Flutter web app
RUN flutter clean && flutter pub get && flutter build web --release

# Stage 2 - Create the run-time image
FROM nginx:1.21.1-alpine

# Copy the built web files to NGINX's default directory
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Run NGINX
CMD ["nginx", "-g", "daemon off;"]
