local EncodingService = game:GetService("EncodingService")
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/pubmain/LinoriaLib/refs/heads/main/Library.lua"))() 
local thememanager = loadstring(game:HttpGet("https://raw.githubusercontent.com/pubmain/LinoriaLib/refs/heads/main/addons/ThemeManager.lua"))() 
local savemanager = loadstring(game:HttpGet("https://raw.githubusercontent.com/pubmain/LinoriaLib/refs/heads/main/addons/SaveManager.lua"))() 

local options = library.Options
local toggles = library.Toggles
library.ToggleKeybind = "Del"

local execname = identifyexecutor() or "Shit-Ware"

local window = library:CreateWindow({
	Title = "Aniphobia | " .. execname,
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
	UnlockMouseWhileOpen = true,
	TabPadding = 8,
	MenuFadeTime = 0.5,
	NotifySide = "Right",
	ShowToggleFrameInKeybinds = true,
})

local tabs = {
	main = window:AddTab("main"),
    config = window:AddTab("configs")
}

local main = tabs.main:AddLeftGroupbox("main")
local misc = tabs.main:AddRightGroupbox("misc")
local itemteleports = tabs.main:AddLeftTabbox()
local objectvisuals = tabs.main:AddRightGroupbox("visuals")

local lighting = cloneref(game:GetService("Lighting"))
local runserv = cloneref(game:GetService("RunService"))
local startergui = cloneref(game:GetService("StarterGui"))
local localplayer = cloneref(game:GetService("Players")).LocalPlayer
local character = localplayer.Character
local camera = cloneref(game:GetService("Workspace")).CurrentCamera

local ammocolor = Color3.fromRGB(180, 219, 163)
local lootcolor = Color3.fromRGB(81, 255, 0)
local vehiclecolor = Color3.fromRGB(30, 4, 179)
local waifucolor = Color3.fromRGB(146, 5, 5)
local playercolor = Color3.fromRGB(9, 148, 136)
local playertrans = 0
local waifutrans = 0
local ammotrans = 0
local vehicletrans = 0
local loottrans = 0

local lootespcon
local waifuespcon 
local ammoespcon
local vehicleespcon
local walkspeedcon
local jumppowercon
local infammocon
local playerespcon

local lootfolder = game:GetService("Workspace"):FindFirstChild("LootItems", true) -- hopefully only one loot folder
local ammofolder = game:GetService("Workspace"):FindFirstChild("AmmoBoxes")
local vehiclefolder = game:GetService("Workspace"):FindFirstChild("Vehicles")
local waifufolder = game:GetService("Workspace"):FindFirstChild("OtherWaifus")

local ogcframe

local oldammo = {}
local oldfirerate = {}
local oldrecoil = {}
local oldpenetration = {}
local oldrun = {}

local infammo = false
local rapidfire = false
local norecoil = false
local infpenetration = false
local runwithgun = false

local silentaim = false

local firerate = 0.015

