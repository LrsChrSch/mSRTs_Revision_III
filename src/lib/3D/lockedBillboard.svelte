<script lang="ts">
	// This component is a fork of the Billboard-Component
	// It allows locking a rotation axis and is being used to show the axis names in the 3D view

	import { T, useStage, useTask, useThrelte } from '@threlte/core';
	import { Group, Quaternion } from 'three';
	import type { Props } from '@threlte/core';
	import type { Object3D } from 'three';

	type BillboardProps = Props<Group> & {
		/**
		 * @default true
		 */
		follow?: boolean | Object3D;
		lockX?: boolean;
		lockY?: boolean;
		lockZ?: boolean;
		flipOnX?: boolean;
		flipOnY?: boolean;
		flipOnZ?: boolean;
	};

	let {
		follow = true,
		lockX = false,
		lockY = false,
		lockZ = false,
		flipOnX = false,
		flipOnY = false,
		flipOnZ = false,

		ref = $bindable(),
		children,
		...props
	}: BillboardProps = $props();

	const inner = new Group();
	const localRef = new Group();

	const { camera, renderStage } = useThrelte();

	const q = new Quaternion();

	let followObject = $derived(follow === true ? $camera : follow === false ? undefined : follow);

	const stage = useStage('<LockedBillboard>', { before: renderStage });

	const { start, stop } = useTask(
		() => {
			// always face the follow object while taking the lockX, lockY, lockZ into account
			// lockX means that the object will not rotate around the x-axis
			if (!followObject || !localRef) return;

			const prevRotation = inner.rotation.clone();

			localRef.updateMatrix();
			localRef.updateWorldMatrix(false, false);
			localRef.getWorldQuaternion(q);
			followObject?.getWorldQuaternion(inner.quaternion).premultiply(q.invert());

			if (lockX) inner.rotation.x = prevRotation.x;
			if (lockY) inner.rotation.y = prevRotation.y;
			if (lockZ) inner.rotation.z = prevRotation.z;
		},
		{ autoStart: false, stage }
	);

	$effect.pre(() => {
		if (follow) {
			start();
		} else {
			stop();
		}
	});
</script>

<T is={localRef} bind:ref {...props}>
	<T is={inner}>
		{@render children?.({ ref: localRef })}
	</T>
</T>
