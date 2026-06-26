local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zvsvkrul/CustomUILib/refs/heads/main/Library.lua?t=" .. tostring(tick())))()

local Window = Library:CreateWindow({
    Name = "My Roblox Menu"
})

-- Build Categories
local PlayerCat = Window:AddCategory({ Title = "LocalPlayer", Icon = Library.Icons.Player })
local SettingsCat = Window:AddCategory({ Title = "Settings", Icon = Library.Icons.Settings })

-- LocalPlayer Category Modules
local WalkSpeedMod = PlayerCat:AddModule({ Name = "WalkSpeed", Default = false })
WalkSpeedMod:AddSlider("Speed", { Default = 16, Min = 16, Max = 100, Rounding = 0, Callback = function(val)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = val
    end
end})

local JumpPowerMod = PlayerCat:AddModule({ Name = "JumpPower", Default = false })
JumpPowerMod:AddSlider("Power", { Default = 50, Min = 50, Max = 200, Rounding = 0, Callback = function(val)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.UseJumpPower = true
        char.Humanoid.JumpPower = val
    end
end})

-- Settings Category: Theme Customization
local ThemeMod = SettingsCat:AddModule({ Name = "Theme Configuration", Default = true })

local function UpdateAccentColor()
    local r = Library.Options["Accent R"].Value
    local g = Library.Options["Accent G"].Value
    local b = Library.Options["Accent B"].Value
    Library:SetThemeColor("Accent", Color3.fromRGB(r, g, b))
    
    -- Refresh watermark text to match new hex code
    Library.HUD:SetWatermark({
        Name = "RobloxClient",
        Server = "Public",
        FPS = "60 fps"
    })
end

ThemeMod:AddSlider("Accent R", { Default = 208, Min = 0, Max = 255, Rounding = 0, Callback = UpdateAccentColor })
ThemeMod:AddSlider("Accent G", { Default = 92, Min = 0, Max = 255, Rounding = 0, Callback = UpdateAccentColor })
ThemeMod:AddSlider("Accent B", { Default = 227, Min = 0, Max = 255, Rounding = 0, Callback = UpdateAccentColor })

local ConfigMod = SettingsCat:AddModule({ Name = "Config Manager", Default = true })
Library.SaveManager:SetFolder("MyRobloxMenuConfigs")

local ConfigNameBox = ConfigMod:AddTextBox("Config Name", "default")
ConfigMod:AddButton("Save Config", function()
    Library.SaveManager:Save(ConfigNameBox.Value)
end)
ConfigMod:AddButton("Load Config", function()
    Library.SaveManager:Load(ConfigNameBox.Value)
end)

-- HUD Elements setup
Library.HUD:SetWatermark({
    Name = "RobloxClient",
    Server = "Public",
    FPS = "60 fps"
})
