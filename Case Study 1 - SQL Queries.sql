use Case_Study_1;

-- 2- "Combine Data in single table"
--rename column name of 2019_Q2 , make column names as of 2020_Q1
EXEC sp_rename '[Divvy_Trips_2019_Q2].[01 - Rental Details Rental ID]', 'ride_id', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q2].[01 - Rental Details Bike ID]', 'rideable_type', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q2].[01 - Rental Details Local Start Time]', 'started_at', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q2].[01 - Rental Details Local End Time]', 'ended_at', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q2].[03 - Rental Start Station Name]', 'start_station_name', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q2].[03 - Rental Start Station ID]', 'start_station_id', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q2].[02 - Rental End Station Name]', 'end_station_name', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q2].[02 - Rental End Station ID]', 'end_station_id', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q2].[User Type]', 'member_casual', 'COLUMN'

--rename column name of 2019_Q3 , make column names as of 2020_Q1
EXEC sp_rename '[Divvy_Trips_2019_Q3].[trip_id]', 'ride_id', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q3].[bikeid]', 'rideable_type', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q3].[start_time]', 'started_at', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q3].[end_time]', 'ended_at', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q3].[from_station_name]', 'start_station_name', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q3].[from_station_id]', 'start_station_id', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q3].[to_station_name]', 'end_station_name', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q3].[to_station_id]', 'end_station_id', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q3].[usertype]', 'member_casual', 'COLUMN'


--rename column name of 2019_Q4 , make column names as of 2020_Q1
EXEC sp_rename '[Divvy_Trips_2019_Q4].[trip_id]', 'ride_id', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q4].[bikeid]', 'rideable_type', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q4].[start_time]', 'started_at', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q4].[end_time]', 'ended_at', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q4].[from_station_name]', 'start_station_name', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q4].[from_station_id]', 'start_station_id', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q4].[to_station_name]', 'end_station_name', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q4].[to_station_id]', 'end_station_id', 'COLUMN'
EXEC sp_rename '[Divvy_Trips_2019_Q4].[usertype]', 'member_casual', 'COLUMN'

-- remove columns not required in all 4 tables
--2019_Q2 - remove '01 - Rental Details Duration In Seconds Uncapped', 'Member Gender' , '05 - Member Details Member Birthday Year'
--2019_Q3 - remove 'tripduration' , gender, birth year
--2019_Q4 - remove 'tripduration' , gender, birth year
--2020_Q1 - remove 'start_lat' , start_lng , end_lat , end_lng

alter table [Divvy_Trips_2019_Q2]
drop column [01 - Rental Details Duration In Seconds Uncapped] , [Member Gender],[05 - Member Details Member Birthday Year];

alter table [Divvy_Trips_2019_Q3]
drop column tripduration , gender,birthyear;

alter table [Divvy_Trips_2019_Q4]
drop column tripduration , gender,birthyear;

alter table [Divvy_Trips_2020_Q1]
drop column start_lat,start_lng , end_lat , end_lng;

-- append all tables data in 1 table 
select * into all_trips from [Divvy_Trips_2019_Q2] UNION ALL select * from [Divvy_Trips_2019_Q3] UNION ALL SELECT * from [dbo].[Divvy_Trips_2019_Q4] UNION ALL SELECT ride_id,started_at,ended_at,rideable_type,start_station_id,start_station_name,end_station_id,end_station_name,member_casual FROM [dbo].[Divvy_Trips_2020_Q1];

-- 3- Data Cleaning and add new columns 
-- a). member_casual column has 4 type of values member,subscriber, customer, casual,
--     it have only two Member and Casual. Subscriber should be changed to Member and customer should be changed to casual.

update all_trips set member_casual = 'member'
where member_casual = 'Subscriber';


update all_trips set member_casual = 'casual'
where member_casual = 'Customer';

-- b). Adding some additional columns like ride_length,day_of_week, Day, month, year
select cast(cast(ended_at as datetime) - cast(started_at as datetime) as time(0)) as ride_length from all_trips;

alter table all_trips
add ride_length time(0);

update all_trips
set ride_length =  cast(cast(ended_at as datetime) - cast(started_at as datetime) as time(0));

ALTER TABLE all_trips
add day_of_week int;

update all_trips
set day_of_week = DATEPART(WEEKDAY, cast(started_at as datetime));


Alter table all_trips
add Day varchar(32), Month varchar(32), Year varchar(32);

update all_trips
set Day = DATENAME(dw,cast(started_at as datetime));

update all_trips
set Month = datename(month,cast(started_at as datetime));

update all_trips
set Year = datename(year,cast(started_at as datetime));

alter table all_trips
add ride_length_sec int;

update all_trips
set ride_length_sec = DATEDIFF(second, cast(started_at as datetime), cast(ended_at as datetime));

-- c). Some trip duration are negative , will delete those rows.
select ride_length_sec from all_trips where ride_length_sec< 0;
delete from all_trips where ride_length_sec < 0;

---------------------4. Desciptive analysis------------
-- mean of ride length 
select AVG(cast(ride_length_sec as float)) 
from all_trips;
-- 1477.7505216909

--max_ride length
select MAX(ride_length_sec)
from all_trips;
-- 9387024

select MIN(ride_length_sec)
from all_trips;
-- 0

--mode
SELECT TOP 1 day_of_week
FROM   all_trips
GROUP  BY [day_of_week]
ORDER  BY COUNT(*) DESC
-- 3

-- count number of member riders and casual riders


select member_casual,count(member_casual) as rider_count , ((SUM(cast(ride_length_sec as bigint)))/60)/60 as Sum_of_ride_duration_hrs , ((AVG(cast(ride_length_sec as float)))/60)/60 as avg_of_ride_duration_hrs
from all_trips 
group by member_casual;





