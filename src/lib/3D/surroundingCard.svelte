<script lang="ts">
	// This component shows the 2D cards that follow the viewer around
	// It handles the display of both text and images
	// It also handles all the interactions with the cards and the animation that triggers

	import { Billboard, ImageMaterial, Text, useCursor } from '@threlte/extras';
	import * as THREE from 'three';
	import { invalidateSurrounding, linePoints, origin, sculptureIndex } from './stores.svelte';
	import { Tween } from 'svelte/motion';
	import { T } from '@threlte/core';
	import { cubicInOut } from 'svelte/easing';
	import { writable } from 'svelte/store';
	import { interactions, pointData } from './pointData.svelte';
	import { soundAdapter } from '$lib/csound.svelte';

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

	const textMaxSize = 0.2;
	const textMinSize = 0.16;

	$effect(() => {
		if ($hovering && type === 'image') {
			opacity.target = 1;
			onPointerOverCursor.set('pointer');
			soundAdapter.surroundingHoverInteraction(index, animationIndex);
		} else if (type === 'bigText' || type === 'text') {
			opacity.target = 0.75;
			onPointerOverCursor.set('auto');
		} else {
			opacity.target = 0.25;
			onPointerOverCursor.set('auto');
			soundAdapter.surroundingHoverInteraction(-1, animationIndex);
		}
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

			const newOrigin: [x: number, y: number, z: number] = [
				e.eventObject.position.x + origin.origin[0],
				e.eventObject.position.y + origin.origin[1],
				e.eventObject.position.z + origin.origin[2]
			];
			interactions.add();

			linePoints.addPoints(newOrigin);
			origin.set(newOrigin);

			soundAdapter.transitionStartedInteraction();

			setTimeout(() => {
				sculptureIndex.set(index);

				pointData.regenerate();
			}, 750);
		}}
		position={[position[0] * distance, position[1] * distance, position[2] * distance]}
		scale={size.current}
	>
		{#if type === 'text'}
			<Text
				color="#737373"
				anchorX="center"
				anchorY="middle"
				characters="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!?.,-'"
				font="/fonts/SuisseIntl-Bold.otf"
				position={[0, 0, 0]}
				textAlign="center"
				fontSize={Math.max(
					textMinSize,
					Math.min(textMaxSize, textMaxSize - (text.length / 256) * (textMaxSize - textMinSize))
				)}
				maxWidth={3.5}
				lineHeight={1.25}
				sdfGlyphSize={64}
				{text}
			/>
		{:else if type === 'image'}
			<T.Mesh>
				<T.PlaneGeometry args={[7, 7]} />
				<ImageMaterial opacity={opacity.current} transparent url={`/data/${index}Preview.webp`} />
			</T.Mesh>
		{/if}
	</Billboard>
{/if}
