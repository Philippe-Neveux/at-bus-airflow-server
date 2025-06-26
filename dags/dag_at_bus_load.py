from datetime import datetime, timedelta

from airflow.decorators import task, dag
from airflow.providers.docker.operators.docker import DockerOperator
import google.auth
import google.auth.transport.requests

GCP_REGION='australia-southeast1'
GCP_PROJECT_ID='glossy-apex-462002-i3'
GCP_ARTIFACT_REPOSITORY='python-projects'
PROJECT_NAME='at-bus-load'
IMAGE_VERSION="latest"

DOCKER_IMAGE_NAME=f"{GCP_REGION}-docker.pkg.dev/{GCP_PROJECT_ID}/{GCP_ARTIFACT_REPOSITORY}/{PROJECT_NAME}:{IMAGE_VERSION}"

def get_gcp_token_from_default_credentials() -> str:
    creds, _ = google.auth.default(scopes=['https://www.googleapis.com/auth/cloud-platform'])

    auth_req = google.auth.transport.requests.Request()
    creds.refresh(auth_req)

    return creds.token

@dag(
    schedule='0 8 * * *',
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["at-bus-load"],
    # Define default parameters that can be overridden from the UI
    params={
        "execution_date": None,  # None means use DAG's execution date by default
    },
)
def DAG_at_bus_load():

    token = get_gcp_token_from_default_credentials()

    get_at_api_data = DockerOperator(
        task_id="get_at_api_data",
        image=DOCKER_IMAGE_NAME,
        command='uv run get_at_api_data --env-var-token=GCP_TOKEN --date={{ params.execution_date or ds }}',
        mount_tmp_dir = False,
        auto_remove="force",
        environment={"GCP_TOKEN": token},
        # Task-specific retry configuration (overrides DAG defaults)
        retries=5,
    )

    move_gcs_data_to_bq = DockerOperator(
        task_id="move_gcs_data_to_bq",
        image=DOCKER_IMAGE_NAME,
        command='uv run move_gcs_data_to_bq --env-var-token=GCP_TOKEN --date={{ params.execution_date or ds }}',
        mount_tmp_dir = False,
        auto_remove="force",
        environment={"GCP_TOKEN": token}
    )

    get_at_api_data >> move_gcs_data_to_bq

DAG_at_bus_load()