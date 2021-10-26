# Install PostgreSQL and create database used by cardano-db-sync

- This guide assumes you are running a recent version of linux
- The `cardano-db-sync` and `cardano-db-sync-extended` programs write
blockchain data to a Postgres database according to a specific schema
- This document will set up the PostgreSQL database and the schema used by the db-sync programs  

## Install PostgreSQL

- These directions apply to Ubuntu (Debian variant). If you are using a different linux variant, please adjust as needed
- Update/upgrade your package indexes
  ```shell
  sudo apt-get update
  sudo apt-get upgrade  
  ```
- Install postgres and the -contrib package that adds some additional utilities and functionality
  ```shell
  sudo apt-get install postgresql postgresql-contrib
  ```
- Verify postgres is installed by starting a postgres sql session in the terminal
  ```shell
  sudo -u postgres psql
  
  # exit the session 
  \q
  ```

## Create new Postgres user (AKA role) for your own linux user account

- We will be using a BASH shell script, `postgresql-setup.sh` from the `cardano-db-sync` project to create/drop the database and run migrations.
- We want to run this script using our own user account.  Our user must be a superuser in order to create/drop databases, etc.
- Upon installation, Postgres is set up to use `ident authentication`, 
  meaning that it associates Postgres roles with a matching Unix/Linux system account. 
  If a role exists within Postgres, a Unix/Linux username with the same name is able to sign in as that role.
  - [Postgresql Ident Authentication](https://www.postgresql.org/docs/current/auth-ident.html)  
  
---
- Create a user for your local linux user account and give it superuser role
  ```shell
  sudo -u postgres createuser --interactive
  
  # enter your linux user account
  Enter name of role to add: <your_linux_user_account>
  Shall the new role be a superuser? (y/n) y
  ```

## Create the db-sync database

- Modify the postgres connection file [here](./postgres-config/pgpass-privatenet) as necessary. The defaults should probably work for you.
- Open terminal and set up environment variable with path to the postgres connection file above
  ```shell
  # set the variable with path to this project
  export PGPASSFILE=<path_to_this_project>/postgres-config/pgpass-privatenet  
  ```
- Run the cardano-db-sync script to create the database and install the schema
  ```shell
  # navigate to your cardano-db-sync project source directory
  cd /path/to/cardano-db-sync
  ./scripts/postgresql-setup.sh --createdb
  
  # output
  # verify you see "All good!" or correct any errors as necessary
  ```
- **Note**: Installing the schema for the database we just created will be done automatically, when we run the cardano-db-sync process