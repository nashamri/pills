<script>
  import { login } from "../stores/auth";

  let email = "";
  let password = "";
  let rememberMe = true;
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

<div class="page">
  <div class="card">
    <div class="brand">
      <div class="logo">✓</div>
      <div></div>
    </div>

    <h2>Welcome</h2>
    <p class="subtitle">Sign in to access your medical system</p>

    {#if error}
      <p class="error-msg">{error}</p>
    {/if}

    <form on:submit={handleLogin}>
      <label for="email">Email</label>
      <input
        id="email"
        type="email"
        bind:value={email}
        placeholder="Enter your Email"
      />

      <label for="password">Password</label>
      <div class="password-wrap">
        <input
          id="password"
          type="password"
          value={password}
          on:input={(e) => (password = e.currentTarget.value)}
          placeholder="Enter your password"
        />
      </div>

      <div class="row">
        <label class="remember">
          <input type="checkbox" bind:checked={rememberMe} />
          <span>Remember me</span>
        </label>

        <a href="#/forgot_password" class="link">Forgot password?</a>
      </div>

      <button type="submit" class="login-btn" disabled={isLoading}>
        {isLoading ? "Logging in..." : "Log In"}
      </button>
    </form>

    <p class="signup">
      Don’t have an account?
      <a href="#/create_user">Create New Account</a>
    </p>
  </div>
</div>

<style>
  /* Component-specific styles using global CSS variables */
  .error-msg {
    background: var(--r50);
    border: 1px solid var(--r400);
    color: var(--r600);
    padding: 10px 14px;
    border-radius: var(--radius-sm);
    margin-bottom: 16px;
    text-align: center;
  }

  .page {
    padding: calc(16px + env(safe-area-inset-top, 0px))
      calc(16px + env(safe-area-inset-right, 0px))
      calc(16px + env(safe-area-inset-bottom, 0px))
      calc(16px + env(safe-area-inset-left, 0px));
  }

  .brand {
    display: flex;
    align-items: center;
    gap: 12px;
    justify-content: center;
    margin-bottom: 14px;
  }

  .logo {
    width: 46px;
    height: 46px;
    border-radius: var(--radius-md);
    display: grid;
    place-items: center;
    background: var(--t400);
    color: #fff;
    font-weight: 700;
    font-size: 24px;
  }

  h1 {
    font-size: 24px;
    color: var(--t600);
  }

  .brand p {
    margin: 2px 0 0;
    font-size: 13px;
    color: var(--gr400);
  }

  h2 {
    text-align: center;
    margin: 14px 0 6px;
    font-size: 30px;
    color: var(--gr900);
  }

  .subtitle {
    text-align: center;
    margin: 0 0 22px;
    color: var(--gr400);
    font-size: 16px;
  }

  form {
    display: grid;
    gap: 10px;
  }

  label {
    font-weight: 700;
    color: var(--gr800);
    font-size: 18px;
    margin-top: 4px;
  }

  input[type="email"],
  input[type="password"],
  input[type="text"] {
    border-radius: var(--radius-lg);
    height: 56px;
    padding: 0 16px;
    font-size: 24px;
  }

  .password-wrap {
    position: relative;
  }

  .row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 10px 12px;
    margin: 6px 0 8px;
  }

  .remember {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 20px;
    font-weight: 500;
    color: var(--gr700);
  }

  .remember input {
    width: 18px;
    height: 18px;
    accent-color: var(--b400);
  }

  .link {
    color: var(--t400);
    font-size: 20px;
    font-weight: 700;
  }

  .login-btn {
    margin-top: 4px;
    height: 62px;
    border: none;
    border-radius: var(--radius-lg);
    background: var(--t400);
    color: #fff;
    font-size: 36px;
    font-weight: 700;
    cursor: pointer;
    transition: background 0.15s;
  }

  .login-btn:hover:not(:disabled) {
    background: var(--t600);
  }

  .login-btn:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }

  .signup {
    margin-top: 18px;
    text-align: center;
    color: var(--gr500);
    font-size: 22px;
  }

  .signup a {
    margin-left: 8px;
    color: var(--t400);
    font-weight: 700;
  }

  @media (max-width: 520px) {
    .card {
      padding: 20px;
      border-radius: 18px;
    }

    h2 {
      font-size: 24px;
    }

    .subtitle {
      font-size: 14px;
    }

    label,
    .remember,
    .link,
    .signup {
      font-size: 16px;
    }

    .login-btn {
      font-size: 24px;
      height: 52px;
    }

    input[type="email"],
    input[type="password"],
    input[type="text"] {
      font-size: 18px;
      height: 50px;
    }
  }

  @media (max-width: 380px) {
    .row {
      flex-direction: column;
      align-items: stretch;
    }

    .row .link {
      text-align: center;
    }
  }
</style>
