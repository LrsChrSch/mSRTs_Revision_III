giObjectClickCount init 0

instr objectSoundTrig
  iCounter = giObjectClickCount % 3
  printks2("kCounter: %d\n", iCounter)
  if (iCounter == 0) then
	event_i("i", "objectSound_1", 0, 60, i(gkNumOfCubes))
  endif
  if (iCounter == 1) then
	event_i("i", "objectSound_2", 0, 60, i(gkNumOfCubes))
  endif
  if (iCounter == 2) then
	event_i("i", "objectSound_3", 0, 60, i(gkNumOfCubes))
  endif
  giObjectClickCount += 1
  turnoff
endin

instr objectSoundKill
  turnoff2("objectSound_1", 0, 1)
  turnoff2("objectSound_2", 0, 1)
  turnoff2("objectSound_2_triggerEnv", 0, 1)
  turnoff2("objectSound_2_sound", 0, 1)
  turnoff2("objectSound_3", 0, 1)
  turnoff2("objectSound_3_triggerEnv", 0, 1)
  turnoff2("objectSound_3_sound", 0, 1)
  turnoff
endin


instr objectSound_1 ;; sine beatings
  // browser data
  kCameraX = port(gkCameraX, 0.25)
  kCameraY = port(gkCameraY, 0.25)
  
  kFreq = giRoot * 12
  kBeatings = 0.125 + (kCameraY * 5) 
  kFreq1 = kFreq - (kBeatings / 2)
  kFreq2 = kFreq + (kBeatings / 2)

  kAmp = db(-16)
  aSine1 = poscil(kAmp, kFreq1)
  aSine2 = poscil(kAmp, kFreq2)
  aSum = sum(aSine1, aSine2)

  // envelope
  iAtt = random(1, 4)
  iDec = iAtt
  iSusTime = p3 - (iAtt + iDec)
  aEnv = linsegr(0, iAtt, 1, iSusTime, 1, 1, 0)
  aSum *= aEnv

  // modulation
  iRingFreq = (giRoot * 12) / ((p4 % 10) + 1)
  aRing = poscil(1, iRingFreq)
  k1 = 1 / ((p4 % 8) + 1)
  k2 = 1 / ((p4 % 5) + 1)
  k3 = 1 / ((p4 % 5) + 1)
  k4 = 1 / ((p4 % 3) + 1)
  aRing = chebyshevpoly(aRing, k1 * kCameraX, k2 * kCameraY, k3 * kCameraX, k4)
  aSum *= aRing

  // amp modulation
  aAmpMod = rspline(0.5, 1, 0.125, 1)
  aSum *= aAmpMod
  
  // panning
  aSig1, aSig2 pan2 aSum, kCameraX
  
  // reverb send
  iRevAmount = db(-18)
  gaReverbBus[0] = (iRevAmount * aSig1) + gaReverbBus[0]
  gaReverbBus[1] = (iRevAmount * aSig2) + gaReverbBus[1]

  // master send
  iMasterSend = db(-14)
  gaMasterBus[0] = gaMasterBus[0] + (iMasterSend * aSig1)
  gaMasterBus[1] = gaMasterBus[1] + (iMasterSend * aSig2)
endin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gaObjectSound_2_triggerEnv init 0

instr objectSound_2
  schedule("objectSound_2_sound", 0, p3, p4)
  kTrig = changed(gkCameraX)
  schedkwhen(kTrig, 0, 1, "objectSound_2_triggerEnv", 0,
	random:k(0.0625, 0.25))
endin

instr objectSound_2_triggerEnv
  gaObjectSound_2_triggerEnv = expseg(0.00001, 0.01, 1, 0.25, 0.00001)
endin

