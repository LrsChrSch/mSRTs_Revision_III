
instr transitionSound
  // data from browser
  iCameraX = i(gkCameraX) ;; 0 -1 
  iCameraY = i(gkCameraY) ;; 0 -1 
  print(iCameraY)
  print(iCameraX)
  // basic sound modulation depending on browser data
  // fm output
  if (iCameraY >= 0.01) then
	iIndex = 10
	kModFreq = (giRoot * 10) * (iIndex * gkCameraX)
	kModAmount = 400 * (iIndex * gkCameraX)
	aFmMod = poscil(kModAmount, kModFreq)
  else
	aFmMod = 0
  endif
  
  ;; noise sections
  // noise generator and waveshaping
  iNoiseAmp = db(-10)
  iBeta = -0.99 // 0 = white, 1 = pink, 2 = brown
  aNoise = noise(iNoiseAmp, iBeta)
  aNoise = distort(aNoise, 1, giHeavyTanh)
  
  // filter noise
  aCf = line(80, p3, 500)
  iRes = 0.3;limit(0.5, 0, 0.9)
  aNoise = moogladder2(aNoise, aCf, iRes)
  
  // envelope noise
  aEnv = transeg(0, p3 * 0.8, -5, 1, p3 * 0.2, 5, 0)
  aNoise *= aEnv

  ;; sub section 
  // sub triangle wave 
  iFreqTri = giRoot * 2^(-7/12)
  aTri = vco2(db(6), iFreqTri + k(aFmMod), 12)
  
  // triangle waveshaping
  iShapeAmount = 1;transeg(0, p3*0.75, 1.5, 0.9, p3*0.25, 0, 1)
  aTri = distort(aTri, iShapeAmount, giMidTanh)
  
  // sub sine
  aSubSineFreq = line(giRoot * 2^(-7/12), p3, giRoot)
  aSine = poscil(db(-3), aSubSineFreq + aFmMod)
  
  // summing sub signals
  aSub = sum(aTri, aSine)
  
  // sub mod 
  aModFreq = line(30, p3, 1)
  aMod = randomh(-1, 1, aModFreq)  
  aSub *= aMod
  
  // filter sub
  kFilterMod = gkCameraX * 250
  aSub = moogladder2(aSub, 500 + kFilterMod, 0.5)
  aSub *= aSub
  // envelope sub
  aEnvSub = transeg(0, p3 * 0.9, 2.5, 1, p3 * 0.2, 5, 0)
  aSub *= aEnvSub
  
  ;; summing section
  // sum signals 
  aSum = sum(aNoise, aSub)
  aSum = distort(aSum, 0.75, giSoftTanh)

  ;; // stutter effect
  ;; if (iCameraY <= 0.5) then
  ;; 	kStutterFreq = iCameraX * 500 
  ;; 	aStutter = vco2(kStutterFreq, 1, 10)
  ;; 	aStutter += 1
  ;; 	aStutter *= 0.5
  ;; 	aSum *= aStutter
  ;; endif

  
  // envelope sum
  iAttCurve = (iCameraX + 1) * 5 
  iDecCurve = (iCameraY + 1) * 5
  aSumEnv = transeg(0, 0.5, iAttCurve, 1, p3 - 1, 1, 1, 0.5, iDecCurve,
	0)
  aSum *= aSumEnv

  
  // send to reverb
  gaReverbBus[0] = gaReverbBus[0] + (aSum*0.125)
  gaReverbBus[1] = gaReverbBus[1] + (aSum*0.125)
  
  // send to master
  gaMasterBus[0] = gaMasterBus[0] + aSum
  gaMasterBus[1] = gaMasterBus[1] + aSum
endin


