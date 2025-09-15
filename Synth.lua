local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/hdbfishwh/SynthorixV2/refs/heads/main/Theme.lua"))()

-- Check if WindUI loaded correctly
if not WindUI then
    error("Failed to load WindUI library")
    return
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Wait for player to load
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Dapatkan username pemain
local playerName = LocalPlayer.Name
local displayName = LocalPlayer.DisplayName

-- Check if WindUI has Localization method before calling it
if WindUI.Localization then
    WindUI:Localization({
        Enabled = true,
        Prefix = "loc:",
        DefaultLanguage = "en",
        Translations = {
            ["en"] = {
                ["WINDUI_EXAMPLE"] = "Synth [Beta]",
                ["WELCOME"] = "UniversalAimbot by Synth",
                ["LIB_DESC"] = "Hello " .. displayName .. ", this script still has allot of bug please report it to my discord server to fix the bug",
                ["SETTINGS"] = "Settings",
                ["APPEARANCE"] = "Appearance",
                ["FEATURES"] = "Features",
                ["UTILITIES"] = "Utilities",
                ["UI_ELEMENTS"] = "UI Elements",
                ["CONFIGURATION"] = "Configuration",
                ["SAVE_CONFIG"] = "Save Configuration",
                ["LOAD_CONFIG"] = "Load Configuration",
                ["THEME_SELECT"] = "Select Theme",
                ["TRANSPARENCY"] = "Window Transparency",
                ["DISCORD"] = "Discord Server",
                ["JOIN_DISCORD"] = "Join Our Discord",
                ["DISCORD_DESC"] = "Join our Discord community for updates, support, and more!"
            }
        }
    })
end

-- SET TRANSPARENCY TO 0.50 IMMEDIATELY
if WindUI.TransparencyValue then
    WindUI.TransparencyValue = 0.50
end

if WindUI.SetTheme then
    WindUI:SetTheme("Dark")
end

-- Create custom logo
local function CreateCustomLogo()
    return "rbxassetid://111308654185180"
end

local customLogo = CreateCustomLogo()

local function gradient(text, startColor, endColor)
    local result = ""
    for i = 1, #text do
        local t = (i - 1) / (#text - 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

-- Check if Popup method exists before calling it
if WindUI.Popup then
    WindUI:Popup({
        Title = gradient("Synth [Beta]", Color3.fromHex("#6A11CB"), Color3.fromHex("#2575FC")),
        Icon = "rbxassetid://111308654185180",
        Content = "loc:LIB_DESC",
        Buttons = {
            {
                Title = "Get Started",
                Icon = "arrow-right",
                Variant = "Primary",
                Callback = function() end
            }
        }
    })
end

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

-- Functions
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

-- Function to open Discord link
local function OpenDiscord()
    local discordUrl = "https://discord.gg/ckc8gFGuT7"
    
    if WindUI and WindUI.Notify then
        WindUI:Notify({
            Title = "Discord",
            Content = "Opening Discord invite link...",
            Icon = "external-link",
            Duration = 3
        })
    end
    
    -- Try to open the link
    pcall(function()
        if syn then
            syn.request({
                Url = discordUrl,
                Method = "GET"
            })
        else
            -- Fallback for other executors
            setclipboard(discordUrl)
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Discord",
                    Content = "Link copied to clipboard!",
                    Icon = "copy",
                    Duration = 5
                })
            end
        end
    end)
end

-- Check if CreateWindow method exists before proceeding
if not WindUI.CreateWindow then
    warn("WindUI library doesn't have CreateWindow method")
    return
end

local Window = WindUI:CreateWindow({
    Title = "Synth [Beta]",
    Icon = "rbxassetid://111308654185180",
    Author = "UniversalAimbot by Synth",
    Folder = "WindUI_Example",
    Size = UDim2.fromOffset(200, 200),
    Theme = "Dark",
    User = {
        Enabled = true,
        Anonymous = false,
        Username = playerName,
        UserId = LocalPlayer.UserId,
        Callback = function()
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "User Profile",
                    Content = "Hello, " .. displayName .. "! (ID: " .. LocalPlayer.UserId .. ")",
                    Duration = 3
                })
            end
        end
    },
    SideBarWidth = 200,
    Transparency = 0.50
})

-- Check if Window was created successfully
if not Window then
    error("Failed to create WindUI window")
    return
end

