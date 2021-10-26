# Install Cardano Executables 

---

### Summary
This guide covers installing `cardano-node`, `cardano-cli`, `cardano-db-sync`, and `cardano-db-sync-extended` into `~/.local/bin`

If necessary, edit your `~/.bashrc` to modify the PATH variable so that the executables can be found on your system path
  ```shell
  export PATH="~/.local/bin:$PATH"  
  ```

#### Assumptions
- This guide assumes you are running a recent version of linux
 
## Install latest Cardano node and Cardano CLI executables

Please see the following IOHK instructions to install from haskell source code.
- [Install cardano-node and cardano-cli from source](https://iohk.zendesk.com/hc/en-us/articles/900001951646-Building-a-node-from-source)
- After completing this guide, `cardano-node` and `cardano-cli` executables will be installed in `~/.local/bin`
- Verify the versions
  ```shell
  cardano-node --version
  cardano-cli --version
  
  # when this document was written, the current version for each is 1.30.1 on linux-x86_64
  ```

## Install latest Cardano db-sync executables 

These instructions will compile and install `cardano-db-sync` and `cardano-db-sync-extended` from haskell source code

- Verify you have Haskell tools installed including cabal and ghc, and they are set to appropriate version. If necessary,
  please visit the link in the first section to install `cardano-node` and `cardano-cli`,
  which includes haskell set-up
  ```shell
  # should be version 8.10.4
  ghc --version
  # should be version 3.4.0.0
  cabal --version  
  ```
- Create a working directory, e.g. `~/src` 
  ```shell
  mkdir -p ~/src
  cd ~/src    
  ```
- Install libsodium shared library and package config if necessary
  ```shell
  # Note: if you installed the cardano-node/cardano-cli from source, you will have already done this
  # so you can skip this step
  
  git clone https://github.com/input-output-hk/libsodium 
  cd libsodium
  # we need to check out a particular SHA commit of the IOHK libsodium project to support Cardano features     
  git checkout 66f017f1
  ./autogen.sh
  ./configure
  make
  # Run make install which will install libsodium to /usr/local/lib and its package config to /usr/local/lib/pkgconfig
  sudo make install  
  ```
- Set the predefined Linux environment variables defining the path to linked libraries and package configs.
  When building the dependencies needed by `cardano-db-sync` executables, it will link in the libsodium- library and its package config.
  If you like, you may append these lines to your `.bashrc` file to set these variables automatically,
  when you open a bash terminal.
  ```shell
  export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" 
  export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
  ```
- Clone the IOHK cardano-db-sync repo
  ```shell
  cd ~/src
  git clone https://github.com/input-output-hk/cardano-db-sync
  cd cardano-db-sync  
  ```
- Fetch the list of tags and check out the latest release tag name
  ```shell
  git fetch --tags --all
  git checkout $(curl -s https://api.github.com/repos/input-output-hk/cardano-db-sync/releases/latest | jq -r .tag_name)
  ```
- Update dependencies and compile the cardano-db-sync project
  ```shell
  cabal update
  cabal build all
  ```
- Copy db-sync executables to local user default path location
  ```shell
  cp -p $(find ~/cardano-src/cardano-db-sync/dist-newstyle/build -type f -name "cardano-db-sync") ~/.local/bin/cardano-db-sync
  cp -p $(find ~/cardano-src/cardano-db-sync/dist-newstyle/build -type f -name "cardano-db-sync-extended") ~/.local/bin/cardano-db-sync-extended  
  ```
- Verify the versions of the db-sync executables
  ```shell
  cardano-db-sync --version
  cardano-db-sync-extended --version
  
  # when this document was written, the current version for each is 11.0.4 on linux-x86_64
  ```