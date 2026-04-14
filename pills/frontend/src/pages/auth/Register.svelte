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
    gender: 'ذكر',
    password: '',
    confirmPassword: '',
    securityQuestion: 'اسم مدينة ولادتك؟',
    securityAnswer: ''
  };

  let pwStrength = 0;
  let pwText = 'أدخل كلمة المرور';
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
    const texts = ['أدخل كلمة المرور', 'ضعيفة', 'ضعيفة', 'متوسطة', 'قوية جداً ✓'];

    pwStrength = s * 25;
    pwColor = colors[s];
    pwText = 'القوة: ' + texts[s];
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
    <div class="ah" style="font-size:17px">اختر نوع حسابك</div>
    <div class="as">سيحدد هذا صلاحياتك في النظام</div>
    <div class="qr">
      <button class="qrc {regRole === 'patient' ? 'on' : ''}" on:click={() => regRole = 'patient'}>
        <div class="qrc-ico">🧓</div>
        <div class="qrc-l">مريض</div>
        <div class="qrc-s">متابعة الأدوية</div>
      </button>
      <button class="qrc {regRole === 'caregiver' ? 'on' : ''}" on:click={() => regRole = 'caregiver'}>
        <div class="qrc-ico">👨‍⚕️</div>
        <div class="qrc-l">مقدم رعاية</div>
        <div class="qrc-s">إدارة المرضى</div>
      </button>
      <button class="qrc {regRole === 'admin' ? 'on' : ''}" on:click={() => regRole = 'admin'}>
        <div class="qrc-ico">🛠</div>
        <div class="qrc-l">مشرف</div>
        <div class="qrc-s">إدارة النظام</div>
      </button>
    </div>
    <button class="cta" on:click={nextStep}>التالي ←</button>

  <!-- Step 2: Personal info -->
  {:else if currentStep === 2}
    <div class="ah" style="font-size:17px">البيانات الشخصية</div>
    <div class="as">أدخل معلوماتك الأساسية</div>
    <div class="f2">
      <div class="fg">
        <label class="fl">الاسم الأول *</label>
        <input class="fi" type="text" bind:value={formData.firstName} placeholder="محمد"/>
      </div>
      <div class="fg">
        <label class="fl">اسم العائلة *</label>
        <input class="fi" type="text" bind:value={formData.lastName} placeholder="العمري"/>
      </div>
    </div>
    <div class="fg">
      <label class="fl">البريد الإلكتروني *</label>
      <input class="fi" type="email" bind:value={formData.email} placeholder="example@email.com"/>
    </div>
    <div class="fg">
      <label class="fl">رقم الجوال *</label>
      <input class="fi" type="tel" bind:value={formData.phone} placeholder="+966 5X XXX XXXX"/>
    </div>
    <div class="f2">
      <div class="fg">
        <label class="fl">تاريخ الميلاد</label>
        <input class="fi" type="date" bind:value={formData.dob}/>
      </div>
      <div class="fg">
        <label class="fl">الجنس</label>
        <select class="fi" bind:value={formData.gender}>
          <option value="ذكر">ذكر</option>
          <option value="أنثى">أنثى</option>
        </select>
      </div>
    </div>
    <div class="f2">
      <button class="cta back-btn" on:click={prevStep}>→ السابق</button>
      <button class="cta" on:click={nextStep}>التالي ←</button>
    </div>

  <!-- Step 3: Password & security -->
  {:else if currentStep === 3}
    <div class="ah" style="font-size:17px">كلمة المرور والأمان</div>
    <div class="as">اختر كلمة مرور قوية</div>
    <div class="fg">
      <label class="fl">كلمة المرور *</label>
      <div class="pw">
        <input
          class="fi"
          type={showPassword ? 'text' : 'password'}
          value={formData.password}
          on:input={(e) => { formData.password = e.currentTarget.value; checkPwStrength(e.currentTarget.value); }}
          placeholder="8 أحرف على الأقل"
          style="padding-left:40px"
        />
        <button class="pw-e" type="button" on:click={() => showPassword = !showPassword}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
            <circle cx="12" cy="12" r="3"/>
          </svg>
        </button>
      </div>
      <div class="pw-bar" style="width:{pwStrength}%; background:{pwColor}"></div>
      <div class="fh" style="color:{pwColor}">{pwText}</div>
    </div>
    <div class="fg">
      <label class="fl">تأكيد كلمة المرور *</label>
      <div class="pw">
        <input
          class="fi"
          type={showConfirmPassword ? 'text' : 'password'}
          value={formData.confirmPassword}
          on:input={(e) => { formData.confirmPassword = e.currentTarget.value; }}
          placeholder="أعد الكتابة"
          style="padding-left:40px"
        />
        <button class="pw-e" type="button" on:click={() => showConfirmPassword = !showConfirmPassword}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
            <circle cx="12" cy="12" r="3"/>
          </svg>
        </button>
      </div>
    </div>
    <div class="fg">
      <label class="fl">سؤال الأمان</label>
      <select class="fi" bind:value={formData.securityQuestion}>
        <option>اسم مدينة ولادتك؟</option>
        <option>اسم مدرستك الأولى؟</option>
        <option>اسم حيوانك الأول؟</option>
      </select>
    </div>
    <div class="fg">
      <label class="fl">الإجابة</label>
      <input class="fi" type="text" bind:value={formData.securityAnswer} placeholder="الإجابة"/>
    </div>
    <div class="f2">
      <button class="cta back-btn" on:click={prevStep}>→ السابق</button>
      <button class="cta" on:click={handleRegister}>إنشاء الحساب ✓</button>
    </div>
  {/if}

  <div class="asw">لديك حساب؟ <button class="alink-btn" on:click={goToLogin}>تسجيل الدخول</button></div>
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