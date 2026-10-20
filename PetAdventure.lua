local UI = loadstring(game:HttpGet(getgenv().HUB_BASE .. "UI.lua"))()
local ventana = UI.CrearVentana("Pet Adventure")

local Players = game:GetService("Players")
local jugador = Players.LocalPlayer

local function humanoide()
    return jugador.Character and jugador.Character:FindFirstChildOfClass("Humanoid")
end

-- Pestaña 1: Principal (aquí irán las funciones del juego)
local principal = ventana:AddTab("Principal")
principal:AddToggle("Anti-AFK", function(estado)
    if estado then
        getgenv().AntiAfkConexion = jugador.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    elseif getgenv().AntiAfkConexion then
        getgenv().AntiAfkConexion:Disconnect()
    end
end)

-- Pestaña 2: Jugador
local tabJugador = ventana:AddTab("Jugador")
tabJugador:AddButton("Velocidad x2", function()
    local h = humanoide()
    if h then h.WalkSpeed = 32 end
end)
tabJugador:AddButton("Velocidad normal", function()
    local h = humanoide()
    if h then h.WalkSpeed = 16 end
end)

-- Pestaña 3: Ajustes
local ajustes = ventana:AddTab("Ajustes")
ajustes:AddButton("Cerrar menú", function()
    ventana.Gui:Destroy()
end)
