**free
// ****************************************************************************
// Program: CUSTTERM
// Description: Customer Management Terminal Interface
// Author: Customer Update System
// Date: 2025
// 
// Purpose: Provides a classic terminal interface for customer management
//          with the same functionality as the web interface.
//
// Features:
//   - View all customers
//   - Add new customer
//   - Search customers
//   - Update customer information
//   - Delete customer
//
// Flow:
//   1. Display main menu
//   2. Process user selection
//   3. Perform requested operation
//   4. Return to main menu
// ****************************************************************************

ctl-opt nomain thread(*yes) decedit('0,') datfmt(*iso) timfmt(*hms);

// Program Interface
dcl-pi CUSTTERM export;
end-pi;

// Copy members for data structures
/copy CUSTLIB/QRPGCOPY,CUSTCOPY
/copy CUSTLIB/QRPGCOPY,LOGCOPY

// Global variables
dcl-s currentScreen char(10) inz('MAIN');
dcl-s userInput char(1);
dcl-s errorMsg varchar(100);
dcl-s successMsg varchar(100);
dcl-s currentUser char(10);
dcl-s currentTS timestamp;

// Customer data structure
dcl-ds customerData;
  custName varchar(100);
  phone varchar(20);
  email varchar(100);
  address varchar(255);
  taxId char(11);
  status char(1);
end-ds;

// SQL communication area
exec sql include SQLCA;

// Main procedure
dcl-proc main;
  dcl-pi *n end-pi;
  
  monitor;
    // Initialize
    currentUser = %trim(%subst(%scan(' ': %str(%addr(_RTNPSN))) + 1: 10));
    currentTS = %timestamp();
    
    // Main program loop
    dow '1';
      select;
        when currentScreen = 'MAIN';
          displayMainMenu();
        when currentScreen = 'LIST';
          displayCustomerList();
        when currentScreen = 'ADD';
          displayAddCustomer();
        when currentScreen = 'SEARCH';
          displaySearchCustomer();
        when currentScreen = 'UPDATE';
          displayUpdateCustomer();
        when currentScreen = 'DELETE';
          displayDeleteCustomer();
        other;
          currentScreen = 'MAIN';
      endsl;
    enddo;
    
  on-error;
    errorMsg = 'SYSTEM ERROR: ' + %trim(%str(%error()));
    logCustomerAction('ERROR': errorMsg);
    currentScreen = 'MAIN';
  endmon;
end-proc;

// Display main menu
dcl-proc displayMainMenu;
  dcl-pi *n end-pi;
  
  clear errorMsg;
  clear successMsg;
  
  // Display header
  dsply 'CUSTOMER MANAGEMENT SYSTEM' ' ';
  dsply '------------------------' ' ';
  dsply ' ' ' ';
  
  // Display menu options
  dsply '1. View All Customers' ' ';
  dsply '2. Add New Customer' ' ';
  dsply '3. Search Customers' ' ';
  dsply '4. Update Customer' ' ';
  dsply '5. Delete Customer' ' ';
  dsply '6. Exit' ' ';
  dsply ' ' ' ';
  
  // Display messages if any
  if %len(errorMsg) > 0;
    dsply errorMsg ' ';
  endif;
  if %len(successMsg) > 0;
    dsply successMsg ' ';
  endif;
  
  // Get user input
  dsply 'Enter option (1-6):' userInput;
  
  // Process selection
  select;
    when userInput = '1';
      currentScreen = 'LIST';
    when userInput = '2';
      currentScreen = 'ADD';
    when userInput = '3';
      currentScreen = 'SEARCH';
    when userInput = '4';
      currentScreen = 'UPDATE';
    when userInput = '5';
      currentScreen = 'DELETE';
    when userInput = '6';
      *inlr = *on;
    other;
      errorMsg = 'Invalid option selected';
  endsl;
end-proc;

