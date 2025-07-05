dbt_run:
	uv run dbt run --profiles-dir ~/.dbt

dbt_test:
	uv run dbt test --profiles-dir ~/.dbt

dbt_docs:
	uv run dbt docs generate
	uv run dbt docs serve

# Run the dynamic consolidation model
dbt_run_stops_consolidated:
	uv run dbt run --select stops_consolidated --profiles-dir ~/.dbt

dbt_run_trips_consolidated:
	uv run dbt run --select trips_consolidated --profiles-dir ~/.dbt

dbt_run_gold_dataset:
	uv run dbt run --select trips_consolidated --profiles-dir ~/.dbt