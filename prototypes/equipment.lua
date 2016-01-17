data:extend({
	{
		type = "movement-bonus-equipment",
		name = "repair-module",
		take_result = "repair-module",
		sprite = {
			filename = "__PocketRepair__/graphics/equip-repair-module.png",
			width = 64,
			height = 64,
			priority = "medium"
		},
		shape = {
			width = 2,
			height = 2,
			type = "full"
		},
		energy_source = {
			type = "electric",
			buffer_capacity = "1MJ",
			input_flow_limit = "100KW",
			usage_priority = "secondary-input"
		},
		energy_consumption = "10kW",
		movement_bonus = 0.0
	}
})
