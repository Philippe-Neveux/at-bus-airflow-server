from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='DAG_with_Postgres',
    default_args=default_args,
    description='A simple example Airflow DAG',
    # schedule='*/2 * * * *',  # Runs daily at midnight
    # start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['example'],
) as dag:

    create_table = SQLExecuteQueryOperator(
        task_id='create_postgres_table',
        conn_id='postgres_localhost',  # Make sure this connection exists in Airflow
        sql="""
            CREATE TABLE IF NOT EXISTS dags_runs (
                dt date,
                dag_id character varying(250),
                primary key (dt, dag_id)
            )
        """
    )

    insert_dag_id = SQLExecuteQueryOperator(
        task_id='insert_into_table',
        conn_id='postgres_localhost',  # Make sure this connection exists in Airflow
        sql="""
            INSERT INTO dags_run (dt, dag_id) values ('{{ ds }}', '{{ dag.dag_id }}')
        """
    )
    
    create_table >> insert_dag_id