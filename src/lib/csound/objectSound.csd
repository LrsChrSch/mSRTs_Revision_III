giObjectCount init 0

instr prepare_objectSoundTrig
  
endin
schedule("prepare_objectSoundTrig", 0, giGlobalTime)

instr objectSoundTrig
  // create numbers for strings
  strset(0, "objectSound_1")
  strset(1, "objectSound_2")
  strset(2, "objectSound_3")
  strset(3, "objectSound_4")

  // create arrays for instrument calls
  iInstrArr1[] = fillarray(0, 1, 2, 3, 1, 2, 0, 0, 3)
  iInstrArr2[] = fillarray(3, 2, 1, 0, 2, 0)
  iInstrArr1Length = lenarray(iInstrArr1)
  iInstrArr2Length = lenarray(iInstrArr2)

  // call isorhymtically instruments
  iInstrCnt1 = giObjectCount % iInstrArr1Length
  iInstrCnt2 = giObjectCount % iInstrArr2Length
  iInstrNumber1 = iInstrArr1[iInstrCnt1]
  iInstrNumber2 = iInstrArr2[iInstrCnt2]
  S_instr_1 = strget(iInstrNumber1)
  S_instr_2 = strget(iInstrNumber2)

  // choose effect sends for instruments
  iEffectSendArr1[] = fillarray(0, 1, 2, 1, 0, 2)
  iEffectSendArr2[] = fillarray(0, 1, 2, 1, 0, 2, 0)
  iEffectSendArr1Length = lenarray(iEffectSendArr1)
  iEffetcSendArr2Length = lenarray(iEffectSendArr2)
  iEffectCnt1 = giObjectCount % iEffectSendArr1Length
  iEffectCnt2 = giObjectCount % iEffetcSendArr2Length
  iEffectForInstr1 = iEffectSendArr1[iEffectCnt1]
  iEffectForInstr2 = iEffectSendArr2[iEffectCnt2]

  // choose wet only or not
  iWetOnlyArr1[] = fillarray(0, 0, 0, 0, 1, 0, 1, 1)
  iWetOnlyArr2[] = fillarray(0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1)
  iWetOnlyArr1Length = lenarray(iWetOnlyArr1)
  iWetOnlyArr2Length = lenarray(iWetOnlyArr2)
  iWetOnlyCnt1 = giObjectCount % iWetOnlyArr1Length
  iWetOnlyCnt2 = giObjectCount % iWetOnlyArr2Length
  iWetOnlyForInstr1 = iWetOnlyArr1[iWetOnlyCnt1]
  iWetOnlyForInstr2 = iWetOnlyArr2[iWetOnlyCnt2]
  
  schedule(S_instr_1, 0, 60, iEffectForInstr1, iWetOnlyForInstr1)
  schedule(S_instr_2, 0, 60, iEffectForInstr2, iWetOnlyForInstr2)
  schedule("envelope_generator", 0, 60)
  giObjectCount += 1
  turnoff
endin

instr objectSoundKill
  turnoff2("objectSound_1", 0, 1)
  turnoff2("objectSound_2", 0, 1)
  turnoff2("objectSound_3", 0, 1)
  turnoff2("objectSound_4", 0, 1)
  turnoff2("envelope_generator", 0, 1)
  turnoff
endin

instr envelope_generator
  kTrig = changed(gkCameraX)
  schedkwhen(kTrig, 0, 1, "envelope_generator_env", 0, .1)
endin

gaEnvelopeGen init 0
instr envelope_generator_env ;; amount of percussivness in sound
  // object data
  iRotation = i(gkRotationRange)
  iScale = i(gkScaleOffset)

  // envelope data
  iMaxDur = 2
  iMinDur = 0.1 
  iDur = linear_scaling(iScale, 0, 1, iMinDur, iMaxDur)
  iDur *= random:i(0.75, 1.25)
  p3 = iDur


  iStartEndVol = 0
  iAtt = linear_scaling(iScale, 0, 1, iDur * 0.05, iDur * 0.1)
  iDec = linear_scaling(iScale, 0, 1, iDur * 0.1, iDur * 0.2)
  iRel = linear_scaling(iScale, 0, 1, iDur * 0.15, iDur * 0.25)
  iSusTime = iDur - (iAtt + iDec + iRel)
  iSusLvl = linear_scaling(iRotation, 0, 1, 0.25, 1)
  
  gaEnvelopeGen = linsegr(iStartEndVol, iAtt, 1, iDec, iSusLvl,
	iSusTime, iSusLvl, iRel, iStartEndVol)
