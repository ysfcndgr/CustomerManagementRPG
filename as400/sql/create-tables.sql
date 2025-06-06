-- Customer Information Update System - Database Schema
-- IBM DB2 for AS400/IBM i
-- Version: 1.0
-- Description: Creates the main tables for customer data management

-- Create Customer Data Library if it doesn't exist
-- CRTLIB LIB(CUSTDATA) TEXT('Customer Data Library');

-- Create Customer Log Library if it doesn't exist  
-- CRTLIB LIB(CUSTLOG) TEXT('Customer Log Library');

-- =============================================================================
-- Table: CUSTOMER (Main Customer Records)
-- Description: Stores validated customer information
-- =============================================================================
CREATE TABLE CUSTDATA.CUSTOMER (
    CUSTID INTEGER GENERATED ALWAYS AS IDENTITY 
           (START WITH 1000 INCREMENT BY 1 NO MAXVALUE NO CYCLE) NOT NULL,
    CUSTNAME VARCHAR(100) NOT NULL,
    PHONE VARCHAR(20),
    EMAIL VARCHAR(100),
    ADDRESS VARCHAR(255),
    TAXID CHAR(11) NOT NULL,
    CREATED_TS TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UPDATED_TS TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CREATED_BY VARCHAR(50) DEFAULT USER NOT NULL,
    UPDATED_BY VARCHAR(50) DEFAULT USER NOT NULL,
    
    CONSTRAINT PK_CUSTOMER PRIMARY KEY (CUSTID),
    CONSTRAINT UK_CUSTOMER_TAXID UNIQUE (TAXID),
    CONSTRAINT CK_CUSTOMER_NAME CHECK (LENGTH(TRIM(CUSTNAME)) >= 2),
    CONSTRAINT CK_CUSTOMER_TAXID CHECK (LENGTH(TAXID) = 11),
    CONSTRAINT CK_CUSTOMER_EMAIL CHECK (EMAIL LIKE '%@%.%' OR EMAIL IS NULL)
);

-- Add table comment
COMMENT ON TABLE CUSTDATA.CUSTOMER IS 'Main customer records table - stores validated customer information';

-- Add column comments
COMMENT ON COLUMN CUSTDATA.CUSTOMER.CUSTID IS 'Unique customer identifier';
COMMENT ON COLUMN CUSTDATA.CUSTOMER.CUSTNAME IS 'Customer full name (2-100 characters)';
COMMENT ON COLUMN CUSTDATA.CUSTOMER.PHONE IS 'Customer phone number';
COMMENT ON COLUMN CUSTDATA.CUSTOMER.EMAIL IS 'Customer email address';
COMMENT ON COLUMN CUSTDATA.CUSTOMER.ADDRESS IS 'Customer mailing address';
COMMENT ON COLUMN CUSTDATA.CUSTOMER.TAXID IS 'Customer tax identification (11 digits)';
COMMENT ON COLUMN CUSTDATA.CUSTOMER.CREATED_TS IS 'Record creation timestamp';
COMMENT ON COLUMN CUSTDATA.CUSTOMER.UPDATED_TS IS 'Record last update timestamp';
COMMENT ON COLUMN CUSTDATA.CUSTOMER.CREATED_BY IS 'User who created the record';
COMMENT ON COLUMN CUSTDATA.CUSTOMER.UPDATED_BY IS 'User who last updated the record';

-- =============================================================================
-- Table: CUSTOMER_TEMP (Validation Staging)
-- Description: Temporary staging table for customer data validation
-- =============================================================================
CREATE TABLE CUSTDATA.CUSTOMER_TEMP (
    TEMPID INTEGER GENERATED ALWAYS AS IDENTITY 
           (START WITH 1 INCREMENT BY 1 NO MAXVALUE NO CYCLE) NOT NULL,
    CUSTNAME VARCHAR(100),
    PHONE VARCHAR(20),
    EMAIL VARCHAR(100),
    ADDRESS VARCHAR(255),
    TAXID CHAR(11),
    ERROR_MSG VARCHAR(500),
    STATUS CHAR(1) DEFAULT 'P' NOT NULL,  -- P=Pending, V=Valid, E=Error, X=Expired
    CREATED_TS TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PROCESSED_TS TIMESTAMP,
    PROCESSED_BY VARCHAR(50),
    SOURCE_SYSTEM VARCHAR(20) DEFAULT 'WEB_API',
    SESSION_ID VARCHAR(100),
    
    CONSTRAINT PK_CUSTOMER_TEMP PRIMARY KEY (TEMPID),
    CONSTRAINT CK_TEMP_STATUS CHECK (STATUS IN ('P', 'V', 'E', 'X'))
);

