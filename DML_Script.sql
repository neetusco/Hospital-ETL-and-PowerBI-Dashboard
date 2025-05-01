--Inseting data from CSV files saved in C drive of local machine
--Appointment Table
BULK INSERT appointment
FROM 'C:\My Files\BISI\Database analytics\data\Appointment.csv'
with (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

--Billing Table
BULK INSERT Billing
FROM 'C:\My Files\BISI\Database analytics\data\Billing.csv'
with (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

--Departments Table
BULK INSERT Department
FROM 'C:\My Files\BISI\Database analytics\data\Departments.csv'
with (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

--Doctors Table
BULK INSERT Doctor
FROM 'C:\My Files\BISI\Database analytics\data\Doctors.csv'
with (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

--Medical Records Table
BULK INSERT MedicalRecord
FROM 'C:\My Files\BISI\Database analytics\data\MedicalRecords.csv'
with (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

--Medicines Table
BULK INSERT Medicine
FROM 'C:\My Files\BISI\Database analytics\data\Medicines.csv'
with (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

--Patients Table
INSERT INTO Patient
SELECT * FROM Hospital_Database_v2.dbo.Patients$;

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Patient';

EXEC sp_help Patient;

ALTER TABLE Patient
ALTER COLUMN PhoneNumber float;

ALTER TABLE Patient
ALTER COLUMN EmergencyContactPhone float;

--Prescriptions Table
BULK INSERT Prescription
FROM 'C:\My Files\BISI\Database analytics\data\Prescriptions.csv'
with (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

--Room Assignments Table
BULK INSERT RoomAssignment
FROM 'C:\My Files\BISI\Database analytics\data\RoomAssignments.csv'
with (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

--Rooms Table
BULK INSERT Room
FROM 'C:\My Files\BISI\Database analytics\data\Rooms.csv'
with (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

--Staff Table
BULK INSERT Staff
FROM 'C:\My Files\BISI\Database analytics\data\Staff.csv'
with (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);