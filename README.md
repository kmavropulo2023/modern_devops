# Домашняя работа 1 (Написать два докер-файла nginx и postgresql)
#### Автор - Константин Мавропуло
Решение состоит из двух частей:  
* создание и тестирование запуска образа nginx ([ссылка на описание](#nginx));
* создание и тестирование запуска образа postgresql ([ссылка на описание](#postgres)).

<a id="nginx"></a>
### Решение первой части (написать docker-file nginx).
##### Для решения первой части первого задания (написать docker-file nginx) создано три скрипта:
- `nginx_docker_image_env_data_creation_script.sh` - создает окружение для создания docker-file и образа;
- `nginx_docker_compose_build_run.sh` - создает образ и запускает через docker-compose;
- `test_that_nginx_works.sh` - тестирует процессинг запросов сервиса nginx.
##### Файлы для решения первой части первого задания (написать docker-file nginx):
* в папке nginx - результаты решения первой части, включая dockerfile, вышеуказанные скрипты, файл конфигурации nginx, файл запуска docker compose и прочие файлы.

**Детали решения первой части первого задания** (написать docker-file nginx) - ниже:  
1. `nginx_docker_image_env_data_creation_script.sh` - создает окружение для создания docker-file и образа, перед запуском требуется поместить в папку пользователя на linux ОС, добавить права на запуск.
Имеет детальное описание как в самом скрипте, так и по итогам запуска в логах, ниже пример вывода запуска скрипта и логи отображающие основные изменения:  
```sh
silicicarcher@instance-1:~$ ./nginx_docker_image_env_data_creation_script.sh 80 55051
Docker version 24.0.0, build 98fdcd7
Docker Compose version v2.23.3
Шаг 1. Версии Docker и Docker Compose выведены.
Шаг 2. Создана директория ~/hw1_nginx/docker_env, выбрана текущей.
Шаг 3. Права доступа установлены.
Шаг 4. Dockerfile создан.
Шаг 5. Конфигурационный файл nginx.conf создан.
Шаг 6. Права доступа на все файлы установлены.
/home/silicicarcher/hw1_nginx/
└── [4.0K]  docker_env
    ├── [  74]  kmavropulo_hw1_nginx_dockerfile
    ├── [4.0K]  logs
    └── [1.4K]  nginx.conf

2 directories, 2 files
Шаг 7. Данные дерева файлов окружения для сборки docker образа отображено.
```
2. `nginx_docker_compose_build_run.sh` - создает образ nginx на основе созданного окружения (предыдущим скриптом) и запускает контейнер в режиме совместимости с предыдущими версиями через Docker Compose, перед запуском требуется поместить в папку пользователя на linux ОС, добавить права на запуск.
Имеет детальное описание в самом скрипте, ниже пример вывода запуска скрипта:  
```sh
silicicarcher@instance-1:~$ ./nginx_docker_compose_build_run.sh 35051 80
[+] Running 1/1
 ! nginx Warning                                                                    0.4s 
[+] Building 1.4s (9/9) FINISHED                                          docker:default
 => [nginx internal] load .dockerignore                                             0.0s
 => => transferring context: 2B                                                     0.0s
 => [nginx internal] load build definition from kmavropulo_hw1_nginx_dockerfile     0.0s
 => => transferring dockerfile: 660B                                                0.0s
 => [nginx internal] load metadata for docker.io/library/nginx:alpine               0.4s
 => [nginx 1/4] FROM docker.io/library/nginx:alpine@sha256:db353d0f0c479c91bd15e01  0.0s
 => [nginx internal] load build context                                             0.0s
 => => transferring context: 1.44kB                                                 0.0s
 => CACHED [nginx 2/4] RUN apk --no-cache add shadow &&  if [ "$(id -u nginx)" !=   0.0s
 => [nginx 3/4] COPY ./nginx.conf /etc/nginx/nginx.conf                             0.0s
 => [nginx 4/4] RUN ls -l /etc/nginx/nginx.conf &&     echo "Обновлен фа            0.6s
 => [nginx] exporting to image                                                      0.1s
 => => exporting layers                                                             0.1s
 => => writing image sha256:cbacd235595ee7cb2eab5303bfc58e3f4d10b08da805eaa1beeddb  0.0s
 => => naming to docker.io/library/kmavropulo_hw1_nginx_image                       0.0s
[+] Running 1/1
 ✔ Container kmavropulo_hw1_nginx_container  Started                                0.1s
```
3. `test_that_nginx_works.sh` - тестирует запущенный контейнер образа nginx с помощью запросов к nginx сервису из host linux ОС через утилиту curl, перез запуском требуется поместить скрипт в папку пользователя на linux ОС, добавить права на запуск.
Имеет детальное описание как в самом скрипте, так и по итогам запуска в логах, ниже пример вывода запуска скрипта и логи, отображающие этапы тестирования (выполнение GET и POST запросов и успешный вывод ответов и логов nginx, сторонние сервисы upstream не запускались):  
```sh
silicicarcher@instance-1:~$ ./test_that_nginx_works.sh 35051
Выполнение GET запроса к nginx
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.25.3</center>
</body>
</html>
Выполнение POST запроса к nginx
<html>
<head><title>502 Bad Gateway</title></head>
<body>
<center><h1>502 Bad Gateway</h1></center>
<hr><center>nginx/1.25.3</center>
</body>
</html>
Получение логов доступа nginx:
172.19.0.1 - - [24/Nov/2023:23:56:57 +0000] "GET /db HTTP/1.1" 403 153 "-" "curl/7.74.0"
172.19.0.1 - - [24/Nov/2023:23:56:57 +0000] "POST /db HTTP/1.1" 502 157 "-" "curl/7.74.0"
Получение логов ошибок nginx:
2023/11/24 23:56:57 [error] 30#30: *1 access forbidden by rule, client: 172.19.0.1, server: localhost, request: "GET /db HTTP/1.1", host: "localhost:35051"
2023/11/24 23:56:57 [error] 31#31: *2 connect() failed (111: Connection refused) while connecting to upstream, client: 172.19.0.1, server: localhost, request: "POST /db HTTP/1.1", upstream: "http://127.0.0.1:55051/db", host: "localhost:35051"
```

<a id="postgres"></a>
### Решение второй части (написать docker-file postgres).
##### Для решения второй части первого задания (написать docker-file postgres) создано три скрипта:
- `postgres_docker_image_env_data_creation_script.sh` - создает окружение для создания docker-file и образа;
- `postgres_docker_compose_build_run.sh` - создает образ и запускает через docker-compose;
- `test_that_postgres_works.sh` - тестирует процессинг запросов к контейнеру с БД postgres.
  
##### Файлы для решения второй части первого задания (написать docker-file postgres):
* в папке postgres - результаты решения второй части, включая dockerfile, вышеуказанные скрипты, скрипты инициализации базы данных postgres, файл конфигурации базы данных, файл запуска docker compose и прочие файлы.

**Детали решения второй части первого задания** (написать docker-file postgres) - ниже:
1. `postgres_docker_image_env_data_creation_script.sh` - создает окружение для создания docker-file и образа, перед запуском требуется поместить в папку пользователя на linux ОС, добавить права на запуск.
Имеет детальное описание как в самом скрипте, так и по итогам запуска в логах, ниже пример вывода запуска скрипта и логи отображающие основные изменения:  
```sh
silicicarcher@instance-1:~$ ./postgres_docker_image_env_data_creation_script.sh 
Docker version 24.0.0, build 98fdcd7
Docker Compose version v2.23.3
Шаг 1. Версии Docker и Docker Compose выведены.
Шаг 2. Создана директория ~/hw1_postgres/docker_env, выбрана текущей.
Шаг 3. Права доступа установлены.
Шаг 4. Dockerfile создан.
Шаг 5. Файл pg_hba.conf создан.
Шаг 6. Скрипты инициализации созданы.
Шаг 7. Директория для данных PostgreSQL создана.
Шаг 8. Права доступа на все файлы установлены.
/home/silicicarcher/hw1_postgres/
└── [4.0K]  docker_env
    ├── [4.0K]  db_config
    │   └── [ 439]  pg_hba.conf
    ├── [4.0K]  init-scripts
    │   ├── [  22]  01_create_test_db.sql
    │   ├── [ 120]  02_create_test_user.sql
    │   ├── [  52]  03_create_test_schema.sql
    │   └── [ 169]  04_grant_test_ownership.sql
    ├── [1.4K]  kmavropulo_hw1_postgres_dockerfile
    └── [4.0K]  postgres_db_data

4 directories, 6 files
Шаг 9. Данные дерева файлов окружения для сборки docker образа отображено.
```
2. `postgres_docker_compose_build_run.sh` - создает образ postgres на основе созданного окружения (предыдущим скриптом) и запускает контейнер в режиме совместимости с предыдущими версиями через Docker Compose, перед запуском требуется поместить в папку пользователя на linux ОС, добавить права на запуск.
Имеет детальное описание в самом скрипте, ниже пример вывода запуска скрипта:  
```sh
silicicarcher@instance-1:~$ ./postgres_docker_compose_build_run.sh 45051
[+] Running 1/1
 ! postgres Warning                                                                 0.4s 
[+] Building 0.2s (14/14) FINISHED                                        docker:default
 => [postgres internal] load .dockerignore                                          0.0s
 => => transferring context: 2B                                                     0.0s
 => [postgres internal] load build definition from kmavropulo_hw1_postgres_dockerf  0.0s
 => => transferring dockerfile: 1.47kB                                              0.0s
 => [postgres internal] load metadata for docker.io/library/postgres:latest         0.1s
 => [postgres 1/9] FROM docker.io/library/postgres:latest@sha256:71da05df8c4f1e1ba  0.0s
 => [postgres internal] load build context                                          0.0s
 => => transferring context: 1.18kB                                                 0.0s
 => CACHED [postgres 2/9] RUN echo "User ID: 1000, Group ID: 1001"                  0.0s
 => CACHED [postgres 3/9] RUN if [ "$(id -u postgres)" != "1000" ]; then         u  0.0s
 => CACHED [postgres 4/9] RUN mkdir -p /docker-entrypoint-initdb.d &&     echo "С   0.0s
 => CACHED [postgres 5/9] COPY ./init-scripts/ /docker-entrypoint-initdb.d/         0.0s
 => CACHED [postgres 6/9] RUN ls -l /docker-entrypoint-initdb.d/ &&     echo "До    0.0s
 => CACHED [postgres 7/9] COPY ./db_config/pg_hba.conf /var/lib/postgresql/data/pg  0.0s
 => CACHED [postgres 8/9] RUN ls -l /var/lib/postgresql/data/pg_hba.conf &&     ec  0.0s
 => CACHED [postgres 9/9] RUN chown -R 1000:1001 /var/lib/postgresql     /docker-e  0.0s
 => [postgres] exporting to image                                                   0.0s
 => => exporting layers                                                             0.0s
 => => writing image sha256:e7f27db9ad93c8e75ab26e9a917a4854381f251716be9611eb4c58  0.0s
 => => naming to docker.io/library/kmavropulo_hw1_postgres_image                    0.0s
[+] Running 1/1
 ✔ Container kmavropulo_hw1_postgres_container  Started                                0.0s
```
3. `test_that_postgres_works.sh` - тестирует запущенный контейнер образа postgres с помощью запросов к БД из host linux ОС через клиент psql, перез запуском требуется поместить скрипт в папку пользователя на linux ОС, добавить права на запуск.
Имеет детальное описание как в самом скрипте, так и по итогам запуска в логах, ниже пример вывода запуска скрипта и логи, отображающие этапы тестирования (выполнение запросов существования созданного пользователя, базы данных, схемы и статистик БД):  
```sh
silicicarcher@instance-1:~$ ./test_that_postgres_user_db_schema_created.sh test_password 45051
Установка клиента PostgreSQL
Hit:1 https://packages.cloud.google.com/apt google-compute-engine-bullseye-stable InRelease
Get:2 https://packages.cloud.google.com/apt cloud-sdk-bullseye InRelease [6406 B]       
Hit:3 https://deb.debian.org/debian bullseye InRelease                                  
Hit:4 https://deb.debian.org/debian-security bullseye-security InRelease 
Hit:5 https://deb.debian.org/debian bullseye-updates InRelease
Hit:6 https://deb.debian.org/debian bullseye-backports InRelease
Ign:7 https://download.docker.com/linux/ubuntu bullseye InRelease
Hit:8 https://download.docker.com/linux/debian bullseye InRelease
Err:9 https://download.docker.com/linux/ubuntu bullseye Release
  404  Not Found [IP: 65.8.248.22 443]
Reading package lists... Done
E: The repository 'https://download.docker.com/linux/ubuntu bullseye Release' does not have a Release file.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
postgresql is already the newest version (13+225).
postgresql-client is already the newest version (13+225).
0 upgraded, 0 newly installed, 0 to remove and 2 not upgraded.
Выполнение запросов к PostgreSQL
Запрос на проверку существования пользователя 'test':
rolname|rolsuper|rolinherit|rolcreaterole|rolcreatedb|rolcanlogin|rolreplication|rolconnlimit|rolpassword|rolvaliduntil|rolbypassrls|rolconfig|oid
test|f|t|f|f|t|f|-1|********||f||16385
(1 row)
Запрос на проверку существования базы данных 'test':
oid|datname|datdba|encoding|datlocprovider|datistemplate|datallowconn|datconnlimit|datfrozenxid|datminmxid|dattablespace|datcollate|datctype|daticulocale|daticurules|datcollversion|datacl
16384|test|16385|6|c|f|t|-1|723|1|1663|en_US.utf8|en_US.utf8|||2.36|{=Tc/test,test=CTc/test}
(1 row)
Запрос на проверку существования схемы 'test':
catalog_name|schema_name|schema_owner|default_character_set_catalog|default_character_set_schema|default_character_set_name|sql_path
test|test|test||||
(1 row)
Запрос статистик БД (pg_stat_database):
datid|datname|numbackends|xact_commit|xact_rollback|blks_read|blks_hit|tup_returned|tup_fetched|tup_inserted|tup_updated|tup_deleted|conflicts|temp_files|temp_bytes|deadlocks|checksum_failures|checksum_last_failure|blk_read_time|blk_write_time|session_time|active_time|idle_in_transaction_time|sessions|sessions_abandoned|sessions_fatal|sessions_killed|stats_reset
0||0|0|0|89|702|212|107|33|7|0|0|0|0|0|||0|0|0|0|0|0|0|0|0|
5|postgres|0|9|0|104|1798|1007|922|0|0|0|0|0|0|0|||0|0|223.38|143.023|0|5|0|0|0|
1|template1|0|884|0|505|82405|69860|23205|17613|590|28|0|0|0|0|||0|0|0|0|0|0|0|0|0|
4|template0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|||0|0|0|0|0|0|0|0|0|
16384|test|1|16|0|146|3873|3038|2000|1|2|0|0|0|0|0|||0|0|56.023|10.956|0|6|0|0|0|
(5 rows)
```
