1. .dlt / secrets.toml
contains destination and source credentials

2. DBT Configuration (~/.dbt/profiles.yml)
The profiles.yml file is used by DBT to store connection details to the destination database where the transformed data will be written. This file allows DBT to know how to connect to your target database for running the transformations.

Location:
~/.dbt/profiles.yml
