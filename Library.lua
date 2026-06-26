local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Options = {},
    Toggles = {},
    Elements = {},
    ThemeInstances = {},
    
    Theme = {
        Background = Color3.fromRGB(20, 17, 28),
        CategoryHeader = Color3.fromRGB(26, 21, 37),
        ModuleBg = Color3.fromRGB(26, 21, 37),
        ModuleExpandedBg = Color3.fromRGB(22, 18, 30),
        Accent = Color3.fromRGB(208, 92, 227),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 160),
        On = Color3.fromRGB(50, 255, 50),
        Off = Color3.fromRGB(255, 50, 50),
        Hover = Color3.fromRGB(35, 30, 45),
        Stroke = Color3.fromRGB(40, 35, 50),
    },
    
    Icons = {
        Combat = "rbxassetid://10723396107", 
        Movement = "rbxassetid://10734910243",
        Render = "rbxassetid://10734898592",
        Player = "rbxassetid://10723415903",
        Misc = "rbxassetid://10734954301",
        Search = "rbxassetid://10734896022",
        ArrowDown = "rbxassetid://10709790948",
        ArrowUp = "rbxassetid://10709791334",
        Check = "rbxassetid://10709790644",
        X = "rbxassetid://10709791437",
        Settings = "rbxassetid://10734954301"
    }
}

local function Tween(instance, properties, duration, style, dir)
    duration = duration or 0.2
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, dir), properties)
    tween:Play()
    return tween
end

local function AssignTheme(instance, property, themeKey)
    instance[property] = Library.Theme[themeKey]
    table.insert(Library.ThemeInstances, {Instance = instance, Property = property, ThemeKey = themeKey})
end

function Library:SetThemeColor(themeKey, color)
    Library.Theme[themeKey] = color
    for _, data in ipairs(self.ThemeInstances) do
        if data.Instance and data.Instance.Parent and data.ThemeKey == themeKey then
            Tween(data.Instance, {[data.Property] = color}, 0.2)
        end
    end
end

local function MakeDraggable(topbarObject, object, conditionFunc)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        Tween(object, {Position = pos}, 0.15)
    end

    topbarObject.InputBegan:Connect(function(input)
        if conditionFunc and not conditionFunc() then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

Library.SaveManager = {
    Folder = "CustomUILibConfigs",
    Ignore = {}
}
function Library.SaveManager:SetFolder(folderName)
    self.Folder = folderName
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
end
function Library.SaveManager:Save(name)
    if not isfolder(self.Folder) then makefolder(self.Folder) end
    local data = {}
    for idx, toggle in pairs(Library.Toggles) do
        if not self.Ignore[idx] then data[idx] = toggle.Value end
    end
    for idx, opt in pairs(Library.Options) do
        if not self.Ignore[idx] then data[idx] = opt.Value end
    end
    writefile(self.Folder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
end
function Library.SaveManager:Load(name)
    local file = self.Folder .. "/" .. name .. ".json"
    if isfile(file) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(file)) end)
        if success and type(data) == "table" then
            for idx, value in pairs(data) do
                if Library.Toggles[idx] then Library.Toggles[idx]:SetValue(value) end
                if Library.Options[idx] then Library.Options[idx]:SetValue(value) end
            end
        end
    end
end
function Library.SaveManager:GetConfigs()
    if not isfolder(self.Folder) then return {} end
    local configs = {}
    local success, files = pcall(function() return listfiles(self.Folder) end)
    if success and files then
        for _, file in ipairs(files) do
            local name = file:match("([^/\\]+)%.json$")
            if name then table.insert(configs, name) end
        end
    end
    return configs
end

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

