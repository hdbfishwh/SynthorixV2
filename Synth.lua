local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else 
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Get player info
local playerName = LocalPlayer.Name
local displayName = LocalPlayer.DisplayName

-- Configuration
local Config = {
    ESP = {
        Enabled = false,
        BoxColor = Color3.new(1, 0.3, 0),
        DistanceColor = Color3.new(1, 1, 1),
        UsernameColor = Color3.new(1, 1, 1),
        HealthGradient = {
            Color3.new(0, 1, 0),
            Color3.new(1, 1, 0),
            Color3.new(1, 0, 0)
        },
        SnaplineEnabled = true,
        SnaplinePosition = "Center",
        RainbowEnabled = false,
        ShowUsername = true
    },
    Aimbot = {
        Enabled = false,
        FOV = 30,
        MaxDistance = 200,
        ShowFOV = false,
        TargetPart = "Head",
        BigHead = {
            Enabled = false,
            Size = 15
        }
    }
}

-- Variables
local RainbowSpeed = 0.5
local ESPDrawings = {}
local BigHeadEnabled = Config.Aimbot.BigHead.Enabled
local BigHeadSize = Config.Aimbot.BigHead.Size

-- ESP Functions
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local drawings = {
        Box = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Distance = Drawing.new("Text"),
        Username = Drawing.new("Text"),
        Snapline = Drawing.new("Line")
    }
    
    for _, drawing in pairs(drawings) do
        drawing.Visible = false
        if drawing.Type == "Square" then
            drawing.Thickness = 2
            drawing.Filled = false
        end
    end
    
    drawings.Box.Color = Config.ESP.BoxColor
    drawings.HealthBar.Filled = true
    drawings.Distance.Size = 16
    drawings.Distance.Center = true
    drawings.Distance.Color = Config.ESP.DistanceColor
    
    drawings.Username.Size = 16
    drawings.Username.Center = true
    drawings.Username.Color = Config.ESP.UsernameColor
    drawings.Username.Text = player.Name
    
    drawings.Snapline.Color = Config.ESP.BoxColor
    
    ESPDrawings[player] = drawings
end

local function UpdateESP(player, drawings)
    if not Config.ESP.Enabled or not player.Character then
        for _, drawing in pairs(drawings) do
            drawing.Visible = false
        end
        return
    end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local head = player.Character:FindFirstChild("Head")
    
    if not humanoid or humanoid.Health <= 0 or not head then
        for _, drawing in pairs(drawings) do
            drawing.Visible = false
        end
        return
    end
    
    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
    if not onScreen then
        for _, drawing in pairs(drawings) do
            drawing.Visible = false
        end
        return
    end
    
    local distance = (head.Position - Camera.CFrame.Position).Magnitude
    local scale = 1000 / distance
    
    -- Box ESP
    drawings.Box.Size = Vector2.new(scale, scale * 1.5)
    drawings.Box.Position = Vector2.new(headPos.X - (scale / 2), headPos.Y - (scale * 0.75))
    drawings.Box.Visible = true
    
    -- Health Bar
    local healthRatio = humanoid.Health / humanoid.MaxHealth
    local healthColorIndex = math.clamp(3 - (healthRatio * 2), 1, 3)
    local healthColor = Config.ESP.HealthGradient[math.floor(healthColorIndex)]:Lerp(
        Config.ESP.HealthGradient[math.ceil(healthColorIndex)],
        healthColorIndex % 1
    )
    
    drawings.HealthBar.Size = Vector2.new(4, scale * 1.5 * healthRatio)
    drawings.HealthBar.Position = Vector2.new(
        headPos.X + (scale / 2) + 5,
        (headPos.Y - (scale * 0.75)) + (scale * 1.5 * (1 - healthRatio))
    )
    drawings.HealthBar.Color = healthColor
    drawings.HealthBar.Visible = true
    
    -- Distance
    drawings.Distance.Text = math.floor(distance) .. "m"
    drawings.Distance.Position = Vector2.new(headPos.X, headPos.Y + (scale * 0.75) + 10)
    drawings.Distance.Visible = true
    
    -- Username
    if Config.ESP.ShowUsername then
        drawings.Username.Text = player.Name
        drawings.Username.Position = Vector2.new(headPos.X, headPos.Y - (scale * 0.75) - 20)
        drawings.Username.Visible = true
    else
        drawings.Username.Visible = false
    end
    
    -- Rainbow effect
    if Config.ESP.RainbowEnabled then
        local hue = (tick() * RainbowSpeed) % 1
        local rainbowColor = Color3.fromHSV(hue, 1, 1)
        drawings.Snapline.Color = rainbowColor
        drawings.Box.Color = rainbowColor
        drawings.Username.Color = rainbowColor
    else
        drawings.Snapline.Color = Config.ESP.BoxColor
        drawings.Box.Color = Config.ESP.BoxColor
        drawings.Username.Color = Config.ESP.UsernameColor
    end
    
    -- Snapline
    if Config.ESP.SnaplineEnabled then
        local lineYPosition
        if Config.ESP.SnaplinePosition == "Bottom" then
            lineYPosition = Camera.ViewportSize.Y
        elseif Config.ESP.SnaplinePosition == "Top" then
            lineYPosition = 0
        else
            lineYPosition = Camera.ViewportSize.Y / 2
        end
        
        drawings.Snapline.From = Vector2.new(headPos.X, headPos.Y + (scale * 0.75))
        drawings.Snapline.To = Vector2.new(Camera.ViewportSize.X / 2, lineYPosition)
        drawings.Snapline.Visible = true
    else
        drawings.Snapline.Visible = false
    end
