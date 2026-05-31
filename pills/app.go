package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

const errEmailAlreadyInUse = "email already in use"

type App struct {
	ctx context.Context
	db  *gorm.DB
}

type PatientScheduleView struct {
	ScheduleID     uint
	MedicationID   uint
	Medication     string
	MedicationType string
	StartDate      time.Time
	EndDate        time.Time
	StartHour      time.Time
	Frequency      uint
	Instructions   string
	Dosage         string
	Quantity       uint
}

func dbPath() string {
	if runtime.GOOS == "darwin" {
		homeDir, err := os.UserHomeDir()
		if err != nil {
			log.Printf("[macOS] could not resolve home directory: %v; using relative path", err)
			return "test.db"
		}
		dir := filepath.Join(homeDir, "Library", "Application Support", "pills")
		if err := os.MkdirAll(dir, 0755); err != nil {
			log.Printf("[macOS] could not create app support directory %s: %v; using relative path", dir, err)
			return "test.db"
		}
		path := filepath.Join(dir, "test.db")
		log.Printf("[macOS] database path: %s", path)
		return path
	}
	return "test.db"
}

func NewApp() *App {

	db, err := gorm.Open(sqlite.Open(dbPath()), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	db.AutoMigrate(&User{})
	db.AutoMigrate(&Caregiver{}, &Medication{}, &Schedule{})
	db.AutoMigrate(&Log{})
	return &App{db: db}
}

func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

func (a *App) CreateUser(firstName, lastName, username, email, password, gender string, role UserRole) error {
	normalizedEmail := normalizeEmail(email)
	if normalizedEmail == "" {
		return errors.New("email is required")
	}

	var existingUser User
	lookupResult := a.db.Where("email = ?", normalizedEmail).First(&existingUser)
	if lookupResult.Error == nil {
		return errors.New(errEmailAlreadyInUse)
	}
	if lookupResult.Error != nil && !errors.Is(lookupResult.Error, gorm.ErrRecordNotFound) {
		return lookupResult.Error
	}

	hashedPassword, err := hashPassword(password)
	if err != nil {
		return err
	}

	newUser := &User{
		FirstName: firstName,
		LastName:  lastName,
		UserName:  username,
		Email:     normalizedEmail,
		Password:  hashedPassword,
		Gender:    gender,
		Role:      role,
	}

	result := a.db.Create(&newUser)
	if result.Error != nil {
		if isEmailUniqueViolation(result.Error) {
			return errors.New(errEmailAlreadyInUse)
		}
		return result.Error
	}
	return nil
}

func (a *App) AddPatientToCaregiver(caregiverUserId, patientUserId uint) error {
	var caregiver User
	result := a.db.First(&caregiver, caregiverUserId)
	if result.Error != nil {
		return result.Error
	}
	if caregiver.Role != Caregivers {
		return gorm.ErrInvalidData
	}

	var patient User
	result = a.db.First(&patient, patientUserId)
	if result.Error != nil {
		return result.Error
	}
	if patient.Role != Patients {
		return gorm.ErrInvalidData
	}

	var existing Caregiver
	result = a.db.Where("user_id = ? AND patients_id = ?", caregiverUserId, patientUserId).First(&existing)
	if result.Error == nil {
		return nil
	}

	link := &Caregiver{
		UserId:     caregiverUserId,
		PatientsId: patientUserId,
	}
	result = a.db.Create(link)
	return result.Error
}

func (a *App) RemovePatientFromCaregiver(caregiverUserId, patientUserId uint) error {
	result := a.db.Where("user_id = ? AND patients_id = ?", caregiverUserId, patientUserId).Delete(&Caregiver{})
	return result.Error
}

func (a *App) GetCaregiverPatients(caregiverUserId uint) ([]User, error) {
	var links []Caregiver
	result := a.db.Where("user_id = ?", caregiverUserId).Find(&links)
	if result.Error != nil {
		return nil, result.Error
	}

	if len(links) == 0 {
		return []User{}, nil
	}

	patientIds := make([]uint, len(links))
	for i, l := range links {
		patientIds[i] = l.PatientsId
	}

	var patients []User
	result = a.db.Where("id IN ?", patientIds).Find(&patients)
	if result.Error != nil {
		return nil, result.Error
	}
	return patients, nil
}

func (a *App) AddPatientByEmail(caregiverUserId uint, email string) error {
	normalizedEmail := normalizeEmail(email)

	var caregiver User
	if err := a.db.First(&caregiver, caregiverUserId).Error; err != nil {
		return err
	}
	if caregiver.Role != Caregivers {
		return errors.New("user is not a caregiver")
	}

	var patient User
	if err := a.db.Where("email = ?", normalizedEmail).First(&patient).Error; err != nil {
		return errors.New("no patient account found with that email")
	}
	if patient.Role != Patients {
		return errors.New("no patient account found with that email")
	}

	var existing Caregiver
	if err := a.db.Where("user_id = ? AND patients_id = ?", caregiverUserId, patient.ID).First(&existing).Error; err == nil {
		return errors.New("patient is already linked to your account")
	}

	link := &Caregiver{UserId: caregiverUserId, PatientsId: patient.ID}
	return a.db.Create(link).Error
}

func (a *App) GetAllPatients() ([]User, error) {
	var patients []User
	result := a.db.Where("role = ?", Patients).Find(&patients)
	if result.Error != nil {
		return nil, result.Error
	}
	return patients, nil
}

func (a *App) GetUsers() ([]User, error) {
	var users []User
	result := a.db.Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return users, nil
}

type DrugInfo struct {
	ID                  uint   `json:"id"`
	TradeName           string `json:"trade_name"`
	ScientificName      string `json:"scientific_name"`
	Size                string `json:"size"`
	SizeUnit            string `json:"size_unit"`
	LegalStatus         string `json:"legal_status"`
	ManufactureName     string `json:"manufacture_name"`
	AuthorizationStatus string `json:"authorization_status"`
}

func (a *App) SearchDrugInfo(query string) ([]DrugInfo, error) {
	if len(strings.TrimSpace(query)) < 3 {
		return []DrugInfo{}, nil
	}
	like := "%" + query + "%"
	var results []DrugInfo
	result := a.db.Raw(
		`SELECT id, trade_name, scientific_name, size, size_unit, legal_status, manufacture_name, authorization_status
		 FROM drug_info WHERE trade_name LIKE ? OR scientific_name LIKE ? LIMIT 20`,
		like, like,
	).Scan(&results)
	if result.Error != nil {
		return nil, result.Error
	}
	return results, nil
}

func (a *App) GetMedications() ([]Medication, error) {
	var medications []Medication
	result := a.db.Order("name asc").Find(&medications)
	if result.Error != nil {
		return nil, result.Error
	}
	return medications, nil
}

func (a *App) CreateMedication(name string, medType MedicationType, photoUrl string) (*Medication, error) {
	trimmedName := strings.TrimSpace(name)
	if trimmedName == "" {
		return nil, errors.New("medication name is required")
	}

	if medType == "" {
		medType = Pill
	}

	var medication Medication
	result := a.db.Where("name = ? AND type = ?", trimmedName, medType).First(&medication)
	if result.Error == nil {
		return &medication, nil
	}
	if !errors.Is(result.Error, gorm.ErrRecordNotFound) {
		return nil, result.Error
	}

	medication = Medication{
		Name:     trimmedName,
		Type:     medType,
		PhotoUrl: photoUrl,
	}
	result = a.db.Create(&medication)
	if result.Error != nil {
		return nil, result.Error
	}

	return &medication, nil
}

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
	if err := a.verifyCaregiverPatientLink(caregiverUserId, patientUserId); err != nil {
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
		PatientId:     patientUserId,
		MedicationId:  medication.ID,
		StartDate:     parsedStartDate,
		EndDate:       parsedEndDate,
		StartHour:     parsedStartHour,
		Frequency:     frequency,
		Instructions:  instructions,
		Dosage:        dosage,
		Quantity:      quantity,
	}

	if err := a.db.Create(&newSchedule).Error; err != nil {
		return err
	}
	return nil
}

