instr objectSoundTrig
  turnoff2("objectSound", 0, 2)
  schedule("objectSound", 0, 30, i(gkNumOfCubes))
  turnoff
endin

instr objectSoundKill
  turnoff
endin

instr objectSound
  prints("Started")
  // data 
  iNumOfCubes = p4

  // ft looper
  
  iFt = giPad
  kSpeed = 1 / ((iNumOfCubes % 4) + 0.25)
  kLoopStart = line(0, p3, 1)
  kLoopSize = 250
  iOff = 0.5
  iWndwFt = giHanning
  iPhasDistFt = giPhs1
  kMaskArr[] = fillarray(1, 1, 1, 1)
  aSig1, aSig2 ft_looper_stereo iFt, kSpeed, kLoopStart, kLoopSize,\
	iOff, iWndwFt, iPhasDistFt, kMaskArr

  // amp env
  iAtt = random(2, 4)
  iRel = iAtt
  iSusTime = p3 - (iAtt + iRel)
  aEnv = linseg(0, iAtt, 1, iSusTime, 1, iRel, 0)
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