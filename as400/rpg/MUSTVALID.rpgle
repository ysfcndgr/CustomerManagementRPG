**free
// ****************************************************************************
// Program: MUSTVALID
// Description: Customer Data Validation Program
// Author: Customer Update System
// Date: 2024
// 
// Purpose: Validates customer information received from web API and either
//          approves or rejects the update request based on business rules.
//
// Parameters:
//   custName   - Customer name (input)
//   phone      - Phone number (input)  
//   email      - Email address (input)
//   address    - Mailing address (input)
//   taxId      - Tax ID number (input)
//   result     - Validation result message (output)
//
// Flow:
//   1. Insert data into CUSTOMER_TEMP table
//   2. Validate each field according to business rules
//   3. Check for duplicate Tax ID
//   4. If valid: Insert/Update CUSTOMER table and log success
//   5. If invalid: Update CUSTOMER_TEMP with error and log failure
// ****************************************************************************

ctl-opt nomain thread(*yes) decedit('0,') datfmt(*iso) timfmt(*hms);

// Program Interface
dcl-pi MUSTVALID export;
  custName varchar(100) const;
  phone varchar(20) const;
  email varchar(100) const;
  address varchar(255) const;
  taxId char(11) const;
  result varchar(500);
end-pi;

// Copy members for data structures
/copy CUSTLIB/QRPGCOPY,CUSTCOPY
/copy CUSTLIB/QRPGCOPY,LOGCOPY

// Global variables
dcl-s tempId int(10);
dcl-s existingCustId int(10);
dcl-s errorMsg varchar(500);
dcl-s isValid ind inz(*on);
dcl-s currentUser char(10);
dcl-s currentTS timestamp;

// SQL communication area
exec sql include SQLCA;

// Main validation procedure
dcl-proc validateCustomerData;
  dcl-pi *n varchar(500) end-pi;
  
  dcl-s validationResult varchar(500);
  
  monitor;
    // Initialize
    clear errorMsg;
    isValid = *on;
    currentUser = %trim(%subst(%scan(' ': %str(%addr(_RTNPSN))) + 1: 10));
    currentTS = %timestamp();
    
    // Step 1: Insert into CUSTOMER_TEMP table
    exec sql
      INSERT INTO CUSTDATA.CUSTOMER_TEMP 
        (CUSTNAME, PHONE, EMAIL, ADDRESS, TAXID, STATUS, CREATED_TS, SOURCE_SYSTEM)
      VALUES 
        (:custName, :phone, :email, :address, :taxId, 'P', :currentTS, 'WEB_API');
    
    if sqlcode < 0;
      validationResult = 'ERROR: Failed to create temporary record - ' + 
                        %trim(%str(sqlstate));
      return validationResult;
    endif;
    
    // Get the temp ID for tracking
    exec sql
      SELECT TEMPID INTO :tempId 
      FROM CUSTDATA.CUSTOMER_TEMP 
      WHERE TAXID = :taxId AND STATUS = 'P'
      ORDER BY CREATED_TS DESC
      FETCH FIRST 1 ROW ONLY;
    
    // Step 2: Validate each field
    if not validateName(custName);
      isValid = *off;
    endif;
    
    if not validatePhone(phone);
      isValid = *off;
    endif;
    
    if not validateEmail(email);
      isValid = *off;
    endif;
    
    if not validateAddress(address);
      isValid = *off;
    endif;
    
    if not validateTaxId(taxId);
      isValid = *off;
    endif;
    
    // Step 3: Check for duplicate Tax ID (only if basic validation passed)
    if isValid;
      if checkDuplicateTaxId(taxId);
        isValid = *off;
        errorMsg += 'Tax ID already exists in database. ';
      endif;
    endif;
    
    // Step 4: Process based on validation result
    if isValid;
      validationResult = processValidCustomer();
    else;
      validationResult = processInvalidCustomer();
    endif;
    
  on-error;
    validationResult = 'SYSTEM ERROR: ' + %trim(%str(%error()));
    
    // Log the system error
    logCustomerAction('ERROR': %trim(%str(%error())));
  endmon;
  
  return validationResult;
end-proc;

