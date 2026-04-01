<script>

    import {currentUser, logout} from '../stores/auth';
</script>

<h1>Home Page</h1>

  {#if $currentUser}                                                                                                                              
      <p>hello {$currentUser.name}</p>
      <p>Your age is {$currentUser.age}</p>
  {/if}
  

<button on:click={logout}>Logout</button>
