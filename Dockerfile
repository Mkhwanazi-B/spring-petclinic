#lightweight base image for java 
FROM openjdk:17-jdk-alpine 

#set working directory inside image 
WORKDIR /app

#copy the jar file into the container 
COPY target/spring-petclinic-3.5.0-SNAPSHOT.jar app.jar
# Use a base image with Java installed
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /app

# Copy the JAR file from the host machine into the image
# Make sure your Jenkins pipeline makes the 'target' directory available
COPY target/spring-petclinic-3.5.0-SNAPSHOT.jar app.jar

# Expose the application's port
EXPOSE 8080

# Define the command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]