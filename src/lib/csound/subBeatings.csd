instr subBeatings
  // sub beatings
  kBeatings = (abs(gkSubBeatings - 0.5) * 10 ) + 0.25
  kAmp = db(-36)
  kFreq = giRoot * 2^(7/12) 
  kFreq1 = kFreq + (kBeatings / 2)
  kFreq2 = kFreq - (kBeatings / 2)
  aSine1 = poscil(kAmp, kFreq1)
  aSine2 = poscil(kAmp, kFreq2)
  aSum = sum(aSine1/2, aSine2/2)

  // envelope
  iAtt = random(2, 4)
  iRel = iAtt
  iSusTime = p3 - (2*iAtt)
  aEnv = linseg(0, iAtt, 1, iSusTime, 1, iRel, 0)
  aSum *= aEnv
  
  // send to master
  gaMasterBus[0] = gaMasterBus[0] + aSum
  gaMasterBus[1] = gaMasterBus[1] + aSum
endin

