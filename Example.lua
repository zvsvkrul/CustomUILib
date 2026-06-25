local Library = loadstring(readfile("CustomUILib/Library.lua"))()

local Window = Library:CreateWindow({
    Name = "Client Menu"
})

-- Build Categories
local CombatCat = Window:AddCategory({ Title = "Combat", Icon = Library.Icons.Combat })
local MovementCat = Window:AddCategory({ Title = "Movement", Icon = Library.Icons.Movement })
local RenderCat = Window:AddCategory({ Title = "Render", Icon = Library.Icons.Render })
local PlayerCat = Window:AddCategory({ Title = "Player", Icon = Library.Icons.Player })
local MiscCat = Window:AddCategory({ Title = "Misc", Icon = Library.Icons.Misc })

-- Add Modules to Combat
local AuraModule = CombatCat:AddModule({ Name = "Aura", Default = true })
AuraModule:AddSlider("Range", { Default = 3, Min = 1, Max = 6, Rounding = 1 })
AuraModule:AddDropdown("Mode", { Values = {"Single", "Switch", "Multi"}, Default = "Switch", Multi = false })

local AutoArmorModule = CombatCat:AddModule({ Name = "AutoArmor", Default = false })
local VelocityModule = CombatCat:AddModule({ Name = "Velocity", Default = true })
VelocityModule:AddSlider("Horizontal", { Default = 0, Min = 0, Max = 100, Rounding = 0 })
VelocityModule:AddSlider("Vertical", { Default = 0, Min = 0, Max = 100, Rounding = 0 })

local CriticalsModule = CombatCat:AddModule({ Name = "Criticals", Default = false })
CriticalsModule:AddToggle("Only when falling", { Default = true })
CriticalsModule:AddToggle("Packet mode", { Default = false })

-- Add Modules to Movement
local SprintModule = MovementCat:AddModule({ Name = "Sprint", Default = true })
local SpeedModule = MovementCat:AddModule({ Name = "Speed", Default = false })
SpeedModule:AddSlider("Value", { Default = 1.5, Min = 1, Max = 5, Rounding = 1 })
SpeedModule:AddDropdown("Mode", { Values = {"Vanilla", "NCP", "Hypixel", "Matrix"}, Default = "Vanilla" })

local FlyModule = MovementCat:AddModule({ Name = "Fly", Default = false })
local StepModule = MovementCat:AddModule({ Name = "Step", Default = false })
local SafeWalkModule = MovementCat:AddModule({ Name = "SafeWalk", Default = true })

-- HUD Elements setup
Library.HUD:SetWatermark({
    Name = "nameclient",
    Server = "localhost",
    FPS = "60 fps"
})

local KeysList = Library.HUD:AddList("Клавиши", { Icon = Library.Icons.Combat })
KeysList:AddItem("Aura", "[R]", Library.Theme.TextDim)
KeysList:AddItem("Sprint", "[V]", Library.Theme.TextDim)

local StaffList = Library.HUD:AddList("Персонал", { Icon = Library.Icons.Player })
StaffList:AddItem("admin", "atomskycode", Library.Theme.TextDim)

local EffectsList = Library.HUD:AddList("Эффекты", { Icon = Library.Icons.Misc })
EffectsList:AddItem("Speed II", "01:30", Library.Theme.Accent)

local EventsList = Library.HUD:AddList("События", { Icon = Library.Icons.Misc })
EventsList:AddItem("AirDrop", "04:55", Library.Theme.Accent)

-- Target HUD
Library.HUD:SetTarget({
    Name = "atomskycode",
    Distance = "3.2",
    Health = 80,
    MaxHealth = 100,
    Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
})

-- Load Config
Library.SaveManager:SetFolder("MyClientConfigs")
-- Library.SaveManager:Load("default")
