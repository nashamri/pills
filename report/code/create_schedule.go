func (a *App) CreateScheduleForPatient(
    caregiverUserId uint,
    patientUserId uint,
    medicationName string,
    medicationType MedicationType,
    startDate string,
    endDate string,
    startHour string,
    frequency uint,
    instructions string,
    dosage string,
    quantity uint,
) error {
    if err := a.verifyCaregiverPatientLink(
        caregiverUserId, patientUserId); err != nil {
        return err
    }

    medication, err := a.CreateMedication(medicationName, medicationType, "")
    if err != nil {
        return err
    }

    parsedStartDate, err := time.Parse("2006-01-02", startDate)
    if err != nil {
        return fmt.Errorf("invalid start date: %w", err)
    }
    parsedEndDate, err := time.Parse("2006-01-02", endDate)
    if err != nil {
        return fmt.Errorf("invalid end date: %w", err)
    }
    if parsedEndDate.Before(parsedStartDate) {
        return errors.New("end date cannot be before start date")
    }
    parsedStartHour, err := time.Parse("15:04", startHour)
    if err != nil {
        return fmt.Errorf("invalid start hour: %w", err)
    }
    if frequency < 1 || frequency > 5 {
        return errors.New("frequency must be between 1 and 5")
    }

    newSchedule := Schedule{
        PatientId:    patientUserId,
        MedicationId: medication.ID,
        StartDate:    parsedStartDate,
        EndDate:      parsedEndDate,
        StartHour:    parsedStartHour,
        Frequency:    frequency,
        Instructions: instructions,
        Dosage:       dosage,
        Quantity:     quantity,
    }
    return a.db.Create(&newSchedule).Error
}
