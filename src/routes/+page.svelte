<script lang="ts">
	// The page is the main thing you see:
	// It handles the start screen and initializes the sound + the 3D scene

	import Scene from '$lib/3D/scene.svelte';
	import { Canvas } from '@threlte/core';
	import Renderer from '$lib/3D/renderer.svelte';
	import { Tween } from 'svelte/motion';
	import { circInOut, cubicOut } from 'svelte/easing';
	import { onDestroy, onMount } from 'svelte';
	import { blur, draw, fly } from 'svelte/transition';
	import { browser } from '$app/environment';
	import { soundAdapter } from '$lib/csound.svelte';

	const loadingProgress = new Tween(0, {
		duration: 1,
		easing: circInOut
	});

	onDestroy(() => {
		soundAdapter.disposeSound();
	});

	let entered = $state(false);
</script>

<svelte:head>
	<title>Fraktal-Formen-Raum</title>
</svelte:head>

<section
	class="pointer-events-none absolute inset-0 z-50 {entered
		? 'bg-transparent'
		: 'bg-zinc-950'} transition-colors duration-1000 delay-[2000ms]"
>
	{#if !entered}
		<svg class="absolute w-full h-full p-4 pointer-events-none z-10 opacity-0 md:opacity-100">
			<line
				out:draw={{
					duration: 2000
				}}
				x1="50%"
				y1="0"
				x2="50%"
				y2="50%"
				stroke="currentColor"
				class="text-zinc-900"
			/>
			<line
				out:draw={{
					duration: 2000
				}}
				x1="50%"
				y1="100%"
				x2="50%"
				y2="50%"
				stroke="currentColor"
				class="text-zinc-900"
			/>
			<line
				out:draw={{
					duration: 2000
				}}
				x1="0"
				y1="50%"
				x2="50%"
				y2="50%"
				stroke="currentColor"
				class="text-zinc-900"
			/>
			<line
				out:draw={{
					duration: 2000
				}}
				x1="100%"
				y1="50%"
				x2="50%"
				y2="50%"
				stroke="currentColor"
				class="text-zinc-900"
			/>
		</svg>
	{/if}

	<div class="absolute inset-0 p-4 md:p-8 flex flex-col overflow-y-hidden gap-4 z-10">
		<nav class="flex justify-between gap-4">
			<div class="flex gap-4">
				<!-- Hinweis: Ich hab mich nicht selbst erst genannt, weil ich assozial bin, sondern weil die Seite vermutlich von meinem Server gehostet wird (?) Hoffe das ist okay so :) -->
				<a class="pointer-events-auto" target="_blank" href="https://lrs-chr-sch.de">lrs-chr-sch</a>
				<p>+</p>
				<a class="pointer-events-auto" target="_blank" href="https://www.von-neumann.com/">
					von-neumann
				</a>
			</div>
			<button
				class="text-right pointer-events-auto"
				onclick={() => {
					soundAdapter.toggleSound();
				}}>[{soundAdapter.soundPaused ? 'off' : 'on'}] Sound</button
			>
		</nav>
		<div class="flex-1 flex items-start md:justify-center md:items-center z-20">
			<div
				class="grid md:grid-cols-7 lg:grid-cols-9 xl:grid-cols-[repeat(13,_minmax(0,_1fr))] overflow-y-scroll max-h-[calc(100vh-7rem)] md:max-h-[calc(100vh-8rem)]"
			>
				<div class="col-span-2 lg:col-start-2 xl:col-start-4">
					{#if !entered}
						<h1
							out:fly={{
								x: '100%',
								duration: 1500,
								delay: 300,
								easing: cubicOut
							}}
							class="pointer-events-auto text-left md:text-right font-display text-2xl bg-zinc-950 md:pl-4 md:mt-3"
						>
							Fraktal-<span class="hidden md:inline"><br /></span>Formen-<span
								class="hidden md:inline"><br /></span
							>Raum
						</h1>
					{/if}
				</div>

				{#if !entered}
					<div
						out:blur={{
							duration: 1000,
							delay: 1250
						}}
						class="col-span-3 lg:col-start-4 xl:col-start-6 flex flex-col items-center py-4 md:p-4 z-10 {entered
							? 'bg-transparent'
							: 'bg-zinc-950'} transition-colors duration-500 group"
					>
						<button
							onclick={() => {
								entered = true;
								soundAdapter.startSound();
							}}
							class="border-neutral-700 border overflow-clip w-full aspect-square md:aspect-[4/5] h-auto relative pointer-events-auto"
						>
							<img
								src="/output10.webp"
								class="blur-xs w-[512px] h-full object-cover hover:scale-110 transition-transform duration-500 mix-blend-screen contrast-[120%]"
								alt="preview"
								loading="lazy"
							/>

							<svg
								class="absolute inset-0 object-cover w-full h-full pointer-events-none mix-blend-overlay contrast-[250%] brightness-75 grayscale-100"
								viewBox="0 0 100 100"
								xmlns="http://www.w3.org/2000/svg"
							>
								<filter id="noiseFilter">
									<feTurbulence
										type="fractalNoise"
										baseFrequency="3"
										numOctaves="1"
										stitchTiles="stitch"
									>
										<animate
											attributeName="baseFrequency"
											values="3;4;2"
											dur="0.1s"
											repeatCount="indefinite"
										/>
									</feTurbulence>
								</filter>

								<rect width="500%" height="500%" filter="url(#noiseFilter)" />
							</svg>
						</button>
						<p class="mt-2 font-display text-stone-400 group-hover:underline">click to enter</p>
					</div>
				{/if}
				{#if !entered}
					<div
						out:fly={{
							x: '-100%',
							duration: 1000,
							easing: cubicOut
						}}
						class="col-span-2 md:col-start-6 lg:col-start-7 xl:col-start-9 self-end mb-11 bg-zinc-950 pr-4"
					>
						<p class="pointer-events-auto text-sm hyphens-auto">
							Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut et massa mi. Aliquam in
							hendrerit urna. Pellentesque sit amet sapien fringilla, mattis ligula consectetur,
							ultrices mauris. Maecenas vitae mattis tellus. Nullam quis imperdiet augue. Vestibulum
							auctor ornare leo, non suscipit magna interdum eu. Curabitur pellentesque nibh nibh,
							at maximus ante fermentum sit amet.
						</p>
					</div>
				{/if}
			</div>
		</div>
		<footer class="flex justify-end gap-4">
			<a class="pointer-events-auto" href="https://lrs-chr-sch.de/imprint">Imprint</a>
			<a class="pointer-events-auto" href="https://lrs-chr-sch.de/privacy">Privacy</a>
		</footer>
	</div>
</section>

<main>
	<Canvas>
		<Renderer />
		<Scene />
	</Canvas>
</main>
