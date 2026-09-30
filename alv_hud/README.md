# alv_hud

HUD minimalista para FiveM. Standalone: no necesita ningún framework, pero se integra solo con **esx_status** (hambre/sed) y **pma-voice** (modo de voz / radio) si los tienes.

## Qué muestra

**A pie** (esquina inferior izquierda, sin minimapa):
- Vida, armadura, hambre, sed, stamina, oxígeno (solo bajo el agua) y voz.
- Los indicadores se ocultan cuando no aportan nada: la armadura si es 0, la stamina si está llena, el oxígeno fuera del agua.
- Vida, hambre, sed y oxígeno parpadean en rojo por debajo de `Config.LowThreshold`.
- El micrófono se ilumina al hablar (verde) o por radio (rojo), y el anillo indica el alcance de voz.

**En vehículo:**
- Aparece el minimapa y los indicadores suben automáticamente encima de él.
- Brújula, calle y zona.
- Velocímetro (km/h o mph), marcha, barra de RPM, combustible y aviso de motor dañado.

El HUD se oculta solo con el menú de pausa y con la pantalla en negro.

## Instalación

1. Copia la carpeta `alv_hud` a `resources/`.
2. Añade a tu `server.cfg`, **después** de `esx_status` / `pma-voice` si los usas:
   ```cfg
   ensure alv_hud
   ```
3. Ajusta `config.lua` a tu servidor.

## Configuración

Todo está en `config.lua`. Lo más habitual:

| Opción | Descripción |
| --- | --- |
| `Config.SpeedUnit` | `'kmh'` o `'mph'` |
| `Config.MinimapOnlyInVehicle` | Oculta el minimapa a pie |
| `Config.ShowLocation` | `'vehicle'`, `'always'` o `'never'` |
| `Config.Fuel` | `'native'`, `'LegacyFuel'` u `'ox_fuel'` |
| `Config.Voice.modes` | Nº de modos de alcance de tu pma-voice |
| `Config.AutoHide.statusAbove` | Oculta hambre/sed por encima de ese % (`nil` = siempre visibles) |

Los colores se cambian en las variables del principio de `html/style.css`.

## Comando

- `/hud` — mostrar / ocultar el HUD.

## Exports (cliente)

```lua
exports.alv_hud:SetVisible(false)     -- ocultar (p. ej. en una cinemática)
exports.alv_hud:IsVisible()           -- true / false

-- Si tu hambre/sed no viene de esx_status, envíalas tú (0-100):
exports.alv_hud:SetStatus('hunger', 75)
exports.alv_hud:SetStatus('thirst', 40)
```
