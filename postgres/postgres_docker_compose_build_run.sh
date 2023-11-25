#!/bin/bash

set -e

USER_ID=$(id -u)
GROUP_ID=$(id -g)
HOST_PORT="$1"

# Проверка передан ли номер порта в качестве аргумента
if [ -z "$HOST_PORT" ]; then
    echo "Укажите порт PostgreSQL."
    exit 1
fi

# Обновленный файл docker-compose.yml с ограничениями по памяти и CPU
echo "version: '2.4'

services:
  postgres:
    build:
      context: ~/hw1_postgres/docker_env
      dockerfile: kmavropulo_hw1_postgres_dockerfile
      args:
        USER_ID: ${USER_ID}
        GROUP_ID: ${GROUP_ID}
    image: kmavropulo_hw1_postgres_image
    ports:
      - '${HOST_PORT}:5432'
    volumes:
      - ~/hw1_postgres/docker_env/postgres_db_data:/var/lib/postgresql/data
    container_name: kmavropulo_hw1_postgres_container
    mem_limit: 500m  # Максимальный предел использования памяти контейнером
    memswap_limit: 1g  # Максимальный предел использования swap-памяти
    cpus: 0.5  # Ограничение использования CPU контейнером до 50%" > docker-compose.yml

# Запуск сборки образа и запуска контейнера в режиме совместимости версий
sudo -E docker-compose --compatibility up -d
