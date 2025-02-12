<script lang="ts">
	// This component shows the 2D cards that follow the viewer around
	// It handles the display of both text and images
	// It also handles all the interactions with the cards and the animation that triggers

	import { Billboard, ImageMaterial, Text, useCursor } from '@threlte/extras';
	import * as THREE from 'three';
	import {
		invalidateSurrounding,
		linePoints,
		lineSlicer,
		origin,
		sculptureIndex,
		textSlicer
	} from './stores.svelte';
	import { Tween } from 'svelte/motion';
	import { T } from '@threlte/core';
	import { cubicInOut } from 'svelte/easing';
	import { onMount } from 'svelte';
	import type { CsoundModule } from '$lib/csound.svelte';
	import { browser } from '$app/environment';
	import { writable } from 'svelte/store';
	import { interactions, pointData } from './pointData.svelte';

	const { animationIndex, index, position, type, text } = $props();

	const onPointerOverCursor = writable('auto');
	const { hovering, onPointerEnter, onPointerLeave } = useCursor(onPointerOverCursor);
	const distance = 15;

	const size = new Tween(1, {
		duration: 500,
		delay: animationIndex * 20,
		easing: cubicInOut
	});
	const opacity = new Tween(1, {
		duration: 500,
		easing: cubicInOut
	});

	$effect(() => {
		if ($hovering && type === 'image') {
			opacity.target = 1;
			onPointerOverCursor.set('pointer');
		} else if (type === 'bigText' || type === 'text') {
			opacity.target = 0.75;
			onPointerOverCursor.set('auto');
		} else {
			opacity.target = 0.25;
			onPointerOverCursor.set('auto');
		}
	});

	let module: CsoundModule = $state();
	onMount(async () => {
		if (browser) module = await import('$lib/csound.svelte');
	});

	$effect(() => {
		if (origin.origin) size.target = 0;
		if (invalidateSurrounding.get) size.target = 0;
		// wait 2 seconds, then set the size.target back to 1
		setTimeout(() => {
			size.target = 1;
		}, 2000);
	});
</script>

{#if size.current !== 0}
	<Billboard
		onpointerenter={onPointerEnter}
		onpointerleave={onPointerLeave}
		onclick={(
			e: THREE.Intersection & {
				intersections: THREE.Intersection[]; // The first intersection of each intersected object
				object: THREE.Object3D; // The object that was actually hit
				eventObject: THREE.Object3D; // The object that registered the event
				camera: THREE.Camera; // The camera used for raycasting
				delta: THREE.Vector2; //  Distance between mouse down and mouse up event in pixels
				nativeEvent: MouseEvent | PointerEvent | WheelEvent; // The native browser event
				pointer: THREE.Vector2; // The pointer position in normalized device coordinates
				ray: THREE.Ray; // The ray used for raycasting
				stopPropagation: () => void; // Function to stop propagation of the event
				stopped: boolean; // Whether the event propagation has been stopped
			}
		) => {
			e.stopPropagation();
			if (type !== 'image') return;
			if (module) module.flourish();

			const newOrigin: [x: number, y: number, z: number] = [
				e.eventObject.position.x + origin.origin[0],
				e.eventObject.position.y + origin.origin[1],
				e.eventObject.position.z + origin.origin[2]
			];
			interactions.add();

			linePoints.addPoints(newOrigin);
			origin.set(newOrigin);

			textSlicer.set(0, {
				delay: 0
			});
			lineSlicer.set(0, {
				delay: 500
			});

			setTimeout(() => {
				sculptureIndex.set(index);

				pointData.regenerate();
			}, 750);

			setTimeout(() => {
				textSlicer.set(1, {
					delay: 500
				});
				lineSlicer.set(1, {
					delay: 0
				});
			}, 2500);
		}}
		position={[position[0] * distance, position[1] * distance, position[2] * distance]}
		scale={size.current}
	>
		{#if type === 'bigText'}
			<Text
				color="#d6d3d1"
				anchorX="center"
				anchorY="middle"
				font="/fonts/STIXTwoText-Italic.ttf"
				position={[0, 0, 0]}
				textAlign="center"
				fontSize={0.4}
				maxWidth={5}
				lineHeight={1.25}
				sdfGlyphSize={64}
				fillOpacity={0.75}
				{text}
			/>
		{:else if type === 'text'}
			<Text
				color="#d6d3d1"
				anchorX="center"
				anchorY="middle"
				font="/fonts/NimbusSanL-Regu.ttf"
				position={[0, 0, 0]}
				textAlign="center"
				fontSize={0.25}
				maxWidth={5}
				lineHeight={1.25}
				sdfGlyphSize={64}
				fillOpacity={0.25}
				{text}
			/>
		{:else}
			<T.Mesh>
				<T.PlaneGeometry args={[7, 7]} />
				<ImageMaterial opacity={opacity.current} transparent url={`/data/${index}Preview.webp`} />
			</T.Mesh>
		{/if}
	</Billboard>
{/if}
