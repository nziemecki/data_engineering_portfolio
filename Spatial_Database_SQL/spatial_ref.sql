set search_path to shakespeare, boundless, natural_earth, public;
--Create a query which measures the area of all the neighborhoods in the
nyc_neighborhoods table.
--Write one query which displays the neighborhood name, area as calculated in UTM
18N (which the data is stored in), New York State Plane Long Island (look up the
appropriate SRID), and on the WGS 84 spheroid by casting to the geography type.
--Make sure to pay attention to the units, and convert all the outputs to square
kilometers.--
select name, ST_Area(geom)/1000 as utm18N,
ST_Area(ST_Transform(geom, 2263))/1000 as NYSP,
ST_Area(ST_Transform(geom, 4326))/1000 as WGS84
from nyc_neighborhoods;
--Not sure why WGS looks like this--
--Create a query which calculates the distance from 4/5/6 Grand Central Station
stop to every neighborhood in nyc_neighborhoods.
--Use a subquery to select the geom only for Grand Central Station as one of the
input parameters to the distance function.
--Show the neighborhood name and calculate the distance using UTM 18N (which the
data is stored in), New York State Plane Long Island, and on the WGS 84 spheroid by
casting to the geography type.
--Make sure to pay attention to the units, and convert all the outputs to
kilometers.
select name, ST_Distance(ST_Point(586351, 4511718, 26918), geom)/1000 as utm18N,
ST_Distance(ST_Point(586351, 4511718, 2263), ST_Transform(geom, 2263))/1000 as
NYSP,
ST_Distance(ST_Point(586351, 4511718, 4326), ST_Transform(geom, 4326))/1000 as
WGS84
from nyc_neighborhoods;
--Create a query which calculates distance from Philadelphia to the five most
populous cities in the table ne_10m_populated_places (use the pop_max column for
population size).
--Include the table name and the following distances:
--the distance in the coordinate system as stored (decimal degrees, which will be
useless)
--the distance in Web Mercator (which will also be useless)
--the geodetic distance using a geography cast
select name, ST_Distance(geom::geography, (select geom from ne_10m_populated_places
where name = 'Philadelphia')::geography)/1000 as KM_to_Philly_cast,
ST_Distance(geom, (select geom from ne_10m_populated_places where name =
'Philadelphia'))/1000 as KM_to_Philly_utm18N,
ST_Distance(ST_Transform(geom, 4326), ST_Transform((select geom from
ne_10m_populated_places where name = 'Philadelphia'), 4326))/1000 as
KM_to_Philly_utm18N
from ne_10m_populated_places order by pop_max limit 5;
select geom from ne_10m_populated_places where name = 'Philadelphia';
