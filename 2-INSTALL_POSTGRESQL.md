# Install PostgreSQL and create user

## Note: Please skip running this guide until an issue is fixed

A recent change to the `cardano-db-sync` project source code leads to a validation failure when trying to
attach the db-sync process to the private testnet. The author has logged an issue to find out how to resolve:
[logged cardano-db-sync issue](https://github.com/input-output-hk/cardano-db-sync/issues/1046).

[comment]: <> (**Note**: If you have not installed `cardano-db-sync`, then you should skip this guide and continue to next guide: [3. Run scripts]&#40;3-RUN_NETWORK_SCRIPTS.md&#41;)

[comment]: <> (This document explains how to install PostgreSQL and create a Postgres user.)

[comment]: <> (#### Assumptions)

[comment]: <> (- This guide assumes you are running a recent version of linux. )

[comment]: <> (  Specifically, these directions apply to Ubuntu &#40;Debian&#41;. If you are using a different linux variant, please adjust as needed)
   

[comment]: <> (## 1. Install PostgreSQL)
 
[comment]: <> (- Update/upgrade your package indexes)

[comment]: <> (  ```shell)

[comment]: <> (  sudo apt-get update)

[comment]: <> (  sudo apt-get upgrade)

[comment]: <> (  # reboot as necessary  )

[comment]: <> (  ```)

[comment]: <> (- Install postgreSQL packages)

[comment]: <> (  ```shell)

[comment]: <> (  sudo apt-get install postgresql postgresql-contrib)

[comment]: <> (  ```)

[comment]: <> (- Verify postgres is installed by starting a postgres sql session in the terminal)

[comment]: <> (  ```shell)

[comment]: <> (  sudo -u postgres psql)
  
[comment]: <> (  # you should see prompt)

[comment]: <> (  # postgres=#)
  
[comment]: <> (  # to exit the session )

[comment]: <> (  \q)

[comment]: <> (  ```)

[comment]: <> (## 2. Create new Postgres role for your linux user account)

[comment]: <> (- Upon installation, Postgres is set up to use `ident authentication`, )

[comment]: <> (  meaning that it associates Postgres roles with a matching Unix/Linux system account. )

[comment]: <> (  If a role exists within Postgres, a Unix/Linux username with the same name is able to sign in as that role.)

[comment]: <> (  - Additional background documentation: [Postgresql Ident Authentication]&#40;https://www.postgresql.org/docs/current/auth-ident.html&#41;  )
    
[comment]: <> (- Create a user for your local linux user account and give it superuser role.   Our user must be a superuser in order to create/drop databases, etc.)

[comment]: <> (  ```shell)

[comment]: <> (  sudo -u postgres createuser --interactive)
  
[comment]: <> (  # enter your linux user account)

[comment]: <> (  Enter name of role to add: <your_linux_user_account_name>)

[comment]: <> (  Shall the new role be a superuser? &#40;y/n&#41; y)

[comment]: <> (  ```)

[comment]: <> (- Verify your local account got created)

[comment]: <> (  ```shell)

[comment]: <> (  sudo -u postgres psql)
  
[comment]: <> (  # you should see prompt)

[comment]: <> (  # postgres=#)
  
[comment]: <> (  # to display users )

[comment]: <> (  \du)
  
[comment]: <> (  # you should see a role name of your linux account with Superuser role attribute)
  
[comment]: <> (  # to exit the session )

[comment]: <> (  \q)

[comment]: <> (  ```)

[comment]: <> (---)

[comment]: <> (Continue to next guide: [3. Run scripts]&#40;3-RUN_NETWORK_SCRIPTS.md&#41;)