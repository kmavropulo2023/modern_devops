#!/bin/bash

NGINX_HOST="localhost"
NGINX_PORT="$1"

# Проверка передан ли номер порта в качестве аргумента
if [ -z "$NGINX_PORT" ]; then
    echo "Пожалуйста, укажите номер порта nginx в качестве аргумента."
    exit 1
fi

# Проверка наличия утилиты curl
if ! command -v curl &> /dev/null; then
    echo "Установка утилиты curl ..."
    sudo apt-get update && sudo apt-get install -y curl
fi

echo "Выполнение GET запроса к nginx"
curl -X GET http://${NGINX_HOST}:${NGINX_PORT}/db

echo "Выполнение POST запроса к nginx"
curl -X POST http://${NGINX_HOST}:${NGINX_PORT}/db

# Получение логов nginx из Docker контейнера
echo "Получение логов доступа nginx:"
docker exec kmavropulo_hw1_nginx_container cat /var/log/nginx/access.log

echo "Получение логов ошибок nginx:"
docker exec kmavropulo_hw1_nginx_container cat /var/log/nginx/error.log
