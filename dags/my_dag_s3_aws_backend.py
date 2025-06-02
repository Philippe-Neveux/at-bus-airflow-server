from datetime import datetime

import logging

from airflow.sdk import dag, task, Variable, ObjectStoragePath
import polars as pl

@dag(
    dag_id='DAG_s3_aws_backend',
    description='Simple connection to s3 using AWS backend',
    schedule=None,  # Runs daily at midnight
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['example'],
)
def tutorial_objectstorage():

    @task()
    def print_secrets():
        
        s3_path = ObjectStoragePath(
            "s3://pndataraw/titanic.csv",
            conn_id="conn_aws",
        )
        
        # List files in the bucket
        files = list(s3_path.glob("*"))
        print("Files in S3 bucket:", files)
        
        with s3_path.open("rb") as f:
            df = pl.read_csv(f)
            
        logging.info(f"DataFrame loaded from S3: {df}")
        
        import boto3

        def check_s3_access():
            s3 = boto3.client("s3")
            try:
                response = s3.list_buckets()
                print("S3 Buckets:", [bucket["Name"] for bucket in response["Buckets"]])
                print("S3 access successful.")
            except Exception as e:
                print("S3 access failed:", e)

        check_s3_access()
        
        s3_url = "s3://pndataraw/titanic.csv"
        df = pl.read_csv(s3_url)
            
        logging.info(f"DataFrame loaded from S3: {df}")

        key_id = Variable.get("s3_access_key_id")
        logging.info(f"My variable is: {key_id}")
        
        secret_key = Variable.get("s3_secret_access_key")
        logging.info(f"My variable is: {secret_key}")
    
        
        

    print_secrets()
    
tutorial_objectstorage()