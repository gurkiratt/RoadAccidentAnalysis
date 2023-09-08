#----ROAD ACCIDENT ANALYSIS-----
#----(Authenticating data visualisation using SQL QUERIES)-----


#creating the database
create database RoadAccident;
use RoadAccident;


#viewing database structure
select * from accident_data;


#defining the table and datatypes
create table accident_data(
   accident_index varchar(30),
   accident_date date,
   day_of_week varchar(30),
   junction_control varchar(50),
   junction_detail varchar(50),
   accident_severity varchar(30),
   light_conditions varchar(50),
   local_authority varchar(50),
   carriageway_hazards varchar(50),
   number_of_casualties int,
   number_of_vehicles int,
   police_force varchar(50),
   road_surface_conditions varchar(50),
   road_type varchar(50),
   speed_limit int,
   `time` time,
   urban_or_rural_area varchar(50),
   weather_conditions varchar(50),
   vehicle_type varchar(50)
   );


#setting secure-file-priv to allow data infile load   
SHOW VARIABLES LIKE "secure_file_priv";   


#loading data from csv file to the data table accident_data
LOAD DATA INFILE 'road_accident.csv'
INTO TABLE accident_data
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;


#---RUNNING SQL QUERIES----


#total casualities categorised by year
SELECT 
    YEAR(accident_date) AS Year,
    SUM(number_of_casualties) AS TotalCasualities
FROM
    accident_data
GROUP BY Year;


#fatal casualities categorised by year
SELECT 
    YEAR(accident_date) AS Year,
    SUM(number_of_casualties) AS FatalCasualities
FROM
    accident_data
WHERE
    accident_severity = 'Fatal'
GROUP BY Year;


#serious casualities categorised by year
SELECT 
    YEAR(accident_date) AS Year,
    SUM(number_of_casualties) AS SeriousCasualities
FROM
    accident_data
WHERE
    accident_severity = 'Serious'
GROUP BY Year;


#top 10 locations with maximum accidents
SELECT 
    local_authority AS location, COUNT(accident_index) AS Count
FROM
    accident_data
GROUP BY location
ORDER BY count DESC
LIMIT 10;


#categorise total casualities by road conditions
SELECT 
    road_surface_conditions AS RoadConditions,
    SUM(number_of_casualties) AS Casualities
FROM
    accident_data
GROUP BY RoadConditions;


#categorise total casualities by weather conditions
SELECT 
    weather_conditions AS WeatherConditions,
    SUM(number_of_casualties) AS Casualities
FROM
    accident_data
GROUP BY weather_conditions;


#casualities for an year-2022 where weather-rain and severity-fatal
SELECT 
    SUM(number_of_casualties) AS Casualities
FROM
    accident_data
WHERE
    YEAR(accident_date) = '2022'
        AND weather_conditions LIKE '%Rain%'
        AND accident_severity = 'Fatal';
  
  
#casualities for an year-2021 where severity-serious and road condition-wet
SELECT 
    SUM(number_of_casualties) AS Casualities
FROM
    accident_data
WHERE
    YEAR(accident_date) = '2021'
        AND road_surface_conditions LIKE '%Wet%'
        AND accident_severity = 'Serious';
        
 
#casualities for year 2022 by vehicle type grouped as  
SELECT
    YEAR(accident_date) AS year,
    vehicle_subcategory,
    SUM(number_of_casualties) AS casualties_per_subcategory
FROM (
    SELECT
        accident_date,
        CASE
            WHEN vehicle_type IN ('Taxi/Private hire car', 'Car') THEN 'Car'
            WHEN vehicle_type IN ('Goods 7.5 tonnes mgw and over', 'Goods over 3.5t. and under 7.5t', 'Van / Goods 3.5 tonnes mgw or under') THEN 'Goods_Vehicles'
            WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)', 'Minibus (8 - 16 passenger seats)') THEN 'Bus'
            WHEN vehicle_type IN ('Motorcycle 125cc and under', 'Motorcycle 50cc and under', 'Motorcycle over 125cc and up to 500cc', 'Motorcycle over 500cc') THEN 'Motorcycle'
            WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural vehicle'
            ELSE 'Other'
        END AS vehicle_subcategory,
        number_of_casualties
    FROM accident_data
) AS subquery
GROUP BY year, vehicle_subcategory
ORDER BY year, vehicle_subcategory;