func (a *App) GetPatientSchedules(patientUserId uint) ([]PatientScheduleView, error) {
	var patient User
	if err := a.db.First(&patient, patientUserId).Error; err != nil {
		return nil, err
	}
	if patient.Role != Patients {
		return nil, errors.New("user is not a patient")
	}

	var schedules []PatientScheduleView
	result := a.db.Table("schedules").
		Select("schedules.id as schedule_id, schedules.medication_id, medications.name as medication, medications.type as medication_type, schedules.start_date, schedules.end_date, schedules.start_hour, schedules.interval_hours as frequency, schedules.instructions, schedules.dosage, schedules.quantity").
		Joins("left join medications on medications.id = schedules.medication_id").
		Where("schedules.patient_id = ?", patientUserId).
		Order("schedules.start_date asc, schedules.start_hour asc").
		Scan(&schedules)
	if result.Error != nil {
		return nil, result.Error
	}

	return schedules, nil
}

func (a *App) verifyCaregiverPatientLink(caregiverUserId, patientUserId uint) error {
	var caregiver User
	if err := a.db.First(&caregiver, caregiverUserId).Error; err != nil {
		return err
	}
	if caregiver.Role != Caregivers {
		return errors.New("user is not a caregiver")
	}

	var patient User
	if err := a.db.First(&patient, patientUserId).Error; err != nil {
		return err
	}
	if patient.Role != Patients {
		return errors.New("selected user is not a patient")
	}

	var link Caregiver
	if err := a.db.Where("user_id = ? AND patients_id = ?", caregiverUserId, patientUserId).First(&link).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("patient is not linked to this caregiver")
		}
		return err
	}
	return nil
}

