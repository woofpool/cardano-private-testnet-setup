# Attach db-sync process to the private network
## Note: Please skip running this guide until an issue is fixed

A recent change to the `cardano-db-sync` project source code leads to a validation failure when trying to
attach the db-sync process to the private testnet. The author has logged an issue to find out how to resolve:
[logged cardano-db-sync issue](https://github.com/input-output-hk/cardano-db-sync/issues/1046).

---

[comment]: <> (**Note**: If you have not installed `cardano-db-sync`, then you should skip this guide and continue to next guide: [5. Run transaction]&#40;5-RUN_TRANSACTION.md&#41;)

[comment]: <> (This guide covers attaching the `cardano-db-sync` process to the private testnet.  Doing so causes the blockchain data to)

[comment]: <> (be written to a highly normalized database schema in PostgresSQL database.  Then, it's possible to run SQL queries against the data)

[comment]: <> (for easy retrieval of information.)

[comment]: <> (#### Assumptions)

[comment]: <> (- This guide assumes you are running a recent version of linux.)

[comment]: <> (  Specifically, these directions apply to Ubuntu &#40;Debian&#41;. If you are using a different linux variant, please adjust as needed)

[comment]: <> (- Before using this guide, you should have completed the [Install executables guide]&#40;./1-INSTALL_EXECUTABLES.md&#41; and)

[comment]: <> (  [Install PostgreSQL guide]&#40;2-INSTALL_POSTGRESQL.md&#41;.)

[comment]: <> (## 1. Run the script to start up the cardano-db-sync process)

[comment]: <> (- Make sure the nodes are running)

[comment]: <> (- If necessary, please modify the `SCHEMA_DIR` environment variable below based on the location of your cloned copy of cardano-db-sync project)

[comment]: <> (- In **terminal 3**, start the db sync process.  This will install the database schema and sync blockchain data to the Postgres database.)

[comment]: <> (  ```shell)

[comment]: <> (  # navigate to project root folder)

[comment]: <> (  cd $HOME/src/cardano-private-testnet-setup)
  
[comment]: <> (  # set environment variable needed by `./scripts/db-sync-start.sh`)

[comment]: <> (  export SCHEMA_DIR=$HOME/src/cardano-db-sync/schema)
  
[comment]: <> (  # run script file)

[comment]: <> (  ./scripts/db-sync-start.sh)
  
[comment]: <> (  # output)

[comment]: <> (  # verify the output does not show any errors)

[comment]: <> (  # in a steady state, you should see logs of SQL insert statements into slot_leader and block tables   )

[comment]: <> (  ```)

[comment]: <> (---)

[comment]: <> (Continue to next guide: [5. Run transaction]&#40;5-RUN_TRANSACTION.md&#41;)