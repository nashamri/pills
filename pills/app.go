package main

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

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
	IntervalHours  uint
	Instructions   string
	Dosage         string
	Quantity       uint
}

func NewApp() *App {

	db, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	db.AutoMigrate(&User{})
	db.AutoMigrate(&Caregiver{}, &Medication{}, &Schedule{})
	return &App{db: db}
}

func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

func (a *App) CreateUser(firstName, lastName, username, email, password, gender string, role UserRole) error {
	hashedPassword, err := hashPassword(password)
	if err != nil {
		return err
	}

	newUser := &User{
		FirstName: firstName,
		LastName:  lastName,
		UserName:  username,
		Email:     email,
		Password:  hashedPassword,
		Gender:    gender,
		Role:      role,
	}

	result := a.db.Create(&newUser)
	if result.Error != nil {
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
	intervalHours uint,
	instructions string,
	dosage string,
	quantity uint,
) error {
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

	if intervalHours == 0 {
		return errors.New("interval hours must be greater than zero")
	}

	newSchedule := Schedule{
		PatientId:     patientUserId,
		MedicationId:  medication.ID,
		StartDate:     parsedStartDate,
		EndDate:       parsedEndDate,
		StartHour:     parsedStartHour,
		IntervalHours: intervalHours,
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
		Select("schedules.id as schedule_id, schedules.medication_id, medications.name as medication, medications.type as medication_type, schedules.start_date, schedules.end_date, schedules.start_hour, schedules.interval_hours, schedules.instructions, schedules.dosage, schedules.quantity").
		Joins("left join medications on medications.id = schedules.medication_id").
		Where("schedules.patient_id = ?", patientUserId).
		Order("schedules.start_date asc, schedules.start_hour asc").
		Scan(&schedules)
	if result.Error != nil {
		return nil, result.Error
	}

	return schedules, nil
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

	user.FirstName = firstName
	user.LastName = lastName
	user.UserName = username
	user.Email = email
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
		return result.Error
	}

	return nil
}

func (a *App) Login(email, password string) (*User, error) {
	var user User
	result := a.db.Where("email = ?", email).First(&user)
	if result.Error != nil {
		return nil, result.Error
	}

	if isBcryptHash(user.Password) {
		if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
			return nil, errors.New("invalid email or password")
		}
		return &user, nil
	}

	if user.Password != password {
		return nil, errors.New("invalid email or password")
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
