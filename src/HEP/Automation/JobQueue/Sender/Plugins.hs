module HEP.Automation.JobQueue.Sender.Plugins where

import GHC 
import GHC.Paths
import DynFlags
import Unsafe.Coerce

import HEP.Automation.JobQueue.JobType
import HEP.Storage.WebDAV.Type

import Control.Monad
import System.FilePath

pluginCompile :: String -> String -> IO ([EventSet],WebDAVRemoteDir) 
pluginCompile datasetdir mname =  
  defaultErrorHandler defaultDynFlags $ do 
    let modulename = "HEP.Automation.MadGraph.Dataset." ++ mname
    let fp = datasetdir </> "HEP/Automation/MadGraph/Dataset" </> mname ++ ".hs"
    func <- runGhc (Just libdir) $ do 
      dflags <- getSessionDynFlags
      setSessionDynFlags dflags
      target <- guessTarget fp Nothing 
      addTarget target
      r <- load LoadAllTargets 
      case r of 
        Failed -> error "Compilation Failed"
        Succeeded -> do 
          m <- findModule (mkModuleName modulename) Nothing
          setContext [] [(m,Nothing)]
          value <- compileExpr ("(eventsets,webdavdir)")
          do let value' = (unsafeCoerce value) :: ([EventSet],WebDAVRemoteDir)  
             return value'
--    let f = func 
    return func




