-- Bob's Logistics integration: compact loaders and stacking beltboxes for Bob's extra
-- belt tiers, running at exactly Bob's belt speeds.
--
-- This file is loaded from data-updates.lua, i.e. after every mod's data.lua. boblogistics
-- creates its belts, technologies and belt speeds in data.lua, so by the time this runs the
-- belt speeds below are final: every loader gets the speed of the belt it belongs to, no
-- matter which values the "belt speed overhaul" startup settings are on.
--
-- What this adds:
--   * loaders + beltboxes for Bob's tier-0 basic belt (belt overhaul only)
--   * loaders + beltboxes for Bob's turbo (tier 4) and ultimate (tier 5) belts
--     (turbo is skipped when Space Age already provides it)
--   * next_upgrade links between all tiers, so the upgrade planner and fast replace work
--     across the whole T0 -> T5 chain
--   * flat, cheap upgrade costs for every tier (see CONFIG below)

local DBL = require("prototypes.shared")

---------------------------------------------------------------------------------------------------
-- configuration
---------------------------------------------------------------------------------------------------

local CONFIG = {
	-- what one tier upgrade costs, on top of the previous tier's loader
	upgrade_iron_plate = 2,
	upgrade_iron_gear = 2,

	-- true : each tier's loader = previous tier's loader + the cost above
	-- false: each tier's loader = that tier's belt      + the cost above
	upgrade_from_previous = true,

	-- apply the same upgrade cost to the tiers this mod already creates by itself (vanilla and
	-- Space Age). Set to false to leave those recipes alone and only price the new Bob tiers
	-- this way.
	reprice_existing_tiers = true,

	-- create a loader (and beltbox) for Bob's tier-0 "basic transport belt"
	create_basic_tier = true,

	-- recipes for the beltboxes of the new tiers:
	--   "extend"  - keep the beltbox progression this mod already uses
	--   "upgrade" - flat cost, same rule as the loaders
	--   "none"    - don't create beltboxes for the new tiers at all
	beltbox_recipes = "extend",
}

---------------------------------------------------------------------------------------------------
-- the complete tier chain, lowest first; tiers that don't exist in the current game are ignored
---------------------------------------------------------------------------------------------------

local CHAIN = {
	{ belt = "bob-basic-transport-belt", loader = "bob-basic-transport-belt-loader", beltbox = "bob-basic-transport-belt-beltbox" },
	{ belt = "transport-belt", loader = "transport-belt-loader", beltbox = "transport-belt-beltbox" },
	{ belt = "fast-transport-belt", loader = "fast-transport-belt-loader", beltbox = "fast-transport-belt-beltbox" },
	{ belt = "express-transport-belt", loader = "express-transport-belt-loader", beltbox = "express-transport-belt-beltbox" },
	{ belt = "turbo-transport-belt", loader = "turbo-transport-belt-loader", beltbox = "turbo-transport-belt-beltbox" },
	{ belt = "bob-ultimate-transport-belt", loader = "bob-ultimate-transport-belt-loader", beltbox = "bob-ultimate-transport-belt-beltbox" },
}

---------------------------------------------------------------------------------------------------
-- Bob's belt tiers, described here so that the loader/beltbox recipes can be built
---------------------------------------------------------------------------------------------------

local BOB_TIERS = {
	{
		belt = "bob-basic-transport-belt",
		underground_belt = "bob-basic-underground-belt",
		splitter = "bob-basic-splitter",
		technology = "logistics-0",
		-- logistics-0 is a research-trigger technology without a unit, so the beltbox recipe
		-- is unlocked by that technology instead of by a generated beltbox technology
		beltbox_technology = "logistics-0",
		colour = {r = 165, g = 165, b = 165},
		order = "0",
		beltbox_plate = 5,
		beltbox_gear = 5,
	},
	{
		belt = "turbo-transport-belt",
		underground_belt = "turbo-underground-belt",
		splitter = "turbo-splitter",
		technology = "logistics-4",
		beltbox_technology = "deadlock-stacking-4",
		colour = {r = 165, g = 10, b = 225},
		order = "d",
		beltbox_plate = 30,
		beltbox_gear = 30,
		beltbox_circuit = "processing-unit",
		beltbox_circuit_amount = 5,
	},
	{
		belt = "bob-ultimate-transport-belt",
		underground_belt = "bob-ultimate-underground-belt",
		splitter = "bob-ultimate-splitter",
		technology = "logistics-5",
		beltbox_technology = "deadlock-stacking-5",
		colour = {r = 10, g = 225, b = 25},
		order = "e",
		beltbox_plate = 40,
		beltbox_gear = 40,
		beltbox_circuit = "processing-unit",
		beltbox_circuit_amount = 10,
	},
}