-- Add table comment
COMMENT ON TABLE CUSTDATA.CUSTOMER_TEMP IS 'Temporary staging table for customer data validation';

-- Add column comments
COMMENT ON COLUMN CUSTDATA.CUSTOMER_TEMP.TEMPID IS 'Unique temporary record identifier';
COMMENT ON COLUMN CUSTDATA.CUSTOMER_TEMP.STATUS IS 'P=Pending, V=Valid, E=Error, X=Expired';
COMMENT ON COLUMN CUSTDATA.CUSTOMER_TEMP.ERROR_MSG IS 'Validation error message if status=E';
COMMENT ON COLUMN CUSTDATA.CUSTOMER_TEMP.SOURCE_SYSTEM IS 'System that submitted the data';
COMMENT ON COLUMN CUSTDATA.CUSTOMER_TEMP.SESSION_ID IS 'Session identifier for tracking';

-- =============================================================================
-- Table: CUSTOMER_LOG (Audit Trail)
-- Description: Comprehensive audit log of all customer data changes
-- =============================================================================
CREATE TABLE CUSTLOG.CUSTOMER_LOG (
    LOGID INTEGER GENERATED ALWAYS AS IDENTITY 
          (START WITH 1 INCREMENT BY 1 NO MAXVALUE NO CYCLE) NOT NULL,
    CUSTID INTEGER,
    TEMPID INTEGER,
    ACTION VARCHAR(50) NOT NULL,
    OLD_VALUES VARCHAR(1000),
    NEW_VALUES VARCHAR(1000),
    USER_ID VARCHAR(100) DEFAULT USER NOT NULL,
    LOG_TS TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    SOURCE_IP VARCHAR(45),
    SESSION_ID VARCHAR(100),
    PROGRAM_NAME VARCHAR(20) DEFAULT 'MUSTVALID',
    SUCCESS_FLAG CHAR(1) DEFAULT 'Y',
    ERROR_CODE VARCHAR(10),
    ERROR_DESC VARCHAR(200),
    
    CONSTRAINT PK_CUSTOMER_LOG PRIMARY KEY (LOGID),
    CONSTRAINT CK_LOG_ACTION CHECK (ACTION IN ('INSERT', 'UPDATE', 'DELETE', 'VALIDATE', 'ERROR')),
    CONSTRAINT CK_LOG_SUCCESS CHECK (SUCCESS_FLAG IN ('Y', 'N'))
);

-- Add table comment
COMMENT ON TABLE CUSTLOG.CUSTOMER_LOG IS 'Audit trail of all customer data operations';

-- Add column comments
COMMENT ON COLUMN CUSTLOG.CUSTOMER_LOG.LOGID IS 'Unique log entry identifier';
COMMENT ON COLUMN CUSTLOG.CUSTOMER_LOG.CUSTID IS 'Related customer ID (if applicable)';
COMMENT ON COLUMN CUSTLOG.CUSTOMER_LOG.TEMPID IS 'Related temp record ID (if applicable)';
COMMENT ON COLUMN CUSTLOG.CUSTOMER_LOG.ACTION IS 'Type of operation performed';
COMMENT ON COLUMN CUSTLOG.CUSTOMER_LOG.OLD_VALUES IS 'Previous values before change';
COMMENT ON COLUMN CUSTLOG.CUSTOMER_LOG.NEW_VALUES IS 'New values after change';
COMMENT ON COLUMN CUSTLOG.CUSTOMER_LOG.SUCCESS_FLAG IS 'Y=Success, N=Failure';

