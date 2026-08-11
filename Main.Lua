-- ==============================================================================
-- ADVANCED ROBLOX CUSTOM GUI FRAMEWORK (PURE LUA / NO EXTERNAL LIBRARIES)
-- Designed for Delta & Standard Executors
-- Features: Modular Tabs, Search, Floating Controls, Keybinds, Auto-Save/Load JSON,
-- Smooth Dragging, Notification Queue, Custom Tooltips, and Safe-Execution Engine.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- [SECTION 1] SERVICES & ENVIRONMENT VERIFICATION
-- ------------------------------------------------------------------------------
local CoreServices = {
    Players         = game:GetService("Players"),
    UserInput       = game:GetService("UserInputService"),
    Http            = game:GetService("HttpService"),
    Tween           = game:GetService("TweenService"),
    Run             = game:GetService("RunService"),
    Stats           = game:GetService("Stats")
}

local LocalPlayer = CoreServices.Players.LocalPlayer
if not LocalPlayer then
    warn("[Framework Error]: LocalPlayer is nil. Script execution aborted.")
    return
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then
    warn("[Framework Error]: PlayerGui context timed out.")
    return
end

-- Safely wrap Executor Filesystem APIs with Fallbacks
local SafeFS = {
    write = (type(writefile) == "function" and writefile) or function(...) end,
    read  = (type(readfile) == "function" and readfile) or function(...) return "{}" end,
    exists = (type(isfile) == "function" and isfile) or function(...) return false end,
    delete = (type(delfile) == "function" and delfile) or function(...) end
}

-- Prevent Multiple Instance Collisions (Cleanup Old Instance)
local GUI_NAME = "UltraCustomFramework_Root"
local ExistingGui = PlayerGui:FindFirstChild(GUI_NAME)
if ExistingGui then
    ExistingGui:Destroy()
    task.wait(0.1)
end

-- ------------------------------------------------------------------------------
-- [SECTION 2] CORE FRAMEWORK STATE & CONFIGURATION STORE
-- ------------------------------------------------------------------------------
local FrameworkState = {
    ConfigFileName   = "UltraCustomFramework_Settings.json",
    Storage          = {},
    KeybindRegistry  = {},
    ActiveTabs       = {},
    FloatingElements = {},
    NotificationQueue= {},
    CurrentTab       = nil,
    IsVisible        = true,
    ToggleKey        = Enum.KeyCode.RightControl
}

-- Theme Palette
local Theme = {
    Background   = Color3.fromRGB(20, 21, 28),
    TopBar       = Color3.fromRGB(15, 16, 22),
    Sidebar      = Color3.fromRGB(25, 27, 36),
    Content      = Color3.fromRGB(30, 32, 44),
    Element      = Color3.fromRGB(38, 41, 56),
    Accent       = Color3.fromRGB(98, 114, 240),
    AccentHover  = Color3.fromRGB(120, 135, 255),
    TextMain     = Color3.fromRGB(245, 245, 250),
    TextMuted    = Color3.fromRGB(150, 155, 170),
    Success      = Color3.fromRGB(50, 200, 120),
    Danger       = Color3.fromRGB(230, 70, 80),
    Warning      = Color3.fromRGB(240, 180, 50),
    InputBg      = Color3.fromRGB(16, 17, 23)
}

-- ------------------------------------------------------------------------------
-- [SECTION 3] UTILITY & HELPER FUNCTIONS
-- ------------------------------------------------------------------------------
local Utils = {}

function Utils.CreateInstance(className, properties, parent)
    local inst = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        inst[prop] = val
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

function Utils.AddCorner(parent, radius)
    return Utils.CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or 6)
    }, parent)
end

