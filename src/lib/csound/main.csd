<CsoundSynthesizer>
<CsOptions>
-d -odac --port=10000
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; structure_to_scale
;;; creates a set of scale values, based on something similiar like the sieve
;;; theory from Xenakis. The input is a structure, which describes the
;;; step distances to it's previous value. If iScaleDivision is 12 and
;;; iStructure[0] = 1, it's a half step to the base root note. 
;;; - iScaleDivision -> (integer) Scale Division of the final scale, could be 12
;;; like in a standard temperate scale or anything you want
;;; - iStructure[] -> is an array of integers, which represents steps
;;; in the divided system
;;; - iRoot -> Base frequency of the constructed scale, it's also the
;;; first value of the output array
;;; - iOctDown -> is an integer; the number of copies of the
;;; base-scale, which are transposed down below the original
;;; scale. 1 -> there will be one copy of the base-scale, which is one
;;; octave below the base scale, this scale will be prepend to the
;;; base scale. 2 -> there will be two copies of the base-scale, which
;;; will be one and two octaves below the base-scale and prepend to
;;; the base-scale
;;; - iOctUp -> is an integer; the number of copies of the
;;; base-scale, which are transposed up above the original
;;; scale. 1 -> there will be one copy of the base-scale, which is one
;;; octave above the base scale, this scale will be append to the
;;; base scale. 2 -> there will be two copies of the base-scale, which
;;; will be one and two octaves above the base-scale and append to
;;; the base-scale
;;; - iScale[] -> final scale
opcode structure_to_scale, i[], ii[]ioo
  iScaleDivision, iStructure[], iRoot, iOctDown, iOctUp xin

  iCntScl init 0
  iCntBase init 0

  // make basic scale from structure
  iStep init 0
  iCntBase init 0
  iBaseLength = lenarray(iStructure) + 1
  iBase[] init iBaseLength ;; Länge 7

  create_base:
  iBase[iCntBase] = iStep
  iStep += iStructure[iCntBase]
  iCntBase += 1
  if iCntBase < lenarray(iStructure) igoto create_base
  iBase[iCntBase] = iStep
  iCntBase = 0

  // define the outputscale length
  if (iOctDown != 0) || (iOctUp != 0) then
    iScaleLen = (iBaseLength + (iOctDown * iBaseLength) + \
      (iOctUp * iBaseLength))
  else 
    iScaleLen = iBaseLength
  endif

  iScale[] init iScaleLen

  
  // if iOctDown != 0 populate iScale with freqs from octaves below
  iOctDownCnt init 0
  if iOctDown != 0 then
    populate_oct_down:
    
    cnt_struct_down:
    iScale[iCntScl] = (iRoot / (2 ^ iOctDown)) * (2 ^ (iBase[iCntBase] / iScaleDivision))
    iCntScl += 1
    iCntBase += 1
    if iCntBase < iBaseLength igoto cnt_struct_down

    iCntBase = 0
    iOctDown -= 1
    if iOctDown > 0 igoto populate_oct_down
  endif

  // populate with original scale  
  populate:
  
  iScale[iCntScl] = iRoot * (2 ^ (iBase[iCntBase] / iScaleDivision))
  iCntBase += 1
  iCntScl += 1
  if iCntBase < iBaseLength igoto populate  
  iCntBase = 0
  
  // if iOctUp != 0 populate with freqs from octaves abbove
  iOctUpCnt init 1
  if iOctUp != 0 then
    
    pupulate_oct_up:

    cnt_struct_up:
    iScale[iCntScl] = (iRoot * iOctUpCnt) * (2 ^ (iBase[iCntBase] / iScaleDivision))
    iCntScl += 1
    iCntBase += 1
    if iCntBase < iBaseLength igoto cnt_struct_up

    iCntBase = 0
    iOctUpCnt += 1
    if iOctUpCnt <= iOctUp igoto pupulate_oct_up	
  endif   
  
  xout iScale
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; array_offsets
;;; creates deviation values on a input array by a specific maximum
;;; ammount
;;; - iFreqs[] -> could be any integer or float array, but was
;;; designed with frequency values in mind;
;;; - iAmount -> maximum deviation on input values
;;; - iOffsets -> output array of deviation values
opcode array_offsets, i[], i[]i
  iFreqs[], iAmount xin

  // create a array with offsets
  iFreqsLength = lenarray(iFreqs)
  iOffsets[] init iFreqsLength 
  iCnt init 0    
  while iCnt < iFreqsLength do
    iOffsets[iCnt] = iFreqs[iCnt] * random:i(0.99 * \
      (1 - (iAmount - 0.01)), 1.01 * (1 + iAmount))
    iCnt += 1
  od
  
  xout iOffsets
