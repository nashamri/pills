<script>
  import { onMount } from 'svelte';
  import { currentUser } from '../stores/auth.js';
  import { GetPatientSchedules } from '../../wailsjs/go/main/App.js';

  let rawSchedules = [];
  let loading = true;
  let error = '';
  let activeView = 'daily';
  let viewOffset = 0;
  let takenSet = new Set();

  function getViewBounds(view, offset) {
    const now = new Date();
    const y = now.getFullYear(), mo = now.getMonth(), d = now.getDate();
    if (view === 'daily') {
      const s = new Date(y, mo, d + offset);
      return { start: s, end: new Date(s.getTime() + 86400000) };
    }
    if (view === 'weekly') {
      const s = new Date(y, mo, d - now.getDay() + offset * 7);
      return { start: s, end: new Date(s.getTime() + 7 * 86400000) };
    }
    if (view === 'monthly') {
      return { start: new Date(y, mo + offset, 1), end: new Date(y, mo + offset + 1, 1) };
    }
    return { start: new Date(y + offset, 0, 1), end: new Date(y + offset + 1, 0, 1) };
  }

  function getViewLabel(view, offset) {
    const { start, end } = getViewBounds(view, offset);
    if (view === 'daily')
      return start.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
    if (view === 'weekly') {
      const last = new Date(end.getTime() - 1);
      return `${start.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })} – ${last.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}`;
    }
    if (view === 'monthly')
      return start.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });
    return String(start.getFullYear());
  }

  function computeDoses(schedules, start, end) {
    const now = new Date();
    const doses = [];
    for (const s of schedules) {
      const sEnd = new Date(s.EndDate);
      const sStart = new Date(s.StartDate);
      const sHour = new Date(s.StartHour);
      if (start >= sEnd || end <= sStart) continue;
      const intervalMs = (s.IntervalHours || 24) * 60 * 60 * 1000;
      let t = new Date(sStart.getFullYear(), sStart.getMonth(), sStart.getDate(),
        sHour.getUTCHours(), sHour.getUTCMinutes());
      while (t < start) t = new Date(t.getTime() + intervalMs);
      while (t < end && t < sEnd) {
        doses.push({
          id: `${s.ScheduleID}-${t.getTime()}`,
          _time: new Date(t),
          med: s.Medication,
          dose: s.Dosage,
          type: s.MedicationType,
          instructions: s.Instructions,
          quantity: s.Quantity,
          isPast: t < now,
        });
        t = new Date(t.getTime() + intervalMs);
      }
    }
    return doses.sort((a, b) => a._time - b._time);
  }

  function withStatus(doses, daily, taken) {
    let nextPending = daily;
    return doses.map(d => {
      let status;
      if (taken.has(d.id)) status = 'taken';
      else if (d.isPast) status = daily ? 'missed' : 'taken';
      else if (nextPending) { status = 'pending'; nextPending = false; }
      else status = 'upcoming';
      return { ...d, status };
    });
  }

  function goToDay(date) {
    const now = new Date();
    const target = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const diffTime = target.getTime() - today.getTime();
    const diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));
    
    activeView = 'daily';
    viewOffset = diffDays;
  }

  $: bounds    = getViewBounds(activeView, viewOffset);
  $: viewLabel = getViewLabel(activeView, viewOffset);
  $: allDoses  = computeDoses(rawSchedules, bounds.start, bounds.end);
  $: doses     = withStatus(allDoses, activeView === 'daily', takenSet);

  $: dailyList = doses.map(d => ({
    ...d,
    time: d._time.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true }),
  }));

  $: weekDays = Array.from({ length: 7 }, (_, i) => {
    const day  = new Date(bounds.start.getTime() + i * 86400000);
    const ds   = day.toDateString();
    const now  = new Date().toDateString();
    const dd   = doses.filter(d => d._time.toDateString() === ds);
    return {
      fullDate:  day,
      label:     day.toLocaleDateString('en-US', { weekday: 'short' }),
      dateLabel: day.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
      isToday:   ds === now,
      taken:     dd.filter(d => d.status === 'taken').length,
      total:     dd.length,
      doses:     dd.map(d => ({
        ...d,
        time: d._time.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true }),
      })),
    };
  });

  $: monthCells = (() => {
    const { start } = bounds;
    const daysInMonth = new Date(start.getFullYear(), start.getMonth() + 1, 0).getDate();
    const todayStr    = new Date().toDateString();
    const cells       = Array(start.getDay()).fill(null);
    for (let d = 1; d <= daysInMonth; d++) {
      const day = new Date(start.getFullYear(), start.getMonth(), d);
      const ds  = day.toDateString();
      const dd  = doses.filter(x => x._time.toDateString() === ds);
      cells.push({
        day,
        d,
        isToday:  ds === todayStr,
        total:    dd.length,
        taken:    dd.filter(x => x.status === 'taken').length,
        missed:   dd.filter(x => x.status === 'missed').length,
      });
    }
    return cells;
  })();

  $: yearMonths = Array.from({ length: 12 }, (_, m) => {
    const now    = new Date();
    const mStart = new Date(bounds.start.getFullYear(), m, 1);
    const mEnd   = new Date(bounds.start.getFullYear(), m + 1, 1);
    const md     = doses.filter(d => d._time >= mStart && d._time < mEnd);
    const taken  = md.filter(d => d.status === 'taken').length;
    const total  = md.length;
    return {
      mStart,
      label:     mStart.toLocaleDateString('en-US', { month: 'short' }),
      total,
      taken,
      upcoming:  md.filter(d => d.status === 'upcoming').length,
      takenPct:  total ? Math.round((taken / total) * 100) : 0,
      isCurrent: mStart.getMonth() === now.getMonth() && mStart.getFullYear() === now.getFullYear(),
      isFuture:  mStart > now,
    };
  });

  $: progress = (() => {
    const total = doses.length;
    if (!total) return null;
    const taken    = doses.filter(d => d.status === 'taken').length;
    const missed   = doses.filter(d => d.status === 'missed').length;
    const upcoming = total - taken - missed;
    return {
      total, taken, missed, upcoming,
      takenPct:    (taken    / total) * 100,
      missedPct:   (missed   / total) * 100,
      upcomingPct: (upcoming / total) * 100,
    };
  })();

  function markAsTaken(id) {
    takenSet = new Set([...takenSet, id]);
  }

  function setView(v)    { activeView = v; viewOffset = 0; }
  function navigate(dir) { viewOffset += dir; }

  onMount(async () => {
    if (!$currentUser) { loading = false; error = 'Please log in to view your schedule.'; return; }
    try {
      rawSchedules = (await GetPatientSchedules($currentUser.ID)) || [];
    } catch {
      error = 'Failed to load your schedule.';
    } finally {
      loading = false;
    }
  });
