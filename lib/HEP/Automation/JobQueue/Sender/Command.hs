{-# LANGUAGE OverloadedStrings #-}

module HEP.Automation.JobQueue.Sender.Command where

import HEP.Automation.JobQueue.Sender.Type
import HEP.Automation.JobQueue.Sender.Job

import HEP.Automation.EventGeneration.Config
-- import HEP.Automation.Pipeline.Config
import HEP.Automation.JobQueue.Config 

commandLineProcess :: JobSender -> IO () 
commandLineProcess (Send conf mname url) = do 
  mevgencfg <- getConfig conf
  case mevgencfg of 
    Nothing -> putStrLn "getConfig failed "
    Just evgencfg -> jobqueueSend url mname
commandLineProcess (ManySend conf mname) = do 
  putStrLn "not support many send at this time"


{-   lc <- readConfigFile conf 
  let url = nc_jobqueueurl . lc_networkConfiguration $ lc 
      datasetdir = datasetDir . lc_clientConfiguration $ lc 
  jobqueueManySend url datasetdir mname  -}


