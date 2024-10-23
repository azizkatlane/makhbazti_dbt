#!/bin/bash


cd ~/makhbazti_dbt/MAKHBAZTI_DBT


dbt seed --select "Tunisia_Holidays" --profiles-dir ~/.dbt/


dbt snapshot --profiles-dir ~/.dbt/

# Run the dbt transformation
dbt run --profiles-dir ~/.dbt/ 2>&1 | tee logs/dbt_transform.log