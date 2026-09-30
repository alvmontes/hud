Utils = {}

local directions = { 'N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO' }

function Utils.Clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function Utils.Round(value)
    return math.floor(value + 0.5)
end

-- El heading de GTA gira en sentido antihorario (90 = oeste), por eso se invierte
function Utils.Compass(heading)
    local deg = (360.0 - heading) % 360.0
    return directions[(math.floor((deg + 22.5) / 45.0) % 8) + 1]
end

-- Posición del minimapa en fracciones de pantalla (0-1), según safezone y aspect ratio
function Utils.GetMinimapAnchor()
    local safezone = GetSafeZoneSize()
    local margin = (1.0 - safezone) * 0.5
    local aspect = GetAspectRatio(false)

    local width = 1.0 / (4.0 * aspect)
    local height = 1.0 / 5.674
    local bottom = 1.0 - margin

    return {
        left = margin,
        bottom = bottom,
        top = bottom - height,
        width = width,
    }
end

function Utils.GetFuel(vehicle)
    if Config.Fuel == 'LegacyFuel' and GetResourceState('LegacyFuel') == 'started' then
        return exports['LegacyFuel']:GetFuel(vehicle)
    end

    if Config.Fuel == 'ox_fuel' then
        local fuel = Entity(vehicle).state.fuel
        if fuel then return fuel end
    end

    local tank = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume')
    if tank <= 0.0 then return nil end -- eléctricos / sin depósito
    return GetVehicleFuelLevel(vehicle) / tank * 100.0
end
