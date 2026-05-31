func (a *App) LogDose(scheduleId uint, scheduledAtMs int64,
    taken bool, note string) error {

    var log Log
    result := a.db.Where("schedule_id = ? AND scheduled_at_ms = ?",
        scheduleId, scheduledAtMs).First(&log)
    if result.Error != nil &&
        !errors.Is(result.Error, gorm.ErrRecordNotFound) {
        return result.Error
    }

    log.ScheduleId = scheduleId
    log.ScheduledAtMs = scheduledAtMs
    log.Note = note
    if taken {
        now := time.Now()
        log.TakenAt = &now
    } else {
        log.TakenAt = nil
    }

    if errors.Is(result.Error, gorm.ErrRecordNotFound) {
        return a.db.Create(&log).Error
    }
    return a.db.Save(&log).Error
}
