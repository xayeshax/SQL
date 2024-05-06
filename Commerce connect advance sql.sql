Create Database AdvanceSql
Select*From Supplier
Select*From [dbo].[Customer]
select*From Product

--1)List all the customer.
Select Concat(FirstName,' ',LastName) As Customer_Name
From [dbo].[Customer]

--2)List the first name,last name and City of all the customer.
Select FirstName,LastName,City
From [dbo].[Customer]

--3)List the customer in Sweden.
Select CONCAT(FirstName,' ',LastName) As CUST_NAME
From [dbo].[Customer]
Where Country='Sweden'

--4. Create a copy of Supplier table. Update the city to Sydney for supplier starting with letter P.
Select*From[dbo].[Supplier]
Select*into Supp2
From [dbo].[Supplier]
Select*From Supp2
Update Supp2 set City='Sydney'
where CompanyName like 'P%'

--5) Create a copy of Products table and Delete all products with unit price higher than $50.
Select*into Prod2
From [dbo].[Product]

select*from Prod2 
Delete From Prod2 
Where UnitPrice>50


--6. List the number of customers in each country
Select Country,COUNT(id)as Count_OF_CUST
From [dbo].[Customer]
Group by Country

--7. List the number of customers in each country sorted high to low
Select Country,COUNT(id)as Count_OF_CUST
From [dbo].[Customer]
Group by Country
Order by Count_OF_CUST desc

--8. List the total amount for items ordered by each customer
select*from[dbo].[Orders]

Select CustomerId,Sum(TotalAmount) as ToT_Amt
From [dbo].[Orders]
Group By CustomerId

--9. List the number of customers in each country. Only include countries with more than 10 customers.
Select Country,COUNT(id)as Count_OF_CUST
From [dbo].[Customer]
Group by Country
having COUNT(id)>10

---10. List the number of customers in each country, except the USA, sorted high to low. Only include countries with 9 or more customers.
Select*from Customer
Select Country,COUNT(id)as Count_OF_CUST
From [dbo].[Customer]
Where Country<>'USA'
Group by Country
having COUNT(id)>=9
Order by Count_OF_CUST desc

--11. List all customers whose first name or last name contains "ill".
Select Concat(FirstName,' ',Lastname) as Cust_NAme
From[dbo].[Customer]
Where FirstName like '%ill%' or LastName Like  '%ill%' 

--12. List all customers whose average of their total order amount is between $1000 and $1200.Limit your output to 5 results.
select*from[dbo].[Orders]
Select Top 5 *from(
Select CustomerID,AVG(TotalAmount) as Avg_Amount
From Orders
Group by CustomerId
Having Avg(TotalAmount) Between 1000 And 2000) As X
Order by Avg_Amount 

--13. List all suppliers in the 'USA', 'Japan', and 'Germany', ordered by country from A-Z, and then by company name in reverse order.
Select*From[dbo].[Supplier]
Select CompanyName,Country
From Supplier
Where Country In ('USA','Japan','Germany')
Order by Country,CompanyName Desc


--14. Show all orders, sorted by total amount (the largest amount first), within each year.
Select*From[dbo].[Orders]
Alter table [dbo].[Orders]
Alter Column OrderDate Date
select Id,Year(OrderDate) as OrderYear,TotalAmount
From Orders
Order By Year(OrderDate),TotalAmount Desc


/*15. Products with UnitPrice greater than 50 are not selling despite promotions. You are asked to discontinue products over $25.
  Write a query to relfelct this. Do this in the copy of the Product table. DO NOT perform the update operation in the Product table..*/
  Select*from[dbo].[Prod2]
  Update Prod2 set IsDiscontinued=1
  Where UnitPrice>25

--16. List top 10 most expensive products
Select Top 10 ProductName,UnitPrice
From Product
Order by UnitPrice Desc


--17. Get all but the 10 most expensive products sorted by price
Select Productname,UnitPrice
From (Select*,ROW_NUMBER() over(Order by UnitPrice) as Ranks From Product ) as X
Where Ranks>10
--------------------------------------------------------
Select  ProductName,UnitPrice
From Product
Order by UnitPrice Desc
offset 10 rows

--18. Get the 10th to 15th most expensive products sorted by price
Select Productname,UnitPrice
From (Select*,ROW_NUMBER() over(Order by UnitPrice) as Ranks From Product ) as X
Where Ranks in (10,15)
---------------------------------------------
Select  ProductName,UnitPrice
From Product
Order by UnitPrice Desc
offset 9 rows
Fetch next 6 rows only

