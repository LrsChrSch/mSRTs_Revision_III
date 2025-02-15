instr subBeatings
  // sub beatings
  kBeatings = chnget:k("additivStruct.freqPosition")
  kBeatings = port(kBeatings, 0.25)
  kBeatings = (abs(kBeatings - 0.5) * 10 ) + 0.25
  kAmp = db(-36)
  kFreq = giRoot * 2^(7/12) 
  kFreq1 = kFreq + (kBeatings / 2)
  kFreq2 = kFreq - (kBeatings / 2)
  aSine1 = poscil(kAmp, kFreq1)
  aSine2 = poscil(kAmp, kFreq2)
  aSum = sum(aSine1/2, aSine2/2)

  // envelope
  aEnv = linseg(0, 1, 1, p3 - 2, 1, 1, 0)
  aSum *= aEnv
  
  // send to master
  gaMasterBus[0] = gaMasterBus[0] + aSum
  gaMasterBus[1] = gaMasterBus[1] + aSum
endin