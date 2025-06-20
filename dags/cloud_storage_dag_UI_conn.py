from datetime import datetime, timedelta

from airflow.decorators import task, dag
from airflow.providers.google.cloud.hooks.gcs import GCSHook

import polars as pl


@task(task_id="load_csv_from_gcs")
def load_csv_from_gcs():
    bucket_name = 'pne-open-data'
    file_path = 'personality_dataset.csv'
    hook = GCSHook(gcp_conn_id='conn_gcp')
    # Download file as bytes
    file_bytes = hook.download(bucket_name=bucket_name, object_name=file_path)
    # Load into Polars DataFrame
    df = pl.read_csv(file_bytes)
    print(df)

@dag(
    description='A simple example Airflow DAG',
    schedule='0 0 * * *',  # Runs weely at midnight
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['gcp']
)
def GCS_load_csv_dag():
    load_csv_from_gcs()

GCS_load_csv_dag()