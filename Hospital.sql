-- =====================================================
-- HOSPITAL DATABASE SCHEMA
-- Normalization: 3NF | Soft Deletes | Audit Trails
-- =====================================================
show databases; 
create database hospital;
use hospital;
-- Drop tables if exist (in reverse order of dependencies)
-- Executar aixo nomes si voleu reiniciar la database per si dona algun errorallergies
DROP TABLE IF EXISTS SURGICAL_MATERIAL_USAGE;
DROP TABLE IF EXISTS SURGICAL_PROCEDURE_MEDICATIONS;
DROP TABLE IF EXISTS SURGICAL_PROCEDURE_ANESTHESIOLOGISTS;
DROP TABLE IF EXISTS SURGICAL_PROCEDURE_SURGEONS;
DROP TABLE IF EXISTS SURGICAL_PROCEDURE_NURSES;
DROP TABLE IF EXISTS APPOINTMENT_SURGICAL_PROCEDURE;
DROP TABLE IF EXISTS ROLE_PERMISSIONS;
DROP TABLE IF EXISTS PERMISSIONS;
DROP TABLE IF EXISTS PATIENT_CONSENTS;
DROP TABLE IF EXISTS PATIENT_ALLERGIES;
DROP TABLE IF EXISTS AUDIT_LOG;
DROP TABLE IF EXISTS BEDS;
DROP TABLE IF EXISTS WARD;
DROP TABLE IF EXISTS SURGICAL_INVENTORY;
DROP TABLE IF EXISTS SURGICAL_MATERIAL;
DROP TABLE IF EXISTS SURGERY_MONITORING;
DROP TABLE IF EXISTS MEDICATIONS;
DROP TABLE IF EXISTS LAB_RESULTS;
DROP TABLE IF EXISTS LAB_TESTS;
DROP TABLE IF EXISTS IMAGING_STUDIES;
DROP TABLE IF EXISTS ANESTHESIOLOGISTS;
DROP TABLE IF EXISTS SURGEONS;
DROP TABLE IF EXISTS NURSES;
DROP TABLE IF EXISTS OPERATING_ROOM;
DROP TABLE IF EXISTS APPOINTMENTS;
DROP TABLE IF EXISTS SURGICAL_PROCEDURE;
DROP TABLE IF EXISTS PROCEDURES;
DROP TABLE IF EXISTS ALLERGIES;
DROP TABLE IF EXISTS PATIENT;
DROP TABLE IF EXISTS USERS;
DROP TABLE IF EXISTS ROLES;

-- =====================================================
-- STRONG ENTITIES
-- =====================================================

