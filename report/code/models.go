type User struct {
    gorm.Model
    FirstName string
    LastName  string
    UserName  string
    Email     string `gorm:"uniqueIndex"`
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

type Schedule struct {
    gorm.Model
    PatientId    uint
    MedicationId uint
    StartDate    time.Time
    EndDate      time.Time
    StartHour    time.Time
    Frequency    uint `gorm:"column:interval_hours"`
    Instructions string
    Dosage       string
    Quantity     uint
}

type Medication struct {
    gorm.Model
    DrugInfoId uint
    Name       string
    PhotoUrl   string
    Type       MedicationType
}

type Log struct {
    gorm.Model
    ScheduleId    uint
    ScheduledAtMs int64 // Unix ms timestamp of the planned dose time
    TakenAt       *time.Time
    Note          string
}
