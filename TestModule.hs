module TestModule where



import HEP.Automation.JobQueue.JobType
import HEP.Automation.MadGraph.Model
import HEP.Automation.MadGraph.Model.SM
import HEP.Automation.MadGraph.SetupType
import HEP.Automation.MadGraph.Type
import HEP.Storage.WebDAV.Type

psetup :: ProcessSetup SM
psetup = PS { model = SM
            , process = MGProc [] [ "p p > t t~" ] 
            , processBrief = "ttbar"
            , workname = "ttbar"
            , hashSalt = HashSalt Nothing }

param :: ModelParam SM
param = SMParam

rsetup :: RunSetup 
rsetup = 
    RS { numevent = 10000 
       , machine  = LHC7 ATLAS
       , rgrun    = Auto 
       , rgscale  = 200
       , match    = MLM
       , cut      = DefCut
       , pythia   = RunPYTHIA
       , lhesanitizer  = []
       , pgs      = RunPGS (AntiKTJet 0.4, WithTau)
       , uploadhep = NoUploadHEP
       , setnum   = 1 
       }

eventsets :: [EventSet]
eventsets = [ EventSet psetup param rsetup ] 

webdavdir :: WebDAVRemoteDir
webdavdir = WebDAVRemoteDir "dmmproject/test"

