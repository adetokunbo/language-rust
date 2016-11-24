{-# LANGUAGE DuplicateRecordFields #-}

module Language.Rust.Syntax.Token where

import Language.Rust.Syntax.Ident (Ident(..), Name)
import Language.Rust.Data.Position
import Language.Rust.Syntax.AST

------------------
-- Tokenization.
-- https://github.com/serde-rs/syntex/blob/master/syntex_syntax/src/parse/token.rs
------------------

-- | A delimiter token
-- https://docs.serde.rs/syntex_syntax/parse/token/enum.DelimToken.html
data DelimToken
  = Paren   -- ^ A round parenthesis: ( or )
  | Bracket -- ^ A square bracket: [ or ]
  | Brace   -- ^ A curly brace: { or }
  | NoDelim -- ^ An empty delimiter
  deriving (Eq, Enum, Bounded, Show)

-- https://docs.serde.rs/syntex_syntax/parse/token/enum.Lit.html
data LitTok
  = ByteTok Name
  | CharTok Name
  | IntegerTok Name
  | FloatTok Name
  | StrTok Name
  | StrRawTok Name Int     -- ^ raw str delimited by n hash symbols
  | ByteStrTok Name
  | ByteStrRawTok Name Int -- ^ raw byte str delimited by n hash symbols
  deriving (Eq, Show)

-- Represents a token bundled with preceding space tokens (if any)
data TokenSpace s = TokenSpace (s Token) [s Token]

-- Based loosely on <https://docs.serde.rs/syntex_syntax/parse/token/enum.Token.html>
-- Inlined https://docs.serde.rs/syntex_syntax/parse/token/enum.BinOpToken.html
data Token
  -- Single character expression-operator symbols.
  = Equal | Less | Not | Greater | Ampersand | Pipe | Exclamation | Tilde
  | Plus | Minus | Star | Slash | Percent | Caret 
  -- Structural symbols
  | At | Dot | DotDot | DotDotDot | Comma | Semicolon | Colon | ModSep | RArrow
  | LArrow | FatArrow | Pound | Dollar | Question
  -- Delimiters, eg. '{', ']', '('
  | OpenDelim DelimToken | CloseDelim DelimToken
  -- Literals
  | LiteralTok LitTok (Maybe Name)
  -- Name components
  | IdentTok Ident
  | Underscore
  | LifetimeTok Ident
  | Space Space Name        -- ^ Whitespace
  | Doc String DocType      -- ^ Doc comment, contents, whether it is outer or not
  | Shebang
  | Eof
  
  -- NOT NEEDED IN TOKENIZATION!!
  | Interpolated (Nonterminal Span)               -- ^ Can be expanded into several tokens.
  -- In left-hand-sides of MBE macros:
  | MatchNt Ident Ident IdentStyle IdentStyle     -- ^ Parse a nonterminal (name to bind, name of NT)
  -- In right-hand-sides of MBE macros:
  | SubstNt Ident IdentStyle                      -- ^ A syntactic variable that will be filled in by macro expansion.
  | SpecialVarNt                                  -- ^ A macro variable with special meaning.

instance Show Token where
  show _ = error "Token.hs: unimplemented - this instance might belong in Pretty.hs"

data DocType = OuterDoc | InnerDoc deriving (Eq, Show, Enum, Bounded)
data Space = Whitespace | Comment deriving (Eq, Show, Enum, Bounded)
data IdentStyle = ModName | Plain deriving (Eq, Show, Enum, Bounded)

canBeginExpr :: Token -> Bool
canBeginExpr OpenDelim{}   = True
canBeginExpr IdentTok{}    = True
canBeginExpr Underscore    = True
canBeginExpr Tilde         = True
canBeginExpr LiteralTok{}  = True
canBeginExpr Exclamation   = True
canBeginExpr Minus         = True
canBeginExpr Star          = True
canBeginExpr Ampersand     = True
canBeginExpr Pipe          = True -- in lambda syntax
canBeginExpr DotDot        = True
canBeginExpr DotDotDot     = True -- range notation
canBeginExpr ModSep        = True
canBeginExpr Pound         = True -- for expression attributes
canBeginExpr (Interpolated NtExpr{})  = True
canBeginExpr (Interpolated NtIdent{}) = True
canBeginExpr (Interpolated NtBlock{}) = True
canBeginExpr (Interpolated NtPath{})  = True
canBeginExpr _ = False

