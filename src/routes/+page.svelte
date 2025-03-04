<script lang="ts">
	// The page is the main thing you see:
	// It handles the start screen and initializes the sound + the 3D scene

	import Scene from '$lib/3D/scene.svelte';
	import { Canvas } from '@threlte/core';
	import Renderer from '$lib/3D/renderer.svelte';
	import { cubicOut } from 'svelte/easing';
	import { onDestroy } from 'svelte';
	import { blur, draw, fade, fly } from 'svelte/transition';
	import { soundAdapter } from '$lib/csound.svelte';

	onDestroy(() => {
		soundAdapter.disposeSound();
	});

	let entered = $state(false);

	let imgHeight = $state(0);
	let needsReset = $state(false);
</script>

<svelte:head>
	<title>m.SRT.s Revision III</title>
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
				}}
				><span class="font-display tracking-tighter uppercase"
					>[{soundAdapter.soundPaused ? 'off' : 'on'}]</span
				> sound</button
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
							class="pointer-events-auto text-left md:text-right font-bold text-2xl bg-zinc-950 md:pl-4 md:mt-3"
						>
							<!-- Signum<span class="hidden md:inline"><br /> </span>Aeternum<span
								class="hidden md:inline"
								><br />
							</span>Iter -->
							m.SRT.s<span class="hidden md:inline"><br /></span> Revision<span
								class="hidden md:inline"><br /></span
							> III
						</h1>
					{/if}
				</div>

				{#if !entered}
					<button
						out:blur={{
							duration: 1000,
							delay: 1250
						}}
						onclick={() => {
							entered = true;
							soundAdapter.startSound();
						}}
						class="col-span-3 lg:col-start-4 xl:col-start-6 flex flex-col items-center py-4 md:p-4 z-10 pointer-events-auto focus:!ring-0 {entered
							? 'bg-transparent'
							: 'bg-zinc-950'} transition-colors duration-500 group"
					>
						<div
							class="border-neutral-700 border overflow-clip w-full aspect-square md:aspect-[4/5] h-auto relative group-focus:ring-1"
						>
							<img
								src="/vid.webp"
								class="blur-xs w-[512px] h-full object-cover group-hover:scale-110 transition-transform duration-500 mix-blend-screen contrast-[120%]"
								alt="preview"
								loading="lazy"
								bind:clientHeight={imgHeight}
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
						</div>
						<p class="mt-2 tracking-tighter font-display text-stone-400 group-hover:underline">
							click to enter
						</p>
					</button>
				{/if}
				{#if !entered}
					<div
						out:fly={{
							x: '-100%',
							duration: 1000,
							easing: cubicOut
						}}
						class="col-span-2 md:col-start-6 lg:col-start-7 xl:col-start-9 self-end mb-11 bg-zinc-950 pr-4 overflow-y-auto"
						style={'max-height:' + imgHeight + 'px'}
					>
						<p class="pointer-events-auto text-sm space-y-1">
							What is language? What are symbols? What is the meaning of meaning? If language shapes
							thought, to what extent does it limit our ability to perceive reality? And in a
							reality of misinformation, infinite viewpoints and computers being capable of
							rendering imposing high fidelity graphics anywhere, do our simple abstracted symbols
							even matter? Aren't we ultimately held back by the minimalist character of our 2D
							alphabetic characters?
						</p>
						<p class="pointer-events-auto text-sm mt-2">
							This project allows the exploration of a virtual space trying to answer these
							questions. Moving through the space from point to point reveals various viewpoints
							from science, philosophy, fiction and art. Shifting from meaning to intuition. From
							reading to observing. From the known to the unknown...
						</p>
					</div>
				{/if}
			</div>
		</div>
		<footer class="flex gap-4 {entered ? 'justify-between' : 'justify-end'}">
			{#if entered}
				<button
					in:fade={{
						duration: 1000,
						delay: 2000
					}}
					class="text-right pointer-events-auto"
					onclick={() => {
						needsReset = true;
						setTimeout(() => {
							needsReset = false;
						}, 1);
					}}><span class="font-display tracking-tighter uppercase">[reset]</span> cam</button
				>
			{/if}
			<div class="flex gap-4">
				<a class="pointer-events-auto" href="https://lrs-chr-sch.de/imprint">Imprint</a>
				<a class="pointer-events-auto" href="https://lrs-chr-sch.de/privacy">Privacy</a>
			</div>
		</footer>
	</div>
</section>

<main>
	<Canvas>
		<Renderer />
		<Scene {needsReset} />
	</Canvas>
</main>
