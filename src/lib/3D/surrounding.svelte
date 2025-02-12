<script lang="ts">
	// This component mainly groups all surroundingCards and assigns the correct data to each one based on pointData
	import { T } from '@threlte/core';
	import SurroundingCard from './surroundingCard.svelte';
	import { origin } from './stores.svelte';
	import { Tween } from 'svelte/motion';
	import { onMount } from 'svelte';
	import { pointData } from './pointData.svelte';

	const positionTween = new Tween(origin.origin, {
		duration: 1,
		delay: 1000
	});

	$effect(() => {
		positionTween.target = origin.origin;
	});

	onMount(async () => {
		await pointData.regenerate();
	});
</script>

<T.Group position={positionTween.current}>
	{#each pointData.data as data, index}
		<SurroundingCard
			animationIndex={index}
			index={data.index}
			position={data.position}
			type={data.type}
			text={data.text}
		/>
	{/each}
</T.Group>