function Library:CreateWindow(options)
    local Window = {
        Categories = {},
        SearchText = ""
    }
    
    local guiName = options.Name or "CustomUILib"
    
    -- Cleanup existing GUIs
    local successCore, oldCore = pcall(function() return CoreGui:FindFirstChild(guiName) end)
    if successCore and oldCore then oldCore:Destroy() end
    
    local oldPlayer = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild(guiName)
    if oldPlayer then oldPlayer:Destroy() end
    
    local Lighting = game:GetService("Lighting")
    local oldBlur = Lighting:FindFirstChild(guiName .. "Blur")
    if oldBlur then oldBlur:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = guiName
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.DisplayOrder = 999999
    ScreenGui.IgnoreGuiInset = true
    ProtectGui(ScreenGui)
    
    local success = pcall(function() ScreenGui.Parent = CoreGui end)
    if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    local Blur = Instance.new("BlurEffect")
    Blur.Name = guiName .. "Blur"
    Blur.Size = 15
    Blur.Parent = Lighting
    
    local DarkBg = Instance.new("Frame")
    DarkBg.Name = "DarkBg"
    DarkBg.Parent = ScreenGui
    DarkBg.BackgroundColor3 = Color3.new(0, 0, 0)
    DarkBg.BackgroundTransparency = 0.4
    DarkBg.Size = UDim2.new(1, 0, 1, 0)
    DarkBg.ZIndex = -1
    
    Window.ScreenGui = ScreenGui
    Window.ToggleKey = Enum.KeyCode.RightControl
    Window.IsVisible = true
    
    local ColumnsContainer = Instance.new("Frame")
    ColumnsContainer.Name = "ColumnsContainer"
    ColumnsContainer.Parent = ScreenGui
    ColumnsContainer.BackgroundTransparency = 1
    ColumnsContainer.Size = UDim2.new(1, 0, 1, 0)
    ColumnsContainer.Position = UDim2.new(0, 0, 0, 0)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.ToggleKey then
            Window.IsVisible = not Window.IsVisible
            ColumnsContainer.Visible = Window.IsVisible
            Blur.Enabled = Window.IsVisible
            Tween(DarkBg, {BackgroundTransparency = Window.IsVisible and 0.4 or 1}, 0.2)
        end
    end)
    
    -- Custom Loading Screen
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Name = "LoadingScreen"
    LoadingFrame.Parent = ScreenGui
    AssignTheme(LoadingFrame, "BackgroundColor3", "Background")
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.ZIndex = 1000
    
    local LoadingText = Instance.new("TextLabel")
    LoadingText.Parent = LoadingFrame
    LoadingText.BackgroundTransparency = 1
    LoadingText.Size = UDim2.new(1, 0, 1, 0)
    LoadingText.Font = Enum.Font.GothamMedium
    LoadingText.Text = "Loading UI..."
    AssignTheme(LoadingText, "TextColor3", "Accent")
    LoadingText.TextSize = 28
    
    ColumnsContainer.Visible = false
    Blur.Size = 0
    DarkBg.BackgroundTransparency = 1
    
    task.spawn(function()
        local pulse = TweenService:Create(LoadingText, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextTransparency = 0.5})
        pulse:Play()
        task.wait(1.5)
        pulse:Cancel()
        LoadingText.TextTransparency = 0
        LoadingText.Text = "Ready!"
        task.wait(0.5)
        
        Tween(LoadingFrame, {BackgroundTransparency = 1}, 0.5)
        Tween(LoadingText, {TextTransparency = 1}, 0.5)
        
        if Window.IsVisible then
            Tween(DarkBg, {BackgroundTransparency = 0.4}, 0.5)
            Tween(Blur, {Size = 15}, 0.5)
            ColumnsContainer.Visible = true
        end
        
        task.wait(0.5)
        LoadingFrame:Destroy()
    end)
    
    local layoutX = 50
    
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Parent = ColumnsContainer
    AssignTheme(SearchFrame, "BackgroundColor3", "CategoryHeader")
    SearchFrame.Size = UDim2.new(0, 300, 0, 35)
    SearchFrame.Position = UDim2.new(0.5, -150, 0, 20)
    Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 6)
    
    local SearchClip = Instance.new("Frame")
    SearchClip.Parent = SearchFrame
    SearchClip.BackgroundTransparency = 1
    SearchClip.Size = UDim2.new(1, 0, 1, 0)
    SearchClip.ClipsDescendants = true
    Instance.new("UICorner", SearchClip).CornerRadius = UDim.new(0, 6)
    
    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Parent = SearchClip
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Position = UDim2.new(0, 8, 0.5, -10)
    SearchIcon.Size = UDim2.new(0, 20, 0, 20)
    SearchIcon.Image = Library.Icons.Search
    AssignTheme(SearchIcon, "ImageColor3", "TextDim")
    
    local SearchBox = Instance.new("TextBox")
    SearchBox.Parent = SearchClip
    SearchBox.BackgroundTransparency = 1
    SearchBox.Position = UDim2.new(0, 35, 0, 0)
    SearchBox.Size = UDim2.new(1, -45, 1, 0)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search modules..."
    AssignTheme(SearchBox, "TextColor3", "Text")
    AssignTheme(SearchBox, "PlaceholderColor3", "TextDim")
    SearchBox.TextSize = 14
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left

    SearchBox.Changed:Connect(function(prop)
        if prop == "Text" then
            Window.SearchText = SearchBox.Text:lower()
            for _, cat in pairs(Window.Categories) do
                cat:ApplySearch(Window.SearchText)
            end
        end
    end)
    
    -- Pop-in animation for SearchFrame
    local ogPos = SearchFrame.Position
    SearchFrame.Position = ogPos - UDim2.new(0, 0, 0, 50)
    Tween(SearchFrame, {Position = ogPos}, 0.5, Enum.EasingStyle.Back)
    
    function Window:AddCategory(catOptions)
        local Category = {
            Modules = {},
            Expanded = true,
            Name = catOptions.Title or "Category"
        }
        table.insert(Window.Categories, Category)
        
        local CatFrame = Instance.new("Frame")
        CatFrame.Name = Category.Name
        CatFrame.Parent = ColumnsContainer
        AssignTheme(CatFrame, "BackgroundColor3", "CategoryHeader")
        CatFrame.Position = UDim2.new(0, layoutX, 0, 80)
        CatFrame.Size = UDim2.new(0, 220, 0, 40)
        layoutX = layoutX + 240
        Instance.new("UICorner", CatFrame).CornerRadius = UDim.new(0, 6)
        
        local CatGradient = Instance.new("UIGradient")
        CatGradient.Parent = CatFrame
        CatGradient.Rotation = 45
        CatGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0.4)
        }
        
        local CatStroke = Instance.new("UIStroke")
        CatStroke.Parent = CatFrame
        AssignTheme(CatStroke, "Color", "Stroke")
        CatStroke.Thickness = 1
        CatStroke.Transparency = 0.5
        
        -- Pop-in animation for categories (glassy transparency)
        local catOgPos = CatFrame.Position
        CatFrame.Position = catOgPos + UDim2.new(0, 0, 0, 50)
        CatFrame.BackgroundTransparency = 1
        Tween(CatFrame, {Position = catOgPos, BackgroundTransparency = 0.25}, 0.6, Enum.EasingStyle.Back)
        
        local TitleIcon = Instance.new("ImageLabel")
        TitleIcon.Parent = CatFrame
        TitleIcon.BackgroundTransparency = 1
        TitleIcon.Position = UDim2.new(0, 10, 0, 10)
        TitleIcon.Size = UDim2.new(0, 20, 0, 20)
        TitleIcon.Image = catOptions.Icon or Library.Icons.Combat
        AssignTheme(TitleIcon, "ImageColor3", "Accent")
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Parent = CatFrame
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Position = UDim2.new(0, 35, 0, 0)
        TitleLabel.Size = UDim2.new(1, -70, 0, 40)
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = Category.Name
        AssignTheme(TitleLabel, "TextColor3", "Text")
        TitleLabel.TextSize = 16
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local ExpandBtn = Instance.new("ImageButton")
        ExpandBtn.Parent = CatFrame
        ExpandBtn.BackgroundTransparency = 1
        ExpandBtn.Position = UDim2.new(1, -25, 0, 12)
        ExpandBtn.Size = UDim2.new(0, 16, 0, 16)
        ExpandBtn.Image = Library.Icons.ArrowUp
        AssignTheme(ExpandBtn, "ImageColor3", "TextDim")
        
        MakeDraggable(CatFrame, CatFrame)
        
        local ContentFrame = Instance.new("Frame")
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Parent = CatFrame
        AssignTheme(ContentFrame, "BackgroundColor3", "Background")
        ContentFrame.BackgroundTransparency = 0.5
        ContentFrame.Position = UDim2.new(0, 0, 0, 40)
        ContentFrame.Size = UDim2.new(1, 0, 0, 0)
        ContentFrame.ClipsDescendants = true
        ContentFrame.BorderSizePixel = 0
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = ContentFrame
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 4)
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.Parent = ContentFrame
        ContentPadding.PaddingTop = UDim.new(0, 4)
        ContentPadding.PaddingBottom = UDim.new(0, 4)
        ContentPadding.PaddingLeft = UDim.new(0, 4)
        ContentPadding.PaddingRight = UDim.new(0, 4)
        
        local function UpdateCatSize()
            if Category.Expanded then
                local h = ContentLayout.AbsoluteContentSize.Y + 8
                Tween(CatFrame, {Size = UDim2.new(0, 220, 0, 40 + h)}, 0.25)
                Tween(ContentFrame, {Size = UDim2.new(1, 0, 0, h)}, 0.25)
                Tween(ExpandBtn, {Rotation = 0}, 0.25)
            else
                Tween(CatFrame, {Size = UDim2.new(0, 220, 0, 40)}, 0.25)
                Tween(ContentFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.25)
                Tween(ExpandBtn, {Rotation = 180}, 0.25)
            end
        end
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCatSize)
        
        ExpandBtn.MouseButton1Click:Connect(function()
            Category.Expanded = not Category.Expanded
            UpdateCatSize()
        end)
        
        function Category:ApplySearch(text)
            for _, mod in pairs(Category.Modules) do
                if text == "" or mod.Name:lower():find(text) then
                    mod.Frame.Visible = true
                else
                    mod.Frame.Visible = false
                end
            end
        end

        function Category:AddModule(modOptions)
            local Module = {
                Name = modOptions.Name or "Module",
                Value = modOptions.Default or false,
                Expanded = false,
                Settings = {},
                Keybind = nil,
                Binding = false
            }
            table.insert(Category.Modules, Module)
            Library.Toggles[modOptions.Name] = Module

            local ModFrame = Instance.new("Frame")
            ModFrame.Name = Module.Name
            ModFrame.Parent = ContentFrame
            AssignTheme(ModFrame, "BackgroundColor3", "ModuleBg")
            ModFrame.BackgroundTransparency = 0.4
            ModFrame.Size = UDim2.new(1, 0, 0, 30)
            ModFrame.ClipsDescendants = true
            Instance.new("UICorner", ModFrame).CornerRadius = UDim.new(0, 4)
            
            local ModStroke = Instance.new("UIStroke")
            ModStroke.Parent = ModFrame
            AssignTheme(ModStroke, "Color", "Stroke")
            ModStroke.Transparency = 0.8
            ModStroke.Thickness = 1
            
            local ModBtn = Instance.new("TextButton")
            ModBtn.Parent = ModFrame
            ModBtn.BackgroundTransparency = 1
            ModBtn.Size = UDim2.new(1, 0, 0, 30)
            ModBtn.Text = ""
            
            ModBtn.MouseEnter:Connect(function()
                Tween(ModFrame, {BackgroundTransparency = 0.2}, 0.2)
                if not Module.Value then
                    Tween(ModStroke, {Transparency = 0.4}, 0.2)
                end
            end)
            
            ModBtn.MouseLeave:Connect(function()
                Tween(ModFrame, {BackgroundTransparency = 0.4}, 0.2)
                if not Module.Value then
                    Tween(ModStroke, {Transparency = 0.8}, 0.2)
                end
            end)
            
            local ModLabel = Instance.new("TextLabel")
            ModLabel.Parent = ModFrame
            ModLabel.BackgroundTransparency = 1
            ModLabel.Position = UDim2.new(0, 10, 0, 0)
            ModLabel.Size = UDim2.new(1, -40, 0, 30)
            ModLabel.Font = Enum.Font.GothamSemibold
            ModLabel.Text = Module.Name
            AssignTheme(ModLabel, "TextColor3", "TextDim")
            ModLabel.TextSize = 14
            ModLabel.TextXAlignment = Enum.TextXAlignment.Center
            
            local SettingsFrame = Instance.new("Frame")
            SettingsFrame.Name = "SettingsFrame"
            SettingsFrame.Parent = ModFrame
            AssignTheme(SettingsFrame, "BackgroundColor3", "ModuleExpandedBg")
            SettingsFrame.BackgroundTransparency = 0.6
            SettingsFrame.Position = UDim2.new(0, 0, 0, 30)
            SettingsFrame.Size = UDim2.new(1, 0, 0, 0)
            SettingsFrame.ClipsDescendants = true
            
            local SettingsLayout = Instance.new("UIListLayout")
            SettingsLayout.Parent = SettingsFrame
            SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SettingsLayout.Padding = UDim.new(0, 4)
            
            local SettingsPadding = Instance.new("UIPadding")
            SettingsPadding.Parent = SettingsFrame
            SettingsPadding.PaddingTop = UDim.new(0, 4)
            SettingsPadding.PaddingBottom = UDim.new(0, 4)
            SettingsPadding.PaddingLeft = UDim.new(0, 6)
            SettingsPadding.PaddingRight = UDim.new(0, 6)

            local BindBtn = Instance.new("TextButton")
            BindBtn.Parent = SettingsFrame
            AssignTheme(BindBtn, "BackgroundColor3", "Stroke")
            BindBtn.Size = UDim2.new(1, 0, 0, 20)
            BindBtn.Font = Enum.Font.Gotham
            BindBtn.Text = "Bind: None"
            AssignTheme(BindBtn, "TextColor3", "TextDim")
            BindBtn.TextSize = 12
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
            BindBtn.LayoutOrder = -1 -- Always at the top

            local function UpdateBindText()
                local keyName = Module.Keybind and Module.Keybind.Name or "None"
                BindBtn.Text = "Bind: " .. keyName
                ModLabel.Text = Module.Name .. (Module.Keybind and (" [" .. keyName .. "]") or "")
            end

            local function StartBinding()
                if Module.Binding then return end
                Module.Binding = true
                BindBtn.Text = "Bind: ..."
                ModLabel.Text = Module.Name .. " [...]"
            end

            BindBtn.MouseButton1Click:Connect(StartBinding)

            ModBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton3 then
                    StartBinding()
                end
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if Module.Binding then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local key = input.KeyCode
                        if key == Enum.KeyCode.Backspace or key == Enum.KeyCode.Escape then
                            Module.Keybind = nil
                        else
                            Module.Keybind = key
                        end
                        Module.Binding = false
                        UpdateBindText()
                    end
                elseif not gameProcessed and Module.Keybind and input.KeyCode == Module.Keybind then
                    Module:SetValue(not Module.Value)
                end
            end)

            local function UpdateModSize()
                if Module.Expanded then
                    local h = SettingsLayout.AbsoluteContentSize.Y + 8
                    Tween(ModFrame, {Size = UDim2.new(1, 0, 0, 30 + h)}, 0.25)
                    Tween(SettingsFrame, {Size = UDim2.new(1, 0, 0, h)}, 0.25)
                else
                    Tween(ModFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.25)
                    Tween(SettingsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.25)
                end
            end
            
            SettingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateModSize)

            function Module:SetValue(val)
                Module.Value = val
                AssignTheme(ModLabel, "TextColor3", val and "Accent" or "TextDim")
                
                if val then
                    local pulse = TweenService:Create(ModLabel, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {TextTransparency = 0.5})
                    pulse:Play()
                    Tween(ModStroke, {Transparency = 0}, 0.2)
                else
                    Tween(ModStroke, {Transparency = 0.8}, 0.2)
                end
                
                if modOptions.Callback then modOptions.Callback(val) end
            end
            
            ModBtn.MouseButton1Click:Connect(function()
                Module:SetValue(not Module.Value)
            end)
            
            ModBtn.MouseButton2Click:Connect(function()
                Module.Expanded = not Module.Expanded
                UpdateModSize()
            end)
            
            Module.Frame = ModFrame
            Module:SetValue(Module.Value)
            
            -- Module Elements
            function Module:AddSlider(name, opts)
                local Slider = { Value = opts.Default or opts.Min }
                Library.Options[name] = Slider
                
                local SFrame = Instance.new("Frame")
                SFrame.Parent = SettingsFrame
                SFrame.BackgroundTransparency = 1
                SFrame.Size = UDim2.new(1, 0, 0, 30)
                
                local SLabel = Instance.new("TextLabel")
                SLabel.Parent = SFrame
                SLabel.BackgroundTransparency = 1
                SLabel.Size = UDim2.new(1, 0, 0, 15)
                SLabel.Font = Enum.Font.GothamSemibold
                SLabel.Text = name .. ":"
                AssignTheme(SLabel, "TextColor3", "TextDim")
                SLabel.TextSize = 12
                SLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local SVal = Instance.new("TextLabel")
                SVal.Parent = SFrame
                SVal.BackgroundTransparency = 1
                SVal.Size = UDim2.new(1, 0, 0, 15)
                SVal.Font = Enum.Font.GothamBold
                SVal.Text = tostring(Slider.Value)
                AssignTheme(SVal, "TextColor3", "Text")
                SVal.TextSize = 12
                SVal.TextXAlignment = Enum.TextXAlignment.Right
                
                local STrack = Instance.new("Frame")
                STrack.Parent = SFrame
                AssignTheme(STrack, "BackgroundColor3", "Stroke")
                STrack.Position = UDim2.new(0, 0, 0, 20)
                STrack.Size = UDim2.new(1, 0, 0, 4)
                Instance.new("UICorner", STrack).CornerRadius = UDim.new(1,0)
                
                local SFill = Instance.new("Frame")
                SFill.Parent = STrack
                AssignTheme(SFill, "BackgroundColor3", "Accent")
                SFill.Size = UDim2.new((Slider.Value - opts.Min) / (opts.Max - opts.Min), 0, 1, 0)
                Instance.new("UICorner", SFill).CornerRadius = UDim.new(1,0)
                
                local SGradient = Instance.new("UIGradient")
                SGradient.Parent = SFill
                SGradient.Rotation = 90
                SGradient.Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 0.3)
                }
                
                local SBtn = Instance.new("TextButton")
                SBtn.Parent = SFrame
                SBtn.BackgroundTransparency = 1
                SBtn.Position = UDim2.new(0, 0, 0, 15)
                SBtn.Size = UDim2.new(1, 0, 0, 15)
                SBtn.Text = ""
                
                SBtn.MouseEnter:Connect(function() Tween(STrack, {BackgroundTransparency = 0.5}, 0.2) end)
                SBtn.MouseLeave:Connect(function() Tween(STrack, {BackgroundTransparency = 0}, 0.2) end)
                
                local function UpdateSlider(input)
                    local percent = math.clamp((input.Position.X - STrack.AbsolutePosition.X) / STrack.AbsoluteSize.X, 0, 1)
                    local rawVal = opts.Min + (opts.Max - opts.Min) * percent
                    local val = math.floor(rawVal * (10 ^ (opts.Rounding or 0))) / (10 ^ (opts.Rounding or 0))
                    Slider:SetValue(val)
                end
                
                local dragging = false
                SBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                function Slider:SetValue(val)
                    Slider.Value = val
                    SVal.Text = tostring(val)
                    -- Elastic bouncing slider fill physics
                    Tween(SFill, {Size = UDim2.new((val - opts.Min) / (opts.Max - opts.Min), 0, 1, 0)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    if opts.Callback then opts.Callback(val) end
                end
                
                return Slider
            end
            
            function Module:AddToggle(name, opts)
                local Toggle = { Value = opts.Default or false }
                Library.Options[name] = Toggle
                
                local TFrame = Instance.new("Frame")
                TFrame.Parent = SettingsFrame
                TFrame.BackgroundTransparency = 1
                TFrame.Size = UDim2.new(1, 0, 0, 20)
                
                local TIcon = Instance.new("ImageLabel")
                TIcon.Parent = TFrame
                TIcon.BackgroundTransparency = 1
                TIcon.Position = UDim2.new(0, 0, 0.5, -7)
                TIcon.Size = UDim2.new(0, 14, 0, 14)
                TIcon.Image = Toggle.Value and Library.Icons.Check or Library.Icons.X
                AssignTheme(TIcon, "ImageColor3", Toggle.Value and "On" or "Off")
                
                local TLabel = Instance.new("TextLabel")
                TLabel.Parent = TFrame
                TLabel.BackgroundTransparency = 1
                TLabel.Position = UDim2.new(0, 20, 0, 0)
                TLabel.Size = UDim2.new(1, -20, 1, 0)
                TLabel.Font = Enum.Font.GothamSemibold
                TLabel.Text = name
                AssignTheme(TLabel, "TextColor3", "TextDim")
                TLabel.TextSize = 12
                TLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local TBtn = Instance.new("TextButton")
                TBtn.Parent = TFrame
                TBtn.BackgroundTransparency = 1
                TBtn.Size = UDim2.new(1, 0, 1, 0)
                TBtn.Text = ""
                
                TBtn.MouseEnter:Connect(function() Tween(TLabel, {TextTransparency = 0.2}, 0.2) end)
                TBtn.MouseLeave:Connect(function() Tween(TLabel, {TextTransparency = 0}, 0.2) end)
                
                function Toggle:SetValue(val)
                    Toggle.Value = val
                    TIcon.Image = val and Library.Icons.Check or Library.Icons.X
                    AssignTheme(TIcon, "ImageColor3", val and "On" or "Off")
                    AssignTheme(TLabel, "TextColor3", val and "Text" or "TextDim")
                    
                    if val then
                        local pulse = TweenService:Create(TIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, -2, 0.5, -9)})
                        pulse:Play()
                    end
                    if opts.Callback then opts.Callback(val) end
                end
                
                TBtn.MouseButton1Click:Connect(function()
                    Toggle:SetValue(not Toggle.Value)
                end)
                
                return Toggle
            end

            function Module:AddDropdown(name, opts)
                local Dropdown = { Value = opts.Default, Multi = opts.Multi or false, Expanded = false }
                if Dropdown.Multi and type(Dropdown.Value) ~= "table" then
                    Dropdown.Value = {}
                end
                Library.Options[name] = Dropdown
                
                local DFrame = Instance.new("Frame")
                DFrame.Parent = SettingsFrame
                DFrame.BackgroundTransparency = 1
                DFrame.Size = UDim2.new(1, 0, 0, 35)
                DFrame.ClipsDescendants = true
                
                local DLabel = Instance.new("TextLabel")
                DLabel.Parent = DFrame
                DLabel.BackgroundTransparency = 1
                DLabel.Size = UDim2.new(1, 0, 0, 15)
                DLabel.Font = Enum.Font.GothamSemibold
                DLabel.Text = name .. ":"
                AssignTheme(DLabel, "TextColor3", "TextDim")
                DLabel.TextSize = 12
                DLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local DBtn = Instance.new("TextButton")
                DBtn.Parent = DFrame
                AssignTheme(DBtn, "BackgroundColor3", "Stroke")
                DBtn.Position = UDim2.new(0, 0, 0, 15)
                DBtn.Size = UDim2.new(1, 0, 0, 20)
                DBtn.Font = Enum.Font.GothamSemibold
                DBtn.Text = type(Dropdown.Value)=="table" and "Multiple" or tostring(Dropdown.Value or "...")
                AssignTheme(DBtn, "TextColor3", "Text")
                DBtn.TextSize = 12
                Instance.new("UICorner", DBtn).CornerRadius = UDim.new(0,4)
                
                DBtn.MouseEnter:Connect(function() Tween(DBtn, {BackgroundTransparency = 0.5}, 0.2) end)
                DBtn.MouseLeave:Connect(function() Tween(DBtn, {BackgroundTransparency = 0}, 0.2) end)
                
                local ListFrame = Instance.new("Frame")
                ListFrame.Parent = DFrame
                AssignTheme(ListFrame, "BackgroundColor3", "Stroke")
                ListFrame.Position = UDim2.new(0, 0, 0, 35)
                ListFrame.Size = UDim2.new(1, 0, 0, 0)
                ListFrame.ClipsDescendants = true
                Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0,4)
                
                local SearchBox = Instance.new("TextBox")
                SearchBox.Parent = ListFrame
                SearchBox.BackgroundTransparency = 1
                SearchBox.Size = UDim2.new(1, -10, 0, 20)
                SearchBox.Position = UDim2.new(0, 5, 0, 0)
                SearchBox.Font = Enum.Font.Gotham
                SearchBox.PlaceholderText = "Search..."
                SearchBox.Text = ""
                AssignTheme(SearchBox, "TextColor3", "Text")
                SearchBox.TextSize = 12
                SearchBox.TextXAlignment = Enum.TextXAlignment.Left
                
                local ItemContainer = Instance.new("Frame")
                ItemContainer.Parent = ListFrame
                ItemContainer.BackgroundTransparency = 1
                ItemContainer.Position = UDim2.new(0, 0, 0, 20)
                ItemContainer.Size = UDim2.new(1, 0, 1, -20)
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Parent = ItemContainer
                
                local ItemBtns = {}
                local function BuildList()
                    for _, v in pairs(ItemBtns) do v:Destroy() end
                    ItemBtns = {}
                    for _, val in pairs(opts.Values) do
                        if SearchBox.Text == "" or tostring(val):lower():find(SearchBox.Text:lower()) then
                            local IBtn = Instance.new("TextButton")
                            IBtn.Parent = ItemContainer
                            IBtn.BackgroundTransparency = 1
                            AssignTheme(IBtn, "BackgroundColor3", "Hover")
                            IBtn.Size = UDim2.new(1, -10, 0, 20)
                            IBtn.Font = Enum.Font.Gotham
                            IBtn.Text = "  " .. tostring(val)
                            
                            local isSelected = false
                            if Dropdown.Multi then
                                isSelected = Dropdown.Value[val]
                            else
                                isSelected = (Dropdown.Value == val)
                            end
                            AssignTheme(IBtn, "TextColor3", isSelected and "Accent" or "TextDim")
                            IBtn.TextSize = 12
                            IBtn.TextXAlignment = Enum.TextXAlignment.Left
                            
                            IBtn.MouseEnter:Connect(function() Tween(IBtn, {BackgroundTransparency = 0.5}, 0.15) end)
                            IBtn.MouseLeave:Connect(function() Tween(IBtn, {BackgroundTransparency = 1}, 0.15) end)
                            
                            IBtn.MouseButton1Click:Connect(function()
                                if Dropdown.Multi then
                                    Dropdown.Value[val] = not Dropdown.Value[val]
                                else
                                    Dropdown.Value = val
                                    Dropdown.Expanded = false
                                end
                                Dropdown:SetValue(Dropdown.Value)
                                BuildList()
                            end)
                            table.insert(ItemBtns, IBtn)
                        end
                    end
                    if Dropdown.Expanded then
                        local h = 20 + ListLayout.AbsoluteContentSize.Y
                        Tween(ListFrame, {Size = UDim2.new(1, 0, 0, h)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        Tween(DFrame, {Size = UDim2.new(1, 0, 0, 35 + h)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    else
                        Tween(ListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.25)
                        Tween(DFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.25)
                    end
                end
                
                SearchBox.Changed:Connect(function(p)
                    if p == "Text" then BuildList() end
                end)
                
                DBtn.MouseButton1Click:Connect(function()
                    Dropdown.Expanded = not Dropdown.Expanded
                    BuildList()
                end)
                
                function Dropdown:SetValue(val)
                    Dropdown.Value = val
                    if Dropdown.Multi then
                        local selected = {}
                        for k, v in pairs(val) do if v then table.insert(selected, tostring(k)) end end
                        DBtn.Text = #selected > 0 and table.concat(selected, ", ") or "None"
                    else
                        DBtn.Text = tostring(val)
                    end
                    if not Dropdown.Expanded then
                        Tween(ListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.25)
                        Tween(DFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.25)
                    end
                    if opts.Callback then opts.Callback(val) end
                end
                
                function Dropdown:SetValues(newValues)
                    opts.Values = newValues
                    if Dropdown.Expanded then
                        BuildList()
                    end
                end
                
                Dropdown:SetValue(Dropdown.Value)
                return Dropdown
            end
            
            function Module:AddButton(name, callback)
                local BFrame = Instance.new("Frame")
                BFrame.Parent = SettingsFrame
                BFrame.BackgroundTransparency = 1
                BFrame.Size = UDim2.new(1, 0, 0, 25)
                
                local Btn = Instance.new("TextButton")
                Btn.Parent = BFrame
                AssignTheme(Btn, "BackgroundColor3", "Stroke")
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.Font = Enum.Font.GothamBold
                Btn.Text = name
                AssignTheme(Btn, "TextColor3", "Text")
                Btn.TextSize = 12
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,4)
                
                Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundTransparency = 0.3}, 0.15) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundTransparency = 0}, 0.15) end)
                
                Btn.MouseButton1Click:Connect(function()
                    local pulse = TweenService:Create(Btn, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {TextTransparency = 0.5})
                    pulse:Play()
                    if callback then callback() end
                end)
            end
            
            function Module:AddTextBox(name, default, callback)
                local TextBox = { Value = default or "" }
                local TFrame = Instance.new("Frame")
                TFrame.Parent = SettingsFrame
                TFrame.BackgroundTransparency = 1
                TFrame.Size = UDim2.new(1, 0, 0, 35)
                
                local TLabel = Instance.new("TextLabel")
                TLabel.Parent = TFrame
                TLabel.BackgroundTransparency = 1
                TLabel.Size = UDim2.new(1, 0, 0, 15)
                TLabel.Font = Enum.Font.GothamSemibold
                TLabel.Text = name .. ":"
                AssignTheme(TLabel, "TextColor3", "TextDim")
                TLabel.TextSize = 12
                TLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local TBox = Instance.new("TextBox")
                TBox.Parent = TFrame
                AssignTheme(TBox, "BackgroundColor3", "Stroke")
                TBox.Position = UDim2.new(0, 0, 0, 15)
                TBox.Size = UDim2.new(1, 0, 0, 20)
                TBox.Font = Enum.Font.GothamSemibold
                TBox.Text = TextBox.Value
                TBox.PlaceholderText = "Type here..."
                AssignTheme(TBox, "TextColor3", "Text")
                TBox.TextSize = 12
                TBox.ClearTextOnFocus = false
                Instance.new("UICorner", TBox).CornerRadius = UDim.new(0,4)
                
                TBox.FocusLost:Connect(function()
                    TextBox.Value = TBox.Text
                    if callback then callback(TextBox.Value) end
                end)
                return TextBox
            end
            
            function Module:AddLabel(text)
                local LFrame = Instance.new("Frame")
                LFrame.Parent = SettingsFrame
                LFrame.BackgroundTransparency = 1
                LFrame.Size = UDim2.new(1, 0, 0, 20)
                
                local LLabel = Instance.new("TextLabel")
                LLabel.Parent = LFrame
                LLabel.BackgroundTransparency = 1
                LLabel.Size = UDim2.new(1, 0, 1, 0)
                LLabel.Font = Enum.Font.Gotham
                LLabel.Text = text
                AssignTheme(LLabel, "TextColor3", "TextDim")
                LLabel.TextSize = 12
                LLabel.TextXAlignment = Enum.TextXAlignment.Left
                LLabel.TextWrapped = true
                
                return LLabel
            end
            
            return Module
        end

        return Category
    end

    Library.HUD = {}
    local HUDContainer = Instance.new("Frame")
    HUDContainer.Name = "HUDContainer"
    HUDContainer.Parent = ScreenGui
    HUDContainer.BackgroundTransparency = 1
    HUDContainer.Size = UDim2.new(1, 0, 1, 0)
    
    local Watermark = Instance.new("Frame")
    Watermark.Name = "Watermark"
    Watermark.Parent = HUDContainer
    AssignTheme(Watermark, "BackgroundColor3", "CategoryHeader")
    Watermark.Position = UDim2.new(0, 10, 0, 10)
    Watermark.Size = UDim2.new(0, 300, 0, 30)
    Watermark.Visible = false
    Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 6)
    
    local WMText = Instance.new("TextLabel")
    WMText.Parent = Watermark
    WMText.BackgroundTransparency = 1
    WMText.Size = UDim2.new(1, -20, 1, 0)
    WMText.Position = UDim2.new(0, 10, 0, 0)
    WMText.Font = Enum.Font.GothamMedium
    AssignTheme(WMText, "TextColor3", "Text")
    WMText.TextSize = 14
    WMText.TextXAlignment = Enum.TextXAlignment.Left
    
    MakeDraggable(Watermark, Watermark, function() return Window.IsVisible end)
    
    local CurrentWatermarkOpts = nil
    local frames = 0
    local lastFps = 60
    
    RunService.RenderStepped:Connect(function() frames = frames + 1 end)
    
    task.spawn(function()
        while true do
            lastFps = frames
            frames = 0
            if CurrentWatermarkOpts and Watermark.Visible then
                Library.HUD:UpdateWatermark()
            end
            task.wait(1)
        end
    end)
    
    function Library.HUD:UpdateWatermark()
        if not CurrentWatermarkOpts then return end
        local r, g, b = math.floor(Library.Theme.Accent.R*255), math.floor(Library.Theme.Accent.G*255), math.floor(Library.Theme.Accent.B*255)
        local hex = string.format("%02X%02X%02X", r, g, b)
        WMText.Text = string.format("<font color='#%s'>%s</font> | %s | %s fps", hex, CurrentWatermarkOpts.Name or "nameclient", CurrentWatermarkOpts.Server or "localhost", tostring(lastFps))
        WMText.RichText = true
        Watermark.Size = UDim2.new(0, WMText.TextBounds.X + 40, 0, 30)
    end
    
    function Library.HUD:SetWatermark(opts)
        CurrentWatermarkOpts = opts
        Watermark.Visible = true
        self:UpdateWatermark()
    end
    
    return Window
end

return Library
