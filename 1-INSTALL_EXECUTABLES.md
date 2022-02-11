# Install Cardano Executables

This guide covers installing `cardano-node`, `cardano-cli` and optionally `cardano-db-sync` into `$HOME/.local/bin`.

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
Continue to guide: [3. Run Network Scripts](./3-RUN_NETWORK_SCRIPTS.md)


[comment]: <> (If you don't plan on using `cardano-db-sync`, you can continue to guide: [3. Run Network Scripts]&#40;./3-RUN_NETWORK_SCRIPTS.md&#41;.)

[comment]: <> (Otherwise, continue following the directions below.)

[comment]: <> (***)

[comment]: <> (**Note**: The remainder of this guide covers how to build all the executables including the `cardano-db-sync` executables)

[comment]: <> (from Haskell sources. **You may skip the rest of this readme, if db-sync is not relevant to you.**)

[comment]: <> (## Optional: Building cardano-db-sync from Haskell sources using cabal and GHC)

[comment]: <> (### 1. Install package dependencies and Haskell tooling)

[comment]: <> (- Install package dependencies of tools)

[comment]: <> (  ```shell)

[comment]: <> (  # update/upgrade your package indexes)

[comment]: <> (  sudo apt-get update)

[comment]: <> (  sudo apt-get upgrade  )

[comment]: <> (  # reboot as necessary)
    
[comment]: <> (  sudo apt-get install automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf -y  )

[comment]: <> (  ```)

[comment]: <> (- Install Cabal and GHC using [GHCUp - Haskell language installer]&#40;https://www.haskell.org/ghcup/&#41;)

[comment]: <> (  ```shell)

[comment]: <> (  # download and run get-ghcup script)

[comment]: <> (  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh)

[comment]: <> (  # During questions, I chose to &#40;A&#41;ppend the path to ghc to .bashrc)

[comment]: <> (  # and did not choose to install Haskell Language Server &#40;HLS&#41; or stack)

[comment]: <> (  # source the bash start script to apply updates to PATH)

[comment]: <> (  cd $HOME)

[comment]: <> (  source .bashrc)
  
[comment]: <> (  # get the latest updates to GHCUp tool)

[comment]: <> (  ghcup upgrade)

[comment]: <> (  # install cabal with GHCUp )

[comment]: <> (  ghcup install cabal 3.4.0.0)

[comment]: <> (  ghcup set cabal 3.4.0.0)

[comment]: <> (  # install GHC with GHCUp)

[comment]: <> (  ghcup install ghc 8.10.4)

[comment]: <> (  ghcup set ghc 8.10.4)
  
[comment]: <> (  # Update cabal and verify the correct versions were installed successfully.)

[comment]: <> (  cabal update)

[comment]: <> (  cabal --version)

[comment]: <> (  ghc --version)

[comment]: <> (  ```)

[comment]: <> (### 2. Install latest release tags of Cardano db-sync executables )

[comment]: <> (**Note**: The author could not find pre-built binaries for cardano-db-sync from IOHK, so the directions below)

[comment]: <> (are to build them from Haskell sources using cabal and GHC.  If you want to explore other options to build)

[comment]: <> (or deploy, e.g. using `nix-build` or `docker`, )

[comment]: <> (please see the [IOHK cardano-db-sync README]&#40;https://github.com/input-output-hk/cardano-db-sync#readme&#41; for more info.)

[comment]: <> (- Clone the IOHK cardano-db-sync repo)

[comment]: <> (  ```shell)

[comment]: <> (  cd $HOME/src)

[comment]: <> (  git clone https://github.com/input-output-hk/cardano-db-sync)

[comment]: <> (  cd cardano-db-sync  )

[comment]: <> (  # fetch the list of tags and check out the latest release tag name  )

[comment]: <> (  git fetch --tags --all)

[comment]: <> (  git checkout $&#40;curl -s https://api.github.com/repos/input-output-hk/cardano-db-sync/releases/latest | jq -r .tag_name&#41;)

[comment]: <> (  ```)

[comment]: <> (- Fetch postgres `libpq-dev` package, update dependencies and build the cardano-db-sync project.  This can take 20 minutes+)
  
[comment]: <> (  **Note**: Building `cardano-db-sync` project from source, depends on finding the postgres `libpq-dev` package on the host OS.)

[comment]: <> (  ```shell)

[comment]: <> (  sudo apt-get install libpq-dev)

[comment]: <> (  cabal update)

[comment]: <> (  cabal build all)

[comment]: <> (  ```)

[comment]: <> (- Copy db-sync executables to local user default path location)

[comment]: <> (  ```shell)

  cp -p $(find dist-newstyle/build -type f -name "cardano-db-sync") $HOME/.local/bin/cardano-db-sync

  cp -p $(find dist-newstyle/build -type f -name "cardano-db-sync-extended") $HOME/.local/bin/cardano-db-sync-extended  

[comment]: <> (  ```)

[comment]: <> (- Verify the versions of the db-sync executables)

[comment]: <> (  ```shell)

[comment]: <> (  cardano-db-sync --version)

[comment]: <> (  cardano-db-sync-extended --version)
  
[comment]: <> (  # when this document was written, the current version for each is 12.0.0 on linux-x86_64)

[comment]: <> (  ```)

[comment]: <> (---)

[comment]: <> (Continue to next guide: [2. Install PostgreSQL instructions]&#40;./2-INSTALL_POSTGRESQL.md&#41;)