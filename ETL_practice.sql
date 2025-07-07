set search_path to shakespeare, boundless, natural_earth, public, streetpole;
--1.Loading Data
--C:\Users\tup93308\Documents\Fall 2022\Spatial Database Design\ETL>ogr2ogr -f
PostgreSQL PG:"host=localhost port=5432 dbname=universe user=postgres
password=postgres" -lco SCHEMA=streetpole -lco PRECISION=NO -oo
EMPTY_STRING_AS_NULL=YES Street_Poles.csv
--2. Create a pole owner look up table
DROP TABLE IF EXISTS pole_owner CASCADE;
CREATE TABLE pole_owner (
pole_owner_id serial PRIMARY KEY,
pole_owner varchar
);
INSERT INTO pole_owner (pole_owner)
SELECT DISTINCT owner FROM street_poles;
select * from pole_owner;
--3. Create a pole type look up table
DROP TABLE IF EXISTS pole_type CASCADE;
CREATE TABLE pole_type (
pole_type varchar PRIMARY KEY,
description varchar
);
select * from pole_type;
insert into pole_type (pole_type, description)
values ('AAMP','avenue of the arts mast arm pole'),
('AAPT','avenue of the arts street light pole'),
('AEL','alley pole'),
('C13','traffic c post 13 foot'),
('C20','traffic c post 20 foot'),
('CCP','center city pedestrian pole'),
('CCR','center city roadway pole'),
('CHP','chestnut hill street light pole'),
('D30','traffic d pole'),
('FLP','franklin light pole'),
('MAP','traffic mast arm pole'),
('MAPT','traffic mast arm pole (twin light)'),
('MLP','millenium light pole'),
('MLPT','millenium light pole (twin light) * oth - other'),
('OTH', 'other'),
('OTHT','other (twin light)'),
('MBC', 'mantion bifocal color'),
('PDT','penndot pole'),
('PDTT','penndot pole (twin light)'),
('PKY','parkway street light pole'),
('PKYT','parkway street light pole (twin pole)'),
('PTA','post top pole (aluminum)'),
('PTC','post top pole (concrete)'),
('PTF','post top pole (fiberglass)'),
('PVT','private pole'),
('PVTT','private pole (twin light)'),
('RP','radar traffic pole'),
('SLA','street light aluminum'),
('SLAT','street light aluminum (twin light)'),
('SLF','street light fiberglass'),
('SLFT','street light fiberglass (twin light)'),
('SM','structure mounted'),
('SMP','strawberry mansion bridge pole'),
('SNP','sign pole'),
('SWP','span wire pole'),
('TP','trolley pole'),
('WP','wood pole'),
('WPT','wood pole (twin light)'),
('CTP','chinatown pole'),
('SEP', 'september pole'),
('SSP','south street tower pole'),
('SMB','septa millennia bridge pole'),
('JMB','jfk blvd millennia bridge pole'),
('MMB','market st millennia bridge pole'),
('CMB','chestnut st millennia bridge pole'),
('WMB','walnut st millennia bridge pole'),
('SMAB','strawberry mansion arch bridge pole'),
('FB','falls bridge pole'),
('RLP','red light camera pole'),
('TCB','traffic control box'),
('AASP','avenue of the arts signal pole'),
('CP','carrier pole');
select * from pole_type;
--4. Create the main street pole table
DROP TABLE IF EXISTS street_pole CASCADE;
create table street_pole
(gid int primary key,
pole_num int,
pole_type varchar,
pole_date date,
pole_owner_id int,
tap_id int,
geom geometry(POINT, 2272),
foreign key (pole_type) references pole_type(pole_type),
foreign key (pole_owner_id) references pole_owner(pole_owner_id));
select * from street_pole;
--5. Create related tables for lighting and alley pole info.
DROP TABLE IF EXISTS pole_light_info CASCADE;
DROP TABLE IF EXISTS alley_pole CASCADE;
create table pole_light_info
(gid int not null primary key,
nlumin int,
lum_size int,
height int);
create table alley_pole
(gid int not null primary key,
block varchar,
plate varchar);
--6. Transform and insert the data into street_pole.
INSERT INTO street_pole (gid, pole_num, pole_type, pole_date, pole_owner_id,
tap_id, geom)
select objectid,
pole_num,
type,
pole_date,
(select pole_owner_id from pole_owner where owner = pole_owner),
tap_id,
ST_Transform (ST_SetSRID(ST_Point (x, y), 4326), 2272)
FROM street_poles;
select * from street_pole;
--7. Insert related data into pole_light_info and alley_pole.
insert into pole_light_info (gid, nlumin, lum_size, height)
select objectid, nlumin, lum_size, height
from street_poles
where objectid is not null and nlumin is not null and lum_size is not null and
height is not null;
insert into alley_pole (gid, block, plate)
select objectid, block, plate
from street_poles
where objectid is not null and block is not null and plate is not null;
select * from pole_light_info;
select * from alley_pole;