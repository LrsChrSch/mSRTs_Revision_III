#include "./helper.udo"

giRoot = 80
giGlobalTime = 1500
gaMasterBus[] init 2
gaReverbBus[] init 2
gaDelBus[] init 2
gaResonatorBus[] init 2

instr tableData
  // wave forms
  giSine = ftgen(0, 0, 4096, 10, 1)
  // db table
  giDb = ftgen(0, 0, 4096, -7, -90, 4096, 3)
  // transfer functions 
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

  
  kCursorAcceleration = changek((kCursorPosYHandler + kCursorPosXHandler)  / 2)
  gkCursorAcceleration = port(kCursorAcceleration, 0.25)
  gkSubBeatings = port(kCursorPosXHandler, 0.25)
  gkCameraX = chnget:k("camera_x")
  gkCameraY = chnget:k("camera_y")

  // data for object sounds
  gkNumOfCubes = chnget:k("numOfCubes")     ; ~10000 - ~20000
  gkTransformMin_x = chnget:k("transformMin_x") ; 0 - 1
  gkTransformMin_y = chnget:k("transformMin_y") ; 0 - 1
  gkTransformMin_z = chnget:k("transformMin_z") ; 0 - 1
  gkTransformMax_x = chnget:k("transformMax_x") ; 0 - 1
  gkTransformMax_y = chnget:k("transformMax_y") ; 0 - 1
  gkTransformMax_z = chnget:k("transformMax_z") ; 0 - 1
  gkMatrixCount = chnget:k("matrixCount")   ; 3 - 5
  gkRotationRange = chnget:k("rotationRange") ; 0 - 1
  gkScaleOffset = chnget:k("scaleOffset") ; 0 - 1
  kCameraDistance = chnget:k("cameraDistance") ; ~0.6 - ~1.7
  gkCameraDistance = port(kCameraDistance, 0.25)
  gkCameraDb = tablei(kCameraDistance - 0.6, giDb, 1)
  
  // event data
  gkHoveredIndex = chnget:k("hoveredIndex")
  kHovered = chnget:k("hovered")
  schedkwhen(kHovered, 1, 1, "ducker", 0, 60)
  schedkwhen(kHovered, 1, 1, "hoveredSound", 0, 60)
  if (kHovered == 0) then
	turnoff2("ducker", 0, 1)
	turnoff2("hoveredSound", 0, 1)
	turnoff2("hoveredSoundSig", 0, 1)
  endif
endin
schedule("getDataFromBrowser", 0, giGlobalTime)


instr main
  schedule("additivStruct", 0, giGlobalTime)
  schedule("subBeatings", 0, giGlobalTime)
  schedule("cursorSound", 0, giGlobalTime)
  turnoff
endin
schedule("main", 0, 1)

#include "./additivStruct.csd"
#include "./subBeatings.csd"
#include "./hoveredSound.csd"
#include "./transitionSound.csd"
#include "./objectSound.csd"

instr cursorSound
  iAmp = db(-6)
  iBaseFreq = giRoot * 2
  kEnvFreq = randomi(1, 8, 1)
  aEnvFreqSig = loopxseg(kEnvFreq, 0, 0, 4, 0.05, 1.4, 0.2, 1, 0.75,
	1, 0)
  aEnvAmpSig = loopxseg(kEnvFreq, 0, 0, 0.001, 0.01, 1, 0.05, 0.75, 0.25, 0.001, 0.69,
	0.001, 0)
  aEnvAmpSub = loopxseg(kEnvFreq, 0, 0, 0.001, 0.01, 1, 0.99,
	0.001, 0)
  aFreq = iBaseFreq * aEnvFreqSig
  aSig = poscil(iAmp * aEnvAmpSig, aFreq) 
  aSub = poscil(iAmp * aEnvAmpSub, aFreq * 0.25) 


  aOut = sum(aSig, aSub)
  aOut *= gkCursorAcceleration

  // main env
  iAtt = 2
  iRel = 2
  iSusTime = p3 - (iAtt + iRel)
  aEnv = linseg(0, iAtt, 1, iSusTime, 1, iRel, 0)
  aOut *= aEnv
  
  // reverb send
  gaReverbBus[0] = gaReverbBus[0] + (aOut * 0.25)
  gaReverbBus[1] = gaReverbBus[1] + (aOut * 0.25)

  // master send
  gaMasterBus[0] = gaMasterBus[0] + aOut
  gaMasterBus[1] = gaMasterBus[1] + aOut
endin

instr resonatorBus
  // resonator input
  aResonIn1 = gaResonatorBus[0]
  aResonIn2 = gaResonatorBus[1]
  clear(gaResonatorBus)
  
  // resonator
  kResonFreq1 = giRoot * randomi(1, 2, 0.125)
  kFdbk1 = 0.95
  aReson1 = streson(aResonIn1, kResonFreq1, kFdbk1)

  kResonFreq2 = kResonFreq1 * 1.1
  kFdbk2 = kFdbk1
  aReson2 = streson(aResonIn2, kResonFreq2, kFdbk2)

  // reverb send
  gaReverbBus[0] = gaReverbBus[0] + (aReson1 * 0.25)
  gaReverbBus[1] = gaReverbBus[1] + (aReson2 * 0.25)

  // master send
  gaMasterBus[0] = gaMasterBus[0] + aReson1
  gaMasterBus[1] = gaMasterBus[1] + aReson2
endin
schedule("resonatorBus", 0, giGlobalTime)

instr delayBus
  // delay input
  aDelIn1 = gaDelBus[0]
  aDelIn2 = gaDelBus[1]
  clear(gaDelBus)

  // delay
  kDelTime1 = 0.03
  kFdbk1 = 0.75
  aDUMP1 delayr 5
  aDelOut1 = deltap3(kDelTime1)
  delayw(aDelIn1 + (aDelOut1 * kFdbk1))

  kDelTime2 = kDelTime1 + 0.01
  kFdbk2 = kFdbk1
  aDUMP2 delayr 5
  aDelOut2 = deltap3(kDelTime2)
  delayw(aDelIn2 + (aDelOut2 * kFdbk2))

  // gain control
  iGain = db(-12)
  aDelOut1 *= iGain
  aDelOut2 *= iGain
  
  // reverb send
  gaReverbBus[0] = gaReverbBus[0] + (aDelOut1 * 0.25)
  gaReverbBus[1] = gaReverbBus[1] + (aDelOut2 * 0.25)

  // master send
  gaMasterBus[0] = gaMasterBus[0] + aDelOut1
  gaMasterBus[1] = gaMasterBus[1] + aDelOut2
endin
schedule("delayBus", 0, giGlobalTime)

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

  // master volume
  aLimited1 *= db(-6)
  aLimited2 *= db(-6)
  
  // output
  outs(aLimited1, aLimited2)
endin
schedule("masterBus", 0, giGlobalTime)


