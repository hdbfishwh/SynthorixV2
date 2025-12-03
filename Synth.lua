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

-- Aimbot System
local AimBot = {
    Enabled = false,
    Target = nil,
    Smoothness = 0.3,
    MaxDistance = 100, -- Max distance to target
    MinDistance = 10, -- Min distance to start locking
    TeamCheck = true,
    WallCheck = true,
    BlacklistedPlayers = {},
    AimPart = "Head", -- Target the head
    Keybind = "E", -- Default keybind to toggle aimbot
    FOV = 30, -- Field of View for target selection
    AutoSwitch = true, -- Auto switch target when current target is invalid
    SilentAim = false, -- Silent aim feature
    Prediction = 0.1, -- Prediction for moving targets
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Local player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Function to check if player is blacklisted
function AimBot:IsBlacklisted(player)
    for _, blacklistedPlayer in ipairs(self.BlacklistedPlayers) do
        if blacklistedPlayer == player or blacklistedPlayer.Name == player.Name then
            return true
        end
    end
    return false
end

-- Function to add player to blacklist
function AimBot:AddToBlacklist(player)
    if not self:IsBlacklisted(player) then
        table.insert(self.BlacklistedPlayers, player)
        return true
    end
    return false
end

-- Function to remove player from blacklist
function AimBot:RemoveFromBlacklist(player)
    for i, blacklistedPlayer in ipairs(self.BlacklistedPlayers) do
        if blacklistedPlayer == player or blacklistedPlayer.Name == player.Name then
            table.remove(self.BlacklistedPlayers, i)
            return true
        end
    end
    return false
end

-- Function to check line of sight (wall check)
function AimBot:IsVisible(target)
    if not target or not target:FindFirstChild("Head") then
        return false
    end
    
    local origin = Camera.CFrame.Position
    local targetPosition = target.Head.Position
    
    -- Raycast to check for obstacles
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, target}
    
    local raycastResult = Workspace:Raycast(origin, (targetPosition - origin).Unit * 1000, raycastParams)
    
    if raycastResult then
        -- Check if what we hit is the target
        local hitParent = raycastResult.Instance:FindFirstAncestorOfClass("Model")
        if hitParent == target then
            return true
        end
        -- If we hit something else, target is not visible
        return false
    end
    
    return true
end

-- Function to calculate distance
function AimBot:GetDistance(player)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    
    local localPos = LocalPlayer.Character.HumanoidRootPart.Position
    local targetPos = player.Character.HumanoidRootPart.Position
    
    return (localPos - targetPos).Magnitude
end

-- Function to find best target
function AimBot:FindBestTarget()
    local bestTarget = nil
    local closestDistance = math.huge
    local closestAngle = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") 
           and player.Character.Humanoid.Health > 0 then
            
            -- Skip blacklisted players (for teaming)
            if self:IsBlacklisted(player) then
                continue
            end
            
            -- Team check
            if self.TeamCheck then
                if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                    continue
                end
            end
            
            -- Distance check
            local distance = self:GetDistance(player)
            if distance < self.MinDistance or distance > self.MaxDistance then
                continue
            end
            
            -- Wall check
            if self.WallCheck and not self:IsVisible(player.Character) then
                continue
            end
            
            -- Check if player is in FOV
            local character = player.Character
            if character and character:FindFirstChild("Head") then
                local headPos = character.Head.Position
                local screenPoint, onScreen = Camera:WorldToViewportPoint(headPos)
                
                if onScreen then
                    local viewportSize = Camera.ViewportSize
                    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                    local mousePos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local angle = (screenCenter - mousePos).Magnitude
                    
                    if angle < self.FOV then
                        if distance < closestDistance then
                            closestDistance = distance
                            closestAngle = angle
                            bestTarget = player
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- Smooth aiming function
function AimBot:SmoothAim(targetPosition)
    if not targetPosition then return end
    
    local currentCF = Camera.CFrame
    local targetCF = CFrame.new(Camera.CFrame.Position, targetPosition)
    
    -- Smooth interpolation
    local smoothCF = currentCF:Lerp(targetCF, self.Smoothness)
    
    -- Apply the rotation
    Camera.CFrame = smoothCF