instr objectSound_2_sound ;; fm
  kCameraX = port(gkCameraX, 0.125)
  kCameraY = port(gkCameraY, 0.125)
  // modulator
  kIndex = gaObjectSound_2_triggerEnv * (p4 % 20)
  kModFreq = giRoot * (20 * (1 + kCameraX))
  kModDeviation = kIndex * 100 
  aMod = poscil(kModDeviation, kModFreq)

  // carrier
  kAmp = db(-6)
  kFreq = giRoot * (10 * (1 + kCameraX))
  aCar = poscil(kAmp, kFreq + aMod)
  aSum = aCar
  
  // envelope
  iAtt = random(1, 4)
  iDec = iAtt
  iSusTime = p3 - (iAtt + iDec)
  aEnv = linsegr(0, iAtt, 1, iSusTime, 1, 1, 0)
  aSum *= aEnv

  // amp modifikation
  aAmpMod = rspline(0, 1, 0.125, 0.25)
  aSum *= aAmpMod
  aSum *= gaObjectSound_2_triggerEnv

  // delay
  aDelTime = rspline(0.03, 1, 0.125, 5)
  aDel = vdelay(aSum, aDelTime, 2)
  aSum = sum(aDel * 1.2, aSum)
  
  // panning
  aSig1, aSig2 pan2 aSum, kCameraX
  
  // reverb send
  iRevAmount = db(-18)
  gaReverbBus[0] = (iRevAmount * aSig1) + gaReverbBus[0]
  gaReverbBus[1] = (iRevAmount * aSig2) + gaReverbBus[1]

  // master send
  iMasterSend = db(-6)
  gaMasterBus[0] = gaMasterBus[0] + (iMasterSend * aSig1)
  gaMasterBus[1] = gaMasterBus[1] + (iMasterSend * aSig2)  
endin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gaObjectSound_3_triggerEnv init 0
instr objectSound_3
  schedule("objectSound_3_sound", 0, p3, p4)
  kTrig = changed(gkCameraX)
  schedkwhen(kTrig, 0, 1, "objectSound_3_triggerEnv", 0,
	random:k(0.125, 0.5))
endin

instr objectSound_3_triggerEnv
  gaObjectSound_3_triggerEnv = expseg(0.00001, 0.25, 1, 0.1, 0.00001)
endin

instr objectSound_3_sound ;; rhythmic noise
  // data from browser
  kCameraX = port(gkCameraX, 0.125)
  kCameraY = port(gkCameraY, 0.125)
  iNumOfCubes = p4

  // noise
  kBeta = 0.75
  aNoiseAmp = db(-12)
  aNoise1 = noise(aNoiseAmp, kBeta)
  aNoise2 = noise(aNoiseAmp, -kBeta)

  // rhythmic
  aSig1 = aNoise1 * gaObjectSound_3_triggerEnv
  aSig2 = aNoise2 * gaObjectSound_3_triggerEnv

  // delay slurr
  aDelIn = sum(aSig1, aSig2)
  kDelTime = kCameraY + 0.3 
  kFdbk = kCameraX 
  aDUMP delayr 2
  aDelOut deltap kDelTime
  delayw aDelIn + (aDelOut * kFdbk)
  
  // amp env
  iAtt = random(1, 2)
  iRel = iAtt
  iSusTime = p3 - (iAtt + iRel)
  aEnv = linsegr(0, iAtt, 1, iSusTime, 1, iRel, 0)
  aSig1 *= aEnv
  aSig2 *= aEnv

  // adding the delay
  aSig1 = sum(aSig1, aDelOut)
  aSig2 = sum(aSig2, aDelOut)
  
  // gain
  iGain = db(-20)
  aSig1 *= iGain
  aSig2 *= iGain
  
  // reverb send
  gaReverbBus[0] = gaReverbBus[0] + (aSig1 * db(-12))
  gaReverbBus[1] = gaReverbBus[1] + (aSig2 * db(-12))

  // master send
  gaMasterBus[0] = gaMasterBus[0] + aSig1
  gaMasterBus[1] = gaMasterBus[1] + aSig2  
endin