// Display customer list
dcl-proc displayCustomerList;
  dcl-pi *n end-pi;
  
  dcl-s customerCount int(10);
  dcl-s pageSize int(10) inz(10);
  dcl-s currentPage int(10) inz(1);
  dcl-s totalPages int(10);
  
  // Get total count
  exec sql
    SELECT COUNT(*) INTO :customerCount
    FROM CUSTDATA.CUSTOMER;
  
  if customerCount = 0;
    dsply 'No customers found' ' ';
    currentScreen = 'MAIN';
    return;
  endif;
  
  // Calculate total pages
  totalPages = (customerCount + pageSize - 1) / pageSize;
  
  // Display header
  dsply 'CUSTOMER LISTING' ' ';
  dsply '----------------' ' ';
  dsply ' ' ' ';
  
  // Display customers for current page
  exec sql
    SELECT CUSTNAME, PHONE, EMAIL, TAXID, STATUS
    FROM CUSTDATA.CUSTOMER
    ORDER BY CUSTNAME
    LIMIT :pageSize
    OFFSET :((currentPage - 1) * pageSize);
  
  // Display navigation
  dsply ' ' ' ';
  dsply 'Page ' + %char(currentPage) + ' of ' + %char(totalPages) ' ';
  dsply ' ' ' ';
  dsply 'N - Next Page' ' ';
  dsply 'P - Previous Page' ' ';
  dsply 'M - Main Menu' ' ';
  
  // Get user input
  dsply 'Enter option:' userInput;
  
  // Process selection
  select;
    when %upper(userInput) = 'N';
      if currentPage < totalPages;
        currentPage += 1;
      else;
        errorMsg = 'Already on last page';
      endif;
    when %upper(userInput) = 'P';
      if currentPage > 1;
        currentPage -= 1;
      else;
        errorMsg = 'Already on first page';
      endif;
    when %upper(userInput) = 'M';
      currentScreen = 'MAIN';
    other;
      errorMsg = 'Invalid option selected';
  endsl;
end-proc;

// Display add customer screen
dcl-proc displayAddCustomer;
  dcl-pi *n end-pi;
  
  clear customerData;
  
  // Display header
  dsply 'ADD NEW CUSTOMER' ' ';
  dsply '----------------' ' ';
  dsply ' ' ' ';
  
  // Get customer information
  dsply 'Enter customer name:' customerData.custName;
  dsply 'Enter phone number:' customerData.phone;
  dsply 'Enter email address:' customerData.email;
  dsply 'Enter mailing address:' customerData.address;
  dsply 'Enter tax ID:' customerData.taxId;
  
  // Validate and save
  if validateCustomerData(customerData.custName: customerData.phone: 
                         customerData.email: customerData.address: 
                         customerData.taxId: errorMsg);
    // Insert into database
    exec sql
      INSERT INTO CUSTDATA.CUSTOMER 
        (CUSTNAME, PHONE, EMAIL, ADDRESS, TAXID, STATUS, CREATED_TS, CREATED_USER)
      VALUES 
        (:customerData.custName, :customerData.phone, :customerData.email,
         :customerData.address, :customerData.taxId, 'A', :currentTS, :currentUser);
    
    if sqlcode = 0;
      successMsg = 'Customer added successfully';
      logCustomerAction('ADD': 'Customer added: ' + customerData.custName);
    else;
      errorMsg = 'Failed to add customer: ' + %trim(%str(sqlstate));
    endif;
  endif;
  
  currentScreen = 'MAIN';
end-proc;

// Display search customer screen
dcl-proc displaySearchCustomer;
  dcl-pi *n end-pi;
  
  dcl-s searchTerm varchar(100);
  dcl-s searchType char(1);
  
  // Display header
  dsply 'SEARCH CUSTOMERS' ' ';
  dsply '----------------' ' ';
  dsply ' ' ' ';
  
  // Get search type
  dsply 'Search by:' ' ';
  dsply '1. Name' ' ';
  dsply '2. Tax ID' ' ';
  dsply '3. Phone' ' ';
  dsply '4. Email' ' ';
  dsply ' ' ' ';
  dsply 'Enter option (1-4):' searchType;
  
  // Get search term
  dsply 'Enter search term:' searchTerm;
  
  // Perform search based on type
  select;
    when searchType = '1';
      exec sql
        SELECT CUSTNAME, PHONE, EMAIL, TAXID, STATUS
        FROM CUSTDATA.CUSTOMER
        WHERE CUSTNAME LIKE '%' || :searchTerm || '%'
        ORDER BY CUSTNAME;
    when searchType = '2';
      exec sql
        SELECT CUSTNAME, PHONE, EMAIL, TAXID, STATUS
        FROM CUSTDATA.CUSTOMER
        WHERE TAXID = :searchTerm
        ORDER BY CUSTNAME;
    when searchType = '3';
      exec sql
        SELECT CUSTNAME, PHONE, EMAIL, TAXID, STATUS
        FROM CUSTDATA.CUSTOMER
        WHERE PHONE LIKE '%' || :searchTerm || '%'
        ORDER BY CUSTNAME;
    when searchType = '4';
      exec sql
        SELECT CUSTNAME, PHONE, EMAIL, TAXID, STATUS
        FROM CUSTDATA.CUSTOMER
        WHERE EMAIL LIKE '%' || :searchTerm || '%'
        ORDER BY CUSTNAME;
    other;
      errorMsg = 'Invalid search type selected';
  endsl;
  
  dsply ' ' ' ';
  dsply 'Press Enter to return to main menu' ' ';
  dsply ' ' userInput;
  
  currentScreen = 'MAIN';
