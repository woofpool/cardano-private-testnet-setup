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
- Install postgres packages including libpq-dev, which is needed for building `cardano-db-sync`
  ```shell
  sudo apt-get install libpq-dev postgresql postgresql-contrib
  ```
- Verify postgres is installed by starting a postgres sql session in the terminal
  ```shell
  sudo -u postgres psql
  
  # you should see prompt
  # postgres=#
  
  # to exit the session 
  \q
  ```

## Create new Postgres role for your linux user account

- Upon installation, Postgres is set up to use `ident authentication`, 
  meaning that it associates Postgres roles with a matching Unix/Linux system account. 
  If a role exists within Postgres, a Unix/Linux username with the same name is able to sign in as that role.
  - Additional background documentation: [Postgresql Ident Authentication](https://www.postgresql.org/docs/current/auth-ident.html)  
    
- Create a user for your local linux user account and give it superuser role.   Our user must be a superuser in order to create/drop databases, etc.
  ```shell
  sudo -u postgres createuser --interactive
  
  # enter your linux user account
  Enter name of role to add: <your_linux_user_account_name>
  Shall the new role be a superuser? (y/n) y
  ```
- Verify your local account got created
  ```shell
  sudo -u postgres psql
  
  # you should see prompt
  # postgres=#
  
  # to display users 
  \du
  
  # you should see a role name of your linux account with Superuser role attribute
  
  # to exit the session 
  \q
  ```

## Create the db-sync database

- Modify the postgres connection file [here](postgres-conn/pgpass-privatenet) as necessary. The defaults should probably work for you.
- Open terminal and set up environment variable with path to the postgres connection file above
  ```shell
  # navigate to this projects root folder
  cd <path/to/cardano-dbsync-private-network>

  # set the variable with path to the postgres connection file
  # this connection file defines a database name of `privatenet`
  export PGPASSFILE=postgres-conn/pgpass-privatenet
  ```
- Run the cardano-db-sync script to create the database and install the schema
  ```shell
  # navigate to your cardano-db-sync project source directory
  cd $HOME/src/cardano-db-sync
  
  # run the setup script to create database
  ./scripts/postgresql-setup.sh --createdb
  
  # output
  # verify you see "All good!" or correct any errors as necessary
  ```
- **Note**: Installing the schema for the database we just created will be done automatically, when we run the cardano-db-sync process