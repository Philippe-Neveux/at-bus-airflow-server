from datetime import datetime

from airflow.sdk import ObjectStoragePath, dag, task
import polars as pl

@dag(
    dag_id='DAG_s3',
    description='Load Titanic csv file from s3 and transfornm it',
    schedule=None,  # Runs daily at midnight
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['example'],
)
def tutorial_objectstorage():

    @task()
    def load_csv_from_s3():
        s3_path = ObjectStoragePath("s3://pndataraw/titanic.csv", conn_id="s3")
        
        # List files in the bucket
        files = list(s3_path.glob("*"))
        print("Files in S3 bucket:", files)
        
        with s3_path.open("rb") as f:
            df = pl.read_csv(f)

        return df.to_dict(as_series=False)  # Polars DataFrame is not serializable

    @task()
    def transform_data(data):
        df = pl.DataFrame(data)
        # Example transformation: Add a column with the count of passengers
        df = df.with_columns(
            (
                pl.col("PassengerId").count()
            )
            .alias("PassengerCount")
        )
        return df.to_dict(as_series=False)

    @task()
    def write_csv_to_s3(data):
        df = pl.DataFrame(data)
        s3_path = ObjectStoragePath("s3://pndataraw/titanic_transformed.csv", conn_id="s3")
        with s3_path.open("wb") as f:
            df.write_csv(f)
            
    raw_data = load_csv_from_s3()
    transformed = transform_data(raw_data)
    write_csv_to_s3(transformed)
    
tutorial_objectstorage()