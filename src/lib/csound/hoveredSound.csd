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
