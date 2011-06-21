{-# LANGUAGE DeriveDataTypeable #-}

module HEP.Automation.JobQueue.Sender.Type where

import System.Console.CmdArgs

data JobClient = List   { queuetyp :: String, config :: String }
               | Assign { jobid :: Int, config :: String} 
               deriving (Show,Data,Typeable)


list :: JobClient 
list = List { queuetyp = "all" &= typ "QUEUETYP" &= argPos 0 
            , config = "test.conf" } 

assign :: JobClient 
assign = Assign { jobid = def &= typ "JOBID" &= argPos 0
                , config = "test.conf" }

mode = modes [list, assign] 