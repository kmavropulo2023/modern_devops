#!/bin/bash

set -e

# Переменные
NGINX_PORT="$1"
SERVER_PORT="$2"

# Проверка передан ли порт для NGINX
if [ -z "$NGINX_PORT" ]; then
    echo "Укажите порт NGINX."
    exit 1
fi

# Проверка передан ли номер порта приложения
if [ -z "$SERVER_PORT" ]; then
    echo "Укажите порт приложения."
    exit 1
fi

# Вывод версии Docker
docker --version
docker-compose --version
echo "Шаг 1. Версии Docker и Docker Compose выведены."

# Настройка среды Docker
mkdir -p ~/hw1_nginx/docker_env/logs
mkdir -p ~/hw1_nginx/docker_env && cd ~/hw1_nginx/docker_env
echo "Шаг 2. Создана директория ~/hw1_nginx/docker_env, выбрана текущей."

# Установка прав доступа текущему пользователю
chown $(id -u):$(id -g) ~/hw1_nginx/docker_env && chmod 700 ~/hw1_nginx/docker_env
echo "Шаг 3. Права доступа установлены."

# Создание Dockerfile для nginx на базе Alpine
cat > kmavropulo_hw1_nginx_dockerfile <<EOF
FROM nginx:alpine

EXPOSE \$NGINX_PORT

CMD ["nginx", "-g", "daemon off;"]
EOF
echo "Шаг 4. Dockerfile создан."

# Создание конфигурационного файла nginx
cat > nginx.conf <<EOF
user nginx;  # Установка пользователя, под которым будут работать процессы nginx
worker_processes  2;  # Количество рабочих процессов nginx
pid /var/log/nginx/nginx.pid;  # Путь к файлу PID
worker_rlimit_nofile 2048;  # Увеличение лимита на открытие файлов для каждого рабочего процесса

events {
    worker_connections  1024;  # Максимальное количество соединений на рабочий процесс
}

http {
    include       /etc/nginx/mime.types;  # Включение файла mime types
    default_type  application/octet-stream;  # Тип контента по умолчанию

    access_log /var/log/nginx/access.log;  # Путь к файлу лога доступа
    error_log /var/log/nginx/error.log;  # Путь к файлу лога ошибок

    server {
        listen       $NGINX_PORT;  # Порт, на котором будет слушать сервер nginx
        server_name  localhost;  # Имя сервера ngins

        location /db {
            proxy_pass http://localhost:$SERVER_PORT;  # Проксирование запросов
            limit_except POST {
                deny all;  # Разрешение только POST-запросов
            }
        }
    }
}
EOF

echo "Шаг 5. Конфигурационный файл nginx.conf создан."

# Установка прав доступа на все файлы
chmod -R 700 ~/hw1_nginx/docker_env
echo "Шаг 6. Права доступа на все файлы установлены."

# Проверка дерева каталога окружения для сборки docker образа
if ! command -v tree &> /dev/null; then
    echo "Установка пакета 'tree' .."
    sudo apt-get update && sudo apt-get install tree
fi

tree -h ~/hw1_nginx/
echo "Шаг 7. Данные дерева файлов окружения для сборки docker образа отображено."
