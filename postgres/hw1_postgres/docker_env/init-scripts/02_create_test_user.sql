CREATE ROLE test WITH LOGIN PASSWORD 'test_password';
GRANT pg_read_all_data, pg_monitor, pg_read_server_files TO test;
