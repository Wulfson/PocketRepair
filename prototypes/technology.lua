data:extend({
	{
		type = "technology",
		name = "repair-module",
		icon = "__PocketRepair__/graphics/tech-repair-module.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "repair-module"
			},
		},
		prerequisites = {"robotics", "solar-panel-equipment"},
		unit = {
			count = 50,
			ingredients = {
				{"science-pack-1", 1},
				{"science-pack-2", 1},
			},
			time = 30
		},
		order = "g-h-zz",
	}
})
