<script>
  import { currentUser, logout } from "../stores/auth";
  import { push } from "svelte-spa-router";

  function redirect() {
    push("/welcome");
  }
</script>

{#if $currentUser}
  <button on:click={logout}>Logout</button>

  {#if $currentUser.Role === 0 }
    <h3>You are an Admin</h3>
  {:else if $currentUser.Role === 1 }
    <h3>You are a patient</h3>
  {:else if $currentUser.Role === 2 }
    <h3>You are a Caregiver</h3>
  {:else}
    <h3>Unknown user role?</h3>
  {/if} 


{:else}
  <p>Go to login page?</p>
  <button on:click={redirect}>Go</button>
{/if}

