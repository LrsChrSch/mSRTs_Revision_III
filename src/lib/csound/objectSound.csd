giObjectCount init 0

instr objectSoundTrig
  // browser data
  iScaleOffset = i(gkScaleOffset)
  iRotationRange = i(gkRotationRange)
  iMatrixCount = i(gkMatrixCount)
  iTransformMin_x = i(gkTransformMin_x)
  iTransformMin_y = i(gkTransformMin_y)
  iTransformMin_z = i(gkTransformMin_z)
  iTransformMax_x = i(gkTransformMax_x)
  iTransformMax_y = i(gkTransformMax_y)
  iTransformMax_z = i(gkTransformMax_z)
  
  // translate transformMin_x data to a scale structure 
  S_TransformMin_x sprintf"%f", iTransformMin_x
  S_TransformMin_x strsub S_TransformMin_x, 2, -1
  iStructureMin_x[] init strlen:i(S_TransformMin_x)
  iCntMinX init 0
  while (strlen:i(S_TransformMin_x) > 0) do
	S_CharMin_x strsub S_TransformMin_x, 0, 1
	iValue = strtol:i(S_CharMin_x)
	if (iValue != 0.0) then
	  iStructureMin_x[iCntMinX] = iValue
	endif
	iCntMinX += 1
	S_TransformMin_x strsub S_TransformMin_x, 1, -1
  od

  // translate transformMin_y data to amplitude data
  S_TransformMin_y sprintf "%f", iTransformMin_y
  S_TransformMin_y strsub S_TransformMin_y, 2, -1
  iAmpMin_y[] init strlen:i(S_TransformMin_y)
  iCntMinY init 0
  while (strlen:i(S_TransformMin_y) > 0) do
	S_CharMin_y strsub S_TransformMin_y, 0, 1
	iValue = strtol:i(S_CharMin_y)
	if (iValue != 0.0) then
	  iAmpMin_y[iCntMinY] = iValue / 10 
	endif
	iCntMinY += 1
	S_TransformMin_y strsub S_TransformMin_y, 1, -1
  od

  // translate transformMin_z data to effect send amount
  S_TransformMin_z sprintf "%f", iTransformMin_z
  S_TransformMin_z strsub S_TransformMin_z, 2, -1
  iEffectSendMin_z[] init strlen:i(S_TransformMin_z)
  iCntMinZ init 0
  while (strlen:i(S_TransformMin_z) > 0) do
	S_CharMin_z strsub S_TransformMin_z, 0, 1
	iValue = strtol:i(S_CharMin_z)
	if (iValue != 0.0) then
	  iEffectSendMin_z[iCntMinZ] = iValue / 10 
	endif
	iCntMinZ += 1
	S_TransformMin_z strsub S_TransformMin_z, 1, -1
  od

  // translate transformMax_x data to a scale structure 
  S_TransformMax_x sprintf "%f", iTransformMax_x
  S_TransformMax_x strsub S_TransformMax_x, 2, -1
  iStructureMax_x[] init strlen:i(S_TransformMax_x)
  iCntMaxX init 0
  while (strlen:i(S_TransformMax_x) > 0) do
	S_CharMax_x strsub S_TransformMax_x, 0, 1
	iValue = strtol:i(S_CharMax_x)
	if (iValue != 0.0) then
	  iStructureMax_x[iCntMaxX] = iValue
	endif
	iCntMaxX += 1
	S_TransformMax_x strsub S_TransformMax_x, 1, -1
  od

  // translate transformMax_y data to amplitude data
  S_TransformMax_y sprintf "%f", iTransformMax_y
  S_TransformMax_y strsub S_TransformMax_y, 2, -1
  iAmpMax_y[] init strlen:i(S_TransformMax_y)
  iCntMaxY init 0
  while (strlen:i(S_TransformMax_y) > 0) do
	S_CharMax_y strsub S_TransformMax_y, 0, 1
	iValue = strtol:i(S_CharMax_y)
	if (iValue != 0.0) then
	  iAmpMax_y[iCntMaxY] = iValue / 10 
	endif
	iCntMaxY += 1
	S_TransformMax_y strsub S_TransformMax_y, 1, -1
  od

  // translate transformMax_z data to effect send amount
  S_TransformMax_z sprintf "%f", iTransformMax_z
  S_TransformMax_z strsub S_TransformMax_z, 2, -1
  iEffectSendMax_z[] init strlen:i(S_TransformMax_z)
  iCntMaxZ init 0
  while (strlen:i(S_TransformMax_z) > 0) do
	S_CharMax_z strsub S_TransformMax_z, 0, 1
	iValue = strtol:i(S_CharMax_z)
	if (iValue != 0.0) then
	  iEffectSendMax_z[iCntMaxZ] = iValue / 10 
	endif
	iCntMaxZ += 1
	S_TransformMax_z strsub S_TransformMax_z, 1, -1
  od
  
  // set data
  iStructure1[] = iStructureMin_x
  iStructure2[] = iStructureMax_x

  iScaleDivision1 = iMatrixCount^2; * iRotationRange
  iScaleDivision2 = iMatrixCount^2; * iScaleOffset
  iRoot = giRoot * iMatrixCount
  iOctDown = 0
  iOctUp = 2
  iFreqs1[] structure_to_scale iScaleDivision1, iStructure1, iRoot,\
    iOctDown, iOctUp
  iFreqs2[] structure_to_scale iScaleDivision2, iStructure2, iRoot,\
    iOctDown, iOctUp
  iOffsets1[] array_offsets iFreqs1, 0.005
  iOffsets2[] array_offsets iFreqs2, 0.005
  
  // final signal data 
  iNoteSelection1[] = interleave(iFreqs1, iOffsets1) 
  iNoteSelection2[] = interleave(iFreqs2, iOffsets2)
  iNumOfNotes = lenarray(iNoteSelection1)
  iAmps1[] = extend_array(iAmpMin_y, iNumOfNotes)
  iAmps2[] = extend_array(iAmpMax_y, iNumOfNotes)
  iEffectSendAmount1[] = extend_array(iEffectSendMin_z, iNumOfNotes)
  iEffectSendAmount2[] = extend_array(iEffectSendMax_z, iNumOfNotes)

  // choose effect send
  iEffectSendArr[] = fillarray(0, 1, 2, 1, 0, 2)
  iEffectCnt = giObjectCount % lenarray(iEffectSendArr)
  iChooseEffectSend = iEffectSendArr[iEffectCnt]
  
  // call synth
  iGain = db(-36)
  iCnt init 0
  while (iCnt < iNumOfNotes) do
	schedule("objectSoundSig", 0, 60, iNoteSelection1[iCnt], \
	  iNoteSelection2[iCnt], iAmps1[iCnt], iAmps2[iCnt],\
	  iEffectSendAmount1[iCnt], iEffectSendAmount2[iCnt], \
	  iChooseEffectSend, iGain)  
	iCnt += 1
  od
  giObjectCount += 1
  turnoff 