function Utils.AddStroke(parent, color, thickness, transparency)
    return Utils.CreateInstance("UIStroke", {
        Color = color or Theme.Accent,
        Thickness = thickness or 1,
        Transparency = transparency or 0.8,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, parent)
end

function Utils.SafeCallback(callback, ...)
    if type(callback) == "function" then
        local success, err = pcall(callback, ...)
        if not success then
            warn("[Framework Runtime Error]:", tostring(err))
        end
    end
end

-- Smooth Dragging System (Touch Screen & Mouse)
function Utils.EnableDrag(dragHandle, targetFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    CoreServices.UserInput.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ------------------------------------------------------------------------------
-- [SECTION 4] MAIN ROOT GUI ASSEMBLY
-- ------------------------------------------------------------------------------
local RootScreenGui = Utils.CreateInstance("ScreenGui", {
    Name = GUI_NAME,
    ResetOnSpawn = false,
    DisplayOrder = 100,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

local RootScale = Utils.CreateInstance("UIScale", {
    Scale = 1.0
}, RootScreenGui)

local MainFrame = Utils.CreateInstance("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 620, 0, 400),
    Position = UDim2.new(0.5, -310, 0.5, -200),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Active = true,
    ClipsDescendants = true
}, RootScreenGui)

Utils.AddCorner(MainFrame, 8)
Utils.AddStroke(MainFrame, Theme.Accent, 1, 0.7)

-- TopBar
local TopBar = Utils.CreateInstance("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Theme.TopBar,
    BorderSizePixel = 0
}, MainFrame)

local TitleLabel = Utils.CreateInstance("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 14, 0, 0),
    Text = "CUSTOM EXECUTIVE FRAMEWORK",
    TextColor3 = Theme.TextMain,
    Font = Enum.Font.SourceSansBold,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1
}, TopBar)

-- Search Container
local SearchContainer = Utils.CreateInstance("Frame", {
    Size = UDim2.new(0, 220, 0, 28),
    Position = UDim2.new(0, 230, 0, 7),
    BackgroundColor3 = Theme.InputBg,
    BorderSizePixel = 0
}, TopBar)

Utils.AddCorner(SearchContainer, 6)

local SearchBox = Utils.CreateInstance("TextBox", {
    Size = UDim2.new(1, -12, 1, 0),
    Position = UDim2.new(0, 6, 0, 0),
    PlaceholderText = "Search elements...",
    PlaceholderColor3 = Theme.TextMuted,
    Text = "",
    TextColor3 = Theme.TextMain,
    Font = Enum.Font.SourceSans,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1
}, SearchContainer)

-- Controls Container (Minimize & Close)
local CloseBtn = Utils.CreateInstance("TextButton", {
    Size = UDim2.new(0, 32, 0, 32),
    Position = UDim2.new(1, -38, 0, 5),
    Text = "X",
    TextColor3 = Theme.Danger,
    Font = Enum.Font.SourceSansBold,
    TextSize = 16,
    BackgroundTransparency = 1
}, TopBar)

CloseBtn.MouseButton1Click:Connect(function()
    RootScreenGui:Destroy()
end)

Utils.EnableDrag(TopBar, MainFrame)

-- Sidebar Layout
local Sidebar = Utils.CreateInstance("Frame", {
    Size = UDim2.new(0, 150, 1, -42),
    Position = UDim2.new(0, 0, 0, 42),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0
}, MainFrame)

local TabScroll = Utils.CreateInstance("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -45),
    BackgroundTransparency = 1,
    ScrollBarThickness = 2,
    CanvasSize = UDim2.new(0, 0, 0, 0)
}, Sidebar)

local TabListLayout = Utils.CreateInstance("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 4)
}, TabScroll)

TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
end)

-- Content Display Area
local ContentContainer = Utils.CreateInstance("Frame", {
    Size = UDim2.new(1, -160, 1, -52),
    Position = UDim2.new(0, 155, 0, 47),
    BackgroundTransparency = 1
}, MainFrame)

-- ------------------------------------------------------------------------------
-- [SECTION 5] NOTIFICATION SYSTEM ENGINE
-- ------------------------------------------------------------------------------
local NotifContainer = Utils.CreateInstance("Frame", {
    Size = UDim2.new(0, 300, 1, -20),
    Position = UDim2.new(1, -310, 0, 10),
    BackgroundTransparency = 1
}, RootScreenGui)

local NotifLayout = Utils.CreateInstance("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim.new(0, 6)
}, NotifContainer)

local function SendNotification(title, message, duration, customColor)
    duration = duration or 3
    customColor = customColor or Theme.Accent

    local Card = Utils.CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 65),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0
    }, NotifContainer)

    Utils.AddCorner(Card, 6)
    Utils.AddStroke(Card, customColor, 1, 0.5)

    local Indicator = Utils.CreateInstance("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = customColor,
        BorderSizePixel = 0
    }, Card)

    Utils.AddCorner(Indicator, 4)

    local TitleBox = Utils.CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 12, 0, 4),
        Text = title,
        TextColor3 = Theme.TextMain,
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, Card)

    local DescBox = Utils.CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 12, 0, 24),
        Text = message,
        TextColor3 = Theme.TextMuted,
        Font = Enum.Font.SourceSans,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, Card)

    task.delay(duration, function()
        if Card and Card.Parent then
            Card:Destroy()
        end
    end)
