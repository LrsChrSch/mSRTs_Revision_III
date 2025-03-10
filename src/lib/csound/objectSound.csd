instr objectSoundTrig
  schedule("objectSound_1", 0, 30, i(gkNumOfCubes))
  turnoff
endin

instr objectSoundKill
  turnoff2("objectSound_1", 0, 1)
  turnoff
endin

instr objectSound_3
  
endin


instr objectSound_1 ;; rhythmic noise 
  prints("Started\n")
  // data 
  iNumOfCubes = p4

  // noise
  kBeta = 0.75
  aNoise1 = noise(1, kBeta)
  aNoise2 = noise(1, -kBeta)

  // rhythmic
  kTrig = metro(4)

  iAtt = 0.001
  iDec = 0.02
  iSusTime = 0.02
  iRel = 0.01 
  iOutTime = 1 - (iAtt + iDec + iSusTime + iRel) 
  aEnv = loopseg(4, 0, 0, 0, iAtt, 1, iDec, 0.8, iSusTime, 0.8, iRel,
	0, iOutTime, 0, 0)
  aSig1 = aNoise1 * aEnv
  aSig2 = aNoise2 * aEnv
  
  // amp env
  iAtt = random(1, 2)
  iRel = iAtt
  iSusTime = p3 - (iAtt + iRel)
  aEnv = linsegr(0, iAtt, 1, iSusTime, 1, iRel, 0)
  aSig1 *= aEnv
  aSig2 *= aEnv
  
  // gain
  iGain = db(-16)
  aSig1 *= iGain
  aSig2 *= iGain
  
  // reverb send
  gaReverbBus[0] = gaReverbBus[0] + (aSig1 * 0.125)
  gaReverbBus[1] = gaReverbBus[1] + (aSig2 * 0.125)

  // master send
  gaMasterBus[0] = gaMasterBus[0] + aSig1
  gaMasterBus[1] = gaMasterBus[1] + aSig2  
endin

instr objectSound_2
  prints("Started\n")
  // data 
  iNumOfCubes = p4

  // ft looper
  
  iFt = giFuzz
  kSpeed = (iNumOfCubes % 5) * 0.125
  kSpeed += 0.25
  kLoopStart = 0.5;line(0, p3, 1)
  kLoopSize = 250
  iOff = 0.5
  iWndwFt = giHanning

  iLengthPhsFtArr = lenarray(giPhsFtArr)
  iPhasDistFt = giPhsFtArr[(iNumOfCubes % iLengthPhsFtArr)]
  kMaskArr[] = fillarray(1, 1, 1, 1)
  aSig1, aSig2 ft_looper_stereo iFt, kSpeed, kLoopStart, kLoopSize,\
	iOff, iWndwFt, iPhasDistFt, kMaskArr

  // amp env
  iAtt = random(1, 2)
  iRel = iAtt
  iSusTime = p3 - (iAtt + iRel)
  aEnv = linsegr(0, iAtt, 1, iSusTime, 1, iRel, 0)
  aSig1 *= aEnv
  aSig2 *= aEnv
  
  // gain
  iGain = db(-12)
  aSig1 *= iGain
  aSig2 *= iGain
  
  // reverb send
  gaReverbBus[0] = gaReverbBus[0] + (aSig1 * 0.25)
  gaReverbBus[1] = gaReverbBus[1] + (aSig2 * 0.25)

  // master send
  gaMasterBus[0] = gaMasterBus[0] + aSig1
  gaMasterBus[1] = gaMasterBus[1] + aSig2  
endin