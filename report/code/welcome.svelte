<script>
  import { login } from "../stores/auth";

  let email = "";
  let password = "";
  let error = "";
  let isLoading = false;

  async function handleLogin(event) {
    event.preventDefault();
    error = "";
    isLoading = true;
    try {
      await login(email, password);
    } catch (err) {
      error = "Invalid email or password";
    } finally {
      isLoading = false;
    }
  }
</script>

<form on:submit={handleLogin}>
  <label for="email">Email</label>
  <input id="email" type="email" bind:value={email}
         placeholder="Enter your Email" />

  <label for="password">Password</label>
  <input id="password" type="password" bind:value={password}
         placeholder="Enter your password" />

  <button type="submit" class="login-btn" disabled={isLoading}>
    {isLoading ? "Logging in..." : "Log In"}
  </button>
</form>
