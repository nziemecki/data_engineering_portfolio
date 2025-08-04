
-- general column_category table
CREATE TABLE final_project.mortality_column_category (
    column_id serial PRIMARY KEY,
    sex varchar,
    age_category varchar,
    leading_cause_death varchar,
    metric_name varchar
);

INSERT INTO mortality_column_category (sex, age_category, leading_cause_death, metric_name)
SELECT DISTINCT sex, age_category, leading_cause_death, metric_name
FROM vital_mortality_pd;

----------------------------------------------------

-- column name and code table
DROP TABLE IF EXISTS mortality_column_name CASCADE;

CREATE TABLE final_project.mortality_column_name (
    column_id serial PRIMARY KEY,
    column_name varchar
);

INSERT INTO mortality_column_name (column_name)
VALUES 
    ('A_AA_LC_count_d'),
    ('A_35plus_SAPD_smoking_d'),
    ('A_35plus_SAPD_smoking_aamr_100k'),
    ('A_AA_CRVD_count_d'),
    ('A_AA_HA_aamr_100k'),
    ('A_less1_ALL_count_id'),
    ('A_35plus_ALLSA_smoking_aamr_100k'),
    ('A_AA_Unintentional_aamr_100k'),
    ('A_less1_ALL_pren_mr_1k_lb'),
    ('A_35plus_SAC_smoking_d'),
    ('A_35plus_SAC_smoking_aamr_100k'),
    ('A_AA_Sep_aamr_100k'),
    ('A_AA_CC_aamr_100k'),
    ('A_AA_CKD_count_d'),
    ('A_AA_ALL_aamr_100k6'),
    ('F_AB_ALL_life_exp_ab'),
    ('A_AA_ALL_count_d'),
    ('A_AA_Sep_count_d'),
    ('A_AA_IP_count_d'),
    ('A_AA_OD_count_d'),
    ('A_AA_CRVD_aamr_100k'),
    ('A_AA_H_aamr_100k'),
    ('A_AA_CLRD_aamr_100k'),
    ('A_AA_CLRD_count_d'),
    ('A_AA_SH_count_d'),
    ('A_AA_PC_aamr_100k'),
    ('A_35plus_ALLSA_smoking_d'),
    ('A_AA_D_aamr_100k'),
    ('A_AA_HA_count_d'),
    ('A_AA_IP_aamr_100k'),
    ('A_AA_PC_count_d'),
    ('A_less1_ALL_count_d'),
    ('A_AA_C_count_d'),
    ('A_35plus_SACMD_smoking_d'),
    ('M_AB_ALL_life_exp_ab'),
    ('A_AA_HD_count_d'),
    ('A_AA_H_count_d'),
    ('A_AA_OD_aamr_100k'),
    ('A_AA_HD_aamr_100k'),
    ('A_AA_BC_aamr_100k'),
    ('A_AA_CC_count_d'),
    ('A_AA_Unintentional_count_d'),
    ('A_less1_ALL_inf_mr_1k_lb'),
    ('A_35plus_SACMD_smoking_aamr_100k'),
    ('A_AA_BC_count_d'),
    ('A_AA_C_aamr_100k'),
    ('A_AA_CKD_aamr_100k'),
    ('A_AA_SH_aamr_100k'),
    ('A_AA_D_count_d'),
    ('A_AA_LC_aamr_100k');

----------------------------------------------------
----------------------------------------------------

-- Final column name reference table
-- can be used to reference codified column names using specified select queries
-- example: "select column_name, metric_name from mortality_column_reference
-- where leading_cause_death = 'HIV/AIDS';"

-- drop table if exists mortality_column_reference cascade;
CREATE TABLE final_project.mortality_column_reference (
    column_id serial PRIMARY KEY,
    column_name varchar,
    sex varchar,
    age_category varchar,
    leading_cause_death varchar,
    metric_name varchar
);

INSERT INTO mortality_column_reference (column_name, sex, age_category, leading_cause_death, metric_name)
SELECT column_name, sex, age_category, leading_cause_death, metric_name
FROM mortality_column_name AS n 
JOIN mortality_column_category AS c ON n.column_id = c.column_id;

-- GEOMETRY TABLE
CREATE TABLE final_project.planning_district (
    geo_id serial PRIMARY KEY,
    geography_name varchar,
    geom geometry
);

INSERT INTO planning_district (geography_name, geom)
SELECT DISTINCT geography_name, ST_Transform(geom, 2272)
FROM vital_mortality_pd;

