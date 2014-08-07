{-# LANGUAGE OverloadedStrings #-}

-----------------------------------------------------------------------------
-- |
-- Module      : HEP.Automation.JobQueue.Sender.Job
-- Copyright   : (c) 2011, 2012, 2014 Ian-Woo Kim
--
-- License     : BSD3
-- Maintainer  : Ian-Woo Kim <ianwookim@gmail.com>
-- Stability   : experimental
-- Portability : GHC
--
-- 
-- 
-----------------------------------------------------------------------------

module HEP.Automation.JobQueue.Sender.Job where

-- other 
import Control.Concurrent (threadDelay)
import Control.Monad.Trans 
import Data.Aeson.Types
import Data.Aeson.Encode
import Network.HTTP.Types
import Network.HTTP.Conduit
import System.Directory
-- my platform
import HEP.Automation.EventGeneration.Type
import HEP.Automation.JobQueue.JobJson
import HEP.Automation.JobQueue.JobQueue
import HEP.Automation.JobQueue.JobType
import HEP.Storage.WebDAV
import HEP.Util.GHC.Plugins
-- this package
import HEP.Automation.JobQueue.Sender.Type
-- extra
import Unsafe.Coerce


jobqueueSend :: Url -> String -> IO ()
jobqueueSend url mname = do 
  datasetdir <- getCurrentDirectory
  r <- pluginCompile False datasetdir mname "(eventsets,webdavdir)" 
  case r of
    Left err -> putStrLn err
    Right value -> do
      putStrLn "success interpreting !"
      let (eventsets,webdavdir) = unsafeCoerce value :: ([EventSet],WebDAVRemoteDir)

      putStrLn $ show (eventsets,webdavdir) 
      let jobdetails = map (flip EventGen webdavdir) eventsets
      putStrLn $ "sending " ++ show (length eventsets) ++ " jobs"
      mapM_ (\x -> sendJob url x NonUrgent >> threadDelay 50000) jobdetails 


sendJob :: Url -> JobDetail -> JobPriority -> IO () 
sendJob url jobdetail prior = do 
  withManager $ \manager -> do  
    requesttemp <- case prior of 
                     Urgent    -> parseUrl (url ++ "/queue/1")
                     NonUrgent -> parseUrl (url ++ "/queue/0")
    let json = encode $ toJSON jobdetail 
    let myrequestbody = RequestBodyLBS json 
    let requestpost = requesttemp 
          { method = methodPost
          , requestHeaders = [ ("Content-Type", "text/plain") ]
          , requestBody = myrequestbody } 
    r <- httpLbs requestpost manager 
    liftIO $ putStrLn $ show r 


jobqueueManySend :: Url -> String -> IO ()
jobqueueManySend url mname = do 
  datasetdir <- getCurrentDirectory
  r <- pluginCompile False datasetdir mname "(manyjobs,webdavdir)" 
  case r of 
    Left err -> putStrLn err
    Right value -> do 
      let (manyjobs,webdavdir) = unsafeCoerce value :: ([[(Int,JobInfo)]],WebDAVRemoteDir)
      putStrLn $ show manyjobs
      putStrLn $ show webdavdir   
      putStrLn $ "sending " ++ show (length manyjobs) ++ " job collections"
      mapM_ (\x -> sendManyJob url x >> threadDelay 50000) manyjobs

sendManyJob :: Url -> [(Int,JobInfo)] -> IO () 
sendManyJob url manyjob = do 
  withManager $ \manager -> do  
    requesttemp <- parseUrl (url ++ "/queuemany")
    let json = encode $ toJSON manyjob 
    let myrequestbody = RequestBodyLBS json 
    let requestpost = requesttemp 
          { method = methodPost
          , requestHeaders = [ ("Content-Type", "text/plain") ]
          , requestBody = myrequestbody } 
    r <- httpLbs requestpost manager 
    liftIO $ putStrLn $ show r 



