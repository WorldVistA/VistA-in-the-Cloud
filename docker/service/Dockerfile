FROM openjdk:8-jdk

VOLUME ["/opt/synthea/dhp-synthea-service"]

RUN mkdir -p /opt/synthea/dhp-synthea-service
WORKDIR /opt/synthea/dhp-synthea-service

ENTRYPOINT [ "/opt/synthea/dhp-synthea-service/gradlew", "clean", "build", "-s" ]