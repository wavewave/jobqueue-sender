{-# LANGUAGE OverloadedStrings #-}

module HEP.Automation.JobQueue.Sender.Command where

import HEP.Automation.JobQueue.Sender.Type
import HEP.Automation.JobQueue.Sender.Job

import HEP.Automation.EventGeneration.Config
-- import HEP.Automation.Pipeline.Config
import HEP.Automation.JobQueue.Config 

commandLineProcess :: JobSender -> IO () 
commandLineProcess (Send conf mname url) = do 
  putStrLn "send called"
  mevgencfg <- getConfig conf
  case mevgencfg of 
    Nothing -> putStrLn "getConfig failed "
    Just evgencfg -> do --  putStrLn "success"
      jobqueueSend url mname
      
  -- print mevgencfg
{-   lc <- readConfigFile conf 
  let url = nc_jobqueueurl . lc_networkConfiguration $ lc 
      datasetdir = datasetDir . lc_clientConfiguration $ lc 
  jobqueueSend url datasetdir mname job -}
commandLineProcess (ManySend conf mname) = do 
  putStrLn "manysend called"
{-   lc <- readConfigFile conf 
  let url = nc_jobqueueurl . lc_networkConfiguration $ lc 
      datasetdir = datasetDir . lc_clientConfiguration $ lc 
  jobqueueManySend url datasetdir mname  -}


