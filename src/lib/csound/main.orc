

#include "./helper.udo"

giRoot = 80
giGlobalTime = 1500
gaMasterBus[] init 2
gaReverbBus[] init 2

instr tableData
  giSine = ftgen(0, 0, 4096, 10, 1)
  giHanning = ftgen(0, 0, 4096, 20, 2)
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

;; instr transitionSound
;;   // sine with undertones
;;   kGain = db(-12)
;;   kFreq = 12000
;;   kAmpWeight = 0.75
;;   kBrowserData = i(gkSubBeatings)
;;   printk2 kBrowserData
;;   kFreqRatio = (3.33 * (kBrowserData - 0.5)) + 0.1
;;   printk2 kFreqRatio
;;   iNumOfPartials = 5
;;   aUnderSine = undersine(kFreq, kAmpWeight, abs(kFreqRatio), iNumOfPartials)
;;   aUnderSine *= kGain

;;   // sine with overtones
;;   aOverSine = oversine(giRoot, kAmpWeight, abs(kFreqRatio), iNumOfPartials)
;;   aOverSine *= kGain
;;   aSum = sum(aUnderSine / 2, aOverSine / 2)
  
;;   // envelope
;;   aEnv = transeg(0, 0.01, 5, 1, 2, -2, 0)
;;   aSum *= aEnv

;;   // clip
;;   aSum = clip(aSum, 2, db(-4))
  
;;   // hilbert
;;   aSig1, aSig2 hilbert aSum

  
;;   // send to master
;;   gaMasterBus[0] = gaMasterBus[0] + aSig1
;;   gaMasterBus[1] = gaMasterBus[1] + aSig2
;; endin

instr transitionSound
  // noise generator
  kAmp = db(-24)
  kBeta = 0 // 0 = white, 1 = pink, 2 = brown
  aNoise = noise(kAmp, kBeta)

  // filter
  kCf = line(30, p3, 600)
  kRes = 0.5;limit(0.5, 0, 0.9)
  aFiltNoise = moogladder2(aNoise, kCf, kRes)
  
  // envelope
  aEnv = transeg(0, p3 * 0.9, 2, 1, p3 * 0.1, 1, 1)
  aFiltNoise *= aEnv

  // hilbert
  aSig1, aSig2 hilbert aFiltNoise

  // send to reverb
  gaReverbBus[0] = gaReverbBus[0] + (aSig1*0.25)
  gaReverbBus[1] = gaReverbBus[1] + (aSig2*0.25)
  
  // send to master
  gaMasterBus[0] = gaMasterBus[0] + aSig1
  gaMasterBus[1] = gaMasterBus[1] + aSig2
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


