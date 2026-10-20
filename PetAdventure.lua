local UI = loadstring(game:HttpGet(getgenv().HUB_BASE .. "UI.lua"))()
local ventana = UI.CrearVentana("Pet Adventure")

ventana:AddButton("Saludar", function()
    print("Hola, " .. game:GetService("Players").LocalPlayer.Name)
end)

ventana:AddToggle("Prueba", function(estado)
    print("Prueba:", estado)
end)
