-- Patient and Appointment Analysis

--Distribution of appointments by age group and gender
SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) BETWEEN 0 AND 17 THEN '0-17'
        WHEN DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) BETWEEN 18 AND 35 THEN '18-35'
        WHEN DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) BETWEEN 36 AND 50 THEN '36-50'
        WHEN DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) BETWEEN 51 AND 65 THEN '51-65'
        ELSE '66+'
    END AS AgeGroup,
    p.Gender,
    COUNT(a.AppointmentID) AS AppointmentCount
FROM 
    Appointment a
JOIN 
    Patient p ON a.PatientID = p.PatientID
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) BETWEEN 0 AND 17 THEN '0-17'
        WHEN DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) BETWEEN 18 AND 35 THEN '18-35'
        WHEN DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) BETWEEN 36 AND 50 THEN '36-50'
        WHEN DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) BETWEEN 51 AND 65 THEN '51-65'
        ELSE '66+'
    END,
    p.Gender
ORDER BY 
    AgeGroup, p.Gender;

--Average number of appointments per patient in the last 6 months ?? 

	SELECT 
    AVG(AppointmentCount) AS AvgAppointmentsPerPatient
FROM (
    SELECT 
        a.PatientID,
        COUNT(*) AS AppointmentCount
    FROM 
        Appointment a
    WHERE 
        a.AppointmentDate >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY 
        a.PatientID
) AS PatientAppointments;


--Doctor Availability and Workload

-- 1. Doctors with highest patient load vs. working hours

SELECT 
    d.DoctorID,
    d.FirstName,
    d.LastName,
    COUNT(DISTINCT a.PatientID) AS PatientLoad,
    TRY_CAST(LEFT(d.Availability, CHARINDEX(':', d.Availability)-1) AS INT) AS StartHour,
    TRY_CAST(
        SUBSTRING(
            d.Availability,
            CHARINDEX('-', d.Availability) + 2,
            CHARINDEX(':', d.Availability, CHARINDEX('-', d.Availability)) - CHARINDEX('-', d.Availability) - 2
        ) AS INT
    ) AS EndHour,
    TRY_CAST(
        SUBSTRING(
            d.Availability,
            CHARINDEX('-', d.Availability) + 2,
            CHARINDEX(':', d.Availability, CHARINDEX('-', d.Availability)) - CHARINDEX('-', d.Availability) - 2
        ) AS INT
    ) -
    TRY_CAST(LEFT(d.Availability, CHARINDEX(':', d.Availability)-1) AS INT) AS WorkingHours
FROM 
    Doctor d
LEFT JOIN 
    Appointment a ON d.DoctorID = a.DoctorID
WHERE 
    d.Availability LIKE '[0-2][0-9]:%' -- Only include time ranges like '09:00 - 17:00'
GROUP BY 
    d.DoctorID, d.FirstName, d.LastName, d.Availability
ORDER BY 
    PatientLoad DESC;

---Doctors with highest number of completed appointments, by department
SELECT 
    dpt.DepartmentName,
    doc.DoctorID,
    doc.FirstName,
    doc.LastName,
    COUNT(a.AppointmentID) AS CompletedAppointments
FROM 
    Appointment a
JOIN 
    Doctor doc ON a.DoctorID = doc.DoctorID
JOIN 
    Department dpt ON a.DepartmentID = dpt.DepartmentID
WHERE 
    a.Status = 'Completed'
GROUP BY 
    dpt.DepartmentName, doc.DoctorID, doc.FirstName, doc.LastName
HAVING 
    COUNT(a.AppointmentID) > 0
ORDER BY 
    dpt.DepartmentName,
    CompletedAppointments DESC;



--4


WITH DoctorWorkingHours AS (
    SELECT 
        DoctorID,
        TRY_CAST(LEFT(Availability, CHARINDEX(':', Availability) - 1) AS INT) AS StartHour,
        TRY_CAST(
            SUBSTRING(
                Availability,
                CHARINDEX('-', Availability) + 2,
                CHARINDEX(':', Availability, CHARINDEX('-', Availability)) - CHARINDEX('-', Availability) - 2
            ) AS INT
        ) AS EndHour
    FROM Doctor
    WHERE Availability LIKE '[0-2][0-9]:%'
),
DoctorAppointmentsPerDay AS (
    SELECT 
        a.DoctorID,
        a.AppointmentDate,
        COUNT(*) AS AppointmentsOnDay
    FROM Appointment a
    GROUP BY a.DoctorID, a.AppointmentDate
),
OverbookedDoctors AS (
    SELECT 
        d.DoctorID,
        doc.FirstName,
        doc.LastName,
        d.AppointmentDate,
        d.AppointmentsOnDay,
        (w.EndHour - w.StartHour) AS WorkingHours,
        d.AppointmentsOnDay * 1.0 / NULLIF((w.EndHour - w.StartHour), 0) AS AppointmentsPerHour
    FROM DoctorAppointmentsPerDay d
    JOIN DoctorWorkingHours w ON d.DoctorID = w.DoctorID
    JOIN Doctor doc ON doc.DoctorID = d.DoctorID
    WHERE d.AppointmentsOnDay > (w.EndHour - w.StartHour)
)
SELECT * FROM OverbookedDoctors
ORDER BY AppointmentsPerHour DESC;


