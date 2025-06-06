# AS400 Integration Components

🖥️ **IBM AS400 RPG Programs and DB2 Database Schema for Customer Validation**

## 🎯 Overview

This directory contains the AS400/IBM i components of the Customer Information Update System, including RPG programs for data validation and DB2 database schema definitions. The AS400 system serves as the validation engine and data repository for customer information.

## 🏗️ Architecture Components

```
┌─────────────────────────────────────────────────────────┐
│                    .NET Core API                       │
│              (HTTP REST Interface)                     │
├─────────────────────────────────────────────────────────┤
│                    ODBC/DB2 Driver                     │
│            (Database Connection Layer)                 │
├─────────────────────────────────────────────────────────┤
│                     AS400/IBM i                        │
│              (RPG Programs + DB2 Database)             │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Features

- ✅ **RPG Validation Programs**: Business logic validation in native AS400
- ✅ **DB2 Database**: High-performance customer data storage
- ✅ **ODBC Integration**: Standard database connectivity
- ✅ **Audit Trail**: Comprehensive logging of all changes
- ✅ **Data Integrity**: Referential integrity and constraints
- ✅ **Performance**: Optimized for high-volume operations

## 📁 Directory Structure

```
as400/
├── rpg/                     # RPG Source Programs
│   ├── MUSTVALID.rpgle      # Main validation program
│   ├── CUSTUTIL.rpgleinc    # Utility procedures
│   └── COPYBOOKS/           # Copy member definitions
│       ├── CUSTCOPY.rpgleinc
│       └── LOGCOPY.rpgleinc
├── sql/                     # Database Scripts
│   ├── create-tables.sql    # Table creation scripts
│   ├── create-indexes.sql   # Index definitions
│   ├── create-procedures.sql # Stored procedures
│   ├── sample-data.sql      # Test data scripts
│   └── permissions.sql      # User permissions
└── README.md                # This documentation
```

## 🛠️ Technology Stack

- **System**: IBM AS400 (IBM i)
- **Language**: RPG ILE (Integrated Language Environment)
- **Database**: IBM DB2 for i
- **Connectivity**: ODBC, DB2 Connect
- **Library**: CUSTLIB (Customer Library)
- **Environment**: Development/Test/Production partitions

## 🔧 Installation & Setup

### Prerequisites
- IBM AS400/IBM i system access
- Authority to create libraries and programs
- DB2 database privileges
- ODBC driver configuration on client systems

### Step 1: Create Library Structure
```
CRTLIB LIB(CUSTLIB) TEXT('Customer Management Library')
CRTLIB LIB(CUSTDATA) TEXT('Customer Data Library')
CRTLIB LIB(CUSTLOG) TEXT('Customer Audit Log Library')
```

### Step 2: Create Database Objects
Execute the SQL scripts in the following order:
```sql
-- 1. Create tables
RUNSQLSTM SRCFILE(CUSTLIB/QSQLSRC) SRCMBR(CREATETBL)

-- 2. Create indexes  
RUNSQLSTM SRCFILE(CUSTLIB/QSQLSRC) SRCMBR(CREATEIDX)

-- 3. Create procedures
RUNSQLSTM SRCFILE(CUSTLIB/QSQLSRC) SRCMBR(CREATEPRC)

