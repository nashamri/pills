<script>
  import { onMount } from "svelte";
  import { currentUser } from "../stores/auth";
  import { push } from "svelte-spa-router";
  import { GetPatientSchedules } from "../../wailsjs/go/main/App.js";

  const MS_DAY = 86400000;

  let schedules = [];
  let loadingSchedules = false;
  let scheduleError = "";

  function redirect() {
    push("/welcome");
  }

  function formatDate(value) {
    if (!value) return "-";
    return new Date(value).toLocaleDateString();
  }

  function formatTime(value) {
    if (!value) return "-";
    return new Date(value).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  }

  function buildDailyDoseTimes(startHourDate, frequency) {
    const startMinutes = (startHourDate.getUTCHours() * 60) + startHourDate.getUTCMinutes();
    const safeFrequency = Math.min(5, Math.max(1, Number(frequency) || 1));
    const remainingMinutes = (24 * 60) - startMinutes;
    const times = [];

    for (let i = 0; i < safeFrequency; i += 1) {
      const minuteOffset = Math.floor((i * remainingMinutes) / safeFrequency);
      const totalMinutes = startMinutes + minuteOffset;
      times.push({
        hour: Math.floor(totalMinutes / 60),
        minute: totalMinutes % 60,
      });
    }

    return times;
  }

  function firstName(user) {
    if (!user) return "";
    return user.FirstName || (user.UserName || "").split(/\s+/)[0] || "there";
  }

  $: today = new Date();
  $: todayLabel = today.toLocaleDateString(undefined, {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  });

  function computeTodayDoses(schedules) {
    const start = new Date();
    start.setHours(0, 0, 0, 0);
    const end = new Date(start.getTime() + MS_DAY);
    const now = new Date();
    const doses = [];

    for (const s of schedules) {
      const sStart = new Date(s.StartDate);
      const sEnd = new Date(s.EndDate);
      const sHour = new Date(s.StartHour);
      if (start >= sEnd || end <= sStart) continue;

      const cursor = new Date(sStart.getFullYear(), sStart.getMonth(), sStart.getDate());
      while (cursor < end && cursor < sEnd) {
        const dailyTimes = buildDailyDoseTimes(sHour, s.Frequency);
        for (const doseTime of dailyTimes) {
          const t = new Date(
            cursor.getFullYear(),
            cursor.getMonth(),
            cursor.getDate(),
            doseTime.hour,
            doseTime.minute,
          );
          if (t < start || t >= end || t < sStart || t >= sEnd) continue;
          doses.push({
            id: `${s.ScheduleID}-${t.getTime()}`,
            time: new Date(t),
            medication: s.Medication,
            type: s.MedicationType,
            dosage: s.Dosage,
            isPast: t < now,
          });
        }
        cursor.setDate(cursor.getDate() + 1);
      }
    }
    return doses.sort((a, b) => a.time - b.time);
  }

  $: todayDoses = computeTodayDoses(schedules);
  $: totalDoses = todayDoses.length;
  $: pastDoses = todayDoses.filter(d => d.isPast).length;
  $: upcomingDoses = todayDoses.filter(d => !d.isPast);
  $: adherencePct = totalDoses === 0 ? 100 : Math.round((pastDoses / totalDoses) * 100);

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

