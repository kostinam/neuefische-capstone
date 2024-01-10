--CREATE TABLE production_and_emissions AS (
--SELECT
--	item,
--	avg(emissions_intensity)
--FROM
--	(
	SELECT
		*,
		CASE
			WHEN emissions_intensity_in_kg_co2eq_per_kg IS NULL THEN emissions_intensity_calc_in_kg_co2eq_per_kg
			ELSE emissions_intensity_in_kg_co2eq_per_kg
		END AS emissions_intensity_combined_in_kg_co2eq_per_kg
	FROM
		(
		SELECT
			area,
			item,
			item_code,
			YEAR,
			area_harvested AS area_harvested_in_ha,
			stocks AS stocks_in_an,
			producing_animals_slaughtered AS producing_animals_slaughtered_in_an,
			egg_or_milk_animals AS egg_or_milk_animals_in_an,
			production AS production_in_t,
			yield,
			yield_unit,
			emissions_ch4 AS emissions_ch4_in_kt,
			emissions_n20 AS emissions_n2o_in_kt,
			round(CAST(emissions_ch4 * 28 + emissions_n20 * 298 AS NUMERIC), 4) AS emissions_co2eq_calc_in_kt,
			CASE
				WHEN production = 0 THEN NULL
				ELSE round(CAST((emissions_ch4 * 28 + emissions_n20 * 298) * 1000 / production AS NUMERIC), 4)
			END AS emissions_intensity_calc_in_kg_co2eq_per_kg,
			round(CAST(emissions_co2eq AS NUMERIC), 4) AS emissions_co2eq_in_kt,
			round(CAST(emissions_intensity AS NUMERIC), 4) AS emissions_intensity_in_kg_co2eq_per_kg,
			production_emissions AS production_emissions_in_t
		FROM
			(
			SELECT
				fpr.*,
				CASE
					WHEN fecr.emissions_ch4 IS NULL THEN felr.emissions_ch4
					ELSE fecr.emissions_ch4
				END AS emissions_ch4,
				CASE
					WHEN fecr.emissions_n20 IS NULL THEN felr.emissions_n20
					ELSE fecr.emissions_n20
				END AS emissions_n20,
				CASE
					WHEN fecr.emissions_n20 IS NULL THEN felr.emissions_unit
					ELSE fecr.emissions_unit
				END AS emissions_unit,
				feir.emissions_co2eq ,
				feir.emissions_co2eq_unit,
				feir.emissions_intensity,
				feir.emissions_intensity_unit,
				feir.production AS production_emissions,
				feir.production_unit AS production_emissions_unit
			FROM
				fao_production_reduced fpr
			LEFT JOIN fao_emissions_crops_reduced fecr 
				ON fpr.area = fecr.area
				AND fpr.item = fecr.item
				AND fpr.item_code = fecr.item_code
				AND fpr.YEAR = fecr.year
			LEFT JOIN fao_emissions_livestock_reduced felr 
				ON fpr.area = felr.area
				AND fpr.item = felr.item
				AND fpr.item_code = felr.item_code
				AND fpr.YEAR = felr.year
			LEFT JOIN fao_emissions_intensities_reduced feir 
				ON fpr.area = feir.area
				AND fpr.item = feir.item
				AND fpr.item_code = feir.item_code
				AND fpr.YEAR = feir.YEAR) AS t) AS h
--	)
--	WHERE
--		(emissions_intensity_calc_in_kg_co2eq_per_kg IS NOT NULL OR emissions_intensity_in_kg_co2eq_per_kg IS NOT NULL) AND YEAR = 2020
	--) AS j
--GROUP BY
--	item