-- no reason to seperate ts with a do end but i will
do
    local prediction = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/src/libraries/prediction.lua"))() -- i cant make prediction
   	local projectilehandler = require(game:GetService("ReplicatedStorage"):FindFirstChild("Modules"):WaitForChild("ProjectileHandler"))
    local getsettings = require(game:GetService("ReplicatedStorage"):FindFirstChild("Modules"):WaitForChild("GetSetting"))
    local ogprojectilesim = projectilehandler.SimulateProjectile

    local maxdistance = 2500
    local silenttype = "mouse"
    local hitbox = "Head"
    local fov = 30

    -- ts so scuffed bro
    local function getsexiestwaifu()
        if not localplayer.Character then return nil end
        
        local sexiestwaifu, bestboobs = nil, math.huge
        local fovdis = (camera.ViewportSize.Magnitude / 2) * (fov / 180)
        local mousepos = game:GetService("UserInputService"):GetMouseLocation()
        local selfroot = localplayer and localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
        
        for _,w in waifufolder:GetChildren() do
            if w:IsA("Model") then
                local waifu = w

                local hum = waifu and waifu:FindFirstChildOfClass("Humanoid")
                local root = waifu and waifu:FindFirstChild("HumanoidRootPart")

                if not root then continue end
                if not hum then continue end
                if hum and hum.Health <= 0 then continue end
                if hum and hum:GetState() == Enum.HumanoidStateType.Dead then continue end

                if waifu and root and hum and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead then -- double check because ts so scuffed it magdumps dead bodies????
                    if silenttype == "mouse" then
                        local screenpos, screen = camera:WorldToViewportPoint(root.Position)
                            if screen then
                                local dis = (Vector2.new(screenpos.X, screenpos.Y) - mousepos).Magnitude

                                if dis and dis <= fovdis and dis < bestboobs then
                                    bestboobs = dis
                                    sexiestwaifu = waifu
                                end
                            end
                        end
                    end

                    if silenttype == "position" then
                        local dis = (root.Position - selfroot.Position).Magnitude

                        if dis and maxdistance == 0 then
                            if dis < bestboobs then
                                bestboobs = dis
                                sexiestwaifu = waifu
                            end
                        end

                        if dis and maxdistance > 0 then
                            if dis <= maxdistance and dis < bestboobs then
                                bestboobs = dis
                                sexiestwaifu = waifu
                            end
                        end
                    end
                end
            end
        return sexiestwaifu
    end

    local function getbulletspeed(tool, misc)
        local settings = getsettings(tool, {ModuleName = misc.ModuleName, ModNames = misc.ModNames, BulletId = misc.BulletId}, nil, nil) -- if u dont pass ts 1:1 it whines and cries

        if settings.ChargedShotAdvanceEnabled and settings.ChargeAlterTable then
            local level = misc.ChargeLevel or 1
            local bulletspeed = settings.ChargeAlterTable.BulletSpeed
            if bulletspeed then
                if level == 1 and bulletspeed.Level1 then return bulletspeed.Level1 end
                if level == 2 and bulletspeed.Level2 then return bulletspeed.Level2 end
                if level == 3 and bulletspeed.Level3 then return bulletspeed.Level3 end
            end
        end

        return settings.BulletSpeed
    end

    projectilehandler.SimulateProjectile = function(v1, tool, v3, bullets, muzzle, v6, misc, replicate)
        if silentaim and replicate and type(bullets) == "table" and muzzle then
            local sexywaifu = getsexiestwaifu()
            if sexywaifu and sexywaifu:FindFirstChild(hitbox) then
                local origin = (muzzle.WorldPosition or muzzle.Position)
                local bulletspeed = getbulletspeed(tool, misc)
                local hitpart = sexywaifu:FindFirstChild(hitbox)
                local root = sexywaifu:FindFirstChild("HumanoidRootPart")
                
                if root and hitpart and origin and bulletspeed then
                    local predictedpos = prediction and prediction.SolveTrajectory(origin, bulletspeed, game:GetService("Workspace").Gravity, hitpart.Position, root.Velocity, nil, nil, nil, nil)
                    local dir = (predictedpos - origin).Unit

                    for _, b in bullets do
                        if type(b) == "table" then b[1] = dir end
                    end
                end
            end
        end
        return ogprojectilesim(v1, tool, v3, bullets, muzzle, v6, misc, replicate)
    end
    
    main:AddToggle('silentaim',{
        Default = false,
        Text = "silentaim",
        Tooltip = "redirects your bullet to the nearest enemy",
        Callback = function(v)
            silentaim = v
        end
    })

    main:AddDropdown('hitbox',{
		Values = {"Head", "Torso", "HumanoidRootPart",},
		Default = "Head",
		Multi = false,
		Text = "hitbox",
        Tooltip = "the part which silentaim will redirect to",
		Callback = function(v)  
            hitbox = v
		end
	})

    main:AddDropdown('silenttype',{
		Values = {"mouse", "position"},
		Default = "mouse",
		Multi = false,
		Text = "silent type",
        Tooltip = "mouse gets closest to your mouse, position gets closest around you (ignores fov)",
		Callback = function(v)  
            silenttype = v

            if v == 'mouse' then
                options.silentfov:SetVisible(true)
                options.silentdistance:SetVisible(false)
            else
                options.silentfov:SetVisible(false)
                options.silentdistance:SetVisible(true)
            end
		end
	})

    main:AddSlider('silentdistance',{
        Min = 0,
        Max = 10000,
        Rounding = 0,
        Default = 2500,
        Compact = true,
        Text = "silent distance",
        Visible = false,
        Tooltip = "maxmium distance that silent will redirect at (0 means silent will redirect no matter the distance)",
        Callback = function(v) 
            maxdistance = v
        end
    })

    main:AddSlider('silentfov',{
        Min = 1,
        Max = 180,
        Rounding = 0,
        Default = 30,
        Compact = true,
        Text = "silent fov",
        Visible = true,
        Tooltip = "the fov that silentaim will use to redirect",
        Callback = function(v) 
            fov = v
        end
    })

    main:AddDivider()
end