{#if $currentUser}
  <div class="dashboard">
    <div class="greeting">
      <span class="wave" aria-hidden="true">👋</span>
      <div>
        <h1 class="hello">Hello, {firstName($currentUser)}</h1>
        <p class="today">Today is {todayLabel}</p>
      </div>
    </div>

    {#if $currentUser.Role === 1}
      <div class="grid">
        <section class="hero-card">
          <div class="hero-head">
            <div class="hero-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
            </div>
            <h2>Today's Adherence</h2>
          </div>
          <div class="hero-body">
            <div class="stats">
              <div class="stat">
                <span class="stat-label">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.5 20.5a7.07 7.07 0 0 1-10-10l9-9a7.07 7.07 0 0 1 10 10l-9 9z"/><line x1="8.5" y1="8.5" x2="15.5" y2="15.5"/></svg>
                  Total Meds
                </span>
                <span class="stat-value">{totalDoses}</span>
              </div>
              <div class="stat">
                <span class="stat-label">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                  Waiting
                </span>
                <span class="stat-value">{upcomingDoses.length}</span>
              </div>
              <div class="stat">
                <span class="stat-label">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                  Taken
                </span>
                <span class="stat-value">{pastDoses}</span>
              </div>
            </div>
            <div class="percent">{adherencePct}%</div>
          </div>
        </section>

        <section class="actions-card">
          <h2>Quick Actions</h2>
          <button class="action action-amber" on:click={() => push("/")}>
            <span class="action-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.5 20.5a7.07 7.07 0 0 1-10-10l9-9a7.07 7.07 0 0 1 10 10l-9 9z"/><line x1="8.5" y1="8.5" x2="15.5" y2="15.5"/></svg>
            </span>
            <span class="action-label">My Medicines</span>
          </button>
          <button class="action action-violet" on:click={() => push("/patient/calendar")}>
            <span class="action-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            </span>
            <span class="action-label">Full Schedule</span>
          </button>
          <button class="action action-mint" on:click={() => push("/patient/calendar")}>
            <span class="action-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            </span>
            <span class="action-label">Add Medication</span>
          </button>
        </section>

        <section class="upcoming-card">
          <h2>Upcoming Doses</h2>
          {#if loadingSchedules}
            <div class="empty-state">
              <p>Loading your medications…</p>
            </div>
          {:else if scheduleError}
            <div class="empty-state error">
              <p>{scheduleError}</p>
            </div>
          {:else if totalDoses === 0}
            <div class="empty-state">
              <div class="empty-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="9 12 11 14 15 10"/></svg>
              </div>
              <p class="empty-title">No scheduled doses for today.</p>
              <p class="empty-sub">Enjoy your day. 🎉</p>
            </div>
          {:else if upcomingDoses.length === 0}
            <div class="empty-state">
              <div class="empty-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="9 12 11 14 15 10"/></svg>
              </div>
              <p class="empty-title">All doses for today have been taken!</p>
              <p class="empty-sub">Great job staying on track. 🎉</p>
            </div>
          {:else}
            <ul class="dose-list">
              {#each upcomingDoses as d}
                <li class="dose-row">
                  <div class="dose-time">{formatTime(d.time)}</div>
                  <div class="dose-info">
                    <div class="dose-name">{d.medication}</div>
                    <div class="dose-meta">{d.type} · {d.dosage}</div>
                  </div>
                </li>
              {/each}
            </ul>
          {/if}
        </section>
      </div>

      {#if schedules.length > 0}
        <section class="meds-card">
          <h2>Your Medications</h2>
          <div class="meds-grid">
            {#each schedules as s}
              <div class="med-card">
                <div class="med-head">
                  <strong>{s.Medication}</strong>
                  <span class="med-type">{s.MedicationType}</span>
                </div>
                <div class="med-line">Dosage: {s.Dosage} · Qty {s.Quantity}</div>
                <div class="med-line">{formatDate(s.StartDate)} → {formatDate(s.EndDate)}</div>
                <div class="med-line">Start: {formatTime(s.StartHour)} · {s.Frequency} dose(s)/day</div>
                {#if s.Instructions}
                  <div class="med-instructions">{s.Instructions}</div>
                {/if}
              </div>
            {/each}
          </div>
        </section>
      {/if}

    {:else if $currentUser.Role === 0}
      <section class="hero-card simple">
        <h2>Admin Dashboard</h2>
        <p>Manage users and review system activity from the sidebar.</p>
      </section>

    {:else if $currentUser.Role === 2}
      <section class="hero-card simple">
        <h2>Caregiver Dashboard</h2>
        <p>Manage your patients, schedules and medications from the sidebar.</p>
      </section>

    {:else}
      <section class="hero-card simple">
        <h2>Unknown user role</h2>
        <p>Please contact your administrator.</p>
      </section>
    {/if}
  </div>
{:else}
  {redirect()}
{/if}

<style>
  .dashboard {
    max-width: 1200px;
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    gap: 22px;
  }

  .greeting {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .wave {
    font-size: 32px;
    line-height: 1;
  }

  .hello {
    font-size: 22px;
    font-weight: 800;
    color: var(--gr800);
    margin: 0 0 2px;
    letter-spacing: -0.01em;
  }

  .today {
    margin: 0;
    color: var(--gr500);
    font-size: 14px;
  }

  /* ---- Layout grid ---- */
  .grid {
    display: grid;
    grid-template-columns: minmax(0, 2fr) minmax(260px, 1fr);
    grid-template-areas:
      "hero    actions"
      "upcoming actions";
    gap: 20px;
  }

  .hero-card { grid-area: hero; }
  .actions-card { grid-area: actions; }
  .upcoming-card { grid-area: upcoming; }

  /* ---- Cards (base) ---- */
  .hero-card,
  .actions-card,
  .upcoming-card,
  .meds-card {
    background: #ffffff;
    border-radius: 18px;
    padding: 24px;
    box-shadow: 0 6px 24px rgba(15, 23, 42, 0.06);
    border: 1px solid rgba(15, 23, 42, 0.04);
    text-align: left;
  }

  /* ---- Hero / Adherence ---- */
  .hero-card {
    color: #fff;
    background: linear-gradient(135deg, #2f7be9 0%, #3aa8e8 55%, #2ed0c5 100%);
    border: none;
    box-shadow: 0 12px 40px rgba(47, 123, 233, 0.25);
  }

  .hero-head {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 18px;
  }

  .hero-icon {
    width: 38px;
    height: 38px;
    border-radius: 12px;
    background: rgba(255, 255, 255, 0.2);
    display: grid;
    place-items: center;
  }

  .hero-icon svg {
    width: 20px;
    height: 20px;
    color: #fff;
  }

  .hero-card h2 {
    font-size: 18px;
    font-weight: 700;
    margin: 0;
  }

  .hero-body {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px;
    flex-wrap: wrap;
  }

  .stats {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 18px;
    flex: 1;
    min-width: 220px;
  }

  .stat {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .stat-label {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
    font-weight: 500;
    color: rgba(255, 255, 255, 0.88);
  }

  .stat-label svg {
    width: 14px;
    height: 14px;
  }

  .stat-value {
    font-size: 26px;
    font-weight: 800;
    line-height: 1;
  }

  .percent {
    font-size: 64px;
    font-weight: 800;
    line-height: 1;
    letter-spacing: -0.02em;
    text-shadow: 0 2px 12px rgba(0, 0, 0, 0.12);
  }

  /* ---- Quick Actions ---- */
  .actions-card h2 {
    font-size: 17px;
    font-weight: 700;
    color: var(--gr800);
    margin: 0 0 14px;
  }

  .action {
    display: flex;
    align-items: center;
    gap: 12px;
    width: 100%;
    padding: 14px 16px;
    border-radius: 14px;
    border: none;
    font-family: inherit;
    font-size: 14px;
    font-weight: 700;
    cursor: pointer;
    margin-bottom: 10px;
    transition: transform 0.15s, box-shadow 0.15s;
    text-align: left;
  }

  .action:last-child {
    margin-bottom: 0;
  }

  .action:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 16px rgba(15, 23, 42, 0.08);
  }

  .action-icon {
    width: 32px;
    height: 32px;
    border-radius: 10px;
    background: rgba(255, 255, 255, 0.7);
    display: grid;
    place-items: center;
    flex-shrink: 0;
  }

  .action-icon svg {
    width: 16px;
    height: 16px;
  }

  .action-amber {
    background: #fff4d6;
    color: #a45a0b;
  }
  .action-amber .action-icon { color: #d97706; background: #ffe4a3; }

  .action-violet {
    background: #ede8ff;
    color: #5b3fb8;
  }
  .action-violet .action-icon { color: #6d4ed1; background: #d9d0ff; }

  .action-mint {
    background: #d8f5e6;
    color: #1f7a4b;
  }
  .action-mint .action-icon { color: #16a34a; background: #b3edcb; }

  .action-label {
    flex: 1;
  }

  /* ---- Upcoming ---- */
  .upcoming-card h2 {
    font-size: 17px;
    font-weight: 700;
    color: var(--gr800);
    margin: 0 0 14px;
  }

  .empty-state {
    text-align: center;
    padding: 32px 12px;
    background: var(--gr50);
    border-radius: 14px;
  }

  .empty-icon {
    width: 56px;
    height: 56px;
    border-radius: 50%;
    background: #d8f5e6;
    color: #16a34a;
    display: grid;
    place-items: center;
    margin: 0 auto 12px;
  }

  .empty-icon svg {
    width: 28px;
    height: 28px;
  }

  .empty-state.error .empty-icon {
    background: #fee2e2;
    color: #dc2626;
  }

  .empty-title {
    font-weight: 700;
    color: var(--gr800);
    margin: 0;
  }

  .empty-sub {
    margin: 4px 0 0;
    color: var(--gr500);
    font-size: 13px;
  }

  .dose-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .dose-row {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 12px 14px;
    background: var(--gr50);
    border-radius: 12px;
    border: 1px solid var(--gr100);
  }

  .dose-time {
    font-weight: 700;
    color: var(--gr800);
    font-size: 14px;
    min-width: 64px;
  }

  .dose-info {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .dose-name {
    font-weight: 700;
    color: var(--gr800);
    font-size: 14px;
  }

  .dose-meta {
    color: var(--gr500);
    font-size: 12px;
  }

  /* ---- Medications block ---- */
  .meds-card h2 {
    font-size: 17px;
    font-weight: 700;
    color: var(--gr800);
    margin: 0 0 14px;
  }

  .meds-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 12px;
  }

  .med-card {
    border: 1px solid var(--gr100);
    background: var(--gr50);
    border-radius: 12px;
    padding: 14px;
  }

  .med-head {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    margin-bottom: 6px;
  }

  .med-head strong {
    color: var(--gr800);
    font-size: 15px;
  }

  .med-type {
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--t600);
    background: var(--t50);
    padding: 2px 8px;
    border-radius: 999px;
  }

  .med-line {
    font-size: 13px;
    color: var(--gr600);
    margin-bottom: 2px;
  }

  .med-instructions {
    margin-top: 8px;
    padding-top: 8px;
    border-top: 1px dashed var(--gr200);
    font-size: 12px;
    color: var(--gr500);
    font-style: italic;
  }

  /* ---- Simple cards (admin/caregiver placeholder) ---- */
  .hero-card.simple {
    background: #fff;
    color: var(--gr800);
    box-shadow: 0 6px 24px rgba(15, 23, 42, 0.06);
  }

  .hero-card.simple h2 {
    color: var(--gr800);
    margin-bottom: 6px;
  }

  .hero-card.simple p {
    margin: 0;
    color: var(--gr500);
  }

  /* ---- Signed-out fallback ---- */
  .signed-out {
    text-align: center;
    padding: 60px 20px;
  }

  /* ---- Responsive ---- */
  @media (max-width: 900px) {
    .grid {
      grid-template-columns: 1fr;
      grid-template-areas:
        "hero"
        "actions"
        "upcoming";
    }

    .percent {
      font-size: 48px;
    }
  }

  @media (max-width: 540px) {
    .stats {
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 10px;
    }

    .stat-value {
      font-size: 20px;
    }

    .percent {
      font-size: 40px;
    }
  }
</style>
