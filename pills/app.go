package main

import (
	"context"
	"errors"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type App struct {
	ctx context.Context
	db  *gorm.DB
}

func NewApp() *App {

	db, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	db.AutoMigrate(&User{})
	return &App{db: db}
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

	// Fallback for legacy plain-text records; upgrade to bcrypt after successful login.
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
