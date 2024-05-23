--*************************************************************************--
-- Title: Assignment06
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 22 May 2024,TM,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_YourNameHere')
	 Begin 
	  Alter Database [Assignment06DB_YourNameHere] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_YourNameHere;
	 End
	Create Database Assignment06DB_YourNameHere;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_YourNameHere;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.

Create View
	vCategories
With Schemabinding
As
	Select Top 1000000
		CategoryID
		, CategoryName
	From	
		dbo.Categories
	Order By
		CategoryName
go

Create View
	vProdcuts
With Schemabinding
As 
	Select Top 1000000
		CategoryID
		, ProductID
		, ProductName
		, UnitPrice
	From
		dbo.Products
	Order By
		CategoryID
go

Create View
	vEmployees
With Schemabinding
As
	Select Top 1000000
		EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
		, EmployeeID
		, ManagerID
	From	
		dbo.Employees
	Order by 
		EmployeeName
go
 

Create View
	vInventory
With Schemabinding
As
	Select Top 1000000
		InventoryDate
		, ProductID
		, Inventories.Count
		, EmployeeID
	From	
		dbo.Inventories
	Order by 
		InventoryDate
go

-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Deny Select On Categories To Public; 
Deny Select On Products To Public; 
Deny Select On Employees To Public; 
Deny Select On Inventories To Public; 
go

Grant Select On vCategories To Public; 
Grant Select On vProdcuts To Public; 
Grant Select On vEmployees To Public; 
Grant Select On vInventory To Public; 
go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 

Create View
	vProductCategory
As
Select Top 1000000
	C.CategoryName
	, P.ProductName
From
	vCategories as C join vProdcuts as P
on 
	C.CategoryID = P.CategoryID
order by 
	CategoryName
go

-- and the price of each product?
Create View
	vProductCategoryPrice
As
Select Top 1000000
	C.CategoryName
	, P.ProductName
	, P.UnitPrice
From
	vCategories as C join vProdcuts as P
on 
	C.CategoryID = P.CategoryID
order by 
	C.CategoryName
go

-- Order the result by the Category and Product!
Create View
	vProductCategoryPriceOrder
As
Select Top 1000000
	C.CategoryName
	, P.ProductName
	, P.UnitPrice
From
	vCategories as C join vProdcuts as P
on 
	C.CategoryID = P.CategoryID
order by 
	C.CategoryName
	, P.ProductName
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?

Create View
	vProductInventoryDateCount
As
Select Top 1000000
	I.InventoryDate
	, I.Count
	, P.ProductName
From	
	vProdcuts as P join vInventory as I
		on P.ProductID = I.ProductID
go


-- Order the results by the Product, Date, and Count!

Create View
	vProductInventoryDateCountOrder
As
Select Top 1000000
	I.InventoryDate
	, I.Count
	, P.ProductName
From	
	vProdcuts as P join vInventory as I
		on P.ProductID = I.ProductID
Order by
	3, 1, 2
go


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?

Create View
	vInventoriesByEmployee
As
Select Top 1000000
	I.InventoryDate
	, E.EmployeeName
From	
	vInventory as I join vEmployees as E
		on I.EmployeeID = E.EmployeeID
go


-- Order the results by the Date and return only one row per date!

Create View
	vInventoriesByEmployeeOrder
As
Select Distinct 
	I.InventoryDate
	, E.EmployeeName
From	
	vInventory as I join vEmployees as E
		on I.EmployeeID = E.EmployeeID
go
-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?

Create View
	vListCatProd
As
Select Top 1000000
	C.CategoryName
	, P.ProductName
	, I.InventoryDate
	, I.Count
	
From	
	vCategories as C join vProdcuts as P
		on C.CategoryID	= P.CategoryID
	join vInventory as I 
		on P.ProductID = I.ProductID
go


-- Order the results by the Category, Product, Date, and Count!
Create View
	vListCatProdOrd
As
Select Top 1000000
	C.CategoryName
	, P.ProductName
	, I.InventoryDate
	, I.Count
	
From	
	vCategories as C join vProdcuts as P
		on C.CategoryID	= P.CategoryID
	join vInventory as I 
		on P.ProductID = I.ProductID
Order By
	1, 2, 3, 4
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?

Create View
	vListCatProdEmp
As
Select Top 1000000
	C.CategoryName
	, P.ProductName
	, I.InventoryDate
	, I.Count
	, E.EmployeeName
	
From	
	vCategories as C join vProdcuts as P
		on C.CategoryID	= P.CategoryID
	join vInventory as I 
		on P.ProductID = I.ProductID
	join vEmployees as E
		on E.EmployeeID = I.EmployeeID
go
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View
	vListCatProdEmpOrd
As
Select Top 1000000
	C.CategoryName
	, P.ProductName
	, I.InventoryDate
	, I.Count
	, E.EmployeeName
	
From	
	vCategories as C join vProdcuts as P
		on C.CategoryID	= P.CategoryID
	join vInventory as I 
		on P.ProductID = I.ProductID
	join vEmployees as E
		on E.EmployeeID = I.EmployeeID
Order By
	1, 2, 3, 4, 5
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View
	vChaiChang
As
Select Top 1000000
	C.CategoryName
	, P.ProductName
	, I.InventoryDate
	, I.Count
	, E.EmployeeName
From	
	vCategories as C join vProdcuts as P
		on C.CategoryID	= P.CategoryID
	join vInventory as I 
		on P.ProductID = I.ProductID
	join vEmployees as E
		on E.EmployeeID = I.EmployeeID
	Where I.ProductID in (Select ProductID From vProdcuts Where ProductName in ('Chai', 'Chang'))
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create View
	vManagerEmployee
As 
Select Top 1000000
	M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager
	, E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee
From 
	Employees as E join Employees M
		on E.ManagerID = M.EmployeeID
Order by
	1,2
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

Create View 
	vAllBasic
As
Select Top 10000
	E.EmployeeName
	, I.InventoryDate
	, II.InventoryID
	, P.ProductName
	, C.CategoryName
From
	vEmployees as E join vInventory as I
		on E.EmployeeID = I.EmployeeID
	join vProdcuts as P 
		on I.ProductID = P.ProductID
	join vCategories as C
		on C.CategoryID = P.ProductID
	join Inventories as II
		on II.InventoryDate = I.InventoryDate
	Where I.ProductID in (Select ProductID from vProdcuts where ProductName in ('Chai', 'Chang'))
	Order by 4, 3, 1
go

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProdcuts]
Select * From [dbo].[vInventory]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductCategory]
Select * From [dbo].[vProductCategoryPrice]
Select * From [dbo].[vProductCategoryPriceOrder]
Select * From [dbo].[vProductInventoryDateCount]
Select * From [dbo].[vProductInventoryDateCountOrder]
Select * From [dbo].[vInventoriesByEmployee]
Select * From [dbo].[vInventoriesByEmployeeOrder]
Select * From [dbo].[vListCatProd]
Select * From [dbo].[vListCatProdOrd]
Select * From [dbo].[vListCatProdEmp]
Select * From [dbo].[vListCatProdEmpOrd]
Select * From [dbo].[vChaiChang]
Select * From [dbo].[vManagerEmployee]
Select * From [dbo].[vAllBasic]
/***************************************************************************************/