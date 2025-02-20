// This file stores all of the information relevant to render the correct data on the surroundingCards


import texts from '$lib/data/texts.json'
import { origin, } from './stores.svelte';
import { createNoise3D } from 'simplex-noise';
import { soundAdapter } from '$lib/csound.svelte';


export const numPoints = 24;

const interactionsClamp = 20;
let noise3D = createNoise3D();


function createInteractionsStore() {
    let interactions = $state(0)

    soundAdapter.interactionAmountHandler(0)

    return {
        get num() { return interactions },
        add: () => {
            interactions++
            soundAdapter.interactionAmountHandler(interactions / interactionsClamp)
        }
    }
}
export let interactions = createInteractionsStore()


function fibonacciSphere(samples: number) {
    const points = [];
    const phi = Math.PI * (Math.sqrt(5) - 1);
    for (let i = 0; i < samples; i++) {
        const y = 1 - (i / (samples - 1)) * 2;
        const radius = Math.sqrt(1 - y * y);

        const theta = phi * i;

        points.push([Math.cos(theta) * radius, y, Math.sin(theta) * radius]);
    }

    return points;
}


function chooseTexts(texts: { message: string; sn: number; mi: number; ec: number }[]) {
    // Choose a random text from the array
    const clampedOrigin = origin.origin.map(coord => Math.max(-1, Math.min(1, coord / 100)));
    //console.log(clampedOrigin);

    // x axis relates to ec, y axis to mi and z axis to sn
    // we will cosine distance to find the closest text to the origin
    // the closer the origin is to the text, the more likely it is to be chosen randomly
    // step 1: calculate the cosine distance between the origin and each text
    // step 2: normalize the distances so that they sum to 1
    // step 3: choose a random number between 0 and 1
    // step 4: iterate through the normalized distances until the sum of the distances is greater than the random number
    // step 5: return the text that corresponds to the distance that was greater than the random number

    const distances = texts.map(text => {
        const textCoords = [text.ec, text.mi, text.sn];
        const sum = Math.sqrt(textCoords.reduce((acc, coord, i) => acc + Math.pow(coord - clampedOrigin[i], 2), 0));
        return sum;
    });

    // Invert distances
    const maxDistance = Math.max(...distances);
    const invertedDistances = distances.map(distance => maxDistance - distance);

    const sum = invertedDistances.reduce((acc, distance) => acc + distance, 0);
    const normalizedDistances = invertedDistances.map(distance => distance / sum);

    const random = Math.random();
    let sumDistances = 0;
    for (let i = 0; i < normalizedDistances.length; i++) {
        sumDistances += normalizedDistances[i];
        if (sumDistances > random) {
            //console.log(texts[i].message);
            return texts[i];
        }
    }

    // Just in case the sum of the distances is less than 1, return a random text
    return texts[Math.floor(Math.random() * texts.length)];

}

let usedImgIndeces: number[] = [];

function map(x: number, fromMin: number, fromMax: number, toMin: number, toMax: number, clamp: boolean = false) {
    let mappedValue = (x - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin;
    if (clamp) {
        if (mappedValue < toMin) return toMin;
        if (mappedValue > toMax) return toMax;
    }
    return mappedValue;
}


function generatePointData() {
    usedImgIndeces = [];

    // copy the texts and bigTexts arrays so we can modify them
    let textsCopy = texts.slice();

    // Calculate distance from origin
    const distanceFromOrigin = Math.sqrt(
        Math.pow(0 - origin.origin[0], 2) +
        Math.pow(0 - origin.origin[1], 2) +
        Math.pow(0 - origin.origin[2], 2)
    );

    // Determine the chance of being 'none' type
    let noneChance = 0.1;
    if (distanceFromOrigin >= 100) {
        noneChance = Math.min(1, 0.1 * Math.exp((distanceFromOrigin - 100) / 100));
    }

    console.log('noneChance', noneChance);

    // console.log(textsCopy.length, bigTextsCopy.length);

    let containsImage = false;

    let pointData = fibonacciSphere(numPoints).map((point) => {
        const noiseScale = 15;
        let noiseValue = noise3D(
            (point[0] + origin.origin[0]) * noiseScale,
            (point[1] + origin.origin[1]) * noiseScale,
            (point[2] + origin.origin[2]) * noiseScale);
        // convert noiseValue from -1-1 to 0-1
        noiseValue = (noiseValue + 1) / 2;



        let type = 'image';
        if (noiseValue < noneChance) {
            type = 'none';
            console.log("None triggered")
        } else if (noiseValue > map(interactions.num, 0, interactionsClamp, 0.5, 0.7, true)) {
            type = 'text';
        }

        if (type === 'image') containsImage = true;

        // choose random image without duplication
        let index = 0;
        do {
            index = Math.floor(Math.random() * 320);
        } while (usedImgIndeces.includes(index));
        usedImgIndeces.push(index);

        let text = chooseTexts(textsCopy);
        // remove the text from the array so it can't be chosen again
        textsCopy = textsCopy.filter(t => t !== text);

        return {
            position: point,
            type: type,
            text: type === 'none' ? '' : text.message,
            index: index,
        }
    });

    if (!containsImage) {
        // set all points to text and give them the same text "void"
        // do not change the index
        console.log("Reached End")
        soundAdapter.reachedEndInteraction();
        pointData = pointData.map(point => {
            return {
                ...point,
                type: 'text',
                text: 'void',
            }
        })
    }

    return pointData;
}


function createPointDataStore() {
    let pointData: { index?: number; position: number[]; type: string, text?: string }[] = $state([])


    return {
        get data() { return pointData },
        regenerate: async () => {
            pointData = generatePointData()
        },
        clear: () => pointData = []
    }
}
export let pointData = createPointDataStore()

