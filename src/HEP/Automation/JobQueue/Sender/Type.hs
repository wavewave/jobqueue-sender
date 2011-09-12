{-# LANGUAGE DeriveDataTypeable #-}

module HEP.Automation.JobQueue.Sender.Type where

import System.Console.CmdArgs

type Url = String

data JobSender = Send { config     :: FilePath 
                      , moduleName :: String
                      , whatjob    :: String
                      }
               | ManySend { config :: FilePath
                          , moduleName :: String }
               deriving (Show,Data,Typeable)

send :: JobSender 
send = Send { config = "test.conf" 
            , moduleName = "" &= typ "MODULENAME" &= argPos 0
            , whatjob = "" &= typ "JOBTYPE" &= argPos 1
            }

manysend :: JobSender 
manysend = ManySend { config = "test.conf"
                    , moduleName = "" &= typ "MODULENAME" &= argPos 0 } 

mode :: JobSender
mode = modes [send, manysend]

