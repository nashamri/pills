package main

import (
	"context"
	"fmt"

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

func (a *App) CreateUser(firstName, lastName, username, email, password, gender string, role int) string {
	newUser := User{
		FirstName: firstName,
		LastName:  lastName,
		UserName:  username,
		Email:     email,
		Password:  password,
		Gender:    gender,
		Role:      UserRole(role),
	}

	result := a.db.Create(&newUser)
	if result.Error != nil {
		return fmt.Sprintf("Error: %v", result.Error)
	}
	return "User created successfully!"
}
