--[[
     _      ___         ____  ______
    | | /| / (_)__  ___/ / / / /  _/
    | |/ |/ / / _ \/ _  / /_/ // /  
    |__/|__/_/_//_/\_,_/\____/___/
    
    by .ftgs#0 (Discord)
    
    This script is NOT intended to be modified.
    To view the source code, see the 'Src' folder on the official GitHub repository.
    
    Author: .ftgs#0 (Discord User)
    Github: https://github.com/Footagesus/WindUI
    Discord: https://discord.gg/84CNGY5wAV
]]

local a a={cache={}, load=function(b)if not a.cache[b]then a.cache[b]={c=a[b]()}end return a.cache[b].c end}do function a.a()
local b=game:GetService"RunService"local d=b.Heartbeat
local e=game:GetService"UserInputService"
local f=game:GetService"TweenService"
local g=game:GetService"LocalizationService"

local h=loadstring(game:HttpGetAsync"https://raw.githubusercontent.com/Footagesus/Icons/main/Main.lua")()
h.SetIconsType"lucide"

local i

local j={
Font="rbxassetid://12187365364",
Localization=nil,
CanDraggable=true,
Theme=nil,
Themes=nil,
Signals={},
Objects={},
LocalizationObjects={},
FontObjects={},
Language=string.match(g.SystemLocaleId,"^[a-z]+"),
Request=http_request or(syn and syn.request)or request,
DefaultProperties={
ScreenGui={
ResetOnSpawn=false,
ZIndexBehavior="Sibling",
},
CanvasGroup={
BorderSizePixel=0,
BackgroundColor3=Color3.new(1,1,1),
},
Frame={
BorderSizePixel=0,
BackgroundColor3=Color3.new(1,1,1),
},
TextLabel={
BackgroundColor3=Color3.new(1,1,1),
BorderSizePixel=0,
Text="",
RichText=true,
TextColor3=Color3.new(1,1,1),
TextSize=14,
},TextButton={
BackgroundColor3=Color3.new(1,1,1),
BorderSizePixel=0,
Text="",
AutoButtonColor=false,
TextColor3=Color3.new(1,1,1),
TextSize=14,
},
TextBox={
BackgroundColor3=Color3.new(1,1,1),
BorderColor3=Color3.new(0,0,0),
ClearTextOnFocus=false,
Text="",
TextColor3=Color3.new(0,0,0),
TextSize=14,
},
ImageLabel={
BackgroundTransparency=1,
BackgroundColor3=Color3.new(1,1,1),
BorderSizePixel=0,
},
ImageButton={
BackgroundColor3=Color3.new(1,1,1),
BorderSizePixel=0,
AutoButtonColor=false,
},
UIListLayout={
SortOrder="LayoutOrder",
},
ScrollingFrame={
ScrollBarImageTransparency=1,
BorderSizePixel=0,
},
VideoFrame={
BorderSizePixel=0,
}
},
Colors={
Red="#e53935",
Orange="#f57c00",
Green="#43a047",
Blue="#039be5",
White="#ffffff",
Grey="#484848",
},
}

function j.Init(l)
i=l
end

function j.AddSignal(l,m)
table.insert(j.Signals,l:Connect(m))
end

function j.DisconnectAll()
for l,m in next,j.Signals do
local p=table.remove(j.Signals,l)
p:Disconnect()
end
end

function j.SafeCallback(l,...)
if not l then
return
end

local m,p=pcall(l,...)
if not m then local
r, u=p:find":%d+: "

warn("[ WindUI: DEBUG Mode ] "..p)

return i:Notify{
Title="DEBUG Mode: Error",
Content=not u and p or p:sub(u+1),
Duration=8,
}
end
end

function j.SetTheme(l)
j.Theme=l
j.UpdateTheme(nil,true)
end

function j.AddFontObject(l)
table.insert(j.FontObjects,l)
j.UpdateFont(j.Font)
end

function j.UpdateFont(l)
j.Font=l
for m,p in next,j.FontObjects do
p.FontFace=Font.new(l,p.FontFace.Weight,p.FontFace.Style)
end
end

function j.GetThemeProperty(l,m)
return m[l]or j.Themes.Dark[l]
end

