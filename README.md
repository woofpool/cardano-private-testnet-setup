# cardano-dbsync-private-network

This project provides instructions and BASH shell scripts to bootstrap a private Cardano network and connect `cardano-dbsync` process to it. 
- The private network consists of three block-producing nodes.
- The `cardano-dbsync` process syncs blockchain data to a highly normalized database schema. This enables blockchain data to be queried with SQL. 
- The scripts used by this project to create the private Cardano network are taken from the `cardano-node` project and have been modified as needed.
    - Please find original script files in the IOHK git repository: [cardano-node/scripts](https://github.com/input-output-hk/cardano-node/tree/master/scripts) 

## Usage Instructions
1. **Install required executables**

    * Before running shell scripts to bootstrap the network, some required binary executables must be installed.
    * Please refer to the [Install Required guide](INSTALL_REQUIRED.md) for instructions.

2. **Set up Postgres database connection and schema** 

    * The `cardano-db-sync` process uses a connection to a Postgres database installed with specific schema designed to work with `cardano-dbsync` process.
    * Please refer to the [DB Setup guide](DB_SETUP.md) for instructions.

3. **Run scripts to setup & run private Cardano network and connect DB Sync process**

    * Run scripts to bootstrap the Cardano private network and attach the `cardano-dbsync` process to it to sync blockchain data to SQL database.
    * Please refer to the [Use Scripts guide](USE_SCRIPTS.md) for instructions. 

## Contributors

This project is provided free of charge to the Cardano community. If you want to support its continued development, you can delegate or recommend the Cardano staking pools of our contributors:

- [**WOOF Cardano Staking Pool**](https://woofpool.github.io/)

## Contributing

If you'd like to help maintain this project, please feel free to submit a pull request. Please ensure that any script changes have been tested and verified.

## License

This project is licensed under the terms of the [MIT License](LICENSE).