-- 4. Set permissions
RUNSQLSTM SRCFILE(CUSTLIB/QSQLSRC) SRCMBR(SETPERMS)
```

### Step 3: Compile RPG Programs
```
CRTBNDRPG PGM(CUSTLIB/MUSTVALID) SRCFILE(CUSTLIB/QRPGLESRC)
CRTBNDRPG PGM(CUSTLIB/CUSTUTIL) SRCFILE(CUSTLIB/QRPGLESRC)
```

### Step 4: Configure ODBC Connection
On the .NET API server, configure ODBC DSN:
```ini
[CUSTLIB_AS400]
Driver=IBM i Access ODBC Driver
System=your-as400-system-name
UserID=APIUSER
Password=your-password
DefaultLibraries=CUSTLIB,CUSTDATA,CUSTLOG
CommitMode=2
ExtendedDynamic=1
```

## 📊 Database Schema

### Table: CUSTOMER (Main Customer Records)
```sql
CREATE TABLE CUSTDATA.CUSTOMER (
    CUSTID INTEGER GENERATED ALWAYS AS IDENTITY 
           (START WITH 1 INCREMENT BY 1) NOT NULL,
    CUSTNAME VARCHAR(100) NOT NULL,
    PHONE VARCHAR(20),
    EMAIL VARCHAR(100),
    ADDRESS VARCHAR(255),
    TAXID CHAR(11) NOT NULL,
    CREATED_TS TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UPDATED_TS TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_CUSTOMER PRIMARY KEY (CUSTID),
    CONSTRAINT UK_CUSTOMER_TAXID UNIQUE (TAXID)
);
```

### Table: CUSTOMER_TEMP (Validation Staging)
```sql
CREATE TABLE CUSTDATA.CUSTOMER_TEMP (
    TEMPID INTEGER GENERATED ALWAYS AS IDENTITY 
           (START WITH 1 INCREMENT BY 1) NOT NULL,
    CUSTNAME VARCHAR(100),
    PHONE VARCHAR(20),
    EMAIL VARCHAR(100),
    ADDRESS VARCHAR(255),
    TAXID CHAR(11),
    ERROR_MSG VARCHAR(500),
    STATUS CHAR(1) DEFAULT 'P',  -- P=Pending, V=Valid, E=Error
    CREATED_TS TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PROCESSED_TS TIMESTAMP,
    CONSTRAINT PK_CUSTOMER_TEMP PRIMARY KEY (TEMPID)
);
```

### Table: CUSTOMER_LOG (Audit Trail)
```sql
CREATE TABLE CUSTLOG.CUSTOMER_LOG (
    LOGID INTEGER GENERATED ALWAYS AS IDENTITY 
          (START WITH 1 INCREMENT BY 1) NOT NULL,
    CUSTID INTEGER,
    ACTION VARCHAR(50) NOT NULL,
    OLD_VALUES VARCHAR(1000),
    NEW_VALUES VARCHAR(1000),
    USER_ID VARCHAR(100),
    LOG_TS TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_CUSTOMER_LOG PRIMARY KEY (LOGID)
);
```

## 🔧 RPG Program: MUSTVALID

### Program Purpose
The `MUSTVALID` program validates customer data according to business rules and either approves or rejects the update request.

### Program Interface
```rpg
// Program Parameters
dcl-pi MUSTVALID;
  custName varchar(100) const;
  phone varchar(20) const;
  email varchar(100) const;
  address varchar(255) const;
  taxId char(11) const;
  result varchar(500);
end-pi;
```

### Validation Rules
1. **Name Validation**
   - Must be 2-100 characters
   - Cannot contain special characters except spaces, hyphens, apostrophes
   - Cannot be empty or all spaces

2. **Phone Validation**
   - Must follow format: (XXX) XXX-XXXX or XXX-XXX-XXXX
   - Can include country code: +1-XXX-XXX-XXXX
   - Must contain only digits, spaces, parentheses, hyphens, plus sign

3. **Email Validation**
   - Must contain @ symbol
   - Must have domain with at least one dot
   - Must be valid email format
   - Maximum 100 characters

4. **Address Validation**
   - Must be at least 5 characters
   - Cannot be empty or all spaces
   - Maximum 255 characters

5. **Tax ID Validation**
   - Must be exactly 11 characters
   - Must contain only digits
   - Must not already exist in database (uniqueness check)

### Program Flow
```
1. Receive parameters from .NET API
2. Insert record into CUSTOMER_TEMP with status 'P' (Pending)
3. Validate each field according to business rules
4. If all validations pass:
   - Check for duplicate Tax ID in CUSTOMER table
   - Insert/Update record in CUSTOMER table
   - Log action in CUSTOMER_LOG table
   - Update CUSTOMER_TEMP status to 'V' (Valid)
   - Return success message