-- Roles Table
CREATE TABLE ROLES (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Users Table
CREATE TABLE USERS (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    pass VARCHAR(255) NOT NULL, -- Encrypted (bcrypt/argon2)
    email VARCHAR(100) NOT NULL UNIQUE,
    role_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (role_id) REFERENCES ROLES(role_id),
    INDEX idx_role_id (role_id),
    INDEX idx_email (email),
    INDEX idx_deleted_at (deleted_at)
);

-- Patient Table (EHR = Electronic Health Record)
CREATE TABLE PATIENT (
    EHR VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    surnames VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('M', 'F', 'Other') NOT NULL,
    address VARCHAR(255), -- Encrypted
    phone VARCHAR(20), -- Encrypted
    email VARCHAR(100), -- Encrypted
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_name (first_name),
    INDEX idx_surnames (surnames),
    INDEX idx_date_of_birth (date_of_birth),
    INDEX idx_deleted_at (deleted_at)
);

-- Allergies Table
CREATE TABLE ALLERGIES (
    allergy_id INT AUTO_INCREMENT PRIMARY KEY,
    allergy_name VARCHAR(100) NOT NULL,
    allergen_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_allergy_name (allergy_name),
    INDEX idx_deleted_at (deleted_at)
);

-- Procedure Table
CREATE TABLE PROCEDURES (
    procedure_id INT AUTO_INCREMENT PRIMARY KEY,
    procedure_name VARCHAR(200) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_procedure_name (procedure_name),
    INDEX idx_deleted_at (deleted_at)
);

-- Ward Table
CREATE TABLE WARD (
    ward_id INT AUTO_INCREMENT PRIMARY KEY,
    ward_name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_ward_name (ward_name),
    INDEX idx_deleted_at (deleted_at)
);

-- Operating Room Table
CREATE TABLE OPERATING_ROOM (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL UNIQUE,
    room_type VARCHAR(50),
    availability_status ENUM('Available', 'Occupied', 'Maintenance', 'Reserved') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_room_number (room_number),
    INDEX idx_availability_status (availability_status),
    INDEX idx_deleted_at (deleted_at)
);

-- Surgical Procedure Table
CREATE TABLE SURGICAL_PROCEDURE (
    surgical_procedure_id INT AUTO_INCREMENT PRIMARY KEY,
    procedure_id INT NOT NULL,
    date_time DATETIME NOT NULL,
    duration INT, -- Duration in minutes
    status ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled', 'Postponed') DEFAULT 'Scheduled',
    notes TEXT,
    operating_room_id INT,
    ward_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (procedure_id) REFERENCES PROCEDURES(procedure_id),
    FOREIGN KEY (operating_room_id) REFERENCES OPERATING_ROOM(room_id),
    FOREIGN KEY (ward_id) REFERENCES WARD(ward_id),
    INDEX idx_procedure_id (procedure_id),
    INDEX idx_date_time (date_time),
    INDEX idx_status (status),
    INDEX idx_operating_room_id (operating_room_id),
    INDEX idx_ward_id (ward_id),
    INDEX idx_deleted_at (deleted_at)
);

-- Appointments Table
CREATE TABLE APPOINTMENTS (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    EHR VARCHAR(50) NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status ENUM('Scheduled', 'Confirmed', 'Completed', 'Cancelled', 'No-show') DEFAULT 'Scheduled',
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (EHR) REFERENCES PATIENT(EHR),
    INDEX idx_ehr (EHR),
    INDEX idx_appointment_date (appointment_date),
    INDEX idx_status (status),
    INDEX idx_deleted_at (deleted_at)
);

-- Nurses Table
CREATE TABLE NURSES (
    nurse_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    surnames VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    specialization VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_license_number (license_number),
    INDEX idx_name (first_name),
    INDEX idx_deleted_at (deleted_at)
);

-- Surgeons Table
CREATE TABLE SURGEONS (
    surgeon_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    surnames VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    specialization VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_license_number (license_number),
    INDEX idx_name (first_name),
    INDEX idx_deleted_at (deleted_at)
);

-- Anesthesiologists Table
CREATE TABLE ANESTHESIOLOGISTS (
    anesthesiologist_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    surnames VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    specialization VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_license_number (license_number),
    INDEX idx_name (first_name),
    INDEX idx_deleted_at (deleted_at)
);

-- Imaging Studies Table
CREATE TABLE IMAGING_STUDIES (
    imaging_id INT AUTO_INCREMENT PRIMARY KEY,
    surgical_procedure_id INT NOT NULL,
    study_type VARCHAR(100) NOT NULL,
    study_date DATETIME NOT NULL,
    results TEXT,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (surgical_procedure_id) REFERENCES SURGICAL_PROCEDURE(surgical_procedure_id),
    INDEX idx_surgical_procedure_id (surgical_procedure_id),
    INDEX idx_study_date (study_date),
    INDEX idx_deleted_at (deleted_at)
);

-- Lab Tests Table
CREATE TABLE LAB_TESTS (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    surgical_procedure_id INT NOT NULL,
    test_name VARCHAR(200) NOT NULL,
    test_date DATETIME NOT NULL,
    ordered_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (surgical_procedure_id) REFERENCES SURGICAL_PROCEDURE(surgical_procedure_id),
    INDEX idx_surgical_procedure_id (surgical_procedure_id),
    INDEX idx_test_date (test_date),
    INDEX idx_deleted_at (deleted_at)
);

-- Lab Results Table
CREATE TABLE LAB_RESULTS (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    test_id INT NOT NULL,
    surgical_procedure_id INT NOT NULL,
    result_value VARCHAR(200),
    result_date DATETIME NOT NULL,
    normal_range VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (test_id) REFERENCES LAB_TESTS(test_id),
    FOREIGN KEY (surgical_procedure_id) REFERENCES SURGICAL_PROCEDURE(surgical_procedure_id),
    INDEX idx_test_id (test_id),
    INDEX idx_surgical_procedure_id (surgical_procedure_id),
    INDEX idx_result_date (result_date),
    INDEX idx_deleted_at (deleted_at)
);

-- Medications Table
CREATE TABLE MEDICATIONS (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    medication_name VARCHAR(200) NOT NULL,
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    route VARCHAR(50), -- Oral, IV, IM, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_medication_name (medication_name),
    INDEX idx_deleted_at (deleted_at)
);

-- Surgery Monitoring Table
CREATE TABLE SURGERY_MONITORING (
    monitoring_id INT AUTO_INCREMENT PRIMARY KEY,
    surgical_procedure_id INT NOT NULL,
    vital_signs JSON, -- Stores BP, HR, O2, Temp, etc.
    timestamp DATETIME NOT NULL,
    observations TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (surgical_procedure_id) REFERENCES SURGICAL_PROCEDURE(surgical_procedure_id),
    INDEX idx_surgical_procedure_id (surgical_procedure_id),
    INDEX idx_timestamp (timestamp),
    INDEX idx_deleted_at (deleted_at)
);

-- Surgical Material Table
CREATE TABLE SURGICAL_MATERIAL (
    material_id INT AUTO_INCREMENT PRIMARY KEY,
    material_name VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_material_name (material_name),
    INDEX idx_deleted_at (deleted_at)
);

-- Surgical Inventory Table
CREATE TABLE SURGICAL_INVENTORY (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    material_id INT NOT NULL,
    location VARCHAR(100),
    quantity_available INT NOT NULL DEFAULT 0,
    supplier VARCHAR(200),
    minimum_stock INT DEFAULT 0,
    maximum_stock INT DEFAULT 1000,
    expiration_date DATE,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (material_id) REFERENCES SURGICAL_MATERIAL(material_id),
    INDEX idx_material_id (material_id),
    INDEX idx_location (location),
    INDEX idx_expiration_date (expiration_date),
    INDEX idx_deleted_at (deleted_at)
);

-- Beds Table
CREATE TABLE BEDS (
    bed_id INT AUTO_INCREMENT PRIMARY KEY,
    ward_id INT NOT NULL,
    bed_status ENUM('Available', 'Occupied', 'Maintenance', 'Reserved') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (ward_id) REFERENCES WARD(ward_id),
    INDEX idx_ward_id (ward_id),
    INDEX idx_bed_status (bed_status),
    INDEX idx_deleted_at (deleted_at)
);

-- Permissions Table
CREATE TABLE PERMISSIONS (
    permission_id INT AUTO_INCREMENT PRIMARY KEY,
    resource VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,
    scope VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_resource (resource),
    INDEX idx_action (action),
    INDEX idx_deleted_at (deleted_at)
);

-- Audit Log Table
CREATE TABLE AUDIT_LOG (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    table_affected VARCHAR(100),
    record_id VARCHAR(50),
    details JSON, -- Stores before/after values
    FOREIGN KEY (user_id) REFERENCES USERS(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_timestamp (timestamp),
    INDEX idx_table_affected (table_affected),
    INDEX idx_record_id (record_id)
);

-- =====================================================
-- RELATIONSHIP TABLES (Many-to-Many)
-- =====================================================

-- Patient Allergies (Many-to-Many)
CREATE TABLE PATIENT_ALLERGIES (
    EHR VARCHAR(50) NOT NULL,
    allergy_id INT NOT NULL,
    diagnosed_date DATE,
    severity ENUM('Mild', 'Moderate', 'Severe', 'Life-threatening') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    PRIMARY KEY (EHR, allergy_id),
    FOREIGN KEY (EHR) REFERENCES PATIENT(EHR),
    FOREIGN KEY (allergy_id) REFERENCES ALLERGIES(allergy_id),
    INDEX idx_ehr (EHR),
    INDEX idx_allergy_id (allergy_id),
    INDEX idx_deleted_at (deleted_at)
);

-- Patient Consents
CREATE TABLE PATIENT_CONSENTS (
    consent_id INT AUTO_INCREMENT PRIMARY KEY,
    EHR VARCHAR(50) NOT NULL,
    procedure_id INT NOT NULL,
    consent_date DATE NOT NULL,
    consent_type VARCHAR(100),
    signed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (EHR) REFERENCES PATIENT(EHR),
    FOREIGN KEY (procedure_id) REFERENCES PROCEDURES(procedure_id),
    INDEX idx_ehr (EHR),
    INDEX idx_procedure_id (procedure_id),
    INDEX idx_consent_date (consent_date),
    INDEX idx_deleted_at (deleted_at)
);

-- Role Permissions (Many-to-Many)
CREATE TABLE ROLE_PERMISSIONS (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES ROLES(role_id),
    FOREIGN KEY (permission_id) REFERENCES PERMISSIONS(permission_id),
    INDEX idx_role_id (role_id),
    INDEX idx_permission_id (permission_id),
    INDEX idx_deleted_at (deleted_at)
);

-- Appointment Surgical Procedure (Many-to-Many)
CREATE TABLE APPOINTMENT_SURGICAL_PROCEDURE (
    appointment_id INT NOT NULL,
    surgical_procedure_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    PRIMARY KEY (appointment_id, surgical_procedure_id),
    FOREIGN KEY (appointment_id) REFERENCES APPOINTMENTS(appointment_id),
    FOREIGN KEY (surgical_procedure_id) REFERENCES SURGICAL_PROCEDURE(surgical_procedure_id),
    INDEX idx_appointment_id (appointment_id),
    INDEX idx_surgical_procedure_id (surgical_procedure_id),
    INDEX idx_deleted_at (deleted_at)
);

-- Surgical Procedure Nurses (Many-to-Many)
CREATE TABLE SURGICAL_PROCEDURE_NURSES (
    surgical_procedure_id INT NOT NULL,
    nurse_id INT NOT NULL,
    role_in_surgery VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    PRIMARY KEY (surgical_procedure_id, nurse_id),
    FOREIGN KEY (surgical_procedure_id) REFERENCES SURGICAL_PROCEDURE(surgical_procedure_id),
    FOREIGN KEY (nurse_id) REFERENCES NURSES(nurse_id),
    INDEX idx_surgical_procedure_id (surgical_procedure_id),
    INDEX idx_nurse_id (nurse_id),
    INDEX idx_deleted_at (deleted_at)
);

-- Surgical Procedure Surgeons (Many-to-Many)
CREATE TABLE SURGICAL_PROCEDURE_SURGEONS (
    surgical_procedure_id INT NOT NULL,
    surgeon_id INT NOT NULL,
    role_in_surgery VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    PRIMARY KEY (surgical_procedure_id, surgeon_id),
    FOREIGN KEY (surgical_procedure_id) REFERENCES SURGICAL_PROCEDURE(surgical_procedure_id),
    FOREIGN KEY (surgeon_id) REFERENCES SURGEONS(surgeon_id),
    INDEX idx_surgical_procedure_id (surgical_procedure_id),
    INDEX idx_surgeon_id (surgeon_id),
    INDEX idx_deleted_at (deleted_at)
);

-- Surgical Procedure Anesthesiologists (Many-to-Many)
CREATE TABLE SURGICAL_PROCEDURE_ANESTHESIOLOGISTS (
    surgical_procedure_id INT NOT NULL,
    anesthesiologist_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    PRIMARY KEY (surgical_procedure_id, anesthesiologist_id),
    FOREIGN KEY (surgical_procedure_id) REFERENCES SURGICAL_PROCEDURE(surgical_procedure_id),
    FOREIGN KEY (anesthesiologist_id) REFERENCES ANESTHESIOLOGISTS(anesthesiologist_id),
    INDEX idx_surgical_procedure_id (surgical_procedure_id),
    INDEX idx_anesthesiologist_id (anesthesiologist_id),
    INDEX idx_deleted_at (deleted_at)
);

-- Surgical Procedure Medications (Many-to-Many)
CREATE TABLE SURGICAL_PROCEDURE_MEDICATIONS (
    surgical_procedure_id INT NOT NULL,
    medication_id INT NOT NULL,
    prescribed_datetime DATETIME NOT NULL,
    prescribed_by VARCHAR(100),
    dosage VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    PRIMARY KEY (surgical_procedure_id, medication_id, prescribed_datetime),
    FOREIGN KEY (surgical_procedure_id) REFERENCES SURGICAL_PROCEDURE(surgical_procedure_id),
    FOREIGN KEY (medication_id) REFERENCES MEDICATIONS(medication_id),
    INDEX idx_surgical_procedure_id (surgical_procedure_id),
    INDEX idx_medication_id (medication_id),
    INDEX idx_prescribed_datetime (prescribed_datetime),
    INDEX idx_deleted_at (deleted_at)
);

-- Surgical Material Usage (Many-to-Many)
CREATE TABLE SURGICAL_MATERIAL_USAGE (
    surgical_procedure_id INT NOT NULL,
    material_id INT NOT NULL,
    amount_used INT NOT NULL,
    usage_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    PRIMARY KEY (surgical_procedure_id, material_id),
    FOREIGN KEY (surgical_procedure_id) REFERENCES SURGICAL_PROCEDURE(surgical_procedure_id),
    FOREIGN KEY (material_id) REFERENCES SURGICAL_MATERIAL(material_id),
    INDEX idx_surgical_procedure_id (surgical_procedure_id),
    INDEX idx_material_id (material_id),
    INDEX idx_deleted_at (deleted_at)
);

-- =====================================================
-- AUDIT TRIGGERS (Example for PATIENT table)
-- =====================================================

DELIMITER //

CREATE TRIGGER audit_patient_insert
AFTER INSERT ON PATIENT
FOR EACH ROW
BEGIN
    INSERT INTO AUDIT_LOG (user_id, action, table_affected, record_id, details)
    VALUES (
        @current_user_id,
        'INSERT',
        'PATIENT',
        NEW.EHR,
        JSON_OBJECT('new_data', JSON_OBJECT(
            'EHR', NEW.EHR,
            'name', NEW.first_name,
            'surnames', NEW.surnames,
            'date_of_birth', NEW.date_of_birth,
            'gender', NEW.gender
        ))
    );
END//

CREATE TRIGGER audit_patient_update
AFTER UPDATE ON PATIENT
FOR EACH ROW
BEGIN
    INSERT INTO AUDIT_LOG (user_id, action, table_affected, record_id, details)
    VALUES (
        @current_user_id,
        'UPDATE',
        'PATIENT',
        NEW.EHR,
        JSON_OBJECT(
            'old_data', JSON_OBJECT(
                'name', OLD.first_name,
                'surnames', OLD.surnames,
                'address', OLD.address,
                'phone', OLD.phone,
                'email', OLD.email
            ),
            'new_data', JSON_OBJECT(
                'name', NEW.first_name,
                'surnames', NEW.surnames,
                'address', NEW.address,
                'phone', NEW.phone,
                'email', NEW.email
            )
        )
    );
END//

CREATE TRIGGER audit_patient_delete
BEFORE UPDATE ON PATIENT
FOR EACH ROW
BEGIN
    IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
        INSERT INTO AUDIT_LOG (user_id, action, table_affected, record_id, details)
        VALUES (
            @current_user_id,
            'SOFT_DELETE',
            'PATIENT',
            OLD.EHR,
            JSON_OBJECT('deleted_data', JSON_OBJECT(
                'EHR', OLD.EHR,
                'name', OLD.first_name,
                'surnames', OLD.surnames
            ))
        );
    END IF;
END//

DELIMITER ;

-- =====================================================
-- SAMPLE DATA (Optional)
-- =====================================================

-- Insert sample roles
INSERT INTO ROLES (role_name, description) VALUES
('Administrator', 'Full system access'),
('Doctor', 'Medical staff with patient access'),
('Nurse', 'Nursing staff with limited access'),
('Receptionist', 'Front desk and appointment management');

-- =====================================================
-- HOSPITAL DATABASE - FAKE DATA INSERTION SCRIPT
-- =====================================================

-- Set the current user for audit logs
SET @current_user_id = 18;

-- =====================================================
-- 1. ROLES
-- =====================================================
INSERT INTO ROLES (role_name, description) VALUES
('Administrative Staff', 'Front desk, scheduling, and administrative support'),
('Director', 'Department heads and executive management');

-- =====================================================
-- 2. USERS
-- =====================================================
INSERT INTO USERS (username, pass, email, role_id) VALUES
-- Administrators
('admin_sarah', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', 'sarah.admin@hospital.com', 1),
-- Physicians
('dr_martinez', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', 'j.martinez@hospital.com', 2),
('dr_chen', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', 'l.chen@hospital.com', 2),
('dr_patel', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', 'r.patel@hospital.com', 2),
-- Nurses
('nurse_emily', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', 'e.rodriguez@hospital.com', 3),
('nurse_james', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', 'j.wilson@hospital.com', 3),
-- Administrative
('admin_kate', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', 'k.brown@hospital.com', 4),
('admin_michael', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', 'm.davis@hospital.com', 4),
-- Directors
('dir_anderson', '$2y$10$abcdefghijklmnopqrstuvwxyz123456', 'r.anderson@hospital.com', 6);

-- =====================================================
-- 3. PATIENTS
-- =====================================================

INSERT INTO PATIENT (EHR, first_name, surnames, date_of_birth, gender, address, phone, email) VALUES
('EHR001', 'John', 'Smith', '1985-03-15', 'M', '123 Main St, Barcelona', '+34612345001', 'john.smith@email.com'),
('EHR002', 'Maria', 'Garcia Lopez', '1990-07-22', 'F', '456 Park Ave, Barcelona', '+34612345002', 'maria.garcia@email.com'),
('EHR003', 'Robert', 'Johnson', '1978-11-30', 'M', '789 Ocean Blvd, Barcelona', '+34612345003', 'robert.j@email.com'),
('EHR004', 'Emma', 'Williams Brown', '1995-05-10', 'F', '321 Beach Rd, Barcelona', '+34612345004', 'emma.wb@email.com'),
('EHR005', 'Carlos', 'Rodriguez Fernandez', '1982-09-18', 'M', '654 Mountain View, Barcelona', '+34612345005', 'carlos.rf@email.com'),
('EHR006', 'Sofia', 'Martinez Sanchez', '1988-12-05', 'F', '987 Valley Lane, Barcelona', '+34612345006', 'sofia.ms@email.com'),
('EHR007', 'David', 'Lee', '1975-02-28', 'M', '147 River St, Barcelona', '+34612345007', 'david.lee@email.com'),
('EHR008', 'Anna', 'Petrov', '1992-08-14', 'F', '258 Lake Dr, Barcelona', '+34612345008', 'anna.petrov@email.com'),
('EHR009', 'Michael', 'O\'Connor', '1980-04-20', 'M', '369 Forest Ave, Barcelona', '+34612345009', 'michael.oc@email.com'),
('EHR010', 'Laura', 'Gonzalez Torres', '1987-10-12', 'F', '741 Garden Blvd, Barcelona', '+34612345010', 'laura.gt@email.com');

-- =====================================================
-- 4. ALLERGIES
-- =====================================================
INSERT INTO ALLERGIES (allergy_name, allergen_type) VALUES
('Penicillin', 'Medication'),
('Latex', 'Material'),
('Peanuts', 'Food'),
('Dust Mites', 'Environmental'),
('Ibuprofen', 'Medication'),
('Shellfish', 'Food'),
('Bee Venom', 'Insect'),
('Aspirin', 'Medication'),
('Pollen', 'Environmental'),
('Eggs', 'Food');

-- =====================================================
-- 5. PATIENT_ALLERGIES
-- =====================================================
INSERT INTO PATIENT_ALLERGIES (EHR, allergy_id, diagnosed_date) VALUES
('EHR001', 1, '2010-05-15'),  -- John has Penicillin allergy
('EHR001', 4, '2015-03-20'),  -- John has Dust Mites allergy
('EHR002', 3, '2005-09-10'),  -- Maria has Peanuts allergy
('EHR003', 2, '2012-11-22'),  -- Robert has Latex allergy
('EHR004', 6, '2018-07-18'),  -- Emma has Shellfish allergy
('EHR005', 5, '2016-02-14'),  -- Carlos has Ibuprofen allergy
('EHR007', 7, '2008-06-30'),  -- David has Bee Venom allergy
('EHR008', 9, '2019-04-25'),  -- Anna has Pollen allergy
('EHR009', 8, '2013-12-10');  -- Michael has Aspirin allergy

-- =====================================================
-- 6. PROCEDURES
-- =====================================================
INSERT INTO PROCEDURES (procedure_name, description) VALUES
('Appendectomy', 'Surgical removal of the appendix'),
('Knee Arthroscopy', 'Minimally invasive knee joint surgery'),
('Cataract Surgery', 'Removal of clouded lens from the eye'),
('Hernia Repair', 'Surgical correction of abdominal hernia'),
('Gallbladder Removal', 'Laparoscopic cholecystectomy'),
('Hip Replacement', 'Total hip arthroplasty'),
('Colonoscopy', 'Endoscopic examination of the colon'),
('Cardiac Catheterization', 'Heart vessel examination and treatment'),
('Thyroidectomy', 'Surgical removal of thyroid gland'),
('Tonsillectomy', 'Surgical removal of tonsils');

-- =====================================================
-- 7. WARDS
-- =====================================================
INSERT INTO WARD (ward_name, capacity) VALUES
('Surgical Ward A', 20),
('Surgical Ward B', 18),
('Recovery Ward', 15),
('ICU', 12),
('Pediatric Ward', 16),
('Cardiology Ward', 14),
('Orthopedic Ward', 20),
('General Medicine', 25);

-- =====================================================
-- 8. BEDS
-- =====================================================
INSERT INTO BEDS (ward_id, bed_status) VALUES
-- Surgical Ward A (20 beds)
(1, 'Occupied'), (1, 'Occupied'), (1, 'Available'), (1, 'Available'), (1, 'Occupied'),
(1, 'Available'), (1, 'Occupied'), (1, 'Available'), (1, 'Occupied'), (1, 'Available'),
(1, 'Available'), (1, 'Reserved'), (1, 'Occupied'), (1, 'Available'), (1, 'Occupied'),
(1, 'Available'), (1, 'Available'), (1, 'Occupied'), (1, 'Available'), (1, 'Maintenance'),
-- Surgical Ward B (18 beds)
(2, 'Occupied'), (2, 'Available'), (2, 'Occupied'), (2, 'Available'), (2, 'Occupied'),
(2, 'Available'), (2, 'Occupied'), (2, 'Available'), (2, 'Reserved'), (2, 'Occupied'),
(2, 'Available'), (2, 'Occupied'), (2, 'Available'), (2, 'Available'), (2, 'Occupied'),
(2, 'Available'), (2, 'Maintenance'), (2, 'Available'),
-- ICU (12 beds)
(4, 'Occupied'), (4, 'Occupied'), (4, 'Occupied'), (4, 'Available'), (4, 'Occupied'),
(4, 'Occupied'), (4, 'Available'), (4, 'Occupied'), (4, 'Reserved'), (4, 'Occupied'),
(4, 'Available'), (4, 'Occupied');

-- =====================================================
-- 9. OPERATING ROOMS
-- =====================================================
INSERT INTO OPERATING_ROOM (room_number, room_type, availability_status) VALUES
('OR-101', 'General Surgery', 'Available'),
('OR-102', 'Orthopedic Surgery', 'Occupied'),
('OR-103', 'Cardiac Surgery', 'Available'),
('OR-104', 'Neurosurgery', 'Maintenance'),
('OR-105', 'General Surgery', 'Reserved'),
('OR-106', 'Laparoscopic Suite', 'Available');

-- =====================================================
-- 10. SURGEONS
-- =====================================================
INSERT INTO SURGEONS (first_name, surnames, license_number, specialization, phone) VALUES
('James', 'Martinez Rodriguez', 'SRG-2015-001', 'General Surgery', '+34600111001'),
('Linda', 'Chen Wang', 'SRG-2016-002', 'Orthopedic Surgery', '+34600111002'),
('Rajesh', 'Patel Kumar', 'SRG-2014-003', 'Cardiac Surgery', '+34600111003'),
('Elena', 'Ivanova Petrova', 'SRG-2017-004', 'Neurosurgery', '+34600111004'),
('Antonio', 'Garcia Lopez', 'SRG-2013-005', 'General Surgery', '+34600111005'),
('Sarah', 'Thompson White', 'SRG-2018-006', 'Laparoscopic Surgery', '+34600111006');

-- =====================================================
-- 11. NURSES
-- =====================================================
INSERT INTO NURSES (first_name, surnames, license_number, specialization, phone) VALUES
('Emily', 'Rodriguez Smith', 'NRS-2018-001', 'Surgical Nursing', '+34600222001'),
('James', 'Wilson Brown', 'NRS-2019-002', 'Perioperative Nursing', '+34600222002'),
('Maria', 'Fernandez Torres', 'NRS-2017-003', 'Critical Care', '+34600222003'),
('David', 'Anderson Lee', 'NRS-2020-004', 'Surgical Nursing', '+34600222004'),
('Ana', 'Sanchez Ruiz', 'NRS-2016-005', 'Anesthesia Nursing', '+34600222005'),
('Thomas', 'Clark Johnson', 'NRS-2019-006', 'Recovery Room', '+34600222006'),
('Laura', 'Martinez Diaz', 'NRS-2018-007', 'Surgical Nursing', '+34600222007'),
('Robert', 'Taylor Moore', 'NRS-2021-008', 'Perioperative Nursing', '+34600222008');

-- =====================================================
-- 12. ANESTHESIOLOGISTS
-- =====================================================
INSERT INTO ANESTHESIOLOGISTS (first_name, surnames, license_number, specialization, phone) VALUES
('Michael', 'Anderson Davis', 'ANS-2015-001', 'General Anesthesia', '+34600333001'),
('Jennifer', 'Thompson Harris', 'ANS-2016-002', 'Cardiac Anesthesia', '+34600333002'),
('Carlos', 'Rodriguez Martinez', 'ANS-2014-003', 'Regional Anesthesia', '+34600333003'),
('Patricia', 'Wilson Clark', 'ANS-2017-004', 'Pediatric Anesthesia', '+34600333004');

-- =====================================================
-- 13. MEDICATIONS
-- =====================================================
INSERT INTO MEDICATIONS (medication_name, dosage, frequency, route) VALUES
('Morphine Sulfate', '10mg', 'Every 4 hours', 'IV'),
('Fentanyl', '50mcg', 'As needed', 'IV'),
('Propofol', '200mg', 'Continuous infusion', 'IV'),
('Cefazolin', '1g', 'Every 8 hours', 'IV'),
('Ondansetron', '4mg', 'Every 6 hours', 'IV'),
('Ketorolac', '30mg', 'Every 6 hours', 'IV'),
('Midazolam', '2mg', 'Pre-operative', 'IV'),
('Vancomycin', '1g', 'Every 12 hours', 'IV'),
('Heparin', '5000 units', 'Twice daily', 'SC'),
('Acetaminophen', '650mg', 'Every 6 hours', 'PO');

-- =====================================================
-- 14. SURGICAL MATERIAL
-- =====================================================
INSERT INTO SURGICAL_MATERIAL (material_name) VALUES
('Sterile Surgical Gloves Size 7'),
('Sterile Surgical Gloves Size 8'),
('Suture Silk 3-0'),
('Suture Vicryl 2-0'),
('Surgical Masks N95'),
('Surgical Drapes Large'),
('Scalpel Blades #15'),
('Gauze Pads 4x4'),
('Surgical Staples'),
('Endotracheal Tubes 7.5mm'),
('IV Catheters 18G'),
('Surgical Sponges'),
('Bone Cement'),
('Surgical Mesh'),
('Drainage Tubes');

-- =====================================================
-- 15. SURGICAL INVENTORY
-- =====================================================
INSERT INTO SURGICAL_INVENTORY (material_id, location, quantity_available, supplier, minimum_stock, maximum_stock, expiration_date) VALUES
(1, 'OR Storage Room A', 500, 'MedSupply Corp', 100, 1000, '2026-12-31'),
(2, 'OR Storage Room A', 450, 'MedSupply Corp', 100, 1000, '2026-12-31'),
(3, 'OR Storage Room B', 200, 'SurgTech Inc', 50, 500, '2027-06-30'),
(4, 'OR Storage Room B', 180, 'SurgTech Inc', 50, 500, '2027-06-30'),
(5, 'Central Supply', 1000, 'SafeMed Ltd', 200, 2000, '2025-12-31'),
(6, 'OR Storage Room A', 150, 'MedSupply Corp', 30, 300, '2028-03-31'),
(7, 'OR Storage Room B', 300, 'BladeWorks', 50, 500, '2026-09-30'),
(8, 'Central Supply', 2000, 'MedSupply Corp', 500, 5000, '2027-12-31'),
(9, 'OR Storage Room B', 100, 'SurgTech Inc', 20, 200, '2028-01-31'),
(10, 'Anesthesia Supply', 80, 'AirwayPro', 20, 150, '2026-08-31'),
(11, 'Central Supply', 500, 'IVTech Solutions', 100, 1000, '2026-11-30'),
(12, 'OR Storage Room A', 800, 'MedSupply Corp', 200, 1500, '2027-10-31'),
(13, 'OR Storage Room C', 50, 'OrthoPro Systems', 10, 100, '2029-12-31'),
(14, 'OR Storage Room C', 30, 'SurgTech Inc', 5, 50, '2028-06-30'),
(15, 'OR Storage Room B', 120, 'DrainageTech', 30, 200, '2027-03-31');

-- =====================================================
-- 16. APPOINTMENTS
-- =====================================================
INSERT INTO APPOINTMENTS (EHR, appointment_date, appointment_time, status, reason) VALUES
('EHR001', '2024-11-25', '09:00:00', 'Confirmed', 'Pre-operative consultation for appendectomy'),
('EHR002', '2024-11-26', '10:30:00', 'Scheduled', 'Follow-up knee arthroscopy'),
('EHR003', '2024-11-27', '11:00:00', 'Confirmed', 'Cataract surgery evaluation'),
('EHR004', '2024-11-28', '14:00:00', 'Scheduled', 'Hernia repair consultation'),
('EHR005', '2024-11-29', '15:30:00', 'Confirmed', 'Gallbladder removal pre-op'),
('EHR006', '2024-12-02', '09:30:00', 'Scheduled', 'Hip replacement consultation'),
('EHR007', '2024-11-22', '10:00:00', 'Completed', 'Post-operative check-up'),
('EHR008', '2024-11-20', '13:00:00', 'Completed', 'Colonoscopy preparation'),
('EHR009', '2024-11-18', '08:30:00', 'No-show', 'Cardiac catheterization consultation'),
('EHR010', '2024-11-15', '16:00:00', 'Cancelled', 'Thyroidectomy evaluation');

-- =====================================================
-- 17. SURGICAL PROCEDURES
-- =====================================================
INSERT INTO SURGICAL_PROCEDURE (procedure_id, date_time, duration, status, notes, operating_room_id, ward_id) VALUES
(1, '2024-11-26 10:00:00', 90, 'Scheduled', 'Patient fasted, no complications expected', 1, 1),
(2, '2024-11-27 14:00:00', 120, 'Scheduled', 'Left knee arthroscopy, previous injury', 2, 7),
(3, '2024-11-28 09:00:00', 60, 'Scheduled', 'Right eye cataract, routine procedure', 1, 1),
(4, '2024-11-22 11:00:00', 150, 'Completed', 'Inguinal hernia repair, successful', 1, 2),
(5, '2024-11-20 15:00:00', 180, 'Completed', 'Laparoscopic cholecystectomy, no complications', 6, 1),
(6, '2024-11-18 08:00:00', 240, 'Completed', 'Total hip replacement, recovery normal', 2, 7),
(7, '2024-11-15 13:00:00', 45, 'Completed', 'Diagnostic colonoscopy, polyps removed', 1, 3),
(1, '2024-11-12 10:30:00', 85, 'Completed', 'Emergency appendectomy, successful', 1, 1),
(9, '2024-11-10 09:00:00', 200, 'Completed', 'Total thyroidectomy, pathology pending', 1, 1),
(10, '2024-11-08 16:00:00', 30, 'Completed', 'Pediatric tonsillectomy, no issues', 1, 5);

-- =====================================================
-- 18. PATIENT CONSENTS
-- =====================================================
INSERT INTO PATIENT_CONSENTS (EHR, procedure_id, consent_date, consent_type, signed) VALUES
('EHR001', 1, '2024-11-20', 'Surgical Consent', TRUE),
('EHR002', 2, '2024-11-21', 'Surgical Consent', TRUE),
('EHR003', 3, '2024-11-22', 'Surgical Consent', TRUE),
('EHR004', 4, '2024-11-15', 'Surgical Consent', TRUE),
('EHR005', 5, '2024-11-13', 'Surgical Consent', TRUE),
('EHR006', 6, '2024-11-11', 'Surgical Consent', TRUE),
('EHR007', 7, '2024-11-10', 'Diagnostic Procedure Consent', TRUE),
('EHR001', 1, '2024-11-05', 'Anesthesia Consent', TRUE),
('EHR009', 9, '2024-11-03', 'Surgical Consent', TRUE),
('EHR010', 10, '2024-11-01', 'Surgical Consent', TRUE);

-- =====================================================
-- 19. APPOINTMENT_SURGICAL_PROCEDURE
-- =====================================================
INSERT INTO APPOINTMENT_SURGICAL_PROCEDURE (appointment_id, surgical_procedure_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(7, 4),
(8, 7);

-- =====================================================
-- 20. SURGICAL_PROCEDURE_SURGEONS
-- =====================================================
INSERT INTO SURGICAL_PROCEDURE_SURGEONS (surgical_procedure_id, surgeon_id, role_in_surgery) VALUES
(1, 1, 'Lead Surgeon'),
(2, 2, 'Lead Surgeon'),
(3, 1, 'Lead Surgeon'),
(4, 5, 'Lead Surgeon'),
(5, 6, 'Lead Surgeon'),
(6, 2, 'Lead Surgeon'),
(6, 5, 'Assisting Surgeon'),
(7, 1, 'Lead Surgeon'),
(8, 1, 'Lead Surgeon'),
(9, 1, 'Lead Surgeon'),
(10, 5, 'Lead Surgeon');

-- =====================================================
-- 21. SURGICAL_PROCEDURE_NURSES
-- =====================================================
INSERT INTO SURGICAL_PROCEDURE_NURSES (surgical_procedure_id, nurse_id, role_in_surgery) VALUES
(1, 1, 'Scrub Nurse'),
(1, 2, 'Circulating Nurse'),
(2, 3, 'Scrub Nurse'),
(2, 4, 'Circulating Nurse'),
(3, 1, 'Scrub Nurse'),
(4, 5, 'Scrub Nurse'),
(4, 6, 'Circulating Nurse'),
(5, 7, 'Scrub Nurse'),
(5, 8, 'Circulating Nurse'),
(6, 3, 'Scrub Nurse'),
(6, 4, 'Circulating Nurse'),
(6, 5, 'Recovery Nurse'),
(7, 1, 'Endoscopy Nurse'),
(8, 2, 'Scrub Nurse'),
(9, 7, 'Scrub Nurse'),
(10, 1, 'Scrub Nurse');

-- =====================================================
-- 22. SURGICAL_PROCEDURE_ANESTHESIOLOGISTS
-- =====================================================
INSERT INTO SURGICAL_PROCEDURE_ANESTHESIOLOGISTS (surgical_procedure_id, anesthesiologist_id) VALUES
(1, 1),
(2, 2),
(3, 1),
(4, 3),
(5, 1),
(6, 2),
(7, 3),
(8, 1),
(9, 2),
(10, 4);

-- =====================================================
-- 23. SURGICAL_PROCEDURE_MEDICATIONS
-- =====================================================
INSERT INTO SURGICAL_PROCEDURE_MEDICATIONS (surgical_procedure_id, medication_id, prescribed_datetime, prescribed_by, dosage) VALUES
(1, 3, '2024-11-26 09:45:00', 'Dr. Anderson', '200mg'),
(1, 4, '2024-11-26 09:50:00', 'Dr. Anderson', '1g'),
(1, 1, '2024-11-26 11:30:00', 'Dr. Martinez', '10mg'),
(2, 3, '2024-11-27 13:45:00', 'Dr. Thompson', '200mg'),
(2, 2, '2024-11-27 14:30:00', 'Dr. Chen', '50mcg'),
(3, 7, '2024-11-28 08:45:00', 'Dr. Anderson', '2mg'),
(4, 3, '2024-11-22 10:45:00', 'Dr. Anderson', '200mg'),
(4, 4, '2024-11-22 10:50:00', 'Dr. Rodriguez', '1g'),
(5, 3, '2024-11-20 14:45:00', 'Dr. Anderson', '200mg'),
(5, 1, '2024-11-20 16:30:00', 'Dr. Thompson', '10mg');

-- =====================================================
-- 24. SURGICAL_MATERIAL_USAGE
-- =====================================================
INSERT INTO SURGICAL_MATERIAL_USAGE (surgical_procedure_id, material_id, amount_used, usage_notes) VALUES
(1, 1, 4, 'Surgical team gloves'),
(1, 2, 2, 'Surgeon gloves'),
(1, 3, 3, 'Wound closure'),
(1, 6, 2, 'Sterile field preparation'),
(1, 7, 5, 'Incision'),
(1, 8, 20, 'Wound cleaning'),
(2, 1, 4, 'Surgical team gloves'),
(2, 12, 10, 'Arthroscopy procedure'),
(3, 1, 4, 'Surgical team gloves'),
(3, 7, 2, 'Cataract incision'),
(4, 14, 1, 'Hernia repair mesh'),
(4, 4, 5, 'Wound closure'),
(5, 1, 4, 'Surgical team gloves'),
(5, 15, 1, 'Drainage tube placement'),
(6, 13, 1, 'Hip prosthesis cement');

-- =====================================================
-- 25. IMAGING STUDIES
-- =====================================================
INSERT INTO IMAGING_STUDIES (surgical_procedure_id, study_type, study_date, results, image_url) VALUES
(1, 'Abdominal CT Scan', '2024-11-25 16:00:00', 'Acute appendicitis confirmed', '/images/studies/ct_001.dcm'),
(2, 'Knee MRI', '2024-11-26 10:00:00', 'Meniscal tear identified', '/images/studies/mri_002.dcm'),
(3, 'Eye Ultrasound', '2024-11-27 08:00:00', 'Dense cataract confirmed', '/images/studies/us_003.dcm'),
(4, 'Abdominal X-Ray', '2024-11-21 14:00:00', 'Inguinal hernia visible', '/images/studies/xr_004.dcm'),
(5, 'Abdominal Ultrasound', '2024-11-19 11:00:00', 'Gallstones confirmed', '/images/studies/us_005.dcm'),
(6, 'Hip X-Ray', '2024-11-17 09:00:00', 'Severe osteoarthritis', '/images/studies/xr_006.dcm'),
(6, 'Hip CT Scan', '2024-11-17 13:00:00', 'Joint damage assessment', '/images/studies/ct_007.dcm');

-- =====================================================
-- 26. LAB TESTS
-- =====================================================
INSERT INTO LAB_TESTS (surgical_procedure_id, test_name, test_date, ordered_by) VALUES
(1, 'Complete Blood Count', '2024-11-25 08:00:00', 'Dr. Martinez'),
(1, 'Basic Metabolic Panel', '2024-11-25 08:00:00', 'Dr. Martinez'),
(2, 'Coagulation Panel', '2024-11-26 07:00:00', 'Dr. Chen'),
(3, 'Pre-operative CBC', '2024-11-27 07:30:00', 'Dr. Martinez'),
(4, 'Complete Blood Count', '2024-11-21 08:00:00', 'Dr. Garcia'),
(5, 'Liver Function Tests', '2024-11-19 08:00:00', 'Dr. Thompson'),
(5, 'Lipid Panel', '2024-11-19 08:00:00', 'Dr. Thompson'),
(6, 'Complete Blood Count', '2024-11-17 07:00:00', 'Dr. Chen'),
(6, 'ESR and CRP', '2024-11-17 07:00:00', 'Dr. Chen');

-- =====================================================
-- 27. LAB RESULTS
-- =====================================================
INSERT INTO LAB_RESULTS (test_id, surgical_procedure_id, result_value, result_date, normal_range, notes) VALUES
(1, 1, 'WBC: 14.5', '2024-11-25 10:00:00', '4.5-11.0 K/uL', 'Elevated WBC consistent with appendicitis'),
(2, 1, 'Normal', '2024-11-25 10:30:00', 'Within normal limits', 'All electrolytes normal'),
(3, 2, 'PT: 12.5s, INR: 1.0', '2024-11-26 09:00:00', 'PT: 11-13.5s', 'Normal coagulation'),
(4, 3, 'Normal', '2024-11-27 09:00:00', 'Within normal limits', 'Cleared for surgery'),
(5, 4, 'WBC: 10.2', '2024-11-21 10:00:00', '4.5-11.0 K/uL', 'Normal range'),
(6, 5, 'ALT: 45, AST: 38', '2024-11-19 10:00:00', 'ALT: 7-56, AST: 10-40', 'Liver function normal'),
(7, 5, 'Total Chol: 220', '2024-11-19 10:30:00', '<200 mg/dL', 'Slightly elevated cholesterol');