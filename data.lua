-- internal functions for prototype manipulation
require("prototypes.create_beltbox")
require("prototypes.create_loader")
require("prototypes.create_stack")
-- mod API
require("prototypes.public")
-- vanilla tiers
require("prototypes.vanilla_tiers")

-- stacking loaders: unlock the recipes and link the tiers created above
deadlock.update_stack_loaders()