main:AddToggle('infiniteammo',{
    Default = false,
    Text = "infinite ammo",
    Tooltip = "prevents your gun from losing ammo when firing",
    Callback = function(v)
        infammo = v

        if v then
            for _,v in filtergc("table",{Keys = {"AmmoCost", "AmmoPerMag"}}) do
                if not oldammo[v] then
                    oldammo[v] = {v.AmmoCost, v.LimitedAmmoEnabled}
                end

                setreadonly(v, false)
                v.AmmoCost = 0 
                v.LimitedAmmoEnabled = false
                setreadonly(v, true)
            end
        else
            for i,v in oldammo do
                setreadonly(i, false)
                i.LimitedAmmoEnabled = v[2] 
                i.AmmoCost = v[1]
                setreadonly(i, true)
            end
        end
    end
})
main:AddToggle('rapidfire',{
    Default = false,
    Text = "rapid fire",
    Tooltip = "lets you customize the firerate of guns (lower your volume as much as possible pls)",
    Callback = function(v)
        rapidfire = v
        options.firerate:SetVisible(v)

        if v then
            for _,v in filtergc("table",{Keys = {"FireRate", "MaximumFireRate", "FireRateIncrement", "DelayBeforeFiring", "DelayAfterFiring", "Auto", "ChargingTime", "ShotgunPumpinSpeed", "LaserBeamStartupDelay", "LaserBeamStopDelay"}}) do
                if not oldfirerate[v] then
                    oldfirerate[v] = {v.FireRate, v.MaximumFireRate, v.FireRateIncrement, v.DelayBeforeFiring, v.DelayAfterFiring, v.Auto, v.ChargingTime, v.ShotgunPumpinSpeed, v.LaserBeamStartupDelay, v.LaserBeamStopDelay}
                end

                setreadonly(v, false)
                v.FireRate = firerate
                v.MaximumFireRate = firerate
                v.FireRateIncrement = 0
                v.DelayBeforeFiring = 0
                v.DelayAfterFiring = 0
                v.Auto = true
                v.ChargingTime = 0
                v.ShotgunPumpinSpeed = 0
                v.LaserBeamStartupDelay = 0
                v.LaserBeamStopDelay = 0
                setreadonly(v, true)
            end
        else
            for i,v in oldfirerate do
                setreadonly(i, false)
                i.FireRate = v[1] 
                i.MaximumFireRate = v[2]
                i.FireRateIncrement = v[3]
                i.DelayBeforeFiring = v[4]
                i.DelayAfterFiring = v[5]
                i.Auto = v[6]
                v.ChargingTime = v[7]
                v.ShotgunPumpinSpeed = v[8]
                v.LaserBeamStartupDelay = v[9]
                v.LaserBeamStopDelay = v[10]
                setreadonly(i, true)
            end
        end
    end
})
main:AddSlider('firerate',{
    Min = 0,
    Max = 1,
    Rounding = 2,
    Default = firerate,
    Compact = true,
    Text = "firerate",
    Visible = false,
    Tooltip = "lets you change the firerate rapid fire uses (low values = earrape)",
    Callback = function(v) 
        firerate = v

        for _,t in filtergc("table",{Keys = {"FireRate", "MaximumFireRate"}}) do
            setreadonly(t, false)
            t.FireRate = firerate
            t.MaximumFireRate = firerate
            setreadonly(t, true)
        end
    end
})
main:AddToggle('no recoil',{
    Default = false,
    Text = "no recoil",
    Tooltip = "prevents screen from shaking when firing",
    Callback = function(v)
        norecoil = v

        if v then
            for _,v in filtergc("table",{Keys = {"Recoil"}}) do
                if not oldrecoil[v] then
                    oldrecoil[v] = {v.Recoil}
                end

                setreadonly(v, false)
                v.Recoil = 0
                setreadonly(v, true)
            end
        else
            for i,v in oldrecoil do
                setreadonly(i, false)
                i.Recoil = v[1] 
                setreadonly(i, true)
            end
        end
    end
})
main:AddToggle('infinite penetration',{
    Default = false,
    Text = "infinite penetration",
    Tooltip = "lets your bullets penetrate most objects/terrain (works best with red ryder carbine)",
    Callback = function(v)
        infpenetration = v

        if v then
            for _,v in filtergc("table",{Keys = {"PenetrationAmount", "PenetrationDepth", "DamageThroughWall", "IgnoreHumanoids"}}) do
                if not oldpenetration[v] then
                    oldpenetration[v] = {v.PenetrationAmount, v.PenetrationDepth, v.DamageThroughWall, v.IgnoreHumanoids}
                end

                setreadonly(v, false)
                v.PenetrationAmount = 9e9
                v.PenetrationDepth  = 9e9
                v.DamageThroughWall = true
                v.IgnoreHumanoids   = false
                setreadonly(v, true)
            end
        else
            for i,v in oldpenetration do
                setreadonly(i, false)
                i.PenetrationAmount = v[1]
                i.PenetrationDepth  = v[2]
                i.DamageThroughWall = v[3]
                i.IgnoreHumanoids   = v[4] 
                setreadonly(i, true)
            end
        end
    end
})
main:AddToggle('runwithgun',{
    Default = false,
    Text = "run with gun",
    Tooltip = "lets you shoot and sprint",
    Callback = function(v)
        runwithgun = v

        if v then
            for _,v in filtergc("table",{Keys = {"HoldDownEnabled"}}) do
                if not oldrun[v] then
                    oldrun[v] = {v.HoldDownEnabled}
                end

                setreadonly(v, false)
                v.HoldDownEnabled = false
                setreadonly(v, true)
            end
        else
            for i,v in oldrun do
                setreadonly(i, false)
                i.HoldDownEnabled = v[1]
                setreadonly(i, true)
            end
        end
    end
})

