# cardano-private-testnet-setup

---

This project provides instructions and shell scripts to bootstrap a private Cardano testnet and connect a `cardano-db-sync` process to it.
If you don't want to bother with setting up `cardano-db-sync`, you can easily skip over the sections of this project that are not relevant.

The scripts used by this project to create the private Cardano testnet are taken from the IOHK `cardano-node` project and have been modified as needed.
You may find the original script files in the IOHK git repository: [cardano-node scripts](https://github.com/input-output-hk/cardano-node/tree/master/scripts/byron-to-alonzo).
In particular, running `cardano-db-sync` to sync to the private testnet required a few changes to the original scripts provided by IOHK.

Hopefully, this documentation provides a lot of value for others. I welcome your feedback both good and bad!

### Why is this useful?
- A private Cardano testnet provides a controlled environment to execute transactions
- With `cardano-db-sync` connected to your private testnet, you can use SQL queries to view blockchain activity data.
- You can use this controlled environment for local Cardano development.
- Lastly, it is a great learning experience to set up your own private testnet and learn about the data stored on the blockchain.

### Key Details
- The private testnet consists of three block-producing node processes.
- The `cardano-db-sync` process syncs blockchain data to a highly normalized database schema. This enables blockchain data to be queried with SQL. 

### Medium article
For an additional overview of this project, please check out this [medium article](https://medium.com/@extramileit/how-to-set-up-a-private-cardano-testnet-5e5afaa22d0b)

## Usage Instructions

1. **Install Cardano executables**

    * Install the following executables: `cardano-node`, `cardano-cli`, and optionally `cardano-db-sync`
    * Please refer to the [Install executables guide](1-INSTALL_EXECUTABLES.md) for instructions.
    
2. **Optional: Install PostgreSQL packages and create Postgres user** 
    
    * The `cardano-db-sync` process uses a connection to a PostgreSQL database.
    * Please refer to the [Install posgreSQL](2-INSTALL_POSTGRESQL.md) for instructions to set up.

3. **Run scripts to set up & run private Cardano network and optionally connect DB Sync process**

    * Run scripts to bootstrap the Cardano private network and attach the `cardano-db-sync` process to it to sync blockchain data to SQL database.
    * Please refer to the [Run network scripts guide](3-RUN_NETWORK_SCRIPTS.md) for instructions. 

4. **Optional: Attach DB Sync process the network**

    * Attach the `cardano-db-sync` process to the network, which syncs blockchain data to a `PostgreSQL` database.
    * Please refer to the [Attach db-sync guide](4-ATTACH_DB_SYNC.md) for instructions.

5. **Run simple transaction and optionally query the db-sync database to see results**

    * Set up a new walllet for user2 and make a payment from user1 to user2. Query the database to confirm the transaction.
    * Please refer to the [Run transaction guide](5-RUN_TRANSACTION.md) for instructions.

6. **Run Plutus script transactions**

    * Build the project code for a simple vesting script, which sets User2 as the beneficiary with a vesting deadline
    * Set up transaction to give ADA from User1 to the script address and a transaction to grab ADA from the script by User2    
    * Please refer to the [Run Plutus Script transactions guide](6-RUN_PLUTUS_SCRIPT_TXS.md) for instructions.

## Contributors

This project is provided free of charge to the Cardano community. The author of this project is a fan of Cardano, as well as a Cardano stake pool operator.
I am not affiliated with IOHK in any official capacity.  

If you want to support the continued development of this project, you can delegate or recommend my staking pool:

- [**WOOF Cardano Staking Pool**](https://woofpool.github.io/)

## Contributing

If you'd like to help maintain this project, please feel free to submit a pull request. Please ensure that any script changes have been tested and verified.

## License

This project is licensed under the terms of the [MIT License](LICENSE).