--19. Write a query to get the number of supplier countries. Do not count duplicate values.
Select*from[dbo].[Supplier]
Select Count(distinct(Country)) As COUNT_OF_SUPPLIER_COUNTRY
From Supplier

--20. Find the total sales cost in each month of the year 2013.
Select*from[dbo].[Orders]
Select MONTH(OrderDate) as Months,SUM(TotalAmount) as Sales
From Orders
Where YEAR(OrderDate)=2013
Group by Month(OrderDate)

--21. List all products with names that start with 'Ca'.
select*from[dbo].[Product]
Select ProductName
From Product
Where ProductName Like 'Ca%'

--22. List all products that start with 'Cha' or 'Chan' and have one more character.
Select ProductName
From Product  
Where ProductName Like 'cha_'
         Or 
ProductName Like'Chan_'

/*23. Your manager notices there are some suppliers without fax numbers. He seeks your help to get a list of suppliers with remark as "No fax number" 
for suppliers who do not have fax numbers (fax numbers might be null or blank).Also, Fax number should be displayed for customer with fax numbers.*/
Select*From[dbo].[Supplier]
Update Supplier Set Fax='No _Fax_Number'--(use case when then else end)
Where Fax =''   ---(use is null or len(fax)=0 instead of '')

--24. List all orders, their orderDates with product names, quantities, and prices.
Select*from[dbo].[Orders]
Select*from[dbo].[OrderItem]
select*From[dbo].[Product]
Select Orders.Id,OrderDate,Productname,OrderItem.Quantity,OrderItem.unitprice
From Orders
Inner Join Orderitem
On orders.id=orderitem.Orderid
Inner Join Product
On Orderitem.productid=product.id

--25. List all customers who have not placed any Orders.

Select id From Customer
except 
select CustomerId From Orders

/*26. List suppliers that have no customers in their country, and customers that have no suppliers in their country, and customers and suppliers
that are from the same country.*/
Select*from Customer
Select*From Supplier
Select*From Orders
Select*From OrderItem
Select*from Product
Select FirstName,LastName,Customer.Country, CompanyName,Supplier.Country
From Supplier
Full join Customer
On Supplier.Country=Customer.country
where Customer.country is Null
Union all
Select FirstName,LastName,Customer.Country, CompanyName,Supplier.Country
From Customer
Full join Supplier
On Supplier.Country=Customer.country
where Supplier.Country Is null
Union all
Select FirstName,LastName,Customer.Country, CompanyName,Supplier.Country
From Supplier
Inner join Customer
On Supplier.Country=Customer.country
----------------------------------------------------
Select FirstName,LastName,Customer.Country, CompanyName,Supplier.Country
From Supplier
Full join Customer        ----(although the output is same it is not systematic as shown in screenshot)
On Supplier.Country=Customer.country


/*27. Match customers that are from the same city and country. That is you are asked to give a list of customers that are from same country and city.
Display firstname, lastname, city and coutntry of such customers.*/ 

Select *From customer
Select A.FirstName As FirstName1,A.LastName As LastName1, B.firstName as FirstName2,
       B.LastName As LastName2,A.Country,A.City
From   Customer As A 
          join
       Customer as  B
 on    A.Id<>B.Id                        --( there is no functional diffrence in inner join and join)
           And                          --(Self Join-You can use without join by using comma but with where clause instead of on )
       A.Country=B.Country 
	        And
       A.city=B.city
order by city,Country



/*28. List all Suppliers and Customers. Give a Label in a separate column as 'Suppliers' if he is a supplier and 'Customer' if he is a customer accordingly.
Also, do not display firstname and lastname as two fields; Display Full name of customer or supplier.*/
Select*from Customer
Select*from Supplier

Select
     Case 
	      When [contact Name] in (Select Concat(Firstname,' ',LastName) From Customer)
		     THEN 'Customer'
			 ELSE 'Supplier'
	 END As [Type],
	 *From(
	       Select Concat(FirstName,' ',LastName) As [Contact Name],City,Country,Phone 
		   From Customer
		   Union All
		   Select ContactName as[Contact Name],City,Country,Phone
		   From Supplier
		   ) As X



