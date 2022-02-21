/*

SQL CLEANING PROJECT

Skills used: String functions, Database functions (CREATE, ALTER, DROP), Temp Tables, CTEs, Joins, Convert datatypes, Case, Like, Partition By.

*/
-------------------------------------------------------------------------------------------------------------------------------

-- Explore dataset

select *
from Holiday_Package;

-- Let's break out PRODUCT into individual columns (product number and product name).

select Product
from Holiday_Package;

select SUBSTRING(Product,1,CHARINDEX('/',Product)-1) as Product_Number
from Holiday_Package;
select SUBSTRING(Product,CHARINDEX('/',Product)+1,LEN(Product)) as Product_Name
from Holiday_Package;

ALTER TABLE Holiday_Package
ADD Product_Number NVARCHAR(255); 

UPDATE Holiday_Package
SET Product_Number = SUBSTRING(Product,1,CHARINDEX('/',Product)-1);

ALTER TABLE Holiday_Package
ADD Product_Name NVARCHAR(255); 

UPDATE Holiday_Package
SET Product_Name = SUBSTRING(Product,CHARINDEX('/',Product)+1,LEN(Product));

-------------------------------------------------------------------------------------------------------------------------------

-- Let's break out LOCATION_OF_TRAVEL into Country_of_travel and City_of_travel. 

select SUBSTRING(Location_of_Travel,1,CHARINDEX(',',Location_of_Travel)-1)
from Holiday_Package;

select SUBSTRING(Location_of_Travel,CHARINDEX(',',Location_of_Travel)+1,LEN(Location_of_Travel))
from Holiday_Package;

ALTER TABLE Holiday_Package
ADD Country_of_travel NVARCHAR(255);

UPDATE Holiday_Package
SET Country_of_travel = SUBSTRING(Location_of_Travel,1,CHARINDEX(',',Location_of_Travel)-1);

ALTER TABLE Holiday_Package
ADD City_of_travel NVARCHAR(255);

UPDATE Holiday_Package
SET City_of_travel = SUBSTRING(Location_of_Travel,CHARINDEX(',',Location_of_Travel)+1,LEN(Location_of_Travel));

-------------------------------------------------------------------------------------------------------------------------------

-- Let's fill in the blanks in City by creating a TEMP TABLE with the unique destinations.

select *
from Holiday_Package;

DROP TABLE IF exists #UniqueDestinations
CREATE TABLE #UniqueDestinations (
UniqueCountry nvarchar(255),
UniqueCity nvarchar(255));

INSERT INTO #UniqueDestinations
select distinct Country_of_travel, City_of_travel
from Holiday_Package
where LEN(City_of_travel)!=0;

select *
from #UniqueDestinations;

select Country_of_travel, City_of_travel, UniqueCity
from Holiday_Package
left join #UniqueDestinations
on Country_of_travel = UniqueCountry;

UPDATE Holiday_Package
SET City_of_travel = UniqueCity
from Holiday_Package
left join #UniqueDestinations
on Country_of_travel = UniqueCountry;

--Test
select City_of_travel
from Holiday_Package
where LEN(City_of_travel)=0;

-------------------------------------------------------------------------------------------------------------------------------

-- Let's convert Age_Seller from decimal to integers.

select Age_Seller
from Holiday_Package;

select CONVERT(int,Age_Seller)
from Holiday_Package;

UPDATE Holiday_Package
SET Age_Seller = CONVERT(int,Age_Seller);

-- If it doesn't update properly.

ALTER TABLE Holiday_Package
ADD Age_Seller_edited int;

UPDATE Holiday_Package
set Age_Seller_edited = CONVERT(int,Age_Seller);

-------------------------------------------------------------------------------------------------------------------------------

-- Let's standarize Date_of_Travel format and separate it into different columns as Day, Month and Year

select Date_of_travel
from Holiday_Package;

select CAST(Date_of_travel AS date)
from Holiday_Package;

ALTER TABLE Holiday_Package
ADD Date_of_travel_Edited date;

UPDATE Holiday_Package
SET Date_of_travel_Edited = CAST(Date_of_travel AS date);

select Date_of_travel_Edited
from Holiday_Package;

select Date_of_travel_Edited, DAY(Date_of_travel_Edited) Day, MONTH(Date_of_travel_Edited) Month, YEAR(Date_of_travel_Edited) Year
from Holiday_Package;

ALTER TABLE Holiday_Package
ADD Day_of_travel int, Month_of_travel int, Year_of_travel int;

UPDATE Holiday_Package
SET Day_of_travel = DAY(Date_of_travel_Edited),
    Month_of_travel = MONTH(Date_of_travel_Edited),
	Year_of_travel = YEAR(Date_of_travel_Edited);

-------------------------------------------------------------------------------------------------------------------------------

-- Let's standarize column PROD_TAKEN with 1 and 0 instead of "YES" and "NO".  

select distinct Prod_Taken, COUNT(Prod_Taken)
from Holiday_Package
group by Prod_Taken;

select Prod_Taken, 
	case when Prod_Taken='NO' then 0
		 when Prod_Taken='YES' then 1 
		 else Prod_Taken
		 END
from Holiday_Package;

UPDATE Holiday_Package
SET Prod_Taken = case when Prod_Taken='NO' then 0
		 when Prod_Taken='YES' then 1 
		 else Prod_Taken
		 END;

-------------------------------------------------------------------------------------------------------------------------------

-- Let's correct the words in the column Type_of_Contact.

select distinct Type_of_Contact
from Holiday_Package
order by 1;

select Type_of_Contact,
	case when Type_of_Contact like 'Sel%' then 'Self Enquiry'
		 when Type_of_Contact like 'Com%' then 'Company Invited'
		 end
from Holiday_Package;

UPDATE Holiday_Package
SET Type_of_Contact = case when Type_of_Contact like 'Sel%' then 'Self Enquiry'
		 when Type_of_Contact like 'Com%' then 'Company Invited'
		 end;

-------------------------------------------------------------------------------------------------------------------------------

-- Let's convert the Last_name_Seller into uppercase and eliminate white spaces.

select Last_name_Seller
from Holiday_Package;

select Last_name_Seller, UPPER(TRIM(Last_name_Seller))
from Holiday_Package;

UPDATE Holiday_Package
SET Last_name_Seller = UPPER(TRIM(Last_name_Seller));


-------------------------------------------------------------------------------------------------------------------------------

-- Let's remove duplicates in a CTE so to not affect our raw data.

WITH ROW_NUM_CTE AS(
select *, ROW_NUMBER() over(
	partition by ID_Travel,
	Product,
	Cost,
	Location_of_Travel,
	Date_of_travel,
	Number_Of_persons
	order by ID_Travel) as row_num
from Holiday_Package)

DELETE
from ROW_NUM_CTE
where row_num >1;

-------------------------------------------------------------------------------------------------------------------------------

-- Let's drop unused columns.

select *
from Holiday_Package;

ALTER TABLE Holiday_Package
DROP COLUMN Product, Location_of_Travel, Age_Seller, Date_of_travel;






-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
