<script>
  import { onMount } from 'svelte';
  import { currentUser } from '../stores/auth.js';
  import { GetPatientSchedules, LogDose, DeleteLog, GetPatientLogs } from '../../wailsjs/go/main/App.js';

  const MS_DAY = 86400000;
  const ADHERENCE_DOT_INDICES = [0, 1, 2];
  const WEEKDAY_HEADERS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const VIEW_MODES = ['daily', 'weekly', 'monthly', 'yearly'];

  let rawSchedules = [];
  let loading = true;
  let error = '';
  let activeView = 'daily';
  let viewOffset = 0;
  let doseStatusMap = {};
  let noteMap = {};

  function getViewBounds(view, offset) {
    const now = new Date();
    const y = now.getFullYear();
    const mo = now.getMonth();
    const d = now.getDate();

    if (view === 'daily') {
      const start = new Date(y, mo, d + offset);
      return { start, end: new Date(start.getTime() + MS_DAY) };
    }
    if (view === 'weekly') {
      const start = new Date(y, mo, d - now.getDay() + offset * 7);
      return { start, end: new Date(start.getTime() + 7 * MS_DAY) };
    }
    if (view === 'monthly') {
      return {
        start: new Date(y, mo + offset, 1),
        end: new Date(y, mo + offset + 1, 1),
      };
    }
    return {
      start: new Date(y + offset, 0, 1),
      end: new Date(y + offset + 1, 0, 1),
    };
  }

  function getViewLabel(view, offset) {
    const { start, end } = getViewBounds(view, offset);
    if (view === 'daily') {
      return start.toLocaleDateString('en-US', {
        weekday: 'long', year: 'numeric', month: 'long', day: 'numeric',
      });
    }
    if (view === 'weekly') {
      const last = new Date(end.getTime() - 1);
      return `${start.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })} – ${last.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}`;
    }
    if (view === 'monthly') {
      return start.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });
    }
    return String(start.getFullYear());
  }

  function formatTime(date) {
    return date.toLocaleTimeString('en-US', {
      hour: '2-digit', minute: '2-digit', hour12: true,
    });
  }

  function dosesOnDate(allDoses, date) {
    const key = date.toDateString();
    return allDoses.filter(d => d._time.toDateString() === key);
  }

  function dayAdherencePct(dayDoses, statusMap) {
    const due = dayDoses.filter(d => d.isPast);
    if (!due.length) return null;
    const taken = due.filter(d => statusMap[d.id] === 'taken').length;
    return Math.round((taken / due.length) * 100);
  }

  function adherenceFilledDots(pct) {
    if (pct >= 67) return 3;
    if (pct >= 34) return 2;
    if (pct > 0) return 1;
    return 0;
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
      let t = new Date(
        sStart.getFullYear(), sStart.getMonth(), sStart.getDate(),
        sHour.getUTCHours(), sHour.getUTCMinutes(),
      );

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

  function withStatus(doses, statusMap) {
    return doses.map(d => {
      const manual = statusMap[d.id];
      if (manual) return { ...d, status: manual };
      return { ...d, status: d.isPast ? 'pending' : 'upcoming' };
    });
  }

  function buildMonthCells(allDoses, monthStart, statusMap) {
    const daysInMonth = new Date(
      monthStart.getFullYear(), monthStart.getMonth() + 1, 0,
    ).getDate();
    const todayStr = new Date().toDateString();
    const cells = Array(monthStart.getDay()).fill(null);

    for (let d = 1; d <= daysInMonth; d++) {
      const day = new Date(monthStart.getFullYear(), monthStart.getMonth(), d);
      const dayDoses = dosesOnDate(allDoses, day);
      const adherencePct = dayAdherencePct(dayDoses, statusMap);

      cells.push({
        day,
        d,
        isToday: day.toDateString() === todayStr,
        total: dayDoses.length,
        adherencePct,
        filledDots: adherencePct !== null ? adherenceFilledDots(adherencePct) : 0,
      });
    }

    return cells;
  }

  function parseId(id) {
    const i = id.indexOf('-');
    return {
      scheduleId: Number(id.slice(0, i)),
      scheduledAtMs: Number(id.slice(i + 1)),
    };
  }

  function goToDay(date) {
    const now = new Date();
    const target = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    viewOffset = Math.round((target.getTime() - today.getTime()) / MS_DAY);
    activeView = 'daily';
  }

  function goToMonth(mStart) {
    const now = new Date();
    viewOffset =
      (mStart.getFullYear() - now.getFullYear()) * 12 +
      (mStart.getMonth() - now.getMonth());
    activeView = 'monthly';
  }

  function setView(v) {
    activeView = v;
    viewOffset = 0;
  }

  function navigate(dir) {
    viewOffset += dir;
  }

  function setDoseStatus(id, status) {
    if (status === null) {
      const { [id]: _, ...rest } = doseStatusMap;
      doseStatusMap = rest;
    } else {
      doseStatusMap = { ...doseStatusMap, [id]: status };
    }

    const { scheduleId, scheduledAtMs } = parseId(id);
    if (status === null) {
      DeleteLog(scheduleId, scheduledAtMs).catch(() => {});
    } else {
      LogDose(scheduleId, scheduledAtMs, status === 'taken', noteMap[id] || '').catch(() => {});
    }
  }

  function saveNote(id, note) {
    noteMap = { ...noteMap, [id]: note };
    const status = doseStatusMap[id];
    if (!status) return;
    const { scheduleId, scheduledAtMs } = parseId(id);
    LogDose(scheduleId, scheduledAtMs, status === 'taken', note).catch(() => {});
  }

  $: bounds = getViewBounds(activeView, viewOffset);
  $: viewLabel = getViewLabel(activeView, viewOffset);
  $: allDoses = computeDoses(rawSchedules, bounds.start, bounds.end);
  $: doses = withStatus(allDoses, doseStatusMap);

  $: dailyList = doses.map(d => ({ ...d, time: formatTime(d._time) }));

  $: weekDays = Array.from({ length: 7 }, (_, i) => {
    const day = new Date(bounds.start.getTime() + i * MS_DAY);
    const dayDoses = dosesOnDate(allDoses, day);
    const adherencePct = dayAdherencePct(dayDoses, doseStatusMap);

    return {
      fullDate: day,
      label: day.toLocaleDateString('en-US', { weekday: 'short' }),
      dateLabel: day.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
      isToday: day.toDateString() === new Date().toDateString(),
      total: dayDoses.length,
      adherencePct,
      doses: dayDoses.map(d => ({
        ...d,
        status: doseStatusMap[d.id] || (d.isPast ? 'missed' : 'upcoming'),
        time: formatTime(d._time),
      })),
    };
  });

  $: monthCells = buildMonthCells(allDoses, bounds.start, doseStatusMap);

  $: yearMonths = Array.from({ length: 12 }, (_, m) => {
    const now = new Date();
    const mStart = new Date(bounds.start.getFullYear(), m, 1);
    const mEnd = new Date(bounds.start.getFullYear(), m + 1, 1);
    const monthDoses = doses.filter(d => d._time >= mStart && d._time < mEnd);
    const taken = monthDoses.filter(d => d.status === 'taken').length;
    const total = monthDoses.length;

    return {
      mStart,
      label: mStart.toLocaleDateString('en-US', { month: 'short' }),
      total,
      takenPct: total ? Math.round((taken / total) * 100) : 0,
      isCurrent: mStart.getMonth() === now.getMonth() && mStart.getFullYear() === now.getFullYear(),
      isFuture: mStart > now,
    };
  });

  $: progress = (() => {
    const total = doses.length;
    if (!total) return null;

    const taken = doses.filter(d => d.status === 'taken').length;
    const missed = doses.filter(d => d.status === 'missed').length;
    const upcoming = total - taken - missed;

    return {
      total, taken, missed, upcoming,
      takenPct: (taken / total) * 100,
      missedPct: (missed / total) * 100,
      upcomingPct: (upcoming / total) * 100,
    };
  })();

  onMount(async () => {
    if (!$currentUser) {
      loading = false;
      error = 'Please log in to view your schedule.';
      return;
    }

    try {
      const [schedules, logs] = await Promise.all([
        GetPatientSchedules($currentUser.ID),
        GetPatientLogs($currentUser.ID),
      ]);

      rawSchedules = schedules || [];

      const statusMap = {};
      const notes = {};
      for (const log of logs || []) {
        const key = `${log.ScheduleId}-${log.ScheduledAtMs}`;
        statusMap[key] = log.Taken ? 'taken' : 'missed';
        if (log.Note) notes[key] = log.Note;
      }
      doseStatusMap = statusMap;
      noteMap = notes;
    } catch {
      error = 'Failed to load your schedule.';
    } finally {
      loading = false;
    }
  });
</script>

<div class="schedule-container" dir="ltr">
  <header class="sticky-header">
    <nav class="view-tabs">
      {#each VIEW_MODES as v}
        <button class="tab" class:active={activeView === v} on:click={() => setView(v)}>
          {v.charAt(0).toUpperCase() + v.slice(1)}
        </button>
      {/each}
    </nav>

    <div class="nav-header">
      <button class="nav-btn" on:click={() => navigate(-1)} aria-label="Previous">‹</button>
      <div class="header-center">
        <h1>{activeView.charAt(0).toUpperCase() + activeView.slice(1)} Schedule</h1>
        <p>{viewLabel}</p>
      </div>
      <button class="nav-btn" on:click={() => navigate(1)} aria-label="Next">›</button>
    </div>

    {#if progress}
      <section class="progress-section">
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
          <div class="seg seg-taken" style="width:{progress.takenPct}%"></div>
          <div class="seg seg-missed" style="width:{progress.missedPct}%"></div>
          <div class="seg seg-upcoming" style="width:{progress.upcomingPct}%"></div>
        </div>
      </section>
    {/if}
  </header>

  {#if loading}
    <p class="empty-text">Loading your medications...</p>
  {:else if error}
    <p class="empty-text error-text">{error}</p>
  {:else if activeView === 'daily'}
    {#if dailyList.length === 0}
      <p class="empty-text">No medications scheduled for this day.</p>
    {:else}
      <div class="timeline">
        {#each dailyList as item (item.id)}
          <article class="timeline-item {item.status}">
            <div class="time-column">
              <span class="time">{item.time}</span>
              <span class="dot" aria-hidden="true"></span>
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
              <div class="card-right">
                <div class="dose-actions">
                  <button
                    class="btn-action btn-taken"
                    class:is-active={doseStatusMap[item.id] === 'taken'}
                    on:click|stopPropagation={() => setDoseStatus(item.id, 'taken')}>
                    ✓ Taken
                  </button>
                  <button
                    class="btn-action btn-missed"
                    class:is-active={doseStatusMap[item.id] === 'missed'}
                    on:click|stopPropagation={() => setDoseStatus(item.id, 'missed')}>
                    ✗ Missed
                  </button>
                  <button
                    class="btn-action btn-undo"
                    on:click|stopPropagation={() => setDoseStatus(item.id, null)}
                    disabled={!doseStatusMap[item.id]}>
                    ↩ Undo
                  </button>
                </div>
                <textarea
                  class="note-input"
                  placeholder="Add a note..."
                  value={noteMap[item.id] || ''}
                  on:blur={e => saveNote(item.id, e.target.value)}
                  on:click|stopPropagation
                  rows="1"
                ></textarea>
              </div>
            </div>
          </article>
        {/each}
      </div>
    {/if}

  {:else if activeView === 'weekly'}
    <div class="week-grid">
      {#each weekDays as day}
        <button
          type="button"
          class="week-day"
          class:today={day.isToday}
          on:click={() => goToDay(day.fullDate)}>
          <div class="wd-header">
            <span class="wd-name">{day.label}</span>
            <span class="wd-date">{day.dateLabel}</span>
            {#if day.total > 0 && day.adherencePct !== null}
              <div class="mini-bar">
                <div class="mini-taken" style="width:{day.adherencePct}%"></div>
              </div>
              <span class="wd-count">{day.adherencePct}%</span>
            {:else if day.total > 0}
              <span class="wd-count wd-scheduled">Scheduled</span>
            {/if}
          </div>
          {#if day.doses.length === 0}
            <p class="day-empty">—</p>
          {:else}
            <ul class="day-doses">
              {#each day.doses as d}
                <li class="day-dose {d.status}">
                  <span class="dd-dot" aria-hidden="true"></span>
                  <span class="dd-time">{d.time}</span>
                  <span class="dd-med">{d.med}</span>
                </li>
              {/each}
            </ul>
          {/if}
        </button>
      {/each}
    </div>

  {:else if activeView === 'monthly'}
    <div class="month-cal">
      {#each WEEKDAY_HEADERS as h}
        <div class="cal-head">{h}</div>
      {/each}
      {#each monthCells as cell}
        {#if cell === null}
          <div class="cal-empty"></div>
        {:else}
          <button
            type="button"
            class="cal-cell"
            class:today={cell.isToday}
            class:has-scheduled={cell.total > 0}
            on:click={() => goToDay(cell.day)}>
            <span class="cal-d">{cell.d}</span>
            {#if cell.total > 0}
              <div class="cal-dots" aria-label="Adherence indicator">
                {#each ADHERENCE_DOT_INDICES as i}
                  <span
                    class="cdot"
                    class:cdot-taken={i < cell.filledDots}
                    class:cdot-neutral={i >= cell.filledDots}
                  ></span>
                {/each}
              </div>
              {#if cell.adherencePct !== null}
                <span class="cal-pct">{cell.adherencePct}%</span>
              {/if}
            {/if}
          </button>
        {/if}
      {/each}
    </div>

  {:else}
    <div class="year-grid">
      {#each yearMonths as m}
        <button
          type="button"
          class="year-month"
          class:current={m.isCurrent}
          class:future={m.isFuture}
          on:click={() => goToMonth(m.mStart)}>
          <span class="ym-label">{m.label}</span>
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
        </button>
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
    max-width: 900px;
    margin: 0 auto 40px;
    padding: 0 20px;
  }

  .sticky-header {
    position: sticky;
    top: 0;
    z-index: 100;
    padding: 20px 0 10px;
    background-color: #f8fafc;
  }

  .view-tabs {
    display: flex;
    gap: 6px;
    justify-content: center;
    margin-bottom: 20px;
  }

  .tab {
    padding: 7px 18px;
    border: 1px solid #e2e8f0;
    border-radius: 20px;
    background: #fff;
    color: #64748b;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.15s, color 0.15s, border-color 0.15s;
  }

  .tab:hover { background: #f1f5f9; }

  .tab.active {
    border-color: #1d9e75;
    background: #1d9e75;
    color: #fff;
  }

  .nav-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 24px;
  }

  .header-center { text-align: center; }

  .header-center h1 {
    margin: 0;
    font-size: 24px;
    color: #1e293b;
  }

  .header-center p {
    margin-top: 4px;
    font-size: 14px;
    color: #64748b;
  }

  .nav-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    background: #fff;
    color: #64748b;
    font-size: 20px;
    cursor: pointer;
    transition: background 0.15s;
  }

  .nav-btn:hover { background: #f1f5f9; }

  .progress-section {
    margin-bottom: 18px;
    padding: 14px 18px;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    background: #fff;
  }

  .progress-labels {
    display: flex;
    flex-wrap: wrap;
    gap: 14px;
    margin-bottom: 8px;
  }

  .lbl {
    font-size: 12px;
    font-weight: 600;
  }

  .lbl-taken    { color: #1d9e75; }
  .lbl-missed   { color: #ef4444; }
  .lbl-upcoming { color: #94a3b8; }
  .lbl-total    { margin-left: auto; color: #1e293b; }

  .progress-bar {
    display: flex;
    height: 8px;
    overflow: hidden;
    border-radius: 99px;
    background: #f1f5f9;
  }

  .seg { height: 100%; transition: width 0.4s; }
  .seg-taken    { background: #1d9e75; }
  .seg-missed   { background: #ef4444; }
  .seg-upcoming { background: #cbd5e1; }

  .empty-text {
    margin-top: 60px;
    text-align: center;
    font-size: 15px;
    color: #64748b;
  }

  .error-text { color: #ef4444; }

  /* Daily */
  .timeline {
    position: relative;
    margin-top: 20px;
    padding-left: 20px;
  }

  .timeline::before {
    content: '';
    position: absolute;
    top: 0;
    bottom: 0;
    left: 88px;
    width: 2px;
    background: #e2e8f0;
  }

  .timeline-item {
    display: flex;
    gap: 30px;
    align-items: center;
    margin-bottom: 25px;
  }

  .timeline-item.taken  { opacity: 0.65; }
  .timeline-item.missed { opacity: 0.8; }

  .time-column {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: space-between;
    width: 80px;
  }

  .time {
    font-size: 14px;
    font-weight: 600;
    color: #64748b;
  }

  .dot {
    position: absolute;
    right: -11px;
    width: 12px;
    height: 12px;
    border: 3px solid #fff;
    border-radius: 50%;
    background: #cbd5e1;
  }

  .timeline-item.taken   .dot { background: #1d9e75; }
  .timeline-item.pending .dot { background: #ef9f27; }
  .timeline-item.missed  .dot { background: #ef4444; }

  .card {
    display: flex;
    flex: 1;
    align-items: flex-start;
    justify-content: space-between;
    padding: 18px;
    border: 1px solid #e2e8f0;
    border-left: 4px solid transparent;
    border-radius: 12px;
    background: #fff;
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
    font-size: 14px;
    font-weight: normal;
    color: #64748b;
  }

  .type {
    display: block;
    margin-top: 4px;
    font-size: 12px;
    color: #94a3b8;
  }

  .instructions {
    display: block;
    margin-top: 2px;
    font-size: 12px;
    font-style: italic;
    color: #64748b;
  }

  .card-right {
    display: flex;
    flex-direction: column;
    gap: 8px;
    align-items: flex-end;
    flex-shrink: 0;
  }

  .note-input {
    width: 220px;
    padding: 6px 10px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    background: #f8fafc;
    color: #475569;
    font-family: inherit;
    font-size: 12px;
    line-height: 1.4;
    resize: none;
    outline: none;
  }

  .note-input:focus {
    border-color: #1d9e75;
    background: #fff;
  }

  .note-input::placeholder { color: #cbd5e1; }

  .dose-actions {
    display: flex;
    gap: 6px;
    flex-shrink: 0;
  }

  .btn-action {
    padding: 7px 12px;
    border: 1.5px solid transparent;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 600;
    white-space: nowrap;
    cursor: pointer;
    transition: all 0.15s;
  }

  .btn-taken {
    border-color: #bbf7d0;
    background: #f0fdf8;
    color: #15803d;
  }

  .btn-taken:hover { border-color: #1d9e75; background: #dcfce7; }
  .btn-taken.is-active { border-color: #1d9e75; background: #1d9e75; color: #fff; }

  .btn-missed {
    border-color: #fecaca;
    background: #fff5f5;
    color: #b91c1c;
  }

  .btn-missed:hover { border-color: #ef4444; background: #fee2e2; }
  .btn-missed.is-active { border-color: #ef4444; background: #ef4444; color: #fff; }

  .btn-undo {
    border-color: #e2e8f0;
    background: #f8fafc;
    color: #94a3b8;
  }

  .btn-undo:hover:not(:disabled) {
    border-color: #cbd5e1;
    background: #f1f5f9;
    color: #64748b;
  }

  .btn-undo:disabled {
    opacity: 0.35;
    cursor: not-allowed;
  }

  /* Weekly */
  .week-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 10px;
    margin-top: 10px;
  }

  .week-day {
    min-height: 140px;
    padding: 12px 10px;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    background: #fff;
    text-align: inherit;
    cursor: pointer;
    transition: transform 0.1s, border-color 0.2s;
  }

  .week-day:hover {
    border-color: #1d9e75;
    transform: translateY(-2px);
  }

  .week-day.today { border-color: #1d9e75; }

  .wd-header { margin-bottom: 10px; text-align: center; }

  .wd-name {
    display: block;
    font-size: 11px;
    font-weight: 700;
    color: #94a3b8;
    text-transform: uppercase;
  }

  .wd-date {
    display: block;
    margin-top: 2px;
    font-size: 13px;
    font-weight: 600;
    color: #1e293b;
  }

  .mini-bar {
    height: 4px;
    margin: 6px 0 2px;
    overflow: hidden;
    border-radius: 99px;
    background: #e2e8f0;
  }

  .mini-taken {
    height: 100%;
    border-radius: 99px;
    background: #1d9e75;
    transition: width 0.3s;
  }

  .wd-count {
    font-size: 11px;
    color: #64748b;
  }

  .wd-scheduled { color: #94a3b8; }

  .day-empty {
    margin: 20px 0;
    text-align: center;
    font-size: 18px;
    color: #cbd5e1;
  }

  .day-doses {
    display: flex;
    flex-direction: column;
    gap: 5px;
    margin: 0;
    padding: 0;
    list-style: none;
  }

  .day-dose {
    display: flex;
    align-items: center;
    gap: 5px;
    font-size: 11px;
  }

  .dd-dot {
    flex-shrink: 0;
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #cbd5e1;
  }

  .day-dose.taken   .dd-dot { background: #1d9e75; }
  .day-dose.pending .dd-dot { background: #ef9f27; }
  .day-dose.missed  .dd-dot { background: #ef4444; }

  .dd-time { flex-shrink: 0; color: #94a3b8; }

  .dd-med {
    flex: 1;
    overflow: hidden;
    font-weight: 600;
    color: #1e293b;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  /* Monthly */
  .month-cal {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 4px;
    margin-top: 10px;
  }

  .cal-head {
    padding: 6px 0;
    text-align: center;
    font-size: 11px;
    font-weight: 700;
    color: #94a3b8;
    text-transform: uppercase;
  }

  .cal-empty { background: transparent; }

  .cal-cell {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 3px;
    min-height: 64px;
    padding: 6px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    background: #fff;
    cursor: pointer;
    transition: background 0.2s, border-color 0.2s;
  }

  .cal-cell:hover {
    border-color: #1d9e75;
    background: #f8fafc;
  }

  .cal-cell.today {
    border-color: #1d9e75;
    background: #f0fdf8;
  }

  .cal-cell.has-scheduled {
    border-color: #94a3b8;
    background: #f1f5f9;
  }

  .cal-d {
    font-size: 13px;
    font-weight: 600;
    color: #1e293b;
  }

  .cal-dots {
    display: flex;
    gap: 3px;
    justify-content: center;
  }

  .cdot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
  }

  .cdot-taken   { background: #1d9e75; }
  .cdot-neutral { background: #cbd5e1; }

  .cal-pct {
    font-size: 10px;
    font-weight: 600;
    color: #64748b;
  }

  /* Yearly */
  .year-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    margin-top: 10px;
  }

  .year-month {
    display: flex;
    flex-direction: column;
    gap: 8px;
    padding: 16px;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    background: #fff;
    text-align: inherit;
    cursor: pointer;
    transition: transform 0.2s, border-color 0.2s;
  }

  .year-month:hover {
    border-color: #1d9e75;
    transform: scale(1.02);
  }

  .year-month.current { border-color: #1d9e75; }
  .year-month.future  { opacity: 0.6; }

  .ym-label {
    font-size: 15px;
    font-weight: 700;
    color: #1e293b;
  }

  .ym-bar {
    height: 6px;
    overflow: hidden;
    border-radius: 99px;
    background: #e2e8f0;
  }

  .ym-taken {
    height: 100%;
    border-radius: 99px;
    background: #1d9e75;
    transition: width 0.4s;
  }

  .ym-stats {
    display: flex;
    justify-content: space-between;
    font-size: 11px;
  }

  .ym-pct   { font-weight: 700; color: #1d9e75; }
  .ym-total { color: #94a3b8; }
  .ym-none  { text-align: center; font-size: 20px; color: #e2e8f0; }
</style>
