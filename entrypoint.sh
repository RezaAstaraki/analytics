#!/bin/bash
set -e

# Start SQL Server in the background
/opt/mssql/bin/sqlservr &
pid=$!

shutdown() {
  echo "Shutting down SQL Server..."
  kill -SIGTERM "$pid"
  wait "$pid"
  exit 0
}
trap shutdown SIGTERM SIGINT

echo "Waiting for SQL Server to start..."
for i in $(seq 1 60); do
  if /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" >/dev/null 2>&1; then
    echo "SQL Server is ready."
    break
  fi
  sleep 2
  if [ "$i" -eq 60 ]; then
    echo "ERROR: SQL Server failed to start within 120 seconds."
    exit 1
  fi
done

# Run init scripts only once per data volume
INIT_FLAG=/var/opt/mssql/.analytics-initialized
if [ -f "$INIT_FLAG" ]; then
  echo "Init already completed — skipping scripts."
elif [ -d "/docker-entrypoint-initdb.d" ]; then
  for sql_file in /docker-entrypoint-initdb.d/*.sql; do
    if [ -f "$sql_file" ]; then
      echo "Running $sql_file..."
      /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -i "$sql_file"
    fi
  done
  touch "$INIT_FLAG"
  echo "Initialization scripts completed."
else
  echo "No init scripts folder found, skipping."
fi

wait "$pid"
