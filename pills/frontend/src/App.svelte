<script>
  import CreateUser from './pages/CreateUser.svelte';
  import ViewUsers from './pages/ViewUsers.svelte';
  import Home from './pages/Home.svelte';
  import Welcome from './pages/Welcome.svelte';
  import NotFound from './pages/NotFound.svelte';
  import ForgotPassword from './pages/ForgotPassword.svelte';
  import ManagePatients from './pages/ManagePatients.svelte';
  import Schedules from './pages/Schedules.svelte';
  import PatientSchedule from './pages/calendar.svelte';
  import Router from 'svelte-spa-router'
  import { currentUser } from './stores/auth';

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

  const routes = {
    '/': Home,
    '/welcome': Welcome,
    '/create_user': CreateUser,
    '/forgot_password': ForgotPassword,
    '/view_users': ViewUsers,
    '/manage_patients': ManagePatients,
    '/schedules': Schedules,
    '/patient/calendar': PatientSchedule,
    '*': NotFound
  }
</script>

<main>
  <div class="top-bar">
    <nav class="navbar">
      {#if $currentUser}
        {#if $currentUser.Role === 1}
          <a href='#/'>Home</a>
          <a href='#/patient/calendar'>Calendar</a>
        {:else}
          <a href='#/'>Home</a>
          <a href='#/view_users'>View Users</a>
          {#if $currentUser.Role === 2}
            <a href='#/manage_patients'>Manage Patients</a>
            <a href='#/schedules'>Schedules</a>
          {/if}
        {/if}
      {:else}
        <a href='#/'>Home</a>
        <a href='#/welcome'>Welcome</a>
      {/if}
    </nav>

    {#if $currentUser}
      <div class="user-chip">
        <span class="user-name">{getDisplayName($currentUser)}</span>
        <span class="user-role">({getRoleLabel($currentUser.Role)})</span>
      </div>
    {/if}
  </div>

  <Router {routes} />

</main>

<style>
  main {
    display: flex;
    flex-direction: column;
    align-items: center;
    min-height: 100vh;
    width: 100%;
  }

  .top-bar {
    width: min(1200px, 96vw);
    margin-top: 30px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    flex-wrap: wrap;
  }

  .navbar {
    display: flex;
    gap: 20px;
    padding: 10px;
    background: var(--b400);
    border-radius: var(--radius-sm);
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
  }

  .navbar a {
    color: white;
    font-weight: 600;
  }

  .user-chip {
    display: flex;
    align-items: baseline;
    gap: 8px;
    background: #ffffff;
    border: 1px solid rgba(37, 169, 136, 0.35);
    border-radius: var(--radius-sm);
    padding: 8px 12px;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
  }

  .user-name {
    font-weight: 700;
    color: var(--t400);
  }

  .user-role {
    color: var(--t400);
    font-size: 14px;
    font-weight: 600;
  }
</style>