--Financial Overview

-- 1. Total revenue from different departments
SELECT 
    d.DepartmentName,
    SUM(b.TotalAmount) AS TotalRevenue
FROM 
    Billing b
JOIN 
    Appointment a ON b.PatientID = a.PatientID
JOIN 
    Department d ON a.DepartmentID = d.DepartmentID
WHERE 
    b.PaymentStatus = 'Paid'
GROUP BY 
    d.DepartmentName
ORDER BY 
    TotalRevenue DESC;

--by quaters 
SELECT 
    d.DepartmentName,
    CONCAT('Q', DATEPART(QUARTER, b.PaymentDate), '-', YEAR(b.PaymentDate)) AS Quarter,
    SUM(b.TotalAmount) AS TotalRevenue
FROM 
    Billing b
JOIN 
    Appointment a ON b.PatientID = a.PatientID
JOIN 
    Department d ON a.DepartmentID = d.DepartmentID
WHERE 
    b.PaymentStatus = 'Paid'
    AND b.PaymentDate IS NOT NULL
GROUP BY 
    d.DepartmentName,
    DATEPART(QUARTER, b.PaymentDate),
    YEAR(b.PaymentDate)
ORDER BY 
    d.DepartmentName,
    YEAR(b.PaymentDate),
    DATEPART(QUARTER, b.PaymentDate);

--Percentage of unpaid revenue and departments with highest outstanding
-- Total revenue (paid + unpaid)
WITH RevenueByStatus AS (
    SELECT 
        b.PaymentStatus,
        SUM(b.TotalAmount) AS Amount
    FROM Billing b
    GROUP BY b.PaymentStatus
),
-- Unpaid revenue by department
UnpaidByDepartment AS (
    SELECT 
        d.DepartmentName,
        SUM(b.TotalAmount) AS OutstandingAmount
    FROM 
        Billing b
    JOIN Appointment a ON b.PatientID = a.PatientID
    JOIN Department d ON a.DepartmentID = d.DepartmentID
    WHERE 
        b.PaymentStatus = 'Unpaid'
    GROUP BY 
        d.DepartmentName
)

-- Final result
SELECT 
    -- Total unpaid %
    (SELECT Amount FROM RevenueByStatus WHERE PaymentStatus = 'Unpaid') * 100.0 / 
    NULLIF((SELECT SUM(Amount) FROM RevenueByStatus), 0) AS UnpaidRevenuePercentage,

    -- Department-wise unpaid
    ubd.DepartmentName,
    ubd.OutstandingAmount
FROM 
    UnpaidByDepartment ubd
ORDER BY 
    ubd.OutstandingAmount DESC;

--Average billing amount per patient by department 

SELECT 
    d.DepartmentName,
    COUNT(DISTINCT b.PatientID) AS TotalPatients,
    SUM(b.TotalAmount) AS TotalBilling,
    CAST(SUM(b.TotalAmount) * 1.0 / COUNT(DISTINCT b.PatientID) AS DECIMAL(10, 2)) AS AvgBillingPerPatient
FROM 
    Billing b
JOIN 
    Appointment a ON b.PatientID = a.PatientID
JOIN 
    Department d ON a.DepartmentID = d.DepartmentID
WHERE 
    b.PaymentStatus = 'Paid'  -- Optional: Only consider paid bills
GROUP BY 
    d.DepartmentName
ORDER BY 
    AvgBillingPerPatient DESC;

--Payment methods and status
SELECT 
    PaymentMethod,
    PaymentStatus,
    COUNT(*) AS NumberOfBills,
    SUM(TotalAmount) AS TotalAmount
FROM 
    Billing
GROUP BY 
    PaymentMethod,
    PaymentStatus
ORDER BY 
    PaymentMethod,
    PaymentStatus;


--Top 10 medicine 
SELECT TOP 10 
    m.MedicineName,
    COUNT(p.PrescriptionID) AS PrescriptionCount
FROM 
    Prescription p
JOIN 
    Medicine m ON p.MedicineID = m.MedicineID