endin

instr objectSound_1 ;; sine beatings
  // browser data
  kCameraX = port(gkCameraX, 0.125)
  kCameraY = port(gkCameraY, 0.125)
  
  kFreq = giRoot * 12
  kBeatings = 0.125 + (kCameraY * 5) 
  kFreq1 = kFreq - (kBeatings / 2)
  kFreq2 = kFreq + (kBeatings / 2)

  kAmp = db(-8)
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
  aRing1 = chebyshevpoly(aRing, k1 * kCameraX, k2 * kCameraY, k3 * kCameraX, k4)
  aSum *= aRing1

  ;; aRing2 = randi(1, iRingFreq)
  ;; aSum *= aRing2
    // amp modulation
  aAmpMod = rspline(0.5, 1, 0.125, 1)
  aSum *= aAmpMod
  
  // envelope_generator
  aSum *= gaEnvelopeGen
  
  // phaser
  aSum = phaser1(aSum, giRoot, 64, 0.85)
  
  // panning
  aSig1, aSig2 pan2 aSum, kCameraX

  // wet only via p5
  if (p5 == 1) then
	iWetOnly = 0
  else
	iWetOnly = 1
  endif
  
  // choose effect send via p4
  if (p4 == 0) then 
	// reverb send
	iRevAmount = db(-18) + (iWetOnly * db(-3))
	gaReverbBus[0] = (iRevAmount * aSig1) + gaReverbBus[0]
	gaReverbBus[1] = (iRevAmount * aSig2) + gaReverbBus[1]
  elseif (p4 == 1) then
	// delay send
	iDelAmount = db(-18) + (iWetOnly * db(-3))
	gaDelBus[0] = (iDelAmount * aSig1) + gaDelBus[0]
	gaDelBus[1] = (iDelAmount * aSig2) + gaDelBus[1]
  elseif (p4 == 2) then 
	// resonatore send
	iResonAmount = db(-18) + (iWetOnly * db(-3))
	gaResonatorBus[0] = (iResonAmount * aSig1) + gaResonatorBus[0]
	gaResonatorBus[1] = (iResonAmount * aSig2) + gaResonatorBus[1]
  endif 

  // master send
  iMasterSend = db(-14)
  iMasterSend *= iWetOnly
  gaMasterBus[0] = gaMasterBus[0] + (iMasterSend * aSig1)
  gaMasterBus[1] = gaMasterBus[1] + (iMasterSend * aSig2)
endin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gaObjectSound_2_triggerEnv init 0

;; instr objectSound_2
;;   schedule("objectSound_2_sound", 0, p3, p4)
;;   kTrig = changed(gkCameraX)
;;   schedkwhen(kTrig, 0, 1, "objectSound_2_triggerEnv", 0,
;; 	random:k(0.0625, 0.25))
;; endin

;; instr objectSound_2_triggerEnv
;;   gaObjectSound_2_triggerEnv = expseg(0.00001, 0.01, 1, 0.25, 0.00001)
;; endin

