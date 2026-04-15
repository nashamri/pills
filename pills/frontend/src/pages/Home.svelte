<script>
  import { currentUser, logout } from "../stores/auth";
  import { push } from "svelte-spa-router";

  function redirect() {
    push("/welcome");
  }
</script>

<h1>Home Page</h1>

{#if $currentUser}
  <p>email: {$currentUser.Email}</p>
  <p>gender: {$currentUser.Gender}</p>
  <p>role: {$currentUser.Role}</p>
  <button on:click={logout}>Logout</button>
{:else}
  <p>Go to login page?</p>
  <button on:click={redirect}>Go</button>
{/if}
