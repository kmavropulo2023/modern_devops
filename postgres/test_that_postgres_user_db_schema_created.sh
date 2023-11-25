#!/bin/bash

# Проверка передан ли пароль в качестве аргумента
if [ -z "$1" ]; then
    echo "Пожалуйста, укажите пароль для подключения к PostgreSQL в качестве аргумента."
    exit 1
fi

# Проверка передан ли номер порта в качестве второго аргумента
if [ -z "$2" ]; then
    echo "Пожалуйста, укажите номер порта PostgreSQL в качестве второго аргумента."
    exit 1
fi

# Настройки PostgreSQL
PG_PASSWORD=$1
PG_PORT=$2
PG_HOST="localhost"
TEST_USER="test"
TEST_USER_SCHEMA="test"
DB_NAME="test"

# Установка переменной окружения PGPASSWORD
export PGPASSWORD=$PG_PASSWORD

echo "Установка клиента PostgreSQL"
sudo apt-get update
sudo apt-get install -y postgresql postgresql-client

echo "Выполнение запросов к PostgreSQL"

echo "Запрос на проверку существования пользователя '${TEST_USER}':"
psql -h ${PG_HOST} -p ${PG_PORT} -U ${TEST_USER} -Ac "SELECT * FROM pg_roles WHERE rolname='${TEST_USER}'"

echo "Запрос на проверку существования базы данных '${DB_NAME}':"
psql -h ${PG_HOST} -p ${PG_PORT} -U ${TEST_USER} -Ac "SELECT * FROM pg_database WHERE datname='${DB_NAME}'"

echo "Запрос на проверку существования схемы '${TEST_USER_SCHEMA}':"
psql -h ${PG_HOST} -p ${PG_PORT} -U ${TEST_USER} -Ac "SELECT * FROM information_schema.schemata WHERE schema_name='${TEST_USER_SCHEMA}'"

echo "Запрос статистик БД (pg_stat_database):"
psql -h ${PG_HOST} -p ${PG_PORT} -U ${TEST_USER} -Ac "SELECT * FROM pg_stat_database;"

# Сброс переменной окружения
unset PGPASSWORD
