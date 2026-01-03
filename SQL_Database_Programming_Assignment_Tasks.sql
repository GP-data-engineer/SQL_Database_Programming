-- 3.1) write a function that checks if the given argument text is a palindrome
create function palind4(@tekst varchar(50)) returns varchar(50)
as begin
declare @odwotnosc varchar(50)
declare @zwrot varchar(50)
set @odwotnosc = reverse(lower(@tekst))
if (lower(@tekst) = @odwotnosc)
set @zwrot = 'is a palindrome' 
else
set @zwrot = 'is not a palindrome'
return @zwrot
end
-- function call set @zwrot = 
select dbo.palind('kajak')

drop function palind4

-- 3.2) based on the Northwind database - write a function returning the sales value of goods for the given parameters: 
     -- category and customer name. The function should never return a Null value.

select sum(ode.UnitPrice * ode.Quantity) as 'Sales Value', cat.CategoryName, cus.CompanyName from [Order Details] ode
join Products pro on pro.ProductID = ode.ProductID
join Categories cat on cat.CategoryID = pro.CategoryID
join Orders ord on ord.OrderID = ode.OrderID
join Customers cus on ord.CustomerID = cus.CustomerID
where 'Sales Value' is not null
group by cat.CategoryName, cus.CompanyName
order by cus.CompanyName
--========================

create function Wartosc_sp(@kategoria varchar(50), @klient varchar(50))
returns decimal(38,2) --float numeric
as begin
declare @wart_sprz decimal(38,2) --float numeric
select @wart_sprz = sum(ode.UnitPrice * ode.Quantity) from [Order Details] ode
join Products pro on pro.ProductID = ode.ProductID
join Categories cat on cat.CategoryID = pro.CategoryID
join Orders ord on ord.OrderID = ode.OrderID
join Customers cus on ord.CustomerID = cus.CustomerID
where cat.CategoryName = @kategoria and cus.CompanyName = @klient
if @wart_sprz is null
set @wart_sprz = 0
return @wart_sprz
end

select dbo.Wartosc_sp('Dairy Products','Ana Trujillo Emparedados y helados')

drop function Wartosc_sp

-- 3.3) write a function returning unique customer names who made a purchase in the month specified as parameter.
--===
select cus.CompanyName, ord.OrderDate from Orders ord
join Customers cus on ord.CustomerID = cus.CustomerID
where month(ord.OrderDate) = 7

--===
create function miesiac_zakup(@numer int) returns table
as return
(select cus.CompanyName from Orders ord
join Customers cus on ord.CustomerID = cus.CustomerID
where @numer = month(ord.OrderDate))
-- this function is stored in the tree: Programmability/Functions/Table-valued Functions
select * from dbo.miesiac_zakup(7)

drop function miesiac_zakup


-- 4.1) improve the function czy_pesel so that it is resistant to incorrect parameters (it should display an appropriate message instead of generating errors), 
     -- the function should also correctly validate PESEL numbers ending with digit 0

create function czy_pesel_3(@pesel char(11)) returns int
as begin
declare @suma int , @wynik tinyint = 0, @modulo int, @rok int, @miesiac int
declare @dzien int, @data_urodzenia datetime

if len(@pesel) != 11 
or @pesel like '%[^0-9]%' --in my opinion this should cover all problems including 'O' instead of 0
or @pesel like '%[Oo]%' -- the task requires this, so I add it, unless I'm wrong or missing something?
	begin
	return @wynik -- because by default it is set to 0 meaning false
	end
--========
    set @rok = cast(substring(@pesel, 1, 2) as int)
    set @miesiac = cast(substring(@pesel, 3, 2) as int)
    set @dzien = cast(substring(@pesel, 5, 2) as int)
--========
    if @miesiac between 1 and 12 
    set @rok = @rok + 1900		-- check date for those born after 1900

    else if @miesiac between 21 and 32 -- check date for those born after 2000
    begin
    set @rok = @rok + 2000
    set @miesiac = @miesiac - 20
    end
    else 
    return @wynik

set @suma = 
cast(substring(@pesel,1,1) as int ) * 1 + cast(substring(@pesel,2,1) as int ) * 3 +
cast(substring(@pesel,3,1) as int ) * 7 + cast(substring(@pesel,4,1) as int ) * 9 +
cast(substring(@pesel,5,1) as int ) * 1 + cast(substring(@pesel,6,1) as int ) * 3 +
cast(substring(@pesel,7,1) as int ) * 7 + cast(substring(@pesel,8,1) as int ) * 9 +
cast(substring(@pesel,9,1) as int ) * 1 + cast(substring(@pesel,10,1) as int ) *3
set @modulo = (@suma % 10)
if (cast(substring(@pesel,11,1) as int) = 10 - @modulo)
	begin
	set @wynik = 1 -- if it returns 1 then PESEL is TRUE - valid
	end
return @wynik -- returns 0 false or 1 true
end


