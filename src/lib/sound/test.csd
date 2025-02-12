<CsoundSynthesizer>
<CsOptions>
-d -odac --port=10000
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1.0

instr Main
  ; synth waveform
  giwave  ftgen 1, 0, 1024, 10, 1, 1, 1, 1
  ; blending window
  giblend ftgen 2, 0, 1024, -19, 1, 0.5, 270, 0.5
  
  // input data from website
  kAmp chnget "main.note.amp"
  kAmp = port(kAmp, 0.5)

  kTone = 0.5
  kBrite = 0.5

  aOut hsboscil db(kAmp), kTone, kBrite, 65, giwave, giblend
  
  outs aOut, aOut
endin
schedule("Main", 0, 1000)

</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>
