{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE TypeFamilies        #-}
{-# LANGUAGE TypeOperators       #-}

module NftExample.Policy where

import           Control.Monad          hiding (fmap)
import           Data.Aeson             (ToJSON, FromJSON)
import           Data.Text              (Text)
import           Data.ByteString        (ByteString)
import           Data.Void              (Void)
import           GHC.Generics           (Generic)
import           Plutus.Contract        as Contract
import qualified PlutusTx
import           PlutusTx.Prelude       hiding (Semigroup(..), unless)
import           PlutusTx.Builtins.Internal
import           Ledger                 hiding (mint, singleton)
import           Ledger.Constraints     as Constraints
import qualified Ledger.Typed.Scripts   as Scripts
import           Ledger.Value           as Value
import           Prelude                (IO, Show (..), String)
import           Text.Printf            (printf)

data CustomRedeemer = CustomRedeemer
    { txOut :: TxOutRef
    , nftName :: String
    } deriving Show

PlutusTx.unstableMakeIsData ''CustomRedeemer

{-# INLINABLE mkNftPolicy #-}
mkNftPolicy :: CustomRedeemer -> ScriptContext -> Bool
mkNftPolicy dat ctx = traceIfFalse "UTxO not consumed"   hasUTxO           &&
                      traceIfFalse "wrong amount minted" checkMintedAmount
  where
    tranOutRefId :: ByteString
    tranOutRefId = PlutusTx.fromData BuiltinByteString (nftDatum !! 0)

    tranOutRefIdx :: Integer
    tranOutRefIdx = nftDatum !! 1

    nftName :: ByteString
    nftName = nftDatum !! 2

    txId :: TxId
    txId = TxId (BuiltinByteString tranOutRefId)

    oref :: TxOutRef
    oref = TxOutRef txId (tranOutRefIdx)

    info :: TxInfo
    info = scriptContextTxInfo ctx

    hasUTxO :: Bool
    hasUTxO = any (\i -> txInInfoOutRef i == oref) $ txInfoInputs info

    checkMintedAmount :: Bool
        checkMintedAmount = case flattenValue (txInfoForge info) of
            [(cs, nftName', amt)] -> cs  == ownCurrencySymbol ctx && nftName' == nftName && amt == 1
            _                -> False

-- replace this code with equivalent instance of PolicyType
data Typed
instance Scripts.PolicyType Typed where
    type instance RedeemerType Typed = CustomRedeemer

-- replace this code with equivalent function to build TypedPolicyScript
typedPolicy :: Scripts.TypedPolicy? Typed
typedPolicy = Scripts.mkTypedPolicy @Typed
    $$(PlutusTx.compile [|| mkNftPolicy ||])
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.wrapPolicyScript @CustomRedeemer

nftPolicy :: Scripts.MintingPolicy
nftPolicy = mkMintingPolicyScript
    $$(PlutusTx.compile [|| Scripts.wrapMintingPolicy mkNftPolicy ||])

nftPlutusScript :: Script
nftPlutusScript = unMintingPolicyScript nftPolicy

nftValidator :: Validator
nftValidator = Validator nftPlutusScript
