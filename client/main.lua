ESX                             = nil
local PlayerData                = {}
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local OnJob                     = false
local Cooking 					= false
local FoodInPlace				= nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)



RegisterNetEvent('esx_foodtruck:refreshMarket')
AddEventHandler('esx_foodtruck:refreshMarket', function()
	OpenFoodTruckMarketMenu()
end)

function OpenFoodTruckMarketMenu()
	if PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_foodtruck:getStock', function(fridge, MarketPrices)

			local elements = {
				head = {_U('ingredients'), _U('price_unit'), _U('on_you'), _U('action')},
				rows = {}
			}

			local itemName = nil
			local price = nil

			for j=1, #MarketPrices, 1 do

				for i=1, #fridge, 1 do
					if fridge[i].name == MarketPrices[j].item then
						table.insert(elements.rows,
						{
							data = fridge[i],
							cols = {
								MarketPrices[j].label,
								MarketPrices[j].price,
								tostring(fridge[i].count),
								'{{' .. _U('buy_10') .. '|buy10}} {{' .. _U('buy_50') .. '|buy50}}'
							}
						})

						break
					end
				end

			end

			ESX.UI.Menu.CloseAll()

			ESX.UI.Menu.Open(
				'list', GetCurrentResourceName(), 'restaurante', elements,
				function(data, menu)
					if data.value == 'buy10' then
						TriggerServerEvent('esx_foodtruck:buyItem', 10, data.data.name)
					elseif data.value == 'buy50' then
						TriggerServerEvent('esx_foodtruck:buyItem', 50, data.data.name)
					end
					menu.close()
				end,
				function(data, menu)
					menu.close()
					CurrentAction     = 'foodtruck_market_menu'
					CurrentActionMsg  = _U('foodtruck_market_menu')
					CurrentActionData = {}
				end
			)
		end)
	else
		ESX.ShowNotification(_U('need_more_exp'))
	end
end



RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

AddEventHandler('esx_foodtruck:hasEnteredMarker', function(zone)
	Citizen.Trace('zone: ' .. zone)
	
	if zone == 'Market' then
		CurrentAction     = 'foodtruck_market'
		CurrentActionMsg  = _U('foodtruck_market_menu')
		CurrentActionData = {}
	end
	
end)

AddEventHandler('esx_foodtruck:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)


-- Create Blips
Citizen.CreateThread(function()		

	blip = AddBlipForCoord(Config.Zones.Market.Pos.x, Config.Zones.Market.Pos.y, Config.Zones.Market.Pos.z)
	SetBlipSprite (blip, 52)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 1.0)
	SetBlipColour (blip, 5)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('blip_market'))
	EndTextCommandSetBlipName(blip)
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Wait(0)
		if PlayerData.job ~= nil and PlayerData.job.name == 'restaurante' then

			local coords = GetEntityCoords(GetPlayerPed(-1))

			for k,v in pairs(Config.Zones) do
				if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Wait(0)
		if PlayerData.job ~= nil and PlayerData.job.name == 'restaurante' then
			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil
			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end
			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('esx_foodtruck:hasEnteredMarker', currentZone)
			end
			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_foodtruck:hasExitedMarker', LastZone)
			end
		end
	end
end)



-- Key Controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if CurrentAction ~= nil then
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            
            if IsControlJustReleased(0, 38) and PlayerData.job ~= nil and PlayerData.job.name == 'restaurante' then

            	--TriggerServerEvent('esx:clientLog', 'PUSHING E')
                if 'foodtruck_market' then
                    OpenFoodTruckMarketMenu()
                end
                CurrentAction = nil

            end
            
        end

       
    end
end)