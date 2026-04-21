<script>
  import { onMount } from 'svelte';
  import { currentUser } from '../../stores/auth.js';
  import { GetPatientSchedules } from '../../../wailsjs/go/main/App.js';

  let schedule = [];
  let loading = true;
  let error = '';

  const todayLabel = new Date().toLocaleDateString('en-US', {
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
  });

  function computeTodayDoses(schedules) {
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const todayEnd = new Date(todayStart.getTime() + 24 * 60 * 60 * 1000);

    let allDoses = [];
    let id = 1;

    for (const s of schedules) {
      const startDate = new Date(s.StartDate);
      const endDate = new Date(s.EndDate);
      const startHour = new Date(s.StartHour);

      if (todayStart > endDate || todayEnd <= startDate) continue;

      const firstDose = new Date(
        todayStart.getFullYear(),
        todayStart.getMonth(),
        todayStart.getDate(),
        startHour.getUTCHours(),
        startHour.getUTCMinutes()
      );

      const intervalMs = (s.IntervalHours || 24) * 60 * 60 * 1000;
      let t = new Date(firstDose);

      while (t < todayEnd) {
        allDoses.push({
          id: id++,
          _time: new Date(t),
          med: s.Medication,
          dose: s.Dosage,
          type: s.MedicationType,
          instructions: s.Instructions,
          quantity: s.Quantity,
        });
        t = new Date(t.getTime() + intervalMs);
      }
    }

    allDoses.sort((a, b) => a._time - b._time);

    let nextPending = true;
    return allDoses.map(d => {
      const isPast = d._time < now;
      let status;
      if (isPast) {
        status = 'taken';
      } else if (nextPending) {
        status = 'pending';
        nextPending = false;
      } else {
        status = 'upcoming';
      }
      return {
        ...d,
        time: d._time.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true }),
        status
      };
    });
  }

  function markAsTaken(id) {
    schedule = schedule.map(item =>
      item.id === id ? { ...item, status: 'taken' } : item
    );
  }

  onMount(async () => {
    if (!$currentUser) { loading = false; return; }
    try {
      const raw = await GetPatientSchedules($currentUser.ID);
      schedule = computeTodayDoses(raw || []);
    } catch (e) {
      error = 'Failed to load your schedule.';
    } finally {
      loading = false;
    }
  });
</script>

<div class="schedule-container" dir="ltr">
  <div class="header">
    <h1>Daily Schedule</h1>
    <p>{todayLabel}</p>
  </div>

  {#if loading}
    <p class="empty-text">Loading your medications...</p>
  {:else if error}
    <p class="empty-text error-text">{error}</p>
  {:else if schedule.length === 0}
    <p class="empty-text">No medications scheduled for today.</p>
  {:else}
    <div class="timeline">
      {#each schedule as item (item.id)}
        <div class="timeline-item {item.status}">
          <div class="time-column">
            <span class="time">{item.time}</span>
            <div class="dot"></div>
          </div>

          <div class="card">
            <div class="info">
              <h3>{item.med} <span class="dose">({item.dose})</span></h3>
              <span class="type">{item.type}</span>
              {#if item.instructions}
                <span class="instructions">{item.instructions}</span>
              {/if}
            </div>

            <div class="actions">
              {#if item.status === 'taken'}
                <span class="status-badge success">✓ Taken</span>
              {:else if item.status === 'pending'}
                <button class="btn-confirm" on:click={() => markAsTaken(item.id)}>Confirm Dose</button>
              {:else}
                <span class="status-badge info">Upcoming</span>
              {/if}
            </div>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>

<style>
  :global(body) {
    background-color: #f8fafc;
    font-family: 'Inter', sans-serif;
  }

  .schedule-container {
    max-width: 800px;
    margin: 40px auto;
    padding: 20px;
  }

  .header {
    margin-bottom: 30px;
  }

  .header h1 {
    font-size: 28px;
    color: #1e293b;
    margin: 0;
  }

  .header p {
    color: #64748b;
    margin-top: 5px;
  }

  .empty-text {
    text-align: center;
    color: #64748b;
    font-size: 15px;
    margin-top: 60px;
  }

  .error-text { color: #ef4444; }

  .timeline {
    position: relative;
    padding-left: 20px;
  }

  .timeline::before {
    content: '';
    position: absolute;
    left: 88px;
    top: 0;
    bottom: 0;
    width: 2px;
    background: #e2e8f0;
  }

  .timeline-item {
    display: flex;
    gap: 30px;
    margin-bottom: 25px;
    align-items: center;
  }

  .time-column {
    width: 80px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    position: relative;
  }

  .time {
    font-size: 14px;
    font-weight: 600;
    color: #64748b;
  }

  .dot {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: #cbd5e1;
    border: 3px solid #fff;
    z-index: 1;
    position: absolute;
    right: -11px;
  }

  .timeline-item.taken .dot { background: #1d9e75; }
  .timeline-item.pending .dot { background: #ef9f27; }

  .card {
    flex: 1;
    background: #fff;
    padding: 18px;
    border-radius: 12px;
    border: 1px solid #e2e8f0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 2px 4px rgba(0,0,0,0.02);
  }

  h3 {
    margin: 0;
    font-size: 16px;
    color: #0f172a;
  }

  .dose {
    font-weight: normal;
    color: #64748b;
    font-size: 14px;
  }

  .type {
    font-size: 12px;
    color: #94a3b8;
    display: block;
    margin-top: 4px;
  }

  .instructions {
    font-size: 12px;
    color: #64748b;
    display: block;
    margin-top: 2px;
    font-style: italic;
  }

  .btn-confirm {
    background: #1d9e75;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 13px;
    transition: background 0.2s;
  }

  .btn-confirm:hover {
    background: #0f6e56;
  }

  .status-badge {
    padding: 5px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 700;
  }

  .status-badge.success { background: #e1f5ee; color: #0f6e56; }
  .status-badge.info { background: #f1f5f9; color: #64748b; }
</style>
