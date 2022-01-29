# Install Cardano Executables

This guide covers installing `cardano-node`, `cardano-cli`, and `cardano-db-sync` into `$HOME/.local/bin`.
If you don't plan on using `cardano-db-sync`, you can simply follow the instuctions on downloading executables
and continue to guide: [3. Run Network Scripts](./3-RUN_NETWORK_SCRIPTS.md)

#### Assumptions
- This guide assumes you are running a Debian/Ubuntu linux OS.
  If you are using a different flavor of Linux, you will need to use the correct package manager for your platform
  
## Download/install the latest release tags of Cardano node and Cardano CLI executables

- Go to the [README page](https://github.com/input-output-hk/cardano-node#linux-executable) of the `cardano-node` project
  and you will see links to follow, where you can download the latest release binaries.
- Copy the binaries to local user path
  ```shell
  # extract cardano-cli and cardano-node from the archive
  # copy them to local path location
  cp cardano-cli $HOME/.local/bin/
  cp cardano-node $HOME/.local/bin/
  ```

**As written above, the remainder of this readme covers building all the executables including the `cardano-db-sync` executables
from Haskell sources. You may skip the rest of this readme, if db-sync is not relevant to you.**

## Building executables from Haskell sources using cabal and GHC

### 1. Install package dependencies and Haskell tooling

- Install package dependencies of tools
  ```shell
  # update/upgrade your package indexes
  sudo apt-get update
  sudo apt-get upgrade  
  # reboot as necessary
    
  sudo apt-get install automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf -y  
  ```

- Install Cabal and GHC using [GHCUp - Haskell language installer](https://www.haskell.org/ghcup/)
  ```shell
  # download and run get-ghcup script
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
  # During questions, I chose to (A)ppend the path to ghc to .bashrc
  # and did not choose to install Haskell Language Server (HLS) or stack

  # source the bash start script to apply updates to PATH
  cd $HOME
  source .bashrc
  
  # get the latest updates to GHCUp tool
  ghcup upgrade

  # install cabal with GHCUp 
  ghcup install cabal 3.4.0.0
  ghcup set cabal 3.4.0.0

  # install GHC with GHCUp
  ghcup install ghc 8.10.4
  ghcup set ghc 8.10.4
  
  # Update cabal and verify the correct versions were installed successfully.
  cabal update
  cabal --version
  ghc --version
  ```

### 2. Install Libsodium library dependency from IOHK github

[Libsodium](https://doc.libsodium.org/) contains cryptographic tools for encryption, decryption, signatures,
password hashing, and more.

IOHK maintains a fork of the libsodium library and we need to use a particular SHA commit of this fork
to support the latest Cardano node software.

- Create a working directory, e.g. `$HOME/src`
  ```shell
  mkdir -p $HOME/src
  cd $HOME/src    
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
  When building the Cardano executables, it will link in the libsodium- library and its package config.
  If you like, you may append these lines to your `.bashrc` file to set these variables automatically,
  when you open a bash terminal.
  ```shell
  export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" 
  export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
  
  # source the bash start script to apply updates to environment variables
  cd $HOME
  source .bashrc
  ```

### 3. Build the cardano-node and cardano-cli executables    
- Clone the IOHK cardano-node repo
  ```shell
  cd $HOME/src 
  git clone https://github.com/input-output-hk/cardano-node.git
  cd cardano-node
  
  # fetch the list of tags and check out the latest release tag name
  git fetch --all --recurse-submodules --tags
  git checkout $(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .tag_name)
  
  # configure the build options
  cabal configure --with-compiler=ghc-8.10.4
  
  # update project dependencies and build - this can take 20 minutes+
  cabal update
  cabal build all
  ```
- Copy cardano-cli and cardano-node files to local user default path location
  ```shell
  cp $(find dist-newstyle/build -type f -name "cardano-cli") $HOME/.local/bin/cardano-cli
  cp $(find dist-newstyle/build -type f -name "cardano-node") $HOME/.local/bin/cardano-node
  ```
- Verify the versions
  ```shell
  cardano-node version
  cardano-cli version
  
  # when this document was written, the current version for each is 1.30.1 on linux-x86_64

  ```
### 4. Install latest release tags of Cardano db-sync executables 
**Note**: The author could not find pre-built binaries for cardano-db-sync from IOHK, so the directions below
are to build them from Haskell sources using cabal and GHC.  If you want to explore other options to build
or deploy, e.g. using `nix-build` or `docker`, 
please see the [IOHK cardano-db-sync README](https://github.com/input-output-hk/cardano-db-sync#readme) for more info.

- Clone the IOHK cardano-db-sync repo
  ```shell
  cd $HOME/src
  git clone https://github.com/input-output-hk/cardano-db-sync
  cd cardano-db-sync  

  # fetch the list of tags and check out the latest release tag name  
  git fetch --tags --all
  git checkout $(curl -s https://api.github.com/repos/input-output-hk/cardano-db-sync/releases/latest | jq -r .tag_name)
  ```
- Fetch postgres `libpq-dev` package, update dependencies and build the cardano-db-sync project.  This can take 20 minutes+
  
  **Note**: Building `cardano-db-sync` project from source, depends on finding the postgres `libpq-dev` package on the host OS.
  ```shell
  sudo apt-get install libpq-dev
  cabal update
  cabal build all
  ```
- Copy db-sync executables to local user default path location
  ```shell
  cp -p $(find dist-newstyle/build -type f -name "cardano-db-sync") $HOME/.local/bin/cardano-db-sync
  cp -p $(find dist-newstyle/build -type f -name "cardano-db-sync-extended") $HOME/.local/bin/cardano-db-sync-extended  
  ```
- Verify the versions of the db-sync executables
  ```shell
  cardano-db-sync --version
  cardano-db-sync-extended --version
  
  # when this document was written, the current version for each is 11.0.4 on linux-x86_64
  ```

---

Continue to next guide: [2. Install PostgreSQL instructions](./2-INSTALL_POSTGRESQL.md)