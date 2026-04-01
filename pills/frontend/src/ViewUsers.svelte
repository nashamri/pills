<script>
  import { onMount } from 'svelte';
  
  import { GetUsers, DeleteUser } from '../wailsjs/go/main/App.js';

  let users = [];
  let message = '';

 
  function fetchUsers() {
    GetUsers()
      .then((result) => {
        users = result;
      })
      .catch((err) => {
        message = 'Error loading users: ' + err;
      });
  }

  
  function handleDelete(id) {
    if (confirm('Are you sure you want to delete this user?')) {
      DeleteUser(id)
        .then(() => {
          message = 'User deleted successfully';
          fetchUsers(); 
        })
        .catch((err) => {
          message = 'Error deleting user: ' + err;
        });
    }
  }

 
  onMount(fetchUsers);

 
  function getRoleName(role) {
    const roles = ['Admin', 'Patient', 'Caregiver'];
    return roles[role] || 'Unknown';
  }
</script>

<main>
  <h2>Registered Users</h2>

  {#if message}
    <p class="status">{message}</p>
  {/if}

  {#if users.length === 0}
    <p>No users found in the database.</p>
  {:else}
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Username</th>
          <th>Email</th>
          <th>Gender</th>
          <th>Role</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        {#each users as user}
          <tr>
            <td>{user.FirstName} {user.LastName}</td>
            <td>{user.UserName}</td>
            <td>{user.Email}</td>
            <td>{user.Gender}</td>
            <td>{getRoleName(user.Role)}</td>
            <td>
              <button class="delete-btn" on:click={() => handleDelete(user.ID)}>
                Delete
              </button>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  {/if}
</main>

<style>
  main {
    padding: 20px;
    max-width: 900px;
    margin: auto;
    color: white;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
    background-color: #2c3e50; 
  }

  th, td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #444;
  }

  th {
    background-color: #1b2636;
  }

  .delete-btn {
    background-color: #e74c3c;
    color: white;
    border: none;
    padding: 6px 12px;
    border-radius: 4px;
    cursor: pointer;
    transition: background 0.2s;
  }

  .delete-btn:hover {
    background-color: #c0392b;
  }

  .status {
    background: #34495e;
    padding: 10px;
    border-radius: 5px;
    text-align: center;
    margin-bottom: 15px;
  }
</style>