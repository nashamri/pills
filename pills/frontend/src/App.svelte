<script>
  import CreateUser from './CreateUser.svelte';
  import ViewUsers from './ViewUsers.svelte';

 
  let currentView = 'create'; 
</script>

<main>
  <nav class="navbar">
    <button 
      class:active={currentView === 'create'} 
      on:click={() => currentView = 'create'}>
      Add User
    </button>
    <button 
      class:active={currentView === 'view'} 
      on:click={() => currentView = 'view'}>
      View Users
    </button>
  </nav>

  <section class="content">
    {#if currentView === 'create'}
      <CreateUser />
    {:else}
      <ViewUsers />
    {/if}
  </section>
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
    background: #2c3e50;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.3);
  }

  .navbar button {
    background: transparent;
    border: 2px solid transparent;
    color: #bdc3c7;
    padding: 10px 20px;
    cursor: pointer;
    font-size: 16px;
    font-weight: bold;
    transition: all 0.3s;
    border-radius: 5px;
  }

  .navbar button:hover {
    color: white;
  }

  .navbar button.active {
    color: white;
    border-bottom: 2px solid #3498db;
    background: rgba(255, 255, 255, 0.1);
  }

  .content {
    width: 100%;
    max-width: 1000px;
    margin-top: 20px;
  }
</style>