--CREATE TABLE production_and_emissions_final AS (
SELECT
	area,
	YEAR,
	population,
	t.item,
	item_code,
	area_harvested_in_ha,
	stocks_in_an,
	producing_animals_slaughtered_in_an,
	egg_or_milk_animals_in_an,
	production_in_t,
	yield,
	yield_unit,
	emissions_ch4_in_kt,
	emissions_n2o_in_kt,
	emissions_co2eq_calc_in_kt,
	emissions_intensity_calc_in_kg_co2eq_per_kg,
	source_emissions,
	emissions_co2eq_in_kt,
	emissions_intensity_in_kg_co2eq_per_kg,
	production_emissions_in_t,
	emissions_intensity_combined_in_kg_co2eq_per_kg,
	im.item_group,
	im.item_category,
	area_group
	FROM (
SELECT
	*,
	CASE
		WHEN area IN (
'Africa',
'Americas',
'Asia',
'Australia and New Zealand',
'Caribbean',
'Central America',
'Central Asia',
'Eastern Africa',
'Eastern Asia',
'Eastern Europe',
'Europe',
'European Union (27)',
'Land Locked Developing Countries',
'Least Developed Countries',
'Low Income Food Deficit Countries',
'Melanesia',
'Micronesia',
'Middle Africa',
'Net Food Importing Developing Countries',
'Northern Africa',
'Northern America',
'Northern Europe',
'Oceania',
'Polynesia',
'Small Island Developing States',
'South America',
'South-eastern Asia',
'Southern Africa',
'Southern Asia',
'Southern Europe',
'Western Africa',
'Western Asia',
'Western Europe',
'World') 
		THEN 'yes'
		ELSE 'no'
	END AS area_group,
	CASE
		WHEN item IN (
'Crops, primary',
'Live Animals',
'Livestock primary',
'Beef and Buffalo Meat, primary',
'Butter and Ghee',
'Cattle and Buffaloes',
'Cereals, primary',
'Cheese (All Kinds)',
'Citrus Fruit, Total',
'Crops Processed',
'Eggs Primary',
'Evaporated & Condensed Milk',
'Fibre Crops Primary',
'Fibre Crops, Fibre Equivalent',
'Fruit Primary',
'Hides and skins, primary',
'Livestock processed',
'Meat, Poultry',
'Meat, Total',
'Milk, Total',
'Oilcrops Primary',
'Oilcrops, Cake Equivalent',
'Oilcrops, Oil Equivalent',
'Poultry Birds',
'Pulses, Total',
'Roots and Tubers, Total',
'Sheep and Goat Meat',
'Sheep and Goats',
'Skim Milk & Buttermilk, Dry',
'Sugar Crops Primary',
'Treenuts, Total',
'Vegetables Primary')
		THEN 'yes'
		ELSE 'no'
	END AS item_group1
FROM
	production_and_emissions
ORDER BY
	area,
	YEAR,
	item) t
LEFT JOIN item_mapping im 
	ON im.item = t.item
WHERE t.item_group1 = 'no'
--)