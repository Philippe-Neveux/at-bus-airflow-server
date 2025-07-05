deploy-airflow:
	uv run ansible-playbook -i inventory/production.yml playbooks/deploy/airflow.yml -v

deploy-airflow-files:
	uv run ansible-playbook -i inventory/production.yml playbooks/deploy/airflow.yml -v --tags files


check-syntax-playbooks:
	uv run ansible-playbook --syntax-check -i inventory/production.yml playbooks/deploy/airflow.yml
	uv run ansible-playbook --syntax-check -i inventory/production.yml playbooks/operations/stop-airflow.yml
	uv run ansible-playbook --syntax-check -i inventory/production.yml playbooks/operations/restart-airflow.yml
	uv run ansible-playbook --syntax-check -i inventory/production.yml playbooks/operations/status-airflow.yml
	uv run ansible-playbook --syntax-check -i inventory/production.yml playbooks/operations/docker-pull.yml

stop-airflow:
	uv run ansible-playbook -i inventory/production.yml playbooks/operations/stop-airflow.yml -v

restart-airflow:
	uv run ansible-playbook -i inventory/production.yml playbooks/operations/restart-airflow.yml -v

check-airflow-status:
	uv run ansible-playbook -i inventory/production.yml playbooks/operations/status-airflow.yml -v

# Docker pull with custom image (usage: make docker-pull IMAGE=postgres:13)
docker-pull:
	uv run ansible-playbook -i inventory/production.yml playbooks/operations/docker-pull.yml -v -e "docker_image_name=$(IMAGE)"
