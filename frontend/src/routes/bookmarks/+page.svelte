<script>
  import ArticleList from '$lib/components/ArticleList.svelte';
  import { app } from '$lib/stores/app.svelte.js';
  app.activeView = 'bookmarks';
</script>

<svelte:head>
  <title>Bookmarks · rssnook</title>
</svelte:head>

<ArticleList bookmarksOnly={true} />
