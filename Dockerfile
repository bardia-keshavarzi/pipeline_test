FROM sapmachine:24-jdk-ubuntu-noble
WORKDIR /app
COPY target/*.jar ./
CMD ["java", "-jar", "jb-hello-world-maven-0.2.0.jar"]