end

-- Aimbot Functions
local function FindAimbotTarget()
    local closestTarget = nil
    local closestDistance = math.huge
    local fov = Config.Aimbot.FOV or 30
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local direction = (head.Position - Camera.CFrame.Position).Unit
            local lookVector = Camera.CFrame.LookVector
            local angle = math.deg(math.acos(direction:Dot(lookVector)))
            
            if angle <= (fov / 2) then
                local distance = (Camera.CFrame.Position - head.Position).Magnitude
                
                if distance <= Config.Aimbot.MaxDistance then
                    local ray = Ray.new(Camera.CFrame.Position, direction * 500)
                    local hitPart, _ = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                    
                    if hitPart and hitPart:IsDescendantOf(player.Character) then
                        if distance < closestDistance then
                            closestDistance = distance
                            closestTarget = player
                        end
                    end
                end
            end
        end
    end
    
    return closestTarget
end

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Visible = Config.Aimbot.ShowFOV
FOVCircle.Color = Color3.new(1, 1, 1)

-- Big Head Function
local function UpdateBigHead()
    if not BigHeadEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            pcall(function()
                local head = player.Character.Head
                head.Size = Vector3.new(BigHeadSize, BigHeadSize, BigHeadSize)
                head.Transparency = 1
                head.BrickColor = BrickColor.new("Red")
                head.Material = "Neon"
                head.CanCollide = false
                head.Massless = true
            end)
        end
    end
end

-- Welcome Popup
function createPopup()
    return WindUI:Popup({
        Title = "Welcome to Synthorix V5!",
        Icon = "bird",
        Content = "Hello " .. displayName .. ", thank you for using our script! ESP, Aimbot, and BigHead features are ready.",
        Buttons = {
            {
                Title = "Get Started",
                Icon = "arrow-right",
            }
        }
    })
end

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Synthorix V5",
    Author = "by Rai & Vilo",
    Folder = "ftgshub",
    Icon = "sfsymbols:appleLogo",
    IconSize = 44,
    NewElements = true,
    
    HideSearchBar = false,
    
    OpenButton = {
        Title = "Open Synthorix V5",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"), 
            Color3.fromHex("#e7ff2f")
        )
    }
})

-- Tags
Window:Tag({
    Title = "v" .. WindUI.Version,
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c")
})

