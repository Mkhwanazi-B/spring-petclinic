#lightweight base image for java 
FROM openjdk:17-jdk-alpine 

#set working directory inside image 
WORKDIR /app

#copy the jar file into the container 
COPY target/spring-petclinic-3.5.0-SNAPSHOT.jar app.jar

#Epose the needed port
EXPOSE 8080

#Runtime command at start of container
ENTRYPOINT ["java", "-jar", "app.jar"]