<script>
	// The layout only sets up the main page (this website is technically a one-pager)
	// Mainly the css gets loaded here
	let { children } = $props();
	import '@fontsource-variable/stix-two-text';
	import '../app.css';
</script>

{@render children()}
