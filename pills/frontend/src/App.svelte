<script>
  import CreateUser from './pages/CreateUser.svelte';
  import ViewUsers from './pages/ViewUsers.svelte';
  import Home from './pages/Home.svelte';
  import Welcome from './pages/Welcome.svelte';
  import NotFound from './pages/NotFound.svelte';
  import ForgotPassword from './pages/ForgotPassword.svelte';
  import ManagePatients from './pages/ManagePatients.svelte';
  import Schedules from './pages/Schedules.svelte';
  import EditSchedules from './pages/EditSchedules.svelte';
  import PatientSchedule from './pages/Calendar.svelte';
  import Router, { location } from 'svelte-spa-router'
  import { currentUser, logout } from './stores/auth';

  let sidebarCollapsed = false;

  function toggleSidebar() {
    sidebarCollapsed = !sidebarCollapsed;
  }

  function getRoleLabel(role) {
    if (role === 0) return 'Admin';
    if (role === 1) return 'Patient';
    if (role === 2) return 'Caregiver';
    return 'Unknown';
  }

  function getDisplayName(user) {
    if (!user) return '';
    return (
      user.UserName ||
      user.Name ||
      [user.FirstName, user.LastName].filter(Boolean).join(' ') ||
      user.Email ||
      'User'
    );
  }

  function getInitials(user) {
    const name = getDisplayName(user);
    if (!name) return '?';
    const parts = name.trim().split(/\s+/);
    if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  $: navItems = buildNavItems($currentUser);

  function buildNavItems(user) {
    if (!user) return [];
    if (user.Role === 1) {
      return [
        { href: '/', label: 'Dashboard', icon: 'grid' },
        { href: '/patient/calendar', label: 'Schedule', icon: 'calendar' },
      ];
    }
    if (user.Role === 2) {
      return [
        { href: '/', label: 'Dashboard', icon: 'grid' },
        { href: '/manage_patients', label: 'Patients', icon: 'users' },
        { href: '/schedules', label: 'Schedules', icon: 'calendar' },
        { href: '/edit_schedules', label: 'Edit Schedules', icon: 'edit' },
        { href: '/view_users', label: 'Users', icon: 'users' },
      ];
    }
    if (user.Role === 0) {
      return [
        { href: '/', label: 'Dashboard', icon: 'grid' },
        { href: '/view_users', label: 'Users', icon: 'users' },
      ];
    }
    return [];
  }

  $: activePath = '/' + ($location || '').replace(/^\/+/, '').split('?')[0];

  const routes = {
    '/': Home,
    '/welcome': Welcome,
    '/create_user': CreateUser,
    '/forgot_password': ForgotPassword,
    '/view_users': ViewUsers,
    '/manage_patients': ManagePatients,
    '/schedules': Schedules,
    '/edit_schedules': EditSchedules,
    '/patient/calendar': PatientSchedule,
    '*': NotFound
  }
</script>

{#if $currentUser}
  <div class="app-shell" class:collapsed={sidebarCollapsed}>
    <aside class="sidebar" aria-label="Primary navigation">
      <div class="brand-row">
        <div class="brand-logo" aria-hidden="true">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.5 13.5L4 20a3 3 0 0 1-4-4l6.5-6.5"/><path d="M20 4a3 3 0 0 0-4 0l-9 9a3 3 0 0 0 0 4l1 1 12-12-1-1z"/></svg>
        </div>
        <span class="brand-name">Pills</span>
        <button class="collapse-btn" on:click={toggleSidebar} aria-label="Toggle sidebar" title={sidebarCollapsed ? 'Expand' : 'Collapse'}>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            {#if sidebarCollapsed}
              <polyline points="9 18 15 12 9 6"/>
            {:else}
              <polyline points="15 18 9 12 15 6"/>
            {/if}
          </svg>
        </button>
      </div>

      <nav class="nav-primary">
        {#each navItems as item}
          <a
            href={`#${item.href}`}
            class="nav-link"
            class:active={activePath === item.href}
            title={item.label}
          >
            <span class="nav-icon" aria-hidden="true">
              {#if item.icon === 'grid'}
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
              {:else if item.icon === 'pill'}
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.5 20.5a7.07 7.07 0 0 1-10-10l9-9a7.07 7.07 0 0 1 10 10l-9 9z"/><line x1="8.5" y1="8.5" x2="15.5" y2="15.5"/></svg>
              {:else if item.icon === 'calendar'}
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
              {:else if item.icon === 'bar'}
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="20" x2="12" y2="10"/><line x1="18" y1="20" x2="18" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
              {:else if item.icon === 'users'}
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
              {:else if item.icon === 'edit'}
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
              {/if}
            </span>
            <span class="nav-label">{item.label}</span>
          </a>
        {/each}
      </nav>

      <div class="nav-footer">
        <a class="nav-link disabled" title="Settings">
          <span class="nav-icon" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
          </span>
          <span class="nav-label">Settings</span>
        </a>
        <a class="nav-link disabled" title="Help">
          <span class="nav-icon" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
          </span>
          <span class="nav-label">Help</span>
        </a>
      </div>
    </aside>

    <div class="main-area">
      <header class="topbar">
        <button class="mobile-toggle" on:click={toggleSidebar} aria-label="Toggle menu">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
        </button>
        <div class="topbar-spacer"></div>
        <div class="user-area">
          <div class="user-chip">
            <div class="avatar" aria-hidden="true">{getInitials($currentUser)}</div>
            <div class="user-meta">
              <span class="user-name">{getDisplayName($currentUser)}</span>
              <span class="user-role">{getRoleLabel($currentUser.Role)}</span>
            </div>
          </div>
          <button class="logout-btn" on:click={logout} title="Log out">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
            <span>Logout</span>
          </button>
        </div>
      </header>

      <main class="content">
        <Router {routes} />
      </main>
    </div>
  </div>
{:else}
  <main class="guest-main">
    <Router {routes} />
  </main>
{/if}

<style>
  .app-shell {
    display: grid;
    grid-template-columns: 240px 1fr;
    min-height: 100vh;
    background: #f3f4f6;
    transition: grid-template-columns 0.25s ease;
  }

  .app-shell.collapsed {
    grid-template-columns: 72px 1fr;
  }

  /* ---------- Sidebar ---------- */
  .sidebar {
    background: #ffffff;
    border-right: 1px solid var(--gr200);
    display: flex;
    flex-direction: column;
    padding: 20px 14px;
    gap: 18px;
    position: sticky;
    top: 0;
    height: 100vh;
    overflow: hidden;
  }

  .brand-row {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 0 6px 12px;
    border-bottom: 1px solid var(--gr100);
    position: relative;
  }

  .brand-logo {
    width: 36px;
    height: 36px;
    border-radius: 10px;
    background: linear-gradient(135deg, #3b82f6, #06b6d4);
    color: #fff;
    display: grid;
    place-items: center;
    flex-shrink: 0;
  }

  .brand-logo svg {
    width: 20px;
    height: 20px;
  }

  .brand-name {
    font-size: 18px;
    font-weight: 800;
    color: var(--gr800);
    letter-spacing: -0.01em;
    flex: 1;
    white-space: nowrap;
    overflow: hidden;
  }

  .collapse-btn {
    width: 28px;
    height: 28px;
    border-radius: 8px;
    border: 1px solid var(--gr200);
    background: #fff;
    color: var(--gr600);
    cursor: pointer;
    display: grid;
    place-items: center;
    transition: background 0.15s, color 0.15s;
    flex-shrink: 0;
  }

  .collapse-btn:hover {
    background: var(--gr100);
    color: var(--gr800);
  }

  .collapse-btn svg {
    width: 14px;
    height: 14px;
  }

  .nav-primary {
    display: flex;
    flex-direction: column;
    gap: 4px;
    flex: 1;
    overflow-y: auto;
  }

  .nav-footer {
    display: flex;
    flex-direction: column;
    gap: 4px;
    padding-top: 14px;
    border-top: 1px solid var(--gr100);
  }

  .nav-link {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 12px;
    border-radius: 10px;
    color: var(--gr600);
    font-weight: 600;
    font-size: 14px;
    cursor: pointer;
    transition: background 0.15s, color 0.15s;
    text-decoration: none;
    white-space: nowrap;
  }

  .nav-link:hover {
    background: var(--gr100);
    color: var(--gr800);
    text-decoration: none;
  }

  .nav-link.active {
    background: #e0ecff;
    color: #2563eb;
  }

  .nav-link.disabled {
    opacity: 0.5;
    cursor: default;
    pointer-events: none;
  }

  .nav-icon {
    width: 18px;
    height: 18px;
    display: grid;
    place-items: center;
    flex-shrink: 0;
  }

  .nav-icon svg {
    width: 18px;
    height: 18px;
  }

  .nav-label {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .app-shell.collapsed .brand-name,
  .app-shell.collapsed .nav-label {
    opacity: 0;
    width: 0;
    overflow: hidden;
  }

  .app-shell.collapsed .nav-link {
    justify-content: center;
    padding: 10px;
  }

  .app-shell.collapsed .brand-row {
    justify-content: center;
  }

  /* ---------- Top bar ---------- */
  .main-area {
    display: flex;
    flex-direction: column;
    min-width: 0;
  }

  .topbar {
    background: #ffffff;
    border-bottom: 1px solid var(--gr200);
    padding: 14px 28px;
    display: flex;
    align-items: center;
    gap: 16px;
    position: sticky;
    top: 0;
    z-index: 5;
  }

  .topbar-spacer {
    flex: 1;
  }

  .mobile-toggle {
    display: none;
    width: 36px;
    height: 36px;
    border-radius: 8px;
    border: 1px solid var(--gr200);
    background: #fff;
    color: var(--gr700);
    cursor: pointer;
    place-items: center;
  }

  .mobile-toggle svg {
    width: 18px;
    height: 18px;
  }

  .user-area {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .user-chip {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 6px 12px 6px 6px;
    background: var(--gr50);
    border-radius: 999px;
    border: 1px solid var(--gr200);
  }

  .avatar {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: linear-gradient(135deg, #3b82f6, #06b6d4);
    color: #fff;
    display: grid;
    place-items: center;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 0.02em;
  }

  .user-meta {
    display: flex;
    flex-direction: column;
    line-height: 1.15;
  }

  .user-name {
    font-weight: 700;
    color: var(--gr800);
    font-size: 13px;
  }

  .user-role {
    color: var(--gr500);
    font-size: 11px;
    font-weight: 600;
  }

  .logout-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    border: 1px solid var(--gr200);
    border-radius: 10px;
    background: #fff;
    color: var(--gr700);
    font-weight: 600;
    font-size: 13px;
    padding: 8px 12px;
    cursor: pointer;
    transition: background 0.15s, color 0.15s, border-color 0.15s;
  }

  .logout-btn svg {
    width: 14px;
    height: 14px;
  }

  .logout-btn:hover {
    background: #fef2f2;
    border-color: #fecaca;
    color: #dc2626;
  }

  /* ---------- Content ---------- */
  .content {
    padding: 28px;
    flex: 1;
    min-width: 0;
  }

  .guest-main {
    min-height: 100vh;
  }

  /* ---------- Responsive ---------- */
  @media (max-width: 860px) {
    .app-shell {
      grid-template-columns: 72px 1fr;
    }

    .app-shell .brand-name,
    .app-shell .nav-label {
      opacity: 0;
      width: 0;
      overflow: hidden;
    }

    .app-shell .nav-link {
      justify-content: center;
      padding: 10px;
    }

    .app-shell .brand-row {
      justify-content: center;
    }

    .collapse-btn {
      display: none;
    }
  }

  @media (max-width: 540px) {
    .content {
      padding: 16px;
    }

    .topbar {
      padding: 12px 16px;
    }

    .user-name {
      display: none;
    }

    .user-role {
      display: none;
    }

    .logout-btn span {
      display: none;
    }
  }
</style>
