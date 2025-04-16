FROM docker.arvancloud.ir/sapmachine
WORKDIR /app
COPY target/*.jar ./
CMD ["java", "-jar", "jb-hello-world-maven-0.2.0.jar"]