create table results(
    id INT,
    response TEXT
);


/*1*/

insert into results
select 1, count(passenger_id) as count_pass
from tickets t
group by book_ref
order by count_pass desc
limit 1;


/*2*/

with count_pass as (
	select count(passenger_id) as pc
	from tickets t
	group by book_ref
)
insert into results
select 2, count(*)
from count_pass
where pc > (select avg(pc) from count_pass);




/*3*/
insert into results
select 3,  book_ref
from tickets t
where book_ref in (select  book_ref
							 from tickets t
							 group by book_ref,passenger_name  
							 having count(*)>= 2 
					union 		 
					select  book_ref
							 from tickets t
							 group by book_ref,passenger_id  
							 having count(*)>= 2 		 						
							 )
and book_ref in (select book_ref 
					 from tickets t
					 group by book_ref 
					 having count(*) = (select  count(passenger_id) as pass_count
										from tickets t
										group by book_ref
										order by pass_count desc
										limit 1)
				     )							
	


/*4*/

insert into results
select 4,  concat(book_ref, '|', passenger_id, '|', passenger_name, '|', contact_data)
from tickets
where book_ref in (select book_ref
                   from tickets
                   group by book_ref
                   having count(*) = 3)
order by book_ref, passenger_id, passenger_name, contact_data;


/*5*/

insert into results
select 5, count(book_ref) as cflights
from bookings
join tickets using(book_ref)
join ticket_flights using(ticket_no)
group by book_ref
order by cflights desc
limit 1;


/*6.*/

insert into results
select 6, count(*) as cflights
from bookings
join tickets using(book_ref)
join ticket_flights using(ticket_no)
group by book_ref, passenger_id
order by cflights desc
limit 1;


/* 7.*/

insert into results
select 7, count(*) cflights
from tickets
join ticket_flights using(ticket_no)
group by passenger_id
order by cflights desc
limit 1;


/*8.*/

with sum_amount as (
	select passenger_id, passenger_name, contact_data, sum(amount) as total_sum_amount
	from tickets join ticket_flights using(ticket_no)
	join flights f using(flight_id)
	where status <> 'Cancelled'
	group by passenger_id, passenger_name, contact_data
	order by total_sum_amount
)
insert into results
select 8, concat(passenger_id, '|', passenger_name, '|', contact_data, '|', total_sum_amount)
from (
    select passenger_id, passenger_name, contact_data, total_sum_amount
    from sum_amount
    where total_sum_amount = (select min(total_sum_amount) from sum_amount)
    order by passenger_id, passenger_name, contact_data asc
) as t1;


/*9.*/

with flight_time as (
	select passenger_id, passenger_name, contact_data, sum(actual_duration) as total_sum_flight_time
	from flights_v join ticket_flights using(flight_id)
	join tickets using(ticket_no)
	where actual_duration is not null
	group by passenger_id, passenger_name, contact_data
)
insert into results
select 9, concat(passenger_id, '|', passenger_name, '|', contact_data, '|', total_sum_flight_time)
from (
	select passenger_id, passenger_name, contact_data, total_sum_flight_time
	from flight_time
	where total_sum_flight_time = (select max(total_sum_flight_time) from flight_time)
	order by passenger_id, passenger_name, contact_data
) as t1;


/*10.*/

insert into results
select 10, city
from airports
group by city
having count(airport_code) > 1
order by city;


/*11. */

with cities_count as (
	select departure_city, count(distinct arrival_city) as c_cities
	from routes
	group by departure_city
)
insert into results
select 11, departure_city
from cities_count
where c_cities = (select min(c_cities) from cities_count)
order by departure_city;


/*12. */

with d_a_cities as (
	select distinct departure_city, arrival_city
	from routes
)
insert into results
select 12, concat(departure_city, '|', arrival_city)
from(
	select t1.departure_city, t2.arrival_city
	from d_a_cities t1, d_a_cities t2
	where t1.departure_city < t2.arrival_city
	except
	select * from d_a_cities) t
order by departure_city, arrival_city;


/*13.*/

insert into results
select distinct 13, departure_city
from routes
where departure_city  not in (
	select arrival_city from routes
	where departure_city = 'Москва'
	) and departure_city <> 'Москва';


/*14.*/

insert into results
select 14, model
from  flights join aircrafts using(aircraft_code)
where status = 'Arrived'
group by model
order by count(*) desc
limit 1;


/*15.*/

insert into results
select 15, model
from  flights join aircrafts using(aircraft_code)
join ticket_flights using(flight_id)
join tickets using(ticket_no)
where status = 'Arrived'
group by model
order by count(*) desc
limit 1;


/*16.*/

insert into results
select 16, EXTRACT(EPOCH FROM datediff)/60 AS minutes
from (
	select (sum(actual_duration) - sum(scheduled_duration)) as datediff
	from flights_v
	where status = 'Arrived'
) as t


/*17.*/

insert into results
select distinct 17, arrival_city
from flights_v
where status = 'Arrived' and departure_city = 'Санкт-Петербург' and date(actual_departure) = '2016-09-13'
order by arrival_city;


/*18.*/

insert into results
select 18, flight_id
from flights
where flight_id = (
    select flight_id
    from ticket_flights
	group by flight_id
	order by sum(amount) desc
	limit 1);


/*19.*/

with flights_count as (
	select date(actual_departure) as d_date, count(flight_id) as fc
	from flights f
	where status <> 'Cancelled' and actual_departure is not null
	group by date(actual_departure)
)
insert into results
select 19, d_date
from flights_count
where fc = (select min(fc) from flights_count);


/*20.*/

insert into results
select 20, avg(flights_count) flights_avg
from (
	select count(flight_id) flights_count
	from flights
	where actual_departure is not null and date_trunc('month', actual_departure) = '2016-09-01'
	group by actual_departure::date
) t;


/*21.*/

insert into results
select 21, t.d_city
from (
    select departure_city as d_city
	from flights_v
	group by departure_city
	having avg(actual_duration)  > interval '3hours'
	order by  avg(actual_duration) desc
	limit 5) t
order by t.d_city;