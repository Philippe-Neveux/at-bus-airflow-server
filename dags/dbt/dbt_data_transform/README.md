# dbt-data-transform

This project uses [dbt](https://www.getdbt.com/) to transform and analyze a personality dataset.

## Project Structure

- **models/**: Contains dbt models, including:
  - `personality_dataset_updated.sql`: Loads and cleans the raw dataset.
  - `personality_dataset_gold.sql`: Produces the gold (final) dataset with standardized column names.
  - `schema.yml`: Describes model schemas and tests.
- **macros/**, **analyses/**, **seeds/**, **snapshots/**: Standard dbt project directories.
- **dbt_project.yml**: Main dbt project configuration.
- **pyproject.toml**: Python project configuration.
- **dbt-user-creds.json**: Credentials for dbt (BigQuery).

## Setup

1. **Install dependencies with uv**  
   ```sh
   uv sync # Downloads all python dependencies
   uv venv # Creates a virtual environment
   ``` 

2. **Configure credentials**  
   Update `dbt-user-creds.json` with your BigQuery credentials.


## Usage

- **Run transformations:**
  ```sh
  dbt run
  ```
- **Test models:**
  ```sh
  dbt test
  ```
- **View documentation:**
  ```sh
  dbt docs generate
  dbt docs serve
  ```

## Data

The main dataset is located at [`data/personality_dataset.csv`](data/personality_dataset.csv).  
It contains columns such as:
- `Time_spent_Alone`
- `Stage_fear`
- `Social_event_attendance`
- `Going_outside`
- `Drained_after_socializing`
- `Friends_circle_size`
- `Post_frequency`
- `Personality` (target: Introvert/Extrovert)
