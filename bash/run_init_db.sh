#!/bin/bash
docker run --name postgres \
-p 5432:5432 \
-e POSTGRES_DB="demo" \
-e POSTGRES_USER="test_sde" \
-e POSTGRES_PASSWORD="@sde_password012" \
-d postgres
 docker cp $(pwd)/../sql postgres://var/lib/postgresql/data
 sleep 5
winpty docker exec postgres psql -U test_sde -d demo -f //var/lib/postgresql/data/sql/init_db/demo.sql

 sleep 200



