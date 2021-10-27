# Use scripts to start network and connect db-sync

- Now, we get to the fun part.  We are ready to create & start a private Cardano network,
which will run three block producer nodes. Then, we connect the db-sync process to it, so that
activity occurring on the network gets stored in a SQL database.   
- As mentioned in the [project readme](./README.md), the scripts to create the private 
  Cardano network are taken from the `cardano-node` project and have been modified as needed.
  - Please find original script files in the IOHK git repository: [cardano-node/scripts](https://github.com/input-output-hk/cardano-node/tree/master/scripts)
---

## Make the network files and start the network

- Adjust the [config.cfg file](./scripts/config.cfg) as desired. The defaults should work for you.
- Open **terminal #1** and run script to make the network files
  ```shell
  # navigate to this projects root folder
  cd <path/to/this/project>
  
  # run script file
  ./scripts/mkfiles.sh
  
  # output
  # verify the script completed successfully and the files were created in the $ROOT
  # location specified in the [config.cfg file](./scripts/config.cfg)
  ```
- In the same **terminal #1**, start up the all three nodes using the script that gets generated by running make-network-files
  ```shell
  # run generated script to start all three nodes
  ./$ROOT/run/all.sh
  
  # output
  # verify the output does not show any errors
  # It's possible you will see some forge errors, but they may go away, once all the nodes have connected to one another   
  ```

## Apply updates to the network to advance the network protocol to latest era and protocol version

At the time of this writing, the current era is `alonzo` and protocol version `6`

- Open **terminal #2** and run the v1 update script
  ```shell
  # navigate to this projects root folder
  cd <path/to/this/project>
  
  # run script file
  ./scripts/update-1.sh
  
  # output
  # verify the script completed successfully 
  ```
- Wait for 1 to 2 epochs to make sure the update to protocol V1 is completed.
  ```shell
  # run query to find out the current epoch
  cardano-cli query tip --testnet-magic 42
  
  # run query to get network protocol info
  cardano-cli query protocol-parameters --testnet-magic 42
  ```
- In **terminal 2**, run the v2 update script  
  ```shell
  # run script file
  ./scripts/update-2.sh
    
  # output
  # verify the script completed successfully 
  ```
- Switch to **terminal 1** and restart the nodes
  ```shell
  # Use Ctrl + c to stop the script process
  
  # run the script again to start up the nodes
  ./run/all.sh
  
  # output
  # verify the output does not show any errors
  # It's possible you will see some forge errors, but they may go away, once all the nodes have connected to one another   
  ```
- Wait for 1 to 2 epochs to make sure the update to protocol V2 is completed.
  ```shell
  # run query to find out the current epoch
  cardano-cli query tip --testnet-magic 42
  
  # run query to get network protocol info
  cardano-cli query protocol-parameters --testnet-magic 42
  ```
- In **terminal 2**, run the v3 update script
  ```shell
  # run script file and pass the current epoch number
  ./scripts/update-2.sh <current_epoch>
    
  # output
  # verify the script completed successfully 
  ```
- Switch to **terminal 1** and restart the nodes
  ```shell
  # Use Ctrl + c to stop the script process
  
  # run the script again to start up the nodes
  ./run/all.sh
  
  # output
  # verify the output does not show any errors
  # It's possible you will see some forge errors, but they may go away, once all the nodes have connected to one another   
  ```
- Wait for 1 to 2 epochs to make sure the update to protocol V3 is completed.
  ```shell
  # run query to find out the current epoch
  cardano-cli query tip --testnet-magic 42
  
  # run query to get network protocol info
  cardano-cli query protocol-parameters --testnet-magic 42
  ```
- Repeat the same process as you did for each of update-4, update-5, and update-6
to advance the protocol updates to Alonzo era and protocol V6.  This is the current era and protocol
at the time of this writing.

## Connect the db-sync process to your private network

- In **terminal 3**, start db sync process
  ```shell
  
  
  
  ```

  
  
  