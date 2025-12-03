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
    
    -- Apply the rotation (this part needs to be handled differently based on the game)
    -- For most games, you would set the camera CFrame directly
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
                        self:SmoothAim(aimPart.Position)
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
        Title = "Open Synthorix V5", -- Updated title
        CornerRadius = UDim.new(1,0), -- fully rounded
        StrokeThickness = 3, -- removing outline
        Enabled = true, -- enable or disable openbutton
        Draggable = true,
        OnlyMobile = false,
        
        Color = ColorSequence.new( -- gradient
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

-- Create Aimbot Tab
local AimbotTab = Window:Tab({
    Title = "Aimbot",
    Icon = "target",
})

-- Main Aimbot Section
local MainSection = AimbotTab:Section({
    Title = "Aimbot Settings",
    Box = true,
    Opened = true,
})

-- Toggle for aimbot
local AimToggle = MainSection:Toggle({
    Title = "Enable Aimbot",
    Desc = "Toggle the aimbot system",
    Callback = function(value)
        AimBot.Enabled = value
        if value then
            AimBot:Start()
            -- Update tag
            Window:Tag({
                Title = "Aimbot: ON",
                Icon = "target",
                Color = Color3.fromHex("#30d158")
            })
        else
            AimBot.Target = nil
            -- Update tag
            Window:Tag({
                Title = "Aimbot: OFF",
                Icon = "target",
                Color = Color3.fromHex("#ff3b30")
            })
        end
    end
})

MainSection:Space()

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

MainSection:Dropdown({
    Title = "Aimbot Keybind",
    Desc = "Press this key to toggle aimbot",
    Values = keyOptions,
    Value = "E"
})

MainSection:Space()

-- Smoothness slider
MainSection:Slider({
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

MainSection:Space()

-- Distance Settings Section
local DistanceSection = AimbotTab:Section({
    Title = "Distance Settings",
    Box = true,
    Opened = true,
})

-- Min distance
DistanceSection:Slider({
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

DistanceSection:Space()

-- Max distance
DistanceSection:Slider({
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

DistanceSection:Space()

-- FOV Settings
DistanceSection:Slider({
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

-- Targeting Section
local TargetSection = AimbotTab:Section({
    Title = "Targeting Settings",
    Box = true,
    Opened = true,
})

-- Team check toggle
TargetSection:Toggle({
    Title = "Team Check",
    Desc = "Don't aim at teammates",
    Default = AimBot.TeamCheck,
    Callback = function(value)
        AimBot.TeamCheck = value
    end
})

TargetSection:Space()

-- Wall check toggle
TargetSection:Toggle({
    Title = "Wall Check",
    Desc = "Don't aim through walls",
    Default = AimBot.WallCheck,
    Callback = function(value)
        AimBot.WallCheck = value
    end
})

TargetSection:Space()

-- Auto switch toggle
TargetSection:Toggle({
    Title = "Auto Switch Target",
    Desc = "Automatically switch targets when current is invalid",
    Default = AimBot.AutoSwitch,
    Callback = function(value)
        AimBot.AutoSwitch = value
    end
})

TargetSection:Space()

-- Aim part selector
TargetSection:Dropdown({
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

-- Blacklist Management Section
local BlacklistSection = AimbotTab:Section({
    Title = "Blacklist Management",
    Desc = "Add friends to blacklist so you don't aim at them",
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
                    -- Refresh the dropdown
                    updateBlacklistDisplay()
                    PlayerListDropdown:Refresh(blacklistPlayers)
                end
            })
        end
    end
end

-- Create player list dropdown
local PlayerListDropdown = BlacklistSection:Dropdown({
    Title = "Player List",
    Desc = "Click to toggle blacklist status",
    Values = blacklistPlayers
})

-- Refresh button
BlacklistSection:Button({
    Title = "Refresh Player List",
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

BlacklistSection:Space()

-- Clear all blacklist button
BlacklistSection:Button({
    Title = "Clear All Blacklists",
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

-- Initialize blacklist display
updateBlacklistDisplay()

-- Status Section
local StatusSection = AimbotTab:Section({
    Title = "Aimbot Status",
    Box = true,
    Opened = true,
})

-- Current target display
local targetDisplay = StatusSection:Section({
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

-- Info Section
local InfoSection = AimbotTab:Section({
    Title = "How to Use",
    Box = true,
    Opened = true,
})

InfoSection:Section({
    Title = [[
1. Press the keybind (default: E) to toggle aimbot
2. Blacklist friends using the Player List
3. Adjust smoothness for easier team recognition
4. Set distance limits to avoid close/far targets
5. Enable wall check to avoid aiming through walls
    
Features:
• Head-targeting aimbot
• Proximity-based activation
• Auto-unlock when behind walls
• Smooth movement for teaming
• Blacklist system for friends
• Adjustable FOV and distance
    ]],
    TextSize = 14,
    TextTransparency = 0.3,
})

-- Start the aimbot system
AimBot:Start()

-- */ Using Nebula Icons /* --
do
    local NebulaIcons = loadstring(game:HttpGetAsync("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
    
    -- Adding icons (e.g. Fluency)
    WindUI.Creator.AddIcons("nebula",    NebulaIcons.Fluency)
    --               ^ Icon name          ^ Table of Icons
    
    -- You can also add nebula icons
    WindUI.Creator.AddIcons("nebula",    NebulaIcons.nebulaIcons)
    
    -- Usage ↑ ↓
    
    local TestSection = Window:Section({
        Title = "this is my hard work so i hope you guys could give me some donation if you don't is alright ;)",
        Icon = "nebula:nebula",
    })
end

-- Initial popup
createPopup()
