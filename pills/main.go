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
	Id         uint
	F_Name     string
	L_Name     string
	UserName   string
	Email      string
	Password   string
	Gender     string
	Role       UserRole
	Created_at time.Time
}

type UserRole string

const (
	Admin      UserRole = "Admin"
	Patients   UserRole = "patients"
	Caregivers UserRole = "Caregivers"
)

type Schedules struct {
	gorm.Model
	Id             uint
	Patient_id     uint
	Pedication_id  uint
	Start_date     time.Time
	End_date       time.Time
	Start_hour     time.Time
	Interval_hours uint
	Instructions   string
	Dosage         string
	Quantity       uint
}

type patients struct {
	gorm.Model
	User_Id       uint
	date_of_birth time.Time
	medical_notes string
}
type caregivers struct {
	gorm.Model
	User_Id     uint
	Id          uint
	patients_id uint
}
type Measurements struct {
	gorm.Model
	Id           uint
	Patient_id   uint
	caergiver_id uint
	Type         UserRole
	value        string
	measured_at  time.Time
	notes        string
}
type report struct {
	gorm.Model
	Id           uint
	Patient_id   uint
	Caregiver_id uint
	file_path    string
	generated_at time.Time
}
type Notifications struct {
	gorm.Model
	Id                 uint
	Patient_id         uint
	Medication_id      uint
	Notification_sound string
	Type               NotificationType
	Sent_at            time.Time
	Read               bool
}

type NotificationType string

const (
	Voice NotificationType = "Voice"
	Text  NotificationType = "Text"
)

type Preferences struct {
	gorm.Model
	Id            uint
	User_Id       uint
	Language      string
	Font_Size     string
	Contrast_Mode string
	Theme         string
}

type Drug_Database struct {
	gorm.Model
	Id           uint
	Name         string
	Description  string
	Interactions string
	Manufacturer string
	Image_url    string
}
type Logs struct {
	gorm.Model
	Id          uint
	Schedule_Id uint
	Taken_At    time.Time
	Note        string
}

type Medications struct {
	gorm.Model
	Id           uint
	Drug_Info_Id uint
	Name         string
	Photo_url    string
	Type         MedicationType
}
type MedicationType string

const (
	Dose  MedicationType = "Dose"
	Pill  MedicationType = "Pill"
	Drink MedicationType = "Drink"
)

type Admins struct {
	gorm.Model
	Id      uint
	User_Id uint
}

var assets embed.FS

func main() {

	app := NewApp()

	// Create application with options
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

	db.Create(&User{Id: 1, F_Name: "saud", L_Name: "ahmad", UserName: "saud111", Email: "saud@.com", Password: "password123", Gender: "Male", Role: Admin, Created_at: time.Now()})
	db.Create(&User{Id: 2, F_Name: "fahad", L_Name: "farhan", UserName: "fahad111", Email: "fahad@.com", Password: "password123", Gender: "Male", Role: Admin, Created_at: time.Now()})
	db.Create(&User{Id: 3, F_Name: "ahmad", L_Name: "nasser", UserName: "ahmad111", Email: "ahmad@.com", Password: "password123", Gender: "Male", Role: Admin, Created_at: time.Now()})

}
