# Localy PostgreSQL install

``` Shell
sudo dnf install postgresql-server postgresql-contrib
sudo systemctl enable postgresql
sudo postgresql-setup --initdb --unit postgresql
sudo systemctl start postgresql
sudo -u postgres psql
```

``` PG
    CREATE USER jondaw WITH PASSWORD '550309666';
    CREATE DATABASE test OWNER jondaw;
```

``` Shell
psql test
```

## Change credential privileges

``` Shell
sudo vim /var/lib/pgsql/data/pg_hba.conf
```

``` Shell
 # TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     password
# IPv4 local connections:
host    all             all             127.0.0.1/32            password
# IPv6 local connections:
host    all             all             ::1/128                 password
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     password
host    replication     all             127.0.0.1/32            password
host    replication     all             ::1/128                 password
```

## Set credentials

``` JS
var pg = require('pg');
const conString = {
    user: 'jondaw',
    database: 'test',
    password: '550309666',
    host: 'localhost',
    // port: process.env.DBPORT
};
```