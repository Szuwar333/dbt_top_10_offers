
FROM python:3.10-slim-buster
# FROM public.ecr.aws/lambda/python:3.12
# setting the working directory to usr
WORKDIR /dbt

COPY requirements.txt requirements.txt
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
# RUN pip install awslambdaric

COPY models models
COPY tests tests
COPY snapshots snapshots
COPY seeds seeds
COPY macros macros
COPY dbt_project.yml dbt_project.yml
COPY profiles.yml profiles.yml
COPY packages.yml packages.yml
COPY entrypoint.py entrypoint.py
# COPY requirements.txt requirements.txt
# COPY packages.yml packages.yml
# COPY dbt_run.py /usr/python/
RUN dbt deps
RUN dbt seed
# CMD dbt run --profiles-dir /dbt
CMD ["python", "entrypoint.py"]

