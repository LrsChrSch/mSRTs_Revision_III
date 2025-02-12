// This component handles all sound functions and stores the sound state
// It serves as an adapter between the Csound API and the rest of the app
// functions like volume control and events are defined here and get executed from other modules

import { Csound, type CsoundObj } from "@csound/browser";
import csd from '$lib/csound/main.csd?raw'
import helper from '$lib/csound/helper.udo?raw'
import additivStruct from '$lib/csound/additivStruct.csd?raw'

let csound: CsoundObj | null | undefined = null;


function createSoundPauseStore() {
    let paused = $state(false)

    return {
        get paused() { return paused },
        toggle: () => {
            paused = !paused
            // console.log(paused)
            if (csound) {
                if (paused) {
                    csound.pause();
                } else {
                    // check if it hasn't started yet
                    csound.resume();
                }
            }
        }
    }
}
export const soundPaused = createSoundPauseStore()


export async function startSound() {
    if (csound) return;
    csound = await Csound();
    if (!csound) return;
    // console.log(csound)

    await csound.setOption("-m0");

    const encoder = new TextEncoder();
    const helperBinary = encoder.encode(helper);
    await csound.fs.writeFile("helper.udo", helperBinary);
    const additivStructBinary = encoder.encode(additivStruct);
    await csound.fs.writeFile("additivStruct.csd", additivStructBinary);
    await csound.compileCsdText(csd);


    if (soundPaused.paused) {
        csound.pause();
    }
    await csound.start();
}

export async function flourish() {
    if (!csound) return;
    await csound.evalCode(`schedule("Flourish", next_time(.25), 0, 0)`)
}

export async function volumeControl(volume: number) {
    if (!csound) return;
    await csound.setControlChannel('main.note.amp', volume)
}

export async function disposeSound() {
    if (!csound) return;
    await csound.stop();
    await csound.cleanup();
    await csound.destroy();
}

export type CsoundModule = {
    startSound: () => Promise<void>;
    flourish: () => Promise<void>;
    disposeSound: () => Promise<void>;
    volumeControl: (volume: number) => Promise<void>;
    soundPaused: {
        paused: boolean;
        toggle: () => void;
    };
} | undefined;
