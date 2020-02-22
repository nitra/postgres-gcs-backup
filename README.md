# postgres-gcs-backup

This project aims to provide a simple way to perform a PostgreSQL server/db backup using `pg_dump` and to upload it to Google Cloud Storage. It was greatly inspired from [`takemetour/docker-postgres-gcs-backup`](https://github.com/takemetour/docker-postgres-gcs-backup).

### Docker image

You can pull the public image from Docker Hub:

    docker pull nitra/postgres-gcs-backup:latest

### Configuration

The following table lists the configurable parameters you can set up.

| Environment Variable | Required | Default               | Description                                                                          |
| -------------------- | -------- | --------------------- | ------------------------------------------------------------------------------------ |
| `JOB_NAME`           | No       | `default-job`         | Job name                                                                             |
| `BACKUP_DIR`         | No       | `/tmp`                | The path where the `pg_dump` result will be temporarily stored.                      |
| `BOTO_CONFIG_PATH`   | No       | `/root/.boto`         | The path where `gsutil` will search for the boto configuration file.                 |
| `GCS_BUCKET`         | Yes      |                       | The bucket you want to upload the backup archive to.                                 |
| `GCS_KEY_FILE_PATH`  | Yes      |                       | The location where the GCS serviceaccount key file will be mounted.                  |
| `POSTGRES_HOST`      | No       | `localhost`           | The PostgreSQL server host.                                                          |
| `POSTGRES_PORT`      | No       | `5432`                | The PostgreSQL port.                                                                 |
| `POSTGRES_DB`        | No       |                       | The database to backup. By default, a backup of all the databases will be performed. |
| `POSTGRES_USER`      | No       |                       | The PostgreSQL user if any.                                                          |
| `POSTGRES_PASSWORD`  | No       |                       | The PostgreSQL password if any.                                                      |
| `SLACK_AUTHOR_NAME`  | No       | `postgres-gcs-backup` | `true` slack author name.                                                            |
| `SLACK_ALERTS`       | No       |                       | `true` if you want to send Slack alerts in case of failure.                          |
| `SLACK_WEBHOOK_URL`  | No       |                       | The Incoming WebHook URL to use to send the alerts.                                  |

### Usage

#### Run locally

You can run the script locally:

    docker build -t t1 .
    docker run -e POSTGRES_HOST=db -e POSTGRES_DB=strapi  -e POSTGRES_USER=strapi -e POSTGRES_PASSWORD=strapi -e "GCS_BUCKET=gs://backup" t1

or

    docker run -e POSTGRES_HOST=db -e POSTGRES_DB=strapi  -e POSTGRES_USER=strapi -e POSTGRES_PASSWORD=strapi -e "GCS_BUCKET=gs://backup" -e SLACK_ALERTS=true -e SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T027RKXGB/BUCEFU988/yWGdLTd4l1cC4rQiWylT4oN  -e JOB_NAME=pgDump --network=tempo_default t1

### Authenticate with GCS

#### Using the gcloud CLI

If you are running the script locally, the easiest solution is to sign in to the google account associated with your Google Cloud Storage data:

    gcloud init --console-only

More information on how to setup gsutil locally [here](https://cloud.google.com/storage/docs/gsutil_install).

#### Using a service account within Kubernetes

You can create a [service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) with the required roles to write to GCS attached.

To use the resulting JSON key file within Kubernetes you can create a secret from it by running the following command:

      kubectl create secret generic postgres-gcs-backup \
      --from-file=credentials.json=/path/to/your/key.json

Then you will need to specify this secret name (by default, the secret name is set to `postgres-gcs-backup`). The key file will be mounted by default under `/secrets/gcp/credentials.json` and the `GCS_KEY_FILE_PATH` variable should point to it.
