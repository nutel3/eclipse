local UI = {}
UI.__index = UI

local Tab = {}
Tab.__index = Tab

local COLOR_FONDO = Color3.fromRGB(25, 25, 30)
local COLOR_BOTON = Color3.fromRGB(45, 45, 55)
local COLOR_ACTIVO = Color3.fromRGB(40, 120, 70)
local COLOR_PESTANA_ON = Color3.fromRGB(70, 70, 90)

local function crearBoton(padre, texto)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = COLOR_BOTON
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.Text = texto
    b.Parent = padre
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

function Tab:AddButton(texto, callback)
    local b = crearBoton(self.Lista, texto)
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then warn("Error en botón '" .. texto .. "': " .. tostring(err)) end
    end)
end

function Tab:AddToggle(texto, callback)
    local estado = false
    local b = crearBoton(self.Lista, texto .. ": OFF")
    b.MouseButton1Click:Connect(function()
        estado = not estado
        b.Text = texto .. ": " .. (estado and "ON" or "OFF")
        b.BackgroundColor3 = estado and COLOR_ACTIVO or COLOR_BOTON
        local ok, err = pcall(callback, estado)
        if not ok then warn("Error en toggle '" .. texto .. "': " .. tostring(err)) end
    end)
end

function UI.CrearVentana(titulo)
    local padre = (gethui and gethui()) or game:GetService("CoreGui")

    local viejo = padre:FindFirstChild("MiHub")
    if viejo then viejo:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MiHub"
    gui.ResetOnSpawn = false
    gui.Parent = padre

    local ALTO = 340
    local marco = Instance.new("Frame")
    marco.Size = UDim2.fromOffset(320, ALTO)
    marco.AnchorPoint = Vector2.new(0.5, 0.5)
    marco.Position = UDim2.fromScale(0.5, 0.5)
    marco.BackgroundColor3 = COLOR_FONDO
    marco.Active = true
    marco.Draggable = true
    marco.ClipsDescendants = true
    marco.Parent = gui
    Instance.new("UICorner", marco).CornerRadius = UDim.new(0, 8)

    -- Barra superior
    local barra = Instance.new("TextLabel")
    barra.Size = UDim2.new(1, -80, 0, 36)
    barra.Position = UDim2.fromOffset(10, 0)
    barra.BackgroundTransparency = 1
    barra.Text = titulo
    barra.TextXAlignment = Enum.TextXAlignment.Left
    barra.TextColor3 = Color3.new(1, 1, 1)
    barra.Font = Enum.Font.GothamBold
    barra.TextSize = 16
    barra.Parent = marco

    local function botonBarra(texto, posX)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(28, 24)
        b.Position = UDim2.new(1, posX, 0, 6)
        b.BackgroundColor3 = COLOR_BOTON
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.Text = texto
        b.Parent = marco
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        return b
    end

    local btnMin = botonBarra("-", -64)
    local btnCerrar = botonBarra("X", -32)

    -- Contenido (se oculta al minimizar)
    local contenido = Instance.new("Frame")
    contenido.Position = UDim2.fromOffset(0, 36)
    contenido.Size = UDim2.new(1, 0, 1, -36)
    contenido.BackgroundTransparency = 1
    contenido.Parent = marco

    local barraTabs = Instance.new("Frame")
    barraTabs.Position = UDim2.fromOffset(10, 4)
    barraTabs.Size = UDim2.new(1, -20, 0, 30)
    barraTabs.BackgroundTransparency = 1
    barraTabs.Parent = contenido
    local lt = Instance.new("UIListLayout")
    lt.FillDirection = Enum.FillDirection.Horizontal
    lt.Padding = UDim.new(0, 4)
    lt.Parent = barraTabs

    local minimizado = false
    btnMin.MouseButton1Click:Connect(function()
        minimizado = not minimizado
        contenido.Visible = not minimizado
        marco.Size = minimizado and UDim2.fromOffset(320, 36) or UDim2.fromOffset(320, ALTO)
    end)

    btnCerrar.MouseButton1Click:Connect(function()
        if getgenv().HubAlCerrar then
            pcall(getgenv().HubAlCerrar)
        end
        gui:Destroy()
    end)

    -- Tecla para ocultar/mostrar: RightShift
    local UIS = game:GetService("UserInputService")
    local conexion = UIS.InputBegan:Connect(function(input, procesado)
        if not procesado and input.KeyCode == Enum.KeyCode.RightShift then
            marco.Visible = not marco.Visible
        end
    end)
    gui.Destroying:Connect(function() conexion:Disconnect() end)

    return setmetatable({
        Gui = gui,
        Contenido = contenido,
        BarraTabs = barraTabs,
        Tabs = {},
    }, UI)
end

function UI:AddTab(nombre)
    local boton = Instance.new("TextButton")
    boton.Size = UDim2.new(0, 90, 1, 0)
    boton.BackgroundColor3 = COLOR_BOTON
    boton.TextColor3 = Color3.new(1, 1, 1)
    boton.Font = Enum.Font.GothamMedium
    boton.TextSize = 13
    boton.Text = nombre
    boton.Parent = self.BarraTabs
    Instance.new("UICorner", boton).CornerRadius = UDim.new(0, 6)

    local pagina = Instance.new("ScrollingFrame")
    pagina.Position = UDim2.fromOffset(10, 42)
    pagina.Size = UDim2.new(1, -20, 1, -52)
    pagina.BackgroundTransparency = 1
    pagina.BorderSizePixel = 0
    pagina.ScrollBarThickness = 4
    pagina.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pagina.CanvasSize = UDim2.new()
    pagina.Visible = false
    pagina.Parent = self.Contenido

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = pagina

    local entrada = { boton = boton, pagina = pagina }
    table.insert(self.Tabs, entrada)

    local function seleccionar()
        for _, t in ipairs(self.Tabs) do
            t.pagina.Visible = false
            t.boton.BackgroundColor3 = COLOR_BOTON
        end
        pagina.Visible = true
        boton.BackgroundColor3 = COLOR_PESTANA_ON
    end

    boton.MouseButton1Click:Connect(seleccionar)
    if #self.Tabs == 1 then seleccionar() end

    return setmetatable({ Lista = pagina }, Tab)
end

return UI
