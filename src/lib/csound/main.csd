<CsoundSynthesizer>
<CsOptions>
-odac -d 
--port=10000 
</CsOptions>
<CsInstruments>
sr = 48000
ksmps = 16
nchnls = 2
0dbfs = 1


#include "./helper.udo"

giGlobalTime = 10000
gaReverbBus[] init 2


instr getDataFromBrowser
  gkAdditivStructFiltCf = chnget:k("additivStruct.filtCf")
;;  printks("Filter: %f\n", 2, gkAdditivStructFiltCf)
  gkAdditivStructFiltCf = port(gkAdditivStructFiltCf, 0.25)
endin
schedule("getDataFromBrowser", 0, giGlobalTime)


instr main
  schedule("additivStruct", 0, giGlobalTime)
  turnoff
endin
schedule("main", 0, 1)

#include "./additivStruct.csd"

instr reverbBus
  // reverb input
  aRevIn1 = gaReverbBus[0]
  aRevIn2 = gaReverbBus[1]
  clear(gaReverbBus)
  
  // reverb
  kFdbk = 0.85
  kFco = sr/4
  aRev1, aRev2 reverbsc aRevIn1, aRevIn2, kFdbk, kFco

  // output
  outs(aRev1, aRev2) 
endin
schedule("reverbBus", 0, giGlobalTime)
</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>
