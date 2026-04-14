<script>
  import { createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher();


  let currentStep = 1;
  let regRole = 'patient';


  let formData = {
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    dob: '',
    gender: 'Male',
    password: '',
    confirmPassword: ''
  };


  let pwStrength = 0;
  let pwText = 'Enter password';
  let pwColor = 'var(--gr200)';
  let showPassword = false;
  let showConfirmPassword = false;


  function checkPwStrength(v) {
    let s = 0;
    if (v.length >= 8) s++;
    if (/[A-Z]/.test(v)) s++;
    if (/[0-9]/.test(v)) s++;
    if (/[^A-Za-z0-9]/.test(v)) s++;


    const colors = ['var(--gr200)', 'var(--r400)', 'var(--r400)', 'var(--a200)', 'var(--t400)'];
    const texts = ['Enter password', 'Weak', 'Weak', 'Medium', 'Very Strong ✓'];


    pwStrength = s * 25;
    pwColor = colors[s];
    pwText = 'Strength: ' + texts[s];
  }


  const nextStep = () => currentStep++;
  const prevStep = () => currentStep--;


  function handleRegister() {
    dispatch('success', { role: regRole });
  }


  function goToLogin() {
    dispatch('switch', { view: 'login' });
  }
</script>


<div class="auth-box">
  <!-- Step dots -->
  <div class="sdots">
    <div class="sdot {currentStep >= 1 ? 'on' : ''}"></div>
    <div class="sdot {currentStep >= 2 ? 'on' : ''}"></div>
    <div class="sdot {currentStep >= 3 ? 'on' : ''}"></div>
  </div>


  <!-- Step 1: Role selection -->
  {#if currentStep === 1}
    <div class="ah" style="font-size:17px">Select your account type</div>
    <div class="as">This will determine your permissions in the system</div>
    <div class="qr">
      <button class="qrc {regRole === 'patient' ? 'on' : ''}" on:click={() => regRole = 'patient'}>
        <div class="qrc-ico">🧓</div>
        <div class="qrc-l">Patient</div>
        <div class="qrc-s">Medication tracking</div>
      </button>
      <button class="qrc {regRole === 'caregiver' ? 'on' : ''}" on:click={() => regRole = 'caregiver'}>
        <div class="qrc-ico">👨‍⚕️</div>
        <div class="qrc-l">Caregiver</div>
        <div class="qrc-s">Patient management</div>
      </button>
      <button class="qrc {regRole === 'admin' ? 'on' : ''}" on:click={() => regRole = 'admin'}>
        <div class="qrc-ico">🛠</div>
        <div class="qrc-l">Admin</div>
        <div class="qrc-s">System management</div>
      </button>
    </div>
    <button class="cta" on:click={nextStep}>Next ←</button>


  <!-- Step 2: Personal info -->
  {:else if currentStep === 2}
    <div class="ah" style="font-size:17px">Personal Information</div>
    <div class="as">Enter your basic information</div>
    <div class="f2">
      <div class="fg">
       <label> class="fl">First Name *</label>
        <input class="fi" type="text" bind:value={formData.firstName} placeholder="First Name"/>
      </div>
      <div class="fg">
          <label> class="fl">Last Name *</label>
        <input class="fi" type="text" bind:value={formData.lastName} placeholder="Last Name"/>
      </div>
    </div>
    <div class="fg">
        <label> class="fl">Email *</label>
      <input class="fi" type="email" bind:value={formData.email} placeholder="Enter your Email"/>
    </div>
    <div class="fg">
        <label> class="fl">Phone Number *</label>
      <input class="fi" type="tel" bind:value={formData.phone} placeholder="Phone Numbe"/>
    </div>
    <div class="f2">
      <div class="fg">
          <label> class="fl">Date of Birth</label>
        <input class="fi" type="date" bind:value={formData.dob}/>
      </div>
      <div class="fg">
          <label> class="fl">Gender</label>
        <select class="fi" bind:value={formData.gender}>
          <option value="Male">Male</option>
          <option value="Female">Female</option>
        </select>
      </div>
    </div>
    <div class="f2">
      <button class="cta back-btn" on:click={prevStep}>← Back</button>
      <button class="cta" on:click={nextStep}>Next ←</button>
    </div>


  <!-- Step 3: Password -->
  {:else if currentStep === 3}
    <div class="ah" style="font-size:17px">Password</div>
    <div class="as">Choose a strong password</div>
    <div class="fg">
        <label> class="fl">Password *</label>
      <div class="pw">
        <input
          class="fi"
          type={showPassword ? 'text' : 'password'}
          value={formData.password}
          on:input={(e) => { formData.password = e.currentTarget.value; checkPwStrength(e.currentTarget.value); }}
          placeholder="At least 8 characters"
          style="padding-left:40px"
        />
        <button class="pw-e" type="button" on:click={() => showPassword = !showPassword}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
            ircle cx="12" cy="12" r="3"/>
          </svg>
        </button>
      </div>
      <div class="pw-bar" style="width:{pwStrength}%; background:{pwColor}"></div>
      <div class="fh" style="color:{pwColor}">{pwText}</div>
    </div>
    <div class="fg">
        <label> class="fl">Confirm Password *</label>
      <div class="pw">
        <input
          class="fi"
          type={showConfirmPassword ? 'text' : 'password'}
          value={formData.confirmPassword}
          on:input={(e) => { formData.confirmPassword = e.currentTarget.value; }}
          placeholder="Re-type"
          style="padding-left:40px"
        />
        <button class="pw-e" type="button" on:click={() => showConfirmPassword = !showConfirmPassword}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
            ircle cx="12" cy="12" r="3"/>
          </svg>
        </button>
      </div>
    </div>
    <div class="f2">
      <button class="cta back-btn" on:click={prevStep}>← Back</button>
      <button class="cta" on:click={handleRegister}>Create Account ✓</button>
    </div>
  {/if}


  <div class="asw">Already have an account? <button class="alink-btn" on:click={goToLogin}>Sign In</button></div>
</div>


<style>
  :root {
    --t50:#E1F5EE; --t100:#9FE1CB; --t400:#1D9E75; --t600:#0F6E56; --t800:#085041;
    --b50:#E6F1FB; --b400:#378ADD; --b600:#185FA5;
    --a50:#FAEEDA; --a200:#EF9F27; --a600:#854F0B;
    --r50:#FCEBEB; --r100:#F7C1C1; --r400:#E24B4A; --r600:#A32D2D;
    --gr100:#F1F5F9; --gr200:#E2E8F0; --gr300:#CBD5E1; --gr400:#94A3B8;
    --gr500:#64748B; --gr600:#475569; --gr700:#334155; --gr800:#1E293B;
  }


  .auth-box {
    background: #fff;
    border-radius: 24px;
    box-shadow: 0 8px 40px rgba(0,0,0,.12);
    padding: 40px;
    width: 100%;
    max-width: 460px;
    max-height: 95vh;
    overflow-y: auto;
    font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
  }


  .sdots {
    display: flex;
    gap: 6px;
    justify-content: center;
    margin-bottom: 20px;
  }
  .sdot {
    height: 5px;
    border-radius: 3px;
    background: var(--gr200);
    transition: all .2s;
    flex: 1;
    max-width: 40px;
  }
  .sdot.on { background: var(--t400); }


  .ah {
    font-size: 20px;
    font-weight: 700;
    text-align: center;
    margin-bottom: 4px;
    color: var(--gr800);
  }
  .as {
    font-size: 13px;
    color: var(--gr400);
    text-align: center;
    margin-bottom: 24px;
  }


  .fg { margin-bottom: 14px; }
  .fl {
    display: block;
    font-size: 12px;
    font-weight: 700;
    color: var(--gr600);
    margin-bottom: 5px;
    text-transform: uppercase;
    letter-spacing: .04em;
  }
  .fi {
    width: 100%;
    padding: 10px 13px;
    border-radius: 8px;
    border: 1.5px solid var(--gr200);
    font-size: 14px;
    color: var(--gr800);
    font-family: inherit;
    outline: none;
    background: #fff;
    transition: border .15s;
    box-sizing: border-box;
  }
  .fi:focus {
    border-color: var(--t400);
    box-shadow: 0 0 0 3px rgba(29,158,117,.1);
  }


  /* password wrapper */
  .pw { position: relative; }
  .pw-e {
    position: absolute;
    left: 10px;
    top: 50%;
    transform: translateY(-50%);
    cursor: pointer;
    color: var(--gr400);
    background: none;
    border: none;
    padding: 4px;
    display: flex;
    align-items: center;
  }
  .pw-e:hover { color: var(--gr600); }


  .pw-bar {
    height: 4px;
    border-radius: 2px;
    margin-top: 5px;
    transition: all .3s;
    background: var(--gr200);
  }
  .fh {
    font-size: 11px;
    color: var(--gr400);
    margin-top: 3px;
  }


  .f2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }


  .qr {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 8px;
    margin-bottom: 18px;
  }
  .qrc {
    border: 2px solid var(--gr200);
    border-radius: 12px;
    padding: 12px 6px;
    text-align: center;
    cursor: pointer;
    background: #fff;
    font-family: inherit;
    transition: all .18s;
  }
  .qrc:hover {
    border-color: var(--t100);
    background: var(--t50);
    transform: translateY(-2px);
  }
  .qrc.on {
    border-color: var(--t400);
    background: var(--t50);
    box-shadow: 0 0 0 3px rgba(29,158,117,.15);
  }
  .qrc-ico { font-size: 26px; margin-bottom: 5px; }
  .qrc-l { font-size: 12px; font-weight: 700; color: var(--gr800); }
  .qrc-s { font-size: 10px; color: var(--gr400); }


  .cta {
    width: 100%;
    padding: 12px;
    border-radius: 8px;
    border: none;
    background: var(--t400);
    color: #fff;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    transition: all .15s;
    margin-top: 6px;
    font-family: inherit;
  }
  .cta:hover {
    background: var(--t600);
    transform: translateY(-1px);
    box-shadow: 0 4px 14px rgba(29,158,117,.3);
  }
  .back-btn {
    background: var(--gr100);
    color: var(--gr700);
  }
  .back-btn:hover {
    background: var(--gr200);
    box-shadow: none;
    transform: none;
  }


  .asw {
    text-align: center;
    font-size: 13px;
    color: var(--gr500);
    margin-top: 16px;
  }
  .alink-btn {
    color: var(--t400);
    border: none;
    background: none;
    cursor: pointer;
    font-weight: 600;
    font-family: inherit;
    font-size: 13px;
  }
  .alink-btn:hover { color: var(--t600); }
</style>