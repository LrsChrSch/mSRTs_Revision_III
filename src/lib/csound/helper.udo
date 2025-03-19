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

/* ft_looper_stereo
function table looper with two voices, optional phasedistortion of
the readhead and masking table for both voices
- kSpeed -> transposition factor
- kLoopStart -> 0-1, Position in Soundfile
- kLoopSize -> size of loopsegment in MS
- iStereoOffset -> 0-1, offset of the both voices
- iWndwFt -> window function for 
- iPhaseDistTable -> FT for the phasedistortion
- kMaskArr[] -> masking array for voices
*/

// split a stereo ft into two mono ft
opcode split_ft, ii, i
  iFt xin

  iFtSr = ftsr(iFt)
  iFtLen = ftlen(iFt)
  iLenHalf = iFtLen/2
  iFt1 ftgen 0, 0, iLenHalf, 2, 0
  iFt2 ftgen 0, 0, iLenHalf, 2, 0
  ftslicei iFt, iFt1, 0, 0, 2
  ftslicei iFt, iFt2, 1, 0, 2

  xout iFt1, iFt2
endop

opcode ft_looper_stereo, aa, ikkkiiik[]
  setksmps 1
  iFt, kSpeed, kLoopStart, kLoopSize, iStereoOffset, iWndwFt, iPhaseDistTable, kMaskArr[] xin

  // read data from table
  if ftchnls(iFt) == 2 then
    iFt1, iFt2 split_ft iFt
  else
    iFt1 = iFt
    iFt2 = iFt
  endif

  iSndflTbl1 = iFt1
  iSndflTbl2 = iFt2

  // calculate size
  iSndflSamps = ftlen(iFt1)
  iSndflSr = ftsr(iFt)
  iSndflSeconds = iSndflSamps / iSndflSr
  iSndflMs = iSndflSeconds * 1000 ;; size of ft in MS
  kSize = ((kLoopSize / 1000) * iSndflSr) ;; loop size in samples

  // main phasor
  kSizeFactor = kSize / iSndflSamps
  kPhasorSpeed = (kSpeed / iSndflSeconds)
  kPhasorSpeed = kPhasorSpeed / kSizeFactor

  aSyncOut1 init 1
  aSyncOut2 init 1
  kPhasorSpeed1 = (k(aSyncOut1) == 1 ? kPhasorSpeed : kPhasorSpeed1)
  kPhasorSpeed2 = (k(aSyncOut2) == 1 ? kPhasorSpeed : kPhasorSpeed2)
  iOff1 = iStereoOffset
  aSyncIn init 0
  aMainPhasor1,aSyncOut1 syncphasor kPhasorSpeed1,aSyncIn
  aMainPhasor2,aSyncOut2 syncphasor kPhasorSpeed2,aSyncIn,iOff1

  // phase distortion
  aPhaseDst1 tablei aMainPhasor1, iPhaseDistTable, 1
  aPhaseDst2 tablei aMainPhasor2, iPhaseDistTable, 1

  // soundfile table
  kStart = kLoopStart * iSndflSamps
  kSize1 = (k(aSyncOut1) == 1 ? kSize : kSize1)
  kSize2 = (k(aSyncOut2) == 1 ? kSize : kSize2)
  kStart1 = (k(aSyncOut1) == 1 ? kStart : kStart1)
  kStart2 = (k(aSyncOut2) == 1 ? kStart : kStart2)
  aSndfl1 table3 (aPhaseDst1 * kSize1)+kStart1,iSndflTbl1,0,0,1
  aSndfl2 table3 (aPhaseDst2 * kSize2)+kStart2,iSndflTbl2,0,0,1

  // window table
  aWin1 table3 aMainPhasor1,iWndwFt,1
  aWin2 table3 aMainPhasor2,iWndwFt,1
  aOut1 = aWin1*aSndfl1
  aOut2 = aWin2*aSndfl2

  // masking
  kMaskArr1[],kMaskArr2[] deinterleave kMaskArr
  kMaskCount1 init 0
  kMaskCount2 init 0
  kMaskCount1 = (k(aSyncOut1) == 1 ? kMaskCount1+1 : kMaskCount1)
  kMaskCount1 = kMaskCount1 % lenarray:i(kMaskArr1)
  kMaskCount2 = (k(aSyncOut2) == 1 ? kMaskCount2+1 : kMaskCount2)
  kMaskCount2 = kMaskCount2 % lenarray:i(kMaskArr2)
  aOut1 = aOut1*kMaskArr1[kMaskCount1]
  aOut2 = aOut2*kMaskArr2[kMaskCount2]

  ;; output
  xout aOut1, aOut2
  ;; by philipp von neumann
endop

opcode linear_scaling, i, iiiii
  iInValue, iInMin, iInMax, iOutMin, iOutMax xin

  iFraction = ((iInValue - iInMin) / (iInMax - iInMin))
  iOutValue = iOutMin + iFraction * (iOutMax - iOutMin)

  xout iOutValue
endop

opcode extend_array, i[], i[]i
  iInputArray[], iFinalLength xin

  iOutArray[] init iFinalLength

  iReadCnt init 0
  iWriteCnt init 0
  while (iWriteCnt < iFinalLength) do
	iValue = iInputArray[iReadCnt % lenarray(iInputArray)]
	iOutArray[iWriteCnt] = iValue
	iReadCnt += 1
	iWriteCnt += 1
  od
  
  xout iOutArray
endop

opcode changek, k, k
  kIn xin

  ;; the differnce from the actual k value and the k value delayed by
  ;; iSampleTime is kChange
  iSampleTime = 0.1
  kPrevious delayk  kIn, iSampleTime
  kChange  = kIn - kPrevious
  
  xout abs(kChange)
endop