endin

instr objectSoundSig
  // p-field data
  iFreqStart = p4
  iFreqEnd = p5
  iAmpStart = p6
  iAmpEnd = p7
  iEffectSendAmountStart = p8
  iEffectSendAmountEnd = p9
  iChooseEffectSend = p10
  iGain = p11
  
  // signal
  aFreq = line(iFreqStart, p3, iFreqEnd)
  aAmp = line(iAmpStart, p3, iAmpEnd)
  aSig = poscil3(aAmp, aFreq) 
  aSig *= iGain

  // camera distance mod
  aSig *= 1 - db(gkCameraDb) ; amplitude mod
  ;; filter mod
  kCf = 17000 - (gkCameraDistance * 10500)
  aSig = butterlp(aSig, kCf) 
  ;; reverb send mod 
  kDistanceRev = 1 - db(gkCameraDb)
  gaReverbBus[0] = (kDistanceRev * aSig) + gaReverbBus[0]
  gaReverbBus[1] = (kDistanceRev * aSig) + gaReverbBus[1]

  
  // envelope
  iAtt = random:i(1, 2)
  iRel = iAtt
  iSusTime = p3 - (iAtt + iRel)
  aEnv linsegr 0, iAtt, 1, iSusTime, 1, iRel, 0
  aSig *= aEnv

  // panning
  aSig1, aSig2 pan2 aSig, random:i(0,1) 

  // effect send
  aEffectSendAmount = line(iEffectSendAmountStart, p3, iEffectSendAmountEnd)
  if (iChooseEffectSend == 0) then 
	// reverb send
	gaReverbBus[0] = (aEffectSendAmount * aSig1) + gaReverbBus[0]
	gaReverbBus[1] = (aEffectSendAmount * aSig2) + gaReverbBus[1]
  elseif (iChooseEffectSend == 1) then
	// delay send
	gaDelBus[0] = (aEffectSendAmount * aSig1) + gaDelBus[0]
	gaDelBus[1] = (aEffectSendAmount * aSig2) + gaDelBus[1]
  elseif (iChooseEffectSend == 2) then 
	// resonatore send
	gaResonatorBus[0] = (aEffectSendAmount * aSig1) + gaResonatorBus[0]
	gaResonatorBus[1] = (aEffectSendAmount * aSig2) + gaResonatorBus[1]
  endif 

  // master send
  gaMasterBus[0] = gaMasterBus[0] + ((1 - aEffectSendAmount) * aSig1)
  gaMasterBus[1] = gaMasterBus[1] + ((1 - aEffectSendAmount) * aSig2)
endin

instr objectSoundKill
  turnoff2("objectSoundSig", 0, 1)
  turnoff
endin