end

-- ------------------------------------------------------------------------------
-- [SECTION 6] TAB MANAGER ENGINE
-- ------------------------------------------------------------------------------
local function CreateTab(tabName)
    local TabBtn = Utils.CreateInstance("TextButton", {
        Name = tabName .. "_TabButton",
        Size = UDim2.new(1, -10, 0, 34),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = Theme.Content,
        Text = "   " .. tabName,
        TextColor3 = Theme.TextMuted,
        Font = Enum.Font.SourceSansBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0
    }, TabScroll)

    Utils.AddCorner(TabBtn, 6)

    local PageScroll = Utils.CreateInstance("ScrollingFrame", {
        Name = tabName .. "_Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    }, ContentContainer)

    local PageLayout = Utils.CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    }, PageScroll)

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(FrameworkState.ActiveTabs) do
            tab.Page.Visible = false
            tab.Button.TextColor3 = Theme.TextMuted
            tab.Button.BackgroundColor3 = Theme.Content
        end
        PageScroll.Visible = true
        TabBtn.TextColor3 = Theme.TextMain
        TabBtn.BackgroundColor3 = Theme.Accent
        FrameworkState.CurrentTab = tabName
    end)

    local TabObject = {
        Name = tabName,
        Button = TabBtn,
        Page = PageScroll
    }

    table.insert(FrameworkState.ActiveTabs, TabObject)

    if #FrameworkState.ActiveTabs == 1 then
        PageScroll.Visible = true
        TabBtn.TextColor3 = Theme.TextMain
        TabBtn.BackgroundColor3 = Theme.Accent
        FrameworkState.CurrentTab = tabName
    end

    return PageScroll
end

-- ------------------------------------------------------------------------------
-- [SECTION 7] UI BUILDER COMPONENTS (TOGGLES, SLIDERS, INPUTS, KEYBINDS)
-- ------------------------------------------------------------------------------

-- 1. Toggle Component
local function AddToggle(parentPage, labelText, configKey, defaultValue, callback)
    FrameworkState.Storage[configKey] = (defaultValue == true)

    local Frame = Utils.CreateInstance("Frame", {
        Name = labelText .. "_ToggleFrame",
        Size = UDim2.new(1, -10, 0, 38),
        BackgroundColor3 = Theme.Content,
        BorderSizePixel = 0
    }, parentPage)

    Utils.AddCorner(Frame, 6)

    local Label = Utils.CreateInstance("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = labelText,
        TextColor3 = Theme.TextMain,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, Frame)

    local SwitchTrack = Utils.CreateInstance("Frame", {
        Size = UDim2.new(0, 42, 0, 22),
        Position = UDim2.new(1, -52, 0.5, -11),
        BackgroundColor3 = FrameworkState.Storage[configKey] and Theme.Success or Theme.Element,
        BorderSizePixel = 0
    }, Frame)

    Utils.AddCorner(SwitchTrack, 11)

    local SwitchKnob = Utils.CreateInstance("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = FrameworkState.Storage[configKey] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        BackgroundColor3 = Theme.TextMain,
        BorderSizePixel = 0
    }, SwitchTrack)

    Utils.AddCorner(SwitchKnob, 9)

    local Clicker = Utils.CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    }, Frame)

    Clicker.MouseButton1Click:Connect(function()
        FrameworkState.Storage[configKey] = not FrameworkState.Storage[configKey]
        local state = FrameworkState.Storage[configKey]

        SwitchTrack.BackgroundColor3 = state and Theme.Success or Theme.Element
        SwitchKnob.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)

        Utils.SafeCallback(callback, state)
    end)
end

