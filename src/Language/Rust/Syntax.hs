{-|
Module      : Language.Rust.Syntax
Description : Syntax data defintions
Copyright   : (c) Alec Theriault, 2017
License     : BSD-style
Maintainer  : alec.theriault@gmail.com
Stability   : experimental
Portability : GHC
-}

module Language.Rust.Syntax (
  -- * Abstract syntax trees
  module Language.Rust.Syntax.AST,
  -- * Tokens
  module Language.Rust.Syntax.Token,
) where

import Language.Rust.Syntax.AST
import Language.Rust.Syntax.Token 

-- Using import/export shortcut screws up Haddock
{-# ANN module "HLint: ignore Use import/export shortcut" #-}