// Validate customer name
dcl-proc validateName;
  dcl-pi *n ind;
    name varchar(100) const;
  end-pi;
  
  dcl-s trimmedName varchar(100);
  dcl-s i int(10);
  dcl-s char char(1);
  
  trimmedName = %trim(name);
  
  // Check if empty
  if %len(trimmedName) = 0;
    errorMsg += 'Customer name is required. ';
    return *off;
  endif;
  
  // Check length
  if %len(trimmedName) < 2 or %len(trimmedName) > 100;
    errorMsg += 'Customer name must be 2-100 characters. ';
    return *off;
  endif;
  
  // Check for invalid characters (allow letters, spaces, hyphens, apostrophes)
  for i = 1 to %len(trimmedName);
    char = %subst(trimmedName: i: 1);
    if not ((%check('ABCDEFGHIJKLMNOPQRSTUVWXYZ': %upper(char)) = 0) or
            char = ' ' or char = '-' or char = '''');
      errorMsg += 'Customer name contains invalid characters. ';
      return *off;
    endif;
  endfor;
  
  return *on;
end-proc;

// Validate phone number
dcl-proc validatePhone;
  dcl-pi *n ind;
    phoneNum varchar(20) const;
  end-pi;
  
  dcl-s cleanPhone varchar(20);
  dcl-s i int(10);
  dcl-s char char(1);
  dcl-s digitCount int(10);
  
  if %len(%trim(phoneNum)) = 0;
    return *on; // Phone is optional
  endif;
  
  cleanPhone = %trim(phoneNum);
  digitCount = 0;
  
  // Count digits and check for valid characters
  for i = 1 to %len(cleanPhone);
    char = %subst(cleanPhone: i: 1);
    if %check('0123456789': char) = 0;
      digitCount += 1;
    elseif not (char = ' ' or char = '-' or char = '(' or char = ')' or char = '+');
      errorMsg += 'Phone number contains invalid characters. ';
      return *off;
    endif;
  endfor;
  
  // Must have at least 10 digits
  if digitCount < 10;
    errorMsg += 'Phone number must contain at least 10 digits. ';
    return *off;
  endif;
  
  return *on;
end-proc;

// Validate email address
dcl-proc validateEmail;
  dcl-pi *n ind;
    emailAddr varchar(100) const;
  end-pi;
  
  dcl-s trimmedEmail varchar(100);
  dcl-s atPos int(10);
  dcl-s dotPos int(10);
  
  if %len(%trim(emailAddr)) = 0;
    return *on; // Email is optional
  endif;
  
  trimmedEmail = %trim(emailAddr);
  
  // Check length
  if %len(trimmedEmail) > 100;
    errorMsg += 'Email address too long (max 100 characters). ';
    return *off;
  endif;
  
  // Must contain @ symbol
  atPos = %scan('@': trimmedEmail);
  if atPos = 0;
    errorMsg += 'Email address must contain @ symbol. ';
    return *off;
  endif;
  
  // Must have domain part with at least one dot
  dotPos = %scan('.': trimmedEmail: atPos);
  if dotPos = 0 or dotPos = %len(trimmedEmail);
    errorMsg += 'Email address must have valid domain. ';
    return *off;
  endif;
  
  // Basic format check - must have characters before @, between @ and ., and after .
  if atPos = 1 or (dotPos - atPos) <= 1 or (atPos > 1 and dotPos > atPos);
    // More detailed validation could be added here
    return *on;
  else;
    errorMsg += 'Invalid email address format. ';
    return *off;
  endif;
  
  return *on;
end-proc;

// Validate address
dcl-proc validateAddress;
  dcl-pi *n ind;
    addr varchar(255) const;
  end-pi;
  
  dcl-s trimmedAddr varchar(255);
  
  trimmedAddr = %trim(addr);
  
  // Check if empty
  if %len(trimmedAddr) = 0;
    errorMsg += 'Address is required. ';
    return *off;
  endif;
  
  // Check minimum length
  if %len(trimmedAddr) < 5;
    errorMsg += 'Address must be at least 5 characters. ';
    return *off;
  endif;
  
  // Check maximum length
  if %len(trimmedAddr) > 255;
    errorMsg += 'Address too long (max 255 characters). ';
    return *off;
  endif;
  
  return *on;
end-proc;

// Validate Tax ID
dcl-proc validateTaxId;
  dcl-pi *n ind;
    taxIdNum char(11) const;
  end-pi;
  
  dcl-s i int(10);
  dcl-s char char(1);
  
  // Check length
  if %len(%trim(taxIdNum)) <> 11;
    errorMsg += 'Tax ID must be exactly 11 characters. ';
    return *off;
  endif;
  
  // Check that all characters are digits
  for i = 1 to 11;
    char = %subst(taxIdNum: i: 1);
    if %check('0123456789': char) <> 0;
      errorMsg += 'Tax ID must contain only digits. ';
      return *off;
    endif;
  endfor;
  
  return *on;
end-proc;

// Check for duplicate Tax ID
dcl-proc checkDuplicateTaxId;
  dcl-pi *n ind;
    taxIdNum char(11) const;
  end-pi;
  
  dcl-s count int(10);
  
  exec sql
    SELECT COUNT(*) INTO :count
    FROM CUSTDATA.CUSTOMER
    WHERE TAXID = :taxIdNum;
  
  if sqlcode = 0 and count > 0;
    return *on; // Duplicate found
  endif;
  
  return *off; // No duplicate
end-proc;

// Process valid customer data
dcl-proc processValidCustomer;
  dcl-pi *n varchar(500) end-pi;
  
  dcl-s newCustId int(10);
  dcl-s successMsg varchar(500);
  
  monitor;
    // Insert into main CUSTOMER table
    exec sql
      INSERT INTO CUSTDATA.CUSTOMER 
        (CUSTNAME, PHONE, EMAIL, ADDRESS, TAXID, CREATED_TS, UPDATED_TS, 
         CREATED_BY, UPDATED_BY)
      VALUES 
        (:custName, :phone, :email, :address, :taxId, :currentTS, :currentTS,
         :currentUser, :currentUser);
    
    if sqlcode < 0;
      return 'ERROR: Failed to insert customer record - ' + %trim(%str(sqlstate));
    endif;
    
    // Get the new customer ID
    exec sql
      SELECT CUSTID INTO :newCustId
      FROM CUSTDATA.CUSTOMER
      WHERE TAXID = :taxId;
    
    // Update CUSTOMER_TEMP status to Valid
    exec sql
      UPDATE CUSTDATA.CUSTOMER_TEMP
      SET STATUS = 'V', 
          PROCESSED_TS = :currentTS,
          PROCESSED_BY = :currentUser
      WHERE TEMPID = :tempId;
    
    // Log successful action
    logCustomerAction('INSERT': 'Customer successfully created with ID: ' + 
                     %trim(%char(newCustId)));
    
    successMsg = 'SUCCESS: Customer information validated and saved successfully. ' +
                'Customer ID: ' + %trim(%char(newCustId));
    
    return successMsg;
    
  on-error;
    return 'ERROR: Failed to process valid customer - ' + %trim(%str(%error()));
  endmon;
  
end-proc;

// Process invalid customer data  
dcl-proc processInvalidCustomer;
  dcl-pi *n varchar(500) end-pi;
  
  monitor;
    // Update CUSTOMER_TEMP with error message
    exec sql
      UPDATE CUSTDATA.CUSTOMER_TEMP
      SET STATUS = 'E',
          ERROR_MSG = :errorMsg,
          PROCESSED_TS = :currentTS,
          PROCESSED_BY = :currentUser
      WHERE TEMPID = :tempId;
    
    // Log validation failure
    logCustomerAction('VALIDATE': 'Validation failed: ' + %trim(errorMsg));
    
    return 'VALIDATION_ERROR: ' + %trim(errorMsg);
    
  on-error;
    return 'ERROR: Failed to process invalid customer - ' + %trim(%str(%error()));
  endmon;
  
end-proc;

// Log customer action to audit table
dcl-proc logCustomerAction;
  dcl-pi *n;
    action varchar(50) const;
    description varchar(200) const;
  end-pi;
  
  dcl-s newValues varchar(1000);
  
  // Build new values string
  newValues = 'Name: ' + %trim(custName) + 
              ', Phone: ' + %trim(phone) +
              ', Email: ' + %trim(email) +
              ', Address: ' + %trim(address) +
              ', TaxID: ' + %trim(taxId);
  
  exec sql
    INSERT INTO CUSTLOG.CUSTOMER_LOG
      (TEMPID, ACTION, NEW_VALUES, USER_ID, LOG_TS, PROGRAM_NAME, 
       SUCCESS_FLAG, ERROR_DESC)
    VALUES
      (:tempId, :action, :newValues, :currentUser, :currentTS, 'MUSTVALID',
       CASE WHEN :action = 'ERROR' THEN 'N' ELSE 'Y' END, :description);

end-proc;

// Main program execution
result = validateCustomerData();

*inlr = *on; 