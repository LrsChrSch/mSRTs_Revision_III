// This component handles all sound functions and stores the sound state
// It serves as an adapter between the Csound API and the rest of the app
// functions like volume control and events are defined here and get executed from other modules

import { browser } from "$app/environment";
import csd from '$lib/csound/main.csd?raw'
import helper from '$lib/csound/helper.udo?raw'
import additivStruct from '$lib/csound/additivStruct.csd?raw'
import type { CsoundObj } from "@csound/browser";

let Csound: typeof import("@csound/browser").Csound;
let csound: CsoundObj | undefined;

class SoundAdapter {
    soundPaused = $state(false);

    async toggleSound() {
        this.soundPaused = !this.soundPaused;
        if (csound) {
            if (this.soundPaused) {
                csound.pause();
            } else {
                if (await csound.getScoreTime() === 0) { // this is the case, if a user has turned the sound off before entering. In that case we need to start the sound here for the first time.
                    await csound.start();
                } else {

                    csound.resume();
                }
            }
        }
    }

    async prepareSound() {
        // Csound throws an error when using it on the server side, so we only import it on the client
        if (browser) {
            ({ Csound } = await import("@csound/browser"));
        }

        if (csound) return;

        csound = await Csound({ useWorker: true, inputChannelCount: 0 }); // useWorker, so it runs in a separate thread, inputChannelCount: 0, so it doesn't expect any input

        // console.log(csound)

        await csound?.setOption("-m0");

        const encoder = new TextEncoder();
        const helperBinary = encoder.encode(helper);
        await csound?.fs.writeFile("helper.udo", helperBinary);
        const additivStructBinary = encoder.encode(additivStruct);
        await csound?.fs.writeFile("additivStruct.csd", additivStructBinary);

        const filePaths = await csound?.fs.readdir("/");
        console.log("Csound File System:", filePaths);
        await csound?.compileCsdText(csd);
    }

    async startSound() {
        const csoundContext = await csound?.getAudioContext();
        csoundContext?.resume(); // since the browser blocks the audioContext from starting automatically, we need to resume it here on a use action

        if (!this.soundPaused) { // check if the user has turned the sound off before entering the page
            await csound?.start();
        }

    }

    async additivStructFreqPosition(value: number) {
        await csound?.setControlChannel('additivStruct.freqPosition', value);
    }

    async additivStructFiltCf(value: number) {
        await csound?.setControlChannel('additivStruct.filtCf', value);
    }

    async disposeSound() {
        await csound?.stop();
        await csound?.cleanup();
        await csound?.destroy();
        csound = undefined;
    }
}

export const soundAdapter = new SoundAdapter();