5. If validation fails:
   - Update CUSTOMER_TEMP with error message and status 'E' (Error)
   - Return error message
```

## 🔌 API Integration Points

### ODBC Connection from .NET
```csharp
// Connection string for AS400 DB2
string connectionString = "Driver={IBM i Access ODBC Driver};" +
                         "System=AS400-SYSTEM;" +
                         "UserID=APIUSER;" +
                         "Password=PASSWORD;" +
                         "DefaultLibraries=CUSTLIB,CUSTDATA,CUSTLOG;";

// Call RPG program via stored procedure
using (var connection = new OdbcConnection(connectionString))
{
    var command = new OdbcCommand("CALL CUSTLIB.MUSTVALID(?,?,?,?,?,?)", connection);
    command.Parameters.AddWithValue("@name", customerData.Name);
    command.Parameters.AddWithValue("@phone", customerData.Phone);
    command.Parameters.AddWithValue("@email", customerData.Email);
    command.Parameters.AddWithValue("@address", customerData.Address);
    command.Parameters.AddWithValue("@taxId", customerData.TaxId);
    command.Parameters.Add("@result", OdbcType.VarChar, 500).Direction = ParameterDirection.Output;
    
    await connection.OpenAsync();
    await command.ExecuteNonQueryAsync();
    
    string result = command.Parameters["@result"].Value.ToString();
}
```

### Direct SQL Access
```csharp
// Query customer data
string sql = @"
    SELECT CUSTID, CUSTNAME, PHONE, EMAIL, ADDRESS, TAXID, CREATED_TS, UPDATED_TS 
    FROM CUSTDATA.CUSTOMER 
    WHERE TAXID = ?";

using (var command = new OdbcCommand(sql, connection))
{
    command.Parameters.AddWithValue("@taxId", taxId);
    using (var reader = await command.ExecuteReaderAsync())
    {
        // Process results
    }
}
```

## 🛡️ Security & Permissions

### User Profiles
```
CRTUSRPRF USRPRF(APIUSER) PASSWORD(SecurePassword123) 
          USRCLS(*USER) TEXT('API Integration User')

CRTUSRPRF USRPRF(CUSTADMIN) PASSWORD(AdminPassword456) 
          USRCLS(*SECADM) TEXT('Customer Admin User')
