// this file manages all the global stores
// they are used to store reactive state across different components
// for example: the surroundingCard component updates the origin and the sculpture uses that info to animate itself

import { soundAdapter } from '$lib/csound.svelte';
import { writable } from 'svelte/store'

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


function createSculptureIndexStore() {

    let index: number = $state(Math.floor(Math.random() * 320))

    return {
        get index() { return index },
        set: async (newIndex: number) => {
            // load the data from /data/{index}Data.json
            soundAdapter.loadSculptureInteraction(newIndex)
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




