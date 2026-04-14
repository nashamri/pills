<script>
    let email = "";
    let password = "";
    let rememberMe = true;
    let showPassword = false;
  
    function togglePassword() {
      showPassword = !showPassword;
    }
  
    function handleLogin(event) {
      event.preventDefault();
      
      console.log({ email, password, rememberMe });
    }
  </script>
  
  <div class="page">
    <div class="card">
      <div class="brand">
        <div class="logo">✓</div>
        <div>
          
          
        </div>
      </div>
  
      <h2>Welcome Back</h2>
      <p class="subtitle">Sign in to access your medical system</p>
  
      <form on:submit={handleLogin}>
        <label for="email">Email</label>
        <input id="email" type="email" bind:value={email} placeholder="      Enter your Email" />
  
        <label for="password">Password</label>
        <div class="password-wrap">
          <button type="button" class="eye" on:click={togglePassword} aria-label="Toggle password visibility">
           
          </button>
          <input
       id="password"
        type={showPassword ? "text" : "password"}
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
  
          <a href="#/forgot-password" class="link">Forgot password?</a>
        </div>
  
        <button type="submit" class="login-btn">Log In</button>
      </form>
  
      <p class="signup">
        Don’t have an account?
        <a href="#/create_user">Create New Account</a>
      </p>
    </div>
  </div>
  
  <style>
    :global(body) {
      margin: 0;
      font-family: "Segoe UI", Tahoma, Arial, sans-serif;
      background: #b0b4ba;
      color: #0f172a;
    }
  
    .page {
      min-height: 100vh;
      min-height: 100dvh;
      display: grid;
      place-items: center;
      padding: calc(16px + env(safe-area-inset-top, 0px))
        calc(16px + env(safe-area-inset-right, 0px))
        calc(16px + env(safe-area-inset-bottom, 0px))
        calc(16px + env(safe-area-inset-left, 0px));
      box-sizing: border-box;
    }
  
    .card {
      width: 100%;
      max-width: 460px;
      box-sizing: border-box;
      background: #fff;
      border-radius: 22px;
      padding: 28px;
      box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
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
      border-radius: 12px;
      display: grid;
      place-items: center;
      background: #26a17b;
      color: #fff;
      font-weight: 700;
      font-size: 24px;
    }
  
    h1 {
      font-size: 24px;
      margin: 0;
      color: #0f766e;
    }
  
    .brand p {
      margin: 2px 0 0;
      font-size: 13px;
      color: #94a3b8;
    }
  
    h2 {
      text-align: center;
      margin: 14px 0 6px;
      font-size: 30px;
      color: #0f172a;
    }
  
    .subtitle {
      text-align: center;
      margin: 0 0 22px;
      color: #94a3b8;
      font-size: 16px;
    }
  
    form {
      display: grid;
      gap: 10px;
    }
  
    label {
      font-weight: 700;
      color: #1e293b;
      font-size: 18px;
      margin-top: 4px;
    }
  
    input[type="email"],
    input[type="password"],
    input[type="text"] {
      width: 100%;
      box-sizing: border-box;
      border: 1px solid #e2e8f0;
      border-radius: 14px;
      height: 56px;
      padding: 0 16px;
      font-size: 24px;
      outline: none;
      background: #fff;
      color: #0f172a;
    }
  
    input:focus {
      border-color: #26a17b;
      box-shadow: 0 0 0 3px rgba(38, 161, 123, 0.12);
    }
  
    .password-wrap {
      position: relative;
    }
  
    .password-wrap input {
      padding-left: 54px;
    }
  
    .eye {
      position: absolute;
      left: 12px;
      top: 50%;
      transform: translateY(-50%);
      border: none;
      background: transparent;
      cursor: pointer;
      font-size: 20px;
      opacity: 0.65;
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
      color: #334155;
    }
  
    .remember input {
      width: 18px;
      height: 18px;
      accent-color: #2563eb;
    }
  
    .link {
      color: #26a17b;
      text-decoration: none;
      font-size: 20px;
      font-weight: 700;
    }
  
    .link:hover {
      text-decoration: underline;
    }
  
    .login-btn {
      margin-top: 4px;
      height: 62px;
      border: none;
      border-radius: 14px;
      background: #26a17b;
      color: #fff;
      font-size: 36px;
      font-weight: 700;
      cursor: pointer;
    }
  
    .login-btn:hover {
      background: #218f6d;
    }
  
    .signup {
      margin-top: 18px;
      text-align: center;
      color: #64748b;
      font-size: 22px;
    }
  
    .signup a {
      margin-left: 8px;
      color: #26a17b;
      font-weight: 700;
      text-decoration: none;
    }
  
    .signup a:hover {
      text-decoration: underline;
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
        /* 16px+ avoids iOS zooming the page on input focus */
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