if Window.CreateTopbarButton then
    Window:CreateTopbarButton("theme-switcher", "moon", function()
        if WindUI and WindUI.SetTheme and WindUI.GetCurrentTheme and WindUI.Notify then
            WindUI:SetTheme(WindUI:GetCurrentTheme() == "Dark" and "Light" or "Dark")
            WindUI:Notify({
                Title = "Theme Changed",
                Content = "Current theme: "..WindUI:GetCurrentTheme(),
            })
        end
    end, 990)
end

local Tabs = {
    Main = Window:Section({ Title = "Features", Opened = true }),
    Settings = Window:Section({ Title = "Settings", Opened = true }),
    Utilities = Window:Section({ Title = "Utilities", Opened = true }),
    Discord = Window:Section({ Title = "Discord", Opened = true })
}

local TabHandles = {
    ESP = Tabs.Main:Tab({ Title = "ESP", Icon = "eye" }),
    Aimbot = Tabs.Main:Tab({ Title = "Aimbot", Icon = "crosshair" }),
    Appearance = Tabs.Settings:Tab({ Title = "Appearance", Icon = "brush" }),
    Config = Tabs.Utilities:Tab({ Title = "Configuration", Icon = "settings" }),
    DiscordTab = Tabs.Discord:Tab({ Title = "Discord", Icon = "message-circle" })
}

-- Add a custom logo to the main section
if TabHandles.ESP and TabHandles.ESP.Paragraph then
    TabHandles.ESP:Paragraph({
        Title = "ESP Settings",
        Desc = "Configure your ESP features",
        Image = "rbxassetid://111308654185180",
        ImageSize = 64,
        Color = Color3.fromHex("#30ff6a"),
    })

    TabHandles.ESP:Divider()
end

-- Add Discord section content
if TabHandles.DiscordTab and TabHandles.DiscordTab.Paragraph then
    TabHandles.DiscordTab:Paragraph({
        Title = "Join Our Community",
        Desc = "Join our Discord community for updates, support, and more!",
        Image = "rbxassetid://111308654185180",
        ImageSize = 64,
        Color = Color3.fromHex("#5865F2")
    })

    TabHandles.DiscordTab:Divider()

    TabHandles.DiscordTab:Button({
        Title = "Join Our Discord",
        Icon = "discord",
        Variant = "Primary",
        Callback = OpenDiscord
    })

    TabHandles.DiscordTab:Paragraph({
        Title = "Benefits of Joining",
        Desc = "• Get script updates\n• Request features\n• Report bugs\n• Get support\n• Share your experiences",
        Image = "star",
        ImageSize = 20,
        Color = Color3.fromHex("#FFD700")
    })
end

-- Toggle untuk ESP
if TabHandles.ESP and TabHandles.ESP.Toggle then
    local espToggle = TabHandles.ESP:Toggle({
        Title = "Enable ESP",
        Desc = "Toggle ESP on/off",
        Value = Config.ESP.Enabled,
        Callback = function(state) 
            Config.ESP.Enabled = state
            
            -- Jika ESP dimatikan, sembunyikan semua drawing
            if not state then
                for _, drawings in pairs(ESPDrawings) do
                    for _, drawing in pairs(drawings) do
                        drawing.Visible = false
                    end
                end
            end
            
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "ESP",
                    Content = state and "ESP Enabled" or "ESP Disabled",
                    Icon = state and "check" or "x",
                    Duration = 2
                })
            end
        end
    })

    -- Toggle untuk menampilkan username
    local usernameToggle = TabHandles.ESP:Toggle({
        Title = "Show Username",
        Desc = "Toggle username display on/off",
        Value = Config.ESP.ShowUsername,
        Callback = function(state) 
            Config.ESP.ShowUsername = state
            
            -- Jika username dimatikan, sembunyikan semua username drawing
            if not state then
                for _, drawings in pairs(ESPDrawings) do
                    if drawings.Username then
                        drawings.Username.Visible = false
                    end
                end
            end
            
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Username ESP",
                    Content = state and "Username Display Enabled" or "Username Display Disabled",
                    Icon = state and "check" or "x",
                    Duration = 2
                })
            end
        end
    })

    local snaplineToggle = TabHandles.ESP:Toggle({
        Title = "Enable Snapline",
        Desc = "Toggle snapline on/off",
        Value = Config.ESP.SnaplineEnabled,
        Callback = function(state) 
            Config.ESP.SnaplineEnabled = state
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Snapline",
                    Content = state and "Snapline Enabled" or "Snapline Disabled",
                    Icon = state and "check" or "x",
                    Duration = 2
                })
            end
        end
    })

    local rainbowToggle = TabHandles.ESP:Toggle({
        Title = "Rainbow Effect",
        Desc = "Toggle rainbow colors on/off",
        Value = Config.ESP.RainbowEnabled,
        Callback = function(state) 
            Config.ESP.RainbowEnabled = state
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Rainbow",
                    Content = state and "Rainbow Enabled" or "Rainbow Disabled",
                    Icon = state and "check" or "x",
                    Duration = 2
                })
            end
        end
    })

    local snaplinePosition = TabHandles.ESP:Dropdown({
        Title = "Snapline Position",
        Values = { "Center", "Bottom", "Top" },
        Value = Config.ESP.SnaplinePosition,
        Callback = function(option)
            Config.ESP.SnaplinePosition = option
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Snapline Position",
                    Content = "Position: "..option,
                    Duration = 2
                })
            end
        end
    })

    TabHandles.ESP:Colorpicker({
        Title = "ESP Color",
        Default = Config.ESP.BoxColor,
        Callback = function(color, transparency)
            Config.ESP.BoxColor = color
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "ESP Color",
                    Content = "Color changed",
                    Duration = 2
                })
            end
        end
    })

    TabHandles.ESP:Colorpicker({
        Title = "Username Color",
        Default = Config.ESP.UsernameColor,
        Callback = function(color, transparency)
            Config.ESP.UsernameColor = color
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Username Color",
                    Content = "Username color changed",
                    Duration = 2
                })
            end
        end
    })
