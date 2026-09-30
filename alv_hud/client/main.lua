local hudVisible = true
local lastPayload = nil
local radarShown = nil

local status = {}     -- hunger / thirst u otros estados externos (0-100)
local voice = {
    mode = Config.Voice.defaultMode,
    radio = false,
}

local location = nil
local nextLocationUpdate = 0
local anchor = nil
local nextAnchorUpdate = 0

local speedFactor = Config.SpeedUnit == 'mph' and 2.236936 or 3.6

-- ---------------------------------------------------------------------------
-- Integraciones externas (todas opcionales)
-- ---------------------------------------------------------------------------

-- esx_status envía { name, val, percent } de cada estado en cada tick
AddEventHandler('esx_status:onTick', function(data)
    for i = 1, #data do
        local s = data[i]
        if Config.Status[s.name] then
            status[s.name] = s.percent
        end
    end
end)

AddEventHandler('pma-voice:setTalkingMode', function(mode)
    voice.mode = mode
end)

AddEventHandler('pma-voice:radioActive', function(active)
    voice.radio = active
end)

-- ---------------------------------------------------------------------------
-- Recolección de datos
-- ---------------------------------------------------------------------------

local function percent(value)
    return Utils.Round(Utils.Clamp(value, 0.0, 100.0))
end

local function getPlayerData(ped, player)
    local maxHealth = GetEntityMaxHealth(ped) - 100
    local health = maxHealth > 0 and (GetEntityHealth(ped) - 100) / maxHealth * 100.0 or 0.0
    if IsEntityDead(ped) then health = 0.0 end

    local data = {
        health = percent(health),
        armor = percent(GetPedArmour(ped)),
        stamina = percent(100.0 - GetPlayerSprintStaminaRemaining(player)),
        hunger = status.hunger and percent(status.hunger) or nil,
        thirst = status.thirst and percent(status.thirst) or nil,
    }

    if IsPedSwimmingUnderWater(ped) then
        data.oxygen = percent(GetPlayerUnderwaterTimeRemaining(player) * 10.0)
    end

    if Config.Voice.enabled then
        data.voice = {
            mode = voice.mode,
            modes = Config.Voice.modes,
            talking = NetworkIsPlayerTalking(player),
            radio = voice.radio,
        }
    end

    return data
end

local function getVehicleData(vehicle)
    local gear = GetVehicleCurrentGear(vehicle)
    local speed = GetEntitySpeed(vehicle) * speedFactor
    local fuel = GetVehicleClass(vehicle) ~= 13 and Utils.GetFuel(vehicle) or nil

    return {
        speed = Utils.Round(speed),
        rpm = percent(GetVehicleCurrentRpm(vehicle) * 100.0),
        gear = gear == 0 and 'R' or (speed < 1.0 and gear == 1 and 'N' or tostring(gear)),
        fuel = fuel and percent(fuel) or nil,
        engine = percent(GetVehicleEngineHealth(vehicle) / 10.0),
    }
end

local function getLocation(ped)
    local coords = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)

    return {
        compass = Utils.Compass(GetEntityHeading(ped)),
        street = GetStreetNameFromHashKey(streetHash),
        zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z)),
    }
end

local function setRadar(show)
    if radarShown == show then return end
    radarShown = show
    DisplayRadar(show)
end

-- ---------------------------------------------------------------------------
-- Bucle principal: solo envía a la NUI cuando algo cambia
-- ---------------------------------------------------------------------------

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(500) end

    SendNUIMessage({
        action = 'config',
        data = {
            unit = Config.SpeedUnit == 'mph' and 'MPH' or 'KM/H',
            autoHide = Config.AutoHide,
            lowThreshold = Config.LowThreshold,
        },
    })

    while true do
        local ped = PlayerPedId()
        local player = PlayerId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        local inVehicle = vehicle ~= 0
        local now = GetGameTimer()

        setRadar(inVehicle or not Config.MinimapOnlyInVehicle)

        if now >= nextAnchorUpdate then
            anchor = Utils.GetMinimapAnchor()
            nextAnchorUpdate = now + 5000
        end

        local showLocation = Config.ShowLocation == 'always' or (Config.ShowLocation == 'vehicle' and inVehicle)
        if not showLocation then
            location = nil
        elseif now >= nextLocationUpdate or not location then
            location = getLocation(ped)
            nextLocationUpdate = now + 500
        end

        local data = {
            visible = hudVisible and not IsPauseMenuActive() and not IsScreenFadedOut(),
            radar = radarShown,
            anchor = anchor,
            player = getPlayerData(ped, player),
            vehicle = inVehicle and getVehicleData(vehicle) or false,
            location = location or false,
        }

        local payload = json.encode(data)
        if payload ~= lastPayload then
            lastPayload = payload
            SendNUIMessage({ action = 'update', data = data })
        end

        Wait(inVehicle and Config.Interval.vehicle or Config.Interval.onFoot)
    end
end)

-- ---------------------------------------------------------------------------
-- Ocultar elementos nativos (requiere ejecutarse cada frame)
-- ---------------------------------------------------------------------------

if Config.HideDefaultHud or Config.HideMinimapBars then
    CreateThread(function()
        local minimap

        if Config.HideMinimapBars then
            minimap = RequestScaleformMovie('minimap')
            while not HasScaleformMovieLoaded(minimap) do Wait(0) end
            -- fuerza al minimapa a recargar su layout
            SetRadarBigmapEnabled(true, false)
            Wait(0)
            SetRadarBigmapEnabled(false, false)
        end

        while true do
            if Config.HideDefaultHud then
                HideHudComponentThisFrame(6)  -- nombre del vehículo
                HideHudComponentThisFrame(7)  -- nombre de la zona
                HideHudComponentThisFrame(8)  -- clase del vehículo
                HideHudComponentThisFrame(9)  -- nombre de la calle
            end

            if minimap then
                BeginScaleformMovieMethod(minimap, 'SETUP_HEALTH_ARMOUR')
                ScaleformMovieMethodAddParamInt(3)
                EndScaleformMovieMethod()
            end

            Wait(0)
        end
    end)
end

-- ---------------------------------------------------------------------------
-- Comando y exports
-- ---------------------------------------------------------------------------

local function setVisible(state)
    hudVisible = state and true or false
    lastPayload = nil -- fuerza reenvío inmediato
end

RegisterCommand(Config.Command, function()
    setVisible(not hudVisible)
end, false)

TriggerEvent('chat:addSuggestion', '/' .. Config.Command, 'Mostrar / ocultar el HUD')

exports('SetVisible', setVisible)
exports('IsVisible', function() return hudVisible end)

-- Para sistemas de hambre/sed que no sean esx_status: exports.alv_hud:SetStatus('hunger', 75)
exports('SetStatus', function(name, value)
    status[name] = value and Utils.Clamp(value + 0.0, 0.0, 100.0) or nil
end)
