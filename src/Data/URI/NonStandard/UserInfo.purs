module Data.URI.NonStandard.UserInfo where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Newtype (class Newtype)
import Data.URI.Common (anyString)
import Global (encodeURI)
import Text.Parsing.StringParser (Parser)

-- | The user info part of an `Authority`. For example: `user`, `foo:bar`.
newtype UserInfo = UserInfo String

derive newtype instance eqUserInfo ∷ Eq UserInfo
derive newtype instance ordUserInfo ∷ Ord UserInfo
derive instance genericUserInfo ∷ Generic UserInfo _
derive instance newtypeUserInfo ∷ Newtype UserInfo _
instance showUserInfo ∷ Show UserInfo where show = genericShow

parser ∷ Parser UserInfo
parser = UserInfo <$> anyString

print ∷ UserInfo → String
print (UserInfo u) = encodeURI u