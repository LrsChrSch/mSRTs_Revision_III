

#include "./helper.udo"

giRoot = 80
giGlobalTime = 1500
gaMasterBus[] init 2
gaReverbBus[] init 2

instr tableData
  giSine = ftgen(0, 0, 4096, 10, 1)
  giHanning = ftgen(0, 0, 4096, 20, 2)
  giSoftTanh = ftgen(0, 0, 4096, "tanh", -1, 1, 0)
  giMidTanh = ftgen(0, 0, 4096, "tanh", -10, 10, 0)
  giHeavyTanh = ftgen(0, 0, 4096, "tanh", -100, 100, 0)
endin
schedule("tableData", 0, giGlobalTime)

instr getDataFromBrowser
  kCursorPosYHandler = chnget:k("cursorPosYHandler")
  gkAdditivStructFiltCf = port(kCursorPosYHandler, 0.25)
  kCursorPosXHandler = chnget:k("cursorPosXHandler")
  gkSubBeatings = port(kCursorPosXHandler, 0.25)
endin
schedule("getDataFromBrowser", 0, giGlobalTime)


instr main
  schedule("additivStruct", 0, giGlobalTime)
  schedule("subBeatings", 0, giGlobalTime)
  turnoff
endin
schedule("main", 0, 1)

#include "./additivStruct.csd"
#include "./subBeatings.csd"

opcode undersine, a, kkkio
  kFreq, kAmpWeight, kFreqRatio, iNumOfUndertones, iIndex xin

  aSig = poscil(0dbfs / iNumOfUndertones, kFreq)

  if (iIndex < iNumOfUndertones) then
	aSigNew = undersine(kFreq / kFreqRatio, kFreqRatio, kAmpWeight, iNumOfUndertones, iIndex + 1)
	aSigNew = (kAmpWeight / sqrt(iIndex+1)) * aSigNew
	aSig += aSigNew
  endif
  
  xout aSig
endop

opcode oversine, a, kkkio
  kFreq, kAmpWeight, kFreqRatio, iNumOfOvertones, iIndex xin

  aSig = poscil(0dbfs / iNumOfOvertones, kFreq)

  if (iIndex < iNumOfOvertones) then
	aSigNew = oversine(kFreq * kFreqRatio, kFreqRatio, kAmpWeight, iNumOfOvertones, iIndex + 1)
	aSigNew = (kAmpWeight / sqrt(iIndex+1)) * aSigNew
	aSig += aSigNew
  endif
  
  xout aSig
endop

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



instr reverbBus
  // reverb input
  aRevIn1 = gaReverbBus[0]
  aRevIn2 = gaReverbBus[1]
  clear(gaReverbBus)
  
  // reverb
  kFdbk = 0.85
  kFco = sr/4
  aRev1, aRev2 reverbsc aRevIn1, aRevIn2, kFdbk, kFco

  // send to master
  gaMasterBus[0] = gaMasterBus[0] + aRev1
  gaMasterBus[1] = gaMasterBus[1] + aRev2
endin
schedule("reverbBus", 0, giGlobalTime)

instr masterBus
  // master bus in
  aMasterIn1 = gaMasterBus[0]
  aMasterIn2 = gaMasterBus[1]
  clear(gaMasterBus)
  
  // compressor
  aCmpIn1 = aMasterIn1
  aCmpIn2 = aMasterIn2
  kLoKnee = -12
  kHiKnee = -6
  kRatio = 4
  aCmpOut1 = compress2(aCmpIn1, aCmpIn1, -90, kLoKnee, kHiKnee,  \
    kRatio, 0.01, 0.1,  0.05) 
  aCmpOut2 = compress2(aCmpIn2, aCmpIn2, -90, kLoKnee, kHiKnee,  \
    kRatio, 0.01, 0.1,  0.05)

  // limiter
  aLimited1 = limit(aCmpOut1, -1, 1)
  aLimited2 = limit(aCmpOut2, -1, 1)

  // output
  outs(aLimited1, aLimited2)
endin
schedule("masterBus", 0, giGlobalTime)