infammocon = localplayer.DescendantAdded:Connect(function(c)
    task.wait(0.5) -- sometime for weapon logic

    if c:IsA("Tool") and c:FindFirstChild("GunClient") then
        if infammo then
            for _,v in filtergc("table",{Keys = {"AmmoCost", "AmmoPerMag"}}) do
                if not oldammo[v] then
                    oldammo[v] = {v.AmmoCost, v.LimitedAmmoEnabled}
                end

                setreadonly(v, false)
                v.AmmoCost = 0 
                v.LimitedAmmoEnabled = false
                setreadonly(v, true)
            end
        end

        if rapidfire then
            for _,v in filtergc("table",{Keys = {"FireRate", "MaximumFireRate", "FireRateIncrement", "DelayBeforeFiring", "DelayAfterFiring", "Auto", "ChargingTime", "ShotgunPumpinSpeed", "LaserBeamStartupDelay", "LaserBeamStopDelay"}}) do
                if not oldfirerate[v] then
                    oldfirerate[v] = {v.FireRate, v.MaximumFireRate, v.FireRateIncrement, v.DelayBeforeFiring, v.DelayAfterFiring, v.Auto, v.ChargingTime, v.ShotgunPumpinSpeed, v.LaserBeamStartupDelay, v.LaserBeamStopDelay}
                end

                setreadonly(v, false)
                v.FireRate = firerate 
                v.MaximumFireRate = firerate
                v.FireRateIncrement = 0
                v.DelayBeforeFiring = 0
                v.DelayAfterFiring = 0
                v.Auto = true
                v.ChargingTime = 0
                v.ShotgunPumpinSpeed = 0
                v.LaserBeamStartupDelay = 0
                v.LaserBeamStopDelay = 0
                setreadonly(v, true)
            end
        end

        if norecoil then
            for _,v in filtergc("table",{Keys = {"Recoil"}}) do
                if not oldrecoil[v] then
                    oldrecoil[v] = {v.Recoil}
                end

                setreadonly(v, false)
                v.Recoil = 0
                setreadonly(v, true)
            end
        end

        if infpenetration then
            for _,v in filtergc("table",{Keys = {"PenetrationAmount", "PenetrationDepth", "DamageThroughWall", "IgnoreHumanoids"}}) do
                if not oldpenetration[v] then
                    oldpenetration[v] = {v.PenetrationAmount, v.PenetrationDepth, v.DamageThroughWall, v.IgnoreHumanoids}
                end

                setreadonly(v, false)
                v.PenetrationAmount = math.huge
                v.PenetrationDepth  = math.huge
                v.DamageThroughWall = true
                v.IgnoreHumanoids   = false
                setreadonly(v, true)
            end
        end

        if runwithgun then
            for _,v in filtergc("table",{Keys = {"HoldDownEnabled"}}) do
                if not oldrun[v] then
                    oldrun[v] = {v.HoldDownEnabled}
                end

                setreadonly(v, false)
                v.HoldDownEnabled = false
                setreadonly(v, true)
            end
        end
    end
end)

do
    local loottab = itemteleports:AddTab("loot")
    local teleportobject
    local loot = {}

    local function getloot()
        table.clear(loot)

        for _,v in lootfolder:GetChildren() do -- ui lib treats object with same name as same entry ffs, would do counting method but debugid is easier and shorter
            if v and v.Name then
                local uid = v.Name .. v:GetDebugId()
                table.insert(loot, uid)
            end
        end
    end

    loottab:AddDropdown('lootobjects',{
		Values = loot,
		Default = loot[1] or "None",
		Multi = false,
		Text = "loot object",
		Callback = function(v)
            for _,l in lootfolder:GetChildren() do
                if string.find(v, l.Name) then
                    teleportobject = l
                end
            end
		end
	})

    lootteleport = loottab:AddButton({
        Text = "teleport",
        Func = function()
            if localplayer and localplayer.Character and teleportobject ~= nil then
                localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(teleportobject.Position)
            end
        end,
        DoubleClick = false,
        Visible = true
    })

    refreshdropdown = loottab:AddButton({
        Text = "refresh",
        Func = function()
            teleportobject = nil
            options.lootobjects:SetValues({})
            getloot()
            options.lootobjects:SetValues(loot)
        end,
        DoubleClick = false,
        Visible = true
    })

    loottab:AddDivider()

    saveoldcframe = loottab:AddButton({
        Text = "save cframe",
        Func = function()
            if localplayer and localplayer.Character then
                ogcframe = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame
            end
        end,
        DoubleClick = false,
        Visible = true
    })

    teleportooldcframe = loottab:AddButton({
        Text = "teleport to old cframe",
        Func = function()
            if localplayer and localplayer.Character and ogcframe then
                localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame = ogcframe
            end
        end,
        DoubleClick = false,
        Visible = true
    })
end

do
    local ammotab = itemteleports:AddTab("ammo")
    local teleportobject
    local ammo = {}

    local function getloot()
        table.clear(ammo)

        for _,v in ammofolder:GetChildren() do
            if v and v.Name then
                local uid = v.Name .. v:GetDebugId()
                table.insert(ammo, uid)
            end
        end
    end

    ammotab:AddDropdown('ammoobjects',{
		Values = ammo,
		Default = ammo[1] or "None",
		Multi = false,
		Text = "loot object",
		Callback = function(v)
            for _,l in ammofolder:GetChildren() do
                if string.find(v, l.Name) then
                    teleportobject = l
                end
            end
		end
	})

    ammoteleport = ammotab:AddButton({
        Text = "teleport",
        Func = function()
            if localplayer and localplayer.Character and teleportobject ~= nil then
                localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(teleportobject.Position)
            end
        end,
        DoubleClick = false,
        Visible = true
    })

    refreshdropdown = ammotab:AddButton({
        Text = "refresh",
        Func = function()
            teleportobject = nil
            options.ammoobjects:SetValues({})
            getloot()
            options.ammoobjects:SetValues(ammo)
        end,
        DoubleClick = false,
        Visible = true
    })

    ammotab:AddDivider()

    saveoldcframe = ammotab:AddButton({
        Text = "save cframe",
        Func = function()
            if localplayer and localplayer.Character then
                ogcframe = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame
            end
        end,
        DoubleClick = false,
        Visible = true
    })

    teleportooldcframe = ammotab:AddButton({
        Text = "teleport to old cframe",
        Func = function()
            if localplayer and localplayer.Character and ogcframe then
                localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame = ogcframe
            end
        end,
        DoubleClick = false,
        Visible = true
    })
