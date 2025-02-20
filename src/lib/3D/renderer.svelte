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
		GridEffect,
		BloomEffect,
		LensDistortionEffect,
		ShockWaveEffect
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
					feather: 0.5,
					kernelSize: 1,
					resolutionScale: 1
				})
			)
		);

		composer.addPass(
			new EffectPass(
				camera,
				new SMAAEffect({
					preset: SMAAPreset.ULTRA
				})
			)
		);

		composer.addPass(
			new EffectPass(
				camera,
				new LensDistortionEffect({
					distortion: new THREE.Vector2(0.05, 0.05),
					principalPoint: new THREE.Vector2(0, 0),
					focalLength: new THREE.Vector2(0.9, 0.9)
				})
			)
		);

		composer.addPass(
			new EffectPass(
				camera,
				new BloomEffect({
					blendFunction: BlendFunction.SCREEN,
					luminanceThreshold: 0.5,
					mipmapBlur: true,
					levels: 5,
					intensity: 0.25
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
