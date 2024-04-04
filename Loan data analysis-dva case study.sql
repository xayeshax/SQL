--Create a new database (named Loans) in SQL Server 
Create database Loans
-----------------------------------------------------------------------------------------------------------------------------
--import file
Select*from Banker_Data
Select*from Customer_Data
Select*from Home_Loan_Data
Select*from Loan_Records_Data
------------------------------------------------------------------------------------------------------------------------------
--Write a query to print all the databases available in the SQL Server. 
Select name FROM master.sys.databases
--------------------------------------------------------------------------------------------------------------------------------
--Write a query to print the names of the tables from the Loans database.

Select TABLE_NAME from INFORMATION_SCHEMA.TABLES
-------------------------------------------------------------------------------------------------------------------------------------
--Write a query to print 5 records in each table 
Select top 5 *from Banker_Data
Select top 5 *from Customer_Data
Select top 5 *from Home_Loan_Data
Select top 5 *from Loan_Records_Data

---------------------------------------------------------------------------------------------------------------------------
/*Q. Find the maximum property value (using appropriate alias) of each property type, ordered by the maximum property 
valuein descending order.*/

Select property_type, max(property_value) as max_property_value
from Home_Loan_Data
Group by property_type
Order by max_property_value desc
----------------------------------------------------------------------------------------------------------------------
/*Q. Find the city name and the corresponding average property value (using appropriate alias) for cities where the
averageproperty value is greater than $3,000,000.*/ 
Select city,avg( property_value) as avg_property_value
From Home_Loan_Data
Group by city
Having avg(property_value)>3000000
------------------------------------------------------------------------------------------------------------------------------------
/*Q. Find the ID, first name, and last name of the top 2 bankers (and corresponding transaction count) involved in the
highest number of distinct loan records*/
Select top 2 b.banker_id,first_name,last_name,count(loan_Id) as no_Transaction
From Banker_Data as b
 join
Loan_Records_Data as l
on b.banker_id=l.banker_id
Group by b.banker_id,first_name,last_name
Order by no_Transaction desc
---------------------------------------------------------------------------------------------------------------------------------
--Q. Find the number of home loans issued in San Francisco.

Select city,COUNT(loan_id) as No_Loan_issued
From Home_Loan_Data
where city='san francisco'
Group by city
---------------------------------------------------------------------------------------------------------------------------------
/*Q. Find the average loan term for loans not for semi-detached and townhome property types, and are in the following list
of cities: Sparks, Biloxi, Waco, Las Vegas, and Lansing.*/
Select avg(loan_term) as avg_loan_term
from Home_Loan_Data
Where  property_type <>'Semi-detached'
        and property_type<>'townhome'
   and city IN ('Sparks','Biloxi','Waco','Las vegas','Lansing')

-----------------------------------------------------------------------------------------------------------------------------------
/*Q. Find the average age (at the point of loan transaction, in years and nearest integer) of female customers 
who took a non-joint loan for townhomes.*/

select Avg(datediff(Year,dob,transaction_date)) as Femlae_avg_age
From Customer_Data as c
Join 
Loan_Records_Data as l
On c.customer_id=l.customer_id
join
Home_Loan_Data as h
On l.loan_id=h.loan_id
Where gender='female'
---------------------------------------------------------------------------------------------------------------------------------
/*Q. Find the names of the top 3 cities (based on descending alphabetical order) and corresponding loan percent 
(in ascending order) with the lowest average loan percent. */

Select top 3 city ,avg(loan_percent) as avg_loan_percent
from Home_Loan_Data
Group by city
order by city desc, avg_loan_percent asc
----------------------------------------------------------------------------------------------------------------------------------
--Q. Find the customer ID, first name, last name, and email of customers whose email address contains the term 'amazon'.
Select customer_id,first_name, last_name, email
From Customer_Data
Where email like '%amazon%'
---------------------------------------------------------------------------------------------------------------------------------
--Q. Find the average age of male bankers (years, rounded to 1 decimal place) based on the date they joined WBG 
Select Round(Avg(DATEDIFF(YEAR, dob, date_joined)), 1) AS avg_age
from Banker_Data
Where gender = 'Male'
---------------------------------------------------------------------------------------------------------------------------------
--Q. Find the total number of different cities for which home loans have been issued.
Select Count(distinct city ) as total_city
From Home_Loan_Data
------------------------------------------------------------------------------------------------------------------------------------
/*Q. Find the top 3 transaction dates (and corresponding loan amount sum) for which the sum of loan amount issued on that
date is the highest. */
Select top 3 transaction_date,Sum(loan_percent*property_value/100) as total_loan_amount
From Loan_Records_Data as L
Join Home_Loan_Data as H 
On L.loan_id=H.loan_id
Group by transaction_date
order by total_loan_amount desc

-----------------------------------------------------------------------------------------------------------------------------
/*Q. Create a view called `dallas_townhomes_gte_1m` which returns all the details of loans involving properties of
townhome type, located in Dallas, and have loan amount of >$1 million. */

