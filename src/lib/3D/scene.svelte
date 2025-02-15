<script lang="ts">
	// This is the main scene of the 3D environment and it contains all of the elements (sculpture, postprocessing, surrounding, etc.)
	import { T, useTask } from '@threlte/core';
	import { interactivity, OrbitControls } from '@threlte/extras';
	import TrackingLine from './trackingLine.svelte';
	import Crosshair from './crosshair.svelte';
	import Surrounding from './surrounding.svelte';
	import { origin, sculptureIndex } from './stores.svelte';
	import { Tween } from 'svelte/motion';
	import { cubicInOut } from 'svelte/easing';
	import * as THREE from 'three';
	import NameLine from './nameLine.svelte';
	import { onDestroy, onMount } from 'svelte';
	import Sculpture from './sculpture.svelte';
	import { soundAdapter } from '$lib/csound.svelte';

	interactivity();

	const targetTween = new Tween(origin.origin, {
		duration: 2000,
		delay: 750,
		easing: cubicInOut
	});

	$effect(() => {
		// console.log(origin.origin);
		targetTween.target = origin.origin;
	});

	let cameraRef: THREE.PerspectiveCamera | undefined = $state();

	let screenPosition: [x: Number, y: Number, z: Number] = $state([0, 0, 0]);

	let cursorX = $state(0.5);
	let cursorY = $state(0.5);
	onMount(async () => {
		await soundAdapter.prepareSound();

		window.addEventListener('mousemove', (e) => {
			const mouseX = e.clientX / window.innerWidth;
			const mouseY = e.clientY / window.innerHeight;

			cursorX = mouseX;
			cursorY = mouseY;

			soundAdapter.additivStructFreqPosition(mouseX);
			soundAdapter.additivStructFiltCf(mouseY);
		});
	});

	onDestroy(() => {
		window.removeEventListener('mousemove', () => {});
	});

	useTask(() => {
		if (cameraRef) {
			// get the length of the vector from the camera to the targetTween.current (using camera.position)
			const distanceToOrigin = new THREE.Vector3()
				.subVectors(cameraRef.position, new THREE.Vector3(...targetTween.current))
				.length();

			// map and clamp the distance from a range of 0 to 10 to a range of -90 to -3
			const newGain = THREE.MathUtils.mapLinear(distanceToOrigin, 0, 10, -3, -24);

			// if (module) module.volumeControl(newGain);

			const screenSpacePosition = new THREE.Vector2(cursorX, cursorY); // Example screen space coordinate (center of the screen)
			const ndc = new THREE.Vector3(
				screenSpacePosition.x * 2 - 1,
				-screenSpacePosition.y * 2 + 1,
				-1 // Near clipping plane
			);

			ndc.unproject(cameraRef);

			const direction = ndc.sub(cameraRef.position).normalize();
			const distance = 2; // Distance from the camera
			const position = cameraRef.position.clone().add(direction.multiplyScalar(distance));

			// update the state of the screenPosition
			screenPosition = [position.x, position.y, position.z];
		}
	});
</script>

<T.Color attach="background" args={['#09090b']} />
<T.Fog attach="fog" args={['#09090b', 10, 25]} />

<T.PerspectiveCamera
	makeDefault
	bind:ref={cameraRef}
	position={[-5, 2.5, 5]}
	fov={70}
	near={0.001}
	far={1000}
>
	<OrbitControls
		enableDamping
		dampingFactor={0.1}
		maxDistance={7}
		minDistance={0.05}
		maxTargetRadius={3}
		cursor={targetTween.current}
	/>
</T.PerspectiveCamera>

<T.AmbientLight intensity={0.5} />
<T.DirectionalLight position={[0, 10, 10]} castShadow />

<TrackingLine />
<Crosshair />

<!--  <NameLine origin={targetTween.current} {screenPosition} /> -->

<Surrounding />

<T.Group position={targetTween.current}>
	<T.PointLight position={[0, 1, 0]} intensity={1} />
	<!-- <CircleText /> -->
	<!-- <Sculpture index={sculptureIndex.index} /> -->
	<Sculpture index={sculptureIndex.index} />
</T.Group>

<!-- <Stars factor={2} count={320} speed={1} lightness={0.1} saturation={0} /> -->
