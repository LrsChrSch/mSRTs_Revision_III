// additiv bandpass noise
instr additivNoise
  iChordsRoot[] = fillarray(0, -7, -12, 3, 7, 11) 
  iNumOfChords = lenarray(iChordsRoot)

  //
  iCnt init 0
  while (iCnt < iNumOfChords) do
  schedule("additivNoiseScales", 0, 1, iNumOfChords, iChordsRoot[iCnt]) 
	iCnt += 1
  od
endin

instr additivNoiseScales
  iMajorScale[] fillarray 60, 62, 64, 65, 67, 69, 71
  iMinorScale[] fillarray 60, 62, 63, 65, 67, 68, 70
  iNotes1[] pick_rand_notes iMajorScale, 5, 5, 6
  iNotes2[] pick_rand_notes iMinorScale, 5, 5, 6 
  iNotes1 += p5
  iNotes2 += p5
  iFreqs1[] array_mtof iNotes1
  iFreqs2[] array_mtof iNotes2
  iOffsets1[] array_offsets iFreqs1, 1.
  iOffsets2[] array_offsets iFreqs2, 1.
  iNoteSelection1[] interleave iFreqs1, iOffsets1
  iNoteSelection2[] interleave iFreqs2, iOffsets2

  iCnt init 0

  call_synth:
  schedule "20240910_additivNoise_signal", 0, 60*30, (1 / lenarray(iNoteSelection1)) / p4, \
    iNoteSelection1[iCnt], iNoteSelection2[iCnt]
  iCnt += 1
  if iCnt < lenarray(iNoteSelection1) igoto call_synth
endin

instr 20240910_additivNoise_signal
  aNoise noise 1, 0
  kBw randomi 1, linseg:k(10, p3/2, 1, p3/2, 20), 1
  kFreq = line:a(p5, p3, p6)
  aSig butterbp aNoise, kFreq, kBw

  // panning
  aOut1, aOut2 pan2 aSig, randomi:k(0, 1, 1)

  // output 
  outs aOut1, aOut2
endin