select dbo.czy_pesel_3('44051401458') -- if it is 1 then PESEL is valid, if 0 then false 
select dbo.czy_pesel_3('440514O1458') -- what if letter O instead of zero?
select dbo.czy_pesel_3('49040501580') -- what if division modulo = 0 but such PESEL exists? - I don't know how to solve this
select dbo.czy_pesel_3('22222222222') -- and here I don’t remember what was the point?

drop function czy_pesel_3

-- sorry, I am unable to finish this problem with 22222222222.
-- most likely it's not about the code itself but I need more time to resolve the essence of the issue


-- 4.2) write a procedure that adds a new student (to the table studenci). The procedure should not allow adding an underage student

create procedure dodaj_studenta
@imie varchar(40), @nazwisko varchar(40), @data_urodzenia datetime, @plec char(1), @miasto varchar(40), @liczba_dzieci int
as 
begin
if (datediff(year, @data_urodzenia, getdate()) > 18) --if age in years > 18 then add:
	begin
    insert into studenci (imie, nazwisko, data_urodzenia, plec, miasto, liczba_dzieci)
    values (@imie, @nazwisko, @data_urodzenia, @plec, @miasto, @liczba_dzieci)
    end
else if (datediff(year, @data_urodzenia, getdate()) = 18) --if exactly 18 years then check further: 
	begin
    if (month(@data_urodzenia) < month(getdate())) or --check month, if < current month then add:
       (month(@data_urodzenia) = month(getdate()) and day(@data_urodzenia) <= day(getdate())) -- if month = current then check day, if <= then add:
       begin
       -- Student is adult, add to database
       insert into studenci (imie, nazwisko, data_urodzenia, plec, miasto, liczba_dzieci)
       values (@imie, @nazwisko, @data_urodzenia, @plec, @miasto, @liczba_dzieci)
       end
	else
		begin -- goes here if month and day are less than 18 compared to current date.
		select 'Student underage, missing month or days'
		end
    end
-- end else if
else -- goes here if age is clearly < 18 compared to current date.
	begin
	select 'Student underage, missing years'
	end
end


exec dodaj_studenta @imie = 'Pultek' , @nazwisko = 'Trepek', @data_urodzenia = '2010-01-18', @plec = 'M', @miasto = 'Byków', @liczba_dzieci = '0'

select * from studenci 

drop procedure dodaj_studenta


-- 5.1) create table: clients ={id_klienta, first_name, last_name, gender, date_of_birth, pesel}. 
-- Write a trigger that will validate the entered PESEL number 
-- and check consistency between the given date of birth and gender.

create table klienci (
        id_klienta smallint primary key identity(1,1),
        imie nvarchar(30) not null,
		nazwisko nvarchar(30) not null,
		plec char(1) not null check (plec in ('M', 'K')), 
		data_urodzenia datetime not null,
		pesel char(11) not null)

select * from klienci

insert into klienci (imie, nazwisko, plec, data_urodzenia, pesel)
values ('Boles³aw', 'Kêdzierzawy', 'M', '1979-06-15', '80051412347') -- will work

insert into klienci (imie, nazwisko, plec, data_urodzenia, pesel)
values ('Mieszko', 'Pl¹tonogi', 'Z', '1990-06-15', '90031512341') -- will not work

drop table klienci

-- trigger

create trigger walidator_pesel on klienci
for insert, update
as begin
    -- Variable declarations
    declare @pesel char(11), @data_urodzenia datetime, @plec char(1)
    declare @id_klienta int

    select @id_klienta = id_klienta, @pesel = pesel, @data_urodzenia = data_urodzenia, @plec = plec
    from inserted

    if dbo.czy_pesel_3(@pesel) = 0 -- here it calls czy_pesel_3 and checks if it returns 1 -true or 0-false
		begin
		print 'Invalid PESEL'
		rollback
		end
    if isdate(@data_urodzenia) = 0 or @data_urodzenia is null
		begin
		print 'Invalid date'
		rollback
		end
    if @plec not in ('M', 'K') 
		begin
		print 'Invalid gender'
		rollback
		end
end

drop trigger walidator_pesel


-- 5.2) In the 'studenci' table create a trigger that will prevent adding underage mothers

create trigger matki_zamlode on studenci for insert
as
begin
    if ((select count(*) from inserted where plec = 'K') > 0) -- checks if female
    begin -- checks if children exist
        if ((select count(*) from inserted where liczba_dzieci > 0)>0) -- without last >0 it won’t work and I don’t know why?
        begin
            if ((select count(*) from inserted WHERE 
			datediff(yy, data_urodzenia, getdate()) < 18
            OR (datediff(yy, data_urodzenia, getdate()) = 18 AND (month(getdate()) < month(data_urodzenia)
            OR (MONTH(getdate()) = month(data_urodzenia) AND day(getdate()) < day(data_urodzenia)))))>0)
            begin
				print 'Cannot add an underage mother.'
				rollback 
            end
        end
    end
end

insert into studenci (imie, nazwisko, data_urodzenia, plec, miasto, liczba_dzieci) 
values ('Lola','D¿ind¿er', '2007-01-16' ,'K' ,'Katowice' , 1)

select * from studenci

delete from studenci where imie = 'Lola'

drop trigger matki_zamlode
