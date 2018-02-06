module Data.URI.AbsoluteURI
  ( AbsoluteURI(..)
  , AbsoluteURIOptions
  , AbsoluteURIParseOptions
  , AbsoluteURIPrintOptions
  , parser
  , print
  , _scheme
  , _hierPart
  , _query
  , module Data.URI.HierarchicalPart
  , module Data.URI.Query
  , module Data.URI.Scheme
  ) where

import Prelude

import Data.Array as Array
import Data.Either (Either)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Lens (Lens', lens)
import Data.Maybe (Maybe(..))
import Data.String as String
import Data.URI.Common (URIPartParseError)
import Data.URI.HierarchicalPart (Authority(..), HierarchicalPart(..), HierPath, Host(..), HostsParseOptions, Path(..), PathAbsolute(..), PathRootless(..), Port(..), UserInfo, _IPv4Address, _IPv6Address, _NameAddress, _authority, _hosts, _path, _userInfo)
import Data.URI.HierarchicalPart as HPart
import Data.URI.Query (Query)
import Data.URI.Query as Query
import Data.URI.Scheme (Scheme(..))
import Data.URI.Scheme as Scheme
import Text.Parsing.Parser (Parser)
import Text.Parsing.Parser.Combinators (optionMaybe)
import Text.Parsing.Parser.String (eof)

-- | A generic AbsoluteURI
data AbsoluteURI userInfo hosts path hierPath query = AbsoluteURI Scheme (HierarchicalPart userInfo hosts path hierPath) (Maybe query)

derive instance eqAbsoluteURI ∷ (Eq userInfo, Eq hosts, Eq path, Eq hierPath, Eq query) ⇒ Eq (AbsoluteURI userInfo hosts path hierPath query)
derive instance ordAbsoluteURI ∷ (Ord userInfo, Ord hosts, Ord path, Ord hierPath, Ord query) ⇒ Ord (AbsoluteURI userInfo hosts path hierPath query)
derive instance genericAbsoluteURI ∷ Generic (AbsoluteURI userInfo hosts path hierPath query) _
instance showAbsoluteURI ∷ (Show userInfo, Show hosts, Show path, Show hierPath, Show query) ⇒ Show (AbsoluteURI userInfo hosts path hierPath query) where show = genericShow

type AbsoluteURIOptions userInfo hosts path hierPath query =
  AbsoluteURIParseOptions userInfo hosts path hierPath query
    (AbsoluteURIPrintOptions userInfo hosts path hierPath query ())

type AbsoluteURIParseOptions userInfo hosts path hierPath query r =
  ( parseUserInfo ∷ UserInfo → Either URIPartParseError userInfo
  , parseHosts ∷ Parser String hosts
  , parsePath ∷ Path → Either URIPartParseError path
  , parseHierPath ∷ Either PathAbsolute PathRootless → Either URIPartParseError hierPath
  , parseQuery ∷ Query → Either URIPartParseError query
  | r
  )

type AbsoluteURIPrintOptions userInfo hosts path hierPath query r =
  ( printUserInfo ∷ userInfo → UserInfo
  , printHosts ∷ hosts → String
  , printPath ∷ path → Path
  , printHierPath ∷ hierPath → Either PathAbsolute PathRootless
  , printQuery ∷ query → Query
  | r
  )

parser
  ∷ ∀ userInfo hosts path hierPath query r
  . Record (AbsoluteURIParseOptions userInfo hosts path hierPath query r)
  → Parser String (AbsoluteURI userInfo hosts path hierPath query)
parser opts = AbsoluteURI
  <$> Scheme.parser
  <*> HPart.parser opts
  <*> optionMaybe (Query.parser opts.parseQuery)
  <* eof

print
  ∷ ∀ userInfo hosts path hierPath query r
  . Record (AbsoluteURIPrintOptions userInfo hosts path hierPath query r)
  → AbsoluteURI userInfo hosts path hierPath query
  → String
print opts (AbsoluteURI s h q) =
  String.joinWith "" $ Array.catMaybes
    [ Just (Scheme.print s)
    , Just (HPart.print opts h)
    , Query.print opts.printQuery <$> q
    ]

_scheme
  ∷ ∀ userInfo hosts path hierPath query
  . Lens'
      (AbsoluteURI userInfo hosts path hierPath query)
      Scheme
_scheme =
  lens
    (\(AbsoluteURI s _ _) → s)
    (\(AbsoluteURI _ h q) s → AbsoluteURI s h q)

_hierPart
  ∷ ∀ userInfo hosts path hierPath query
  . Lens'
      (AbsoluteURI userInfo hosts path hierPath query)
      (HierarchicalPart userInfo hosts path hierPath)
_hierPart =
  lens
    (\(AbsoluteURI _ h _) → h)
    (\(AbsoluteURI s _ q) h → AbsoluteURI s h q)

_query
  ∷ ∀ userInfo hosts path hierPath query
  . Lens'
      (AbsoluteURI userInfo hosts path hierPath query)
      (Maybe query)
_query =
  lens
    (\(AbsoluteURI _ _ q) → q)
    (\(AbsoluteURI s h _) q → AbsoluteURI s h q)
