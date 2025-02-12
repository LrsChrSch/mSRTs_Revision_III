// start of the csound code
<CsoundSynthesizer>

<CsOptions>
// this section tells Csound how to interact with various devices and hardware
-o dac --port=10000
</CsOptions>

<CsInstruments>
sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

#include "testHelper.udo"


</CsInstruments>  

<CsScore>
// call instrument 1 in sequence
i 1 0 3 0.1 440
i 1 3 3 0.2 550
// call instrument 1 simultaneously
i 1 7 3 0.1 550
i 1 7 3 0.1 660

</CsScore>

</CsoundSynthesizer>
// end of the Csound code
