{-# LANGUAGE DeriveDataTypeable #-}

module HEP.Automation.JobQueue.Sender.Type where

import System.Console.CmdArgs

data JobSender = Send  
               deriving (Show,Data,Typeable)

send :: JobSender 
send = Send

mode = modes [send]