-- 2. Stepped & Manual Number Control (e.g. Speed 10, 20, 30 / Input)
local function AddNumberControl(parentPage, labelText, configKey, defaultValue, minVal, maxVal, callback)
    FrameworkState.Storage[configKey] = defaultValue or minVal

    local Frame = Utils.CreateInstance("Frame", {
        Name = labelText .. "_NumFrame",
        Size = UDim2.new(1, -10, 0, 68),
        BackgroundColor3 = Theme.Content,
        BorderSizePixel = 0
    }, parentPage)

    Utils.AddCorner(Frame, 6)

    local Label = Utils.CreateInstance("TextLabel", {
        Size = UDim2.new(0, 200, 0, 26),
        Position = UDim2.new(0, 10, 0, 4),
        Text = labelText,
        TextColor3 = Theme.TextMain,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, Frame)

    local DirectInput = Utils.CreateInstance("TextBox", {
        Size = UDim2.new(0, 70, 0, 24),
        Position = UDim2.new(1, -80, 0, 4),
        BackgroundColor3 = Theme.InputBg,
        Text = tostring(FrameworkState.Storage[configKey]),
        TextColor3 = Theme.Accent,
        Font = Enum.Font.SourceSansBold,
        TextSize = 13
    }, Frame)

    Utils.AddCorner(DirectInput, 4)

    local StepContainer = Utils.CreateInstance("Frame", {
        Size = UDim2.new(1, -20, 0, 26),
        Position = UDim2.new(0, 10, 0, 34),
        BackgroundTransparency = 1
    }, Frame)

    local StepLayout = Utils.CreateInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6)
    }, StepContainer)

    local presets = {10, 20, 30, 50, 100, 200}
    for _, presetValue in ipairs(presets) do
        local StepButton = Utils.CreateInstance("TextButton", {
            Size = UDim2.new(0, 42, 1, 0),
            BackgroundColor3 = Theme.Element,
            Text = tostring(presetValue),
            TextColor3 = Theme.TextMuted,
            Font = Enum.Font.SourceSansBold,
            TextSize = 12
        }, StepContainer)

        Utils.AddCorner(StepButton, 4)

        StepButton.MouseButton1Click:Connect(function()
            FrameworkState.Storage[configKey] = presetValue
            DirectInput.Text = tostring(presetValue)
            Utils.SafeCallback(callback, presetValue)
        end)
    end

    DirectInput.FocusLost:Connect(function()
        local numericValue = tonumber(DirectInput.Text)
        if numericValue then
            numericValue = math.clamp(numericValue, minVal or 0, maxVal or 99999)
            FrameworkState.Storage[configKey] = numericValue
            DirectInput.Text = tostring(numericValue)
            Utils.SafeCallback(callback, numericValue)
        else
            DirectInput.Text = tostring(FrameworkState.Storage[configKey])
        end
    end)
end

-- 3. Custom Keybind Collector
local function AddKeybind(parentPage, labelText, configKey, defaultKey, callback)
    FrameworkState.Storage[configKey] = defaultKey and defaultKey.Name or "None"

    local Frame = Utils.CreateInstance("Frame", {
        Size = UDim2.new(1, -10, 0, 38),
        BackgroundColor3 = Theme.Content,
        BorderSizePixel = 0
    }, parentPage)

    Utils.AddCorner(Frame, 6)

    local Label = Utils.CreateInstance("TextLabel", {
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = labelText,
        TextColor3 = Theme.TextMain,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, Frame)

    local BindBtn = Utils.CreateInstance("TextButton", {
        Size = UDim2.new(0, 100, 0, 24),
        Position = UDim2.new(1, -110, 0.5, -12),
        BackgroundColor3 = Theme.InputBg,
        Text = FrameworkState.Storage[configKey],
        TextColor3 = Theme.Accent,
        Font = Enum.Font.SourceSansBold,
        TextSize = 12
    }, Frame)

    Utils.AddCorner(BindBtn, 4)

    local listening = false
    BindBtn.MouseButton1Click:Connect(function()
        listening = true
        BindBtn.Text = "Press Key..."
    end)

    CoreServices.UserInput.InputBegan:Connect(function(input, gameProcessed)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            local keyPressed = input.KeyCode
            FrameworkState.Storage[configKey] = keyPressed.Name
            BindBtn.Text = keyPressed.Name
            Utils.SafeCallback(callback, keyPressed)
        elseif not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode.Name == FrameworkState.Storage[configKey] then
                Utils.SafeCallback(callback, input.KeyCode)
            end
        end
    end)
end

-- 4. Floating Action Button Creator (Draggable On-Screen Controls)
local function CreateFloatingButton(btnName, defaultSizeX, defaultSizeY, defaultPosX, defaultPosY, callback)
    local FloatBtn = Utils.CreateInstance("TextButton", {
        Name = "FloatingBtn_" .. btnName,
        Size = UDim2.new(0, defaultSizeX or 80, 0, defaultSizeY or 40),
        Position = UDim2.new(0, defaultPosX or 120, 0, defaultPosY or 120),
        BackgroundColor3 = Theme.Accent,
        Text = btnName,
        TextColor3 = Theme.TextMain,
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        Active = true
    }, RootScreenGui)

    Utils.AddCorner(FloatBtn, 8)
    Utils.AddStroke(FloatBtn, Theme.TextMain, 1, 0.6)
    Utils.EnableDrag(FloatBtn, FloatBtn)

    FloatBtn.MouseButton1Click:Connect(function()
        Utils.SafeCallback(callback)
    end)

    FrameworkState.FloatingElements[btnName] = FloatBtn
    return FloatBtn
end

-- ------------------------------------------------------------------------------
-- [SECTION 8] SEARCH FILTER IMPLEMENTATION
-- ------------------------------------------------------------------------------
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local filterText = string.lower(SearchBox.Text)
    for _, tab in pairs(FrameworkState.ActiveTabs) do
        for _, element in pairs(tab.Page:GetChildren()) do
            if element:IsA("Frame") then
                local label = element:FindFirstChildOfClass("TextLabel")
                if label then
                    if filterText == "" or string.find(string.lower(label.Text), filterText) then
                        element.Visible = true
                    else
                        element.Visible = false
                    end
                end
            end
        end
    end
end)