end

do
    local vehicletab = itemteleports:AddTab("vehicle")
    local teleportobject
    local vehicles = {}

    local function getloot()
        table.clear(vehicles)

        for _,v in vehiclefolder:GetChildren() do
            if v and v.Name then
                local uid = v.Name .. v:GetDebugId()
                table.insert(vehicles, uid)
            end
        end
    end

    vehicletab:AddDropdown('vehicleobjects',{
		Values = vehicles,
		Default = vehicles[1] or "None",
		Multi = false,
		Text = "vehicle object",
		Callback = function(v)
            for _,l in vehiclefolder:GetChildren() do
                if string.find(v, l.Name) then
                    teleportobject = l
                end
            end
		end
	})

    vehicleteleport = vehicletab:AddButton({
        Text = "teleport",
        Func = function()
            if localplayer and localplayer.Character and teleportobject ~= nil then
                localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(teleportobject:GetPivot().Position)
            end
        end,
        DoubleClick = false,
        Visible = true
    })

    refreshdropdown = vehicletab:AddButton({
        Text = "refresh",
        Func = function()
            teleportobject = nil
            options.vehicleobjects:SetValues({})
            getloot()
            options.vehicleobjects:SetValues(vehicles)
        end,
        DoubleClick = false,
        Visible = true
    })

    vehicletab:AddDivider()

    saveoldcframe = vehicletab:AddButton({
        Text = "save cframe",
        Func = function()
            if localplayer and localplayer.Character then
                ogcframe = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame
            end
        end,
        DoubleClick = false,
        Visible = true
    })

    teleportooldcframe = vehicletab:AddButton({
        Text = "teleport to old cframe",
        Func = function()
            if localplayer and localplayer.Character and ogcframe then
                localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame = ogcframe
            end
        end,
        DoubleClick = false,
        Visible = true
    })
end

do
    local jumppower = 20
    local walkspeed = 18

    misc:AddToggle('walkspeedoverride',{
        Default = false,
        Text = "walkspeed override",
        Callback = function(v)
            options.walkspeed:SetVisible(v)

            if v then
                walkspeedcon = runserv.Heartbeat:Connect(function()
                    if localplayer and localplayer.Character then
                        local hum = localplayer and localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")

                        if hum and hum.WalkSpeed and hum.WalkSpeed ~= walkspeed then
                            hum.WalkSpeed = walkspeed
                        end
                    end
                end)
            else
                if walkspeedcon then
                    walkspeedcon:Disconnect()
                    walkspeedcon = nil
                end
            end
        end
    })
    misc:AddSlider('walkspeed',{
        Min = 1,
        Max = 250,
        Rounding = 0,
        Default = walkspeed,
        Compact = true,
        Text = "walkspeed",
        Visible = false,
        Callback = function(v) 
            walkspeed = v
        end
    })

    misc:AddToggle('jumppoweroverride',{
        Default = false,
        Text = "jumppower override",
        Callback = function(v)
            options.jumppower:SetVisible(v)
            
            if v then
                jumppowercon = runserv.Heartbeat:Connect(function()
                    if localplayer and localplayer.Character then
                        local hum = localplayer and localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")

                        if hum and hum.JumpPower and hum.JumpPower ~= jumppower then
                            hum.JumpPower = jumppower
                        end
                    end
                end)
            else
                if jumppowercon then
                    jumppowercon:Disconnect()
                    jumppowercon = nil
                end
            end
        end
    })
    misc:AddSlider('jumppower',{
        Min = 1,
        Max = 250,
        Rounding = 0,
        Default = jumppower,
        Compact = true,
        Text = "jump power",
        Visible = false,
        Callback = function(v) 
            jumppower = v
        end
    })
end

objectvisuals:AddToggle('waifuesp',{
    Default = false,
    Text = "waifu esp",
    Callback = function(v)
        if v then
            for _,w in waifufolder:GetChildren() do
                if w and w:FindFirstChildOfClass("Highlight") then
                    w:FindFirstChildOfClass("Highlight").Enabled = true
                end

                if w and not w:FindFirstChildOfClass("Highlight") then
                    local high = Instance.new("Highlight")

                    high.Parent = w
                    high.Adornee = w
                    high.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    high.OutlineColor = waifucolor
                    high.OutlineTransparency = waifutrans
                    high.FillColor = waifucolor
                    high.FillTransparency = waifutrans
                end
            end

            waifuespcon = waifufolder.ChildAdded:Connect(function(w)
                if w and not w:FindFirstChildOfClass("Highlight") then
                    local high = Instance.new("Highlight")

                    high.Parent = w
                    high.Adornee = w
                    high.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    high.OutlineColor = waifucolor
                    high.OutlineTransparency = waifutrans
                    high.FillColor = waifucolor
                    high.FillTransparency = waifutrans
                end
            end)
        else
            for _,w in waifufolder:GetChildren() do
                if w and w:FindFirstChildOfClass("Highlight") then
                    w:FindFirstChildOfClass("Highlight").Enabled = false
                end
            end

            if waifuespcon then
                waifuespcon:Disconnect()
                waifuespcon = nil
            end
        end
    end
})
objectvisuals:AddLabel('waifu color'):AddColorPicker('waifucolor',{
    Title = "waifu color",
    Default =  waifucolor,
    Callback = function(c)
        waifucolor = c

        for _,v in waifufolder:GetChildren() do
            if v and v:FindFirstChildOfClass("Highlight") then
                v:FindFirstChildOfClass("Highlight").FillColor = waifucolor
                v:FindFirstChildOfClass("Highlight").OutlineColor = waifucolor
            end
        end
    end
})
objectvisuals:AddSlider('waifuesptrans',{
    Min = 0,
    Max = 1,
    Rounding = 2,
    Default = waifutrans,
    Compact = true,
    Text = "waifu transparency",
    Callback = function(v) 
        waifutrans = v

        for _,v in waifufolder:GetChildren() do
            if v and v:FindFirstChildOfClass("Highlight") then
                v:FindFirstChildOfClass("Highlight").FillTransparency = waifutrans
                v:FindFirstChildOfClass("Highlight").OutlineTransparency = waifutrans
            end
        end
    end
})

