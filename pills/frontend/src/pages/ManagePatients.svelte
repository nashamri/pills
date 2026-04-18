<script>
  import { onMount } from "svelte";
  import { currentUser } from "../stores/auth";
  import {
    GetCaregiverPatients,
    GetAllPatients,
    AddPatientToCaregiver,
    RemovePatientFromCaregiver,
  } from "../../wailsjs/go/main/App.js";
  import { push } from "svelte-spa-router";

  let connectedPatients = [];
  let allPatients = [];
  let message = "";
  let messageType = "";

  $: availablePatients = allPatients.filter(
    (p) => !connectedPatients.some((cp) => cp.ID === p.ID)
  );

  async function loadData() {
    if (!$currentUser || $currentUser.Role !== 2) {
      push("/");
      return;
    }
    try {
      connectedPatients = await GetCaregiverPatients($currentUser.ID);
      allPatients = await GetAllPatients();
      message = "";
    } catch (error) {
      message = "Failed to load patient data.";
      messageType = "error";
    }
  }

  async function addPatient(patientId) {
    try {
      await AddPatientToCaregiver($currentUser.ID, patientId);
      await loadData();
      message = "Patient added successfully.";
      messageType = "success";
    } catch (error) {
      message = "Failed to add patient.";
      messageType = "error";
    }
  }

  async function removePatient(patientId) {
    try {
      await RemovePatientFromCaregiver($currentUser.ID, patientId);
      await loadData();
      message = "Patient removed successfully.";
      messageType = "success";
    } catch (error) {
      message = "Failed to remove patient.";
      messageType = "error";
    }
  }

  onMount(loadData);
</script>

<div class="manage-box">
  <div class="ah">Manage Patients</div>
  <div class="as">Add or remove patients from your care</div>

  {#if message}
    <p class="status {messageType}">{message}</p>
  {/if}

  <div class="section">
    <h3 class="section-title">Your Patients</h3>
    {#if connectedPatients.length === 0}
      <p class="empty-text">No patients connected yet.</p>
    {:else}
      <div class="patient-list">
        {#each connectedPatients as patient}
          <div class="patient-card">
            <div class="patient-info">
              <span class="patient-name">{patient.FirstName} {patient.LastName}</span>
              <span class="patient-email">{patient.Email}</span>
            </div>
            <button class="btn-remove" on:click={() => removePatient(patient.ID)}>
              Remove
            </button>
          </div>
        {/each}
      </div>
    {/if}
  </div>

  <div class="section">
    <h3 class="section-title">Available Patients</h3>
    {#if availablePatients.length === 0}
      <p class="empty-text">No additional patients available to add.</p>
    {:else}
      <div class="patient-list">
        {#each availablePatients as patient}
          <div class="patient-card">
            <div class="patient-info">
              <span class="patient-name">{patient.FirstName} {patient.LastName}</span>
              <span class="patient-email">{patient.Email}</span>
            </div>
            <button class="btn-add" on:click={() => addPatient(patient.ID)}>
              Add
            </button>
          </div>
        {/each}
      </div>
    {/if}
  </div>

  <button class="btn-back" on:click={() => push("/")}>← Back to Home</button>
</div>

<style>
  .manage-box {
    background: #fff;
    border-radius: var(--radius-xl);
    box-shadow: 0 8px 40px rgba(0, 0, 0, 0.12);
    padding: 40px;
    width: 100%;
    max-width: 600px;
    margin-top: 20px;
  }

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

  .status {
    text-align: center;
    padding: 10px;
    border-radius: 8px;
    margin-bottom: 16px;
    font-weight: 600;
  }

  .status.success {
    background: var(--t50);
    color: var(--t600);
  }

  .status.error {
    background: rgba(255, 0, 0, 0.1);
    color: var(--r400);
  }

  .section {
    margin-bottom: 24px;
  }

  .section-title {
    font-size: 14px;
    font-weight: 700;
    color: var(--gr600);
    text-transform: uppercase;
    letter-spacing: 0.04em;
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 2px solid var(--gr200);
  }

  .empty-text {
    color: var(--gr400);
    font-size: 14px;
    text-align: center;
    padding: 20px;
  }

  .patient-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .patient-card {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 16px;
    background: var(--gr50);
    border-radius: 10px;
    border: 1px solid var(--gr200);
  }

  .patient-info {
    display: flex;
    flex-direction: column;
  }

  .patient-name {
    font-weight: 600;
    color: var(--gr800);
    font-size: 14px;
  }

  .patient-email {
    font-size: 12px;
    color: var(--gr400);
  }

  .btn-add {
    padding: 8px 16px;
    border-radius: 6px;
    border: none;
    background: var(--t400);
    color: #fff;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.15s;
  }

  .btn-add:hover {
    background: var(--t600);
  }

  .btn-remove {
    padding: 8px 16px;
    border-radius: 6px;
    border: none;
    background: var(--r400);
    color: #fff;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.15s;
  }

  .btn-remove:hover {
    background: var(--r600);
  }

  .btn-back {
    width: 100%;
    padding: 12px;
    border-radius: 8px;
    border: none;
    background: var(--gr100);
    color: var(--gr700);
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.15s;
    margin-top: 16px;
  }

  .btn-back:hover {
    background: var(--gr200);
  }
</style>
