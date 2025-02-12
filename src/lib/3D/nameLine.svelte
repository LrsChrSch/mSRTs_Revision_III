<script>
	// This component isn't being used right now
	// It shows a title for the sculpture at the current mouse position

	import { T } from '@threlte/core';
	import { Billboard, Text } from '@threlte/extras';
	import * as THREE from 'three';
	import { lineSlicer, textSlicer, word } from './stores.svelte';

	const { origin, screenPosition } = $props();

	const lineGeometry = new THREE.BufferGeometry();
	$effect(() => {
		lineGeometry.setAttribute(
			'position',
			new THREE.Float32BufferAttribute(
				[
					origin[0],
					origin[1],
					origin[2],
					THREE.MathUtils.lerp(origin[0], screenPosition[0], lineSlicer.current),
					THREE.MathUtils.lerp(origin[1], screenPosition[1], lineSlicer.current),
					THREE.MathUtils.lerp(origin[2], screenPosition[2], lineSlicer.current)
				],
				3
			)
		);
	});

	const material = new THREE.LineBasicMaterial({ color: '#404040' });
</script>

<T.Line frustumCulled={false} geometry={lineGeometry} {material} />
<Billboard position={[screenPosition[0], screenPosition[1] + 0.025, screenPosition[2]]}>
	<Text
		color="#e7e5e4"
		anchorX="left"
		anchorY="middle"
		font="/fonts/STIXTwoText-Italic.ttf"
		textAlign="center"
		fontSize={0.05}
		maxWidth={4}
		lineHeight={1.25}
		sdfGlyphSize={64}
		text={word.word.slice(0, textSlicer.current * word.word.length)}
	/>
</Billboard>
