ARG BASE_IMAGE=python:3.9-slim
FROM $BASE_IMAGE as runtime-environment

# Actualiza pip
RUN python -m pip install --upgrade pip

# Copia el archivo requirements.txt al contenedor
COPY requirements.txt /tmp/requirements.txt

# Instala las dependencias desde requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Actualiza todas las dependencias instaladas
RUN pip install --no-cache-dir --upgrade $(pip freeze | awk -F '==' '{print $1}')

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

# Comando predeterminado para iniciar Jupyter Notebook
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
