-- Bob's Logistics: loaders and beltboxes for Bob's extra belt tiers
if mods["boblogistics"] then
	require("prototypes.bob_tiers")
end

-- create vanilla stacks
require("prototypes.vanilla_stacks")

-- stacking loaders for the tiers added above (Bob's Logistics), plus any that had to wait for
-- Space Age's data to be loaded
deadlock.update_stack_loaders()

-- hit the subgroups again to cover any added since data.lua load
for _, group in pairs(data.raw["item-group"]) do
	if not data.raw["item-subgroup"][string.format("stacks-%s", group.name)] then
		data:extend({
			{
				type = "item-subgroup",
				name = string.format("stacks-%s", group.name),
				group = group.name,
				order = "zzzzz",
			},
		})
	end
end
