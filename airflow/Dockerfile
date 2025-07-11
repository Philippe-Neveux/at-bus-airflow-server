FROM apache/airflow:2.10.5

# COPY --from=ghcr.io/astral-sh/uv:0.7.12 /uv /uvx /bin/

COPY airflow/ /app
COPY requirements.txt /app/

WORKDIR /app

RUN pip install -r requirements.txt