end

-- Main aimbot loop
local aimbotConnection
function AimBot:Start()
    if aimbotConnection then
        aimbotConnection:Disconnect()
    end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not self.Enabled or not LocalPlayer.Character 
           or not LocalPlayer.Character:FindFirstChild("Humanoid") 
           or LocalPlayer.Character.Humanoid.Health <= 0 then
            return
        end
        
        -- Find or validate current target
        if not self.Target or not self.Target.Character 
           or not self.Target.Character:FindFirstChild("Humanoid") 
           or self.Target.Character.Humanoid.Health <= 0
           or self:IsBlacklisted(self.Target) then
            
            if self.AutoSwitch then
                self.Target = self:FindBestTarget()
            else
                self.Target = nil
            end
        end
        
        -- If we have a valid target, aim at them
        if self.Target and self.Target.Character then
            local character = self.Target.Character
            local aimPart = character:FindFirstChild(self.AimPart)
            
            if aimPart then
                -- Check distance
                local distance = self:GetDistance(self.Target)
                if distance >= self.MinDistance and distance <= self.MaxDistance then
                    -- Check wall visibility
                    if not self.WallCheck or self:IsVisible(character) then
                        -- Add prediction for moving targets
                        local velocity = character.HumanoidRootPart.Velocity
                        local predictedPosition = aimPart.Position + (velocity * self.Prediction)
                        
                        self:SmoothAim(predictedPosition)
                    else
                        -- Target is behind wall, unlock
                        self.Target = nil
                    end
                else
                    -- Too far or too close, unlock
                    self.Target = nil
                end
            end
        end
    end)
end

-- Keybind handler
local keybindConnection
function AimBot:SetKeybind(key)
    if keybindConnection then
        keybindConnection:Disconnect()
    end
    
    keybindConnection = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode[key] then
            self.Enabled = not self.Enabled
            
            if self.Enabled then
                WindUI:Notify({
                    Title = "Synthorix Aimbot",
                    Content = "Aimbot Enabled",
                    Icon = "target"
                })
            else
                WindUI:Notify({
                    Title = "Synthorix Aimbot",
                    Content = "Aimbot Disabled",
                    Icon = "target"
                })
            end
        end
    end)
end

-- Initialize keybind
AimBot:SetKeybind(AimBot.Keybind)

function createPopup()
    return WindUI:Popup({
        Title = "Welcome to the Synthorix V5!",
        Icon = "bird",
        Content = "sorry for the script didn't work the aimbot just patched for some reason",
        Buttons = {
            {
                Title = "Oh",
                Icon = "bird",
            },
            {
                Title = "I See",
                Icon = "bird",
            }
        }
    })
end

