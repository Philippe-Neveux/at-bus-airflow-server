# Airflow Deployment 

This project demonstrates using [Apache Airflow](https://airflow.apache.org/) for orchestrating data workflows, including integration with AWS S3 and Postgres, using custom DAGs and Python tasks.

## Project Structure

- `dags/` — Airflow DAG definitions (e.g., S3, Postgres, Python tasks)
- `config/` — Airflow configuration files
- `data/` — Example datasets (e.g., `titanic.csv`)
- `plugins/` — Custom Airflow plugins
- `logs/` — Airflow logs
- `Dockerfile` — Custom Airflow Docker image
- `docker-compose.yaml` — Multi-service orchestration
- `pyproject.toml` — Python dependencies
- `Makefile` — Common development commands

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [uv](https://astral.sh/uv/) (for Python dependency management)

### Setup

1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd airflow_tuto
   ```

2. **Install python dependencies:**
   ```sh
   make python_env
   ```

3. **Build Docker image:**
   ```sh
   make build_image
   ```

4. **Start Airflow services:**
   ```sh
   make compose_up
   ```

5. **Access Airflow UI:**
    - Visit [http://localhost:8080](http://localhost:8080)
    - Default credentials: `airflow` / `airflow`

Stopping services

```sh
make compose_down
```

### Configuration

- Environment variables are set in the .env file.
- Airflow configuration is in *config/airflow.cfg*.


### Example DAGs

- `my_dag.py` — Basic DAG example
- `dag_with_python.py` — PythonOperator example
- `dag_postgres_task.py` — Postgres integration
- `my_dag_s3_aws_backend.py` — S3 integration with AWS backend

### Linting

Run Ruff for code quality checks:

```sh
make ruff_check
make ruff_fix
```