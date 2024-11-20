### DEPRECATED!!

#### ENVIRONMENT VARIABLES

when using exportable env variables make sure secrets.toml is empty

Example setting up:
```bash
export SOURCES__MONGODB__CONNECTION_URL="mongodb://dbuser:passwd@host.or.ip:27017"
export DESTINATION__POSTGRES__CREDENTIALS="postgresql://username:password@host:port/database" 
```
#### Naming convention  

```console
DB name for both DESTINATION__POSTGRES__CREDENTIALS="postgresql://username:password@host:port/database"  and DBT_DB credential should be the same
```
