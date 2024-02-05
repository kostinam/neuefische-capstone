--CREATE TABLE fao_production_and_emissions AS (
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
			area_group,
			YEAR,
			population,
			t.item,
			item_code,
			im.item_group,
			im.item_category,
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
				ELSE round(CAST((emissions_ch4 * 28 + emissions_n20 * 265) * 1000 / production AS NUMERIC), 4)
			END AS emissions_intensity_calc_in_kg_co2eq_per_kg,
			source_emissions,
			round(CAST(emissions_co2eq AS NUMERIC), 4) AS emissions_co2eq_in_kt,
			round(CAST(emissions_intensity AS NUMERIC), 4) AS emissions_intensity_in_kg_co2eq_per_kg,
			production_emissions AS production_emissions_in_t
		FROM
			(
			SELECT
				fpr.*,
				CASE 
					WHEN fecr.SOURCE IS NULL THEN felr.SOURCE
					ELSE fecr.SOURCE
				END AS source_emissions,				
				CASE
					WHEN fecr.emissions_ch4 IS NULL THEN felr.emissions_ch4
					ELSE fecr.emissions_ch4
				END AS emissions_ch4,
				CASE
					WHEN fecr.emissions_n2o IS NULL THEN felr.emissions_n2o
					ELSE fecr.emissions_n2o
				END AS emissions_n20,
				CASE
					WHEN fecr.emissions_n2o IS NULL THEN felr.emissions_unit
					ELSE fecr.emissions_unit
				END AS emissions_unit,
				feir.emissions_co2eq ,
				feir.emissions_co2eq_unit,
				feir.emissions_intensity,
				feir.emissions_intensity_unit,
				feir.production AS production_emissions,
				feir.production_unit AS production_emissions_unit,
				fp.total_population AS population,
				CASE
					WHEN fpr.area IN (SELECT area_group FROM area_groups) THEN 'yes'
					ELSE 'no'
				END AS area_group,
				CASE
					WHEN fpr.item IN (SELECT item_group FROM item_groups) THEN 'yes'
					ELSE 'no'
				END AS item_group1
			FROM
				fao_production_cleaned fpr
			LEFT JOIN fao_emissions_crops_cleaned fecr 
				ON fpr.area = fecr.area
				AND fpr.item = fecr.item
				AND fpr.item_code = fecr.item_code
				AND fpr.YEAR = fecr.year
			LEFT JOIN fao_emissions_livestock_cleaned felr 
				ON fpr.area = felr.area
				AND fpr.item = felr.item
				AND fpr.item_code = felr.item_code
				AND fpr.YEAR = felr.year
			LEFT JOIN fao_emissions_intensities_cleaned feir 
				ON fpr.area = feir.area
				AND fpr.item = feir.item
				AND fpr.item_code = feir.item_code
				AND fpr.YEAR = feir.YEAR
			LEFT JOIN fao_population fp
				ON fpr.area = fp.area
				AND fpr.YEAR = fp.YEAR) AS t
		LEFT JOIN item_mapping im 
			ON im.item = t.item
		WHERE
			t.item_group1 = 'no') AS h
	ORDER BY
		area,
		YEAR,
		item
--)