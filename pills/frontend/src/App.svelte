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
  <nav class="navbar">
    {#if $currentUser}
      {#if $currentUser.Role === 1}
        <a href='#/'>Home</a>
        <a href='#/patient/calendar'>Calendar</a>
      {:else}
        <a href='#/'>Home</a>
        {#if $currentUser.Role === 0}
          <a href='#/view_users'>View Users</a>
        {/if}
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

  <Router {routes} />

</main>

<style>
  main {
    display: flex;
    flex-direction: column;
    align-items: center;
    min-height: 100vh;
  }

  .navbar {
    display: flex;
    gap: 20px;
    margin-top: 30px;
    padding: 10px;
    background: var(--b400);
    border-radius: var(--radius-sm);
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
  }

  .navbar a {
    color: white;
    font-weight: 600;
  }
</style>