function j.AddThemeObject(l,m)
j.Objects[l]={Object=l,Properties=m}
j.UpdateTheme(l,false)
return l
end
function j.AddLangObject(l)
local m=j.LocalizationObjects[l]
local p=m.Object
local r=currentObjTranslationId
j.UpdateLang(p,r)
return p
end

function j.UpdateTheme(l,m)
local function ApplyTheme(p)
for r,u in pairs(p.Properties or{})do
local v=j.GetThemeProperty(u,j.Theme)
if v then
if not m then
p.Object[r]=Color3.fromHex(v)
else
j.Tween(p.Object,0.08,{[r]=Color3.fromHex(v)}):Play()
end
end
end
end

if l then
local p=j.Objects[l]
if p then
ApplyTheme(p)
end
else
for p,r in pairs(j.Objects)do
ApplyTheme(r)
end
end
end

function j.SetLangForObject(l)
if j.Localization and j.Localization.Enabled then
local m=j.LocalizationObjects[l]
if not m then return end

local p=m.Object
local r=m.TranslationId

local u=j.Localization.Translations[j.Language]
if u and u[r]then
p.Text=u[r]
else
local v=j.Localization and j.Localization.Translations and j.Localization.Translations.en or nil
if v and v[r]then
p.Text=v[r]
else
p.Text="["..r.."]"
end
end
end
end

function j.ChangeTranslationKey(l,m,p)
if j.Localization and j.Localization.Enabled then
local r=string.match(p,"^"..j.Localization.Prefix.."(.+)")
if r then
for u,v in ipairs(j.LocalizationObjects)do
if v.Object==m then
v.TranslationId=r
j.SetLangForObject(u)
return
end
end

