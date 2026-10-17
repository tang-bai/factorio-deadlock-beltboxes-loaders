local DBL = require("prototypes.shared")

local ICON_DIR    = "__deadlock-beltboxes-loaders-CN__/graphics/icons/mipmaps/"
-- Space Age's stack inserter icon, used as a badge on the stacking variant
local STACK_BADGE = "__space-age__/graphics/icons/stack-inserter.png"

local function create_loader_belt_component(source)
	local component = {
		filename    = source.filename,
		width       = source.width,
		height      = source.height,
		line_length = source.line_length,
		frame_count = source.frame_count,
		y           = source.y,
		scale       = source.scale,
		priority    = "extra-high",
		flags       = { "no-crop", "low-object" },
	}
	return component
end

-- normal loaders use the tinted loader icon; the stacking variant gets the Space Age stack
-- inserter icon as a badge in the bottom right corner so the two are easy to tell apart
local function create_loader_icons(tier_table, is_stack)
	local icons = {
		{ icon = ICON_DIR .. "loader-icon-base.png" },
		{ icon = ICON_DIR .. "loader-icon-mask.png", tint = tier_table.colour },
	}
	if is_stack then
		table.insert(icons, {
			icon = STACK_BADGE,
			icon_size = 64,
			scale = 0.45,
			shift = { 11, 11 },
		})
	end
	return icons
end

local function localised_loader_name(loader_name)
	if data.raw["loader-1x1"][loader_name] and data.raw["loader-1x1"][loader_name].localised_name then
		return data.raw["loader-1x1"][loader_name].localised_name
	end
	return { "entity-name." .. loader_name }
end

-- Tiers that know their own name (all the tiers this mod creates) point straight at their
-- locale key; anything else falls back to "loader name (stacking)", which works for every mod's
-- tiers without adding a translation for each one
local function stack_loader_localised_name(tier_table)
	if tier_table.stack_loader_localised_name then
		return tier_table.stack_loader_localised_name
	end
	return { "entity-name.deadlock-stack-loader", localised_loader_name(tier_table.loader) }
end

local function create_loader_entity(tier_table, is_stack)
	local name = is_stack and tier_table.stack_loader or tier_table.loader
	local item_name = is_stack and (tier_table.stack_loader_item or name) or (tier_table.loader_item or tier_table.loader)
	local entity = {}
	entity.type = "loader-1x1"
	entity.name = name
	if is_stack then
		entity.localised_name = stack_loader_localised_name(tier_table)
		entity.localised_description = {"entity-description.deadlock-stack-loader"}
	else
		entity.localised_description = {"entity-description.deadlock-loader"}
	end
	entity.icons = create_loader_icons(tier_table, is_stack)
	entity.icon_size = 64
	entity.icon_mipmaps = 4
	entity.flags = {"placeable-neutral", "player-creation"}
	entity.vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 1.0 }
	entity.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg", volume = 1.0 }
	entity.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg", volume = 1.0 }
	entity.corpse = "small-remnants"
	entity.collision_box = { {-0.26, -0.26}, {0.26, 0.26} }  -- 1.1 requires min of 0.5 width
	entity.collision_mask = {layers = {item = true, object = true, player = true, water_tile = true, transport_belt = true, meltable = true}}
	entity.selection_box = { {-0.5, -0.5}, {0.5, 0.5} }
	entity.minable = { hardness = 0.2, mining_time = 0.5, result = item_name }
	entity.max_health = 170
	entity.resistances = {{type = "fire", percent = 60 }}
	entity.belt_distance = 0.5
	entity.container_distance = 1
	entity.belt_length = 0.5
	entity.filter_count = 5
	entity.animation_speed_coefficient = 32
	if settings.startup["deadlock-strict-fast-replace-loaders"].value then
		-- the stacking variants share the group, so they can be fast replaced by/with loaders
		entity.fast_replaceable_group = "deadlock-loader"
	else
		entity.fast_replaceable_group = "transport-belt"
	end
	entity.speed = data.raw["transport-belt"][tier_table.transport_belt].speed
	-- stacking variant: same loader, but it moves whole stacks of items and layers those
	-- stacks onto belts, exactly like Space Age's stack inserter does
	if is_stack then
		entity.bulk = true
		entity.stack_size_bonus = DBL.STACK_LOADER_STACK_SIZE
		entity.max_belt_stack_size = DBL.STACK_LOADER_STACK_SIZE
		if DBL.STACK_LOADER_WAIT_FOR_FULL_STACK then
			entity.wait_for_full_stack = true
		end
	end
	entity.structure = {
		back_patch = {
			sheet = {
				filename = "__deadlock-beltboxes-loaders-CN__/graphics/entities/high/loader-back.png",
				height = 96,
				priority = "extra-high",
				width = 96,
				scale = 0.5,
				shift = { 0, 0 },
			},
		},
		direction_in = {
			sheets = {
				{
					draw_as_shadow = true,
					filename = "__deadlock-beltboxes-loaders-CN__/graphics/entities/high/loader-shadow.png",
					height = 96,
					priority = "medium",
					width = 144,
					scale = 0.5,
					shift = { 0.5, 0 },
				},
				{
					filename = "__deadlock-beltboxes-loaders-CN__/graphics/entities/high/loader-base.png",
					height = 96,
					priority = "extra-high",
					width = 96,
					scale = 0.5,
					shift = { 0, 0 },
				},
				{
					filename = "__deadlock-beltboxes-loaders-CN__/graphics/entities/high/loader-mask.png",
					height = 96,
					priority = "extra-high",
					width = 96,
					scale = 0.5,
					tint = tier_table.colour,
					shift = { 0, 0 },
				},
			},
		},
		direction_out = {
			sheets = {
				{
					draw_as_shadow = true,
					filename = "__deadlock-beltboxes-loaders-CN__/graphics/entities/high/loader-shadow.png",
					height = 96,
					priority = "medium",
					width = 144,
					scale = 0.5,
					shift = { 0.5, 0 },
				},
				{
					filename = "__deadlock-beltboxes-loaders-CN__/graphics/entities/high/loader-base.png",
					height = 96,
					priority = "extra-high",
					width = 96,
					scale = 0.5,
					shift = { 0, 0 },
					y = 96,
				},
				{
					filename = "__deadlock-beltboxes-loaders-CN__/graphics/entities/high/loader-mask.png",
					height = 96,
					priority = "extra-high",
					width = 96,
					scale = 0.5,
					shift = { 0, 0 },
					tint = tier_table.colour,
					y = 96
				},
			},
		}
	}
	-- copy belt textures from the belt, not the loader
	if data.raw["transport-belt"][tier_table.transport_belt].belt_animation_set then
		-- new style animation set
		entity.belt_animation_set = data.raw["transport-belt"][tier_table.transport_belt].belt_animation_set
	else
		-- old style, copy components
		for _, bc in ipairs(DBL.BELT_COMPONENTS) do
			if entity[bc] and data.raw["transport-belt"][tier_table.transport_belt][bc] then
				entity[bc] = create_loader_belt_component(data.raw["transport-belt"][tier_table.transport_belt][bc])
			end
		end
	end
	entity.structure_render_layer = "object"
	return entity
