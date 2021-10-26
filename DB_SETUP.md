# Install PostgreSQL and create database used by cardano-db-sync

---

### Summary

This document explains how to install PostgreSQL and create the database used by the db-sync executables

#### Assumptions
- This guide assumes you are running a recent version of linux. 
  Specifically, these directions apply to Ubuntu (Debian). If you are using a different linux variant, please adjust as needed
   

## Install PostgreSQL
 
- Update/upgrade your package indexes
  ```shell
  sudo apt-get update
  sudo apt-get upgrade
  # reboot as necessary  
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

- We will be using a shell script, `postgresql-setup.sh` from the `cardano-db-sync` project to create the database.
- We want to run this `postgresql-setup.sh` script using the linux user account you are logged in as. Use `whoami` to see your account name.
- Upon installation, Postgres is set up to use `ident authentication`, 
  meaning that it associates Postgres roles with a matching Unix/Linux system account. 
  If a role exists within Postgres, a Unix/Linux username with the same name is able to sign in as that role.
  - [Postgresql Ident Authentication](https://www.postgresql.org/docs/current/auth-ident.html)  
    
- Create a user for your local linux user account and give it superuser role.   Our user must be a superuser in order to create/drop databases, etc.
  ```shell
  sudo -u postgres createuser --interactive
  
  # enter your linux user account
  Enter name of role to add: <your_linux_user_account_name>
  Shall the new role be a superuser? (y/n) y
  ```
- Verify your local account got created
  ```shell
  sudo -u <your_linux_user_account_name> psql
  \conninfo
  ```

## Create the db-sync database

- Modify the postgres connection file [here](postgres-conn/pgpass-privatenet) as necessary. The defaults should probably work for you.
- Open terminal and set up environment variable with path to the postgres connection file above
  ```shell
  # navigate to this projects root folder
  cd <path/to/this/project>

  # set the variable with path to this project
  export PGPASSFILE=postgres-conn/pgpass-privatenet  
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