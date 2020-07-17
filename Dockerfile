FROM openjdk:11 as builder

ARG CLOUDWATCH_EXPORTER_VERSION=0.8.0

RUN apt-get update -qq && apt-get install -qq maven curl && \
    curl -k -LSs --output /tmp/cloudwatch-exporter.tar.gz \
    https://github.com/prometheus/cloudwatch_exporter/archive/cloudwatch_exporter-${CLOUDWATCH_EXPORTER_VERSION}.tar.gz && \
    tar -C /tmp --strip-components=1 -zoxf /tmp/cloudwatch-exporter.tar.gz && \
    mvn -f /tmp/pom.xml -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true package && \
    mv /tmp/target/cloudwatch_exporter-*-with-dependencies.jar /cloudwatch_exporter.jar

FROM openjdk:11-jre-slim

COPY --from=builder /cloudwatch_exporter.jar /cloudwatch-exporter.jar
COPY entrypoint.sh /bin/entrypoint.sh

RUN apt-get update && apt-get -qq install awscli && \
    mkdir /etc/cloudwatch-exporter && \
    chmod 0755 /cloudwatch-exporter.jar /bin/entrypoint.sh && \
    chown -R nobody:nogroup /etc/cloudwatch-exporter

EXPOSE 9106

ENTRYPOINT [ "/bin/entrypoint.sh" ]
