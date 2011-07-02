{-# LANGUAGE OverloadedStrings #-}

module HEP.Automation.JobQueue.Sender.Command where

import HEP.Automation.JobQueue.Sender.Type
import HEP.Automation.JobQueue.Sender.Job

import HEP.Automation.Pipeline.Config

commandLineProcess :: JobSender -> IO () 
commandLineProcess (Send conf) = do 
  putStrLn "send called"
  lc <- readConfigFile conf 
  let url = nc_jobqueueurl . lc_networkConfiguration $ lc 
  jobqueueSend url



