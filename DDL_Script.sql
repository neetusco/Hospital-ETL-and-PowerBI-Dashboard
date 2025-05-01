-- PATIENT TABLE
CREATE TABLE Patient (
    PatientID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR(10),
    Address VARCHAR(255),
    PhoneNumber VARCHAR(15) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE,
    EmergencyContactName VARCHAR(100),
    EmergencyContactPhone VARCHAR(15)
);

-- DOCTOR TABLE
CREATE TABLE Doctor (
    DoctorID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Specialization VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE,
    DepartmentID INT NOT NULL,
    Availability VARCHAR(50),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

-- DEPARTMENT TABLE
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    Location VARCHAR(10) UNIQUE,
    PhoneExtension VARCHAR(10)
);

-- APPOINTMENT TABLE
CREATE TABLE Appointment (
    AppointmentID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    DepartmentID INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Status VARCHAR(20) CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled')),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

-- MEDICAL RECORDS TABLE
CREATE TABLE MedicalRecord (
    RecordID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    VisitDate DATE NOT NULL,
    Diagnosis VARCHAR(255) NOT NULL,
    TreatmentPlan VARCHAR(255),
    Prescription VARCHAR(255),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);

-- PRESCRIPTION TABLE
CREATE TABLE Prescription (
    PrescriptionID INT PRIMARY KEY,
    RecordID INT NOT NULL,
    MedicineID INT NOT NULL,
    Dosage VARCHAR(50),
    Frequency VARCHAR(50),
    Duration VARCHAR(50),
    FOREIGN KEY (RecordID) REFERENCES MedicalRecord(RecordID),
    FOREIGN KEY (MedicineID) REFERENCES Medicine(MedicineID)
);

-- MEDICINE TABLE
CREATE TABLE Medicine (
    MedicineID INT PRIMARY KEY,
    MedicineName VARCHAR(100) NOT NULL,
    Manufacturer VARCHAR(100),
    StockQuantity INT,
    Price DECIMAL(10, 2)
);

-- BILLING TABLE
CREATE TABLE Billing (
    BillingID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    PaymentStatus VARCHAR(10) CHECK (PaymentStatus IN ('Paid', 'Unpaid')),
    PaymentDate DATE,
    PaymentMethod VARCHAR(50),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
);

-- STAFF TABLE
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Role VARCHAR(50),
    DepartmentID INT,
    PhoneNumber VARCHAR(15) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    ShiftHours VARCHAR(50),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

-- ROOM TABLE
CREATE TABLE Room (
    RoomID INT PRIMARY KEY,
    RoomNumber VARCHAR(10) UNIQUE NOT NULL,
    DepartmentID INT NOT NULL,
    RoomType VARCHAR(50),
    AvailabilityStatus VARCHAR(50),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

-- ROOM ASSIGNMENT TABLE
CREATE TABLE RoomAssignment (
    AssignmentID INT PRIMARY KEY,
    RoomID INT NOT NULL,
    PatientID INT NOT NULL,
    AdmissionDate DATE NOT NULL,
    DischargeDate DATE,
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
);
