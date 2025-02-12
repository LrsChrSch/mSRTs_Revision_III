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
endin

instr additivStructSig
  // signal
  aSig poscil3 p4, line:a(p5,p3,p6), giSine

  // envelope
  iAtt = random:i(p3/16, p3/8)
  iRel = iAtt / 2
  iSusTime = p3 - (iAtt + iRel)
  aEnv linseg 0, iAtt, 1, iSusTime, 1, iRel, 0
  aSig *= aEnv

  // panning
  aOut1, aOut2 pan2 aSig, random:i(0,1) 

  // output 
  outs aOut1, aOut2
endin