```

### Object Authorities
```
GRTOBJAUT OBJ(CUSTLIB/*ALL) OBJTYPE(*LIB) USER(APIUSER) AUT(*USE)
GRTOBJAUT OBJ(CUSTDATA/*ALL) OBJTYPE(*FILE) USER(APIUSER) AUT(*CHANGE)
GRTOBJAUT OBJ(CUSTLOG/*ALL) OBJTYPE(*FILE) USER(APIUSER) AUT(*ADD)
GRTOBJAUT OBJ(CUSTLIB/MUSTVALID) OBJTYPE(*PGM) USER(APIUSER) AUT(*USE)
```

## 📈 Performance Considerations

### Indexing Strategy
```sql
-- Primary indexes (automatically created with constraints)
-- Additional performance indexes:

CREATE INDEX CUSTDATA.IDX_CUSTOMER_NAME 
    ON CUSTDATA.CUSTOMER (CUSTNAME);

CREATE INDEX CUSTDATA.IDX_CUSTOMER_EMAIL 
    ON CUSTDATA.CUSTOMER (EMAIL);

CREATE INDEX CUSTLOG.IDX_LOG_TIMESTAMP 
    ON CUSTLOG.CUSTOMER_LOG (LOG_TS DESC);

CREATE INDEX CUSTDATA.IDX_TEMP_STATUS 
    ON CUSTDATA.CUSTOMER_TEMP (STATUS, CREATED_TS);
```

### RPG Optimization
- Use embedded SQL for database operations
- Implement proper error handling
- Use activation groups for better memory management
- Optimize file I/O operations

## 🔍 Monitoring & Maintenance

### Database Monitoring
```sql
-- Check table sizes
SELECT TABLE_SCHEMA, TABLE_NAME, 
       IFNULL(NUMBER_ROWS, 0) AS ROW_COUNT
FROM QSYS2.SYSTABLES 
WHERE TABLE_SCHEMA IN ('CUSTDATA', 'CUSTLOG')
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- Monitor validation errors
SELECT STATUS, COUNT(*) as COUNT, 
       MIN(CREATED_TS) as OLDEST,
       MAX(CREATED_TS) as NEWEST
FROM CUSTDATA.CUSTOMER_TEMP 
GROUP BY STATUS;
```

### Log Rotation
```sql
-- Archive old log entries (older than 1 year)
INSERT INTO CUSTLOG.CUSTOMER_LOG_ARCHIVE 
SELECT * FROM CUSTLOG.CUSTOMER_LOG 
WHERE LOG_TS < CURRENT_TIMESTAMP - 1 YEAR;

DELETE FROM CUSTLOG.CUSTOMER_LOG 
WHERE LOG_TS < CURRENT_TIMESTAMP - 1 YEAR;
```

## 🧪 Testing

### Unit Testing for RPG
Create test programs to validate individual functions:
```rpg
// Test program: TSTVALID
dcl-proc testPhoneValidation;
  dcl-pi *n ind end-pi;
  
  // Test valid phone numbers
  assert(validatePhone('(555) 123-4567') = *on);
  assert(validatePhone('555-123-4567') = *on);
  assert(validatePhone('+1-555-123-4567') = *on);
  
  // Test invalid phone numbers
  assert(validatePhone('123') = *off);
  assert(validatePhone('abc-def-ghij') = *off);
  
  return *on;
end-proc;
```

### Integration Testing
```sql
-- Test data insertion
INSERT INTO CUSTDATA.CUSTOMER_TEMP 
VALUES (DEFAULT, 'Test Customer', '555-123-4567', 
        'test@example.com', '123 Test St', '12345678901', 
        '', 'P', CURRENT_TIMESTAMP, NULL);

-- Call validation program
CALL CUSTLIB.MUSTVALID('Test Customer', '555-123-4567', 
                       'test@example.com', '123 Test St', 
                       '12345678901', ?);
```

## 🚀 Deployment

### Development Environment
```
Library: CUSTDEV
Programs: CUSTDEV/MUSTVALID
Tables: CUSTDEV.CUSTOMER, CUSTDEV.CUSTOMER_TEMP, CUSTDEV.CUSTOMER_LOG
```

### Production Environment
```
Library: CUSTLIB
Programs: CUSTLIB/MUSTVALID
Tables: CUSTDATA.CUSTOMER, CUSTDATA.CUSTOMER_TEMP, CUSTLOG.CUSTOMER_LOG
```

### Deployment Script
```
// Copy source to production library
CPYSRCF FROMSRCF(CUSTDEV/QRPGLESRC) TOSRCF(CUSTLIB/QRPGLESRC) 
        FROMMBR(MUSTVALID) TOMBR(MUSTVALID) MBROPT(*REPLACE)

// Compile production program
CRTBNDRPG PGM(CUSTLIB/MUSTVALID) SRCFILE(CUSTLIB/QRPGLESRC) 
          SRCMBR(MUSTVALID) OPTION(*EVENTF)
```

## 🤝 Contributing

1. Follow RPG ILE coding standards
2. Include comprehensive error handling
3. Document all procedures and programs
4. Write unit tests for new functionality
5. Update this README with any changes

## 🔗 Related Documentation

- [Backend API Documentation](../backend/README.md)
- [Frontend Documentation](../frontend/README.md)
- [Database Schema Details](../docs/database-schema.md)
- [API Integration Guide](../docs/api-specification.md)

## 📞 Support

For AS400 specific issues:
- Check job logs: `WRKJOB JOB(job-name)`
- Review program dumps: `WRKPRB`
- Monitor database locks: `WRKJOB JOB(*) STS(*ACTIVE)`
- Check authorities: `DSPOBJAUT OBJ(object-name)`

---

**System**: IBM AS400/IBM i  
**Library**: CUSTLIB  
**Main Program**: MUSTVALID  
**Database**: DB2 for i 