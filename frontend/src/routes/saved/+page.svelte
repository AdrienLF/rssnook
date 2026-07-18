<script>
  import ArticleList from '$lib/components/ArticleList.svelte';
  import { app } from '$lib/stores/app.svelte.js';
  app.activeView = 'saved';
</script>

<svelte:head>
  <title>Read Later · rssnook</title>
</svelte:head>

<ArticleList savedOnly={true} />
