{-# LANGUAGE OverloadedStrings #-}

module HEP.Automation.JobQueue.Sender.Command where

import HEP.Automation.JobQueue.Sender.Type
import HEP.Automation.JobQueue.Sender.Job


commandLineProcess :: JobSender -> IO () 
commandLineProcess Send = do 
  putStrLn "send called"
  jobqueueSend



