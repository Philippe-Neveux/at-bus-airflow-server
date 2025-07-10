# AT Bus Airflow Server

This repository contains the infrastructure and workflow management for the AT Bus project. It uses Ansible for server provisioning and configuration, and Apache Airflow for orchestrating data workflows.

## 🚀 Project Overview

- **Ansible**: Automates the setup of the production environment, including the installation of Docker, Nginx, and other dependencies.
- **Airflow**: Manages and schedules data pipelines (DAGs). It runs in a Docker environment orchestrated by Docker Compose.
- **CI/CD**: GitHub Actions are configured to automatically deploy changes to the production environment.

## 📁 Project Structure

```
at-bus-airflow-server/
├── airflow/                    # Airflow application files
│   ├── dags/                   # Airflow DAGs
│   ├── plugins/                # Airflow plugins
│   ├── config/                 # Airflow configuration
│   └── docker-compose.yaml     # Local development compose file
├── ansible/                    # Ansible automation for production
│   ├── inventory/              # Server inventories
│   ├── playbooks/              # Deployment & management playbooks
│   └── roles/                  # Ansible roles
├── .github/workflows/          # CI/CD workflows
├── pyproject.toml              # Python project definition and dependencies
└── README.md                   # This file
```

## 🛠️ Setup and Installation

### Local Development

For local development, you can run Airflow using the provided Docker Compose file.

1.  **Navigate to the Airflow directory:**
    ```bash
    cd airflow
    ```

2.  **Start the Airflow services:**
    ```bash
    docker-compose up -d
    ```

3.  **Access the Airflow UI:**
    Open your browser and go to [http://localhost:8080](http://localhost:8080).

### Production Deployment

Production deployment is handled by Ansible. The playbooks will set up the server, install dependencies, and deploy the Airflow application.

1.  **Navigate to the Ansible directory:**
    ```bash
    cd ansible
    ```

2.  **Install Ansible dependencies:**
    ```bash
    # Make sure you have uv or pip installed
    uv run ansible-galaxy collection install -r requirements.yml
    ```

3.  **Configure the inventory:**
    Update `ansible/inventory/production.yml` with your server's IP address and SSH credentials.

4.  **Run the deployment playbook:**
    The `Makefile` provides convenient shortcuts for running the playbooks.
    ```bash
    # Deploy Airflow to production
    make deploy-airflow
    ```

## ⚙️ Usage

### Managing the Production Environment

All management tasks for the production environment should be run from the `ansible` directory.

-   **Deploy Airflow**:
    ```bash
    make deploy-airflow
    ```

-   **Stop Airflow**:
    ```bash
    make stop-airflow
    ```

-   **Restart Airflow**:
    ```bash
    make restart-airflow
    ```

-   **Check Airflow Status**:
    ```bash
    make check-airflow-status
    ```

### Adding New Airflow DAGs

1.  Add your DAG file to the `airflow/dags/` directory.
2.  Commit and push your changes to the repository.
3.  The CI/CD pipeline will automatically deploy the new DAG to the production environment.

### Adding DBT DAGs

1.  Add your repository as a git submodule in the `airflow/dags/dbt` directory. `git submodule add <repository-url> airflow/dags/dbt/<repository-name>`
2.  Create a new Airflow DAG in the `airflow/dags/` directory.
3.  Use [cosmos](https://astronomer.github.io/astronomer-cosmos/) to create dbt tasks in the new Airflow DAG.
4.  Commit and push your changes to the repository.


## 🔧 Dependencies

-   **Application**: `apache-airflow`, `dbt-bigquery`, `polars`
-   **Infrastructure**: `ansible`, `docker`

See `pyproject.toml` for a full list of Python dependencies.
