local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zvsvkrul/CustomUILib/refs/heads/main/Library.lua?t=" .. tostring(tick())))()

local Window = Library:CreateWindow({
    Name = "My Roblox Menu"
})

-- Build Categories
local PlayerCat = Window:AddCategory({ Title = "LocalPlayer", Icon = Library.Icons.Player })
local CombatCat = Window:AddCategory({ Title = "Combat", Icon = Library.Icons.Combat })
local RenderCat = Window:AddCategory({ Title = "Render", Icon = Library.Icons.Render })

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

local InfiniteJump = PlayerCat:AddModule({ Name = "Infinite Jump", Default = false })

-- Combat Category Modules
local AimbotMod = CombatCat:AddModule({ Name = "Aimbot", Default = false })
AimbotMod:AddDropdown("Target Part", { Values = {"Head", "HumanoidRootPart", "Torso"}, Default = "Head" })
AimbotMod:AddToggle("Show FOV", { Default = true })
AimbotMod:AddSlider("FOV Size", { Default = 100, Min = 10, Max = 500, Rounding = 0 })

local ESPMod = RenderCat:AddModule({ Name = "ESP", Default = true })
ESPMod:AddToggle("Boxes", { Default = true })
ESPMod:AddToggle("Names", { Default = true })
ESPMod:AddToggle("Health", { Default = false })
ESPMod:AddDropdown("Color Mode", { Values = {"Team", "Custom"}, Default = "Team" })

-- HUD Elements setup (Keeping the watermark)
Library.HUD:SetWatermark({
    Name = "RobloxClient",
    Server = "Public",
    FPS = "60 fps"
})

-- Load Config
Library.SaveManager:SetFolder("RobloxClientConfigs")
-- Library.SaveManager:Load("default")
