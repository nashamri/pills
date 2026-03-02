<script>
  import { CreateUser } from '../wailsjs/go/main/App.js';

  let firstName = '';
  let lastName = '';
  let username = '';
  let email = '';
  let password = '';
  let gender = 'Male';
  let role = 1; 
  let message = '';

  async function handleSubmit() {
    try {
     
      message = await CreateUser(firstName, lastName, username, email, password, gender, parseInt(role));
      
      
      if (message.includes("successfully")) {
        firstName = lastName = username = email = password = '';
      }
    } catch (err) {
      message = "System error: " + err;
    }
  }
</script>

<main>
  <h2>Create New User</h2>
  
  <form on:submit|preventDefault={handleSubmit}>
    <input bind:value={firstName} placeholder="First Name" required />
    <input bind:value={lastName} placeholder="Last Name" required />
    <input bind:value={username} placeholder="Username" required />
    <input bind:value={email} type="email" placeholder="Email" required />
    <input bind:value={password} type="password" placeholder="Password" required />
    
    <select bind:value={gender}>
      <option value="Male">Male</option>
      <option value="Female">Female</option>
    </select>

    <select bind:value={role}>
      <option value={0}>Admin</option>
      <option value={1}>Patient</option>
      <option value={2}>Caregiver</option>
    </select>

    <button type="submit">Save to DB</button>
  </form>

  {#if message}
    <p class="status">{message}</p>
  {/if}
</main>

<style>
  form { display: flex; flex-direction: column; gap: 10px; max-width: 300px; margin: auto; }
  input, select, button { padding: 8px; border-radius: 4px; border: 1px solid #ccc; }
  button { background-color: #1b2636; color: white; cursor: pointer; }
  .status { text-align: center; margin-top: 15px; font-weight: bold; }
</style>