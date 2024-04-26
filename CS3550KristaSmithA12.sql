/* 1. Display the name of the department, day of the month the employee was hired and the total number of employees hired
per department for each day of the month. The days of the month should appear along the left hand side and the department 
names should appear across the headers
(Complete both Static and Dynamic Pivot Query)
*/

--------------------------------------------------------------------------
-- 1A Static Query DONE
--------------------------------------------------------------------------

SELECT 
DayHired, 
[Document Control],	[Engineering], [Executive], [Facilities and Maintenance], [Finance],
	[Human Resources], [Information Services], [Marketing], [Production], [Production Control],
	[Purchasing], [Quality Assurance], [Research and Development], [Sales], [Shipping and Receiving], [Tool Design]
FROM
(
SELECT 
	hrd.Name AS "DepartmentName"
	, DATEPART(dd, hre.HireDate) AS "DayHired"
	,(hre.BusinessEntityID) AS "NumEmployeesHired"
FROM HumanResources.Department hrd
INNER JOIN HumanResources.EmployeeDepartmentHistory hredh
	ON hredh.DepartmentID = hrd.DepartmentID
INNER JOIN HumanResources.Employee hre
	ON hre.BusinessEntityID = hredh.BusinessEntityID
 GROUP BY hrd.Name, DATEPART(dd, hre.HireDate), hre.BusinessEntityID
 ) dataTable
 PIVOT
 ( 
	COUNT(NumEmployeesHired)
	FOR  DepartmentName IN 
	([Document Control],	[Engineering], [Executive], [Facilities and Maintenance], [Finance],
	[Human Resources], [Information Services], [Marketing], [Production], [Production Control],
	[Purchasing], [Quality Assurance], [Research and Development], [Sales], [Shipping and Receiving], [Tool Design]
	)
	) AS PivotTable;


 -------------------------------------------------------------------
 -- 1B Dynamic Query DONE
 -------------------------------------------------------------------
DECLARE @columns1B NVARCHAR(MAX)
	, @sql1B NVARCHAR(MAX)
SET @columns1B = N'';
SELECT @columns1B += N', ' + QUOTENAME(name)
FROM HumanResources.Department AS t1;
SET @columns1B= STUFF(@columns1B, 1, 2, '');

SET @sql1B = N'SELECT DayHired, ' + @columns1B + 
'FROM
(
SELECT 
	hrd.Name AS "DepartmentName"
	, DATEPART(dd, hre.HireDate) AS "DayHired"
	,(hre.BusinessEntityID) AS "NumEmployeesHired"
FROM HumanResources.Department hrd
INNER JOIN HumanResources.EmployeeDepartmentHistory hredh
	ON hredh.DepartmentID = hrd.DepartmentID
INNER JOIN HumanResources.Employee hre
	ON hre.BusinessEntityID = hredh.BusinessEntityID
 GROUP BY hrd.Name, DATEPART(dd, hre.HireDate), hre.BusinessEntityID
 ) dataTable
 PIVOT
 ( 
	COUNT(NumEmployeesHired)
	FOR  DepartmentName IN (' + @columns1B
	+ ')) AS PivotTable';

EXECUTE sp_executesql @sql1B;

---------------------------------------------------------------------
-- 2A Static Pivot Table DONE
---------------------------------------------------------------------
/* 2)List the Scrap Reason Name, the day of the week for the Product Work Order Start Date and
the total of the Scrapped Quantity per Scrap Reason and Day of the Week. The Day of the Week 
should appear across the top in order with the Scrap Reason name on the left hand side of the table.
(Complete both Static and Dynamic Pivot Query) */

SELECT
ScrapReason,
[Sunday], 
[Monday],
[Tuesday],
[Wednesday],
[Thursday],
[Friday],
[Saturday]
FROM
(
SELECT psr.Name AS "ScrapReason"
	, DATENAME(dw, pwo.StartDate) AS "DayOfWeek"
	, pwo.ScrappedQty
FROM Production.ScrapReason psr
INNER JOIN Production.WorkOrder pwo
	ON pwo.ScrapReasonID = psr.ScrapReasonID
) dataTable2
PIVOT
(  SUM(ScrappedQty)
FOR [DayOfWeek]
IN (
[Sunday], 
[Monday],
[Tuesday],
[Wednesday],
[Thursday],
[Friday],
[Saturday]))PivotTable2
;

---------------------------------------------------------------------
-- 2B Dynamic Pivot Table DONE
---------------------------------------------------------------------

DECLARE @column2B NVARCHAR(MAX)
	, @sql2B NVARCHAR(MAX)
SET @column2B = '';
SELECT @column2B += N', ' + QUOTENAME(DayOfWeekName)
FROM
(
SELECT DISTINCT
DATENAME(dw, StartDate) AS DayOfWeekName
	, DATEPART(dw, StartDate) AS DayOfWeekNumeric
FROM Production.WorkOrder
) as t3
ORDER BY DayOfWeekNumeric;

SET @column2B= STUFF(@column2B, 1, 2, '');

PRINT @column2B;

SET @sql2B= N'
SELECT
ScrapReason,' + @column2B + '
FROM
(
SELECT psr.Name AS "ScrapReason"
	, DATENAME(dw, pwo.StartDate) AS "DayOfWeek"
	, pwo.ScrappedQty
FROM Production.ScrapReason psr
INNER JOIN Production.WorkOrder pwo
	ON pwo.ScrapReasonID = psr.ScrapReasonID
) dataTable2
PIVOT
(  SUM(ScrappedQty)
FOR [DayOfWeek]
IN (' + @column2B +'))PivotTable2';

EXECUTE sp_executesql @sql2B;