# SQL_Database_Programming
SQL programming assignments for database course completion. The repository contains solved tasks covering functions, procedures, and triggers with validation logic. Based on the Northwind database and custom tables.

# Database Programming Assignment – SQL Tasks

This repository contains a collection of SQL programming assignments completed as part of a **Database Programming course**.  
The tasks include writing and testing SQL **functions, stored procedures, and triggers**, with practical use cases such as data validation and database constraints.

## Features
- **User-defined functions**:
  - Palindrome checker
  - Sales value calculation (based on category & customer – Northwind DB)
  - Extracting customers by purchase month
  - PESEL number validation with error handling
- **Stored procedure**:
  - Adding new students with age validation (preventing underage entries)
- **Triggers**:
  - PESEL validation on client table insert/update
  - Preventing insertion of underage mothers in the `studenci` table

## Database Context
- Exercises partly based on the **Northwind database**
- Custom tables (`studenci`, `klienci`) created for validation tasks
- Use of Polish PESEL (national identification number) validation logic

## How it works
1. Functions perform text operations, numeric checks, and aggregation queries.  
2. Validation logic ensures correct PESEL numbers, proper birth dates, and prevents invalid gender/age entries.  
3. Triggers and stored procedures enforce **business rules** at the database level.  
4. Solutions can be reused in real-world database projects where **data consistency** is critical.

## Example Tasks
- Check if a string is a palindrome
- Return the total sales value for a given customer and product category
- Validate PESEL numbers (including edge cases)
- Enforce age restrictions in the `studenci` table

## Requirements
- Microsoft SQL Server or compatible SQL environment
- Northwind sample database (for sales-related tasks)

## Author
**Grzegorz Pieniak**  
Group 1 – Database Programming Course  
