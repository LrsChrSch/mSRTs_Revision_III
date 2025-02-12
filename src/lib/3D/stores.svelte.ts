// this file manages all the global stores
// they are used to store reactive state across different components
// for example: the surroundingCard component updates the origin and the sculpture uses that info to animate itself

import { cubicInOut } from 'svelte/easing'
import { Tween } from 'svelte/motion'
import { writable } from 'svelte/store'

export const maxRange = 100;
export const horizon = 200;

function createLinePointsStore() {
    const { subscribe, update } = writable([
        0, 0, 0
    ])

    return {
        subscribe,
        addPoints: (point: number[]) => {
            update(points => {
                points.push(...point)
                return points
            })
        }
    }
}
export const linePoints = createLinePointsStore()


function createSculptureSizeStore() {
    let size = $state(0)

    return {
        get size() { return size },
        set: (newSize: number) => size = newSize
    }
}
export const sculptureSize = createSculptureSizeStore()


function createOriginStore() {
    let origin: [x: number, y: number, z: number] = $state([0, 0, 0])

    return {
        get origin() { return origin },
        set: (newOrigin: [x: number, y: number, z: number]) => origin = newOrigin
    }
}
export const origin = createOriginStore()


async function generateSculptureName(index: number) {
    fetch(`/data/${index}Data.json`).then(async (res) => {
        type Data = {
            matrixCount: number;
            scaleOffset: number;
            rotationRange: number;
            transformMin: {
                x: number;
                y: number;
                z: number;
            };
            transformMax: {
                x: number;
                y: number;
                z: number;
            };
            seed: number;
        };
        const data: Data = await res.json();
        // the goal is to create a title for the sculpture based on this data
        // each numeric value will be reduced to the first 3 values after the decimal point
        // the numbers will be arranged with short string inbetween like this:
        // C{matrixCount}S{scaleOffset}R{rotationRange}T{length of the vector from transformMin to transformMax}S{seed}
        // example: C5S0.5R90T-1.5|1.5|-1.5S12345

        const length = Math.sqrt(
            Math.pow(data.transformMax.x - data.transformMin.x, 2) +
            Math.pow(data.transformMax.y - data.transformMin.y, 2) +
            Math.pow(data.transformMax.z - data.transformMin.z, 2)
        )
        let title = `C${data.matrixCount} S${data.scaleOffset.toFixed(3)} R${data.rotationRange.toFixed(3)} T${length.toFixed(3)} I${index}`
        // replace all "0." with ""
        title = title.replace(/0\./g, "")
        word.set(title)
    })

}

function createWordStore() {
    let word: string = $state("")

    return {
        get word() { return word },
        set: (newWord: string) => word = newWord
    }
}
export const word = createWordStore()



export const textSlicer = new Tween(1, {
    duration: 500,
    delay: 500,
    easing: cubicInOut
});
export const lineSlicer = new Tween(1, {
    duration: 500,
    easing: cubicInOut
});


function createSculptureIndexStore() {

    let index: number = $state(0)

    return {
        get index() { return index },
        set: async (newIndex: number) => {
            // load the data from /data/{index}Data.json

            generateSculptureName(newIndex)
            index = newIndex
        }
    }
}
export const sculptureIndex = createSculptureIndexStore()


function createInvalidateSurroundingStore() {
    let num = $state(0)

    return {
        get get() { return num },
        invaldiate: () => num++
    }
}
export const invalidateSurrounding = createInvalidateSurroundingStore()