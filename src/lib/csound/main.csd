<CsoundSynthesizer>
<CsOptions>
-d -odac
;;--port=10000
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 6
nchnls = 2
0dbfs = 1.0

gaReverbBus[] init 2

#include "./helper.udo"
#include "./additivStruct.csd"

instr main
  event_i("i", "additivStruct", 0, (60*100))
endin
schedule("main", 0, 60*60)



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
schedule("reverbBus", 0, 60*60)
</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>
