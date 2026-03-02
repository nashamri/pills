package main

import (
	"embed"
	"fmt"
	"time"

	"github.com/wailsapp/wails/v2"
	"github.com/wailsapp/wails/v2/pkg/options"
	"github.com/wailsapp/wails/v2/pkg/options/assetserver"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	FirstName string
	LastName  string
	UserName  string
	Email     string
	Password  string
	Gender    string
	Role      UserRole
}

type UserRole int

const (
	Admins = iota
	Patients
	Caregivers
)

type Schedules struct {
	gorm.Model
	MedicationId  uint
	StartDate     time.Time
	EndDate       time.Time
	StartHour     time.Time
	IntervalHours uint
	Instructions  string
	Dosage        string
	Quantity      uint
}

type Patient struct {
	gorm.Model
	DateOfBirth  time.Time
	MedicalNotes string
}
type Caregiver struct {
	gorm.Model
	UserId     uint
	PatientsId uint
}
type Measurements struct {
	gorm.Model
	PatientId   uint
	CaregiverId uint
	Type        UserRole
	Value       string
	MeasuredAt  time.Time
	Notes       string
}
type Report struct {
	gorm.Model
	PatientId   uint
	CaregiverId uint
	FilePath    string
}
type Notifications struct {
	gorm.Model
	PatientId         uint
	MedicationId      uint
	NotificationSound string
	Type              NotificationType
	SentAt            time.Time
	Read              bool
}

type NotificationType int

const (
	Voice NotificationType = iota
	Text
)

type Preferences struct {
	gorm.Model
	UserId       uint
	Language     string
	FontSize     string
	ContrastMode string
	Theme        string
}

type DrugDatabase struct {
	gorm.Model
	Name         string
	Description  string
	Interactions string
	Manufacturer string
	ImageUrl     string
}
type Logs struct {
	gorm.Model
	ScheduleId uint
	TakenAt    time.Time
	Note       string
}

type Medications struct {
	gorm.Model
	DrugInfoId uint
	Name       string
	PhotoUrl   string
	Type       MedicationType
}
type MedicationType string

const (
	Dose = iota
	Pill
	Drink
)

type Admin struct {
	gorm.Model
	UserId uint
}

var assets embed.FS

func main() {

	app := NewApp()

	err := wails.Run(&options.App{
		Title:  "pills",
		Width:  1024,
		Height: 768,
		AssetServer: &assetserver.Options{
			Assets: assets,
		},
		BackgroundColour: &options.RGBA{R: 27, G: 38, B: 54, A: 1},
		OnStartup:        app.startup,
		Bind: []interface{}{
			app,
		},
	})

	db, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})
	if err != nil {
		fmt.Printf("Error details: %v\n", err)
		panic("failed to connect database")
	}

	db.AutoMigrate(&User{})

	db.Create(&User{FirstName: "saud", LastName: "ahmad", UserName: "saud111", Email: "saud@.com", Password: "password123", Gender: "Male", Role: Admins})
	db.Create(&User{FirstName: "fahad", LastName: "farhan", UserName: "fahad111", Email: "fahad@.com", Password: "password123", Gender: "Male", Role: Admins})
	db.Create(&User{FirstName: "ahmad", LastName: "nasser", UserName: "ahmad111", Email: "ahmad@.com", Password: "password123", Gender: "Male", Role: Admins})

}
