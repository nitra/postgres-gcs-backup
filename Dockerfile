FROM google/cloud-sdk:alpine

RUN apk add --update --no-cache \
  bash \
  postgresql

ADD . /postgres-gcs-backup

WORKDIR /postgres-gcs-backup

RUN chmod +x /postgres-gcs-backup/backup.sh

ENTRYPOINT ["/postgres-gcs-backup/backup.sh"]