</script>

<div class="schedule-container" dir="ltr">
  <div class="sticky-header">
    <div class="view-tabs">
      {#each ['daily','weekly','monthly','yearly'] as v}
        <button class="tab {activeView === v ? 'active' : ''}" on:click={() => setView(v)}>
          {v.charAt(0).toUpperCase() + v.slice(1)}
        </button>
      {/each}
    </div>

    <div class="nav-header">
      <button class="nav-btn" on:click={() => navigate(-1)}>‹</button>
      <div class="header-center">
        <h1>{activeView.charAt(0).toUpperCase() + activeView.slice(1)} Schedule</h1>
        <p>{viewLabel}</p>
      </div>
      <button class="nav-btn" on:click={() => navigate(1)}>›</button>
    </div>

    {#if progress}
      <div class="progress-section">
        <div class="progress-labels">
          <span class="lbl lbl-taken">✓ {progress.taken} taken</span>
          {#if progress.missed > 0}
            <span class="lbl lbl-missed">✗ {progress.missed} missed</span>
          {/if}
          {#if progress.upcoming > 0}
            <span class="lbl lbl-upcoming">◷ {progress.upcoming} upcoming</span>
          {/if}
          <span class="lbl lbl-total">{progress.total} total</span>
        </div>
        <div class="progress-bar">
          <div class="seg seg-taken"    style="width:{progress.takenPct}%"></div>
          <div class="seg seg-missed"   style="width:{progress.missedPct}%"></div>
          <div class="seg seg-upcoming" style="width:{progress.upcomingPct}%"></div>
        </div>
      </div>
    {/if}
  </div>

  {#if loading}
    <p class="empty-text">Loading your medications...</p>
  {:else if error}
    <p class="empty-text error-text">{error}</p>
  {:else}

    {#if activeView === 'daily'}
      {#if dailyList.length === 0}
        <p class="empty-text">No medications scheduled for this day.</p>
      {:else}
        <div class="timeline">
          {#each dailyList as item (item.id)}
            <div class="timeline-item {item.status}">
              <div class="time-column">
                <span class="time">{item.time}</span>
                <div class="dot"></div>
              </div>
              <div class="card">
                <div class="info">
                  <h3>
                    {item.med}
                    <span class="dose">({item.dose}{item.quantity ? ` × ${item.quantity}` : ''})</span>
                  </h3>
                  <span class="type">{item.type}</span>
                  {#if item.instructions}
                    <span class="instructions">{item.instructions}</span>
                  {/if}
                </div>
                <div class="actions">
                  {#if item.status === 'taken'}
                    <span class="status-badge badge-success">✓ Taken</span>
                  {:else if item.status === 'missed'}
                    <span class="status-badge badge-missed">✗ Missed</span>
                  {:else if item.status === 'pending'}
                    <button class="btn-confirm" on:click|stopPropagation={() => markAsTaken(item.id)}>Confirm Dose</button>
                  {:else}
                    <span class="status-badge badge-info">Upcoming</span>
                  {/if}
                </div>
              </div>
            </div>
          {/each}
        </div>
      {/if}

    {:else if activeView === 'weekly'}
      <div class="week-grid">
        {#each weekDays as day}
          <div class="week-day {day.isToday ? 'today' : ''}" role="button" tabindex="0" on:click={() => goToDay(day.fullDate)} on:keydown={(e) => e.key === 'Enter' && goToDay(day.fullDate)}>
            <div class="wd-header">
              <span class="wd-name">{day.label}</span>
              <span class="wd-date">{day.dateLabel}</span>
              {#if day.total > 0}
                <div class="mini-bar">
                  <div class="mini-taken" style="width:{(day.taken / day.total) * 100}%"></div>
                </div>
                <span class="wd-count">{day.taken}/{day.total}</span>
              {/if}
            </div>
            {#if day.doses.length === 0}
              <p class="day-empty">—</p>
            {:else}
              <ul class="day-doses">
                {#each day.doses as d}
                  <li class="day-dose {d.status}">
                    <span class="dd-dot"></span>
                    <span class="dd-time">{d.time}</span>
                    <span class="dd-med">{d.med}</span>
                  </li>
                {/each}
              </ul>
            {/if}
          </div>
        {/each}
      </div>

    {:else if activeView === 'monthly'}
      <div class="month-cal">
        {#each ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'] as h}
          <div class="cal-head">{h}</div>
        {/each}
        {#each monthCells as cell}
          {#if cell === null}
            <div class="cal-empty"></div>
          {:else}
            <div class="cal-cell {cell.isToday ? 'today' : ''} {cell.total > 0 ? (cell.missed > 0 ? 'has-missed' : 'has-taken') : ''}"
                 role="button" tabindex="0"
                 on:click={() => goToDay(cell.day)}
                 on:keydown={(e) => e.key === 'Enter' && goToDay(cell.day)}>
              <span class="cal-d">{cell.d}</span>
              {#if cell.total > 0}
                <div class="cal-dots">
                  {#each Array.from({ length: Math.min(cell.taken, 4) }) as _}
                    <span class="cdot cdot-taken"></span>
                  {/each}
                  {#each Array.from({ length: Math.min(cell.missed, 4) }) as _}
                    <span class="cdot cdot-missed"></span>
                  {/each}
                </div>
                <span class="cal-count">{cell.taken}/{cell.total}</span>
              {/if}
            </div>
          {/if}
        {/each}
      </div>

    {:else}
      <div class="year-grid">
        {#each yearMonths as m}
          <div class="year-month {m.isCurrent ? 'current' : ''} {m.isFuture ? 'future' : ''}"
               role="button" tabindex="0"
               on:click={() => { activeView = 'monthly'; viewOffset = (m.mStart.getFullYear() - new Date().getFullYear()) * 12 + (m.mStart.getMonth() - new Date().getMonth()); }}
               on:keydown={(e) => { if (e.key === 'Enter') { activeView = 'monthly'; viewOffset = (m.mStart.getFullYear() - new Date().getFullYear()) * 12 + (m.mStart.getMonth() - new Date().getMonth()); } }}>
            <div class="ym-label">{m.label}</div>
            {#if m.total > 0}
              <div class="ym-bar">
                <div class="ym-taken" style="width:{m.takenPct}%"></div>
              </div>
              <div class="ym-stats">
                <span class="ym-pct">{m.takenPct}%</span>
                <span class="ym-total">{m.total} doses</span>
              </div>
            {:else}
              <span class="ym-none">—</span>
            {/if}
          </div>
        {/each}
      </div>
    {/if}

  {/if}
</div>

<style>
  :global(body) {
    background-color: #f8fafc;
    font-family: 'Inter', sans-serif;
  }

  .schedule-container {
    max-width: 900px;
    margin: 0 auto 40px;
    padding: 0 20px;
  }

  .sticky-header {
    position: sticky;
    top: 0;
    background-color: #f8fafc;
    z-index: 100;
    padding: 20px 0 10px;
    border-bottom: 1px solid transparent;
  }

  .view-tabs {
    display: flex;
    gap: 6px;
    margin-bottom: 20px;
  }

  .tab {
    padding: 7px 18px;
    border-radius: 20px;
    border: 1px solid #e2e8f0;
    background: #fff;
    color: #64748b;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.15s;
  }

  .tab:hover { background: #f1f5f9; }

  .tab.active {
    background: #1d9e75;
    color: #fff;
    border-color: #1d9e75;
  }

  .nav-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 24px;
  }

  .header-center {
    text-align: center;
  }

  .header-center h1 {
    font-size: 24px;
    color: #1e293b;
    margin: 0;
  }

  .header-center p {
    color: #64748b;
    margin-top: 4px;
    font-size: 14px;
  }

  .nav-btn {
    background: #fff;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    width: 36px;
    height: 36px;
    font-size: 20px;
    color: #64748b;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background 0.15s;
  }

  .nav-btn:hover { background: #f1f5f9; }

  .progress-section {
    margin-bottom: 18px;
    background: #fff;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    padding: 14px 18px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.02);
  }

  .progress-labels {
    display: flex;
    gap: 14px;
    margin-bottom: 8px;
    flex-wrap: wrap;
  }

  .lbl {
    font-size: 12px;
    font-weight: 600;
  }

  .lbl-taken    { color: #1d9e75; }
  .lbl-missed   { color: #ef4444; }
  .lbl-upcoming { color: #94a3b8; }
  .lbl-total    { color: #1e293b; margin-left: auto; }

  .progress-bar {
    height: 8px;
    border-radius: 99px;
    background: #f1f5f9;
    display: flex;
    overflow: hidden;
  }

  .seg { height: 100%; transition: width 0.4s; }
  .seg-taken    { background: #1d9e75; }
  .seg-missed   { background: #ef4444; }
  .seg-upcoming { background: #cbd5e1; }

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
    margin-top: 20px;
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

  .timeline-item.taken  { opacity: 0.65; }
  .timeline-item.missed { opacity: 0.8; }

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

  .timeline-item.taken   .dot { background: #1d9e75; }
  .timeline-item.pending .dot { background: #ef9f27; }
  .timeline-item.missed  .dot { background: #ef4444; }

  .card {
    flex: 1;
    background: #fff;
    padding: 18px;
    border-radius: 12px;
    border: 1px solid #e2e8f0;
    border-left: 4px solid transparent;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 2px 4px rgba(0,0,0,0.02);
  }

  .timeline-item.taken   .card { border-left-color: #1d9e75; }
  .timeline-item.pending .card { border-left-color: #ef9f27; }
  .timeline-item.missed  .card { border-left-color: #ef4444; }

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

  .btn-confirm:hover { background: #0f6e56; }

  .status-badge {
    padding: 5px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 700;
    white-space: nowrap;
  }

  .badge-success { background: #e1f5ee; color: #0f6e56; }
  .badge-missed  { background: #fee2e2; color: #b91c1c; }
  .badge-info    { background: #f1f5f9; color: #64748b; }

  .week-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 10px;
    margin-top: 10px;
  }

  .week-day {
    background: #fff;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    padding: 12px 10px;
    min-height: 140px;
    cursor: pointer;
    transition: transform 0.1s, border-color 0.2s;
  }

  .week-day:hover {
    transform: translateY(-2px);
    border-color: #1d9e75;
  }

  .week-day.today {
    border-color: #1d9e75;
    box-shadow: 0 0 0 2px #e1f5ee;
  }

  .wd-header {
    text-align: center;
    margin-bottom: 10px;
  }

  .wd-name {
    display: block;
    font-size: 11px;
    font-weight: 700;
    color: #94a3b8;
    text-transform: uppercase;
  }

  .wd-date {
    display: block;
    font-size: 13px;
    font-weight: 600;
    color: #1e293b;
    margin-top: 2px;
  }

  .mini-bar {
    height: 4px;
    background: #e2e8f0;
    border-radius: 99px;
    margin: 6px 0 2px;
    overflow: hidden;
  }

  .mini-taken {
    height: 100%;
    background: #1d9e75;
    border-radius: 99px;
    transition: width 0.3s;
  }

  .wd-count {
    font-size: 11px;
    color: #64748b;
  }

  .day-empty {
    text-align: center;
    color: #cbd5e1;
    font-size: 18px;
    margin: 20px 0;
  }

  .day-doses {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 5px;
  }

  .day-dose {
    display: flex;
    align-items: center;
    gap: 5px;
    font-size: 11px;
  }

  .dd-dot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #cbd5e1;
    flex-shrink: 0;
  }

  .day-dose.taken   .dd-dot { background: #1d9e75; }
  .day-dose.pending .dd-dot { background: #ef9f27; }
  .day-dose.missed  .dd-dot { background: #ef4444; }

  .dd-time {
    color: #94a3b8;
    flex-shrink: 0;
  }

  .dd-med {
    color: #1e293b;
    font-weight: 600;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    flex: 1;
  }

  .month-cal {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 4px;
    margin-top: 10px;
  }

  .cal-head {
    text-align: center;
    font-size: 11px;
    font-weight: 700;
    color: #94a3b8;
    text-transform: uppercase;
    padding: 6px 0;
  }

  .cal-empty { background: transparent; }

  .cal-cell {
    background: #fff;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    padding: 6px;
    min-height: 64px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 3px;
    cursor: pointer;
    transition: all 0.2s;
  }

  .cal-cell:hover {
    background: #f8fafc;
    border-color: #1d9e75;
  }

  .cal-cell.today {
    border-color: #1d9e75;
    background: #f0fdf8;
  }

  .cal-cell.has-taken { background: #f0fdf8; }
  .cal-cell.has-missed { background: #fff5f5; }

  .cal-d {
    font-size: 13px;
    font-weight: 600;
    color: #1e293b;
  }

  .cal-dots {
    display: flex;
    gap: 2px;
    flex-wrap: wrap;
    justify-content: center;
  }

  .cdot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
  }

  .cdot-taken  { background: #1d9e75; }
  .cdot-missed { background: #ef4444; }

  .cal-count {
    font-size: 10px;
    color: #94a3b8;
  }

  .year-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    margin-top: 10px;
  }

  .year-month {
    background: #fff;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    cursor: pointer;
    transition: all 0.2s;
  }

  .year-month:hover {
    border-color: #1d9e75;
    transform: scale(1.02);
  }

  .year-month.current {
    border-color: #1d9e75;
    box-shadow: 0 0 0 2px #e1f5ee;
  }

  .year-month.future { opacity: 0.6; }

  .ym-label {
    font-size: 15px;
    font-weight: 700;
    color: #1e293b;
  }

  .ym-bar {
    height: 6px;
    background: #e2e8f0;
    border-radius: 99px;
    overflow: hidden;
  }

  .ym-taken {
    height: 100%;
    background: #1d9e75;
    border-radius: 99px;
    transition: width 0.4s;
  }

  .ym-stats {
    display: flex;
    justify-content: space-between;
    font-size: 11px;
  }

  .ym-pct   { color: #1d9e75; font-weight: 700; }
  .ym-total { color: #94a3b8; }
  .ym-none  { font-size: 20px; color: #e2e8f0; text-align: center; }
</style>
