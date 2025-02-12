instr 1
  // get p4 from the score line as amplitude
  iAmp = p4
  // get p5 from the score line as frequency
  iFreq = p5
  // settings for madsr envelope
  iAtt, iDec, iSus, iRel = 0.1, 0.4, 0.6, 0.7
  // create envelope with madsr opcode
  kEnv = madsr:k(iAtt,iDec,iSus,iRel)
  // set the cutoff frequency and the resonance
  iCutoff, iRes = 5000, 0.4
  // sawtooth tone 
  aVco = vco2:a(iAmp,iFreq)
  // moogladder low pass filter with variable cutoff frequency
  aLp = moogladder:a(aVco,iCutoff*kEnv,iRes)
  // apply envelope by multiplication and output to all channels
  outall(aLp*kEnv)
endin