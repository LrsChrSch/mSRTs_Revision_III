<script>
	// This line follows the origin point whenever it changes.
	// Whenever the linePoints store is updated, the line gets recomputed and displayed
	// There might be some optimization to be done here, but it works for now
	import { T } from '@threlte/core';
	import { linePoints } from './stores.svelte';
	import * as THREE from 'three';

	const lineGeometry = new THREE.BufferGeometry();
	$effect(() => {
		lineGeometry.setAttribute('position', new THREE.Float32BufferAttribute($linePoints, 3));
	});

	const material = new THREE.LineBasicMaterial({ color: '#e7e5e4', depthTest: false });
</script>

<T.Line frustumCulled={false} geometry={lineGeometry} {material} />