-- Load Nebula Icons
do
    local NebulaIcons = loadstring(game:HttpGetAsync("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
    WindUI.Creator.AddIcons("fluency", NebulaIcons.Fluency)
    WindUI.Creator.AddIcons("nebula", NebulaIcons.nebulaIcons)
end

-- Create Sections
local MainSection = Window:Section({
    Title = "Combat Features",
    Icon = "nebula:nebula",
})

local VisualsSection = Window:Section({
    Title = "Visual Features",
    Icon = "eye",
})

local SettingsSection = Window:Section({
    Title = "Settings",
    Icon = "settings",
})

-- ESP Tab
local ESPTab = VisualsSection:Tab({
    Title = "ESP",
    Icon = "eye"
})

ESPTab:Paragraph({
    Title = "ESP Settings",
    Desc = "Configure your ESP features to see enemies through walls",
    Image = "eye",
    ImageSize = 20,
    Color = Color3.fromHex("#30ff6a"),
})

ESPTab:Divider()

local espToggle = ESPTab:Toggle({
    Title = "Enable ESP",
    Desc = "Toggle ESP on/off",
    Value = Config.ESP.Enabled,
    Callback = function(state) 
        Config.ESP.Enabled = state
        
        if not state then
            for _, drawings in pairs(ESPDrawings) do
                for _, drawing in pairs(drawings) do
                    drawing.Visible = false
                end
            end
        end
        
        WindUI:Notify({
            Title = "ESP",
            Content = state and "ESP Enabled" or "ESP Disabled",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

local usernameToggle = ESPTab:Toggle({
    Title = "Show Username",
    Desc = "Display player names above their heads",
    Value = Config.ESP.ShowUsername,
    Callback = function(state) 
        Config.ESP.ShowUsername = state
        
        if not state then
            for _, drawings in pairs(ESPDrawings) do
                if drawings.Username then
                    drawings.Username.Visible = false
                end
            end
        end
        
        WindUI:Notify({
            Title = "Username ESP",
            Content = state and "Username Display Enabled" or "Username Display Disabled",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

local snaplineToggle = ESPTab:Toggle({
    Title = "Enable Snapline",
    Desc = "Draw lines to players",
    Value = Config.ESP.SnaplineEnabled,
    Callback = function(state) 
        Config.ESP.SnaplineEnabled = state
        WindUI:Notify({
            Title = "Snapline",
            Content = state and "Snapline Enabled" or "Snapline Disabled",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

local rainbowToggle = ESPTab:Toggle({
    Title = "Rainbow Effect",
    Desc = "Make ESP colors rainbow",
    Value = Config.ESP.RainbowEnabled,
    Callback = function(state) 
        Config.ESP.RainbowEnabled = state
        WindUI:Notify({
            Title = "Rainbow",
            Content = state and "Rainbow Enabled" or "Rainbow Disabled",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

local snaplinePosition = ESPTab:Dropdown({
    Title = "Snapline Position",
    Values = { "Center", "Bottom", "Top" },
    Value = Config.ESP.SnaplinePosition,
    Callback = function(option)
        Config.ESP.SnaplinePosition = option
        WindUI:Notify({
            Title = "Snapline Position",
            Content = "Position: "..option,
            Duration = 2
        })
    end
})

ESPTab:Colorpicker({
    Title = "ESP Color",
    Default = Config.ESP.BoxColor,
    Callback = function(color, transparency)
        Config.ESP.BoxColor = color
        WindUI:Notify({
            Title = "ESP Color",
            Content = "Color changed",
            Duration = 2
        })
    end
})

ESPTab:Colorpicker({
    Title = "Username Color",
    Default = Config.ESP.UsernameColor,
    Callback = function(color, transparency)
        Config.ESP.UsernameColor = color
        WindUI:Notify({
            Title = "Username Color",
            Content = "Username color changed",
            Duration = 2
        })
    end
})

-- Aimbot Tab
local AimbotTab = MainSection:Tab({
    Title = "Aimbot",
    Icon = "crosshair"
})

AimbotTab:Paragraph({
    Title = "Aimbot Settings",
    Desc = "Configure your aimbot features for better accuracy",
    Image = "crosshair",
    ImageSize = 20,
    Color = Color3.fromHex("#ff3030"),
})

AimbotTab:Divider()

local aimbotToggle = AimbotTab:Toggle({
    Title = "Enable Aimbot",
    Desc = "Automatically aim at enemies",
    Value = Config.Aimbot.Enabled,
    Callback = function(state) 
        Config.Aimbot.Enabled = state
        WindUI:Notify({
            Title = "Aimbot",
            Content = state and "Aimbot Enabled" or "Aimbot Disabled",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

local fovToggle = AimbotTab:Toggle({
    Title = "Show FOV Circle",
    Desc = "Display aimbot field of view",
    Value = Config.Aimbot.ShowFOV,
    Callback = function(state) 
        Config.Aimbot.ShowFOV = state
        FOVCircle.Visible = state
        WindUI:Notify({
            Title = "FOV Circle",
            Content = state and "FOV Circle Enabled" or "FOV Circle Disabled",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

local fovSlider = AimbotTab:Slider({
    Title = "FOV Size",
    Desc = "Adjust aimbot field of view",
    Value = { Min = 5, Max = 100, Default = Config.Aimbot.FOV },
    Callback = function(value)
        Config.Aimbot.FOV = value
    end
})

local distanceSlider = AimbotTab:Slider({
    Title = "Max Distance",
    Desc = "Maximum distance to target enemies",
    Value = { Min = 10, Max = 1000, Default = Config.Aimbot.MaxDistance },
    Callback = function(value)
        Config.Aimbot.MaxDistance = value
    end
})

local targetPart = AimbotTab:Dropdown({
    Title = "Target Part",
    Values = { "Head", "Torso", "HumanoidRootPart" },
    Value = Config.Aimbot.TargetPart,
    Callback = function(option)
        Config.Aimbot.TargetPart = option
        WindUI:Notify({
            Title = "Target Part",
            Content = "Targeting: "..option,
            Duration = 2
        })
    end
})

local bigHeadToggle = AimbotTab:Toggle({
    Title = "Big Head",
    Desc = "Make enemy heads bigger for easier targeting",
    Value = Config.Aimbot.BigHead.Enabled,
    Callback = function(state) 
        Config.Aimbot.BigHead.Enabled = state
        BigHeadEnabled = state
        
        if not state then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    pcall(function()
                        player.Character.Head.Size = Vector3.new(2, 1, 1)
                        player.Character.Head.Transparency = 0
                        player.Character.Head.BrickColor = BrickColor.new("Pastel brown")
                        player.Character.Head.Material = "Plastic"
                    end)
                end
            end
        end
        
        WindUI:Notify({
            Title = "Big Head",
            Content = state and "Big Head Enabled" or "Big Head Disabled",
            Icon = state and "check" or "x",
            Duration = 2
        })
    end
})

local bigHeadSlider = AimbotTab:Slider({
    Title = "Head Size",
    Desc = "Adjust the size of enemy heads",
    Value = { Min = 5, Max = 50, Default = Config.Aimbot.BigHead.Size },
    Callback = function(value)
        Config.Aimbot.BigHead.Size = value
        BigHeadSize = value
    end
})

-- Settings Tab
local ConfigTab = SettingsSection:Tab({
    Title = "Configuration",
    Icon = "settings"
})

ConfigTab:Paragraph({
    Title = "User Information",
    Desc = "Logged in as: " .. displayName .. " (" .. playerName .. ")",
    Image = "user",
    ImageSize = 20,
    Color = "White"
})

ConfigTab:Button({
    Title = "Reset All Settings",
    Icon = "refresh-cw",
    Variant = "Danger",
    Callback = function()
        Config.ESP.Enabled = false
        Config.Aimbot.Enabled = false
        Config.Aimbot.BigHead.Enabled = false
        BigHeadEnabled = false
        
        WindUI:Notify({
            Title = "Settings Reset",
            Content = "All settings have been reset to default",
            Icon = "refresh-cw",
            Duration = 3
        })
    end
})

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    FOVCircle.Visible = Config.Aimbot.ShowFOV
    FOVCircle.Radius = (Config.Aimbot.FOV / 2) * (Camera.ViewportSize.Y / 90)
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Rainbow effect for FOV Circle
    if Config.ESP.RainbowEnabled and Config.Aimbot.ShowFOV then
        local hue = (tick() * RainbowSpeed) % 1
        FOVCircle.Color = Color3.fromHSV(hue, 1, 1)
    elseif Config.Aimbot.ShowFOV then
        FOVCircle.Color = Color3.new(1, 1, 1)
    end
    
    -- Update ESP for all players
    for player, drawings in pairs(ESPDrawings) do
        UpdateESP(player, drawings)
    end
    
    -- Aimbot functionality
    if Config.Aimbot.Enabled then
        local target = FindAimbotTarget()
        if target and target.Character and target.Character:FindFirstChild(Config.Aimbot.TargetPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[Config.Aimbot.TargetPart].Position)
        end
    end
    
    -- Update Big Head
    UpdateBigHead()
end)

-- Initialize ESP for all players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- Player Events
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
    
    player.CharacterAdded:Connect(function()
        if ESPDrawings[player] then
            for _, drawing in pairs(ESPDrawings[player]) do
                pcall(function() drawing:Remove() end)
            end
            ESPDrawings[player] = nil
        end
        CreateESP(player)
    end)
    
    player.CharacterRemoving:Connect(function()
        if ESPDrawings[player] then
            for _, drawing in pairs(ESPDrawings[player]) do
                pcall(function() drawing:Remove() end)
            end
            ESPDrawings[player] = nil
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPDrawings[player] then
        for _, drawing in pairs(ESPDrawings[player]) do
            pcall(function() drawing:Remove() end)
        end
        ESPDrawings[player] = nil
    end
end)

-- UI Toggle (RightShift to hide/show)
local UIVisible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        UIVisible = not UIVisible
        Window.Enabled = UIVisible
    end
end)

-- Welcome Notification
WindUI:Notify({
    Title = "Script Loaded",
    Content = "Welcome, " .. displayName .. "! ESP, Aimbot, and BigHead features are ready!",
    Icon = "check",
    Duration = 5
})

warn("✅ Synthorix V5 successfully loaded for " .. playerName .. "!")