GROUP BY 
    m.MedicineName
ORDER BY 
    PrescriptionCount DESC;
--


--Room Utilization

-- 1. Room occupancy % by type
SELECT 
    r.RoomType,
    SUM(DATEDIFF(DAY, ra.AdmissionDate, ISNULL(ra.DischargeDate, GETDATE()))) AS TotalOccupiedDays,
    COUNT(DISTINCT r.RoomID) AS RoomTotal,
    DATEDIFF(DAY, 
             (SELECT MIN(AdmissionDate) FROM RoomAssignment), 
             (SELECT MAX(ISNULL(DischargeDate, GETDATE())) FROM RoomAssignment)
    ) * COUNT(DISTINCT r.RoomID) AS TotalRoomDays,
    CAST(
        SUM(DATEDIFF(DAY, ra.AdmissionDate, ISNULL(ra.DischargeDate, GETDATE()))) * 100.0 / 
        NULLIF(
            DATEDIFF(DAY, 
                     (SELECT MIN(AdmissionDate) FROM RoomAssignment), 
                     (SELECT MAX(ISNULL(DischargeDate, GETDATE())) FROM RoomAssignment)
            ) * COUNT(DISTINCT r.RoomID), 
        0
        ) AS DECIMAL(5, 2)
    ) AS OccupancyPercent
FROM 
    RoomAssignment ra
JOIN 
    Room r ON ra.RoomID = r.RoomID
GROUP BY 
    r.RoomType
ORDER BY 
    OccupancyPercent DESC;

--Average length of stay by room type

SELECT 
    r.RoomType,
    AVG(DATEDIFF(DAY, ra.AdmissionDate, ISNULL(ra.DischargeDate, GETDATE()))) AS AverageLengthOfStay
FROM 
    RoomAssignment ra
JOIN 
    Room r ON ra.RoomID = r.RoomID
GROUP BY 
    r.RoomType
ORDER BY 
    AverageLengthOfStay DESC;

--Departments with highest room demand and average wait time

SELECT 
    d.DepartmentName,
    COUNT(ra.AssignmentID) AS RoomDemand,
    AVG(DATEDIFF(DAY, a.AppointmentDate, ra.AdmissionDate)) AS AvgWaitTimeDays
FROM 
    RoomAssignment ra
JOIN 
    Room r ON ra.RoomID = r.RoomID
JOIN 
    Department d ON r.DepartmentID = d.DepartmentID
JOIN 
    Appointment a ON ra.PatientID = a.PatientID
    AND a.AppointmentDate <= ra.AdmissionDate  -- ensure correct appointment
GROUP BY 
    d.DepartmentName
ORDER BY 
    RoomDemand DESC;

--with room type

SELECT 
    d.DepartmentName,
    r.RoomType,
    COUNT(ra.AssignmentID) AS RoomDemand,
    AVG(DATEDIFF(DAY, a.AppointmentDate, ra.AdmissionDate)) AS AvgWaitTimeDays
FROM 
    RoomAssignment ra
JOIN 
    Room r ON ra.RoomID = r.RoomID
JOIN 
    Department d ON r.DepartmentID = d.DepartmentID
JOIN 
    Appointment a ON ra.PatientID = a.PatientID
    AND a.AppointmentDate <= ra.AdmissionDate
GROUP BY 
    d.DepartmentName, r.RoomType
ORDER BY 
    RoomDemand DESC;

-- Rooms unoccupied for > 5 consecutive days

WITH RoomAssignmentsOrdered AS (
    SELECT 
        ra.RoomID,
        r.RoomNumber,
        r.RoomType,
        ra.AdmissionDate,
        ra.DischargeDate,
        LEAD(ra.AdmissionDate) OVER (PARTITION BY ra.RoomID ORDER BY ra.AdmissionDate) AS NextAdmissionDate
    FROM 
        RoomAssignment ra
    JOIN 
        Room r ON ra.RoomID = r.RoomID
),
UnoccupiedGaps AS (
    SELECT 
        RoomID,
        RoomNumber,
        RoomType,
        DischargeDate,
        NextAdmissionDate,
        DATEDIFF(DAY, DischargeDate, NextAdmissionDate) AS GapDays
    FROM 
        RoomAssignmentsOrdered
    WHERE 
        DischargeDate IS NOT NULL
        AND NextAdmissionDate IS NOT NULL
        AND DATEDIFF(DAY, DischargeDate, NextAdmissionDate) > 5
)
SELECT 
    RoomID,
    RoomNumber,
    RoomType,
    DischargeDate,
    NextAdmissionDate,
    GapDays
FROM 
    UnoccupiedGaps
ORDER BY 
    GapDays DESC;