------------------------------------

-- MORTALITY TABLE
CREATE TABLE final_project.mortality_metric (
    year int,
    geo_id int,
    A_AA_LC_count_d float8,
    A_35plus_SAPD_smoking_d float8,
    A_35plus_SAPD_smoking_aamr_100k float8,
    A_AA_CRVD_count_d float8,
    A_AA_HA_aamr_100k float8,
    A_less1_ALL_count_id float8,
    A_35plus_ALLSA_smoking_aamr_100k float8,
    A_AA_Unintentional_aamr_100k float8,
    A_less1_ALL_pren_mr_1k_lb float8,
    A_35plus_SAC_smoking_d float8,
    A_35plus_SAC_smoking_aamr_100k float8,
    A_AA_Sep_aamr_100k float8,
    A_AA_CC_aamr_100k float8,
    A_AA_CKD_count_d float8,
    A_AA_ALL_aamr_100k float8,
    F_AB_ALL_life_exp_ab float8,
    A_AA_ALL_count_d float8,
    A_AA_Sep_count_d float8,
    A_AA_IP_count_d float8,
    A_AA_OD_count_d float8,
    A_AA_CRVD_aamr_100k float8,
    A_AA_H_aamr_100k float8,
    A_AA_CLRD_aamr_100k float8,
    A_AA_CLRD_count_d float8,
    A_AA_SH_count_d float8,
    A_AA_PC_aamr_100k float8,
    A_35plus_ALLSA_smoking_d float8,
    A_AA_D_aamr_100k float8,
    A_AA_HA_count_d float8,
    A_AA_IP_aamr_100k float8,
    A_AA_PC_count_d float8,
    A_less1_ALL_count_d float8,
    A_AA_C_count_d float8,
    A_35plus_SACMD_smoking_d float8,
    M_AB_ALL_life_exp_ab float8,
    A_AA_HD_count_d float8,
    A_AA_H_count_d float8,
    A_AA_OD_aamr_100k float8,
    A_AA_HD_aamr_100k float8,
    A_AA_BC_aamr_100k float8,
    A_AA_CC_count_d float8,
    A_AA_Unintentional_count_d float8,
    A_less1_ALL_inf_mr_1k_lb float8,
    A_35plus_SACMD_smoking_aamr_100k float8,
    A_AA_BC_count_d float8,
    A_AA_C_aamr_100k float8,
    A_AA_CKD_aamr_100k float8,
    A_AA_SH_aamr_100k float8,
    A_AA_D_count_d float8,
    A_AA_LC_aamr_100k float8,
    PRIMARY KEY (year, geo_id)
);

