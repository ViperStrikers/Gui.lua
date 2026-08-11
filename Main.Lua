--[[
ULTIMATE CUSTOM GUI FRAMEWORK (NO EXTERNAL LIBRARY) Created for Delta Executor & Cross-Platform (PC / Mobile / Touch)
--]]
local Library = {} local Services = { Players = game:GetService("Players"), UserInputService = game:GetService("UserInputService"), TweenService = game:GetService("TweenService"), HttpService = game:GetService("HttpService") }
local LocalPlayer = Services.Players.LocalPlayer local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
-- Clean up existing instances if re-executed if PlayerGui:FindFirstChild("CustomExecutorGui") then PlayerGui.CustomExecutorGui:Destroy() end
-- ScreenGui Parent local ScreenGui = Instance.new("ScreenGui") ScreenGui.Name = "CustomExecutorGui" ScreenGui.ResetOnSpawn = false ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling ScreenGui.Parent = PlayerGui
-- Notification Container local NotifyContainer = Instance.new("Frame") NotifyContainer.Name = "NotifyContainer" NotifyContainer.Size = UDim2.new(0, 300, 1, -20) NotifyContainer.Position = UDim2.new(1, -310, 0, 10) NotifyContainer.BackgroundTransparency = 1 NotifyContainer.Parent = ScreenGui
local NotifyLayout = Instance.new("UIListLayout") NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder NotifyLayout.Padding = UDim.new(0, 8) NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom NotifyLayout.Parent = NotifyContainer
-- Global Notification System function Library:Notify(config) config = config or {} local title = config.Title or "Notification" local text = config.Content or "" local duration = config.Duration or 3 local color = config.Color or Color3.fromRGB(0, 170, 255)
local Card = Instance.new("Frame") Card.Size = UDim2.new(1, 0, 0, 60) Card.BackgroundColor3 = Color3.fromRGB(25, 25, 33) Card.BorderSizePixel = 0 Card.BackgroundTransparency = 1 Card.Parent = NotifyContainer
local UICorner = Instance.new("UICorner") UICorner.CornerRadius = UDim.new(0, 8) UICorner.Parent = Card
local AccentBar = Instance.new("Frame") AccentBar.Size = UDim2.new(0, 4, 1, 0) AccentBar.BackgroundColor3 = color AccentBar.BorderSizePixel = 0 AccentBar.Parent = Card
local AccentCorner = Instance.new("UICorner") AccentCorner.CornerRadius = UDim.new(0, 8) AccentCorner.Parent = AccentBar
local TitleLabel = Instance.new("TextLabel") TitleLabel.Size = UDim2.new(1, -15, 0, 22) TitleLabel.Position = UDim2.new(0, 12, 0, 5) TitleLabel.Text = title TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) TitleLabel.Font = Enum.Font.SourceSansBold TitleLabel.TextSize = 16 TitleLabel.TextXAlignment = Enum.TextXAlignment.Left TitleLabel.BackgroundTransparency = 1 TitleLabel.Parent = Card
local BodyLabel = Instance.new("TextLabel") BodyLabel.Size = UDim2.new(1, -15, 0, 30) BodyLabel.Position = UDim2.new(0, 12, 0, 25) BodyLabel.Text = text BodyLabel.TextColor3 = Color3.fromRGB(200, 200, 210) BodyLabel.Font = Enum.Font.SourceSans BodyLabel.TextSize = 14 BodyLabel.TextWrapped = true BodyLabel.TextXAlignment = Enum.TextXAlignment.Left BodyLabel.BackgroundTransparency = 1 BodyLabel.Parent = Card
-- Fade In Services.TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
task.delay(duration, function() local tween = Services.TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 1}) tween:Play() tween.Completed:Connect(function() Card:Destroy() end) end) end
-- Window Construction function Library:CreateWindow(guiName) local Window = { Tabs = {}, ActiveTab = nil, ConfigData = {}, FloatingButtons = {} }
-- Main Frame local MainFrame = Instance.new("Frame") MainFrame.Name = "MainFrame" MainFrame.Size = UDim2.new(0, 600, 0, 380) MainFrame.Position = UDim2.new(0.5, -300, 0.5, -190) MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28) MainFrame.BorderSizePixel = 0 MainFrame.Active = true MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 10) MainCorner.Parent = MainFrame
-- Scale Controller for Mobile/PC adjustment local UIScale = Instance.new("UIScale") UIScale.Scale = 1 UIScale.Parent = MainFrame Window.UIScale = UIScale
-- Dragging Handler local function makeDraggable(gui, handle) local dragging, dragInput, dragStart, startPos handle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = gui.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end) handle.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end) Services.UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end) end
-- TopBar Setup local TopBar = Instance.new("Frame") TopBar.Name = "TopBar" TopBar.Size = UDim2.new(1, 0, 0, 45) TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22) TopBar.BorderSizePixel = 0 TopBar.Parent = MainFrame
local TopCorner = Instance.new("UICorner") TopCorner.CornerRadius = UDim.new(0, 10) TopCorner.Parent = TopBar
makeDraggable(MainFrame, TopBar)
-- GUI Title Label local Title = Instance.new("TextLabel") Title.Size = UDim2.new(0, 180, 1, 0) Title.Position = UDim2.new(0, 15, 0, 0) Title.Text = guiName or "Custom Executor GUI" Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.Font = Enum.Font.SourceSansBold Title.TextSize = 18 Title.TextXAlignment = Enum.TextXAlignment.Left Title.BackgroundTransparency = 1 Title.Parent = TopBar
-- Search Bar local SearchBox = Instance.new("TextBox") SearchBox.Name = "SearchBox" SearchBox.Size = UDim2.new(0, 180, 0, 28) SearchBox.Position = UDim2.new(1, -220, 0, 8) SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 42) SearchBox.PlaceholderText = "Search..." SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140) SearchBox.Text = "" SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255) SearchBox.Font = Enum.Font.SourceSans SearchBox.TextSize = 14 SearchBox.Parent = TopBar
local SearchCorner = Instance.new("UICorner") SearchCorner.CornerRadius = UDim.new(0, 6) SearchCorner.Parent = SearchBox
-- Close Button local CloseBtn = Instance.new("TextButton") CloseBtn.Size = UDim2.new(0, 28, 0, 28) CloseBtn.Position = UDim2.new(1, -34, 0, 8) CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60) CloseBtn.Text = "X" CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255) CloseBtn.Font = Enum.Font.SourceSansBold CloseBtn.TextSize = 14 CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner") CloseCorner.CornerRadius = UDim.new(0, 6) CloseCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
-- Sidebar Container (Tab Buttons) local Sidebar = Instance.new("Frame") Sidebar.Name = "Sidebar" Sidebar.Size = UDim2.new(0, 140, 1, -55) Sidebar.Position = UDim2.new(0, 10, 0, 50) Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22) Sidebar.BorderSizePixel = 0 Sidebar.Parent = MainFrame
local SideCorner = Instance.new("UICorner") SideCorner.CornerRadius = UDim.new(0, 8) SideCorner.Parent = Sidebar
local TabScroll = Instance.new("ScrollingFrame") TabScroll.Size = UDim2.new(1, -10, 1, -10) TabScroll.Position = UDim2.new(0, 5, 0, 5) TabScroll.BackgroundTransparency = 1 TabScroll.ScrollBarThickness = 2 TabScroll.Parent = Sidebar
local TabLayout = Instance.new("UIListLayout") TabLayout.SortOrder = Enum.SortOrder.LayoutOrder TabLayout.Padding = UDim.new(0, 5) TabLayout.Parent = TabScroll
-- Content Area local ContentArea = Instance.new("Frame") ContentArea.Name = "ContentArea" ContentArea.Size = UDim2.new(1, -170, 1, -55) ContentArea.Position = UDim2.new(0, 160, 0, 50) ContentArea.BackgroundColor3 = Color3.fromRGB(15, 15, 22) ContentArea.BorderSizePixel = 0 ContentArea.Parent = MainFrame
local ContentCorner = Instance.new("UICorner") ContentCorner.CornerRadius = UDim.new(0, 8) ContentCorner.Parent = ContentArea
-- Search Filter Function SearchBox:GetPropertyChangedSignal("Text"):Connect(function() local query = SearchBox.Text:lower() if Window.ActiveTab then for _, item in ipairs(Window.ActiveTab.Container:GetChildren()) do if item:IsA("Frame") or item:IsA("TextButton") then local title = item:FindFirstChild("Title") or item:FindFirstChild("Label") if title and title:IsA("TextLabel") then if query == "" or title.Text:lower():find(query) then item.Visible = true else item.Visible = false end end end end end end)
-- Tab Generator function Window:AddTab(tabName) local Tab = { Name = tabName, Elements = {} }
-- Tab Button local TabBtn = Instance.new("TextButton") TabBtn.Size = UDim2.new(1, 0, 0, 32) TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35) TabBtn.Text = tabName TabBtn.TextColor3 = Color3.fromRGB(180, 180, 195) TabBtn.Font = Enum.Font.SourceSansBold TabBtn.TextSize = 14 TabBtn.Parent = TabScroll
local TabBtnCorner = Instance.new("UICorner") TabBtnCorner.CornerRadius = UDim.new(0, 6) TabBtnCorner.Parent = TabBtn
-- Tab Content ScrollFrame local Container = Instance.new("ScrollingFrame") Container.Name = tabName .. "_Container" Container.Size = UDim2.new(1, -20, 1, -20) Container.Position = UDim2.new(0, 10, 0, 10) Container.BackgroundTransparency = 1 Container.ScrollBarThickness = 4 Container.Visible = false Container.Parent = ContentArea
local ContainerLayout = Instance.new("UIListLayout") ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder ContainerLayout.Padding = UDim.new(0, 8) ContainerLayout.Parent = Container
Tab.Container = Container
-- Tab Activation Logic TabBtn.MouseButton1Click:Connect(function() for _, t in pairs(Window.Tabs) do t.Container.Visible = false t.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 35) t.Button.TextColor3 = Color3.fromRGB(180, 180, 195) end Container.Visible = true TabBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215) TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) Window.ActiveTab = Tab end)
Tab.Button = TabBtn table.insert(Window.Tabs, Tab)
if #Window.Tabs == 1 then Container.Visible = true TabBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215) TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) Window.ActiveTab = Tab end
-- Element Creator Functions function Tab:AddButton(text, callback) local BtnFrame = Instance.new("TextButton") BtnFrame.Size = UDim2.new(1, 0, 0, 36) BtnFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42) BtnFrame.Text = "" BtnFrame.Parent = Container
local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 6) Corner.Parent = BtnFrame
local Label = Instance.new("TextLabel") Label.Name = "Title" Label.Size = UDim2.new(1, -20, 1, 0) Label.Position = UDim2.new(0, 10, 0, 0) Label.Text = text Label.TextColor3 = Color3.fromRGB(255, 255, 255) Label.Font = Enum.Font.SourceSansBold Label.TextSize = 14 Label.TextXAlignment = Enum.TextXAlignment.Left Label.BackgroundTransparency = 1 Label.Parent = BtnFrame
BtnFrame.MouseButton1Click:Connect(function() if callback then callback() end end) end
function Tab:AddToggle(text, defaultState, callback) local state = defaultState or false Window.ConfigData[text] = state
local ToggleFrame = Instance.new("Frame") ToggleFrame.Size = UDim2.new(1, 0, 0, 36) ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42) ToggleFrame.Parent = Container
local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 6) Corner.Parent = ToggleFrame
local Label = Instance.new("TextLabel") Label.Name = "Title" Label.Size = UDim2.new(1, -60, 1, 0) Label.Position = UDim2.new(0, 10, 0, 0) Label.Text = text Label.TextColor3 = Color3.fromRGB(255, 255, 255) Label.Font = Enum.Font.SourceSans Label.TextSize = 14 Label.TextXAlignment = Enum.TextXAlignment.Left Label.BackgroundTransparency = 1 Label.Parent = ToggleFrame
local Switch = Instance.new("TextButton") Switch.Size = UDim2.new(0, 40, 0, 20) Switch.Position = UDim2.new(1, -50, 0.5, -10) Switch.BackgroundColor3 = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 75) Switch.Text = "" Switch.Parent = ToggleFrame
local SwitchCorner = Instance.new("UICorner") SwitchCorner.CornerRadius = UDim.new(1, 0) SwitchCorner.Parent = Switch
Switch.MouseButton1Click:Connect(function() state = not state Window.ConfigData[text] = state Switch.BackgroundColor3 = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(60, 60, 75) if callback then callback(state) end end) end
-- Slider + Manual Number Input function Tab:AddSlider(text, min, max, default, callback) local value = default or min Window.ConfigData[text] = value
local SliderFrame = Instance.new("Frame") SliderFrame.Size = UDim2.new(1, 0, 0, 50) SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 42) SliderFrame.Parent = Container
local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 6) Corner.Parent = SliderFrame
local Label = Instance.new("TextLabel") Label.Name = "Title" Label.Size = UDim2.new(0.6, 0, 0, 22) Label.Position = UDim2.new(0, 10, 0, 5) Label.Text = text Label.TextColor3 = Color3.fromRGB(255, 255, 255) Label.Font = Enum.Font.SourceSans Label.TextSize = 14 Label.TextXAlignment = Enum.TextXAlignment.Left Label.BackgroundTransparency = 1 Label.Parent = SliderFrame
-- Manual Input Box local NumInput = Instance.new("TextBox") NumInput.Size = UDim2.new(0, 50, 0, 20) NumInput.Position = UDim2.new(1, -60, 0, 5) NumInput.BackgroundColor3 = Color3.fromRGB(20, 20, 30) NumInput.Text = tostring(value) NumInput.TextColor3 = Color3.fromRGB(0, 170, 255) NumInput.Font = Enum.Font.SourceSansBold NumInput.TextSize = 14 NumInput.Parent = SliderFrame
local InputCorner = Instance.new("UICorner") InputCorner.CornerRadius = UDim.new(0, 4) InputCorner.Parent = NumInput
-- Slider Bar local Bar = Instance.new("TextButton") Bar.Size = UDim2.new(1, -20, 0, 8) Bar.Position = UDim2.new(0, 10, 0, 32) Bar.BackgroundColor3 = Color3.fromRGB(20, 20, 30) Bar.Text = "" Bar.Parent = SliderFrame
local BarCorner = Instance.new("UICorner") BarCorner.CornerRadius = UDim.new(1, 0) BarCorner.Parent = Bar
local Fill = Instance.new("Frame") Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0) Fill.BackgroundColor3 = Color3.fromRGB(0, 120, 215) Fill.BorderSizePixel = 0 Fill.Parent = Bar
local FillCorner = Instance.new("UICorner") FillCorner.CornerRadius = UDim.new(1, 0) FillCorner.Parent = Fill
local function updateValue(val) val = math.clamp(math.round(val), min, max) value = val Window.ConfigData[text] = value NumInput.Text = tostring(val) Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0) if callback then callback(val) end end
NumInput.FocusLost:Connect(function() local num = tonumber(NumInput.Text) if num then updateValue(num) else NumInput.Text = tostring(value) end end)
local sliding = false Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1) updateValue(min + ((max - min) * pos)) end end)
Services.UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
Services.UserInputService.InputChanged:Connect(function(input) if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1) updateValue(min + ((max - min) * pos)) end end) end
return Tab end
-- Floating Action Button Creation System function Window:CreateFloatingButton(btnText, sizeX, sizeY, callback) local FloatBtn = Instance.new("TextButton") FloatBtn.Name = "CustomFloat_" .. btnText FloatBtn.Size = UDim2.new(0, sizeX or 60, 0, sizeY or 60) FloatBtn.Position = UDim2.new(0.1, 0, 0.5, 0) FloatBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215) FloatBtn.Text = btnText or "ACTION" FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255) FloatBtn.Font = Enum.Font.SourceSansBold FloatBtn.TextSize = 14 FloatBtn.Active = true FloatBtn.Parent = ScreenGui
local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 12) Corner.Parent = FloatBtn
makeDraggable(FloatBtn, FloatBtn)
FloatBtn.MouseButton1Click:Connect(function() if callback then callback() end end)
table.insert(Window.FloatingButtons, FloatBtn) return FloatBtn end
-- Build Default Settings Tab local SettingTab = Window:AddTab("Settings")
SettingTab:AddSlider("GUI Size Scale", 50, 150, 100, function(val) UIScale.Scale = val / 100 end)
SettingTab:AddButton("Save Config", function() if writefile then writefile("CustomGUI_Config.json", Services.HttpService:JSONEncode(Window.ConfigData)) Library:Notify({Title = "System", Content = "Config saved successfully!", Color = Color3.fromRGB(0, 200, 100)}) else Library:Notify({Title = "Error", Content = "Executor doesn't support writefile!", Color = Color3.fromRGB(220, 50, 50)}) end end)
SettingTab:AddButton("Load Config", function() if readfile and isfile and isfile("CustomGUI_Config.json") then local data = Services.HttpService:JSONDecode(readfile("CustomGUI_Config.json")) Window.ConfigData = data Library:Notify({Title = "System", Content = "Config loaded successfully!", Color = Color3.fromRGB(0, 170, 255)}) else Library:Notify({Title = "Error", Content = "No config file found!", Color = Color3.fromRGB(220, 50, 50)}) end end)
SettingTab:AddButton("Delete Config", function() if delfile and isfile and isfile("CustomGUI_Config.json") then delfile("CustomGUI_Config.json") Library:Notify({Title = "System", Content = "Config file deleted!", Color = Color3.fromRGB(255, 150, 0)}) end end)
return Window end
-- ============================================================================ -- CONTOH PENGGUNAAN & FITUR-FITUR GUI (DEMO SCRIPT) -- ============================================================================
local MyWindow = Library:CreateWindow("Delta Custom GUI")
-- TAB 1: MAIN local MainTab = MyWindow:AddTab("Main")
MainTab:AddToggle("Aimbot Feature", false, function(state) Library:Notify({ Title = "Aimbot Status", Content = state and "Aimbot turned ON" or "Aimbot turned OFF", Duration = 2, Color = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50) }) end)
MainTab:AddSlider("Speed Hack", 16, 200, 16, function(val) local char = LocalPlayer.Character if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = val end end)
-- TAB 2: MOBILE / EXTRA local MobileTab = MyWindow:AddTab("Mobile")
MobileTab:AddButton("Create Floating AIM Button", function() MyWindow:CreateFloatingButton("AIM", 70, 70, function() Library:Notify({Title = "Action", Content = "Floating AIM Button Pressed!", Duration = 1.5}) end) Library:Notify({Title = "Mobile", Content = "Floating button created on screen! You can drag it anywhere."}) end)
Library:Notify({ Title = "Welcome!", Content = "GUI Loaded Successfully. Fully Working on PC & Mobile!", Duration = 4 })
--[[
PETUNJUK LENGKAP PENGGUNAAN GUI INI
Apa saja yang bisa kamu lakukan dengan GUI ini:
1. MENAMBAHKAN TAB BARU Kamu bisa menambahkan tab sebanyak yang kamu mau secara fleksibel: local TabBaru = MyWindow:AddTab("Nama Tab")
2. MENAMBAHKAN TOMBOL (BUTTON) TabBaru:AddButton("Nama Tombol", function() -- Tulis script kamu di sini end)
3. MENAMBAHKAN TOGGLE (ON/OFF) TabBaru:AddToggle("Auto Farm", false, function(state) print("Status:", state) -- true atau false end)
4. MENAMBAHKAN SLIDER + MANUAL NUMBER INPUT Pemain bisa menggeser bar ATAU mengetik angka langsung (seperti 10, 20, 30, dll): TabBaru:AddSlider("Speed Hack", 10, 100, 16, function(value) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value end)
5. MEMBUAT TOMBOL FLOATING / TOMBOL LUAR GUI (Sangat cocok untuk Mobile) Kamu bisa membuat tombol di luar GUI (misal tombol AIM), mengatur ukurannya (X, Y), serta memindahkannya (drag) di mana saja di layar: MyWindow:CreateFloatingButton("AIM", 70, 70, function() -- Kode ketika tombol AIM di layar dipencet end)
6. MENGIRIM NOTIFIKASI KUSTOM Kamu bisa memanggil notifikasi kapan saja: Library:Notify({ Title = "Judul Notif", Content = "Pesan notifikasi kamu...", Duration = 3, -- Detik Color = Color3.fromRGB(0, 170, 255) -- Warna aksen })
7. PENGATURAN KECERDASAN & UKURAN GUI (Fitur Settings)
   * Terdapat pencarian (Search Bar) di bagian atas untuk memfilter tombol.
   * GUI Size Scale: Kamu bisa membesarkan/memkecilkan GUI agar pas di layar HP/PC.
   * Save / Load / Delete Config: Menyimpan semua data settingan toggle/slider pengguna secara otomatis. ================================================================================ --]]