func (a *App) GetCaregiverPatientSchedules(caregiverUserId, patientUserId uint) ([]PatientScheduleView, error) {
	if err := a.verifyCaregiverPatientLink(caregiverUserId, patientUserId); err != nil {
		return nil, err
	}
	return a.GetPatientSchedules(patientUserId)
}

func (a *App) UpdateScheduleForPatient(
	caregiverUserId uint,
	scheduleId uint,
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
	var schedule Schedule
	if err := a.db.First(&schedule, scheduleId).Error; err != nil {
		return err
	}

	if err := a.verifyCaregiverPatientLink(caregiverUserId, schedule.PatientId); err != nil {
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

	schedule.MedicationId = medication.ID
	schedule.StartDate = parsedStartDate
	schedule.EndDate = parsedEndDate
	schedule.StartHour = parsedStartHour
	schedule.Frequency = frequency
	schedule.Instructions = instructions
	schedule.Dosage = dosage
	schedule.Quantity = quantity

	return a.db.Save(&schedule).Error
}

type LogEntry struct {
	ScheduleId    uint
	ScheduledAtMs int64
	Taken         bool
	Note          string
}

func (a *App) LogDose(scheduleId uint, scheduledAtMs int64, taken bool, note string) error {
	var log Log
	result := a.db.Where("schedule_id = ? AND scheduled_at_ms = ?", scheduleId, scheduledAtMs).First(&log)
	if result.Error != nil && !errors.Is(result.Error, gorm.ErrRecordNotFound) {
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

func (a *App) GetPatientLogs(patientUserId uint) ([]LogEntry, error) {
	var scheduleIds []uint
	if err := a.db.Model(&Schedule{}).Where("patient_id = ?", patientUserId).Pluck("id", &scheduleIds).Error; err != nil {
		return nil, err
	}
	if len(scheduleIds) == 0 {
		return []LogEntry{}, nil
	}

	var logs []Log
	if err := a.db.Where("schedule_id IN ?", scheduleIds).Find(&logs).Error; err != nil {
		return nil, err
	}

	entries := make([]LogEntry, len(logs))
	for i, l := range logs {
		entries[i] = LogEntry{
			ScheduleId:    l.ScheduleId,
			ScheduledAtMs: l.ScheduledAtMs,
			Taken:         l.TakenAt != nil,
			Note:          l.Note,
		}
	}
	return entries, nil
}

func (a *App) DeleteLog(scheduleId uint, scheduledAtMs int64) error {
	return a.db.Where("schedule_id = ? AND scheduled_at_ms = ?", scheduleId, scheduledAtMs).Delete(&Log{}).Error
}

func (a *App) DeleteUser(id uint) error {
	result := a.db.Delete(&User{}, id)
	if result.Error != nil {
		return result.Error
	}
	return nil
}

func (a *App) UpdateUser(id uint, firstName, lastName, username, email, password, gender string, role UserRole) error {
	var user User
	result := a.db.First(&user, id)
	if result.Error != nil {
		return result.Error
	}

	normalizedEmail := normalizeEmail(email)
	if normalizedEmail == "" {
		return errors.New("email is required")
	}

	user.FirstName = firstName
	user.LastName = lastName
	user.UserName = username
	user.Email = normalizedEmail
	if password != "" {
		hashedPassword, err := hashPassword(password)
		if err != nil {
			return err
		}
		user.Password = hashedPassword
	}
	user.Gender = gender
	user.Role = role

	result = a.db.Save(&user)
	if result.Error != nil {
		if isEmailUniqueViolation(result.Error) {
			return errors.New(errEmailAlreadyInUse)
		}
		return result.Error
	}

	return nil
}

func (a *App) Login(email, password string) (*User, error) {
	normalizedEmail := normalizeEmail(email)
	var user User
	result := a.db.Where("email = ?", normalizedEmail).First(&user)
	if result.Error != nil {
		return nil, result.Error
	}

	if isBcryptHash(user.Password) {
		if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
			return nil, errors.New("invalid email or password")
		}
		return &user, nil
	}

	hashedPassword, err := hashPassword(password)
	if err == nil {
		user.Password = hashedPassword
		_ = a.db.Save(&user)
	}

	return &user, nil
}

func hashPassword(password string) (string, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hashedPassword), nil
}

func isBcryptHash(hash string) bool {
	return len(hash) >= 4 && hash[:4] == "$2a$" ||
		len(hash) >= 4 && hash[:4] == "$2b$" ||
		len(hash) >= 4 && hash[:4] == "$2y$"
}

func normalizeEmail(email string) string {
	return strings.ToLower(strings.TrimSpace(email))
}

func isEmailUniqueViolation(err error) bool {
	if err == nil {
		return false
	}

	errorText := strings.ToLower(err.Error())
	return strings.Contains(errorText, "unique constraint failed: users.email") ||
		(strings.Contains(errorText, "duplicate key") && strings.Contains(errorText, "email"))
}
