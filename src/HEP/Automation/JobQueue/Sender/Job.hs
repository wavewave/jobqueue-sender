{-# LANGUAGE OverloadedStrings #-}

module HEP.Automation.JobQueue.Sender.Job where

import Network.HTTP.Types
import Network.HTTP.Enumerator

import HEP.Automation.JobQueue.JobJson
import HEP.Automation.JobQueue.JobQueue

import Data.Aeson.Encode

import Control.Concurrent (threadDelay)

import HEP.Automation.MadGraph.Dataset.Set20110630set1

jobqueueSend :: IO ()
jobqueueSend = do 
  let jobdetails = map (flip EventGen webdavdir) eventsets
  putStrLn $ "sending " ++ show (length eventsets) ++ " jobs"
  mapM_ (\x -> sendJob x >> threadDelay 1000000) jobdetails

sendJob :: JobDetail -> IO () 
sendJob jobdetail = do 
  withManager $ \manager -> do  -- manager <- newManager 
    requesttemp <- parseUrl "http://127.0.0.1:3600/queue"
    let json = encode $ toAeson jobdetail 
    let myrequestbody = RequestBodyLBS json 
    let requestpost = requesttemp { method = methodPost, 
                                    requestHeaders = [ ("Content-Type", "text/plain") ], 
                                    requestBody = myrequestbody } 
    r <- httpLbs requestpost manager 
    putStrLn $ show r 



