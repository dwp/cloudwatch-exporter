FROM alpine:3.12.0

ARG CLOUDWATCH_EXPORTER_VERSION=0.19.1-alpha

COPY entrypoint.sh /bin/entrypoint.sh

RUN apk add --update --no-cache aws-cli curl && \
    curl -k -LSs --output /tmp/cloudwatch-exporter.tar.gz \
    https://github.com/ivx/yet-another-cloudwatch-exporter/releases/download/v${CLOUDWATCH_EXPORTER_VERSION}/yet-another-cloudwatch-exporter_${CLOUDWATCH_EXPORTER_VERSION}_Linux_x86_64.tar.gz && \
    tar -C /tmp -zoxf /tmp/cloudwatch-exporter.tar.gz && \
    rm -f /tmp/cloudwatch-exporter.tar.gz && \
    mv /tmp/yace /yace && \
    mkdir /etc/cloudwatch-exporter && \
    chmod 0755 /yace /bin/entrypoint.sh && \
    chown -R nobody:nogroup /etc/cloudwatch-exporter

EXPOSE 5000

ENTRYPOINT [ "/bin/entrypoint.sh" ]