objectvisuals:AddDivider()

-- ts beautiful gng😭👍
objectvisuals:AddToggle('playeresp',{
    Default = false,
    Text = "player esp",
    Callback = function(v)
        if v then
            playerespcon = game:GetService("Workspace").ChildAdded:Connect(function(p)
                for _,plr in game:GetService("Players"):GetPlayers() do -- v, p and plr ig bro
                    if p and plr and plr.Name == p.Name and p.Name ~= localplayer.Name then
                        if p and not p:FindFirstChildOfClass("Highlight") then
                            local high = Instance.new("Highlight")

                            high.Parent = p
                            high.Adornee = p
                            high.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            high.OutlineColor = playercolor
                            high.OutlineTransparency = playertrans
                            high.FillColor = playercolor
                            high.FillTransparency = playertrans
                        end
                    end
                end
            end)

            for _,p in game:GetService("Players"):GetPlayers() do
                if p and p.Character and p ~= localplayer then
                    if p and p.Character and p.Character:FindFirstChildOfClass("Highlight") then
                        p.Character:FindFirstChildOfClass("Highlight").Enabled = true
                    end 

                    if p and p.Character and not p.Character:FindFirstChildOfClass("Highlight") then
                        local high = Instance.new("Highlight")

                        high.Parent = p.Character
                        high.Adornee = p.Character
                        high.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        high.OutlineColor = playercolor
                        high.OutlineTransparency = playertrans
                        high.FillColor = playercolor
                        high.FillTransparency = playertrans
                    end 
                end
            end
        else
            for _,p in game:GetService("Players"):GetPlayers() do
                if p and p.Character then
                    if p and p.Character and p.Character:FindFirstChildOfClass("Highlight") then
                        p.Character:FindFirstChildOfClass("Highlight").Enabled = false
                    end 
                end
            end
        end
    end
})
objectvisuals:AddLabel('player color'):AddColorPicker('playercolor',{
    Title = "player color",
    Default =  playercolor,
    Callback = function(c)
        playercolor = c

        for _,v in game:GetService("Players"):GetPlayers() do
            if v and v.Character then
                if v and v.Character and v.Character:FindFirstChildOfClass("Highlight") then
                    v.Character:FindFirstChildOfClass("Highlight").FillColor = playercolor
                    v.Character:FindFirstChildOfClass("Highlight").OutlineColor = playercolor
                end 
            end
        end
    end
})
objectvisuals:AddSlider('playeresptrans',{
    Min = 0,
    Max = 1,
    Rounding = 2,
    Default = playertrans,
    Compact = true,
    Text = "player transparency",
    Callback = function(v) 
        playertrans = v

        for _,v in game:GetService("Players"):GetPlayers() do
            if v and v.Character then
                if v and v.Character and v.Character:FindFirstChildOfClass("Highlight") then
                    v.Character:FindFirstChildOfClass("Highlight").OutlineTransparency = playertrans
                    v.Character:FindFirstChildOfClass("Highlight").FillTransparency = playertrans
                end 
            end
        end
    end
})

objectvisuals:AddDivider()

