local UI = loadstring(game:HttpGet(getgenv().HUB_BASE .. "UI.lua"))()
local ventana = UI.CrearVentana("Pet Adventure")

local Players = game:GetService("Players")
local jugador = Players.LocalPlayer

-- Anti-AFK: evita que te saque por inactividad
ventana:AddToggle("Anti-AFK", function(estado)
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

-- Velocidad de caminata
ventana:AddButton("Velocidad x2", function()
    local humanoide = jugador.Character and jugador.Character:FindFirstChildOfClass("Humanoid")
    if humanoide then
        humanoide.WalkSpeed = 32
    end
end)

ventana:AddButton("Velocidad normal", function()
    local humanoide = jugador.Character and jugador.Character:FindFirstChildOfClass("Humanoid")
    if humanoide then
        humanoide.WalkSpeed = 16
    end
end)