instr objectSound_2 ;; fm
  kCameraX = port(gkCameraX, 0.125)
  kCameraY = port(gkCameraY, 0.125)
  // modulator
  kIndex = gaEnvelopeGen * (p4 % 20)
  kModFreq = giRoot * (3 * (1 + kCameraX))
  kModDeviation = kIndex * 10 
  aMod = poscil(kModDeviation, kModFreq)

  // carrier
  kAmp = db(-6)
  kFreq = giRoot * (4 * (0.25 + kCameraX))
  aCar = poscil(kAmp, kFreq + aMod)
  aSum = aCar

  ;; // ring mod
  ;; iRingFreq = (giRoot * 12) / ((p4 % 10) + 1)
  ;; aRing = randi(1, giRoot *10)
  ;; aSum *= aRing

  // phaser
  aSum = phaser1(aSum, giRoot * 10, 16, -0.9)
  
  
  // envelope
  iAtt = random(1, 4)
  iDec = iAtt
  iSusTime = p3 - (iAtt + iDec)
  aEnv = linsegr(0, iAtt, 1, iSusTime, 1, 1, 0)
  aSum *= aEnv

  // amp modifikation
  aAmpMod = rspline(0, 1, 0.125, 0.25)
  aSum *= aAmpMod

  // envelope_generator
  aSum *= gaEnvelopeGen

  // delay
  aDelTime = rspline(0.03, 1, 0.125, 5)
  aDel = vdelay(aSum, aDelTime, 2)
  aSum = sum(aDel, aSum)
  
  // panning
  aSig1, aSig2 pan2 aSum, kCameraX
  
  // wet only via p5
  if (p5 == 1) then
	iWetOnly = 0
  else
	iWetOnly = 1
  endif
  
  // choose effect send via p4
  if (p4 == 0) then 
	// reverb send
	iRevAmount = db(-18) + (iWetOnly * db(-3))
	gaReverbBus[0] = (iRevAmount * aSig1) + gaReverbBus[0]
	gaReverbBus[1] = (iRevAmount * aSig2) + gaReverbBus[1]
  elseif (p4 == 1) then
	// delay send
	iDelAmount = db(-18) + (iWetOnly * db(-3))
	gaDelBus[0] = (iDelAmount * aSig1) + gaDelBus[0]
	gaDelBus[1] = (iDelAmount * aSig2) + gaDelBus[1]
  elseif (p4 == 2) then 
	// resonator send
	iResonAmount = db(-18) + (iWetOnly * db(-3))
	gaResonatorBus[0] = (iResonAmount * aSig1) + gaResonatorBus[0]
	gaResonatorBus[1] = (iResonAmount * aSig2) + gaResonatorBus[1]
  endif 

  // master send
  iMasterSend = db(-14)
  iMasterSend *= iWetOnly
  gaMasterBus[0] = gaMasterBus[0] + (iMasterSend * aSig1)
  gaMasterBus[1] = gaMasterBus[1] + (iMasterSend * aSig2)  
endin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gaObjectSound_3_triggerEnv init 0
;; instr objectSound_3
;;   schedule("objectSound_3_sound", 0, p3, p4)
;;   kTrig = changed(gkCameraX)
;;   schedkwhen(kTrig, 0, 1, "objectSound_3_triggerEnv", 0,
;; 	random:k(0.125, 0.5))
;; endin

;; instr objectSound_3_triggerEnv
;;   gaObjectSound_3_triggerEnv = expseg(0.00001, 0.25, 1, 0.1, 0.00001)
;; endin

instr objectSound_3 ;; rhythmic noise
  // data from browser
  kCameraX = port(gkCameraX, 0.125)
  kCameraY = port(gkCameraY, 0.125)
  iNumOfCubes = p4

  // noise
  kBeta = 0.75
  aNoiseAmp = db(-12)
  aNoise1 = noise(aNoiseAmp, kBeta)
  aNoise2 = noise(aNoiseAmp, -kBeta)

  // ring mod
  iRingFreq = (giRoot * 12) / ((p4 % 10) + 1)
  aRing = randi(1, iRingFreq)
  aSig1 = aNoise1 * aRing
  aSig2 = aNoise2 * aRing

  // delay slurr
  aDelIn = sum(aSig1, aSig2)
  kDelTime = kCameraY + 0.3 
  kFdbk = kCameraX 
  aDUMP delayr 2
  aDelOut deltap kDelTime
  delayw aDelIn + (aDelOut * kFdbk)
  
  ;; // amp env


  // adding the delay
  aSig1 = sum(aSig1, aDelOut)
  aSig2 = sum(aSig2, aDelOut)

  // envelope_generator
  aSig1 *= gaEnvelopeGen
  aSig2 *= gaEnvelopeGen
  
  // gain
  iGain = db(-20)
  aSig1 *= iGain
  aSig2 *= iGain

  // wet only via p5
  if (p5 == 1) then
	iWetOnly = 0
  else
	iWetOnly = 1
  endif
  
  // choose effect send via p4
  if (p4 == 0) then 
	// reverb send
	iRevAmount = db(-18) + (iWetOnly * db(-3))
	gaReverbBus[0] = (iRevAmount * aSig1) + gaReverbBus[0]
	gaReverbBus[1] = (iRevAmount * aSig2) + gaReverbBus[1]
  elseif (p4 == 1) then
	// delay send
	iDelAmount = db(-18) + (iWetOnly * db(-3))
	gaDelBus[0] = (iDelAmount * aSig1) + gaDelBus[0]
	gaDelBus[1] = (iDelAmount * aSig2) + gaDelBus[1]
  elseif (p4 == 2) then 
	// resonator send
	iResonAmount = db(-18) + (iWetOnly * db(-3))
	gaResonatorBus[0] = (iResonAmount * aSig1) + gaResonatorBus[0]
	gaResonatorBus[1] = (iResonAmount * aSig2) + gaResonatorBus[1]
  endif 
  
  // master send
  iMasterSend = db(-8)
  iMasterSend *= iWetOnly
  gaMasterBus[0] = gaMasterBus[0] + (aSig1 * iMasterSend)
  gaMasterBus[1] = gaMasterBus[1] + (aSig2 * iMasterSend)
