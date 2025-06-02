python_env:
	uv sync

ruff_check:
	ruff check .

ruff_fix:
	ruff check --fix .

build_image:
	docker image build . --tag airflow_with_deps:latest

compose_up:
	docker compose up -d

compose_down:
	docker compose down -v