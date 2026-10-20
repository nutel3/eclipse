print("Hub cargado")

local BASE = "https://raw.githubusercontent.com/nutel3/eclipse/main/"
getgenv().HUB_BASE = BASE

local juegos = {
    [94727204064824]  = { nombre = "Pet Adventure", archivo = "PetAdventure.lua" },
    [121831322352666] = { nombre = "Dig For Eggs",  archivo = "DigForEggs.lua" },
}

local juego = juegos[game.PlaceId]

if not juego then
    warn("Juego no soportado")
    return
end

print("Cargando: " .. juego.nombre)

local ok, err = pcall(function()
    loadstring(game:HttpGet(BASE .. juego.archivo))()
end)

if not ok then
    warn("Error al cargar " .. juego.nombre .. ": " .. tostring(err))
end
