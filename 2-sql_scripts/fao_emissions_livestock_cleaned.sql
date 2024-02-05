--CREATE TABLE fao_emissions_livestock_cleaned AS (
SELECT
	h.area,
	h.YEAR,
	h.item,
	h.item_code,
	h.source,
	max(j.emissions_CH4) AS emissions_CH4,
	max(j.emissions_N2O) AS emissions_N2O,
	j.emissions_unit
FROM
	(
	SELECT
		area,
		YEAR,
		item,
		item_code,
		ELEMENT,
		min(SOURCE) AS SOURCE
	FROM
		fao_emissions_livestock fec
	WHERE
		ELEMENT LIKE 'Livestock total%'
	GROUP BY
		area,
		YEAR,
		item,
		item_code,
		ELEMENT) AS h
LEFT JOIN (
	SELECT
		area,
		YEAR,
		item,
		item_code,
		SOURCE,
		max(emissions_CH4) AS emissions_CH4,
		max(emissions_N20) AS emissions_N2O,
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
		YEAR,
		item,
		item_code,
		SOURCE,
		emissions_unit) AS j
ON
	h.area = j.area
	AND h.year = j.YEAR
	AND h. item = j.item
	AND h.item_code = j.item_code
	AND h.SOURCE = j.SOURCE
GROUP BY
	h.area,
	h.YEAR,
	h.item,
	h.item_code,
	h.SOURCE,
	emissions_unit
--)