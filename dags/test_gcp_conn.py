from datetime import datetime, timedelta

from airflow.decorators import task, dag
# from google.oauth2 import service_account
from google.cloud import storage


@task(task_id="test_gcp_conn")
def python_callable() -> None:

    client = storage.Client()

    # Specify the bucket and file name
    bucket_name = 'pne-open-data'
    file_name = 'personality_dataset.csv'

    # Get the bucket instance
    bucket = client.get_bucket(bucket_name)

    # Check if the file exists
    blob = bucket.blob(file_name)
    if blob.exists():
        print(f'The file {file_name} exists in bucket {bucket_name}')
    else:
        print(f'The file {file_name} does not exist in bucket {bucket_name}')

@dag(
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["example"],
)
def test_gcp_conn():

    python_callable()

test_gcp_conn()