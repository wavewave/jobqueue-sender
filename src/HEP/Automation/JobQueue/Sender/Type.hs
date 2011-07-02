{-# LANGUAGE DeriveDataTypeable #-}

module HEP.Automation.JobQueue.Sender.Type where

import System.Console.CmdArgs

type Url = String

data JobSender = Send { config :: FilePath }
               deriving (Show,Data,Typeable)

send :: JobSender 
send = Send { config = "test.conf" }

mode = modes [send]

