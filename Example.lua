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

local InfJumpMod = PlayerCat:AddModule({ Name = "Infinite Jump", Default = false })
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Library.Options["Infinite Jump"] and Library.Options["Infinite Jump"].Value then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

local FlyMod = PlayerCat:AddModule({ Name = "Fly", Default = false })
local flyConnection
FlyMod:AddToggle("Enable Fly", { Default = false, Callback = function(val)
    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if val and hrp then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyBodyVelo"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        
        flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local moveVec = require(game.Players.LocalPlayer.PlayerScripts.PlayerModule):GetControls():GetMoveVector()
            local dir = cam.CFrame.LookVector * (moveVec.Z * -1) + cam.CFrame.RightVector * moveVec.X
            bv.Velocity = dir * 50
        end)
    else
        if hrp and hrp:FindFirstChild("FlyBodyVelo") then
            hrp.FlyBodyVelo:Destroy()
        end
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
    end
end})

local ClickTpMod = PlayerCat:AddModule({ Name = "Click TP", Default = false })
local mouse = game.Players.LocalPlayer:GetMouse()
mouse.Button1Down:Connect(function()
    if Library.Options["Click TP"] and Library.Options["Click TP"].Value and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and mouse.Hit then
            char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)
ClickTpMod:AddLabel("Hold LeftControl and Click to TP")

-- Visuals Category Modules
local VisualsCat = Window:AddCategory({ Title = "Visuals", Icon = Library.Icons.Render })

local EspMod = VisualsCat:AddModule({ Name = "ESP / Highlights", Default = false })
local espHighlights = {}
EspMod:AddToggle("Enable ESP", { Default = false, Callback = function(val)
    if val then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character then
                local hl = Instance.new("Highlight")
                hl.Parent = v.Character
                hl.FillColor = Color3.new(1, 0, 0)
                hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.new(1, 1, 1)
                espHighlights[v] = hl
            end
        end
    else
        for _, hl in pairs(espHighlights) do
            if hl.Parent then hl:Destroy() end
        end
        table.clear(espHighlights)
    end
end})

local TracerMod = VisualsCat:AddModule({ Name = "Tracers", Default = false })
local tracers = {}
game:GetService("RunService").RenderStepped:Connect(function()
    if Library.Options["Tracers"] and Library.Options["Tracers"].Value then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local line = tracers[p] or Drawing.new("Line")
                    line.Visible = true
                    line.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    line.To = Vector2.new(vector.X, vector.Y)
                    line.Color = Color3.new(1, 0, 0)
                    line.Thickness = 2
                    tracers[p] = line
                else
                    if tracers[p] then tracers[p].Visible = false end
                end
            else
                if tracers[p] then
                    tracers[p].Visible = false
                end
            end
        end
    else
        for _, t in pairs(tracers) do t.Visible = false end
    end
end)

local ChinaHatMod = VisualsCat:AddModule({ Name = "China Hat", Default = false })
local chinaHatPart
game:GetService("RunService").RenderStepped:Connect(function()
    if Library.Options["China Hat"] and Library.Options["China Hat"].Value then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Head") then
            if not chinaHatPart then
                chinaHatPart = Instance.new("Part")
                chinaHatPart.Size = Vector3.new(3, 0.5, 3)
                chinaHatPart.Anchored = true
                chinaHatPart.CanCollide = false
                chinaHatPart.Material = Enum.Material.Neon
                chinaHatPart.Color = Color3.fromRGB(208, 92, 227)
                local mesh = Instance.new("SpecialMesh")
                mesh.Parent = chinaHatPart
                mesh.MeshType = Enum.MeshType.FileMesh
                mesh.MeshId = "rbxassetid://1697520448"
                chinaHatPart.Parent = workspace
            end
            chinaHatPart.CFrame = char.Head.CFrame * CFrame.new(0, 1, 0)
        end
    else
        if chinaHatPart then
            chinaHatPart:Destroy()
            chinaHatPart = nil
        end
    end
end)

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
local ConfigList = ConfigMod:AddDropdown("Saved Configs", { Values = Library.SaveManager:GetConfigs(), Default = "default" })

ConfigMod:AddButton("Save Config", function()
    Library.SaveManager:Save(ConfigNameBox.Value)
    ConfigList:SetValues(Library.SaveManager:GetConfigs())
end)

ConfigMod:AddButton("Load Selected Config", function()
    if ConfigList.Value then
        Library.SaveManager:Load(ConfigList.Value)
    end
end)

-- HUD Elements setup
Library.HUD:SetWatermark({
    Name = "RobloxClient",
    Server = "Public",
    FPS = "60 fps"
})