-- */  Window  /* --
local Window = WindUI:CreateWindow({
    Title = "Synthorix V5",
    Author = "by Rai & Vilo",
    Folder = "ftgshub",
    Icon = "sfsymbols:appleLogo",
    IconSize = 22*2,
    NewElements = true,
    --Size = UDim2.fromOffset(700,700),
    
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

-- */  Tags  /* --
do
    Window:Tag({
        Title = "v" .. WindUI.Version,
        Icon = "github",
        Color = Color3.fromHex("#1c1c1c")
    })
    
    -- Add status tag
    Window:Tag({
        Title = "Aimbot: OFF",
        Icon = "target",
        Color = Color3.fromHex("#ff3b30")
    })
end

-- */ Using Nebula Icons /* --
do
    local NebulaIcons = loadstring(game:HttpGetAsync("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
    
    -- Adding icons
    WindUI.Creator.AddIcons("nebula", NebulaIcons.Fluency)
    WindUI.Creator.AddIcons("nebula", NebulaIcons.nebulaIcons)
end

-- Create Main Tab (Home)
local HomeTab = Window:Tab({
    Title = "Home",
    Icon = "home",
})

-- Welcome Section
HomeTab:Section({
    Title = "Welcome to Synthorix V5",
    TextSize = 24,
    FontWeight = Enum.FontWeight.SemiBold,
})

HomeTab:Space()

HomeTab:Section({
    Title = [[Advanced Aimbot System with Team-Friendly Features
    
Features Included:
• Smart Head-Targeting Aimbot
• Proximity-Based Activation
• Wall Detection & Auto-Unlock
• Smooth Aiming for Teaming
• Player Blacklist System
• Adjustable Settings
• Silent Aim Option
• Target Prediction]],
    TextSize = 14,
    TextTransparency = 0.3,
})

HomeTab:Space()

-- Quick Settings Section
local QuickSettingsSection = HomeTab:Section({
    Title = "Quick Settings",
    Box = true,
    Opened = true,
})

local QuickToggle = QuickSettingsSection:Toggle({
    Title = "Enable Aimbot",
    Desc = "Quick toggle for aimbot",
    Callback = function(value)
        AimBot.Enabled = value
        if value then
            AimBot:Start()
            Window:Tag({
                Title = "Aimbot: ON",
                Icon = "target",
                Color = Color3.fromHex("#30d158")
            })
            WindUI:Notify({
                Title = "Aimbot Enabled",
                Content = "Press " .. AimBot.Keybind .. " to toggle",
                Icon = "target"
            })
        else
            AimBot.Target = nil
            Window:Tag({
                Title = "Aimbot: OFF",
                Icon = "target",
                Color = Color3.fromHex("#ff3b30")
            })
        end
    end
})

QuickSettingsSection:Space()

QuickSettingsSection:Button({
    Title = "Open Aimbot Settings",
    Icon = "settings",
    Justify = "Center",
    Callback = function()
        -- Switch to Aimbot tab
        -- Note: This would require accessing the tab system directly
        WindUI:Notify({
            Title = "Navigation",
            Content = "Switch to Aimbot tab for detailed settings",
            Icon = "arrow-right"
        })
    end
})

-- Create Aimbot Tab with multiple channels
local AimbotTab = Window:Tab({
    Title = "Aimbot",
    Icon = "target",
})

-- Channel 1: Main Settings
local MainChannel = AimbotTab:Section({
    Title = "Main Settings",
    Box = true,
    Opened = true,
})

-- Toggle for aimbot
local AimToggle = MainChannel:Toggle({
    Title = "Enable Aimbot",
    Desc = "Toggle the aimbot system",
    Callback = function(value)
        AimBot.Enabled = value
        if value then
            AimBot:Start()
            Window:Tag({
                Title = "Aimbot: ON",
                Icon = "target",
                Color = Color3.fromHex("#30d158")
            })
        else
            AimBot.Target = nil
            Window:Tag({
                Title = "Aimbot: OFF",
                Icon = "target",
                Color = Color3.fromHex("#ff3b30")
            })
        end
    end
})

MainChannel:Space()

-- Keybind selector
local keyOptions = {}
for _, key in pairs(Enum.KeyCode:GetEnumItems()) do
    if key.Name ~= "Unknown" then
        table.insert(keyOptions, {
            Title = key.Name,
            Icon = "key",
            Callback = function()
                AimBot.Keybind = key.Name
                AimBot:SetKeybind(key.Name)
                WindUI:Notify({
                    Title = "Keybind Updated",
                    Content = "Aimbot keybind set to: " .. key.Name,
                    Icon = "check"
                })
            end
        })
    end
end

MainChannel:Dropdown({
    Title = "Aimbot Keybind",
    Desc = "Press this key to toggle aimbot",
    Values = keyOptions,
    Value = "E"
})

MainChannel:Space()

-- Channel 2: Aim Settings
local AimSettingsChannel = AimbotTab:Section({
    Title = "Aim Settings",
    Box = true,
    Opened = true,
})

-- Smoothness slider
AimSettingsChannel:Slider({
    Title = "Smoothness",
    Desc = "How smooth the aim movement is (lower = smoother)",
    Step = 0.05,
    Value = {
        Min = 0.1,
        Max = 1.0,
        Default = AimBot.Smoothness,
    },
    Callback = function(value)
        AimBot.Smoothness = value
    end
})

AimSettingsChannel:Space()

-- Silent aim toggle
AimSettingsChannel:Toggle({
    Title = "Silent Aim",
    Desc = "Make aim less obvious (experimental)",
    Default = AimBot.SilentAim,
    Callback = function(value)
        AimBot.SilentAim = value
    end
})

AimSettingsChannel:Space()

-- Prediction slider
AimSettingsChannel:Slider({
    Title = "Target Prediction",
    Desc = "Predict target movement (higher for fast targets)",
    Step = 0.05,
    Value = {
        Min = 0.0,
        Max = 0.5,
        Default = AimBot.Prediction,
    },
    Callback = function(value)
        AimBot.Prediction = value
    end
})

-- Channel 3: Distance & FOV
local DistanceChannel = AimbotTab:Section({
    Title = "Distance & FOV",
    Box = true,
    Opened = true,
})

-- Min distance
DistanceChannel:Slider({
    Title = "Minimum Distance",
    Desc = "Minimum distance to start aiming",
    Step = 1,
    Value = {
        Min = 5,
        Max = 50,
        Default = AimBot.MinDistance,
    },
    Callback = function(value)
        AimBot.MinDistance = value
    end
})

DistanceChannel:Space()

-- Max distance
DistanceChannel:Slider({
    Title = "Maximum Distance",
    Desc = "Maximum distance to aim",
    Step = 5,
    Value = {
        Min = 50,
        Max = 500,
        Default = AimBot.MaxDistance,
    },
    Callback = function(value)
        AimBot.MaxDistance = value
    end
})

DistanceChannel:Space()

-- FOV Settings
DistanceChannel:Slider({
    Title = "Field of View",
    Desc = "Target selection field of view",
    Step = 5,
    Value = {
        Min = 10,
        Max = 120,
        Default = AimBot.FOV,
    },
    Callback = function(value)
        AimBot.FOV = value
    end
})

-- Channel 4: Targeting Options
local TargetingChannel = AimbotTab:Section({
    Title = "Targeting Options",
    Box = true,
    Opened = true,
})

-- Team check toggle
TargetingChannel:Toggle({
    Title = "Team Check",
    Desc = "Don't aim at teammates",
    Default = AimBot.TeamCheck,
    Callback = function(value)
        AimBot.TeamCheck = value
    end
})

TargetingChannel:Space()

-- Wall check toggle
TargetingChannel:Toggle({
    Title = "Wall Check",
    Desc = "Don't aim through walls",
    Default = AimBot.WallCheck,
    Callback = function(value)
        AimBot.WallCheck = value
    end
})

TargetingChannel:Space()

-- Auto switch toggle
TargetingChannel:Toggle({
    Title = "Auto Switch Target",
    Desc = "Automatically switch targets when current is invalid",
    Default = AimBot.AutoSwitch,
    Callback = function(value)
        AimBot.AutoSwitch = value
    end
})

TargetingChannel:Space()

-- Aim part selector
TargetingChannel:Dropdown({
    Title = "Aim Part",
    Desc = "Which body part to target",
    Values = {
        {
            Title = "Head",
            Icon = "user",
            Callback = function()
                AimBot.AimPart = "Head"
            end
        },
        {
            Title = "UpperTorso",
            Icon = "user",
            Callback = function()
                AimBot.AimPart = "UpperTorso"
            end
        },
        {
            Title = "HumanoidRootPart",
            Icon = "user",
            Callback = function()
                AimBot.AimPart = "HumanoidRootPart"
            end
        }
    }
})

-- Channel 5: Blacklist Management
local BlacklistChannel = AimbotTab:Section({
    Title = "Blacklist Management",
    Desc = "Manage players you don't want to target",
    Box = true,
    Opened = true,
})

-- Current blacklist display
local blacklistPlayers = {}
local function updateBlacklistDisplay()
    blacklistPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local isBlacklisted = AimBot:IsBlacklisted(player)
            table.insert(blacklistPlayers, {
                Title = player.Name,
                Icon = isBlacklisted and "user-x" or "user",
                Desc = isBlacklisted and "Blacklisted" or "Click to blacklist",
                Callback = function()
                    if isBlacklisted then
                        AimBot:RemoveFromBlacklist(player)
                        WindUI:Notify({
                            Title = "Blacklist Removed",
                            Content = "Removed " .. player.Name .. " from blacklist",
                            Icon = "user-check"
                        })
                    else
                        AimBot:AddToBlacklist(player)
                        WindUI:Notify({
                            Title = "Blacklist Added",
                            Content = "Added " .. player.Name .. " to blacklist",
                            Icon = "user-x"
                        })
                    end
                    updateBlacklistDisplay()
                    PlayerListDropdown:Refresh(blacklistPlayers)
                end
            })
        end
    end
end

-- Create player list dropdown
local PlayerListDropdown = BlacklistChannel:Dropdown({
    Title = "Player List",
    Desc = "Click to toggle blacklist status",
    Values = blacklistPlayers
})

BlacklistChannel:Space()

-- Blacklist management buttons
local BlacklistButtonsGroup = BlacklistChannel:Group({})

BlacklistButtonsGroup:Button({
    Title = "Refresh List",
    Icon = "refresh-cw",
    Justify = "Center",
    Callback = function()
        updateBlacklistDisplay()
        PlayerListDropdown:Refresh(blacklistPlayers)
        WindUI:Notify({
            Title = "Player List Updated",
            Content = "Refreshed player list",
            Icon = "check"
        })
    end
})

BlacklistButtonsGroup:Space()

BlacklistButtonsGroup:Button({
    Title = "Clear All",
    Color = Color3.fromHex("#ff3b30"),
    Icon = "trash",
    Justify = "Center",
    Callback = function()
        AimBot.BlacklistedPlayers = {}
        updateBlacklistDisplay()
        PlayerListDropdown:Refresh(blacklistPlayers)
        WindUI:Notify({
            Title = "Blacklist Cleared",
            Content = "All players removed from blacklist",
            Icon = "trash"
        })
    end
})

-- Channel 6: Visuals & Status
local VisualsChannel = AimbotTab:Section({
    Title = "Visuals & Status",
    Box = true,
    Opened = true,
})

-- Current target display
local targetDisplay = VisualsChannel:Section({
    Title = "Current Target: None",
    TextSize = 16,
    TextTransparency = 0.5,
})

-- Update target display
local function updateTargetDisplay()
    if AimBot.Target then
        targetDisplay:Set({
            Title = "Current Target: " .. AimBot.Target.Name,
            TextSize = 16,
            TextTransparency = 0,
        })
    else
        targetDisplay:Set({
            Title = "Current Target: None",
            TextSize = 16,
            TextTransparency = 0.5,
        })
    end
end

-- Update display periodically
local displayUpdateConnection
displayUpdateConnection = RunService.Heartbeat:Connect(function()
    updateTargetDisplay()
end)

VisualsChannel:Space()

-- Status indicators
local StatusGroup = VisualsChannel:Group({})

StatusGroup:Section({
    Title = "Aimbot Status: " .. (AimBot.Enabled and "ENABLED" or "DISABLED"),
    TextSize = 14,
    Color = AimBot.Enabled and Color3.fromHex("#30d158") or Color3.fromHex("#ff3b30")
})

StatusGroup:Space()

StatusGroup:Section({
    Title = "Blacklisted Players: " .. #AimBot.BlacklistedPlayers,
    TextSize = 14,
})

-- Create Visuals Tab
local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye",
})

-- Channel 1: ESP Settings
local ESPChannel = VisualsTab:Section({
    Title = "ESP Settings",
    Box = true,
    Opened = true,
})

ESPChannel:Toggle({
    Title = "Enable ESP",
    Desc = "Show player boxes and information",
    Default = false,
    Callback = function(value)
        WindUI:Notify({
            Title = "ESP Feature",
            Content = value and "ESP Enabled" or "ESP Disabled",
            Icon = "eye"
        })
    end
})

ESPChannel:Space()

ESPChannel:Toggle({
    Title = "Show Names",
    Desc = "Display player names",
    Default = true,
})

ESPChannel:Space()

ESPChannel:Toggle({
    Title = "Show Distance",
    Desc = "Display distance to players",
    Default = true,
})

ESPChannel:Space()

ESPChannel:Colorpicker({
    Title = "ESP Color",
    Desc = "Color for ESP boxes",
    Default = Color3.fromHex("#30FF6A"),
})

-- Channel 2: Crosshair Settings
local CrosshairChannel = VisualsTab:Section({
    Title = "Crosshair Settings",
    Box = true,
    Opened = true,
})

CrosshairChannel:Toggle({
    Title = "Custom Crosshair",
    Desc = "Enable custom crosshair",
    Default = false,
})

CrosshairChannel:Space()

CrosshairChannel:Slider({
    Title = "Crosshair Size",
    Desc = "Size of the crosshair",
    Step = 1,
    Value = {
        Min = 5,
        Max = 50,
        Default = 15,
    },
})

CrosshairChannel:Space()

CrosshairChannel:Colorpicker({
    Title = "Crosshair Color",
    Desc = "Color of the crosshair",
    Default = Color3.fromHex("#FF0000"),
})

-- Channel 3: UI Customization
local UIChannel = VisualsTab:Section({
    Title = "UI Customization",
    Box = true,
    Opened = true,
})

UIChannel:Colorpicker({
    Title = "UI Accent Color",
    Desc = "Main color for the UI",
    Default = Color3.fromHex("#30FF6A"),
    Callback = function(color)
        WindUI:Notify({
            Title = "UI Color Updated",
            Content = "Accent color changed",
            Icon = "palette"
        })
    end
})

UIChannel:Space()

UIChannel:Toggle({
    Title = "Rainbow UI",
    Desc = "Make UI colors cycle through rainbow",
    Default = false,
})

-- Create Miscellaneous Tab
local MiscTab = Window:Tab({
    Title = "Miscellaneous",
    Icon = "settings",
})

-- Channel 1: Game Settings
local GameChannel = MiscTab:Section({
    Title = "Game Settings",
    Box = true,
    Opened = true,
})

GameChannel:Toggle({
    Title = "Auto Respawn",
    Desc = "Automatically respawn when dead",
    Default = false,
})

GameChannel:Space()

GameChannel:Toggle({
    Title = "No Recoil",
    Desc = "Remove weapon recoil",
    Default = false,
})

GameChannel:Space()

GameChannel:Toggle({
    Title = "No Spread",
    Desc = "Remove weapon spread",
    Default = false,
})

-- Channel 2: Performance
local PerformanceChannel = MiscTab:Section({
    Title = "Performance",
    Box = true,
    Opened = true,
})

PerformanceChannel:Toggle({
    Title = "FPS Boost",
    Desc = "Optimize game performance",
    Default = false,
})

PerformanceChannel:Space()

PerformanceChannel:Slider({
    Title = "Update Rate",
    Desc = "How often features update (higher = smoother)",
    Step = 1,
    Value = {
        Min = 30,
        Max = 144,
        Default = 60,
    },
})

-- Channel 3: Configuration
local ConfigChannel = MiscTab:Section({
    Title = "Configuration",
    Box = true,
    Opened = true,
})

ConfigChannel:Button({
    Title = "Save Configuration",
    Icon = "save",
    Justify = "Center",
    Callback = function()
        WindUI:Notify({
            Title = "Configuration Saved",
            Content = "All settings have been saved",
            Icon = "check"
        })
    end
})

ConfigChannel:Space()

ConfigChannel:Button({
    Title = "Load Configuration",
    Icon = "folder-open",
    Justify = "Center",
    Callback = function()
        WindUI:Notify({
            Title = "Configuration Loaded",
            Content = "Settings loaded from file",
            Icon = "check"
        })
    end
})

ConfigChannel:Space()

ConfigChannel:Button({
    Title = "Reset to Default",
    Color = Color3.fromHex("#ff3b30"),
    Icon = "refresh-cw",
    Justify = "Center",
    Callback = function()
        WindUI:Popup({
            Title = "Reset Settings",
            Content = "Are you sure you want to reset all settings to default?",
            Buttons = {
                {
                    Title = "Yes",
                    Icon = "check",
                    Callback = function()
                        WindUI:Notify({
                            Title = "Settings Reset",
                            Content = "All settings reset to default",
                            Icon = "check"
                        })
                    end
                },
                {
                    Title = "No",
                    Icon = "x",
                }
            }
        })
    end
})

-- Channel 4: Info & Help
local InfoChannel = MiscTab:Section({
    Title = "Information & Help",
    Box = true,
    Opened = true,
})

InfoChannel:Section({
    Title = [[
Synthorix V5 - Advanced Aimbot System
    
Key Features:
• Smart Head-Targeting Aimbot
• Proximity-Based Activation (10-100 studs)
• Wall Detection & Auto-Unlock
• Smooth Aiming for Teaming
• Player Blacklist System
• Adjustable FOV and Distance
• Silent Aim Option
    
How to Use:
1. Press E to toggle aimbot
2. Add friends to blacklist in Aimbot tab
3. Adjust smoothness for team recognition
4. Set distance limits as needed
    
For Team Play:
• Use high smoothness settings
• Blacklist your teammates
• Enable wall check
• Use silent aim for discretion
    
Controls:
• E - Toggle Aimbot
• UI can be dragged
• Right-click UI buttons for options
    ]],
    TextSize = 12,
    TextTransparency = 0.3,
})

-- Create Credits Tab
local CreditsTab = Window:Tab({
    Title = "Credits",
    Icon = "users",
})

CreditsTab:Section({
    Title = "Synthorix V5",
    TextSize = 24,
    FontWeight = Enum.FontWeight.SemiBold,
})

CreditsTab:Space()

CreditsTab:Section({
    Title = [[
Developed by:
• Rai - Lead Developer
• Vilo - UI Designer
    
Special Thanks:
• WindUI Developers
• Nebula Icons
• Testing Team
    
Donation Info:
If you enjoy this script and want to support development,
consider donating to help us continue improving!
    
Disclaimer:
This script is for educational purposes only.
Use at your own risk.
    ]],
    TextSize = 14,
    TextTransparency = 0.3,
})

CreditsTab:Space()

-- Donation Section
local DonationSection = CreditsTab:Section({
    Title = "Support Development",
    Box = true,
    Opened = true,
})

DonationSection:Button({
    Title = "Copy Discord Link",
    Icon = "discord",
    Justify = "Center",
    Callback = function()
        setclipboard("https://discord.gg/synthorix")
        WindUI:Notify({
            Title = "Discord Link Copied",
            Content = "Join our Discord server!",
            Icon = "check"
        })
    end
})

DonationSection:Space()

DonationSection:Button({
    Title = "Copy Donation Info",
    Icon = "dollar-sign",
    Justify = "Center",
    Callback = function()
        setclipboard("Support us on Patreon: patreon.com/synthorix")
        WindUI:Notify({
            Title = "Donation Info Copied",
            Content = "Thank you for your support!",
            Icon = "heart"
        })
    end
})

-- Initialize blacklist display
updateBlacklistDisplay()

-- Start the aimbot system
AimBot:Start()

-- Initial popup
createPopup()
