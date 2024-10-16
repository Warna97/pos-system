# Use the official Gradle image to build the Spring Boot backend
FROM gradle:7.4.2-jdk17 AS backend-build

# Set the working directory
WORKDIR /workspace/backend

# Copy the backend source code
COPY . .

# Package the Spring Boot application
RUN gradle build --no-daemon

# Use the official Node.js image to build the Angular frontend
FROM node:18 AS frontend-build

# Set the working directory
WORKDIR /workspace/frontend

# Copy the frontend source code
COPY frontend/package.json frontend/package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the frontend source code
COPY frontend/ .

# Build the Angular application
RUN npm run build

# Use the official openjdk image to run the application
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /workspace

# Copy the built backend and frontend applications
COPY --from=backend-build /workspace/backend/build/libs/*.jar app.jar
COPY --from=frontend-build /workspace/frontend/dist /workspace/frontend/dist

# Expose ports for frontend and backend
EXPOSE 8080 4200

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]