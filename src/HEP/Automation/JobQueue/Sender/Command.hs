{-# LANGUAGE OverloadedStrings #-}

module HEP.Automation.JobQueue.Sender.Command where

import HEP.Automation.JobQueue.Sender.Type

commandLineProcess :: JobSender -> IO () 
commandLineProcess Send = do 
  putStrLn "send called"
--  jobqueueAssign cc jid 




