package main

import (
	"context"

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
	newUser := &User{
		FirstName: firstName,
		LastName:  lastName,
		UserName:  username,
		Email:     email,
		Password:  password,
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
