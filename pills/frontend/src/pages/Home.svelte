<script>
  import { onMount } from "svelte";
  import { currentUser, logout } from "../stores/auth";
  import { push } from "svelte-spa-router";
  import { GetPatientSchedules } from "../../wailsjs/go/main/App.js";

  let schedules = [];
  let loadingSchedules = false;
  let scheduleError = "";

  function redirect() {
    push("/welcome");
  }

  function formatDate(value) {
    if (!value) return "-";
    const date = new Date(value);
    return date.toLocaleDateString();
  }

  function formatTime(value) {
    if (!value) return "-";
    const date = new Date(value);
    return date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  }

  async function loadPatientSchedules() {
    if (!$currentUser || $currentUser.Role !== 1) {
      return;
    }

    try {
      loadingSchedules = true;
      scheduleError = "";
      const loadedSchedules = await GetPatientSchedules($currentUser.ID);
      schedules = Array.isArray(loadedSchedules) ? loadedSchedules : [];
    } catch (error) {
      scheduleError = "Failed to load your medication schedules.";
    } finally {
      loadingSchedules = false;
    }
  }

  onMount(loadPatientSchedules);
</script>

{#if $currentUser}
  <button on:click={logout}>Logout</button>

  {#if $currentUser.Role === 0 }
    <h3>You are an Admin</h3>
  {:else if $currentUser.Role === 1 }
    <h3>You are a patient</h3>
    <div class="patient-schedules">
      <h4>Your Medications</h4>
      {#if loadingSchedules}
        <p>Loading medications...</p>
      {:else if scheduleError}
        <p class="error">{scheduleError}</p>
      {:else if schedules.length === 0}
        <p>No medications available.</p>
      {:else}
        <div class="schedule-list">
          {#each schedules as schedule}
            <div class="schedule-card">
              <div class="line"><strong>{schedule.Medication}</strong> ({schedule.MedicationType})</div>
              <div class="line">Dosage: {schedule.Dosage} | Quantity: {schedule.Quantity}</div>
              <div class="line">From {formatDate(schedule.StartDate)} to {formatDate(schedule.EndDate)}</div>
              <div class="line">Start time: {formatTime(schedule.StartHour)} | Every {schedule.IntervalHours} hour(s)</div>
              <div class="line">Instructions: {schedule.Instructions || "-"}</div>
            </div>
          {/each}
        </div>
      {/if}
    </div>
  {:else if $currentUser.Role === 2 }
    <h3>You are a Caregiver</h3>
  {:else}
    <h3>Unknown user role?</h3>
  {/if} 


{:else}
  <p>Go to login page?</p>
  <button on:click={redirect}>Go</button>
{/if}

<style>
  .patient-schedules {
    margin-top: 16px;
    width: min(760px, 96vw);
    background: #fff;
    border-radius: 12px;
    padding: 16px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  }

  .schedule-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .schedule-card {
    border: 1px solid #dbe1eb;
    border-radius: 10px;
    padding: 10px 12px;
    background: #f9fbff;
  }

  .line {
    font-size: 14px;
    margin-bottom: 4px;
  }

  .error {
    color: #b91c1c;
    font-weight: 600;
  }
</style>
