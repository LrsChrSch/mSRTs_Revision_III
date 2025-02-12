<script lang="ts">
	// The crosshair with the axis names and lines
	import { T, useTask, useThrelte } from '@threlte/core';
	import * as THREE from 'three';
	import { origin } from './stores.svelte';
	import { Text } from '@threlte/extras';
	import LockedBillboard from './lockedBillboard.svelte';

	const lineStart = 0;
	const lineEnd = 0;
	const linePadding = 3.5;
	const wordPos = 3;
	const textSize = 0.15;

	function createSimpleLine(pointA: THREE.Vector3, pointB: THREE.Vector3) {
		const lineGeometry = new THREE.BufferGeometry().setAttribute(
			'position',
			new THREE.Float32BufferAttribute(
				[pointA.x, pointA.y, pointA.z, pointB.x, pointB.y, pointB.z],
				3
			)
		);

		return lineGeometry;
	}

	const { camera } = useThrelte();

	const material = new THREE.LineBasicMaterial({ color: '#27272a' });

	let isPositiveX = $state(false);
	let isPositiveZ = $state(false);

	useTask(() => {
		isPositiveX = $camera.position.x > origin.origin[0];
		isPositiveZ = $camera.position.z > origin.origin[2];
	});
</script>

<T.Group position={origin.origin}>
	<T.Line
		geometry={createSimpleLine(new THREE.Vector3(100, 0, 0), new THREE.Vector3(linePadding, 0, 0))}
		{material}
	/>
	<T.Line
		geometry={createSimpleLine(
			new THREE.Vector3(-linePadding, 0, 0),
			new THREE.Vector3(-100, 0, 0)
		)}
		{material}
	/>
	<T.Line
		geometry={createSimpleLine(
			new THREE.Vector3(lineStart, 0, 0),
			new THREE.Vector3(lineEnd, 0, 0)
		)}
		{material}
	/>
	<T.Line
		geometry={createSimpleLine(
			new THREE.Vector3(-lineStart, 0, 0),
			new THREE.Vector3(-lineEnd, 0, 0)
		)}
		{material}
	/>

	<T.Group>
		<LockedBillboard position={[wordPos, 0, 0]} lockZ={true} lockY={true} flipOnZ={true}>
			<Text
				scale.x={isPositiveZ ? 1 : -1}
				scale.y={isPositiveZ ? 1 : -1}
				color="#d6d3d1"
				anchorX={isPositiveZ ? 'right' : 'left'}
				anchorY="middle"
				font="/fonts/STIXTwoText-Italic.ttf"
				position={[0, 0, 0]}
				textAlign="center"
				fontSize={textSize}
				maxWidth={5}
				lineHeight={1.25}
				sdfGlyphSize={64}
				text="constructed"
				fillOpacity={Math.min(Math.max((origin.origin[0] / 100) * 0.9 + 0.1, 0.1), 1)}
			/>
		</LockedBillboard>
		<LockedBillboard position={[-wordPos, 0, 0]} lockZ={true} lockY={true} flipOnZ={true}>
			<Text
				scale.x={isPositiveZ ? 1 : -1}
				scale.y={isPositiveZ ? 1 : -1}
				color="#d6d3d1"
				anchorX={isPositiveZ ? 'left' : 'right'}
				anchorY="middle"
				font="/fonts/STIXTwoText-Italic.ttf"
				position={[0, 0, 0]}
				textAlign="center"
				fontSize={textSize}
				maxWidth={5}
				lineHeight={1.25}
				sdfGlyphSize={64}
				text="emergent"
				fillOpacity={Math.min(Math.max((origin.origin[0] / -100) * 0.9 + 0.1, 0.1), 1)}
			/>
		</LockedBillboard>
	</T.Group>

	<T.Line
		geometry={createSimpleLine(new THREE.Vector3(0, 100, 0), new THREE.Vector3(0, linePadding, 0))}
		{material}
	/>
	<T.Line
		geometry={createSimpleLine(
			new THREE.Vector3(0, -linePadding, 0),
			new THREE.Vector3(0, -100, 0)
		)}
		{material}
	/>
	<T.Line
		geometry={createSimpleLine(
			new THREE.Vector3(0, lineStart, 0),
			new THREE.Vector3(0, lineEnd, 0)
		)}
		{material}
	/>
	<T.Line
		geometry={createSimpleLine(
			new THREE.Vector3(0, -lineStart, 0),
			new THREE.Vector3(0, -lineEnd, 0)
		)}
		{material}
	/>

	<T.Group rotation.z={-Math.PI / 2}>
		<LockedBillboard position={[wordPos, 0, 0]} lockZ={true} lockY={true}>
			<Text
				color="#d6d3d1"
				anchorX="left"
				anchorY="middle"
				font="/fonts/STIXTwoText-Italic.ttf"
				position={[0, 0, 0]}
				textAlign="center"
				fontSize={textSize}
				maxWidth={5}
				lineHeight={1.25}
				sdfGlyphSize={64}
				text="infra"
				fillOpacity={Math.min(Math.max((origin.origin[1] / -100) * 0.9 + 0.1, 0.1), 1)}
			/>
		</LockedBillboard>
		<LockedBillboard position={[-wordPos, 0, 0]} lockZ={true} lockY={true}>
			<Text
				color="#d6d3d1"
				anchorX="right"
				anchorY="middle"
				font="/fonts/STIXTwoText-Italic.ttf"
				position={[0, 0, 0]}
				textAlign="center"
				fontSize={textSize}
				maxWidth={5}
				lineHeight={1.25}
				sdfGlyphSize={64}
				text="meta"
				fillOpacity={Math.min(Math.max((origin.origin[1] / 100) * 0.9 + 0.1, 0.1), 1)}
			/>
		</LockedBillboard>
	</T.Group>

	<T.Line
		geometry={createSimpleLine(new THREE.Vector3(0, 0, 100), new THREE.Vector3(0, 0, linePadding))}
		{material}
	/>
	<T.Line
		geometry={createSimpleLine(
			new THREE.Vector3(0, 0, -linePadding),
			new THREE.Vector3(0, 0, -100)
		)}
		{material}
	/>
	<T.Line
		geometry={createSimpleLine(
			new THREE.Vector3(0, 0, lineStart),
			new THREE.Vector3(0, 0, lineEnd)
		)}
		{material}
	/>
	<T.Line
		geometry={createSimpleLine(
			new THREE.Vector3(0, 0, -lineStart),
			new THREE.Vector3(0, 0, -lineEnd)
		)}
		{material}
	/>

	<T.Group rotation.y={-Math.PI / 2}>
		<LockedBillboard position={[wordPos, 0, 0]} lockZ={true} lockY={true} flipOnX={true}>
			<Text
				scale.x={isPositiveX ? -1 : 1}
				scale.y={isPositiveX ? -1 : 1}
				color="#d6d3d1"
				anchorX={isPositiveX ? 'left' : 'right'}
				anchorY="middle"
				font="/fonts/STIXTwoText-Italic.ttf"
				position={[0, 0, 0]}
				textAlign="center"
				fontSize={textSize}
				maxWidth={5}
				lineHeight={1.25}
				sdfGlyphSize={64}
				text="noise"
				fillOpacity={Math.min(Math.max((origin.origin[2] / 100) * 0.9 + 0.1, 0.1), 1)}
			/>
		</LockedBillboard>
		<LockedBillboard
			position={[-wordPos, 0, 0]}
			scale.x={-1}
			lockZ={true}
			lockY={true}
			flipOnX={true}
		>
			<Text
				scale.x={isPositiveX ? 1 : -1}
				scale.y={isPositiveX ? -1 : 1}
				color="#d6d3d1"
				anchorX={isPositiveX ? 'right' : 'left'}
				anchorY="middle"
				font="/fonts/STIXTwoText-Italic.ttf"
				position={[0, 0, 0]}
				textAlign="center"
				fontSize={textSize}
				maxWidth={5}
				lineHeight={1.25}
				sdfGlyphSize={64}
				text="signal"
				fillOpacity={Math.min(Math.max((origin.origin[2] / -100) * 0.9 + 0.1, 0.1), 1)}
			/>
		</LockedBillboard>
	</T.Group>
</T.Group>