objectvisuals:AddToggle('lootesp',{
    Default = false,
    Text = "loot esp",
    Callback = function(v)
        if v then
            for _,l in lootfolder:GetChildren() do
                if l and l:FindFirstChildOfClass("Highlight") then
                    l:FindFirstChildOfClass("Highlight").Enabled = true
                end

                if l and not l:FindFirstChildOfClass("Highlight") then
                    local high = Instance.new("Highlight")

                    high.Parent = l
                    high.Adornee = l
                    high.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    high.OutlineColor = lootcolor
                    high.OutlineTransparency = loottrans
                    high.FillColor = lootcolor
                    high.FillTransparency = loottrans
                end
            end

            lootespcon = lootfolder.ChildAdded:Connect(function(l)
                if l and not l:FindFirstChildOfClass("Highlight") then
                    local high = Instance.new("Highlight")

                    high.Parent = l
                    high.Adornee = l
                    high.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    high.OutlineColor = lootcolor
                    high.OutlineTransparency = loottrans
                    high.FillColor = lootcolor
                    high.FillTransparency = loottrans
                end
            end)
        else
            for _,l in lootfolder:GetChildren() do
                if l and l:FindFirstChildOfClass("Highlight") then
                    l:FindFirstChildOfClass("Highlight").Enabled = false
                end
            end

            if lootespcon then
                lootespcon:Disconnect()
                lootespcon = nil
            end
        end
    end
})
objectvisuals:AddLabel('loot color'):AddColorPicker('lootcolor',{
    Title = "loot color",
    Default =  lootcolor,
    Callback = function(c)
        lootcolor = c

        for _,v in lootfolder:GetChildren() do
            if v and v:FindFirstChildOfClass("Highlight") then
                v:FindFirstChildOfClass("Highlight").FillColor = lootcolor
                v:FindFirstChildOfClass("Highlight").OutlineColor = lootcolor
            end
        end
    end
})
objectvisuals:AddSlider('lootesptrans',{
    Min = 0,
    Max = 1,
    Rounding = 2,
    Default = loottrans,
    Compact = true,
    Text = "loot transparency",
    Callback = function(v) 
        loottrans = v

        for _,v in lootfolder:GetChildren() do
            if v and v:FindFirstChildOfClass("Highlight") then
                v:FindFirstChildOfClass("Highlight").FillTransparency = loottrans
                v:FindFirstChildOfClass("Highlight").OutlineTransparency = loottrans
            end
        end
    end
})

objectvisuals:AddDivider()

objectvisuals:AddToggle('ammoesp',{
    Default = false,
    Text = "ammo esp",
    Callback = function(v)
        if v then
            for _,a in ammofolder:GetChildren() do
                if a and a:FindFirstChildOfClass("Highlight") then
                    a:FindFirstChildOfClass("Highlight").Enabled = true
                end

                if a and not a:FindFirstChildOfClass("Highlight") then
                    local high = Instance.new("Highlight")

                    high.Parent = a
                    high.Adornee = a
                    high.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    high.OutlineColor = ammocolor
                    high.OutlineTransparency = ammotrans
                    high.FillColor = ammocolor
                    high.FillTransparency = ammotrans
                end
            end

            ammoespcon = ammofolder.ChildAdded:Connect(function(a)
                if a and not a:FindFirstChildOfClass("Highlight") then
                    local high = Instance.new("Highlight")

                    high.Parent = a
                    high.Adornee = a
                    high.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    high.OutlineColor = ammocolor
                    high.OutlineTransparency = ammotrans
                    high.FillColor = ammocolor
                    high.FillTransparency = ammotrans
                end
            end)
        else
            for _,a in ammofolder:GetChildren() do
                if a and a:FindFirstChildOfClass("Highlight") then
                    a:FindFirstChildOfClass("Highlight").Enabled = false
                end
            end

            if ammoespcon then
                ammoespcon:Disconnect()
                ammoespcon = nil
            end
        end
    end
})
objectvisuals:AddLabel('ammo color'):AddColorPicker('ammocolor',{
    Title = "ammo color",
    Default =  ammocolor,
    Callback = function(c)
        ammocolor = c

        for _,v in ammofolder:GetChildren() do
            if v and v:FindFirstChildOfClass("Highlight") then
                v:FindFirstChildOfClass("Highlight").FillColor = ammocolor
                v:FindFirstChildOfClass("Highlight").OutlineColor = ammocolor
            end
        end
    end
})
objectvisuals:AddSlider('ammoesptrans',{
    Min = 0,
    Max = 1,
    Rounding = 2,
    Default = ammotrans,
    Compact = true,
    Text = "ammo transparency",
    Callback = function(v) 
        ammotrans = v

        for _,v in ammofolder:GetChildren() do
            if v and v:FindFirstChildOfClass("Highlight") then
                v:FindFirstChildOfClass("Highlight").FillTransparency = ammotrans
                v:FindFirstChildOfClass("Highlight").OutlineTransparency = ammotrans
            end
        end
    end
})

objectvisuals:AddDivider()

objectvisuals:AddToggle('vehicleesp',{
    Default = false,
    Text = "vehicle esp",
    Callback = function(v)
        if v then
            for _,c in vehiclefolder:GetChildren() do
                if c and c:FindFirstChildOfClass("Highlight") then
                    c:FindFirstChildOfClass("Highlight").Enabled = true
                end

                if c and not c:FindFirstChildOfClass("Highlight") then
                    local high = Instance.new("Highlight")

                    high.Parent = c
                    high.Adornee = c
                    high.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    high.OutlineColor = vehiclecolor
                    high.OutlineTransparency = vehicletrans
                    high.FillColor = vehiclecolor
                    high.FillTransparency = vehicletrans
                end
            end

            vehicleespcon = vehiclefolder.ChildAdded:Connect(function(c)
                if c and not c:FindFirstChildOfClass("Highlight") then
                    local high = Instance.new("Highlight")

                    high.Parent = c
                    high.Adornee = c
                    high.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    high.OutlineColor = vehiclecolor
                    high.OutlineTransparency = vehicletrans
                    high.FillColor = vehiclecolor
                    high.FillTransparency = vehicletrans
                end
            end)
        else
            for _,c in vehiclefolder:GetChildren() do
                if c and c:FindFirstChildOfClass("Highlight") then
                    c:FindFirstChildOfClass("Highlight").Enabled = false
                end
            end

            if vehicleespcon then
                vehicleespcon:Disconnect()
                vehicleespcon = nil
            end
        end
    end
})
objectvisuals:AddLabel('vehicle color'):AddColorPicker('vehiclecolor',{
    Title = "vehicle color",
    Default =  vehiclecolor,
    Callback = function(c)
        vehiclecolor = c

        for _,v in vehiclefolder:GetChildren() do
            if v and v:FindFirstChildOfClass("Highlight") then
                v:FindFirstChildOfClass("Highlight").FillColor = vehiclecolor
                v:FindFirstChildOfClass("Highlight").OutlineColor = vehiclecolor
            end
        end
    end
})
objectvisuals:AddSlider('vehicleesptrans',{
    Min = 0,
    Max = 1,
    Rounding = 2,
    Default = vehicletrans,
    Compact = true,
    Text = "vehicle transparency",
    Callback = function(v) 
        vehicletrans = v

        for _,v in vehiclefolder:GetChildren() do
            if v and v:FindFirstChildOfClass("Highlight") then
                v:FindFirstChildOfClass("Highlight").FillTransparency = vehicletrans
                v:FindFirstChildOfClass("Highlight").OutlineTransparency = vehicletrans
            end
        end
    end
})


