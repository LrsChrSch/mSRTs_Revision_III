// This component handles all sound functions and stores the sound state
// It serves as an adapter between the Csound API and the rest of the app
// functions like volume control and events are defined here and get executed from other modules

import { browser } from "$app/environment";
import csd from '$lib/csound/main.csd?raw'
import helper from '$lib/csound/helper.udo?raw'
import additivStruct from '$lib/csound/additivStruct.csd?raw'
import subBeatings from '$lib/csound/subBeatings.csd?raw'
import type { CsoundObj } from "@csound/browser";
let Csound: typeof import("@csound/browser").Csound;


class SoundAdapter {
    csound: CsoundObj | undefined;

    soundPaused = $state(false);

    async toggleSound() {
        this.soundPaused = !this.soundPaused;
        if (this.csound) {
            if (this.soundPaused) {
                this.csound.pause();
            } else {
                if (await this.csound.getScoreTime() === 0) { // this is the case, if a user has turned the sound off before entering. In that case we need to start the sound here for the first time.
                    await this.csound.start();
                } else {

                    this.csound.resume();
                }
            }
        }
    }

    async prepareSound() {
        // Csound throws an error when using it on the server side, so we only import it on the client
        if (browser) {
            ({ Csound } = await import("@csound/browser"));
        }

        if (this.csound) return;

        this.csound = await Csound({ useWorker: true, }); // useWorker, so it runs in a separate thread, inputChannelCount: 0, so it doesn't expect any input

        // console.log(csound)

        // await csound?.setOption("-m0");

        const encoder = new TextEncoder();
        const helperBinary = encoder.encode(helper);
        await this.csound?.fs.writeFile("helper.udo", helperBinary);
        const additivStructBinary = encoder.encode(additivStruct);
        await this.csound?.fs.writeFile("additivStruct.csd", additivStructBinary);
        const subBeatingsBinary = encoder.encode(subBeatings);
        await this.csound?.fs.writeFile("subBeatings.csd", subBeatingsBinary);


        const filePaths = await this.csound?.fs.readdir("/");
        console.log("Csound File System:", filePaths);
        await this.csound?.compileCsdText(csd);
    }

    async startSound() {
        const csoundContext = await this.csound?.getAudioContext();
        csoundContext?.resume(); // since the browser blocks the audioContext from starting automatically, we need to resume it here on a use action

        if (!this.soundPaused) { // check if the user has turned the sound off before entering the page
            await this.csound?.start();
        }

        // you can add some initial sound interaction here, too
    }

    async cursorPosXHandler(value: number) {
        // value is a number between 0 and 1 (left-right screen position)
        await this.csound?.setControlChannel('cursorPosXHandler', value);
    }

    async cursorPosYHandler(value: number) {
        // value is a number between 0 and 1 (top-bottom screen position)
        await this.csound?.setControlChannel('cursorPosYHandler', value);
    }

    async transitionStartedInteraction() {
        // this gets called when the user clicks on one of the image cards around the origin
        // TODO: implement sound here
        // Example: 
        // await this.csound?.evalCode(`
        //   schedule("Flourish", next_time(.25), 0, 0)
        // `)
		await this.csound?.evalCode(`schedule("transitionSound", 0, 2.75)`);
    }

    async transitionFinishedInteraction() {
        // this gets called when the transition to the next sculpture is finished
        // this also gets called once at the very beginning

    }

    async loadSculptureInteraction(value: number) {
        // this function handles both the index (value) (0-319) and the data of the sculpture
        const jsonData = await fetch(`/data/${value}Data.json`).then(async (res) => {
            return await res.json();
        });

        // console.log("Sculpture Data", jsonData)

        // jsonData contains the following values:
        // jsonData.matrixCount (int 3-5)
        // jsonData.scaleOffset (float 0-1)
        // jsonData.rotationRange (int 0-1)
        // jsonData.transformMin (object with x, y, z values)
        // jsonData.transformMax (object with x, y, z values)
        // jsonData.seed (int)
    }

    async cameraDistanceHandler(value: number) {
        // value is a number between 0 and 1 (distance from the camera to the origin, 1 is the furthest away)
    }

    async surroundingHoverInteraction(value: number) {
        // this function gets called when the user hovers over one of the image cards around the origin
        // index is the sculpture index (0-319). Index is -1 if nothing is hovered

        // console.log(value)

        // just in case you need a boolean value for the hovered state
        // let hovered = value !== -1;
    }

    async globalPositionHandler(x: number, y: number, z: number) {
        // x, y, z are the (animated) origin position values in the global coordinate system, normalized to -1 and 1 (linearly interpolated and clamped from -100 and 100)
        // this also shows the position on the 3 axis
        // -x: emergent
        // +x: constructed
        // -y: infra
        // +y: meta
        // -z: signal
        // +z: noise
        // first value is 0,0,0

        // console.log("Global Position", x, y, z)
    }

    async interactionAmountHandler(value: number) {
        // value is a number between 0 and 1 (amount of interactions up to the max of 24)
        // gets initialized with 0 at the start
    }

    async sculptureInstanceAmountHandler(value: number) {
        // the value is an integer value around ~200000
        // it gets called every time a sculpture is loaded (approx. 750ms after an interaction) and reflects the amount of tiny cubes that are visible
    }


    async disposeSound() {
        await this.csound?.stop();
        await this.csound?.cleanup();
        await this.csound?.destroy();
        this.csound = undefined;
    }
}

export const soundAdapter = new SoundAdapter();
