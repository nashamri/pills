<script>
  import { onMount } from 'svelte';
  import { GetUsers, DeleteUser, UpdateUser } from '../../wailsjs/go/main/App.js';

  const roles = ['Admin', 'Patient', 'Caregiver'];
  const genders = ['Male', 'Female'];

  let users = [];
  let message = '';
  let isError = false;
  let isSaving = false;
  let editingId = null;
  let editForm = {
    firstName: '',
    lastName: '',
    username: '',
    email: '',
    password: '',
    gender: 'Male',
    role: 1
  };

  function fetchUsers() {
    GetUsers()
      .then((result) => {
        users = result;
      })
      .catch((err) => {
        isError = true;
        message = 'Error loading users: ' + err;
      });
  }

  function clearStatus() {
    message = '';
    isError = false;
  }

  function startEdit(user) {
    clearStatus();
    editingId = user.ID;
    editForm = {
      firstName: user.FirstName,
      lastName: user.LastName,
      username: user.UserName,
      email: user.Email,
      password: user.Password,
      gender: user.Gender || 'Male',
      role: Number(user.Role)
    };
  }

  function cancelEdit() {
    editingId = null;
  }

  function handleDelete(id) {
    clearStatus();
    if (confirm('Are you sure you want to delete this user?')) {
      DeleteUser(id)
        .then(() => {
          message = 'User deleted successfully.';
          fetchUsers();
          if (editingId === id) {
            cancelEdit();
          }
        })
        .catch((err) => {
          isError = true;
          message = 'Error deleting user: ' + err;
        });
    }
  }

  function handleUpdate() {
    if (editingId === null) {
      return;
    }

    clearStatus();
    isSaving = true;
    UpdateUser(
      editingId,
      editForm.firstName,
      editForm.lastName,
      editForm.username,
      editForm.email,
      editForm.password,
      editForm.gender,
      Number(editForm.role)
    )
      .then(() => {
        message = 'User updated successfully.';
        cancelEdit();
        fetchUsers();
      })
      .catch((err) => {
        isError = true;
        message = 'Error updating user: ' + err;
      })
      .finally(() => {
        isSaving = false;
      });
  }

  onMount(fetchUsers);

  function getRoleName(role) {
    return roles[role] || 'Unknown';
  }
</script>

<main>
  <section class="panel">
    <h2>User Directory</h2>
    <p class="subtitle">Manage records, update profile details, and keep account roles correct.</p>

    {#if message}
      <p class:error={isError} class="status">{message}</p>
    {/if}

    {#if users.length === 0}
      <p class="empty">No users found in the database.</p>
    {:else}
      <div class="table-wrap">
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
              <tr class:active-row={editingId === user.ID}>
                <td>{user.FirstName} {user.LastName}</td>
                <td>{user.UserName}</td>
                <td>{user.Email}</td>
                <td>{user.Gender}</td>
                <td>{getRoleName(user.Role)}</td>
                <td class="actions">
                  <button class="edit-btn" on:click={() => startEdit(user)}>Edit</button>
                  <button class="delete-btn" on:click={() => handleDelete(user.ID)}>Delete</button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </section>

  {#if editingId !== null}
    <section class="panel editor">
      <h3>Editing User #{editingId}</h3>
      <form on:submit|preventDefault={handleUpdate}>
        <div class="grid">
          <input bind:value={editForm.firstName} placeholder="First Name" required />
          <input bind:value={editForm.lastName} placeholder="Last Name" required />
          <input bind:value={editForm.username} placeholder="Username" required />
          <input bind:value={editForm.email} type="email" placeholder="Email" required />
          <input bind:value={editForm.password} type="text" placeholder="Password" required />

          <select bind:value={editForm.gender}>
            {#each genders as gender}
              <option value={gender}>{gender}</option>
            {/each}
          </select>

          <select bind:value={editForm.role}>
            {#each roles as roleLabel, index}
              <option value={index}>{roleLabel}</option>
            {/each}
          </select>
        </div>

        <div class="form-actions">
          <button class="save-btn" type="submit" disabled={isSaving}>
            {isSaving ? 'Saving...' : 'Save Changes'}
          </button>
          <button class="cancel-btn" type="button" on:click={cancelEdit}>Cancel</button>
        </div>
      </form>
    </section>
  {/if}
</main>

<style>
  /* Component-specific styles using global CSS variables */
  main {
    width: min(980px, 94vw);
    margin: 2rem auto 3rem;
    display: grid;
    gap: 1.25rem;
    color: var(--text-dark);
  }

  .panel {
    background: linear-gradient(160deg, rgba(15, 23, 42, 0.92), rgba(12, 18, 36, 0.92));
    border: 1px solid var(--line-dark);
    border-radius: var(--radius-lg);
    padding: 1.25rem;
    box-shadow: 0 14px 38px rgba(0, 0, 0, 0.35);
  }

  h2, h3 {
    margin: 0 0 0.5rem;
    letter-spacing: 0.02em;
  }

  .subtitle {
    margin: 0 0 1rem;
    color: var(--muted-dark);
  }

  .table-wrap {
    overflow-x: auto;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    background: rgba(10, 14, 28, 0.82);
    border-radius: 10px;
    overflow: hidden;
  }

  th,
  td {
    text-align: left;
    padding: 0.8rem 0.75rem;
    border-bottom: 1px solid rgba(116, 147, 203, 0.2);
    white-space: nowrap;
  }

  th {
    font-size: 0.83rem;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: #bcd5ff;
    background: rgba(20, 30, 53, 0.85);
  }

  .active-row {
    background: rgba(56, 189, 248, 0.12);
  }

  .actions {
    display: flex;
    gap: 0.5rem;
  }

  button {
    border: 1px solid transparent;
    border-radius: var(--radius-sm);
    padding: 0.5rem 0.72rem;
    color: #fff;
    cursor: pointer;
    font-weight: 600;
    transition: transform 130ms ease, opacity 130ms ease, background 130ms ease;
  }

  button:hover {
    transform: translateY(-1px);
  }

  button:disabled {
    cursor: not-allowed;
    opacity: 0.6;
    transform: none;
  }

  .edit-btn {
    background: linear-gradient(120deg, var(--accent-dark-strong), #0ea5e9);
  }

  .delete-btn {
    background: linear-gradient(120deg, var(--danger), var(--danger-strong));
  }

  .status {
    background: rgba(34, 197, 94, 0.16);
    border: 1px solid rgba(34, 197, 94, 0.4);
    color: #bbf7d0;
    border-radius: 8px;
    padding: 0.65rem 0.8rem;
    margin: 0 0 1rem;
  }

  .status.error {
    background: rgba(248, 113, 113, 0.15);
    border-color: rgba(248, 113, 113, 0.4);
    color: #fecaca;
  }

  .empty {
    color: var(--muted-dark);
  }

  .editor form {
    display: grid;
    gap: 0.8rem;
  }

  .grid {
    display: grid;
    gap: 0.65rem;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  }

  input,
  select {
    background: rgba(13, 22, 42, 0.92);
    color: var(--text-dark);
    border: 1px solid rgba(125, 211, 252, 0.25);
    border-radius: var(--radius-sm);
    padding: 0.62rem 0.72rem;
    outline: none;
  }

  input:focus,
  select:focus {
    border-color: var(--accent-dark);
    box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.15);
  }

  .form-actions {
    display: flex;
    gap: 0.55rem;
  }

  .save-btn {
    background: linear-gradient(120deg, #10b981, #22c55e);
  }

  .cancel-btn {
    background: #3b465f;
  }
</style>