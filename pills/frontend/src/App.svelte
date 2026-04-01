<script>
  import CreateUser from './pages/CreateUser.svelte';
  import ViewUsers from './pages/ViewUsers.svelte';
  import Home from './pages/Home.svelte';
  import Welcome from './pages/Welcome.svelte';
  import NotFound from './pages/NotFound.svelte';
  import Router from 'svelte-spa-router'
  import { currentUser } from './stores/auth';
 

  const routes = {
    '/': Home,
    '/welcome': Welcome,
    '/create_user': CreateUser,
    '/view_users': ViewUsers,
    '*': NotFound
  }
</script>

<main>
  <nav class="navbar">

    {#if $currentUser }
      <a href='#/'>Home</a>
      <a href='#/view_users'>View Users</a>
      <a href='#/hellother'>hi?</a>
    {:else}
      <a href='#/'>Home</a>
      <a href='#/welcome'>Welcome</a>
    {/if}
  </nav>

  <Router {routes} />

</main>

<style>
  main {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    display: flex;
    flex-direction: column;
    align-items: center;
    min-height: 100vh;
    background-color: #1b2636; 
    color: white;
  }

  .navbar {
    display: flex;
    gap: 20px;
    margin-top: 30px;
    padding: 10px;
    background: #9fbcda;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.3);
  }

</style>