-- Don't mess with this bit
config = config or {}
config.packs = config.packs or {}
-----------------


-- Use repair packs for fuel
config.packs.enabled = true
-- Multiplies the durability loss of a repair pack when a module repairs 1 percent of health
-- The base amount a module drains is 2, so a mulitplier of 3 would make a total of 6
config.packs.module_expense_multiplier = 1.5


-- Amount of energy used by the repair module
-- Note: Due to limitations this currently only applies when moving
config.module_energy_consumption = "10kW"
