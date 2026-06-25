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
    RegistryMap = {},
    
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
        X = "rbxassetid://10709791437"
    }
}

local function MakeDraggable(topbarObject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        local Tween = TweenService:Create(object, TweenInfo.new(0.15), {Position = pos})
        Tween:Play()
    end

    topbarObject.InputBegan:Connect(function(input)
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

local function Tween(instance, properties, duration, style, dir)
    duration = duration or 0.2
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, dir), properties)
    tween:Play()
    return tween
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
        if not self.Ignore[idx] then
            data[idx] = toggle.Value
        end
    end
    for idx, opt in pairs(Library.Options) do
        if not self.Ignore[idx] then
            data[idx] = opt.Value
        end
    end
    writefile(self.Folder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
end
function Library.SaveManager:Load(name)
    local file = self.Folder .. "/" .. name .. ".json"
    if isfile(file) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(file))
        end)
        if success and type(data) == "table" then
            for idx, value in pairs(data) do
                if Library.Toggles[idx] then Library.Toggles[idx]:SetValue(value) end
                if Library.Options[idx] then Library.Options[idx]:SetValue(value) end
            end
        end
    end
end

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
function Library:CreateWindow(options)
    local Window = {
        Categories = {},
        SearchText = ""
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = options.Name or "CustomUILib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ProtectGui(ScreenGui)
    
    local success = pcall(function() ScreenGui.Parent = CoreGui end)
    if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    Window.ScreenGui = ScreenGui

    local ColumnsContainer = Instance.new("Frame")
    ColumnsContainer.Name = "ColumnsContainer"
    ColumnsContainer.Parent = ScreenGui
    ColumnsContainer.BackgroundTransparency = 1
    ColumnsContainer.Size = UDim2.new(1, 0, 1, 0)
    ColumnsContainer.Position = UDim2.new(0, 0, 0, 0)
    
    local layoutX = 50
    
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Parent = ScreenGui
    SearchFrame.BackgroundColor3 = Library.Theme.CategoryHeader
    SearchFrame.Size = UDim2.new(0, 300, 0, 35)
    SearchFrame.Position = UDim2.new(0.5, -150, 0, 20)
    
    local SearchUICorner = Instance.new("UICorner")
    SearchUICorner.CornerRadius = UDim.new(0, 6)
    SearchUICorner.Parent = SearchFrame
    
    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Parent = SearchFrame
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Position = UDim2.new(0, 8, 0.5, -10)
    SearchIcon.Size = UDim2.new(0, 20, 0, 20)
    SearchIcon.Image = Library.Icons.Search
    SearchIcon.ImageColor3 = Library.Theme.TextDim
    
    local SearchBox = Instance.new("TextBox")
    SearchBox.Parent = SearchFrame
    SearchBox.BackgroundTransparency = 1
    SearchBox.Position = UDim2.new(0, 35, 0, 0)
    SearchBox.Size = UDim2.new(1, -45, 1, 0)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search modules..."
    SearchBox.TextColor3 = Library.Theme.Text
    SearchBox.PlaceholderColor3 = Library.Theme.TextDim
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
        CatFrame.BackgroundColor3 = Library.Theme.CategoryHeader
        CatFrame.Position = UDim2.new(0, layoutX, 0, 80)
        CatFrame.Size = UDim2.new(0, 220, 0, 40)
        layoutX = layoutX + 240
        
        local CatUICorner = Instance.new("UICorner")
        CatUICorner.CornerRadius = UDim.new(0, 6)
        CatUICorner.Parent = CatFrame
        
        local TitleIcon = Instance.new("ImageLabel")
        TitleIcon.Parent = CatFrame
        TitleIcon.BackgroundTransparency = 1
        TitleIcon.Position = UDim2.new(0, 10, 0, 10)
        TitleIcon.Size = UDim2.new(0, 20, 0, 20)
        TitleIcon.Image = catOptions.Icon or Library.Icons.Combat
        TitleIcon.ImageColor3 = Library.Theme.Accent
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Parent = CatFrame
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Position = UDim2.new(0, 35, 0, 0)
        TitleLabel.Size = UDim2.new(1, -70, 0, 40)
        TitleLabel.Font = Enum.Font.GothamMedium
        TitleLabel.Text = Category.Name
        TitleLabel.TextColor3 = Library.Theme.Text
        TitleLabel.TextSize = 16
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local ExpandBtn = Instance.new("ImageButton")
        ExpandBtn.Parent = CatFrame
        ExpandBtn.BackgroundTransparency = 1
        ExpandBtn.Position = UDim2.new(1, -25, 0, 12)
        ExpandBtn.Size = UDim2.new(0, 16, 0, 16)
        ExpandBtn.Image = Library.Icons.ArrowUp
        ExpandBtn.ImageColor3 = Library.Theme.TextDim
        
        MakeDraggable(CatFrame, CatFrame)
        
        local ContentFrame = Instance.new("Frame")
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Parent = CatFrame
        ContentFrame.BackgroundColor3 = Library.Theme.Background
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
                CatFrame.Size = UDim2.new(0, 220, 0, 40 + h)
                ContentFrame.Size = UDim2.new(1, 0, 0, h)
            else
                CatFrame.Size = UDim2.new(0, 220, 0, 40)
                ContentFrame.Size = UDim2.new(1, 0, 0, 0)
            end
        end
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCatSize)
        
        ExpandBtn.MouseButton1Click:Connect(function()
            Category.Expanded = not Category.Expanded
            ExpandBtn.Image = Category.Expanded and Library.Icons.ArrowUp or Library.Icons.ArrowDown
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
                Settings = {}
            }
            table.insert(Category.Modules, Module)
            Library.Toggles[modOptions.Name] = Module

            local ModFrame = Instance.new("Frame")
            ModFrame.Name = Module.Name
            ModFrame.Parent = ContentFrame
            ModFrame.BackgroundColor3 = Library.Theme.ModuleBg
            ModFrame.Size = UDim2.new(1, 0, 0, 30)
            
            local ModUICorner = Instance.new("UICorner")
            ModUICorner.CornerRadius = UDim.new(0, 4)
            ModUICorner.Parent = ModFrame
            
            local ModBtn = Instance.new("TextButton")
            ModBtn.Parent = ModFrame
            ModBtn.BackgroundTransparency = 1
            ModBtn.Size = UDim2.new(1, 0, 0, 30)
            ModBtn.Text = ""
            
            local ModLabel = Instance.new("TextLabel")
            ModLabel.Parent = ModFrame
            ModLabel.BackgroundTransparency = 1
            ModLabel.Position = UDim2.new(0, 10, 0, 0)
            ModLabel.Size = UDim2.new(1, -40, 0, 30)
            ModLabel.Font = Enum.Font.Gotham
            ModLabel.Text = Module.Name
            ModLabel.TextColor3 = Library.Theme.TextDim
            ModLabel.TextSize = 14
            ModLabel.TextXAlignment = Enum.TextXAlignment.Center
            
            local StatusDot = Instance.new("Frame")
            StatusDot.Parent = ModFrame
            StatusDot.BackgroundColor3 = Library.Theme.Off
            StatusDot.Position = UDim2.new(1, -15, 0.5, -3)
            StatusDot.Size = UDim2.new(0, 6, 0, 6)
            local DotUICorner = Instance.new("UICorner")
            DotUICorner.CornerRadius = UDim.new(1, 0)
            DotUICorner.Parent = StatusDot
            
            local SettingsFrame = Instance.new("Frame")
            SettingsFrame.Name = "SettingsFrame"
            SettingsFrame.Parent = ModFrame
            SettingsFrame.BackgroundColor3 = Library.Theme.ModuleExpandedBg
            SettingsFrame.Position = UDim2.new(0, 0, 0, 30)
            SettingsFrame.Size = UDim2.new(1, 0, 0, 0)
            SettingsFrame.ClipsDescendants = true
            SettingsFrame.Visible = false
            
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

            local function UpdateModSize()
                if Module.Expanded then
                    local h = SettingsLayout.AbsoluteContentSize.Y + 8
                    ModFrame.Size = UDim2.new(1, 0, 0, 30 + h)
                    SettingsFrame.Size = UDim2.new(1, 0, 0, h)
                else
                    ModFrame.Size = UDim2.new(1, 0, 0, 30)
                    SettingsFrame.Size = UDim2.new(1, 0, 0, 0)
                end
                UpdateCatSize()
            end
            
            SettingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateModSize)

            function Module:SetValue(val)
                Module.Value = val
                ModLabel.TextColor3 = val and Library.Theme.Accent or Library.Theme.TextDim
                StatusDot.BackgroundColor3 = val and Library.Theme.On or Library.Theme.Off
                if modOptions.Callback then modOptions.Callback(val) end
            end
            
            ModBtn.MouseButton1Click:Connect(function()
                Module:SetValue(not Module.Value)
            end)
            
            ModBtn.MouseButton2Click:Connect(function()
                Module.Expanded = not Module.Expanded
                SettingsFrame.Visible = Module.Expanded
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
                SLabel.Font = Enum.Font.Gotham
                SLabel.Text = name .. ":"
                SLabel.TextColor3 = Library.Theme.TextDim
                SLabel.TextSize = 12
                SLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local SVal = Instance.new("TextLabel")
                SVal.Parent = SFrame
                SVal.BackgroundTransparency = 1
                SVal.Size = UDim2.new(1, 0, 0, 15)
                SVal.Font = Enum.Font.Gotham
                SVal.Text = tostring(Slider.Value)
                SVal.TextColor3 = Library.Theme.Text
                SVal.TextSize = 12
                SVal.TextXAlignment = Enum.TextXAlignment.Right
                
                local STrack = Instance.new("Frame")
                STrack.Parent = SFrame
                STrack.BackgroundColor3 = Library.Theme.Stroke
                STrack.Position = UDim2.new(0, 0, 0, 20)
                STrack.Size = UDim2.new(1, 0, 0, 4)
                Instance.new("UICorner", STrack).CornerRadius = UDim.new(1,0)
                
                local SFill = Instance.new("Frame")
                SFill.Parent = STrack
                SFill.BackgroundColor3 = Library.Theme.Accent
                SFill.Size = UDim2.new((Slider.Value - opts.Min) / (opts.Max - opts.Min), 0, 1, 0)
                Instance.new("UICorner", SFill).CornerRadius = UDim.new(1,0)
                
                local SBtn = Instance.new("TextButton")
                SBtn.Parent = SFrame
                SBtn.BackgroundTransparency = 1
                SBtn.Position = UDim2.new(0, 0, 0, 15)
                SBtn.Size = UDim2.new(1, 0, 0, 15)
                SBtn.Text = ""
                
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
                    SFill.Size = UDim2.new((val - opts.Min) / (opts.Max - opts.Min), 0, 1, 0)
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
                TIcon.ImageColor3 = Toggle.Value and Library.Theme.On or Library.Theme.Off
                
                local TLabel = Instance.new("TextLabel")
                TLabel.Parent = TFrame
                TLabel.BackgroundTransparency = 1
                TLabel.Position = UDim2.new(0, 20, 0, 0)
                TLabel.Size = UDim2.new(1, -20, 1, 0)
                TLabel.Font = Enum.Font.Gotham
                TLabel.Text = name
                TLabel.TextColor3 = Library.Theme.TextDim
                TLabel.TextSize = 12
                TLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local TBtn = Instance.new("TextButton")
                TBtn.Parent = TFrame
                TBtn.BackgroundTransparency = 1
                TBtn.Size = UDim2.new(1, 0, 1, 0)
                TBtn.Text = ""
                
                function Toggle:SetValue(val)
                    Toggle.Value = val
                    TIcon.Image = val and Library.Icons.Check or Library.Icons.X
                    TIcon.ImageColor3 = val and Library.Theme.On or Library.Theme.Off
                    TLabel.TextColor3 = val and Library.Theme.Text or Library.Theme.TextDim
                    if opts.Callback then opts.Callback(val) end
                end
                
                TBtn.MouseButton1Click:Connect(function()
                    Toggle:SetValue(not Toggle.Value)
                end)
                
                return Toggle
            end

            function Module:AddDropdown(name, opts)
                local Dropdown = { Value = opts.Default, Multi = opts.Multi or false }
                if Dropdown.Multi and type(Dropdown.Value) ~= "table" then
                    Dropdown.Value = {}
                end
                Library.Options[name] = Dropdown
                
                local DFrame = Instance.new("Frame")
                DFrame.Parent = SettingsFrame
                DFrame.BackgroundTransparency = 1
                DFrame.Size = UDim2.new(1, 0, 0, 30)
                
                local DLabel = Instance.new("TextLabel")
                DLabel.Parent = DFrame
                DLabel.BackgroundTransparency = 1
                DLabel.Size = UDim2.new(1, 0, 0, 15)
                DLabel.Font = Enum.Font.Gotham
                DLabel.Text = name .. ":"
                DLabel.TextColor3 = Library.Theme.TextDim
                DLabel.TextSize = 12
                DLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local DBtn = Instance.new("TextButton")
                DBtn.Parent = DFrame
                DBtn.BackgroundColor3 = Library.Theme.Stroke
                DBtn.Position = UDim2.new(0, 0, 0, 15)
                DBtn.Size = UDim2.new(1, 0, 0, 20)
                DBtn.Font = Enum.Font.Gotham
                DBtn.Text = type(Dropdown.Value)=="table" and "Multiple" or tostring(Dropdown.Value or "...")
                DBtn.TextColor3 = Library.Theme.Text
                DBtn.TextSize = 12
                Instance.new("UICorner", DBtn).CornerRadius = UDim.new(0,4)
                
                local ListFrame = Instance.new("Frame")
                ListFrame.Parent = SettingsFrame
                ListFrame.BackgroundColor3 = Library.Theme.Stroke
                ListFrame.Size = UDim2.new(1, 0, 0, 0)
                ListFrame.Visible = false
                ListFrame.ClipsDescendants = true
                Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0,4)
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Parent = ListFrame
                
                local SearchBox = Instance.new("TextBox")
                SearchBox.Parent = ListFrame
                SearchBox.BackgroundTransparency = 1
                SearchBox.Size = UDim2.new(1, -10, 0, 20)
                SearchBox.Position = UDim2.new(0, 5, 0, 0)
                SearchBox.Font = Enum.Font.Gotham
                SearchBox.PlaceholderText = "Search..."
                SearchBox.Text = ""
                SearchBox.TextColor3 = Library.Theme.Text
                SearchBox.TextSize = 12
                SearchBox.TextXAlignment = Enum.TextXAlignment.Left
                
                local ItemBtns = {}
                local function BuildList()
                    for _, v in pairs(ItemBtns) do v:Destroy() end
                    ItemBtns = {}
                    local h = 20
                    for _, val in pairs(opts.Values) do
                        if SearchBox.Text == "" or tostring(val):lower():find(SearchBox.Text:lower()) then
                            local IBtn = Instance.new("TextButton")
                            IBtn.Parent = ListFrame
                            IBtn.BackgroundTransparency = 1
                            IBtn.Size = UDim2.new(1, -10, 0, 20)
                            IBtn.Position = UDim2.new(0, 5, 0, h)
                            IBtn.Font = Enum.Font.Gotham
                            IBtn.Text = tostring(val)
                            
                            local isSelected = false
                            if Dropdown.Multi then
                                isSelected = Dropdown.Value[val]
                            else
                                isSelected = (Dropdown.Value == val)
                            end
                            IBtn.TextColor3 = isSelected and Library.Theme.Accent or Library.Theme.TextDim
                            IBtn.TextSize = 12
                            IBtn.TextXAlignment = Enum.TextXAlignment.Left
                            
                            IBtn.MouseButton1Click:Connect(function()
                                if Dropdown.Multi then
                                    Dropdown.Value[val] = not Dropdown.Value[val]
                                else
                                    Dropdown.Value = val
                                    ListFrame.Visible = false
                                    DFrame.Size = UDim2.new(1, 0, 0, 35)
                                    UpdateModSize()
                                end
                                Dropdown:SetValue(Dropdown.Value)
                                BuildList()
                            end)
                            table.insert(ItemBtns, IBtn)
                            h = h + 20
                        end
                    end
                    if ListFrame.Visible then
                        ListFrame.Size = UDim2.new(1, 0, 0, h)
                        DFrame.Size = UDim2.new(1, 0, 0, 35 + h)
                    end
                    UpdateModSize()
                end
                
                SearchBox.Changed:Connect(function(p)
                    if p == "Text" then BuildList() end
                end)
                
                DBtn.MouseButton1Click:Connect(function()
                    ListFrame.Visible = not ListFrame.Visible
                    if not ListFrame.Visible then
                        DFrame.Size = UDim2.new(1, 0, 0, 35)
                    end
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
                    if opts.Callback then opts.Callback(val) end
                end
                
                Dropdown:SetValue(Dropdown.Value)
                return Dropdown
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
    Watermark.BackgroundColor3 = Library.Theme.CategoryHeader
    Watermark.Position = UDim2.new(0, 20, 0, 20)
    Watermark.Size = UDim2.new(0, 300, 0, 30)
    Watermark.Visible = false
    Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 6)
    
    local WMText = Instance.new("TextLabel")
    WMText.Parent = Watermark
    WMText.BackgroundTransparency = 1
    WMText.Size = UDim2.new(1, -20, 1, 0)
    WMText.Position = UDim2.new(0, 10, 0, 0)
    WMText.Font = Enum.Font.GothamMedium
    WMText.TextColor3 = Library.Theme.Text
    WMText.TextSize = 14
    WMText.TextXAlignment = Enum.TextXAlignment.Left
    
    MakeDraggable(Watermark, Watermark)
    
    function Library.HUD:SetWatermark(opts)
        Watermark.Visible = true
        WMText.Text = string.format("<font color='#d05ce3'>%s</font> | %s | %s", opts.Name or "nameclient", opts.Server or "localhost", opts.FPS or "60 fps")
        WMText.RichText = true
        Watermark.Size = UDim2.new(0, WMText.TextBounds.X + 40, 0, 30)
    end
    
    local hudLayoutY = 80
    function Library.HUD:AddList(name, opts)
        local List = {}
        local LFrame = Instance.new("Frame")
        LFrame.Name = name
        LFrame.Parent = HUDContainer
        LFrame.BackgroundColor3 = Library.Theme.CategoryHeader
        LFrame.Position = UDim2.new(0, 20, 0, hudLayoutY)
        LFrame.Size = UDim2.new(0, 150, 0, 30)
        hudLayoutY = hudLayoutY + 60
        Instance.new("UICorner", LFrame).CornerRadius = UDim.new(0, 6)
        
        MakeDraggable(LFrame, LFrame)
        
        local LIcon = Instance.new("ImageLabel")
        LIcon.Parent = LFrame
        LIcon.BackgroundTransparency = 1
        LIcon.Position = UDim2.new(0, 8, 0, 8)
        LIcon.Size = UDim2.new(0, 14, 0, 14)
        LIcon.Image = opts.Icon or Library.Icons.Misc
        LIcon.ImageColor3 = Library.Theme.Accent
        
        local LTitle = Instance.new("TextLabel")
        LTitle.Parent = LFrame
        LTitle.BackgroundTransparency = 1
        LTitle.Position = UDim2.new(0, 30, 0, 0)
        LTitle.Size = UDim2.new(1, -30, 0, 30)
        LTitle.Font = Enum.Font.GothamMedium
        LTitle.Text = name
        LTitle.TextColor3 = Library.Theme.Text
        LTitle.TextSize = 14
        LTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        local LContent = Instance.new("Frame")
        LContent.Parent = LFrame
        LContent.BackgroundTransparency = 1
        LContent.Position = UDim2.new(0, 0, 0, 30)
        LContent.Size = UDim2.new(1, 0, 0, 0)
        
        local LLayout = Instance.new("UIListLayout")
        LLayout.Parent = LContent
        
        LLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            LContent.Size = UDim2.new(1, 0, 0, LLayout.AbsoluteContentSize.Y)
            LFrame.Size = UDim2.new(0, 150, 0, 30 + LLayout.AbsoluteContentSize.Y + 5)
        end)
        
        function List:AddItem(leftText, rightText, rightColor)
            local IFrame = Instance.new("Frame")
            IFrame.Parent = LContent
            IFrame.BackgroundTransparency = 1
            IFrame.Size = UDim2.new(1, 0, 0, 16)
            
            local ILeft = Instance.new("TextLabel")
            ILeft.Parent = IFrame
            ILeft.BackgroundTransparency = 1
            ILeft.Position = UDim2.new(0, 8, 0, 0)
            ILeft.Size = UDim2.new(0.5, -8, 1, 0)
            ILeft.Font = Enum.Font.Gotham
            ILeft.Text = leftText
            ILeft.TextColor3 = Library.Theme.Text
            ILeft.TextSize = 12
            ILeft.TextXAlignment = Enum.TextXAlignment.Left
            
            local IRight = Instance.new("TextLabel")
            IRight.Parent = IFrame
            IRight.BackgroundTransparency = 1
            IRight.Position = UDim2.new(0.5, 0, 0, 0)
            IRight.Size = UDim2.new(0.5, -8, 1, 0)
            IRight.Font = Enum.Font.Gotham
            IRight.Text = rightText or ""
            IRight.TextColor3 = rightColor or Library.Theme.TextDim
            IRight.TextSize = 12
            IRight.TextXAlignment = Enum.TextXAlignment.Right
            
            return {
                Update = function(nl, nr, nc)
                    if nl then ILeft.Text = nl end
                    if nr then IRight.Text = nr end
                    if nc then IRight.TextColor3 = nc end
                end,
                Remove = function() IFrame:Destroy() end
            }
        end
        return List
    end
    
    local TargetFrame = Instance.new("Frame")
    TargetFrame.Name = "TargetHUD"
    TargetFrame.Parent = HUDContainer
    TargetFrame.BackgroundColor3 = Library.Theme.CategoryHeader
    TargetFrame.Position = UDim2.new(1, -250, 1, -100)
    TargetFrame.Size = UDim2.new(0, 220, 0, 60)
    TargetFrame.Visible = false
    Instance.new("UICorner", TargetFrame).CornerRadius = UDim.new(0, 6)
    
    local THead = Instance.new("ImageLabel")
    THead.Parent = TargetFrame
    THead.BackgroundColor3 = Library.Theme.ModuleBg
    THead.Position = UDim2.new(0, 10, 0, 10)
    THead.Size = UDim2.new(0, 40, 0, 40)
    Instance.new("UICorner", THead).CornerRadius = UDim.new(0, 6)
    
    local TName = Instance.new("TextLabel")
    TName.Parent = TargetFrame
    TName.BackgroundTransparency = 1
    TName.Position = UDim2.new(0, 60, 0, 10)
    TName.Size = UDim2.new(1, -70, 0, 15)
    TName.Font = Enum.Font.GothamMedium
    TName.Text = "Target"
    TName.TextColor3 = Library.Theme.Text
    TName.TextSize = 14
    TName.TextXAlignment = Enum.TextXAlignment.Left
    
    local TDist = Instance.new("TextLabel")
    TDist.Parent = TargetFrame
    TDist.BackgroundTransparency = 1
    TDist.Position = UDim2.new(0, 60, 0, 25)
    TDist.Size = UDim2.new(1, -70, 0, 15)
    TDist.Font = Enum.Font.Gotham
    TDist.Text = "distance: 0,0 blocks"
    TDist.TextColor3 = Library.Theme.TextDim
    TDist.TextSize = 11
    TDist.TextXAlignment = Enum.TextXAlignment.Left
    
    local THBbg = Instance.new("Frame")
    THBbg.Parent = TargetFrame
    THBbg.BackgroundColor3 = Library.Theme.ModuleBg
    THBbg.Position = UDim2.new(0, 60, 0, 45)
    THBbg.Size = UDim2.new(1, -70, 0, 6)
    Instance.new("UICorner", THBbg).CornerRadius = UDim.new(1, 0)
    
    local THBfill = Instance.new("Frame")
    THBfill.Parent = THBbg
    THBfill.BackgroundColor3 = Library.Theme.Accent
    THBfill.Size = UDim2.new(1, 0, 1, 0)
    Instance.new("UICorner", THBfill).CornerRadius = UDim.new(1, 0)
    
    MakeDraggable(TargetFrame, TargetFrame)
    
    function Library.HUD:SetTarget(opts)
        if not opts then
            TargetFrame.Visible = false
            return
        end
        TargetFrame.Visible = true
        TName.Text = opts.Name or "Target"
        TDist.Text = "distance: " .. (opts.Distance or "0,0") .. " blocks"
        THead.Image = opts.Image or ""
        
        local hp = opts.Health or 100
        local maxhp = opts.MaxHealth or 100
        Tween(THBfill, {Size = UDim2.new(math.clamp(hp/maxhp, 0, 1), 0, 1, 0)}, 0.2)
    end

    return Window
end

return Library
