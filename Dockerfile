FROM apache/airflow:3.0.1

ADD https://astral.sh/uv/0.7.9/install.sh /uv-installer.sh

ADD . /app
WORKDIR /app

RUN uv pip install -r pyproject.toml
