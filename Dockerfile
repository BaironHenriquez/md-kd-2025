FROM python:3.9-slim as runtime-environment

# Instala dependencias del sistema necesarias para psycopg2 y herramientas útiles (ping, psql)
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    gcc \
    iputils-ping \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Actualiza pip
RUN python -m pip install --upgrade pip

# Copia el archivo requirements.txt al contenedor
COPY requirements.txt /tmp/requirements.txt

# Instala las dependencias desde requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Actualiza todas las dependencias instaladas
RUN pip install --no-cache-dir --upgrade $(pip freeze | awk -F '==' '{print $1}')

# Instala las dependencias desde requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
    pip show psycopg2-binary

# Agrega un usuario para Kedro
ARG KEDRO_UID=999
ARG KEDRO_GID=0
RUN groupadd -f -g ${KEDRO_GID} kedro_group && \
    useradd -m -d /home/kedro_docker -s /bin/bash -g ${KEDRO_GID} -u ${KEDRO_UID} kedro_docker

WORKDIR /home/kedro_docker
USER kedro_docker

# Copia todo el proyecto al contenedor
COPY --chown=${KEDRO_UID}:${KEDRO_GID} . .

# Expone el puerto 8888 para Jupyter Notebook
EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