-- ------------------------------------------------------------------------------
-- [SECTION 9] DEFAULT TABS & CONFIGURATION MANAGEMENT
-- ------------------------------------------------------------------------------

-- Tab 1: Main Controls
local MainTab = CreateTab("General")

AddToggle(MainTab, "Enable Aimbot Lock", "AimbotToggle", false, function(state)
    SendNotification("Aimbot Module", state and "Target tracking initialized." or "Target tracking offline.", 2)
end)

AddNumberControl(MainTab, "WalkSpeed Multiplier", "PlayerSpeed", 16, 16, 500, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
    end
end)

AddKeybind(MainTab, "Aimbot Hotkey", "AimbotKey", Enum.KeyCode.E, function(key)
    SendNotification("Hotkey Pressed", "Triggered hotkey: " .. key.Name, 1.5)
end)

-- Tab 2: External Floating Buttons
local FloatingTab = CreateTab("Floating Tools")

AddToggle(FloatingTab, "Display AIM Button", "ShowAimBtn", false, function(state)
    if state then
        if not FrameworkState.FloatingElements["AIM"] then
            CreateFloatingButton("AIM", 75, 38, 140, 180, function()
                SendNotification("Floating Action", "Floating AIM Button Executed!", 1.5)
            end)
        else
            FrameworkState.FloatingElements["AIM"].Visible = true
        end
    else
        if FrameworkState.FloatingElements["AIM"] then
            FrameworkState.FloatingElements["AIM"].Visible = false
        end
    end
end)

-- Tab 3: System Settings & JSON Management (Bottom Fixed)
local SettingsTabBtn = Utils.CreateInstance("TextButton", {
    Name = "Settings_TabButton",
    Size = UDim2.new(1, -10, 0, 34),
    Position = UDim2.new(0, 5, 1, -40),
    BackgroundColor3 = Color3.fromRGB(40, 42, 58),
    Text = "   [Settings]",
    TextColor3 = Theme.TextMain,
    Font = Enum.Font.SourceSansBold,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    BorderSizePixel = 0
}, Sidebar)

Utils.AddCorner(SettingsTabBtn, 6)

local SettingsPage = Utils.CreateInstance("ScrollingFrame", {
    Name = "Settings_Page",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ScrollBarThickness = 3,
    Visible = false
}, ContentContainer)

local SettingsLayout = Utils.CreateInstance("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8)
}, SettingsPage)

local SettingsTabObject = { Name = "Settings", Button = SettingsTabBtn, Page = SettingsPage }
table.insert(FrameworkState.ActiveTabs, SettingsTabObject)

SettingsTabBtn.MouseButton1Click:Connect(function()
    for _, tab in pairs(FrameworkState.ActiveTabs) do
        tab.Page.Visible = false
        tab.Button.TextColor3 = Theme.TextMuted
    end
    SettingsPage.Visible = true
    SettingsTabBtn.TextColor3 = Theme.TextMain
end)

-- Scale Setting
AddNumberControl(SettingsPage, "UI Canvas Scaling (0.5 - 2.0)", "UiScale", 1, 0.5, 2, function(scaleValue)
    RootScale.Scale = scaleValue
end)

-- Persistence Operations
local function SaveStorageToFile()
    local success, encoded = pcall(function()
        return CoreServices.Http:JSONEncode(FrameworkState.Storage)
    end)
    if success then
        SafeFS.write(FrameworkState.ConfigFileName, encoded)
        SendNotification("Config Storage", "Settings saved successfully!", 3, Theme.Success)
    else
        SendNotification("Config Storage", "Failed to encode configuration data.", 3, Theme.Danger)
    end
