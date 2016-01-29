require "defines"
require "config"
--require "lib.printr"

local lists = {}

local function clear()
	lists.packs = {}
	lists.packs.player_main = {}
	lists.packs.player_quickbar = {}
	lists.damaged = {}
	lists.damaged.player_main = {}
	lists.damaged.player_quickbar = {}
end

local function repair_module_count(player)
	local armor = player.get_inventory(defines.inventory.player_armor)[1]
	local count = 0

	if armor.valid_for_read and armor.has_grid then
		for _, mod in pairs(armor.grid.equipment) do
			if mod.name == "repair-module" then
				count = count + 1
			end
		end
	end

	return count
end

local function scan_inventory(player, inv_label, ...)
	local arg = {...}
	local stack = nil
	local inv = player.get_inventory(defines.inventory[inv_label])

	for i = 1, #inv do
		stack = inv[i]

		if stack.valid_for_read then
			for _, func in pairs(arg) do
				func(player, stack, inv_label, i)
			end
		end
	end
end

local function find_packs(player, stack, inv_label, index)
	if stack.type == "repair-tool" then
		if not lists.packs[inv_label][player.index] then
			lists.packs[inv_label][player.index] = {}
		end

		lists.packs[inv_label][player.index][index] = stack
	end
end

local function find_damaged(player, stack, inv_label, index)
	if stack.health < 1 then
		if not lists.damaged[inv_label][player.index] then
			lists.damaged[inv_label][player.index] = {}
		end

		lists.damaged[inv_label][player.index][index] = stack
	end
end

local function build_lists(to_do_list)
	clear()

	for _, player in ipairs(game.players) do
		if player.controller_type == defines.controllers.character then
			scan_inventory(player, "player_quickbar", unpack(to_do_list))
			scan_inventory(player, "player_main", unpack(to_do_list))
		end
	end
end

local function select_pack(player)
	local num_packs = 0
	local selected = nil

	if lists.packs.player_quickbar[player.index] then
		for _, stack in pairs(lists.packs.player_quickbar[player.index]) do
			if not selected then
				selected = stack
			end
			num_packs = num_packs + 1
		end
	end

	if lists.packs.player_main[player.index] then
		for _, stack in pairs(lists.packs.player_main[player.index]) do
			if not selected then
				selected = stack
			end
			num_packs = num_packs + 1
		end
	end

	return num_packs, selected
end

local function handle_durability(selected_pack, player)
	local temp_durability = selected_pack.durability - (2 * config.packs.module_expense_multiplier)
	local temp_count = 0

	if temp_durability < 1 then
		temp_durability = 9000 -- durability gets automatically capped to item's max
		if selected_pack.count > 0 then
			temp_count = selected_pack.count - 1
			selected_pack.count = temp_count

			if temp_count == 0 then
				return false
			end
		end
	end

	selected_pack.durability = temp_durability
	return true
end

local function handle_repair()
	for _, player in ipairs(game.players) do
		if player.controller_type == defines.controllers.character then
			local in_use = 0
			local num_modules = repair_module_count(player)
			local num_packs = 0
			local selected_pack = nil

			if config.packs.enabled then
				num_packs, selected_pack = select_pack(player)
				if num_packs == 0 then
					break
				end
			end

			if num_modules > 0 then
				if lists.damaged.player_quickbar[player.index] then
					for slot, stack in pairs(lists.damaged.player_quickbar[player.index]) do
						if stack.valid_for_read and stack.health < 1 then
							if config.packs.enabled then
								if not handle_durability(selected_pack) then
									return
								end
							end

							stack.health = stack.health + 0.01
							in_use = in_use + 1
						end

						if in_use >= num_modules then
							break
						end
					end
				end

				if lists.damaged.player_main[player.index] and in_use < num_modules then
					for slot, stack in pairs(lists.damaged.player_main[player.index]) do
						if stack.valid_for_read and stack.health < 1 then
							if config.packs.enabled then
								if not handle_durability(selected_pack) then
									return
								end
							end

							stack.health = stack.health + 0.01
							in_use = in_use + 1

							if stack.health == 1 then
								-- This is a hacky way to force the inventory to resort, would prefer a better method
								stack.count = stack.count + 1
								stack.count = stack.count - 1
							end
						end

						if in_use >= num_modules then
							break
						end
					end
				end
			end
		end
	end
end


local to_do_list = {find_damaged}
if config.packs.enabled then
	table.insert(to_do_list, 1, find_packs)
end


script.on_init(clear)
script.on_load(clear)
script.on_event(defines.events.on_tick, function(event)
	if game.tick % 15 == 0 then
		build_lists(to_do_list)
	end

	-- Schedule repairs one tick after list is rebuilt
	if (game.tick % 15 - 1) == 0 then
		handle_repair()
	end
end)
