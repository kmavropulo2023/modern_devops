#!/bin/bash

set -e

# Вывод версии Docker
docker --version
docker-compose --version
echo "Шаг 1. Версии Docker и Docker Compose выведены."

# Настройка среды Docker
mkdir -p ~/hw1_postgres/docker_env && cd ~/hw1_postgres/docker_env
echo "Шаг 2. Создана директория ~/hw1_postgres/docker_env, выбрана текущей."

# Установка прав доступа текущему пользователю
chown $(id -u):$(id -g) ~/hw1_postgres/docker_env && chmod 700 ~/hw1_postgres/docker_env
echo "Шаг 3. Права доступа установлены."

# Создание Dockerfile
cat > kmavropulo_hw1_postgres_dockerfile <<EOF
FROM postgres:latest

ARG USER_ID
ARG GROUP_ID

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=mysecurepassword

RUN echo "User ID: \${USER_ID}, Group ID: \${GROUP_ID}"

RUN if [ "\$(id -u postgres)" != "\${USER_ID}" ]; then \
        usermod -u \${USER_ID} postgres; \
    fi && \
    if [ "\$(id -g postgres)" != "\${GROUP_ID}" ]; then \
        groupmod -g \${GROUP_ID} postgres; \
    fi && \
    echo "Изменение id группы и пользователя postgres - успех."

RUN mkdir -p /docker-entrypoint-initdb.d && \
    echo "Создание директории для скриптов инициализации - успех."

COPY ./init-scripts/ /docker-entrypoint-initdb.d/
RUN ls -l /docker-entrypoint-initdb.d/ && \
    echo "Добавлены скрипты инициализации БД /docker-entrypoint-initdb.d - успех."

COPY ./db_config/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
RUN ls -l /var/lib/postgresql/data/pg_hba.conf && \
    echo "Обновлен файл конфигурации БД pg_hba.conf - успех."

RUN chown -R \${USER_ID}:\${GROUP_ID} /var/lib/postgresql \
    /docker-entrypoint-initdb.d \
    /usr/lib/postgresql/ \
    /usr/share/postgresql/ \
    /etc/postgresql/ && \
    chmod -R 700 /var/lib/postgresql/data && \
    echo "Обновление прав собственности и разрешений - успех."

EXPOSE 5432

CMD ["postgres"]
EOF
echo "Шаг 4. Dockerfile создан."

# Создание файла конфигурации pg_hba.conf
mkdir -p db_config && chmod 700 db_config
cat > db_config/pg_hba.conf <<EOF
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     trust
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             ::1/128                 scram-sha-256
host    all             all             0.0.0.0/0               reject
host    all             all             ::/0                    reject
EOF
echo "Шаг 5. Файл pg_hba.conf создан."

# Создание скриптов инициализации
mkdir -p init-scripts && chmod 700 init-scripts
cat > init-scripts/01_create_test_db.sql <<EOF
CREATE DATABASE test;
EOF

cat > init-scripts/02_create_test_user.sql <<EOF
CREATE ROLE test WITH LOGIN PASSWORD 'test_password';
GRANT pg_read_all_data, pg_monitor, pg_read_server_files TO test;
EOF

cat > init-scripts/03_create_test_schema.sql <<EOF
\c test

CREATE SCHEMA test AUTHORIZATION postgres;
EOF

cat > init-scripts/04_grant_test_ownership.sql <<EOF
\c test

ALTER SCHEMA test OWNER TO test;
ALTER DATABASE test OWNER TO test;
GRANT ALL PRIVILEGES ON SCHEMA test TO test;
GRANT ALL PRIVILEGES ON DATABASE test TO test;
EOF
echo "Шаг 6. Скрипты инициализации созданы."

# Создание директории для данных PostgreSQL
mkdir -p ~/hw1_postgres/docker_env/postgres_db_data
echo "Шаг 7. Директория для данных PostgreSQL создана."

# Установка прав доступа на все файлы
chmod -R 700 ~/hw1_postgres/docker_env
echo "Шаг 8. Права доступа на все файлы установлены."

# Проверка дерева каталога окружения для сборки docker образа
if ! command -v tree &> /dev/null; then
    echo "Установка пакета 'tree' .."
    sudo apt-get update && sudo apt-get install tree
fi

tree -h ~/hw1_postgres/
echo "Шаг 9. Данные дерева файлов окружения для сборки docker образа отображено."
