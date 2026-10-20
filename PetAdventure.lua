local UI = loadstring(game:HttpGet(getgenv().HUB_BASE .. "UI.lua"))()
local ventana = UI.CrearVentana("Pet Adventure")

local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Players = game:GetService("Players")
local jugador = Players.LocalPlayer

local function humanoide()
    return jugador.Character and jugador.Character:FindFirstChildOfClass("Humanoid")
end

-- ========== PESTAÑAS ==========
local principal = ventana:AddTab("Principal")
local tabJugador = ventana:AddTab("Jugador")
local ajustes = ventana:AddTab("Ajustes")

-- ========== PRINCIPAL: Anti-AFK ==========
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

-- ========== PRINCIPAL: ESP de huevos ==========

-- true = mostrar, false = ocultar. Cambia lo que quieras.
local MOSTRAR = {
    Common = false,
    Uncommon = false,
    Rare = false,
    Epic = false,       -- Supremo
    Legendary = false,  -- Celestial
    Mythic = true,      -- Trascendental
    Secret = true,      -- Secreta
    Prismatic = true,   -- Prismática
}
local AVISAR = true -- notificación en pantalla cuando aparece uno nuevo
local COLOR_FIJO = { Secret = Color3.fromRGB(255, 255, 255) }

-- Nombres de mascotas y de rarezas, leídos del catálogo del juego
local NOMBRES, RAREZAS = {}, {}
pcall(function()
    local Catalogo = require(RS.Shared.Catalogo)
    for _, e in pairs(Catalogo.Especies) do
        if e.id then NOMBRES[e.id] = e.nombreEs or e.nombre or e.id end
    end
    for clave, r in pairs(Catalogo.Rarezas) do
        RAREZAS[clave] = {
            nombre = r.nombreEs or r.nombre or clave,
            color = (typeof(r.color) == "Color3") and r.color or nil,
        }
    end
end)

local contenedor
local marcas = {}
local conexiones = {}
local avisados = {}
local activo = false
local ciclo = 0

local function limpiarMarca(huevo)
    local m = marcas[huevo]
    if m then
        m.carpeta:Destroy()
        marcas[huevo] = nil
    end
end

local function refrescar(huevo, nuevo, intentos)
    intentos = intentos or 0
    limpiarMarca(huevo)
    if not activo or not huevo.Parent then return end

    local rareza = huevo:GetAttribute("Rareza")
    if not rareza or MOSTRAR[rareza] == false then return end

    local parte = huevo:FindFirstChildWhichIsA("BasePart", true)
    if not parte then
        if intentos < 5 then
            task.delay(1, function() refrescar(huevo, nuevo, intentos + 1) end)
        end
        return
    end

    local info = RAREZAS[rareza]
    local nombreRareza = info and info.nombre or rareza
    local color = COLOR_FIJO[rareza] or (info and info.color) or Color3.fromRGB(255, 60, 200)
    local especie = huevo:GetAttribute("Especie") or "?"
    local nombre = NOMBRES[especie] or especie
    local bioma = huevo:GetAttribute("Bioma") or ""

    local carpeta = Instance.new("Folder")
    carpeta.Parent = contenedor

    local brillo = Instance.new("Highlight")
    brillo.Adornee = huevo
    brillo.FillColor = color
    brillo.OutlineColor = Color3.new(1, 1, 1)
    brillo.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    brillo.Parent = carpeta

    local gui = Instance.new("BillboardGui")
    gui.Adornee = parte
    gui.AlwaysOnTop = true
    gui.Size = UDim2.fromOffset(200, 50)
    gui.StudsOffset = Vector3.new(0, 4, 0)
    gui.Parent = carpeta

    local texto = Instance.new("TextLabel")
    texto.Size = UDim2.fromScale(1, 1)
    texto.BackgroundTransparency = 1
    texto.TextColor3 = color
    texto.TextStrokeTransparency = 0
    texto.Font = Enum.Font.GothamBold
    texto.TextSize = 14
    texto.Parent = gui

    marcas[huevo] = {
        carpeta = carpeta,
        texto = texto,
        parte = parte,
        base = nombre .. "\n" .. nombreRareza .. " | " .. bioma,
    }

    if nuevo and AVISAR and not avisados[huevo] then
        avisados[huevo] = true
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Huevo " .. nombreRareza,
                Text = nombre .. " (" .. bioma .. ")",
                Duration = 8,
            })
        end)
    end
end

local function vigilar(huevo, nuevo)
    if not huevo:IsA("Model") then return end
    refrescar(huevo, nuevo)
    table.insert(conexiones, huevo:GetAttributeChangedSignal("Rareza"):Connect(function()
        refrescar(huevo, true)
    end))
end

local function ESPHuevos(estado)
    activo = estado
    ciclo = ciclo + 1

    if not estado then
        for _, c in ipairs(conexiones) do c:Disconnect() end
        conexiones = {}
        if contenedor then contenedor:Destroy() end
        marcas = {}
        avisados = {}
        return
    end

    contenedor = Instance.new("Folder")
    contenedor.Name = "EspHuevos"
    contenedor.Parent = (gethui and gethui()) or game:GetService("CoreGui")

    for _, nombreCarpeta in ipairs({ "HuevosMundo", "HuevosCaidos" }) do
        local carpeta = WS:FindFirstChild(nombreCarpeta)
        if carpeta then
            for _, huevo in ipairs(carpeta:GetChildren()) do vigilar(huevo, false) end
            table.insert(conexiones, carpeta.ChildAdded:Connect(function(h)
                task.wait(0.5) -- esperar a que carguen sus atributos
                vigilar(h, true)
            end))
            table.insert(conexiones, carpeta.ChildRemoved:Connect(limpiarMarca))
        end
    end

    -- Distancia, cada medio segundo
    local miCiclo = ciclo
    task.spawn(function()
        while activo and ciclo == miCiclo do
            local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
            for _, m in pairs(marcas) do
                if raiz and m.parte.Parent then
                    local d = math.floor((m.parte.Position - raiz.Position).Magnitude)
                    m.texto.Text = m.base .. " | " .. d .. "m"
                end
            end
            task.wait(0.5)
        end
    end)
end

principal:AddToggle("ESP huevos raros", ESPHuevos)

-- ========== JUGADOR ==========
tabJugador:AddButton("Velocidad x2", function()
    local h = humanoide()
    if h then h.WalkSpeed = 32 end
end)
tabJugador:AddButton("Velocidad normal", function()
    local h = humanoide()
    if h then h.WalkSpeed = 16 end
end)

-- ========== AJUSTES ==========
ajustes:AddButton("Cerrar menú", function()
    ventana.Gui:Destroy()
end)