-- shitty cleanup method but it workie
library:OnUnload(function()
    silentaim = false

    for _,v in game:GetService("Players"):GetPlayers() do
        if v and v.Character then
            if v and v.Character and v.Character:FindFirstChildOfClass("Highlight") then
                v.Character:FindFirstChildOfClass("Highlight"):Destroy()
            end 
        end
    end

    for _,v in lootfolder:GetChildren() do
        if v and v:FindFirstChildOfClass("Highlight") then
            v:FindFirstChildOfClass("Highlight"):Destroy()
        end
    end

    for _,v in waifufolder:GetChildren() do
        if v and v:FindFirstChildOfClass("Highlight") then
            v:FindFirstChildOfClass("Highlight"):Destroy()
        end
    end

    for _,v in ammofolder:GetChildren() do
        if v and v:FindFirstChildOfClass("Highlight") then
            v:FindFirstChildOfClass("Highlight"):Destroy()
        end
    end

    for _,v in vehiclefolder:GetChildren() do
        if v and v:FindFirstChildOfClass("Highlight") then
            v:FindFirstChildOfClass("Highlight"):Destroy()
        end
    end

    if lootespcon then
        lootespcon:Disconnect()
        lootespcon = nil
    end

    if ammoespcon then
        ammoespcon:Disconnect()
        ammoespcon = nil
    end

    if vehicleespcon then
        vehicleespcon:Disconnect()
        vehicleespcon = nil
    end

    if waifuespcon then
        waifuespcon:Disconnect()
        waifuespcon = nil
    end

    if walkspeedcon then
        walkspeedcon:Disconnect()
        walkspeedcon = nil
    end

    if jumppowercon then
        jumppowercon:Disconnect()
        jumppowercon = nil
    end

    if infammocon then
        infammocon:Disconnect()
        infammocon = nil
    end

    if playerespcon then
        playerespcon:Disconnect()
        playerespcon = nil
    end

    if oldrun then
        for i,v in oldrun do
            setreadonly(i, false)
            i.HoldDownEnabled = v[1]
            setreadonly(i, true)
        end
    end

    if oldpenetration then
        for i,v in oldpenetration do
            setreadonly(i, false)
            i.PenetrationAmount = v[1]
            i.PenetrationDepth  = v[2]
            i.DamageThroughWall = v[3]
            i.IgnoreHumanoids   = v[4] 
            setreadonly(i, true)
        end
    end
    if oldrecoil then
        for i,v in oldrecoil do
            setreadonly(i, false)
            i.Recoil = v[1] 
            setreadonly(i, true)
        end
    end

    if oldammo then
        for i,v in oldammo do
            setreadonly(i, false)
            i.LimitedAmmoEnabled = v[2] 
            i.AmmoCost = v[1]
            setreadonly(i, true)
        end
    end

    if oldfirerate then
        for i,v in oldfirerate do
            setreadonly(i, false)
            i.FireRate = v[1] 
            i.MaximumFireRate = v[2]
            i.FireRateIncrement = v[3]
            i.DelayBeforeFiring = v[4]
            i.DelayAfterFiring = v[5]
            i.Auto = v[6]
            v.ChargingTime = v[7]
            v.ShotgunPumpinSpeed = v[8]
            v.LaserBeamStartupDelay = v[9]
            v.LaserBeamStopDelay = v[10]
            setreadonly(i, true)
        end
    end
    
    library.Unloaded = true
end)

local configgroupbox = tabs.config:AddRightGroupbox("Misc")

configgroupbox:AddLabel("Menu Keybind"):AddKeyPicker("menukeybind", { 
    Default = "Insert", 
    NoUI = true, 
    Text = "Menu Keybind" 
})
library.ToggleKeybind = options.menukeybind

configgroupbox:AddButton("Unload", function() library:Unload() end)

thememanager:SetLibrary(library)
savemanager:SetLibrary(library)
thememanager:SetFolder("aniphobia")
savemanager:SetFolder('aniphobia')
savemanager:BuildConfigSection(tabs.config)
thememanager:ApplyToTab(tabs.config)
savemanager:LoadAutoloadConfig()