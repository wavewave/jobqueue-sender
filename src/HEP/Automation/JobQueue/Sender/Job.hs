{-# LANGUAGE OverloadedStrings #-}

module HEP.Automation.JobQueue.Sender.Job where

import Network.HTTP.Types
import Network.HTTP.Enumerator

import HEP.Automation.JobQueue.JobJson
import HEP.Automation.JobQueue.JobQueue

import Data.Aeson.Encode

import Control.Concurrent (threadDelay)

import HEP.Automation.JobQueue.Sender.Type
import HEP.Automation.MadGraph.Dataset.Set20110702set4

jobqueueSend :: Url -> IO ()
jobqueueSend url = do 
  let jobdetails = map (flip EventGen webdavdir) eventsets
  putStrLn $ "sending " ++ show (length eventsets) ++ " jobs"
  mapM_ (\x -> sendJob url x >> threadDelay 1000000) jobdetails

sendJob :: Url -> JobDetail -> IO () 
sendJob url jobdetail = do 
  withManager $ \manager -> do  -- manager <- newManager 
    requesttemp <- parseUrl (url ++ "/queue")
    let json = encode $ toAeson jobdetail 
    let myrequestbody = RequestBodyLBS json 
    let requestpost = requesttemp { method = methodPost, 
                                    requestHeaders = [ ("Content-Type", "text/plain") ], 
                                    requestBody = myrequestbody } 
    r <- httpLbs requestpost manager 
    putStrLn $ show r 



