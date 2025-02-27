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

instr additivStructSig
  // get data from browser
  kCutOff = gkAdditivStructFiltCf

  // freq table
  aFreq = line(p5, p3, p6)
  
  // signal
  aSig = poscil3(p4, aFreq) 

  // envelope
  iAtt = random:i(0.25, 2)
  iRel = iAtt
  iSusTime = p3 - (iAtt + iRel)
  aEnv linseg 0, iAtt, 1, iSusTime, 1, iRel, 0
  aSig *= aEnv

  // filter
  aSig = butterlp(aSig, 60 + ((1 - kCutOff) * 200))
  
  // panning
  aOut1, aOut2 pan2 aSig, random:i(0,1) 

  // reverb bus 
  gaReverbBus[0] = gaReverbBus[0] + (aOut1 * 0.5)
  gaReverbBus[1] = gaReverbBus[1] + (aOut2 * 0.5)
  
  // send to master
  gaMasterBus[0] = gaMasterBus[0] + aOut1
  gaMasterBus[1] = gaMasterBus[1] + aOut2
endin
