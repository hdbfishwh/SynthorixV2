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





local b=game:GetService"RunService"local d=
b.Heartbeat
local e=game:GetService"UserInputService"
local f=game:GetService"TweenService"
local g=game:GetService"LocalizationService"

local h=loadstring(game:HttpGetAsync"https://raw.githubusercontent.com/Footagesus/Icons/main/Main.lua")()
h.SetIconsType"lucide"

local i

local j={
Font="rbxassetid://99055441546319", -- Your custom logo ID added here
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
SliceCenter=m~="Shadow-sm"and Rect.new(256
,256
,256
,256

)or Rect.new(512,512,512,512),
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

local l=j.New local m=
j.Tween

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
}end function a.e()











local b=4294967296;local e=b-1;local function c(f,g)local h,i=0,1;while f~=0 or g~=0 do local j,l=f%2,g%2;local m=(j+l)%2;h=h+m*i;f=math.floor(f/2)g=math.floor(g/2)i=i*2 end;return h%b end;local function k(f,g,h,...)local i;if g then f=f%b;g=g%b;i=c(f,g)if h then i=k(i,h,...)end;return i elseif f then return f%b else return 0 end end;local function n(f,g,h,...)local i;if g then f=f%b;g=g%b;i=(f+g-c(f,g))/2;if h then i=n(i,h,...)end;return i elseif f then return f%b else return e end end;local function o(f)return e-f end;local function q(f,g)if g<0 then return lshift(f,-g)end;return math.floor(f%4294967296/2^g)end;local function s(f,g)if g>31 or g<-31 then return 0 end;return q(f%b,g)end;local function lshift(f,g)if g<0 then return s(f,-g)end;return f*2^g%4294967296 end;local function t(f,g)f=f%b;g=g%32;local h=n(f,2^g-1)return s(f,g)+lshift(h,32-g)end;local f={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0-a81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(g)return string.gsub(g,".",function(h)return string.format("%02x",string.byte(h))end)end;local function y(g,h)local i=""for j=1,h do local l=g%256;i=string.char(l)..i;g=(g-l)/256 end;return i end;local function D(g,h)local i=0;for j=h,h+3 do i=i*256+string.byte(g,j)end;return i end;local function E(g,h)local i=64-(h+9)%64;h=y(8*h,8)g=g.."\128"..string.rep("\0",i)..h;assert(#g%64==0)return g end;local function I(g)g[1]=0x6a09e667;g[2]=0xbb67ae85;g[3]=0x3c6ef372;g[4]=0xa54ff53a;g[5]=0x510e527f;g[6]=0x9b05688c;g[7]=0x1f83d9ab;g[8]=0x5be0cd19;return g end;local function K(g,h,i)local j={}for l=1,16 do j[l]=D(g,h+(l-1)*4)end;for l=17,64 do local m=j[l-15]local p=k(t(m,7),t(m,18),s(m,3))m=j[l-2]j[l]=(j[l-16]+p+j[l-7]+k(t(m,17),t(m,19),s(m,10)))%b end;local l,m,p,r,x,z,A,B=i[1],i[2],i[3],i[4],i[5],i[6],i[7],i[8]for C=1,64 do local F=k(t(l,2),t(l,13),t(l,22))local G=k(n(l,m),n(l,p),n(m,p))local H=(F+G)%b;local J=k(t(x,6),t(x,11),t(x,25))local L=k(n(x,z),n(o(x),A))local M=(B+J+L+f[C]+j[C])%b;B=A;A=z;z=x;x=(r+M)%b;r=p;p=m;m=l;l=(M+H)%b end;i[1]=(i[1]+l)%b;i[2]=(i[2]+m)%b;i[3]=(i[3]+p)%b;i[4]=(i[4]+r)%b;i[5]=(i[5]+x)%b;i[6]=(i[6]+z)%b;i[7]=(i[7]+A)%b;i[8]=(i[8]+B)%b end;local function Z(g)g=E(g,#g)local h=I{}for i=1,#g,64 do K(g,i,h)end;return w(y(h[1],4)..y(h[2],4)..y(h[3],4)..y(h[4],4)..y(h[5],4)..y(h[6],4)..y(h[7],4)..y(h[8],4))end;local g;local h={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}local i={["/"]="/"}for j,l in pairs(h)do i[l]=j end;local m=function(m)return"\\"..(h[m]or string.format("u%04x",m:byte()))end;local p=function(p)return"null"end;local r=function(r,x)local z={}x=x or{}if x[r]then error"circular reference"end;x[r]=true;if rawget(r,1)~=nil or next(r)==nil then local A=0;for B in pairs(r)do if type(B)~="number"then error"invalid table: mixed or invalid key types"end;A=A+1 end;if A~=#r then error"invalid table: sparse array"end;for C,F in ipairs(r)do table.insert(z,g(F,x))end;x[r]=nil;return"["..table.concat(z,",").."]"else for A,B in pairs(r)do if type(A)~="string"then error"invalid table: mixed or invalid key types"end;table.insert(z,g(A,x)..":"..g(B,x))end;x[r]=nil;return"{"..table.concat(z,",").."}"end end;local x=function(x)return'"'..x:gsub('[%z\1-\31\\"]',m)..'"'end;local z=function(z)if z~=z or z<=-math.huge or z>=math.huge then error("unexpected number value '"..tostring(z).."'")end;return string.format("%.14g",z)end;local A={["nil"]=p,table=r,string=x,number=z,boolean=tostring}g=function(B,C)local F=type(B)local G=A[F]if G then return G(B,C)end;error("unexpected type '"..F.."'")end;local B=function(B)return g(B)end;local C;local F=function(...)local F={}for G=1,select("#",...)do F[select(G,...)]=true end;return F end;local G=F(" ","\t","\r","\n")local H=F(" ","\t","\r","\n","]","}",",")local J=F("\\","/",'"',"b","f","n","r","t","u")local L=F("true","false","null")local M={["true"]=true,["false"]=false,null=nil}local N=function(N,O,P,Q)for R=O,#N do if P[N:sub(R,R)]~=Q then return R end end;return#N+1 end;local O=function(O,P,Q)local R=1;local S=1;for T=1,P-1 do S=S+1;if O:sub(T,T)=="\n"then R=R+1;S=1 end end;error(string.format("%s at line %d col %d",Q,R,S))end;local P=function(P)local Q=math.floor;if P<=0x7f then return string.char(P)elseif P<=0x7ff then return string.char(Q(P/64)+192,P%64+128)elseif P<=0xffff then return string.char(Q(P/4096)+224,Q(P%4096/64)+128,P%64+128)elseif P<=0x10ffff then return string.char(Q(P/262144)+240,Q(P%262144/4096)+128,Q(P%4096/64)+128,P%64+128)end;error(string.format("invalid unicode codepoint '%x'",P))end;local Q=function(Q)local R=tonumber(Q:sub(1,4),16)local S=tonumber(Q:sub(7,10),16)if S then return P((R-0xd800)*0x400+S-0xdc00+0x10000)else return P(R)end end;local R=function(R,S)local T=""local U=S+1;local V=U;while U<=#R do local W=R:byte(U)if W<32 then O(R,U,"control character in string")elseif W==92 then T=T..R:sub(V,U-1)U=U+1;local X=R:sub(U,U)if X=="u"then local Y=R:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",U+1)or R:match("^%x%x%x%x",U+1)or O(R,U-1,"invalid unicode escape in string")T=T..Q(Y)U=U+#Y else if not J[X]then O(R,U-1,"invalid escape char '"..X.."' in string")end;T=T..i[X]end;V=U+1 elseif W==34 then T=T..R:sub(V,U-1)return T,U+1 end;U=U+1 end;O(R,S,"expected closing quote for string")end;local S=function(S,T)local U=N(S,T,H)local V=S:sub(T,U-1)local W=tonumber(V)if not W then O(S,T,"invalid number '"..V.."'")end;return W,U end;local T=function(T,U)local V=N(T,U,H)local W=T:sub(U,V-1)if not L[W]then O(T,U,"invalid literal '"..W.."'")end;return M[W],V end;local U=function(U,V)local W={}local X=1;V=V+1;while 1 do local Y;V=N(U,V,G,true)if U:sub(V,V)=="]"then V=V+1;break end;Y,V=C(U,V)W[X]=Y;X=X+1;V=N(U,V,G,true)local _=U:sub(V,V)V=V+1;if _=="]"then break end;if _~=","then O(U,V,"expected ']' or ','")end end;return W,V end;local aa=function(V,W)local X={}W=W+1;while 1 do local Y,_;W=N(V,W,G,
