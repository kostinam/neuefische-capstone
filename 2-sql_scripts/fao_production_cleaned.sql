--CREATE TABLE fao_production_cleaned AS (
SELECT
	area,
	item,
	item_code,
	YEAR,
	area_harvested,
	area_harvested_unit,
	stocks,
	stocks_unit,
	producing_animals_slaughtered,
	producing_animals_slaughtered_unit,
	CASE
		WHEN laying = 0 THEN milk_animals
		ELSE laying
	END AS egg_or_milk_animals,
	CASE
		WHEN laying_unit = '-' THEN milk_animals_unit
		ELSE laying_unit
	END AS egg_or_milk_animals_unit,
	production,
	production_unit,
	CASE
		WHEN yield = 0 THEN yield_carcass_weight
		ELSE yield
	END AS yield,
	CASE
		WHEN yield_unit = '-' THEN yield_carcass_weight_unit
		ELSE yield_unit
	END AS yield_unit
FROM
	(
	SELECT
		area,
		item,
		item_code,
		YEAR,
		max(area_harvested) AS area_harvested,
		max(area_harvested_unit) AS area_harvested_unit,
		max(stocks) AS stocks,
		max(stocks_unit) AS stocks_unit,
		max(laying) AS laying,
		max(laying_unit) AS laying_unit,
		max(milk_animals) AS milk_animals,
		max(milk_animals_unit) AS milk_animals_unit,
		max(producing_animals_slaughtered) AS producing_animals_slaughtered,
		max(producing_animals_slaughtered_unit) AS producing_animals_slaughtered_unit,
		max(production) AS production,
		max(production_unit) AS production_unit,
		max(yield) AS yield,
		max(yield_unit) AS yield_unit,
		max(yield_carcass_weight) AS yield_carcass_weight,
		max(yield_carcass_weight_unit) AS yield_carcass_weight_unit
	FROM
		(
		SELECT
			*,
			CASE
				WHEN ELEMENT = 'Area harvested' THEN value
				ELSE 0
			END AS area_harvested,
			CASE
				WHEN ELEMENT = 'Area harvested' THEN unit
				ELSE '-'
			END AS area_harvested_unit,
			CASE
				WHEN ELEMENT = 'Stocks'
				AND unit = '1000 An' THEN value * 1000
				WHEN ELEMENT = 'Stocks'
				AND unit IN ('An', 'No') THEN value
				ELSE 0
			END AS stocks,
			CASE
				WHEN ELEMENT = 'Stocks' THEN 'An'
				ELSE '-'
			END AS stocks_unit,
			CASE
				WHEN ELEMENT = 'Laying' THEN value * 1000
				ELSE 0
			END AS laying,
			CASE
				WHEN ELEMENT = 'Laying' THEN 'An'
				ELSE '-'
			END AS laying_unit,
			CASE
				WHEN ELEMENT = 'Milk Animals' THEN value
				ELSE 0
			END AS milk_animals,
			CASE
				WHEN ELEMENT = 'Milk Animals' THEN unit
				ELSE '-'
			END AS milk_animals_unit,
			CASE
				WHEN ELEMENT = 'Producing Animals/Slaughtered'
				AND unit = '1000 An' THEN value * 1000
				WHEN ELEMENT = 'Producing Animals/Slaughtered'
				AND unit = 'An' THEN value
				ELSE 0
			END AS producing_animals_slaughtered,
			CASE
				WHEN ELEMENT = 'Producing Animals/Slaughtered' THEN 'An'
				ELSE '-'
			END AS producing_animals_slaughtered_unit,
			CASE
				WHEN ELEMENT = 'Production'
				AND unit = 't' THEN value
				ELSE 0
			END AS production,
			CASE
				WHEN ELEMENT = 'Production' THEN 't'
				ELSE '-'
			END AS production_unit,
			CASE
				WHEN ELEMENT = 'Yield'
				AND unit NOT IN ('No/An', '100 g')
				AND unit != '100 mg/An' THEN value
				WHEN ELEMENT = 'Yield'
				AND unit NOT IN ('No/An', '100 g')
				AND unit = '100 mg/An' THEN value * 0.001
				ELSE 0
			END AS yield,
			CASE
				WHEN ELEMENT = 'Yield'
				AND unit NOT IN ('No/An', '100 g')
				AND unit != '100 mg/An' THEN unit
				WHEN ELEMENT = 'Yield'
				AND unit NOT IN ('No/An', '100 g')
				AND unit = '100 mg/An' THEN '100 g/An'
				ELSE '-'
			END AS yield_unit,
			CASE
				WHEN ELEMENT = 'Yield/Carcass Weight'
				AND unit = '0.1 g/An' THEN value * 0.001
				WHEN ELEMENT = 'Yield/Carcass Weight'
				AND unit = '100 g/An' THEN value
				ELSE 0
			END AS yield_carcass_weight,
			CASE
				WHEN ELEMENT = 'Yield/Carcass Weight' THEN '100 g/An'
				ELSE '-'
			END AS yield_carcass_weight_unit
		FROM
			fao_production fp
		WHERE
			ELEMENT != 'Prod Popultn'
			AND unit NOT IN ('1000 No', 'No/An')) AS t
	GROUP BY
		area,
		item,
		item_code,
		YEAR)AS h
--)