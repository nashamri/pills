<script>
  import { onMount } from "svelte";
  import { currentUser } from "../stores/auth";
  import { push } from "svelte-spa-router";
  import {
    GetCaregiverPatients,
    GetCaregiverPatientSchedules,
    UpdateScheduleForPatient,
    SearchDrugInfo
  } from "../../wailsjs/go/main/App.js";

  const medicationTypes = ["Pill", "Drink", "Other"];

  let connectedPatients = [];
  let schedules = [];
  let loading = true;
  let loadingSchedules = false;
  let message = "";
  let isError = false;

  let selectedPatientId = "";
  let editingScheduleId = null;

  let drugSuggestions = [];
  let showSuggestions = false;
  let searchTimeout = null;

  let form = emptyForm();

  function emptyForm() {
    return {
      medicationName: "",
      medicationType: "Pill",
      dosage: "",
      instructions: "",
      quantity: 1,
      intervalHours: 8,
      startDate: "",
      endDate: "",
      startHour: "08:00"
    };
  }

  function toDateInput(value) {
    if (!value) return "";
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return "";
    return d.toISOString().slice(0, 10);
  }

  function toTimeInput(value) {
    if (!value) return "";
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return "";
    return `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
  }

  function formatDate(value) {
    if (!value) return "-";
    return new Date(value).toLocaleDateString();
  }

  function formatTime(value) {
    if (!value) return "-";
    return new Date(value).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  }

  async function loadPatients() {
    if (!$currentUser || $currentUser.Role !== 2) {
      push("/");
      return;
    }

    try {
      loading = true;
      connectedPatients = await GetCaregiverPatients($currentUser.ID);
      isError = false;
      message = "";
    } catch {
      isError = true;
      message = "Failed to load patients.";
    } finally {
      loading = false;
    }
  }

  async function loadSchedules() {
    editingScheduleId = null;
    form = emptyForm();
    schedules = [];

    if (!selectedPatientId) return;

    try {
      loadingSchedules = true;
      schedules = await GetCaregiverPatientSchedules(
        $currentUser.ID,
        Number(selectedPatientId)
      );
      schedules = Array.isArray(schedules) ? schedules : [];
      isError = false;
      message = "";
    } catch {
      isError = true;
      message = "Failed to load schedules for this patient.";
      schedules = [];
    } finally {
      loadingSchedules = false;
    }
  }

  function startEdit(schedule) {
    editingScheduleId = schedule.ScheduleID;
    form = {
      medicationName: schedule.Medication || "",
      medicationType: schedule.MedicationType || "Pill",
      dosage: schedule.Dosage || "",
      instructions: schedule.Instructions || "",
      quantity: schedule.Quantity || 1,
      intervalHours: schedule.IntervalHours || 8,
      startDate: toDateInput(schedule.StartDate),
      endDate: toDateInput(schedule.EndDate),
      startHour: toTimeInput(schedule.StartHour)
    };
    message = "";
    isError = false;
  }

  function cancelEdit() {
    editingScheduleId = null;
    form = emptyForm();
    message = "";
    isError = false;
  }

  function onMedicationInput(e) {
    const val = e.target.value;
    form.medicationName = val;
    clearTimeout(searchTimeout);
    if (val.length < 3) {
      drugSuggestions = [];
      showSuggestions = false;
      return;
    }
    searchTimeout = setTimeout(async () => {
      try {
        drugSuggestions = await SearchDrugInfo(val);
        showSuggestions = drugSuggestions.length > 0;
      } catch {
        drugSuggestions = [];
        showSuggestions = false;
      }
    }, 250);
  }

  function inferMedicationType(sizeUnit) {
    const u = (sizeUnit || "").toLowerCase();
    if (u === "l" || u === "ml") return "Drink";
    if (u === "g" || u === "mg") return "Pill";
    return "Other";
  }

  function selectDrugSuggestion(drug) {
    form.medicationName = drug.trade_name;
    if (drug.size && drug.size_unit) {
      form.dosage = `${drug.size} ${drug.size_unit}`;
    }
    form.medicationType = inferMedicationType(drug.size_unit);
    drugSuggestions = [];
    showSuggestions = false;
  }

  function onMedicationBlur() {
    setTimeout(() => { showSuggestions = false; }, 150);
  }

  async function saveSchedule() {
    if (!editingScheduleId) return;

    if (!form.medicationName.trim()) {
      isError = true;
      message = "Please enter a medication name.";
      return;
    }

    try {
      await UpdateScheduleForPatient(
        $currentUser.ID,
        editingScheduleId,
        form.medicationName.trim(),
        form.medicationType,
        form.startDate,
        form.endDate,
        form.startHour,
        Number(form.intervalHours),
        form.instructions.trim(),
        form.dosage.trim(),
        Number(form.quantity)
      );

      isError = false;
      message = "Schedule updated successfully.";
      editingScheduleId = null;
      form = emptyForm();
      await loadSchedules();
    } catch {
      isError = true;
      message = "Failed to update schedule. Please check all fields.";
    }
  }

  onMount(loadPatients);
</script>

<div class="schedule-box">
  <div class="ah">Edit Schedules</div>
  <div class="as">View and modify medication schedules for your patients</div>

  {#if message}
    <p class:error={isError} class="status">{message}</p>
  {/if}

  {#if loading}
    <p class="empty-text">Loading data...</p>
  {:else if connectedPatients.length === 0}
    <p class="empty-text">You need to connect at least one patient first.</p>
    <button class="btn-back" on:click={() => push("/manage_patients")}>Go to Manage Patients</button>
  {:else}
    <label class="patient-select">
      Patient
      <select bind:value={selectedPatientId} on:change={loadSchedules}>
        <option value="">Select a patient</option>
        {#each connectedPatients as patient}
          <option value={patient.ID}>{patient.FirstName} {patient.LastName} ({patient.Email})</option>
        {/each}
      </select>
    </label>

    {#if !selectedPatientId}
      <p class="empty-text">Select a patient to view their schedules.</p>
    {:else if loadingSchedules}
      <p class="empty-text">Loading schedules...</p>
    {:else if schedules.length === 0}
      <p class="empty-text">No schedules found for this patient.</p>
      <button class="btn-back" type="button" on:click={() => push("/schedules")}>Create a Schedule</button>
    {:else if editingScheduleId}
      <form class="form" on:submit|preventDefault={saveSchedule}>
        <h3 class="form-title">Edit Schedule</h3>

        <div class="grid">
          <label class="autocomplete-label">
            Medication Name
            <div class="autocomplete-wrap">
              <input
                value={form.medicationName}
                on:input={onMedicationInput}
                on:blur={onMedicationBlur}
                type="text"
                placeholder="Type at least 3 letters..."
                autocomplete="off"
                required
              />
              {#if showSuggestions}
                <ul class="suggestions">
                  {#each drugSuggestions as drug}
                    <li on:mousedown={() => selectDrugSuggestion(drug)}>
                      <span class="drug-trade">{drug.trade_name}</span>
                      {#if drug.scientific_name}
                        <span class="drug-scientific">{drug.scientific_name}</span>
                      {/if}
                    </li>
                  {/each}
                </ul>
              {/if}
            </div>
          </label>

          <label>
            Medication Type
            <select bind:value={form.medicationType}>
              {#each medicationTypes as type}
                <option value={type}>{type}</option>
              {/each}
            </select>
          </label>

          <label>
            Dosage
            <input bind:value={form.dosage} type="text" placeholder="e.g. 500mg" required />
          </label>

          <label>
            Quantity
            <input bind:value={form.quantity} type="number" min="1" required />
          </label>

          <label>
            Every (hours)
            <input bind:value={form.intervalHours} type="number" min="1" required />
          </label>

          <label>
            Start hour
            <input bind:value={form.startHour} type="time" required />
          </label>

          <label>
            Start date
            <input bind:value={form.startDate} type="date" required />
          </label>

          <label>
            End date
            <input bind:value={form.endDate} type="date" required />
          </label>
        </div>

        <label>
          Instructions
          <textarea
            bind:value={form.instructions}
            placeholder="e.g. after meal, with water"
            rows="3"
            required
          />
        </label>

        <button class="btn-primary" type="submit">Save Changes</button>
        <button class="btn-back" type="button" on:click={cancelEdit}>Cancel</button>
      </form>
    {:else}
      <div class="schedule-list">
        {#each schedules as schedule}
          <div class="schedule-card">
            <div class="schedule-header">
              <strong>{schedule.Medication}</strong>
              <span class="med-type">({schedule.MedicationType})</span>
            </div>
            <div class="line">Dosage: {schedule.Dosage} | Quantity: {schedule.Quantity}</div>
            <div class="line">
              {formatDate(schedule.StartDate)} – {formatDate(schedule.EndDate)}
            </div>
            <div class="line">
              {formatTime(schedule.StartHour)} · every {schedule.IntervalHours} hour(s)
            </div>
            <div class="line">Instructions: {schedule.Instructions || "-"}</div>
            <button class="btn-edit" type="button" on:click={() => startEdit(schedule)}>Edit</button>
          </div>
        {/each}
      </div>
    {/if}

    <button class="btn-back nav-back" type="button" on:click={() => push("/schedules")}>Add New Schedule</button>
  {/if}
</div>

<style>
  .schedule-box {
    background: #fff;
    border-radius: var(--radius-xl);
    box-shadow: 0 8px 40px rgba(0, 0, 0, 0.12);
    padding: 40px;
    width: 100%;
    max-width: 760px;
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
    background: rgba(34, 197, 94, 0.1);
    color: #166534;
  }

  .status.error {
    background: rgba(255, 0, 0, 0.1);
    color: var(--r400);
  }

  .empty-text {
    color: var(--gr400);
    font-size: 14px;
    text-align: center;
    padding: 20px;
  }

  .patient-select {
    display: flex;
    flex-direction: column;
    gap: 6px;
    font-size: 13px;
    color: var(--gr700);
    font-weight: 600;
    margin-bottom: 20px;
  }

  select,
  input,
  textarea {
    padding: 10px 12px;
    border: 1px solid var(--gr200);
    border-radius: 8px;
    font-size: 14px;
    font-family: inherit;
  }

  .schedule-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .schedule-card {
    border: 1px solid var(--gr200);
    border-radius: 10px;
    padding: 14px 16px;
    background: #f9fbff;
  }

  .schedule-header {
    margin-bottom: 6px;
  }

  .med-type {
    color: var(--gr400);
    font-size: 13px;
    margin-left: 4px;
  }

  .line {
    font-size: 13px;
    color: var(--gr700);
    margin-bottom: 3px;
  }

  .btn-edit {
    margin-top: 10px;
    padding: 8px 14px;
    border: none;
    border-radius: 8px;
    background: var(--b400);
    color: #fff;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
  }

  .btn-edit:hover {
    filter: brightness(1.1);
  }

  .form {
    display: flex;
    flex-direction: column;
    gap: 14px;
  }

  .form-title {
    font-size: 16px;
    font-weight: 700;
    color: var(--gr800);
    margin: 0 0 4px;
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
  }

  label {
    display: flex;
    flex-direction: column;
    gap: 6px;
    font-size: 13px;
    color: var(--gr700);
    font-weight: 600;
  }

  textarea {
    resize: vertical;
  }

  .btn-primary {
    width: 100%;
    padding: 12px;
    border-radius: 8px;
    border: none;
    background: var(--t400);
    color: #fff;
    font-size: 14px;
    font-weight: 700;
    cursor: pointer;
  }

  .btn-primary:hover {
    background: var(--t600);
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
  }

  .btn-back:hover {
    background: var(--gr200);
  }

  .nav-back {
    margin-top: 16px;
  }

  .autocomplete-label {
    position: relative;
  }

  .autocomplete-wrap {
    position: relative;
  }

  .autocomplete-wrap input {
    width: 100%;
    box-sizing: border-box;
  }

  .suggestions {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    z-index: 100;
    background: #fff;
    border: 1px solid var(--gr200);
    border-top: none;
    border-radius: 0 0 8px 8px;
    margin: 0;
    padding: 0;
    list-style: none;
    max-height: 220px;
    overflow-y: auto;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .suggestions li {
    display: flex;
    flex-direction: column;
    padding: 8px 12px;
    cursor: pointer;
    border-bottom: 1px solid var(--gr100);
    gap: 2px;
  }

  .suggestions li:hover {
    background: var(--gr100);
  }

  .drug-trade {
    font-size: 13px;
    font-weight: 600;
    color: var(--gr800);
  }

  .drug-scientific {
    font-size: 11px;
    color: var(--gr400);
    font-style: italic;
  }
</style>