/*29. Create a copy of orders table. In this copy table, now add a column city of type varchar (40). Update this city column using the city info in
customers table.*/
Select*into Orders2
From orders
Select*From Orders2
Alter Table Orders2
Add  City Varchar(40)
Update Orders2 Set Orders2.City=(Select Customer.City from Customer where Customer.id=Orders2.CustomerId)
------------------------------------------------------------------
Select*Into order_copy
From Orders
Select*from order_copy
Select T1*T2.City Into (order_copy)
From Orders As T1
Left Join Customer As T2
On T1.customerID=T2.Id


/*30. Suppose you would like to see the last OrderID and the OrderDate for this last order that was shipped to 'Paris'. Along with that information,
say you would also like to see the OrderDate for the last order shipped regardless of the Shipping City. In addition to this, you would also like to 
calculate the difference in days between these two OrderDates that you get. Write a single query which performs this*/

Select Id, OrderDate as [lastParisOrder] ,( Select max(orderdate) as y  From Orders2)
From Orders2
Where City='Paris' 
And OrderDate=(select Max(orderdate) from Orders2 where City='paris')


/*31. Find those customer countries who do not have suppliers. This might help you provide better delivery time to customers by adding suppliers 
to these countires. Use SubQueries.*/
Select*from Customer
select*from Supplier
select Distinct Country
from Customer
Where  Country Not in (select Distinct Country from Supplier)


/*32. Suppose a company would like to do some targeted marketing where it would contact customers in the country with the fewest number of orders.
It is hoped that this targeted marketing will increase the overall sales in the targeted country. You are asked to write a query to get all details
of such customers from top 5 countries with fewest numbers of orders. Use Subqueries.*/
Select*From Customer
Select*From Orders
Select Customer.Id,Concat(firstName,' ',LastName) as [Name],country,city,phone 
from Customer
where Country in
(Select Top 5 country
From Customer
left join Orders
On Customer.Id=orders.CustomerId
group by Country
order by Count(Orders.Id)) 


/*33. Let's say you want report of all distinct "OrderIDs" where the customer did not purchase more than 10% of the average quantity sold for a 
given product. This way you could review these orders, and possibly contact the customers, to help determine if there was a reason for the low
quantity order. Write a query to report such orderIDs.*/

 
select*from OrderItem
Select Distinct Orderid From OrderItem ---(not  working try to fix again)
Where Quantity in (Select (avg(cast(Quantity as float)))*0.1 From OrderItem Group by ProductId)
------------------------------------------------------------------------------------------------------------------------------

Select Distinct Orderid From OrderItem as O
Left join (select Productid,avg(cast(Quantity as float)) as AVg_order From OrderItem
 Group by ProductId) as X
 On X.productid=O.productid
 where O.Quantity <X.[avg_order]*.1
/*34. Find Customers whose total orderitem amount is greater than 7500$ for the year 2013. The total order item amount for 1 order for a customer 
is calculated using the formula UnitPrice * Quantity * (1 - Discount). DO NOT consider the total amount column from 'Order' table to calculate
the total orderItem for a customer*/
Select*From OrderItem
Select*From Orders
Alter Table Orderitem
alter  column discount Float
Select CustomerId,Sum(UnitPrice*Quantity*(1-discount)) As totalOrderAmount
From OrderItem
Inner Join Orders
On Orderid=Orders.Id
Where Year(orderDate)=2013
Group by CustomerId
Having Sum(UnitPrice*Quantity*(1-discount))>7500


/*35. Display the top two customers, based on the total dollar amount associated with their orders, per country. The dollar amount is calculated as
OI.unitprice * OI.Quantity * (1 -OI.Discount). You might want to perform a query like this so you can reward these customers, since they buy the 
most per country. 
Please note: if you receive the error message for this question "This type of correlated subquery 
pattern is not supported yet", that is totally fine*/
Select*from OrderItem
Select*from Customer
Select*from Orders
Select*From(Select*, ROW_NUMBER() Over(partition by Country Order By TotalDollarAmount desc ) As Ranks
From(
       Select CustomerId,Sum(UnitPrice*Quantity*(1-discount)) As totalDollarAmount, Country
       From OrderItem
       Inner Join Orders
       On Orderid=Orders.Id
       
       Inner Join Customer
       On Customer.id=Orders.CustomerId
       Group by CustomerID,Country
	  ) As Y) As X
Where Ranks in (1,2)


--36. Create a View of Products whose unit price is above average Price.
Create View Prod_above_avg_Price
As
Select*From Product
Where UnitPrice>(Select avg(UnitPrice) From Product)

Select*from Prod_above_avg_Price

