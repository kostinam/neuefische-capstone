--CREATE TABLE fao_emissions_intensities_reduced AS (
SELECT
	area,
	item,
	item_code,
	YEAR,
	max(emissions_co2eq) AS emissions_co2eq,
	emissions_co2eq_unit,
	max(emissions_intensity) AS emissions_intensity,
	emissions_intensity_unit,
	max(production) AS production,
	production_unit
FROM
	(
	SELECT
		*,
		CASE
			WHEN ELEMENT = 'Emissions (CO2eq) (AR5)' THEN value
			ELSE 0
		END AS emissions_co2eq,
		'kt' AS emissions_co2eq_unit,
		CASE
			WHEN ELEMENT = 'Emissions intensity' THEN value
			ELSE 0
		END AS emissions_intensity,
		'kg CO2eq/kg' AS emissions_intensity_unit,
		CASE
			WHEN ELEMENT = 'Production' THEN value
			ELSE 0
		END AS production,
		't' AS production_unit
	FROM
		fao_emissions_intensities fei) AS t
GROUP BY
	area,
	item,
	item_code,
	YEAR,
	emissions_co2eq_unit,
	emissions_intensity_unit,
	production_unit
--)