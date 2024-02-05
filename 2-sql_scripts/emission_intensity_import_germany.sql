
-- Calculate import share of each partner country for each item

SELECT
    item,
    YEAR,
    partner_country,
    import_quantity,
    import_quantity / SUM(import_quantity) OVER (PARTITION BY item, year) AS import_share
FROM
    fao_trade_matrix
WHERE
    YEAR = 2020
    AND reporting_country = 'Germany'
    AND import_quantity IS NOT NULL
GROUP BY
    1, 2, 3,4
LIMIT
    10;

   
-- Add a column with emission intensities for each item and country
 
SELECT
    fao_trade_matrix.item,
    partner_country,
    import_quantity,
    import_quantity / SUM(import_quantity) OVER (PARTITION BY fao_trade_matrix.item, fao_trade_matrix.year) AS import_share, 
    production_and_emissions_new.emissions_intensity_combined_in_kg_co2eq_per_kg AS emission_intensity,
    production_and_emissions_new.emissions_co2eq_combined_in_kt AS emission_amount,
    import_quantity / SUM(import_quantity) OVER (PARTITION BY fao_trade_matrix.item, fao_trade_matrix.year) * production_and_emissions_new.emissions_intensity_combined_in_kg_co2eq_per_kg AS emission_itensity_share,
    import_quantity / SUM(import_quantity) OVER (PARTITION BY fao_trade_matrix.item, fao_trade_matrix.year) * production_and_emissions_new.emissions_co2eq_combined_in_kt AS emission_amount_share
FROM fao_trade_matrix
JOIN production_and_emissions_new ON fao_trade_matrix.item = production_and_emissions_new.item 
	AND fao_trade_matrix.partner_country = production_and_emissions_new.country 
	AND fao_trade_matrix."year"  = production_and_emissions_new."year" 
WHERE
    fao_trade_matrix.year = 2020
    AND reporting_country = 'Germany'
    AND import_quantity IS NOT NULL
    AND production_and_emissions_new.emissions_intensity_combined_in_kg_co2eq_per_kg IS NOT NULL
    AND production_and_emissions_new.emissions_co2eq_combined_in_kt IS NOT NULL
GROUP BY
    fao_trade_matrix.year,
    fao_trade_matrix.item,
    partner_country,
    import_quantity,
    emission_intensity,
    emission_amount
LIMIT
    10; 
    
-- Calculating total emission intensity per product and year
WITH import_emissions_germany AS (
SELECT
    fao_trade_matrix.item,
    partner_country,
    fao_trade_matrix."year" AS import_year,
    import_quantity,
    import_quantity / NULLIF(SUM(import_quantity) OVER (PARTITION BY fao_trade_matrix.item, fao_trade_matrix.year), 0) AS import_share,
    production_and_emissions_new.emissions_intensity_combined_in_kg_co2eq_per_kg AS emission_intensity,
    import_quantity / NULLIF(SUM(import_quantity) OVER (PARTITION BY fao_trade_matrix.item, fao_trade_matrix.year),0) * production_and_emissions_new.emissions_intensity_combined_in_kg_co2eq_per_kg AS emission_itensity_share
FROM
    fao_trade_matrix
JOIN production_and_emissions_new ON fao_trade_matrix.item = production_and_emissions_new.item 
	AND fao_trade_matrix.partner_country = production_and_emissions_new.country 
	AND fao_trade_matrix."year"  = production_and_emissions_new."year" 
WHERE
    reporting_country = 'Germany'
    AND import_quantity IS NOT NULL
    AND production_and_emissions_new.emissions_intensity_combined_in_kg_co2eq_per_kg IS NOT NULL
GROUP BY
    1, 2, 3, 4, 6
)   
SELECT item,
		import_year,
		SUM(import_share) AS total_import_share, -- Assuming you want the total import share for each item
   		SUM(emission_itensity_share) AS total_import_emission_intensity
FROM import_emissions_germany
GROUP BY item, import_year
ORDER BY item, import_year;

