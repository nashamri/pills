<script>
  import { onMount } from "svelte";
  import { currentUser } from "../stores/auth";
  import { push } from "svelte-spa-router";
  import {
    GetCaregiverPatients,
    GetMedications,
    CreateScheduleForPatient,
    SearchDrugInfo
  } from "../../wailsjs/go/main/App.js";

  const medicationTypes = ["Pill", "Drink", "Other"];

  let connectedPatients = [];
  let medications = [];
  let loading = true;
  let message = "";
  let isError = false;

  let drugSuggestions = [];
  let showSuggestions = false;
  let searchTimeout = null;

  let form = {
    patientId: "",
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

  async function loadData() {
    if (!$currentUser || $currentUser.Role !== 2) {
      push("/");
      return;
    }

    try {
      loading = true;
      connectedPatients = await GetCaregiverPatients($currentUser.ID);
      medications = await GetMedications();
      isError = false;
      message = "";
    } catch (error) {
      isError = true;
      message = "Failed to load caregiver patients and medications.";
    } finally {
      loading = false;
    }
  }

  function fillMedicationName(name) {
    form.medicationName = name || "";
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

  async function submitSchedule() {
    if (!form.patientId) {
      isError = true;
      message = "Please select a patient.";
      return;
    }

    if (!form.medicationName.trim()) {
      isError = true;
      message = "Please enter a medication name.";
      return;
    }

    try {
      await CreateScheduleForPatient(
        $currentUser.ID,
        Number(form.patientId),
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
      message = "Medication schedule added successfully.";
      form.dosage = "";
      form.instructions = "";
      form.quantity = 1;
      form.intervalHours = 8;
    } catch (error) {
      isError = true;
      message = "Failed to create schedule. Please check all fields.";
    }
  }

  onMount(loadData);
</script>

<div class="schedule-box">
  <div class="ah">Medication Schedules</div>
  <div class="as">Assign medications to your connected patients</div>

  {#if message}
    <p class:error={isError} class="status">{message}</p>
  {/if}

  {#if loading}
    <p class="empty-text">Loading data...</p>
  {:else if connectedPatients.length === 0}
    <p class="empty-text">You need to connect at least one patient first.</p>
    <button class="btn-back" on:click={() => push("/manage_patients")}>Go to Manage Patients</button>
  {:else}
    <form class="form" on:submit|preventDefault={submitSchedule}>
      <label>
        Patient
        <select bind:value={form.patientId} required>
          <option value="">Select a patient</option>
          {#each connectedPatients as patient}
            <option value={patient.ID}>{patient.FirstName} {patient.LastName} ({patient.Email})</option>
          {/each}
        </select>
      </label>

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
                    {#if drug.size}
                      <span class="drug-size">{drug.size}{drug.size_unit ? ' ' + drug.size_unit : ''}</span>
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

      <button class="btn-primary" type="submit">Add Schedule</button>
      <button class="btn-back" type="button" on:click={() => push("/")}>Back to Home</button>
    </form>
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

  .form {
    display: flex;
    flex-direction: column;
    gap: 14px;
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

  input,
  select,
  textarea {
    padding: 10px 12px;
    border: 1px solid var(--gr200);
    border-radius: 8px;
    font-size: 14px;
    font-family: inherit;
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
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  }

  .suggestions li {
    display: flex;
    flex-direction: column;
    padding: 8px 12px;
    cursor: pointer;
    border-bottom: 1px solid var(--gr100);
    gap: 2px;
  }

  .suggestions li:last-child {
    border-bottom: none;
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

  .drug-size {
    font-size: 11px;
    color: var(--t400);
    font-weight: 500;
  }
</style>
