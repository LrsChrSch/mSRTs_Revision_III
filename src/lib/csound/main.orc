

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
  // streaming data
  kCursorPosYHandler = chnget:k("cursorPosYHandler")
  gkAdditivStructFiltCf = port(kCursorPosYHandler, 0.25)
  kCursorPosXHandler = chnget:k("cursorPosXHandler")
  gkSubBeatings = port(kCursorPosXHandler, 0.25)

  // event data
  kHovered = chnget:k("hovered")
  schedkwhen(kHovered, 1, 1, "hoveredSound", 0, 60)
  if (kHovered == 0) then
	turnoff2("hoveredSoundSig", 0, 1)
  endif
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


;; instr hoveredSound
;;   // signal
;;   kAmp = db(-36)
;;   kTone = 1
;;   kBrite = 3
;;   iBaseFreq = giRoot / 2
;;   aSig1 = hsboscil(kAmp, kTone, kBrite, iBaseFreq, giSine, giHanning)
;;   aSig2 = hsboscil(kAmp, kTone+randomi:k(0.01, 0.025, 0.125), kBrite, iBaseFreq, giSine, giHanning)
;;   aSig = sum(aSig1, aSig2)
  
;;   // trigger envelope
;;   aTrigEnv = linsegr(0, 4, 1, p3 - 2, 1, 0.5, 0)
;;   aSig *= aTrigEnv

;;   // reverb send
;;   gaReverbBus[0] = gaReverbBus[0] + (0.5 * aSig)
;;   gaReverbBus[1] = gaReverbBus[1] + (0.5 * aSig)

;;   // master send
;;   gaMasterBus[0] = gaMasterBus[0] + aSig
;;   gaMasterBus[1] = gaMasterBus[1] + aSig
;; endin


instr hoveredSound
  // set data
  iStructure1[] fillarray 4, 3, 4
  iStructure2[] = iStructure1 * 1
  iScaleDivision1 = 12
  iScaleDivision2 = iScaleDivision1 
  iRoot = giRoot * 16
  iOctDown = 0
  iOctUp = 0
  iNoteSelection1[] structure_to_scale iScaleDivision1, iStructure1, iRoot,\
    iOctDown, iOctUp
  iNoteSelection2[] structure_to_scale iScaleDivision2, iStructure2, iRoot,\
    iOctDown, iOctUp

  iNumOfNotes = lenarray(iNoteSelection1)

  // call synth
  iCnt init 0
  while (iCnt < iNumOfNotes) do
	schedule("hoveredSoundSig", 0, p3, (db(-28) / iNumOfNotes / 2), 
    iNoteSelection1[iCnt], iNoteSelection2[iCnt])  
	iCnt += 1
  od
  turnoff 
endin

instr hoveredSoundSig
  // freq table
  aFreq = line(p5, p3, p6)
  
  // signal
  aSig = poscil3(p4, aFreq) 

  // trigger envelope
  iAtt = random:i(1.5, 2)
  iRel = iAtt
  iSusTime = p3 - (iAtt + iRel)
  aTrigEnv = linsegr(0, iAtt, 1, iSusTime, 1, iRel, 0)
  aSig *= aTrigEnv
  
  // panning
  aOut1, aOut2 pan2 aSig, random:i(0,1) 

  // reverb bus 
  gaReverbBus[0] = gaReverbBus[0] + (aOut1 * 0.5)
  gaReverbBus[1] = gaReverbBus[1] + (aOut2 * 0.5)
  
  // send to master
  gaMasterBus[0] = gaMasterBus[0] + aOut1
  gaMasterBus[1] = gaMasterBus[1] + aOut2
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