end-proc;

// Display update customer screen
dcl-proc displayUpdateCustomer;
  dcl-pi *n end-pi;
  
  dcl-s taxId char(11);
  
  // Display header
  dsply 'UPDATE CUSTOMER' ' ';
  dsply '----------------' ' ';
  dsply ' ' ' ';
  
  // Get tax ID
  dsply 'Enter customer tax ID:' taxId;
  
  // Fetch customer data
  exec sql
    SELECT CUSTNAME, PHONE, EMAIL, ADDRESS, TAXID, STATUS
    INTO :customerData
    FROM CUSTDATA.CUSTOMER
    WHERE TAXID = :taxId;
  
  if sqlcode = 0;
    // Display current data
    dsply 'Current customer information:' ' ';
    dsply 'Name: ' + customerData.custName ' ';
    dsply 'Phone: ' + customerData.phone ' ';
    dsply 'Email: ' + customerData.email ' ';
    dsply 'Address: ' + customerData.address ' ';
    dsply ' ' ' ';
    
    // Get updated information
    dsply 'Enter new name (press Enter to keep current):' customerData.custName;
    dsply 'Enter new phone (press Enter to keep current):' customerData.phone;
    dsply 'Enter new email (press Enter to keep current):' customerData.email;
    dsply 'Enter new address (press Enter to keep current):' customerData.address;
    
    // Validate and update
    if validateCustomerData(customerData.custName: customerData.phone: 
                           customerData.email: customerData.address: 
                           customerData.taxId: errorMsg);
      // Update database
      exec sql
        UPDATE CUSTDATA.CUSTOMER
        SET CUSTNAME = :customerData.custName,
            PHONE = :customerData.phone,
            EMAIL = :customerData.email,
            ADDRESS = :customerData.address,
            UPDATED_TS = :currentTS,
            UPDATED_USER = :currentUser
        WHERE TAXID = :taxId;
      
      if sqlcode = 0;
        successMsg = 'Customer updated successfully';
        logCustomerAction('UPDATE': 'Customer updated: ' + customerData.custName);
      else;
        errorMsg = 'Failed to update customer: ' + %trim(%str(sqlstate));
      endif;
    endif;
  else;
    errorMsg = 'Customer not found';
  endif;
  
  currentScreen = 'MAIN';
end-proc;

// Display delete customer screen
dcl-proc displayDeleteCustomer;
  dcl-pi *n end-pi;
  
  dcl-s taxId char(11);
  dcl-s confirm char(1);
  
  // Display header
  dsply 'DELETE CUSTOMER' ' ';
  dsply '----------------' ' ';
  dsply ' ' ' ';
  
  // Get tax ID
  dsply 'Enter customer tax ID:' taxId;
  
  // Fetch customer data
  exec sql
    SELECT CUSTNAME, PHONE, EMAIL, ADDRESS, TAXID, STATUS
    INTO :customerData
    FROM CUSTDATA.CUSTOMER
    WHERE TAXID = :taxId;
  
  if sqlcode = 0;
    // Display customer information
    dsply 'Customer to be deleted:' ' ';
    dsply 'Name: ' + customerData.custName ' ';
    dsply 'Phone: ' + customerData.phone ' ';
    dsply 'Email: ' + customerData.email ' ';
    dsply 'Address: ' + customerData.address ' ';
    dsply ' ' ' ';
    
    // Confirm deletion
    dsply 'Are you sure you want to delete this customer? (Y/N):' confirm;
    
    if %upper(confirm) = 'Y';
      // Delete from database
      exec sql
        DELETE FROM CUSTDATA.CUSTOMER
        WHERE TAXID = :taxId;
      
      if sqlcode = 0;
        successMsg = 'Customer deleted successfully';
        logCustomerAction('DELETE': 'Customer deleted: ' + customerData.custName);
      else;
        errorMsg = 'Failed to delete customer: ' + %trim(%str(sqlstate));
      endif;
    endif;
  else;
    errorMsg = 'Customer not found';
  endif;
  
  currentScreen = 'MAIN';
end-proc;

// Main program entry point
*inlr = *on;
main();
