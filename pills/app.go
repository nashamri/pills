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
