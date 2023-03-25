{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE  FlexibleInstances #-}
{-# LANGUAGE TypeOperators #-}

module Main (main) where

import Servant
import Data.Text.Lazy
import Network.Wai.Handler.Warp
import Data.Aeson
import Data.List 
import Data.Text.Lazy.Encoding (encodeUtf8)
import Network.HTTP.Media ((//),(/:))
import Data.Monoid ((<>)) 

data HTML

-- instance derived to specify the content type the client expects
instance Accept HTML where
    contentType _ = "text" // "html" /: ("charset","utf-8")


-- render a value of polymorphic type a into HTML 
instance Show a => MimeRender HTML a where
    mimeRender _ = encodeUtf8 . pack . show

type ServerApi = "user" :> Get '[HTML] Text
                :<|> "user" :> "demo" :> Get '[HTML] Text
                :<|> "user" :> QueryParam "id-user" Int :> Get '[JSON] User
                :<|> "user" :> Capture "name" String :> Get '[HTML] Text

data User = User
    { name :: Text
    , idU :: Int
    , address :: Text
    , age :: Text
    } deriving (Show)


--encoding of JSON object from User haskell data type
instance ToJSON User where
    toJSON (User name idU address age) = object ["name" .= name, "id" .= idU, "address" .= address, "age" .= age]

-- decoding of JSON object to haskell data type which the handler expects
instance FromJSON User where
    parseJSON = withObject "User" $ \o ->
        User <$> o .: "name" <*> o .: "id" <*> o .: "address" <*> o .: "age"

-- implementation of the api endpoints by server
serverRoutes :: Server ServerApi
serverRoutes = return "HELLO FROM THE OTHER SIDE!"
            :<|> return "WELCOME TO THE DEMO PAGE"
            :<|> getUserById
            :<|> (\name -> return("The name is" <> pack name))


-- Queryparam is not mandatory to access the resource hence we need to use maybe i.e. the handler function expects a Maybe type serves it by returning the User matching the id wrapped in Handler monad

getUserById :: Maybe Int -> Handler User
getUserById maybeId = case maybeId of
    Nothing -> throwError $ err400 { errBody = "Missing 'id-user' query parameter" }
    Just idval -> case Prelude.filter (\user -> idU user == idval) users of
        [] -> throwError $ err404 { errBody = "User with given id not found" }
        (user:_) -> return user


-- Simple list of User acting as a basic db
users :: [User]
users =
    [ User { name = "Vikram", idU = 1, address = "Yojana Vihar Delhi", age = "21" }
    , User { name = "Dheeraj", idU = 2, address = "Yojana Vihar Delhi", age = "50" }
    , User { name = "Prerak", idU = 3, address = "Greater Kailash Delhi", age = "21" }
    ]

-- proxy function Used to lift the ServerApi type from type world to value world

serverProxy :: Proxy ServerApi
serverProxy = Proxy

-- wai application is defined
router :: Application
router = serve serverProxy serverRoutes

main :: IO ()
main = run 8080 router
