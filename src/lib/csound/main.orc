

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
#include "./hoveredSound.csd"
#include "./transitionSound.csd"

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


