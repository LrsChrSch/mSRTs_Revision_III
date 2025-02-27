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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; some synth udos 
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
