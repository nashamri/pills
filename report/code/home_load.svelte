<script>
  import { onMount } from "svelte";
  import { currentUser } from "../stores/auth";
  import { GetPatientSchedules }
    from "../../wailsjs/go/main/App.js";

  let schedules = [];
  let loadingSchedules = false;
  let scheduleError = "";

  async function loadPatientSchedules() {
    if (!$currentUser || $currentUser.Role !== 1) return;
    try {
      loadingSchedules = true;
      scheduleError = "";
      const loaded = await GetPatientSchedules($currentUser.ID);
      schedules = Array.isArray(loaded) ? loaded : [];
    } catch (error) {
      scheduleError = "Failed to load your medication schedules.";
    } finally {
      loadingSchedules = false;
    }
  }

  onMount(loadPatientSchedules);
</script>
