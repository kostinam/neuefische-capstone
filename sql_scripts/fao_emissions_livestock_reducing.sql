--CREATE TABLE fao_emissions_livestock_reduced AS (
SELECT
	area,
	item,
	item_code,
	YEAR,
	max(emissions_CH4) AS emissions_CH4,
	max(emissions_N20) AS emissions_N20,
	emissions_unit
FROM
	(
	SELECT
		*,
		CASE
			WHEN ELEMENT = 'Livestock total (Emissions CH4)' THEN value
			ELSE 0
		END AS emissions_CH4,
		CASE
			WHEN ELEMENT = 'Livestock total (Emissions N2O)' THEN value
			ELSE 0
		END AS emissions_N20,
		'kt' AS emissions_unit
	FROM
		fao_emissions_livestock) AS t
GROUP BY
	area,
	item,
	item_code,
	YEAR,
	emissions_unit--)