---------------------------------------------------------------------------------------------------
-- helpers
---------------------------------------------------------------------------------------------------

local function item_exists(name)
	return (name and data.raw.item[name]) ~= nil
end

local function any_exists(proto_type, name)
	return (name and data.raw[proto_type] and data.raw[proto_type][name]) ~= nil
end

local function index_in_chain(belt_name)
	for i, entry in ipairs(CHAIN) do
		if entry.belt == belt_name then
			return i
		end
	end
	return nil
end

local function previous_in_chain(belt_name)
	local i = index_in_chain(belt_name)
	if i and i > 1 then
		return CHAIN[i - 1]
	end
	return nil
end

-- one tier upgrade costs the previous tier's loader plus a flat amount of plates and gears
local function loader_ingredients(belt_name)
	local ingredients = {}
	local previous = previous_in_chain(belt_name)
	if CONFIG.upgrade_from_previous and previous and any_exists("loader-1x1", previous.loader) then
		table.insert(ingredients, {type = "item", name = previous.loader, amount = 1})
	else
		table.insert(ingredients, {type = "item", name = belt_name, amount = 1})
	end
	table.insert(ingredients, {type = "item", name = "iron-plate", amount = CONFIG.upgrade_iron_plate})
	table.insert(ingredients, {type = "item", name = "iron-gear-wheel", amount = CONFIG.upgrade_iron_gear})
	return ingredients
end

local function beltbox_ingredients(def)
	local belt_name = def.belt
	local previous = previous_in_chain(belt_name)
	if CONFIG.beltbox_recipes == "upgrade" and previous and any_exists("furnace", previous.beltbox) then
		return {
			{type = "item", name = previous.beltbox, amount = 1},
			{type = "item", name = "iron-plate", amount = CONFIG.upgrade_iron_plate},
			{type = "item", name = "iron-gear-wheel", amount = CONFIG.upgrade_iron_gear},
		}
	end
	local ingredients = {}
	if previous and any_exists("furnace", previous.beltbox) then
		table.insert(ingredients, {type = "item", name = previous.beltbox, amount = 1})
	else
		table.insert(ingredients, {type = "item", name = belt_name, amount = 4})
	end
	table.insert(ingredients, {type = "item", name = "iron-plate", amount = def.beltbox_plate or 10})
	table.insert(ingredients, {type = "item", name = "iron-gear-wheel", amount = def.beltbox_gear or 10})
	if item_exists(def.beltbox_circuit) then
		table.insert(ingredients, {type = "item", name = def.beltbox_circuit, amount = def.beltbox_circuit_amount or 4})
	end
	return ingredients
end

---------------------------------------------------------------------------------------------------
-- create the loaders and beltboxes for Bob's tiers
---------------------------------------------------------------------------------------------------

local created = {}
local skipped = {}

