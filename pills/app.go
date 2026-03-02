package main

import (
	"context"
	"fmt"
	"strings"

	"gorm.io/gorm"
)

// App struct
type App struct {
	ctx context.Context
	db  *gorm.DB
}

type UserDTO struct {
	ID        uint     `json:"id"`
	FirstName string   `json:"firstName"`
	LastName  string   `json:"lastName"`
	UserName  string   `json:"userName"`
	Email     string   `json:"email"`
	Password  string   `json:"password"`
	Gender    string   `json:"gender"`
	Role      UserRole `json:"role"`
}

// NewApp creates a new App application struct
func NewApp(db *gorm.DB) *App {
	return &App{db: db}
}

// startup is called when the app starts. The context is saved
// so we can call the runtime methods
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

// Greet returns a greeting for the given name
func (a *App) Greet(name string) string {
	return fmt.Sprintf("Hello %s, It's show time!", name)
}

func userToDTO(user User) UserDTO {
	return UserDTO{
		ID:        user.ID,
		FirstName: user.FirstName,
		LastName:  user.LastName,
		UserName:  user.UserName,
		Email:     user.Email,
		Password:  user.Password,
		Gender:    user.Gender,
		Role:      user.Role,
	}
}

func dtoToUser(dto UserDTO) User {
	return User{
		FirstName: strings.TrimSpace(dto.FirstName),
		LastName:  strings.TrimSpace(dto.LastName),
		UserName:  strings.TrimSpace(dto.UserName),
		Email:     strings.TrimSpace(dto.Email),
		Password:  dto.Password,
		Gender:    strings.TrimSpace(dto.Gender),
		Role:      dto.Role,
	}
}

func (a *App) validateUser(dto UserDTO) error {
	if strings.TrimSpace(dto.FirstName) == "" {
		return fmt.Errorf("first name is required")
	}
	if strings.TrimSpace(dto.UserName) == "" {
		return fmt.Errorf("username is required")
	}
	if strings.TrimSpace(dto.Email) == "" {
		return fmt.Errorf("email is required")
	}
	return nil
}

func (a *App) CreateUser(dto UserDTO) (UserDTO, error) {
	if err := a.validateUser(dto); err != nil {
		return UserDTO{}, err
	}

	user := dtoToUser(dto)
	if err := a.db.Create(&user).Error; err != nil {
		return UserDTO{}, err
	}

	return userToDTO(user), nil
}

func (a *App) GetAllUsers() ([]UserDTO, error) {
	var users []User
	if err := a.db.Order("id asc").Find(&users).Error; err != nil {
		return nil, err
	}

	result := make([]UserDTO, 0, len(users))
	for _, user := range users {
		result = append(result, userToDTO(user))
	}

	return result, nil
}

func (a *App) GetUser(id uint) (UserDTO, error) {
	var user User
	if err := a.db.First(&user, id).Error; err != nil {
		return UserDTO{}, err
	}

	return userToDTO(user), nil
}

func (a *App) UpdateUser(dto UserDTO) (UserDTO, error) {
	if dto.ID == 0 {
		return UserDTO{}, fmt.Errorf("id is required")
	}
	if err := a.validateUser(dto); err != nil {
		return UserDTO{}, err
	}

	var user User
	if err := a.db.First(&user, dto.ID).Error; err != nil {
		return UserDTO{}, err
	}

	user.FirstName = strings.TrimSpace(dto.FirstName)
	user.LastName = strings.TrimSpace(dto.LastName)
	user.UserName = strings.TrimSpace(dto.UserName)
	user.Email = strings.TrimSpace(dto.Email)
	user.Password = dto.Password
	user.Gender = strings.TrimSpace(dto.Gender)
	user.Role = dto.Role

	if err := a.db.Save(&user).Error; err != nil {
		return UserDTO{}, err
	}

	return userToDTO(user), nil
}

func (a *App) DeleteUser(id uint) error {
	if id == 0 {
		return fmt.Errorf("id is required")
	}

	result := a.db.Delete(&User{}, id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return fmt.Errorf("user not found")
	}

	return nil
}
