FROM amazoncorretto:21.0.0-al2023-headful
RUN mkdir -p /opt/app/
COPY .build/libs/* /opt/app/
RUN  java -jar /opt/app/*.jar