end

local function create_loader_item(tier_table, is_stack)
	local name = is_stack and (tier_table.stack_loader_item or tier_table.stack_loader) or (tier_table.loader_item or tier_table.loader)
	local item = {
		type = "item",
		name = name,
		localised_description = is_stack and {"entity-description.deadlock-stack-loader"} or {"entity-description.deadlock-loader"},
		icons = create_loader_icons(tier_table, is_stack),
		icon_size = 64,
		icon_mipmaps = 4,
		stack_size = 50,
		flags = {},
		place_result = is_stack and tier_table.stack_loader or tier_table.loader,
		group = "logistics",
		subgroup = is_stack and "stack-loaders" or "loaders",
		order = string.format("a%s%s", (tier_table.order or tier_table.loader), is_stack and "-deadlock-stack-loader" or "-deadlock-loader"),
	}
	if is_stack then
		item.localised_name = stack_loader_localised_name(tier_table)
	end
	return item
end

local function create_loader_recipe(tier_table, is_stack)
	-- the stacking variant: one tier's loader plus a stack inserter and a processing unit
	if is_stack then
		local name = tier_table.stack_loader_item or tier_table.stack_loader
		return {
			type = "recipe",
			name = name,
			localised_name = stack_loader_localised_name(tier_table),
			localised_description = {"entity-description.deadlock-stack-loader"},
			category = "crafting",
			group = "logistics",
			subgroup = "stack-loaders",
			order = string.format("a%s%s", (tier_table.order or tier_table.loader), "-deadlock-stack-loader"),
			enabled = false,
			ingredients = {
				{ type = "item", name = tier_table.loader_item or tier_table.loader, amount = 1 },
				{ type = "item", name = DBL.STACK_LOADER_INGREDIENT, amount = 1 },
				{ type = "item", name = "processing-unit", amount = 1 },
			},
			results = {{type = "item", name = name, amount = 1}},
			energy_required = 2.0,
		}
	end
	local recipe = {
		type = "recipe",
		name = tier_table.loader_recipe or tier_table.loader,
		localised_description = {"entity-description.deadlock-loader"},
		category = tier_table.loader_category,
		group = "logistics",
		subgroup = "loaders",
		order = string.format("a%s%s", (tier_table.order or tier_table.loader), "-deadlock-loader"),
		enabled = false,
		ingredients = tier_table.loader_ingredients,
		results = {{type = "item", name = tier_table.loader_item or tier_table.loader, amount = 1}},
		energy_required = 2.0,
	}
	if not tier_table.technology then
		recipe.enabled = true
	end
	return recipe
end

