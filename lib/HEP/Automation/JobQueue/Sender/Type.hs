{-# LANGUAGE DeriveDataTypeable #-}

module HEP.Automation.JobQueue.Sender.Type where

import System.Console.CmdArgs

type Url = String

data JobSender = Send { config     :: FilePath 
                      , moduleName :: String
                      -- , whatjob    :: String
                      , url :: String
                      }
               | ManySend { config :: FilePath
                          , moduleName :: String } 
               deriving (Show,Data,Typeable)

-- mode = modes [CmdA, CmdB]

send :: JobSender 
send = Send { config = "sender.conf" 
            , moduleName = def &= typ "MODULENAME" &= argPos 0
            , url = def &= typ "URL" &= argPos 1 
            -- , whatjob = def &= typ "JOBTYPE" &= argPos 1
            }

manysend :: JobSender 
manysend = ManySend { config = "sender.conf"
                    , moduleName = def &= typ "MODULENAME" &= argPos 0 
                    }

