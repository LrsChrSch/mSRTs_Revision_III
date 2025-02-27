
instr transitionSound
  ;; noise sections
  // noise generator and waveshaping
  kNoiseAmp = db(-12)
  kBeta = -0.99 // 0 = white, 1 = pink, 2 = brown
  aNoise = noise(kNoiseAmp, kBeta)
  aNoise = distort(aNoise, 1, giHeavyTanh)
  
  // filter noise
  kCf = line(80, p3, 500)
  kRes = 0.3;limit(0.5, 0, 0.9)
  aNoise = moogladder2(aNoise, kCf, kRes)
  
  // envelope noise
  aEnv = transeg(0, p3 * 0.8, -5, 1, p3 * 0.2, 5, 0)
  aNoise *= aEnv

  ;; sub section 
  // sub triangle wave 
  kFreqTri = giRoot * 2^(-7/12)
  aTri = vco2(db(6), kFreqTri, 12)
  
  // triangle waveshaping
  kShapeAmount = 1;transeg(0, p3*0.75, 1.5, 0.9, p3*0.25, 0, 1)
  aTri = distort(aTri, kShapeAmount, giMidTanh)
  
  // sub sine
  kSubSineFreq = line(giRoot * 2^(-7/12), p3, giRoot)
  aSine = poscil(db(-3), kSubSineFreq)
  
  // summing sub signals
  aSub = sum(aTri, aSine)
  
  // sub mod 
  kModFreq = line(30, p3, 1)
  aMod = randomh(-1, 1, kModFreq)  
  aSub *= aMod
  
  // filter sub
  aSub = moogladder2(aSub, 500, 0.75)
  
  // envelope sub
  aEnvSub = transeg(0, p3 * 0.9, 2.5, 1, p3 * 0.2, 5, 0)
  aSub *= aEnvSub
  
  ;; summing section
  // sum signals 
  aSum = sum(aNoise, aSub)
  aSum = distort(aSum, 0.5, giSoftTanh)

  // envelope sum
  aSumEnv = linseg(0, 0.01, 1, p3 - 0.04, 1, 0.03, 0)
  aSum *= aSumEnv
  
  // send to reverb
  gaReverbBus[0] = gaReverbBus[0] + (aSum*0.125)
  gaReverbBus[1] = gaReverbBus[1] + (aSum*0.125)
  
  // send to master
  gaMasterBus[0] = gaMasterBus[0] + aSum
  gaMasterBus[1] = gaMasterBus[1] + aSum
endin