function DBL.create_loader(tier_table)
	DBL.debug(string.format("Generating loader for tier %s", tier_table.transport_belt))
	data:extend({
		create_loader_item(tier_table, false),
		create_loader_entity(tier_table, false),
		create_loader_recipe(tier_table, false),
	})
	-- insert the loader recipe into logistics unlock
	if tier_table.technology then
		local tech = data.raw.technology[tier_table.technology]
		if not tech then
			DBL.log_error(string.format("Bad tech specified for loader, %s", tier_table.technology))
			return
		end
		DBL.debug(string.format("Adding loader to tech %s", tier_table.technology))
		table.insert(tech.effects,
			{
				type = "unlock-recipe",
				recipe = tier_table.loader_recipe or tier_table.loader,
			}
		)
	end
	-- the stacking variant of the same tier
	if DBL.stack_loaders_available() then
		DBL.create_stack_loader(tier_table)
	elseif DBL.STACK_LOADER_ENABLED and mods["space-age"] then
		-- Space Age data isn't there yet (load order), retry from data-updates
		DBL.debug(string.format("Deferring stacking loader for tier %s", tier_table.transport_belt))
		table.insert(DBL.pending_stack_loader_tiers, tier_table)
	end
end

---------------------------------------------------------------------------------------------------
-- stacking loaders
--
-- Same machine as the normal loader of that tier, but the entity also gets the Space Age stacking
-- properties (bulk, stack_size_bonus, max_belt_stack_size), so it moves whole stacks of items and
-- layers those stacks onto belts. The recipes are unlocked by Space Age's own stack inserter
-- technology, and each recipe costs that tier's loader + a stack inserter + a processing unit.
---------------------------------------------------------------------------------------------------

function DBL.stack_loaders_available()
	if not DBL.STACK_LOADER_ENABLED then
		return false
	end
	-- belt stacking, the stack_size_bonus fields and the stack inserter all come from Space Age
	if not mods["space-age"] then
		return false
	end
	if not (data.raw.item[DBL.STACK_LOADER_INGREDIENT] and data.raw.technology[DBL.STACK_LOADER_TECH]) then
		if not DBL.stack_loader_availability_warned then
			DBL.stack_loader_availability_warned = true
			DBL.log_warning(string.format("Can't create stacking loaders yet: %s is missing", DBL.STACK_LOADER_INGREDIENT))
		end
		return false
	end
	return true
end

function DBL.create_stack_loader(tier_table)
	local name = tier_table.stack_loader
	if DBL.created_stack_loaders[name] then
		return
	end
	DBL.created_stack_loaders[name] = true
	DBL.debug(string.format("Generating stacking loader for tier %s", tier_table.transport_belt))
	data:extend({
		create_loader_item(tier_table, true),
		create_loader_entity(tier_table, true),
		create_loader_recipe(tier_table, true),
	})
	table.insert(DBL.stack_loader_tiers, {
		name = name,
		speed = data.raw["transport-belt"][tier_table.transport_belt].speed,
	})
	table.insert(DBL.stack_loader_recipes, tier_table.stack_loader_item or name)
	DBL.apply_stack_loader_unlocks()
end

-- recipes are unlocked by the stack inserter technology, which isn't necessarily in data.raw yet
-- when the tier is created, so this is called again from data-updates and data-final-fixes
function DBL.apply_stack_loader_unlocks()
	local tech = data.raw.technology[DBL.STACK_LOADER_TECH]
	if not tech then
		return
	end
	tech.effects = tech.effects or {}
	for _, recipe in ipairs(DBL.stack_loader_recipes) do
		if not DBL.stack_loader_unlocked[recipe] then
			table.insert(tech.effects, { type = "unlock-recipe", recipe = recipe })
			DBL.stack_loader_unlocked[recipe] = true
		end
	end
end

-- chain the stacking loaders together so fast replace and the upgrade planner can walk the tiers
function DBL.link_stack_loaders()
	local tiers = DBL.stack_loader_tiers
	if #tiers < 2 then
		return
	end
	table.sort(tiers, function(a, b) return a.speed < b.speed end)
	for i = 1, #tiers - 1 do
		local this = tiers[i]
		local following = tiers[i + 1]
		if data.raw["loader-1x1"][this.name] and data.raw["loader-1x1"][following.name] then
			data.raw["loader-1x1"][this.name].next_upgrade = following.name
		end
	end
end

-- called from data.lua, data-updates.lua and data-final-fixes.lua
function DBL.update_stack_loaders()
	if DBL.STACK_LOADER_ENABLED and mods["space-age"] and #DBL.pending_stack_loader_tiers > 0 and DBL.stack_loaders_available() then
		local pending = DBL.pending_stack_loader_tiers
		DBL.pending_stack_loader_tiers = {}
		for _, tier_table in ipairs(pending) do
			DBL.create_stack_loader(tier_table)
		end
	end
	DBL.apply_stack_loader_unlocks()
	DBL.link_stack_loaders()
end