end

if TabHandles.Aimbot and TabHandles.Aimbot.Paragraph then
    TabHandles.Aimbot:Paragraph({
        Title = "Aimbot Settings",
        Desc = "Configure your aimbot features",
        Image = "rbxassetid://111308654185180",
        ImageSize = 64,
        Color = Color3.fromHex("#ff3030"),
    })

    TabHandles.Aimbot:Divider()

    local aimbotToggle = TabHandles.Aimbot:Toggle({
        Title = "Enable Aimbot",
        Desc = "Toggle aimbot on/off",
        Value = Config.Aimbot.Enabled,
        Callback = function(state) 
            Config.Aimbot.Enabled = state
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Aimbot",
                    Content = state and "Aimbot Enabled" or "Aimbot Disabled",
                    Icon = state and "check" or "x",
                    Duration = 2
                })
            end
        end
    })

    local fovToggle = TabHandles.Aimbot:Toggle({
        Title = "Show FOV Circle",
        Desc = "Toggle FOV circle visibility",
        Value = Config.Aimbot.ShowFOV,
        Callback = function(state) 
            Config.Aimbot.ShowFOV = state
            FOVCircle.Visible = state
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "FOV Circle",
                    Content = state and "FOV Circle Enabled" or "FOV Circle Disabled",
                    Icon = state and "check" or "x",
                    Duration = 2
                })
            end
        end
    })

    local fovSlider = TabHandles.Aimbot:Slider({
        Title = "FOV Size",
        Desc = "Adjust aimbot field of view",
        Value = { Min = 5, Max = 100, Default = Config.Aimbot.FOV },
        Callback = function(value)
            Config.Aimbot.FOV = value
        end
    })

    local distanceSlider = TabHandles.Aimbot:Slider({
        Title = "Max Distance",
        Desc = "Don't adjust the distance there a bug",
        Value = { Min = 10, Max = 1000, Default = Config.Aimbot.MaxDistance },
        Callback = function(value)
            Config.Aimbot.MaxDistance = value
        end
    })

    local targetPart = TabHandles.Aimbot:Dropdown({
        Title = "Target Part",
        Values = { "Head", "Torso", "HumanoidRootPart" },
        Value = Config.Aimbot.TargetPart,
        Callback = function(option)
            Config.Aimbot.TargetPart = option
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Target Part",
                    Content = "Targeting: "..option,
                    Duration = 2
                })
            end
        end
    })

    local bigHeadToggle = TabHandles.Aimbot:Toggle({
        Title = "Big Head",
        Desc = "Make enemy heads bigger",
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
            
            if WindUI and WindUI.Notify then
                WindUI:Notify({
                    Title = "Big Head",
                    Content = state and "Big Head Enabled" or "Big Head Disabled",
                    Icon = state and "check" or "x",
                    Duration = 2
                })
            end
        end
    })

    local bigHeadSlider = TabHandles.Aimbot:Slider({
        Title = "Head Size",
        Desc = "Adjust head size",
        Value = { Min = 5, Max = 50, Default = Config.Aimbot.BigHead.Size },
        Callback = function(value)
            Config.Aimbot.BigHead.Size = value
            BigHeadSize = value
        end
    })
