local UI = {}
UI.__index = UI

function UI.CrearVentana(titulo)
    local padre = (gethui and gethui()) or game:GetService("CoreGui")

    local viejo = padre:FindFirstChild("MiHub")
    if viejo then viejo:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MiHub"
    gui.ResetOnSpawn = false
    gui.Parent = padre

    local marco = Instance.new("Frame")
    marco.Size = UDim2.fromOffset(260, 320)
    marco.AnchorPoint = Vector2.new(0.5, 0.5)
    marco.Position = UDim2.fromScale(0.5, 0.5)
    marco.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    marco.Active = true
    marco.Draggable = true
    marco.Parent = gui
    Instance.new("UICorner", marco).CornerRadius = UDim.new(0, 8)

    local barra = Instance.new("TextLabel")
    barra.Size = UDim2.new(1, 0, 0, 36)
    barra.BackgroundTransparency = 1
    barra.Text = titulo
    barra.TextColor3 = Color3.new(1, 1, 1)
    barra.Font = Enum.Font.GothamBold
    barra.TextSize = 16
    barra.Parent = marco

    local lista = Instance.new("ScrollingFrame")
    lista.Position = UDim2.fromOffset(10, 42)
    lista.Size = UDim2.new(1, -20, 1, -52)
    lista.BackgroundTransparency = 1
    lista.BorderSizePixel = 0
    lista.ScrollBarThickness = 4
    lista.AutomaticCanvasSize = Enum.AutomaticSize.Y
    lista.CanvasSize = UDim2.new()
    lista.Parent = marco

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = lista

    return setmetatable({ Gui = gui, Lista = lista }, UI)
end

local function crearBoton(lista, texto)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.Text = texto
    b.AutoButtonColor = true
    b.Parent = lista
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

function UI:AddButton(texto, callback)
    local b = crearBoton(self.Lista, texto)
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then warn("Error en botón '" .. texto .. "': " .. tostring(err)) end
    end)
end

function UI:AddToggle(texto, callback)
    local estado = false
    local b = crearBoton(self.Lista, texto .. ": OFF")
    b.MouseButton1Click:Connect(function()
        estado = not estado
        b.Text = texto .. ": " .. (estado and "ON" or "OFF")
        b.BackgroundColor3 = estado and Color3.fromRGB(40, 120, 70) or Color3.fromRGB(45, 45, 55)
        local ok, err = pcall(callback, estado)
        if not ok then warn("Error en toggle '" .. texto .. "': " .. tostring(err)) end
    end)
end

return UI