-- Calculating total emission intensity and emission amount per product and year
WITH import_emissions_germany AS (
SELECT
    fao_trade_matrix.item,
    partner_country,
    fao_trade_matrix."year" AS import_year,
    import_quantity,
    import_quantity / SUM(import_quantity) OVER (PARTITION BY fao_trade_matrix.item, fao_trade_matrix.year) AS import_share, 
    production_and_emissions_new.emissions_intensity_combined_in_kg_co2eq_per_kg AS emission_intensity,
    production_and_emissions_new.emissions_co2eq_combined_in_kt AS emission_amount,
    import_quantity / SUM(import_quantity) OVER (PARTITION BY fao_trade_matrix.item, fao_trade_matrix.year) * production_and_emissions_new.emissions_intensity_combined_in_kg_co2eq_per_kg AS emission_itensity_share,
    import_quantity / SUM(import_quantity) OVER (PARTITION BY fao_trade_matrix.item, fao_trade_matrix.year) * production_and_emissions_new.emissions_co2eq_combined_in_kt AS emission_amount_share
FROM fao_trade_matrix
JOIN production_and_emissions_new ON fao_trade_matrix.item = production_and_emissions_new.item 
	AND fao_trade_matrix.partner_country = production_and_emissions_new.country 
	AND fao_trade_matrix."year"  = production_and_emissions_new."year" 
WHERE
    fao_trade_matrix.year = 2020
    AND reporting_country = 'Germany'
    AND import_quantity IS NOT NULL
    AND production_and_emissions_new.emissions_intensity_combined_in_kg_co2eq_per_kg IS NOT NULL
    AND production_and_emissions_new.emissions_co2eq_combined_in_kt IS NOT NULL
GROUP BY
    fao_trade_matrix.item,
    fao_trade_matrix.year,
    partner_country,
    import_quantity,
    emission_intensity,
    emission_amount
)   
SELECT item,
		import_year,
		SUM(import_share) AS total_import_share, -- Assuming you want the total import share for each item
   		SUM(emission_itensity_share) AS total_import_emission_intensity, 
   		SUM (emission_amount_share) AS total_import_emission_amount
FROM import_emissions_germany
GROUP BY item, import_year
ORDER BY item, import_year;


--Creating a table with the result
CREATE TABLE capstone_envirolytics.mk_import_emissions AS
WITH import_emissions_germany AS (
SELECT
    fao_trade_matrix.item,
    partner_country,
    fao_trade_matrix."year" AS import_year,
    import_quantity,
    import_quantity / NULLIF(SUM(import_quantity) OVER (PARTITION BY fao_trade_matrix.item, fao_trade_matrix.year), 0) AS import_share,
    production_and_emissions_new.emissions_intensity_combined_in_kg_co2eq_per_kg AS emission_intensity,
    production_and_emissions_new.emissions_co2eq_combined_in_kt AS emission_amount,
    import_quantity / NULLIF(SUM(import_quantity) OVER (PARTITION BY fao_trade_matrix.item, fao_trade_matrix.year),0) * production_and_emissions_new.emissions_intensity_combined_in_kg_co2eq_per_kg AS emission_itensity_share,
    import_quantity / NULLIF(SUM(import_quantity) OVER (PARTITION BY fao_trade_matrix.item, fao_trade_matrix.year),0) * production_and_emissions_new.emissions_co2eq_combined_in_kt AS emission_amount_share
FROM
    fao_trade_matrix
JOIN production_and_emissions_new ON fao_trade_matrix.item = production_and_emissions_new.item 
	AND fao_trade_matrix.partner_country = production_and_emissions_new.country 
	AND fao_trade_matrix."year"  = production_and_emissions_new."year" 
WHERE
    reporting_country = 'Germany'
    AND import_quantity IS NOT NULL
    AND production_and_emissions_new.emissions_intensity_combined_in_kg_co2eq_per_kg IS NOT NULL
    AND production_and_emissions_new.emissions_co2eq_combined_in_kt IS NOT NULL
GROUP BY
    fao_trade_matrix.item,
    fao_trade_matrix.year,
    partner_country,
    import_quantity,
    emission_intensity,
    emission_amount
)   
SELECT item,
		import_year,
		SUM(import_share) AS total_import_share, -- Assuming you want the total import share for each item
   		SUM(emission_itensity_share) AS total_import_emission_intensity,
   		SUM (emission_amount_share) AS total_import_emission_amount
FROM import_emissions_germany
GROUP BY item, import_year
ORDER BY item, import_year;


-- Make table available for everyone
CALL capstone_envirolytics.grant_access('mk_import_emissions');