endin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr objectSound_4 ;; karplus strong clicks
  // data from browser
  kCameraX = port(gkCameraX, 0.125)
  kCameraY = port(gkCameraY, 0.125)

  // click
  kClickAmp = db(-0.3)
  kClickFreq = 1 - kCameraX
  aClick = mpulse(kClickAmp, kClickFreq)

  // delay slurr
  aDelIn = aClick
  kDelTime1 = scale(kCameraX, 0.08, 0.01, 1, 0)
  kFdbk1 = -0.85
  aDUMP1 delayr 2
  aDelOut1 deltap kDelTime1
  delayw aDelIn + (aDelOut1 * kFdbk1)

  kDelTime2 = kDelTime1 + 0.02
  kFdbk2 =  kFdbk1
  aDUMP2 delayr 2
  aDelOut2 deltap kDelTime2
  delayw aDelIn + (aDelOut2 * kFdbk2)

  // amp env
  iAtt = random(1, 2)
  iRel = iAtt
  iSusTime = p3 - (iAtt + iRel)
  aEnv = linsegr(0, iAtt, 1, iSusTime, 1, iRel, 0)
  aDelOut1 *= aEnv
  aDelOut2 *= aEnv
  
  // gain
  iGain = db(-16)
  aDelOut1 *= iGain
  aDelOut2 *= iGain

  aSig1 = aDelOut1
  aSig2 = aDelOut2

  // wet only via p5
  if (p5 == 1) then
	iWetOnly = 0
  else
	iWetOnly = 1
  endif
  
  // choose effect send via p4
  if (p4 == 0) then 
	// reverb send
	iRevAmount = db(-18) + (iWetOnly * db(-3))
	gaReverbBus[0] = (iRevAmount * aSig1) + gaReverbBus[0]
	gaReverbBus[1] = (iRevAmount * aSig2) + gaReverbBus[1]
  elseif (p4 == 1) then
	// delay send
	iDelAmount = db(-18) + (iWetOnly * db(-3))
	gaDelBus[0] = (iDelAmount * aSig1) + gaDelBus[0]
	gaDelBus[1] = (iDelAmount * aSig2) + gaDelBus[1]
  elseif (p4 == 2) then 
	// resonator send
	iResonAmount = db(-18) + (iWetOnly * db(-3))
	gaResonatorBus[0] = (iResonAmount * aSig1) + gaResonatorBus[0]
	gaResonatorBus[1] = (iResonAmount * aSig2) + gaResonatorBus[1]
  endif 

  // master send
  iMasterSend = db(-8)
  iMasterSend *= iWetOnly
  gaMasterBus[0] = gaMasterBus[0] + (aSig1 * iMasterSend)
  gaMasterBus[1] = gaMasterBus[1] + (aSig2 * iMasterSend)
endin


