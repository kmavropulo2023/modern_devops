#!/bin/bash

set -e

USER_ID=$(id -u)
GROUP_ID=$(id -g)
NGINX_EXPOSE_PORT="$1"
NGINX_PORT="$2"

# Проверка передан ли номер порта NGINX
if [ -z "$NGINX_EXPOSE_PORT" ]; then
    echo "Укажите порт NGINX на host в качестве первого аргумента."
    exit 1
fi

if [ -z "$NGINX_PORT" ]; then
    echo "Укажите порт NGINX в контейнере в качестве второго аргумента."
    exit 1
fi

# Создание файла docker-compose.yml
echo "version: '3.8'

services:
  nginx:
    build:
      context: ~/hw1_nginx/docker_env
      dockerfile: kmavropulo_hw1_nginx_dockerfile
      args:
        USER_ID: ${USER_ID}
        GROUP_ID: ${GROUP_ID}
    image: kmavropulo_hw1_nginx_image
    ports:
      - '${NGINX_EXPOSE_PORT}:${NGINX_PORT}'
    volumes:
      - ~/hw1_nginx/docker_env/nginx.conf:/etc/nginx/nginx.conf
      - ~/hw1_nginx/docker_env/logs:/var/log/nginx  # Добавленный том для логов nginx
    container_name: kmavropulo_hw1_nginx_container
    mem_limit: 500m  # Максимальный предел использования памяти контейнером
    memswap_limit: 1g  # Максимальный предел использования swap-памяти
    cpus: 0.5  # Ограничение использования CPU контейнером до 50%
" > docker-compose.yml

# Запуск сборки образа и запуска контейнера в режиме совместимости версий
sudo -E docker-compose --compatibility up -d