-- =============================================================================
-- Table: CUSTOMER_VALIDATION_RULES (Business Rules)
-- Description: Configurable validation rules for customer data
-- =============================================================================
CREATE TABLE CUSTDATA.CUSTOMER_VALIDATION_RULES (
    RULE_ID INTEGER GENERATED ALWAYS AS IDENTITY 
            (START WITH 1 INCREMENT BY 1 NO MAXVALUE NO CYCLE) NOT NULL,
    RULE_NAME VARCHAR(50) NOT NULL,
    FIELD_NAME VARCHAR(30) NOT NULL,
    RULE_TYPE VARCHAR(20) NOT NULL,  -- REGEX, LENGTH, REQUIRED, CUSTOM
    RULE_VALUE VARCHAR(500),
    ERROR_MESSAGE VARCHAR(200) NOT NULL,
    IS_ACTIVE CHAR(1) DEFAULT 'Y' NOT NULL,
    CREATED_TS TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CREATED_BY VARCHAR(50) DEFAULT USER NOT NULL,
    
    CONSTRAINT PK_VALIDATION_RULES PRIMARY KEY (RULE_ID),
    CONSTRAINT UK_RULE_NAME UNIQUE (RULE_NAME),
    CONSTRAINT CK_RULE_TYPE CHECK (RULE_TYPE IN ('REGEX', 'LENGTH', 'REQUIRED', 'CUSTOM')),
    CONSTRAINT CK_RULE_ACTIVE CHECK (IS_ACTIVE IN ('Y', 'N'))
);

-- Add table comment
COMMENT ON TABLE CUSTDATA.CUSTOMER_VALIDATION_RULES IS 'Configurable validation rules for customer data';

-- Insert default validation rules
INSERT INTO CUSTDATA.CUSTOMER_VALIDATION_RULES 
    (RULE_NAME, FIELD_NAME, RULE_TYPE, RULE_VALUE, ERROR_MESSAGE) VALUES
    ('NAME_REQUIRED', 'CUSTNAME', 'REQUIRED', NULL, 'Customer name is required'),
    ('NAME_LENGTH', 'CUSTNAME', 'LENGTH', '2,100', 'Customer name must be 2-100 characters'),
    ('PHONE_FORMAT', 'PHONE', 'REGEX', '^\+?[\d\s\-\(\)]+$', 'Invalid phone number format'),
    ('EMAIL_FORMAT', 'EMAIL', 'REGEX', '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', 'Invalid email format'),
    ('EMAIL_LENGTH', 'EMAIL', 'LENGTH', '5,100', 'Email must be 5-100 characters'),
    ('ADDRESS_REQUIRED', 'ADDRESS', 'REQUIRED', NULL, 'Address is required'),
    ('ADDRESS_LENGTH', 'ADDRESS', 'LENGTH', '5,255', 'Address must be 5-255 characters'),
    ('TAXID_REQUIRED', 'TAXID', 'REQUIRED', NULL, 'Tax ID is required'),
    ('TAXID_LENGTH', 'TAXID', 'LENGTH', '11,11', 'Tax ID must be exactly 11 characters'),
    ('TAXID_NUMERIC', 'TAXID', 'REGEX', '^\d{11}$', 'Tax ID must contain only digits');

-- =============================================================================
-- Cleanup old temporary records (older than 7 days)
-- This can be run as a scheduled job
-- =============================================================================

-- Create a view for easy monitoring
CREATE VIEW CUSTDATA.V_CUSTOMER_TEMP_SUMMARY AS
SELECT 
    STATUS,
    COUNT(*) AS RECORD_COUNT,
    MIN(CREATED_TS) AS OLDEST_RECORD,
    MAX(CREATED_TS) AS NEWEST_RECORD,
    COUNT(CASE WHEN CREATED_TS < CURRENT_TIMESTAMP - 7 DAYS THEN 1 END) AS OLD_RECORDS
FROM CUSTDATA.CUSTOMER_TEMP
GROUP BY STATUS;

-- Grant necessary permissions (to be run by security administrator)
-- GRANT SELECT, INSERT, UPDATE ON CUSTDATA.CUSTOMER TO APIUSER;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON CUSTDATA.CUSTOMER_TEMP TO APIUSER;
-- GRANT INSERT ON CUSTLOG.CUSTOMER_LOG TO APIUSER;
-- GRANT SELECT ON CUSTDATA.CUSTOMER_VALIDATION_RULES TO APIUSER;

-- Create journal for recovery (optional but recommended)
-- CRTJRNRCV JRNRCV(CUSTDATA/RCVR001) TEXT('Customer Journal Receiver');
-- CRTJRN JRN(CUSTDATA/CUSTJRN) JRNRCV(CUSTDATA/RCVR001) TEXT('Customer Journal');
-- STRJRNPF FILE(CUSTDATA/CUSTOMER) JRN(CUSTDATA/CUSTJRN);
-- STRJRNPF FILE(CUSTDATA/CUSTOMER_TEMP) JRN(CUSTDATA/CUSTJRN);

-- End of script
COMMIT; 