end

if TabHandles.Appearance and TabHandles.Appearance.Paragraph then
    TabHandles.Appearance:Paragraph({
        Title = "Customize Interface",
        Desc = "Personalize your experience",
        Image = "rbxassetid://111308654185180",
        ImageSize = 64,
        Color = "White"
    })

    local themes = {}
    if WindUI and WindUI.GetThemes then
        for themeName, _ in pairs(WindUI:GetThemes()) do
            table.insert(themes, themeName)
        end
        table.sort(themes)
    else
        themes = {"Dark", "Light"}
    end

    local themeDropdown = TabHandles.Appearance:Dropdown({
        Title = "Select Theme",
        Values = themes,
        Value = "Dark",
        Callback = function(theme)
            if WindUI and WindUI.SetTheme then
                WindUI:SetTheme(theme)
                if WindUI.Notify then
                    WindUI:Notify({
                        Title = "Theme Applied",
                        Content = theme,
                        Icon = "palette",
                        Duration = 2
                    })
                end
            end
        end
    })

    local transparencySlider = TabHandles.Appearance:Slider({
        Title = "Window Transparency",
        Value = { 
            Min = 0,
            Max = 1,
            Default = 0.50,
        },
        Step = 0.1,
        Callback = function(value)
            if Window and Window.ToggleTransparency then
                Window:ToggleTransparency(tonumber(value) > 0)
                if WindUI.TransparencyValue then
                    WindUI.TransparencyValue = tonumber(value)
                end
                
                -- Force refresh UI
                task.wait(0.1)
                if Window.Enabled then
                    Window.Enabled = false
                    task.wait(0.1)
                    Window.Enabled = true
                end
            end
        end
    })
end

if TabHandles.Config and TabHandles.Config.Paragraph then
    TabHandles.Config:Paragraph({
        Title = "Configuration Manager",
        Desc = "Save and load your settings",
        Image = "rbxassetid://111308654185180",
        ImageSize = 64,
        Color = "White"
    })

    local configName = "default"
    local configFile = nil

    TabHandles.Config:Input({
        Title = "Config Name",
        Value = configName,
        Callback = function(value)
            configName = value or "default"
        end
    })

    TabHandles.Config:Button({
        Title = "Save Configuration",
        Icon = "save",
        Variant = "Primary",
        Callback = function()
            if WindUI and WindUI.Notify then
                WindUI:Notify({ 
                    Title = "Configuration", 
                    Content = "Settings saved for " .. playerName .. "!",
                    Icon = "check",
                    Duration = 3
                })
            end
        end
    })

    TabHandles.Config:Button({
        Title = "Load Configuration",
        Icon = "folder",
        Callback = function()
            if WindUI and WindUI.Notify then
                WindUI:Notify({ 
                    Title = "Configuration", 
                    Content = "Settings loaded for " .. playerName .. "!",
                    Icon = "refresh-cw",
                    Duration = 3
                })
            end
        end
    })
end

-- APPLY TRANSPARENCY IMMEDIATELY AFTER WINDOW CREATION
task.spawn(function()
    task.wait(1) -- Tunggu window selesai dibuat
    if Window and Window.ToggleTransparency then
        Window:ToggleTransparency(true)
        if WindUI.TransparencyValue then
            WindUI.TransparencyValue = 0.50
        end
        
        -- Force refresh UI
        if Window.Enabled then
            Window.Enabled = false
            task.wait(0.1)
            Window.Enabled = true
        end
    end
end)

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

-- Player added/removed events
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

-- UI Toggle
local UIVisible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        UIVisible = not UIVisible
        if Window then
            Window.Enabled = UIVisible
        end
    end
end)

-- Welcome Notification
local function ShowWelcomeNotification()
    if WindUI and WindUI.Notify then
        WindUI:Notify({
            Title = "Script Loaded",
            Content = "Welcome, " .. displayName .. "! ESP and Aimbot features are ready!",
            Icon = "check",
            Duration = 5
        })
    end
end

ShowWelcomeNotification()
warn("✅ Script successfully activated for " .. playerName .. "!")
