{-# LANGUAGE OverloadedStrings #-}

module HEP.Automation.JobQueue.Sender.Job where

import Network.HTTP.Types
import Network.HTTP.Enumerator

import HEP.Automation.JobQueue.JobJson
import HEP.Automation.JobQueue.JobQueue
import HEP.Automation.JobQueue.JobType

import HEP.Storage.WebDAV

import Data.Aeson.Encode

import Control.Concurrent (threadDelay)

import HEP.Automation.JobQueue.Sender.Type

import HEP.Util.GHC.Plugins

import Unsafe.Coerce

-- import HEP.Automation.JobQueue.Sender.Plugins

jobqueueSend :: Url -> String -> String -> String -> IO ()
jobqueueSend url datasetdir mname job = do 
  let fullmname = "HEP.Automation.MadGraph.Dataset." ++ mname
  value <- pluginCompile datasetdir fullmname "(eventsets,webdavdir)" 
  let (eventsets,webdavdir) = unsafeCoerce value :: ([EventSet],WebDAVRemoteDir)
  jobdetails <- case job of
                  "atlas_lhco"  -> return $ map (flip (MathAnal "atlas_lhco") webdavdir) eventsets
                  "tev_reco"    -> return $ map (flip (MathAnal "tev_reco") webdavdir) eventsets
                  "tev_top_afb" -> return $ map (flip (MathAnal "tev_top_afb") webdavdir) eventsets
                  "tevpythia"   -> return $ map (flip (MathAnal "tevpythia") webdavdir) eventsets
                  "eventgen"    -> return $ map (flip EventGen webdavdir) eventsets
                  _ -> error "atlas_lhco tev_reco tev_top_afb tevpythia eventgen"
  putStrLn $ "sending " ++ show (length eventsets) ++ " jobs"
  mapM_ (\x -> sendJob url x NonUrgent >> threadDelay 50000) jobdetails

sendJob :: Url -> JobDetail -> JobPriority -> IO () 
sendJob url jobdetail prior = do 
  withManager $ \manager -> do  
    requesttemp <- case prior of 
                     Urgent    -> parseUrl (url ++ "/queue/1")
                     NonUrgent -> parseUrl (url ++ "/queue/0")
    let json = encode $ toAeson jobdetail 
    let myrequestbody = RequestBodyLBS json 
    let requestpost = requesttemp 
          { method = methodPost
          , requestHeaders = [ ("Content-Type", "text/plain") ]
          , requestBody = myrequestbody } 
    r <- httpLbs requestpost manager 
    putStrLn $ show r 



