<script lang="ts">
	// this component fetches the file /data/1Positions.gz, opens it and prints the first 10 lines using pako
	import { onMount } from 'svelte';
	import pako from 'pako';
	import * as THREE from 'three';
	import { origin, sculptureIndex, sculptureSize } from './stores.svelte';
	import { T } from '@threlte/core';
	import { Tween } from 'svelte/motion';
	import { cubicInOut } from 'svelte/easing';
	import { soundAdapter } from '$lib/csound.svelte';

	const { index } = $props();

	onMount(() => {
		sculptureIndex.set(index);
	});

	const size = 0.005;
	const scale = 3;
	const noise = 0.005;
	const count = 50000;

	const geometry = new THREE.BoxGeometry(size, size, size);
	const material = new THREE.MeshStandardMaterial({
		color: '#e7e5e4'
	});

	const mesh = new THREE.InstancedMesh(geometry, material, count);
	let groupRef: THREE.Group | undefined = $state();

	async function loadSculpture(num: number) {
		try {
			// Load the binary file
			const response = await fetch(`/data/${num}Positions.bin`);
			const compressedData = new Uint8Array(await response.arrayBuffer());

			// Decompress using pako
			const decompressed = pako.inflate(compressedData);

			// Convert the buffer back to the original format (Uint8Array)
			const dataArray = new Uint8Array(decompressed);

			// Convert into 2D format (assuming 3 columns per row)
			const numColumns = 3;

			let maxSize = -1;
			const average = new THREE.Vector3(0, 0, 0);
			let total = 0;

			// Reuse objects to avoid unnecessary allocations
			const position = new THREE.Vector3();
			const matrix = new THREE.Matrix4();
			const quaternion = new THREE.Quaternion();
			const scaleVector = new THREE.Vector3();

			for (let i = 0; i < dataArray.length; i += numColumns) {
				position.set(dataArray[i] / 255, dataArray[i + 1] / 255, dataArray[i + 2] / 255);

				position.multiplyScalar(2).subScalar(1);
				position.addScalar((Math.random() - 0.5) * noise);

				// scale value is 1.5 - distance of position from origin
				const distance = position.length();
				const scaleValue = 1.5 - distance;
				scaleVector.set(scaleValue, scaleValue, scaleValue);

				matrix.compose(position, quaternion, scaleVector);
				mesh.setMatrixAt(total, matrix);

				// set maxSize to the length of the longest x and z vector
				maxSize = Math.max(maxSize, distance);
				average.add(position);

				total++;
			}

			sculptureSize.set(maxSize);
			average.divideScalar(total);

			mesh.count = total;
			soundAdapter.sculptureInstanceAmountHandler(total);

			// set the mesh position to 0,0,0
			mesh.position.set(0, 0, 0);
			mesh.position.sub(average.multiplyScalar(scale));
			mesh.scale.setScalar(scale);
			mesh.instanceMatrix.needsUpdate = true;

			if (groupRef && !groupRef.children.length) {
				groupRef.add(mesh);
			}
		} catch (error) {
			console.error('Error loading the file:', error);
		}
	}

	$effect(() => {
		loadSculpture(index);
	});

	const groupSize = new Tween(1, {
		duration: 500,

		easing: cubicInOut
	});

	$effect(() => {
		if (origin.origin) groupSize.target = 0;
		// wait 2 seconds, then set the size.target back to 1
		setTimeout(() => {
			groupSize.target = 1;
		}, 2500);
	});
</script>

<T.Group scale={groupSize.current} bind:ref={groupRef}></T.Group>

<!-- Placeholder while animating-->
<T.Mesh scale={1 - groupSize.current}>
	<T.SphereGeometry args={[0.1, 16]} />
	<T.MeshStandardMaterial color="#e7e5e4" />
</T.Mesh>
