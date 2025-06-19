from datetime import datetime

from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import PostgresUserPasswordProfileMapping

profile_config = ProfileConfig(
    profile_name="dbt_data_transform",
    target_name="dev",
    profiles_yml_filepath="/opt/airflow/dags/dbt/dbt_data_transform/profiles.yml",
)

my_cosmos_dag = DbtDag(
    project_config=ProjectConfig(
        "/opt/airflow/dags/dbt/dbt_data_transform",
    ),
    profile_config=profile_config,
    # execution_config=ExecutionConfig(
    #     dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt",
    # ),
    # normal dag parameters
    schedule="@daily",
    start_date=datetime(2023, 1, 1),
    catchup=False,
    dag_id="Cosmos_dag",
    default_args={"retries": 1},
)