for _, def in ipairs(BOB_TIERS) do
	local loader_name = string.format("%s-loader", def.belt)
	local beltbox_name = string.format("%s-beltbox", def.belt)
	local is_basic_tier = (def.belt == "bob-basic-transport-belt")

	if is_basic_tier and not CONFIG.create_basic_tier then
		table.insert(skipped, string.format("%s (disabled in prototypes/bob_tiers.lua)", def.belt))
	elseif not any_exists("transport-belt", def.belt) then
		table.insert(skipped, string.format("%s (no such belt)", def.belt))
	elseif any_exists("loader-1x1", loader_name) or any_exists("furnace", beltbox_name) then
		table.insert(skipped, string.format("%s (already exists)", def.belt))
	else
		local tier = {
			transport_belt = def.belt,
			colour = def.colour,
			order = def.order,
			technology = def.technology,
			beltbox_technology = def.beltbox_technology,
			loader = loader_name,
			loader_item = loader_name,
			loader_recipe = loader_name,
			loader_category = "crafting",
			loader_ingredients = loader_ingredients(def.belt),
			beltbox = beltbox_name,
			beltbox_item = beltbox_name,
			beltbox_recipe = beltbox_name,
			beltbox_category = "crafting",
			beltbox_ingredients = beltbox_ingredients(def),
		}
		-- only pass the belt entities that actually exist, they are used for validation
		if any_exists("underground-belt", def.underground_belt) then
			tier.underground_belt = def.underground_belt
		end
		if any_exists("splitter", def.splitter) then
			tier.splitter = def.splitter
		end
		if CONFIG.beltbox_recipes == "none" then
			-- create the loader by itself, skipping the beltbox that add_tier() would have added
			-- (add_tier() also applies the "enable loaders/beltboxes" startup settings)
			if settings.startup["deadlock-enable-loaders"].value then
				DBL.create_loader(tier)
				table.insert(created, def.belt)
			end
		else
			deadlock.add_tier(tier)
			table.insert(created, def.belt)
		end
		DBL.debug(string.format("Created loader/beltbox tier for %s", def.belt))
	end
end

---------------------------------------------------------------------------------------------------
-- link the tiers together so that the upgrade planner can walk T0 -> T5
---------------------------------------------------------------------------------------------------

do
	local previous_loader
	local previous_beltbox
	for _, entry in ipairs(CHAIN) do
		if any_exists("loader-1x1", entry.loader) then
			if previous_loader then
				data.raw["loader-1x1"][previous_loader].next_upgrade = entry.loader
			end
			previous_loader = entry.loader
		end
		if any_exists("furnace", entry.beltbox) then
			if previous_beltbox then
				data.raw.furnace[previous_beltbox].next_upgrade = entry.beltbox
			end
			previous_beltbox = entry.beltbox
		end
	end
end

---------------------------------------------------------------------------------------------------
-- flat upgrade costs for every tier in the chain
---------------------------------------------------------------------------------------------------

if CONFIG.reprice_existing_tiers then
	for _, entry in ipairs(CHAIN) do
		local loader_recipe = data.raw.recipe[entry.loader]
		if loader_recipe and any_exists("transport-belt", entry.belt) then
			loader_recipe.ingredients = loader_ingredients(entry.belt)
			-- the vanilla/Space Age high tier recipes used lubricant; the flat recipe doesn't, so
			-- it is a plain crafting recipe and can also be hand-crafted again
			loader_recipe.category = "crafting"
		end
	end

	if CONFIG.beltbox_recipes == "upgrade" then
		for _, entry in ipairs(CHAIN) do
			local beltbox_recipe = data.raw.recipe[entry.beltbox]
			if beltbox_recipe and any_exists("transport-belt", entry.belt) then
				beltbox_recipe.ingredients = beltbox_ingredients({belt = entry.belt, beltbox_plate = 10, beltbox_gear = 10})
				beltbox_recipe.category = "crafting"
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- keep the stacking technologies in a sensible order
---------------------------------------------------------------------------------------------------

if data.raw.technology["deadlock-stacking-5"] and data.raw.technology["deadlock-stacking-4"] then
	local found = false
	for _, tech_name in pairs(data.raw.technology["deadlock-stacking-5"].prerequisites or {}) do
		if tech_name == "deadlock-stacking-4" then
			found = true
			break
		end
	end
	if not found then
		data.raw.technology["deadlock-stacking-5"].prerequisites = data.raw.technology["deadlock-stacking-5"].prerequisites or {}
		table.insert(data.raw.technology["deadlock-stacking-5"].prerequisites, "deadlock-stacking-4")
	end
end

---------------------------------------------------------------------------------------------------

if #created > 0 then
	log(string.format("DBL: Bob's Logistics integration created tiers for: %s", table.concat(created, ", ")))
end
if #skipped > 0 then
	log(string.format("DBL: Bob's Logistics integration skipped: %s", table.concat(skipped, ", ")))
end

return true
