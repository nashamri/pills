<script>
  let email = '';

  function handleSubmit() {
    
  }
</script>

<div class="page" dir="rtl">
  <div class="card">
    <a href="#/welcome" class="back-link">Back ←</a>

    <h1 class="title">Password recovery</h1>
    <p class="subtitle">Enter your email and we will send you a verification code</p>

    <form class="form" on:submit|preventDefault={handleSubmit}>
      <label class="field-label" for="recovery-email">email</label>
      <input
        id="recovery-email"
        type="email"
        class="input"
        placeholder="example@email.com"
        bind:value={email}
        autocomplete="email"
      />

      <button type="submit" class="submit-btn" dir="rtl">
        <span class="btn-text">Send verification code</span>
        <span class="btn-icon" aria-hidden="true">
          <svg width="30" height="30" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect x="3" y="9" width="26" height="15" rx="2.5" fill="#7c3aed" />
            <path d="M3 11.5L16 19.5L29 11.5" stroke="#fff" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round" />
            <text x="16" y="20" text-anchor="middle" fill="white" font-size="12" font-weight="700" font-family="system-ui, sans-serif">@</text>
          </svg>
        </span>
      </button>
    </form>
  </div>
</div>

<style>
  .page {
    width: 100%;
    max-width: 440px;
    margin: 0 auto;
    min-height: calc(100vh - 100px);
    padding: 1.5rem 1rem 2rem;
    box-sizing: border-box;
    display: flex;
    align-items: flex-start;
    justify-content: center;
    background: #d8e4f0;
    color: #0f2744;
    font-family:
      system-ui,
      -apple-system,
      'Segoe UI',
      Tahoma,
      sans-serif;
    border-radius: 0 0 1rem 1rem;
  }

  .card {
    width: 100%;
    background: #fff;
    border-radius: 1.5rem;
    padding: 1.25rem 1.5rem 1.75rem;
    box-shadow: 0 4px 24px rgba(15, 39, 68, 0.08);
    text-align: right;
    position: relative;
  }

  .back-link {
    display: inline-block;
    margin-bottom: 0.5rem;
    font-size: 0.9375rem;
    font-weight: 600;
    color: #2d8a5c;
    text-decoration: none;
  }

  .back-link:hover {
    text-decoration: underline;
  }

  .title {
    margin: 0.5rem 0 0.5rem;
    font-size: 1.5rem;
    font-weight: 700;
    color: #0f2744;
    line-height: 1.35;
    text-align: center;
  }

  .subtitle {
    margin: 0 0 1.5rem;
    font-size: 0.875rem;
    color: #5a6d82;
    line-height: 1.5;
    text-align: center;
  }

  .form {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .field-label {
    font-size: 0.9375rem;
    font-weight: 600;
    color: #0f2744;
    text-align: right;
  }

  .input {
    width: 100%;
    box-sizing: border-box;
    padding: 0.875rem 1rem;
    font-size: 1rem;
    border: 1px solid #c5d0dc;
    border-radius: 0.75rem;
    background: #fff;
    color: #0f2744;
    text-align: right;
    direction: rtl;
  }

  .input::placeholder {
    color: #9ca8b8;
    text-align: right;
  }

  .input:focus {
    outline: none;
    border-color: #2d8a5c;
    box-shadow: 0 0 0 3px rgba(45, 138, 92, 0.15);
  }

  .submit-btn {
    margin-top: 1.25rem;
    width: 100%;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    gap: 0.75rem;
    padding: 0.95rem 1.25rem;
    border: none;
    border-radius: 0.875rem;
    background: #2d8a5c;
    color: #fff;
    font-size: 1rem;
    font-weight: 700;
    cursor: pointer;
    font-family: inherit;
  }

  .submit-btn:hover {
    background: #26734d;
  }

  .submit-btn:active {
    transform: scale(0.99);
  }

  .btn-text {
    flex: 0 1 auto;
  }

  .btn-icon {
    display: flex;
    flex-shrink: 0;
    line-height: 0;
  }

  .btn-icon svg {
    display: block;
  }
</style>
