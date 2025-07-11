from datetime import datetime, timedelta
import os

os.environ['GCP_DATASET_BIGQUERY'] = 'at_bus'

from airflow.decorators import task, dag
from airflow.providers.docker.operators.docker import DockerOperator
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, ExecutionConfig
import google.auth
import google.auth.transport.requests

GCP_REGION='australia-southeast1'
GCP_PROJECT_ID='at-bus-465401'
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
    tags=["at-bus-load-transform"],
    # Define default parameters that can be overridden from the UI
    params={
        "execution_date": None,  # None means use DAG's execution date by default
    },
)
def DAG_at_bus_load_transform():

    token = get_gcp_token_from_default_credentials()

    get_at_api_data = DockerOperator(
        task_id="get_at_api_data",
        image=DOCKER_IMAGE_NAME,
        command='uv run get_at_api_data --env-var-token=GCP_TOKEN --date={{ params.execution_date or ds }}',
        mount_tmp_dir = False,
        auto_remove="force",
        environment={"GCP_TOKEN": token},
    )

    move_gcs_data_to_bq = DockerOperator(
        task_id="move_gcs_data_to_bq",
        image=DOCKER_IMAGE_NAME,
        command='uv run move_gcs_data_to_bq --env-var-token=GCP_TOKEN --date={{ params.execution_date or ds }}',
        mount_tmp_dir = False,
        auto_remove="force",
        environment={"GCP_TOKEN": token}
    )

    profile_config = ProfileConfig(
        profile_name="at_bus_transform",
        target_name="dev",
        profiles_yml_filepath="/opt/airflow/dags/dbt/at-bus-transform/profiles.yml"
    )
    project_config = ProjectConfig(
        dbt_project_path="/opt/airflow/dags/dbt/at-bus-transform",
    )

    transform_bq_data = DbtTaskGroup(
        group_id="at_bus_transform",
        project_config=project_config,
        profile_config=profile_config,
    )

    get_at_api_data >> move_gcs_data_to_bq >> transform_bq_data

DAG_at_bus_load_transform()