Config = {}

-- Comando para mostrar/ocultar el HUD
Config.Command = 'hud'

-- Unidad de velocidad: 'kmh' o 'mph'
Config.SpeedUnit = 'kmh'

-- Intervalos de actualización (ms). Más alto = menos consumo.
Config.Interval = {
    onFoot  = 250,
    vehicle = 100,
}

-- Minimapa solo dentro de un vehículo (look más limpio a pie)
Config.MinimapOnlyInVehicle = true

-- Quita las barras de vida/armadura nativas de debajo del minimapa
Config.HideMinimapBars = true

-- Oculta los textos nativos de GTA (nombre del vehículo, zona, calle...)
Config.HideDefaultHud = true

-- Muestra brújula + calle + zona. 'vehicle' = solo en coche, 'always' o 'never'
Config.ShowLocation = 'vehicle'

-- Sistema de combustible: 'native', 'LegacyFuel' u 'ox_fuel'
Config.Fuel = 'native'

-- Indicador de voz (usa NetworkIsPlayerTalking; el modo de alcance se lee de pma-voice si existe)
Config.Voice = {
    enabled = true,
    modes = 3,       -- nº de modos de alcance configurados en pma-voice
    defaultMode = 2,
}

-- Estados de esx_status (hambre/sed). Si esx_status no está, simplemente no se muestran.
Config.Status = {
    hunger = true,
    thirst = true,
}

-- Autoocultado: los círculos solo aparecen cuando son relevantes
Config.AutoHide = {
    armor   = true, -- oculta la armadura si es 0
    stamina = true, -- oculta la stamina si está llena
    -- oculta hambre/sed por encima de este % (nil = siempre visibles)
    statusAbove = nil,
}

-- Umbral (%) a partir del cual un indicador parpadea en rojo
Config.LowThreshold = 20
