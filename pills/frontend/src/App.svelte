<script>
  import CreateUser from './CreateUser.svelte'
  import UserList from './UserList.svelte'

  let refreshKey = 0

  function onUserCreated() {
    refreshKey += 1
  }
</script>

<main>
  <h1>User Management (CRUD)</h1>
  <CreateUser on:created={onUserCreated} />
  <UserList {refreshKey} />
</main>

<style>
  main {
    max-width: 1200px;
    margin: 0 auto;
    padding: 1.5rem;
  }

  h1 {
    text-align: left;
    margin: 0 0 1rem;
  }
</style>