INSERT INTO mortality_metric
SELECT DISTINCT
    vm.year,
    pd.geo_id,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Lung cancer' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_LC_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = '35+' AND
        leading_cause_death = 'Smoking-attributable pulmonary diseases' AND metric_name = 'smoking_attributable_deaths' THEN metric_value END) AS A_35plus_SAPD_smoking_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = '35+' AND
        leading_cause_death = 'Smoking-attributable pulmonary diseases' AND metric_name = 'age_adjusted_smoking_attributable_mortality_rate_per_100k' THEN metric_value END) AS A_35plus_SAPD_smoking_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Cerebrovascular diseases' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_CRVD_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'HIV/AIDS' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_HA_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = '<1' AND
        leading_cause_death = 'All causes' AND metric_name = 'count_infant_deaths' THEN metric_value END) AS A_less1_ALL_count_id,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = '35+' AND
        leading_cause_death = 'All smoking-attributable causes' AND metric_name = 'age_adjusted_smoking_attributable_mortality_rate_per_100k' THEN metric_value END) AS A_35plus_ALLSA_smoking_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Unintentional injuries (excluding drug overdoses)' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_Unintentional_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = '<1' AND
        leading_cause_death = 'All causes' AND metric_name = 'perinatal_mortality_rate_per_1k_live_births' THEN metric_value END) AS A_less1_ALL_pren_mr_1k_lb,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = '35+' AND
        leading_cause_death = 'Smoking-attributable cancers' AND metric_name = 'smoking_attributable_deaths' THEN metric_value END) AS A_35plus_SAC_smoking_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = '35+' AND
        leading_cause_death = 'Smoking-attributable cancers' AND metric_name = 'age_adjusted_smoking_attributable_mortality_rate_per_100k' THEN metric_value END) AS A_35plus_SAC_smoking_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Septicemia' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_Sep_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Colorectal cancer' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_CC_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Chronic kidney disease' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_CKD_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'All causes' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_ALL_aamr_100k,
    MAX(CASE WHEN sex = 'Female' AND age_category = 'At birth' AND
        leading_cause_death = 'All causes' AND metric_name = 'life_expectancy_at_birth' THEN metric_value END) AS F_AB_ALL_life_exp_ab,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'All causes' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_ALL_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Septicemia' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_Sep_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Influenza and pneumonia' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_IP_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Drug overdoses' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_OD_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Cerebrovascular diseases' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_CRVD_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Homicide' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_H_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Chronic lower respiratory diseases' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_CLRD_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Chronic lower respiratory diseases' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_CLRD_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Intentional self-harm (suicide)' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_SH_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Prostate cancer' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_PC_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = '35+' AND
        leading_cause_death = 'All smoking-attributable causes' AND metric_name = 'smoking_attributable_deaths' THEN metric_value END) AS A_35plus_ALLSA_smoking_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Diabetes' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_D_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'HIV/AIDS' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_HA_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Influenza and pneumonia' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_IP_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Prostate cancer' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_PC_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = '<1' AND
        leading_cause_death = 'All causes' AND metric_name = 'count_perinatal_deaths' THEN metric_value END) AS A_less1_ALL_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Cancer' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_C_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = '35+' AND
        leading_cause_death = 'Smoking-attributable cardiovascular and metabolic diseases' AND metric_name = 'smoking_attributable_deaths' THEN metric_value END) AS A_35plus_SACMD_smoking_d,
    MAX(CASE WHEN sex = 'Male' AND age_category = 'At birth' AND
        leading_cause_death = 'All causes' AND metric_name = 'life_expectancy_at_birth' THEN metric_value END) AS M_AB_ALL_life_exp_ab,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Heart disease' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_HD_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Homicide' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_H_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Drug overdoses' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_OD_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Heart disease' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_HD_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Breast cancer' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_BC_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Colorectal cancer' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_CC_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Unintentional injuries (excluding drug overdoses)' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_Unintentional_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = '<1' AND
        leading_cause_death = 'All causes' AND metric_name = 'infant_mortality_rate_per_1k_live_births' THEN metric_value END) AS A_less1_ALL_inf_mr_1k_lb,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = '35+' AND
        leading_cause_death = 'Smoking-attributable cardiovascular and metabolic diseases' AND metric_name = 'age_adjusted_smoking_attributable_mortality_rate_per_100k' THEN metric_value END) AS A_35plus_SACMD_smoking_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Breast cancer' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_BC_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Cancer' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_C_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Chronic kidney disease' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_CKD_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Intentional self-harm (suicide)' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_SH_aamr_100k,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Diabetes' AND metric_name = 'count_deaths' THEN metric_value END) AS A_AA_D_count_d,
    MAX(CASE WHEN sex = 'All sexes' AND age_category = 'All ages' AND
        leading_cause_death = 'Lung cancer' AND metric_name = 'age_adjusted_mortality_rate_per_100k' THEN metric_value END) AS A_AA_LC_aamr_100k
FROM vital_mortality_pd vm
JOIN planning_district pd ON vm.geography_name = pd.geography_name
GROUP BY year, geo_id;


-- Optimizing crime_incident data for faster results:
DROP TABLE IF EXISTS crime_geom CASCADE;

CREATE TABLE final_project.crime_geom (
    geo_id serial PRIMARY KEY,
    objectid int4,
    geom geometry(POINT, 2272)
);

INSERT INTO crime_geom (objectid, geom)
SELECT DISTINCT objectid, ST_Transform(ST_SetSRID(ST_Point(point_x, point_y), 4326), 2272)
FROM crime_incident;

-- Creating a geometry table for faster look-up: point creation with ST_Point from x and y data,
-- setting SRID for the original data source with ST_SetSRID, transforming the data into desired
-- coordinate system with ST_Transform.

-- Indexing:
CREATE INDEX geo_id_mm_idx ON mortality_metric (geo_id);
CREATE INDEX year_idx ON mortality_metric (year);
CREATE INDEX district_geom_idx ON planning_district USING gist (ST_Transform(geom, 2272));
CREATE INDEX crime_geom_idx ON crime_geom USING gist (ST_Transform(geom, 2272));