table.insert(j.LocalizationObjects,{
TranslationId=r,
Object=m
})
j.SetLangForObject(#j.LocalizationObjects)
end
end
end

function j.UpdateLang(l)
if l then
j.Language=l
end

for m=1,#j.LocalizationObjects do
local p=j.LocalizationObjects[m]
if p.Object and p.Object.Parent~=nil then
j.SetLangForObject(m)
else
j.LocalizationObjects[m]=nil
end
end
end

function j.SetLanguage(l)
j.Language=l
j.UpdateLang()
end

function j.Icon(l)
return h.Icon(l)
end

function j.New(l,m,p)
local r=Instance.new(l)

for u,v in next,j.DefaultProperties[l]or{}do
r[u]=v
end

for x,z in next,m or{}do
if x~="ThemeTag"then
r[x]=z
end
if j.Localization and j.Localization.Enabled and x=="Text"then
local A=string.match(z,"^"..j.Localization.Prefix.."(.+)")
if A then
local B=#j.LocalizationObjects+1
j.LocalizationObjects[B]={TranslationId=A,Object=r}

j.SetLangForObject(B)
end
end
end

for A,B in next,p or{}do
B.Parent=r
end

if m and m.ThemeTag then
j.AddThemeObject(r,m.ThemeTag)
end
if m and m.FontFace then
j.AddFontObject(r)
end
return r
end

function j.Tween(l,m,p,...)
return f:Create(l,TweenInfo.new(m,...),p)
end

function j.NewRoundFrame(l,m,p,r,x)
local z=j.New(x and"ImageButton"or"ImageLabel",{
Image=m=="Squircle"and"rbxassetid://80999662900595"
or m=="SquircleOutline"and"rbxassetid://117788349049947"
or m=="SquircleOutline2"and"rbxassetid://117817408534198"
or m=="Shadow-sm"and"rbxassetid://84825982946844"
or m=="Squircle-TL-TR"and"rbxassetid://73569156276236",
ScaleType="Slice",
SliceCenter=m~="Shadow-sm"and Rect.new(256,256,256,256)or Rect.new(512,512,512,512),
SliceScale=1,
BackgroundTransparency=1,
ThemeTag=p.ThemeTag and p.ThemeTag
},r)

for A,B in pairs(p or{})do
if A~="ThemeTag"then
z[A]=B
end
end

local function UpdateSliceScale(C)
local F=m~="Shadow-sm"and(C/(256))or(C/512)
z.SliceScale=F
end

UpdateSliceScale(l)

return z
end

local l=j.New local m=j.Tween

function j.SetDraggable(p)
j.CanDraggable=p
end

function j.Drag(p,r,x)
local z
local A,B,C,F
local G={
CanDraggable=true
}

if not r or type(r)~="table"then
r={p}
end

local function update(H)
local J=H.Position-C
j.Tween(p,0.02,{Position=UDim2.new(
F.X.Scale,F.X.Offset+J.X,
F.Y.Scale,F.Y.Offset+J.Y
)}):Play()
end

for H,J in pairs(r)do
J.InputBegan:Connect(function(L)
if(L.UserInputType==Enum.UserInputType.MouseButton1 or L.UserInputType==Enum.UserInputType.Touch)and G.CanDraggable then
if z==nil then
z=J
A=true
C=L.Position
F=p.Position

if x and type(x)=="function"then
x(true,z)
end

L.Changed:Connect(function()
if L.UserInputState==Enum.UserInputState.End then
A=false
z=nil

if x and type(x)=="function"then
x(false,z)
end
end
end)
end
end
end)

J.InputChanged:Connect(function(L)
if z==J and A then
if L.UserInputType==Enum.UserInputType.MouseMovement or L.UserInputType==Enum.UserInputType.Touch then
B=L
end
end
end)
end

e.InputChanged:Connect(function(L)
if L==B and A and z~=nil then
if G.CanDraggable then
update(L)
end
end
end)

function G.Set(L,M)
G.CanDraggable=M
end

return G
end

function j.Image(p,r,x,z,A,B,C)
local function SanitizeFilename(F)
F=F:gsub("[%s/\\:*?\"<>|]+","-")
F=F:gsub("[^%w%-_%.]","")
return F
end

z=z or"Temp"
r=SanitizeFilename(r)

local F=l("Frame",{
Size=UDim2.new(0,0,0,0),
BackgroundTransparency=1,
},{
l("ImageLabel",{
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
ScaleType="Crop",
ThemeTag=(j.Icon(p)or C)and{
ImageColor3=B and"Icon"or nil
}or nil,
},{
l("UICorner",{
CornerRadius=UDim.new(0,x)
})
})
})
if j.Icon(p)then
F.ImageLabel.Image=j.Icon(p)[1]
F.ImageLabel.ImageRectOffset=j.Icon(p)[2].ImageRectPosition
F.ImageLabel.ImageRectSize=j.Icon(p)[2].ImageRectSize
end
if string.find(p,"http")then
local G="WindUI/"..z.."/Assets/."..A.."-"..r..".png"
local H,J=pcall(function()
task.spawn(function()
if not isfile(G)then
local H=j.Request{
Url=p,
Method="GET",
}.Body

writefile(G,H)
end
F.ImageLabel.Image=getcustomasset(G)
end)
end)
if not H then
warn("[ WindUI.Creator ]  '"..identifyexecutor().."' doesnt support the URL Images. Error: "..J)

F:Destroy()
end
elseif string.find(p,"rbxassetid")then
F.ImageLabel.Image=p
end

return F
end

return j end function a.b()
local b={}

function b.New(e,f,g)
local h={
Enabled=f.Enabled or false,
Translations=f.Translations or{},
Prefix=f.Prefix or"loc:",
DefaultLanguage=f.DefaultLanguage or"en"
}

g.Localization=h

return h
end

return b end function a.c()
local b=a.load'a'
local e=b.New
local f=b.Tween

local g={
Size=UDim2.new(0,300,1,-156),
SizeLower=UDim2.new(0,300,1,-56),
UICorner=13,
UIPadding=14,

Holder=nil,
NotificationIndex=0,
Notifications={}
}

function g.Init(h)
local i={
Lower=false
}

function i.SetLower(j)
i.Lower=j
i.Frame.Size=j and g.SizeLower or g.Size
end

i.Frame=e("Frame",{
Position=UDim2.new(1,-29,0,56),
AnchorPoint=Vector2.new(1,0),
Size=g.Size,
Parent=h,
BackgroundTransparency=1,
},{
e("UIListLayout",{
HorizontalAlignment="Center",
SortOrder="LayoutOrder",
VerticalAlignment="Bottom",
Padding=UDim.new(0,8),
}),
e("UIPadding",{
PaddingBottom=UDim.new(0,29)
})
})
return i
end

function g.New(h)
local i={
Title=h.Title or"Notification",
Content=h.Content or nil,
Icon=h.Icon or nil,
IconThemed=h.IconThemed,
Background=h.Background,
BackgroundImageTransparency=h.BackgroundImageTransparency,
Duration=h.Duration or 5,
Buttons=h.Buttons or{},
CanClose=true,
UIElements={},
Closed=false,
}
if i.CanClose==nil then
i.CanClose=true
end
g.NotificationIndex=g.NotificationIndex+1
g.Notifications[g.NotificationIndex]=i

local j

if i.Icon then
j=b.Image(
i.Icon,
i.Title..":"..i.Icon,
0,
h.Window,
"Notification",
i.IconThemed
)
j.Size=UDim2.new(0,26,0,26)
j.Position=UDim2.new(0,g.UIPadding,0,g.UIPadding)
end

local l
if i.CanClose then
l=e("ImageButton",{
Image=b.Icon"x"[1],
ImageRectSize=b.Icon"x"[2].ImageRectSize,
ImageRectOffset=b.Icon"x"[2].ImageRectPosition,
BackgroundTransparency=1,
Size=UDim2.new(0,16,0,16),
Position=UDim2.new(1,-g.UIPadding,0,g.UIPadding),
AnchorPoint=Vector2.new(1,0),
ThemeTag={
ImageColor3="Text"
},
ImageTransparency=.4,
},{
e("TextButton",{
Size=UDim2.new(1,8,1,8),
BackgroundTransparency=1,
AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.new(0.5,0,0.5,0),
Text="",
})
})
end

local m=e("Frame",{
Size=UDim2.new(0,0,1,0),
BackgroundTransparency=.95,
ThemeTag={
BackgroundColor3="Text",
},

})

local p=e("Frame",{
Size=UDim2.new(1,
i.Icon and-28-g.UIPadding or 0,
1,0),
Position=UDim2.new(1,0,0,0),
AnchorPoint=Vector2.new(1,0),
BackgroundTransparency=1,
AutomaticSize="Y",
},{
e("UIPadding",{
PaddingTop=UDim.new(0,g.UIPadding),
PaddingLeft=UDim.new(0,g.UIPadding),
PaddingRight=UDim.new(0,g.UIPadding),
PaddingBottom=UDim.new(0,g.UIPadding),
}),
e("TextLabel",{
AutomaticSize="Y",
Size=UDim2.new(1,-30-g.UIPadding,0,0),
TextWrapped=true,
TextXAlignment="Left",
RichText=true,
BackgroundTransparency=1,
TextSize=16,
ThemeTag={
TextColor3="Text"
},
Text=i.Title,
FontFace=Font.new(b.Font,Enum.FontWeight.Medium)
}),
e("UIListLayout",{
Padding=UDim.new(0,g.UIPadding/3)
})
})

if i.Content then
e("TextLabel",{
AutomaticSize="Y",
Size=UDim2.new(1,0,0,0),
TextWrapped=true,
TextXAlignment="Left",
RichText=true,
BackgroundTransparency=1,
TextTransparency=.4,
TextSize=15,
ThemeTag={
TextColor3="Text"
},
Text=i.Content,
FontFace=Font.new(b.Font,Enum.FontWeight.Medium),
Parent=p
})
end

local r=b.NewRoundFrame(g.UICorner,"Squircle",{
Size=UDim2.new(1,0,0,0),
Position=UDim2.new(2,0,1,0),
AnchorPoint=Vector2.new(0,1),
AutomaticSize="Y",
ImageTransparency=.05,
ThemeTag={
ImageColor3="Background"
},

},{
e("CanvasGroup",{
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
},{
m,
e("UICorner",{
CornerRadius=UDim.new(0,g.UICorner),
})

}),
e("ImageLabel",{
Name="Background",
Image=i.Background,
BackgroundTransparency=1,
Size=UDim2.new(1,0,1,0),
ScaleType="Crop",
ImageTransparency=i.BackgroundImageTransparency

},{
e("UICorner",{
CornerRadius=UDim.new(0,g.UICorner),
})
}),

p,
j,l,
})

local x=e("Frame",{
BackgroundTransparency=1,
Size=UDim2.new(1,0,0,0),
Parent=h.Holder
},{
r
})

function i.Close(z)
if not i.Closed then
i.Closed=true
f(x,0.45,{Size=UDim2.new(1,0,0,-8)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
f(r,0.55,{Position=UDim2.new(2,0,1,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
task.wait(.45)
x:Destroy()
end
end

task.spawn(function()
task.wait()
f(x,0.45,{Size=UDim2.new(
1,
0,
0,
r.AbsoluteSize.Y
)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
f(r,0.45,{Position=UDim2.new(0,0,1,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
if i.Duration then
f(m,i.Duration,{Size=UDim2.new(1,0,1,0)},Enum.EasingStyle.Linear,Enum.EasingDirection.InOut):Play()
task.wait(i.Duration)
i:Close()
end
end)

if l then
b.AddSignal(l.TextButton.MouseButton1Click,function()
i:Close()
end)
end

return i
end

return g end function a.d()
return{
Dark={
Name="Dark",
Accent="#18181b",
Dialog="#161616",
Outline="#FFFFFF",
Text="#FFFFFF",
Placeholder="#999999",
Background="#101010",
Button="#52525b",
Icon="#a1a1aa",
},
Light={
Name="Light",
Accent="#FFFFFF",
Dialog="#f4f4f5",
Outline="#09090b",
Text="#000000",
Placeholder="#777777",
Background="#e4e4e7",
Button="#18181b",
Icon="#52525b",
},
Rose={
Name="Rose",
Accent="#f43f5e",
Outline="#ffe4e6",
Text="#ffe4e6",
Placeholder="#fda4af",
Background="#881337",
Button="#e11d48",
Icon="#fecdd3",
},
Plant={
Name="Plant",
Accent="#22c55e",
Outline="#dcfce7",
Text="#dcfce7",
Placeholder="#bbf7d0",
Background="#14532d",
Button="#22c55e",
Icon="#86efac",
},
Red={
Name="Red",
Accent="#ef4444",
Outline="#fee2e2",
Text="#ffe4e6",
Placeholder="#fca5a5",
Background="#7f1d1d",
Button="#ef4444",
Icon="#fecaca",
},
Indigo={
Name="Indigo",
Accent="#6366f1",
Outline="#e0e7ff",
Text="#e0e7ff",
Placeholder="#a5b4fc",
Background="#312e81",
Button="#6366f1",
Icon="#c7d2fe",
},
Sky={
Name="Sky",
Accent="#0ea5e9",
Outline="#e0f2fe",
Text="#e0f2fe",
Placeholder="#7dd3fc",
Background="#075985",
Button="#0ea5e9",
Icon="#bae6fd",
},
Violet={
Name="Violet",
Accent="#8b5cf6",
Outline="#ede9fe",
Text="#ede9fe",
Placeholder="#c4b5fd",
Background="#4c1d95",
Button="#8b5cf6",
Icon="#ddd6fe",
},
Amber={
Name="Amber",
Accent="#f59e0b",
Outline="#fef3c7",
Text="#fef3c7",
Placeholder="#fcd34d",
Background="#78350f",
Button="#f59e0b",
Icon="#fde68a",
},
Emerald={
Name="Emerald",
Accent="#10b981",
Outline="#d1fae5",
Text="#d1fae5",
Placeholder="#6ee7b7",
Background="#064e3b",
Button="#10b981",
Icon="#a7f3d0",
},
}end

-- ... rest of the code remains the same ...

local aa={
Window=nil,
Theme=nil,
Creator=a.load'a',
LocalizationModule=a.load'b',
NotificationModule=a.load'c',
Themes=a.load'd',
Transparent=false,
TransparencyValue=.15,
UIScale=1,
ConfigManager=nil,
Services=a.load'h',
OnThemeChangeFunction=nil,
}

local ac=a.load'l'local ae=aa.Services
local af=aa.Themes
local ag=aa.Creator

local ah=ag.New local ai=ag.Tween

ag.Themes=af local aj=game:GetService"Players"and game:GetService"Players".LocalPlayer or nil

local ak=protectgui or(syn and syn.protect_gui)or function()end

local al=gethui and gethui()or game.CoreGui

aa.ScreenGui=ah("ScreenGui",{
Name="WindUI",
Parent=al,
IgnoreGuiInset=true,
ScreenInsets="None",
},{
ah("UIScale",{
Scale=aa.Scale,
}),
ah("Folder",{
Name="Window"
}),
ah("Folder",{
Name="KeySystem"
}),
ah("Folder",{
Name="Popups"
}),
ah("Folder",{
Name="ToolTips"
})
})

aa.NotificationGui=ah("ScreenGui",{
Name="WindUI/Notifications",
Parent=al,
IgnoreGuiInset=true,
})
aa.DropdownGui=ah("ScreenGui",{
Name="WindUI/Dropdowns",
Parent=al,
IgnoreGuiInset=true,
})
ak(aa.ScreenGui)
ak(aa.NotificationGui)
ak(aa.DropdownGui)

ag.Init(aa)

math.clamp(aa.TransparencyValue,0,1)

local am=aa.NotificationModule.Init(aa.NotificationGui)

function aa.Notify(an,ao)
ao.Holder=am.Frame
ao.Window=aa.Window

return aa.NotificationModule.New(ao)
end

function aa.SetNotificationLower(an,ao)
am.SetLower(ao)
end

function aa.SetFont(an,ao)
ag.UpdateFont(ao)
end

function aa.OnThemeChange(an,ao)
aa.OnThemeChangeFunction=ao
end

function aa.AddTheme(an,ao)
af[ao.Name]=ao
return ao
end

function aa.SetTheme(an,ao)
if af[ao]then
aa.Theme=af[ao]
ag.SetTheme(af[ao])

if aa.OnThemeChangeFunction then
aa.OnThemeChangeFunction(ao)
end
return af[ao]
end
return nil
end

function aa.GetThemes(an)
return af
end
function aa.GetCurrentTheme(an)
return aa.Theme.Name
end
function aa.GetTransparency(an)
return aa.Transparent or false
end
function aa.GetWindowSize(an)
return Window.UIElements.Main.Size
end
function aa.Localization(an,ao)
return aa.LocalizationModule:New(ao,ag)
end

function aa.SetLanguage(an,ao)
if ag.Localization then
return ag.SetLanguage(ao)
end
return false
end

aa:SetTheme"Dark"
aa:SetLanguage(ag.Language)

function aa.Gradient(an,ao,ap)
local ar={}
local as={}

for at,au in next,ao do
local av=tonumber(at)
if av then
av=math.clamp(av/100,0,1)
table.insert(ar,ColorSequenceKeypoint.new(av,au.Color))
table.insert(as,NumberSequenceKeypoint.new(av,au.Transparency or 0))
end
end

table.sort(ar,function(av,aw)return av.Time<aw.Time end)
table.sort(as,function(av,aw)return av.Time<aw.Time end)

if#ar<2 then
error"ColorSequence requires at least 2 keypoints"
end

local av={
Color=ColorSequence.new(ar),
Transparency=NumberSequence.new(as),
}

if ap then
for aw,ax in pairs(ap)do
av[aw]=ax
end
end

return av
end

function aa.Popup(an,ao)
ao.WindUI=aa
return a.load'm'.new(ao)
end

function aa.CreateWindow(an,ao)
local ap=a.load'O'

if not isfolder"WindUI"then
makefolder"WindUI"
end
if ao.Folder then
makefolder(ao.Folder)
else
makefolder(ao.Title)
end

ao.WindUI=aa
ao.Parent=aa.ScreenGui.Window

if aa.Window then
warn"You cannot create more than one window"
return
end

local ar=true

local as=af[ao.Theme or"Dark"]

ag.SetTheme(as)

local at=gethwid or function()
return game:GetService"Players".LocalPlayer.UserId
end

local au=at()

if ao.KeySystem then
ar=false

local function loadKeysystem()
ac.new(ao,au,function(av)ar=av end)
end

local av=ao.Folder.."/"..au..".key"

if not ao.KeySystem.API and ao.KeySystem.SaveKey and ao.Folder then
if isfile(av)then
local aw=readfile(av)
local ax=(type(ao.KeySystem.Key)=="table")
and table.find(ao.KeySystem.Key,aw)
or tostring(ao.KeySystem.Key)==tostring(aw)

if ax then
ar=true
else
loadKeysystem()
end
else
loadKeysystem()
end
else
if isfile(av)then
local aw=readfile(av)
local ax=false

for ay,az in next,ao.KeySystem.API do
local aA=aa.Services[az.Type]
if aA then
local aB={}
for aC,aD in next,aA.Args do
table.insert(aB,az[aD])
end

local aE=aA.New(table.unpack(aB))
local b=aE.Verify(aw)
if b then
ax=true
break
end
end
end

ar=ax
if not ax then loadKeysystem()end
else
loadKeysystem()
end
end

repeat task.wait()until ar
end

local av=ap(ao)

aa.Transparent=ao.Transparent
aa.Window=av

return av
end

return aa