Create view dallas_townhomes_gte_1m
As 

  Select*, property_value*loan_percent/100 as loan_amount 
  From Home_Loan_Data
  Where property_type='townhome'
  and city='Dallas'
  and property_value*loan_percent/100 >1000000
  
  Select*From dallas_townhomes_gte_1m
	  
----------------------------------------------------------------------------------------------------------------------------------	 
/*Q. Create a stored procedure called `recent_joiners` that returns the ID, concatenated full name, date of birth,
and join date of bankers who joined within the recent 2 years (as of 1 Sep 2022).
Call the stored procedure `recent_joiners` you created above */
CREATE PROCEDURE recent_joiners
AS
BEGIN
    DECLARE @current_date DATETIME = '2022-09-01'

    SELECT banker_id,CONCAT(first_name, ' ', last_name) AS full_name,dob,date_joined
    FROM Banker_Data
    WHERE
        date_joined >= DATEADD(YEAR, -2, @current_date)
END

Exec recent_joiners
-------------------------------------------------------------------------------------------------------------------------------
/*Q. Create a stored procedure called `city_and_above_loan_amt` that takes in two parameters (city_name, loan_amt_cutoff)
that returns the full details of customers with loans for properties in the input city and with loan amount greater than 
or equal to the input loan amount cutoff.  
Call the stored procedure `city_and_above_loan_amt` you created above, based on the city San Francisco and 
loan amount cutoff of $1.5 million  */


CREATE PROCEDURE city_and_above_loan_amt
    @city_name NVARCHAR(255),
    @loan_amt_cutoff DECIMAL(18, 2)
AS
BEGIN
    SELECT *,property_value*loan_percent/100 as loan_amount
    FROM Home_Loan_Data
    WHERE
        city = @city_name
        AND property_value*loan_percent/100 >= @loan_amt_cutoff
END


EXEC city_and_above_loan_amt @city_name = 'San Francisco', @loan_amt_cutoff = 1500000;

--------------------------------------------------------------------------------------------------------------------------------
/*Q.Find the number of Chinese customers with joint loans with property values less than $2.1 million,
and served by female bankers. */

Select count(c.customer_id) total_customer 
    From  Customer_Data as c
	 join Loan_Records_Data as l
     on c.customer_id=l.customer_id
     join Banker_Data as b
     on l.banker_id=b.banker_id
	 join Home_Loan_Data as h
	 On l.loan_id=h.loan_id
     Where property_value<2100000
      and joint_loan>0
      and b.gender='Female'
      and c.nationality='china'

 -------------------------------------------------------------------------------------------------------------------------------
/* Q. Find the ID and full name (first name concatenated with last name) of customers who were served by bankers aged
below 30 (as of 1 Aug 2022). */
Select c.customer_id,concat(c.first_name,'',c.last_name) as customer_full_name
from Customer_Data as c
join Loan_Records_Data as l
On c.customer_id=l.customer_id
join Banker_Data as b
On l.banker_id=b.banker_id
Where DATEDIFF(year,b.dob,'2022-08-1')<30
---------------------------------------------------------------------------------------------------------------------------------
/*Q. Find the ID, first name and last name of customers with properties of value between $1.5 and $1.9 million,
along with a new column 'tenure' that categorizes how long the customer has been with WBG. 
The 'tenure' column is based on the following logic:
Long: Joined before 1 Jan 2015
Mid: Joined on or after 1 Jan 2015, but before 1 Jan 2019
Short: Joined on or after 1 Jan 2019*/

Select c.customer_id,first_name, last_name,property_value, 
case when customer_since<'2015-01-01' then 'Long'
     when customer_since >='2015-01-01' and customer_since<'2019-01-01' then 'Mid'
	 When customer_since >= '2019-01-01' Then 'Short'
End as tenure
from Customer_Data as c
join Loan_Records_Data as l 
On c.customer_id=l.customer_id
Join Home_Loan_Data as h 
On l.loan_id=h.loan_id
Where property_value between 1500000 and 1900000
-----------------------------------------------------------------------------------------------------------------------------------

--Q. Find the number of bankers involved in loans where the loan amount is greater than the average loan amount.     
alter table home_loan_data
add loan_amount float
update Home_Loan_Data
set loan_amount=property_value*loan_percent/100
SELECT COUNT(DISTINCT b.Banker_ID) AS num_bankers_involved
FROM Banker_Data as b
JOIN Loan_Records_Data as l
On b.banker_id=l.banker_id
join Home_Loan_Data as h
ON l.loan_id = h.loan_id
WHERE loan_amount> (SELECT AVG(loan_amount) FROM Home_Loan_Data)
------------------------------------------------------------------------------------------------------------------
/*Q. Find the sum of the loan amounts ((i.e., property value x loan percent / 100) for each banker ID, excluding 
properties based in the cities of Dallas and Waco. The sum values should be rounded to nearest integer. */
SELECT b.banker_id,Round(sum(loan_amount),0) as Tot_loan_amount
FROM Banker_Data as b
JOIN Loan_Records_Data as l
On b.banker_id=l.banker_id
join Home_Loan_Data as h
ON l.loan_id = h.loan_id
Where city not in ('Dallas','Waco')
Group by b.banker_id
