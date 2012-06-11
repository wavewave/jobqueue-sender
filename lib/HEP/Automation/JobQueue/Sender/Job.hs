{-# LANGUAGE OverloadedStrings #-}

module HEP.Automation.JobQueue.Sender.Job where

import Network.HTTP.Types
import Network.HTTP.Conduit

import HEP.Automation.JobQueue.JobJson
import HEP.Automation.JobQueue.JobQueue
import HEP.Automation.JobQueue.JobType

import HEP.Storage.WebDAV

import Data.Aeson.Types
import Data.Aeson.Encode

import Control.Concurrent (threadDelay)
import Control.Monad.Trans 

import HEP.Automation.JobQueue.Sender.Type

import HEP.Util.GHC.Plugins

import Unsafe.Coerce

-- import HEP.Automation.JobQueue.Sender.Plugins

jobqueueSend :: Url -> String -> String -> String -> IO ()
jobqueueSend url datasetdir mname job = do 
  let fullmname = "HEP.Automation.MadGraph.Dataset." ++ mname
  r <- pluginCompile datasetdir fullmname "(eventsets,webdavdir)" 
  case r of 
    Left err -> putStrLn err
    Right value -> do 
      let (eventsets,webdavdir) = unsafeCoerce value :: ([EventSet],WebDAVRemoteDir)
      putStrLn $ show (eventsets,webdavdir) 
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
    let json = encode $ toJSON jobdetail 
    let myrequestbody = RequestBodyLBS json 
    let requestpost = requesttemp 
          { method = methodPost
          , requestHeaders = [ ("Content-Type", "text/plain") ]
          , requestBody = myrequestbody } 
    r <- httpLbs requestpost manager 
    liftIO $ putStrLn $ show r 


jobqueueManySend :: Url -> String -> String -> IO ()
jobqueueManySend url datasetdir mname = do 
  let fullmname = "HEP.Automation.MadGraph.Dataset." ++ mname
  r <- pluginCompile datasetdir fullmname "(manyjobs,webdavdir)" 
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



