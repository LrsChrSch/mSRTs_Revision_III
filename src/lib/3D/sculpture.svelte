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
	const count = 1000000;

	const geometry = new THREE.BoxGeometry(size, size, size);
	const material = new THREE.MeshPhysicalMaterial({
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
			const dataArray = Array.from(new Uint8Array(decompressed));

			// Convert into 2D format (assuming 4 columns per row)
			const numColumns = 3;

			let maxSize = -1;
			const average = new THREE.Vector3(0, 0, 0);
			let total = 0;
			const dummy = new THREE.Object3D();

			for (let i = 0; i < dataArray.length; i += numColumns) {
				const data = dataArray.slice(i, i + numColumns);

				let x = data[0] / 255;
				let y = data[1] / 255;
				let z = data[2] / 255;

				x = x * 2 - 1;
				y = y * 2 - 1;
				z = z * 2 - 1;

				x += (Math.random() - 0.5) * noise;
				y += (Math.random() - 0.5) * noise;
				z += (Math.random() - 0.5) * noise;

				dummy.position.set(x, y, z);
				const distance = Math.sqrt(x * x + y * y + z * z);
				dummy.scale.setScalar(1.5 - distance);
				dummy.updateMatrix();

				mesh.setMatrixAt(total, dummy.matrix);

				// set maxSize to the length of the longest x and z vector
				const length = Math.sqrt(x ** 2 + z ** 2);
				maxSize = Math.max(maxSize, length);
				average.add(dummy.position);

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

			while (groupRef?.children.length) {
				groupRef.remove(groupRef.children[0]);
			}
			groupRef?.add(mesh);
		} catch (error) {
			console.error('Error loading the file:', error);
		}
	}

	$effect(() => {
		loadSculpture(index);
	});

	let rotation = $state(0);
	// useTask((delta) => (rotation += delta * 0.05));

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

<T.Group frustumCulled={false} scale={groupSize.current} rotation.y={rotation} bind:ref={groupRef}
></T.Group>

<!-- Placeholder while animating-->
<T.Mesh scale={1 - groupSize.current}>
	<T.SphereGeometry args={[0.1, 16]} />
	<T.MeshStandardMaterial color="#e7e5e4" />
</T.Mesh>