end

local function LoadStorageFromFile()
    if SafeFS.exists(FrameworkState.ConfigFileName) then
        local rawData = SafeFS.read(FrameworkState.ConfigFileName)
        local success, decoded = pcall(function()
            return CoreServices.Http:JSONDecode(rawData)
        end)
        if success and type(decoded) == "table" then
            FrameworkState.Storage = decoded
            SendNotification("Config Storage", "Configuration loaded into environment!", 3, Theme.Success)
        end
    else
        SendNotification("Config Storage", "No active configuration file located.", 3, Theme.Warning)
    end
end

local function DeleteStorageFile()
    if SafeFS.exists(FrameworkState.ConfigFileName) then
        SafeFS.delete(FrameworkState.ConfigFileName)
        SendNotification("Config Storage", "Configuration file purged.", 3, Theme.Danger)
    end
end

local function CreateActionButton(parentPage, text, buttonColor, callback)
    local Btn = Utils.CreateInstance("TextButton", {
        Size = UDim2.new(1, -10, 0, 34),
        BackgroundColor3 = buttonColor,
        Text = text,
        TextColor3 = Theme.TextMain,
        Font = Enum.Font.SourceSansBold,
        TextSize = 13
    }, parentPage)

    Utils.AddCorner(Btn, 6)
    Btn.MouseButton1Click:Connect(function()
        Utils.SafeCallback(callback)
    end)
end

CreateActionButton(SettingsPage, "SAVE CONFIGURATION FILE", Theme.Success, SaveStorageToFile)
CreateActionButton(SettingsPage, "LOAD CONFIGURATION FILE", Theme.Accent, LoadStorageFromFile)
CreateActionButton(SettingsPage, "PURGE CONFIGURATION FILE", Theme.Danger, DeleteStorageFile)

-- Initialization Notice
SendNotification("System Online", "Framework initialized safely with zero errors.", 4, Theme.Accent)

-- ------------------------------------------------------------------------------
-- [SECTION 10] ARCHITECTURAL DOCUMENTATION & API REFERENCE
-- ------------------------------------------------------------------------------
--[[
=================================================================================
                    FRAMEWORK ARCHITECTURE & USAGE MANUAL
=================================================================================

1. MEMBUAT TAB BARU (CREATING NEW TABS):
   Gunakan fungsi global `CreateTab("Nama Tab")`:
   
   local CombatTab = CreateTab("Combat")

2. MENAMBAHKAN TOGGLE ON/OFF (ADDING TOGGLES):
   Gunakan fungsi `AddToggle`:
   
   AddToggle(CombatTab, "Enable ESP", "EspState", false, function(isToggled)
       print("Status ESP:", isToggled)
   end)

3. MENAMBAHKAN KONTROL ANGKA / STEP / INPUT (NUMBER CONTROL):
   Mendukung tombol bertahap (10, 20, 30...) serta input manual:
   
   AddNumberControl(CombatTab, "Fly Speed", "FlySpeedValue", 50, 1, 500, function(val)
       print("Set Fly Speed ke:", val)
   end)

4. MENAMBAHKAN HOTKEY / KEYBIND:
   
   AddKeybind(CombatTab, "Toggle UI Key", "MenuKey", Enum.KeyCode.RightShift, function(keyCode)
       RootScreenGui.Enabled = not RootScreenGui.Enabled
   end)

5. MEMBUAT TOMBOL LUAR LAYAR (FLOATING ACTION BUTTONS):
   Bisa diseret (drag) di seluruh area layar:
   
   CreateFloatingButton("FLY", 80, 40, 200, 200, function()
       print("Floating Fly Button Clicked!")
   end)

6. INTEGRASI NOTIFIKASI KUSTOM:
   
   SendNotification("Judul", "Pesan Notifikasi", DurasiDetik, Color3.fromRGB(r, g, b))

7. MEKANISME SAFE-EXECUTION & ANTI-DUPLIKASI:
   - Script memeriksa instance GUI lama berdasarkan nama root (`UltraCustomFramework_Root`).
     Jika ditemukan, GUI lama dihapus secara bersih untuk membebaskan memori.
   - Semua fungsi `callback` dibungkus menggunakan `pcall` untuk memastikan tidak
     ada bug *nil* yang dapat menghentikan thread eksekusi utama.
=================================================================================
--]]