endop
instr additivStruct
  // set data
  iStructure1[] fillarray 3, 2, 3, 2
  iStructure2[] = iStructure1 * 3
  iScaleDivision1 = 9
  iScaleDivision2 = iScaleDivision1 * 3
  iRoot = 80
  iOctDown = 1
  iOctUp = 3
  iFreqs1[] structure_to_scale iScaleDivision1, iStructure1, iRoot,\
    iOctDown, iOctUp
  iFreqs2[] structure_to_scale iScaleDivision2, iStructure2, iRoot,\
    iOctDown, iOctUp
  iOffsets1[] array_offsets iFreqs1, 1
  iOffsets2[] array_offsets iFreqs2, 1
  iNoteSelection1[] interleave iFreqs1, iOffsets1
  iNoteSelection2[] interleave iFreqs2, iOffsets2

  iNumOfNotes = lenarray(iNoteSelection1)

  // call synth
  iCnt init 0
  while (iCnt < iNumOfNotes) do
	schedule("additivStructSig", 0, p3, (1 / iNumOfNotes / 2), 
    iNoteSelection1[iCnt], iNoteSelection2[iCnt])  
	iCnt += 1
  od
  turnoff 
endin


gaReverbBus[] init 2

instr additivStructSig
  // get data from browser
  ;; kPointer = chnget(additivStruct.freqPosition)
  ;; aPointer = port(kPointer, 0.25)
  ;; kCutOff = chnget(additivStruct.filtCf)
  aPointer = oscil(0.5, .1)
  kCutOff = 300
  // freq table
  iFreqFt = ftgen(0, 0, 1024, -7, p5, 1024, p6)
  ;;  aPointer = ((oscil:a(1, 0.1) + 1) * 0.5)
  aFreq = tablei:a(aPointer, iFreqFt, 1)
  
  // signal
  aSig = poscil3(p4, aFreq) 

  // envelope
  iAtt = random:i(0.25, 2)
  iRel = iAtt
  iSusTime = p3 - (iAtt + iRel)
  aEnv linseg 0, iAtt, 1, iSusTime, 1, iRel, 0
  aSig *= aEnv

  // filter
  aSig = butlp(aSig, 80 + (kCutOff * 300))
  
  // panning
  aOut1, aOut2 pan2 aSig, random:i(0,1) 

  // reverb bus 
  gaReverbBus[0] = gaReverbBus[0] + (aOut1 * 0.5)
  gaReverbBus[1] = gaReverbBus[1] + (aOut2 * 0.5)
  
  // output 
  outs aOut1, aOut2
endin


#include "./helper.udo"
#include "./additivStruct.csd"

instr main
    event_i("i", "additivStruct", 0, (60*100))
endin
schedule("main", 0, 60)



instr reverbBus
  // reverb input
  aRevIn1 = gaReverbBus[0]
  aRevIn2 = gaReverbBus[1]
  clear(gaReverbBus)
  
  // reverb
  kFdbk = 0.85
  kFco = sr/4
  aRev1, aRev2 reverbsc aRevIn1, aRevIn2, kFdbk, kFco

  // output
  outs(aRev1, aRev2) 
endin
schedule("reverbBus", 0, 60*60)
</CsInstruments>
<CsScore>
</CsScore>
</CsoundSynthesizer>
