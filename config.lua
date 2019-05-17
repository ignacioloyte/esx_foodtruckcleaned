Config                        = {}
Config.DrawDistance           = 100.0
Config.Locale                 = 'en'

local seconde = 1000
local minute = 60 * seconde

Config.Fridge = {
	meat = 300,
	packaged_chicken = 100,
	bread = 200,
	water = 100,
	cola = 100,
	vegetables = 100,
	levadura = 100
} -- maxquantity


Config.Zones = {
	
	Market = {
		Pos   = {x = -2511.07, y = 3615.16, z = 12.6714},
		Size  = {x = 1.5, y = 1.5, z = 0.4},
		Color = {r = 0, g = 255, b = 0},
		Type  = 1
	}
}