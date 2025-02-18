<script lang="ts">
	// This component sets up the renderer and postprocessing in a neat way
	import { useThrelte, useTask } from '@threlte/core';
	import { onMount } from 'svelte';
	import {
		EffectComposer,
		EffectPass,
		RenderPass,
		SMAAEffect,
		SMAAPreset,
		ChromaticAberrationEffect,
		VignetteEffect,
		VignetteTechnique,
		NoiseEffect,
		BlendFunction,
		TiltShiftEffect,
		PixelationEffect,
		DepthOfFieldEffect,
		GridEffect
	} from 'postprocessing';
	import * as THREE from 'three';
	import type { Camera } from 'three';

	const { scene, renderer, camera, size } = useThrelte();

	const composer = new EffectComposer(renderer);

	const setupEffectComposer = (camera: Camera) => {
		composer.removeAllPasses();
		composer.addPass(new RenderPass(scene, camera));

		composer.addPass(
			new EffectPass(
				camera,
				new TiltShiftEffect({
					focusArea: 1,
					feather: 0.5
				})
			)
		);

		composer.addPass(
			new EffectPass(
				camera,
				new SMAAEffect({
					preset: SMAAPreset.HIGH
				})
			)
		);

		composer.addPass(
			new EffectPass(
				camera,
				new ChromaticAberrationEffect({
					offset: new THREE.Vector2(0.00025, 0),
					radialModulation: false,
					modulationOffset: 0
				})
			)
		);

		composer.addPass(
			new EffectPass(
				camera,
				new NoiseEffect({
					premultiply: true,
					blendFunction: BlendFunction.SCREEN
					// premultiply: false,
					// blendFunction: BlendFunction.SOFT_LIGHT
				})
			)
		);

		composer.addPass(
			new EffectPass(
				camera,
				new VignetteEffect({
					offset: 0.1,
					darkness: 0.5,
					technique: VignetteTechnique.DEFAULT
				})
			)
		);
	};

	$effect(() => {
		setupEffectComposer($camera);
	});

	$effect(() => {
		composer.setSize($size.width, $size.height);
	});

	const { renderStage, autoRender } = useThrelte();

	onMount(() => {
		let before = autoRender.current;
		autoRender.set(false);
		return () => autoRender.set(before);
	});

	useTask(
		(delta) => {
			composer.render(delta);
		},
		{
			stage: renderStage,
			autoInvalidate: false
		}
	);
</script>
