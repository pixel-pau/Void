-- This script was created by Yusuf. If you intend to use this code to "skid," know this: skids only fool themselves; using someone else's code and passing it off as your own is for idiots.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local muscleEvent = player:WaitForChild("muscleEvent")
local leaderstats = player:WaitForChild("leaderstats")
local rebirthsStat = leaderstats:WaitForChild("Rebirths")
local rEvents = ReplicatedStorage:WaitForChild("rEvents")

_G.Players = game:GetService("Players")
_G.player = _G.Players.LocalPlayer
_G.VirtualInputManager = game:GetService("VirtualInputManager")
_G.ReplicatedStorage = game:GetService("ReplicatedStorage")
_G.muscleEvent = _G.player:WaitForChild("muscleEvent")
_G.leaderstats = _G.player:WaitForChild("leaderstats")
_G.rebirthsStat = _G.leaderstats:WaitForChild("Rebirths")
_G.rEvents = _G.ReplicatedStorage:WaitForChild("rEvents")


local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SynioxStudios/Syn-Paid-Ui/refs/heads/main/SynioxGui.txt"))()
_G.library = library 

local player = game.Players.LocalPlayer
_G.player = player 

local displayName = player.DisplayName
_G.displayName = displayName 

local window = library:AddWindow("Syniox Private | Muscle Legends || HI - ".. displayName, {
    title_bar = {
        Color3.fromRGB(180, 0, 255),
        Color3.fromRGB(60, 0, 100),
        Color3.fromRGB(0, 0, 0)
    }, 
    title_bar_transparency = 0.1, 
    background = {
        Color3.fromRGB(10, 5, 15),
        Color3.fromRGB(15, 10, 25),
        Color3.fromRGB(0, 0, 0)
    }, 
    background_transparency = 0.1, 
    main_color = Color3.fromRGB(104, 34, 139),
    min_size = Vector2.new(450, 300), 
    can_resize = true 
})
_G.window = window

local rebirthTab = window:AddTab("Fast Rebirth")

local petsFolder = player:WaitForChild("petsFolder")

local function formatNumber(num)
    if num >= 1e15 then return string.format("%.2fQa", num/1e15) end
    if num >= 1e12 then return string.format("%.2fT", num/1e12) end
    if num >= 1e9 then return string.format("%.2fB", num/1e9) end
    if num >= 1e6 then return string.format("%.2fM", num/1e6) end
    if num >= 1e3 then return string.format("%.2fK", num/1e3) end
    return string.format("%.0f", num)
end

local isRunning = false
local startTime = 0
local totalElapsed = 0
local initialRebirths = rebirthsStat.Value

local serverLabel = rebirthTab:AddLabel("📊 Stats:")
serverLabel.TextSize = 17
local timeLabel = rebirthTab:AddLabel("0d 0h 0m 0s - Inactive")
local paceLabel = rebirthTab:AddLabel("Rebirth Pace: /Hour | /Day | /Week")
local averagePaceLabel = rebirthTab:AddLabel("Average Rebirth Pace: /Hour | /Day | /Week")

paceLabel.TextSize = 15
averagePaceLabel.TextSize = 15
timeLabel.TextSize = 15
timeLabel.TextColor3 = Color3.fromRGB(255, 50, 50)

local rebirthsStatsLabel = rebirthTab:AddLabel("Rebirths: "..formatNumber(rebirthsStat.Value).." | Gained: 0")
rebirthsStatsLabel.TextSize = 15

local lastRebirthTime = tick()
local lastRebirthValue = rebirthsStat.Value

local function updateRebirthsLabel()
    local gained = rebirthsStat.Value - initialRebirths
    rebirthsStatsLabel.Text = string.format("Rebirths: %s | Gained: %s",
        formatNumber(rebirthsStat.Value),
        formatNumber(gained))
end

local function updateUI()
    local currentTime = tick()
    local elapsed = isRunning and (currentTime - startTime + totalElapsed) or totalElapsed

    local days = math.floor(elapsed / 86400)
    local hours = math.floor((elapsed % 86400) / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)
    local seconds = math.floor(elapsed % 60)

    local statusText = isRunning and "Rebirthing" or (elapsed > 0 and "Rebirthing Paused" or "Fast Reb Inactive")
    timeLabel.Text = string.format("%dd %dh %dm %ds - %s", days, hours, minutes, seconds, statusText)

    if isRunning then
        timeLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
    elseif elapsed > 0 then
        timeLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
    else
        timeLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

local paceHistoryHour = {}
local paceHistoryDay = {}
local paceHistoryWeek = {}
local maxHistoryLength = 20
local rebirthCount = 0
local savedPaceHour = 0
local savedPaceDay = 0
local savedPaceWeek = 0
local savedAvgHour = 0
local savedAvgDay = 0
local savedAvgWeek = 0

local function calculatePaceOnRebirth()
    rebirthCount = rebirthCount + 1
    if rebirthCount < 2 then
        lastRebirthTime = tick()
        lastRebirthValue = rebirthsStat.Value
        return
    end

    if not isRunning then return end

    local now = tick()
    local gained = rebirthsStat.Value - lastRebirthValue

    if gained > 0 then
        local avgTimePerRebirth = (now - lastRebirthTime) / gained
        local paceHour = 3600 / avgTimePerRebirth
        local paceDay = 86400 / avgTimePerRebirth
        local paceWeek = 604800 / avgTimePerRebirth

        savedPaceHour = paceHour
        savedPaceDay = paceDay
        savedPaceWeek = paceWeek

        paceLabel.Text = string.format("Pace: %s / Hour | %s / Day | %s / Week",
            formatNumber(paceHour), formatNumber(paceDay), formatNumber(paceWeek))

        table.insert(paceHistoryHour, paceHour)
        table.insert(paceHistoryDay, paceDay)
        table.insert(paceHistoryWeek, paceWeek)

        if #paceHistoryHour > maxHistoryLength then
            table.remove(paceHistoryHour, 1)
            table.remove(paceHistoryDay, 1)
            table.remove(paceHistoryWeek, 1)
        end

        local function average(tbl)
            local sum = 0
            for _, v in ipairs(tbl) do sum = sum + v end
            return #tbl > 0 and (sum / #tbl) or 0
        end

        local avgHour = average(paceHistoryHour)
        local avgDay = average(paceHistoryDay)
        local avgWeek = average(paceHistoryWeek)

        savedAvgHour = avgHour
        savedAvgDay = avgDay
        savedAvgWeek = avgWeek

        averagePaceLabel.Text = string.format("Average Pace: %s / Hour | %s / Day | %s / Week",
            formatNumber(avgHour), formatNumber(avgDay), formatNumber(avgWeek))

        lastRebirthTime = now
        lastRebirthValue = rebirthsStat.Value
    end
end

rebirthsStat:GetPropertyChangedSignal("Value"):Connect(function()
    calculatePaceOnRebirth()
    updateRebirthsLabel()
end)

local function managePets(petName)
    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.1)

    local uniqueFolder = petsFolder:FindFirstChild("Unique")
    if uniqueFolder then
        for _, pet in pairs(uniqueFolder:GetChildren()) do
            if pet.Name == petName then
                rEvents.equipPetEvent:FireServer("equipPet", pet)
            end
        end
    end
end

local function doRebirth()
    local rebirths = rebirthsStat.Value
    local strengthTarget = 5000 + (rebirths * 2550)

    while isRunning and leaderstats.Strength.Value < strengthTarget do
        local reps = player.MembershipType == Enum.MembershipType.Premium and 12 or 20
        for _ = 1, reps do
            muscleEvent:FireServer("rep")
        end
        task.wait(0.02)
    end

    if isRunning and leaderstats.Strength.Value >= strengthTarget then
        managePets("Tribal Overlord")
        task.wait(0.25)

        local before = rebirthsStat.Value
        repeat
            rEvents.rebirthRemote:InvokeServer("rebirthRequest")
            task.wait(0.05)
        until rebirthsStat.Value > before or not isRunning
    end
end

local function fastRebirthLoop()
    while isRunning do
        managePets("Swift Samurai")
        doRebirth()
        task.wait(0.5)
    end
end

rebirthTab:AddLabel("")
rebirthTab:AddLabel("🔄️ Rebirth:").TextSize = 17

rebirthTab:AddSwitch("Fast Rebirth", function(state)
    isRunning = state

    if state then
        startTime = tick()
        if savedPaceHour > 0 then
            paceLabel.Text = string.format("Pace: %s / Hour | %s / Day | %s / Week",
                formatNumber(savedPaceHour), formatNumber(savedPaceDay), formatNumber(savedPaceWeek))
            averagePaceLabel.Text = string.format("Average Pace: %s / Hour | %s / Day | %s / Week",
                formatNumber(savedAvgHour), formatNumber(savedAvgDay), formatNumber(savedAvgWeek))
        end
        task.spawn(fastRebirthLoop)
    else
        totalElapsed = totalElapsed + (tick() - startTime)
        updateUI()
    end
end)

task.spawn(function()
    while true do
        updateUI()
        task.wait(0.1)
    end
end)

rebirthTab:AddButton("🏋️‍♂️ Jungle Lift", function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-8666, 34, 2070)
        task.wait(0.5)
        local machine = findMachine("Jungle Bar Lift")
        if machine and machine:FindFirstChild("interactSeat") then
            local retryCount = 0
            repeat
                task.wait(0.2)
                pressE()
                retryCount = retryCount + 1
            until (player.Character and player.Character.Humanoid.Sit) or retryCount > 10
        end
    end
end)

_G.StrTab = _G.window:AddTab("Fast Strength")

function _G.formatNumber(num)
    if num >= 1e15 then return string.format("%.2fQa", num/1e15) end
    if num >= 1e12 then return string.format("%.2fT", num/1e12) end
    if num >= 1e9 then return string.format("%.2fB", num/1e9) end
    if num >= 1e6 then return string.format("%.2fM", num/1e6) end
    if num >= 1e3 then return string.format("%.2fK", num/1e3) end
    return string.format("%.0f", num)
end

_G.strengthStat = _G.leaderstats:WaitForChild("Strength")
_G.durabilityStat = _G.player:FindFirstChild("Durability") or _G.leaderstats:FindFirstChild("Durability")
if not _G.durabilityStat then
    _G.durabilityStat = Instance.new("IntValue")
    _G.durabilityStat.Name = "Durability"
    _G.durabilityStat.Parent = _G.player
    _G.durabilityStat.Value = 0
end

_G.StrTab:AddLabel("📊 Stats:").TextSize = 17
_G.stopwatchLabel = _G.StrTab:AddLabel("0d 0h 0m 0s - Fast Rep Inactive")
_G.stopwatchLabel.TextSize = 15
_G.stopwatchLabel.TextColor3 = Color3.fromRGB(255, 50, 50)

_G.projectedStrengthLabel = _G.StrTab:AddLabel("Strength: /Hour | /Day | /Week")
_G.projectedStrengthLabel.TextSize = 15
_G.averageStrengthLabel = _G.StrTab:AddLabel("Average: /Hour | /Day | /Week")
_G.averageStrengthLabel.TextSize = 15
_G.projectedDurabilityLabel = _G.StrTab:AddLabel("Dura: /Hour | /Day | /Week")
_G.projectedDurabilityLabel.TextSize = 15
_G.averageDurabilityLabel = _G.StrTab:AddLabel("Average: /Hour | /Day | /Week")
_G.averageDurabilityLabel.TextSize = 15
_G.StrTab:AddLabel("")

_G.strengthLabel = _G.StrTab:AddLabel("Strength: " .. _G.formatNumber(_G.strengthStat.Value) .. " | Gained: 0")
_G.strengthLabel.TextSize = 15
_G.durabilityLabel = _G.StrTab:AddLabel("Durability: " .. _G.formatNumber(_G.durabilityStat.Value) .. " | Gained: 0")
_G.durabilityLabel.TextSize = 15

_G.startTime = 0
_G.pausedElapsedTime = 0

_G.runFastRep = false
_G.trackingStarted = false

_G.strengthHistory = {}
_G.durabilityHistory = {}
_G.calculationInterval = 10

_G.initialStrength = _G.strengthStat.Value
_G.initialDurability = _G.durabilityStat.Value

_G.savedStrengthPerHour = 0
_G.savedStrengthPerDay = 0
_G.savedStrengthPerWeek = 0
_G.savedDurabilityPerHour = 0
_G.savedDurabilityPerDay = 0
_G.savedDurabilityPerWeek = 0

_G.savedAvgStrengthPerHour = 0
_G.savedAvgStrengthPerDay = 0
_G.savedAvgStrengthPerWeek = 0
_G.savedAvgDurabilityPerHour = 0
_G.savedAvgDurabilityPerDay = 0
_G.savedAvgDurabilityPerWeek = 0

task.spawn(function()
    local lastCalcTime = tick()
    while true do
        local currentTime = tick()
        local currentStrength = _G.strengthStat.Value
        local currentDurability = _G.durabilityStat.Value

        _G.strengthLabel.Text = "Strength: " .. _G.formatNumber(currentStrength) .. " | Gained: " .. _G.formatNumber(currentStrength - _G.initialStrength)
        _G.durabilityLabel.Text = "Durability: " .. _G.formatNumber(currentDurability) .. " | Gained: " .. _G.formatNumber(currentDurability - _G.initialDurability)

        if _G.runFastRep then
            if not _G.trackingStarted then
                _G.trackingStarted = true
                _G.startTime = currentTime
                _G.strengthHistory = {}
                _G.durabilityHistory = {}
                
                if _G.savedStrengthPerHour > 0 then
                    _G.projectedStrengthLabel.Text = "Strength: " .. _G.formatNumber(_G.savedStrengthPerHour) .. "/Hour | " .. _G.formatNumber(_G.savedStrengthPerDay) .. "/Day | " .. _G.formatNumber(_G.savedStrengthPerWeek) .. "/Week"
                    _G.projectedDurabilityLabel.Text = "Dura: " .. _G.formatNumber(_G.savedDurabilityPerHour) .. "/Hour | " .. _G.formatNumber(_G.savedDurabilityPerDay) .. "/Day | " .. _G.formatNumber(_G.savedDurabilityPerWeek) .. "/Week"
                    _G.averageStrengthLabel.Text = "Average: " .. _G.formatNumber(_G.savedAvgStrengthPerHour) .. "/Hour | " .. _G.formatNumber(_G.savedAvgStrengthPerDay) .. "/Day | " .. _G.formatNumber(_G.savedAvgStrengthPerWeek) .. "/Week"
                    _G.averageDurabilityLabel.Text = "Average: " .. _G.formatNumber(_G.savedAvgDurabilityPerHour) .. "/Hour | " .. _G.formatNumber(_G.savedAvgDurabilityPerDay) .. "/Day | " .. _G.formatNumber(_G.savedAvgDurabilityPerWeek) .. "/Week"
                end
            end
            
            local elapsedTime = _G.pausedElapsedTime + (currentTime - _G.startTime)
            local days = math.floor(elapsedTime / (24 * 3600))
            local hours = math.floor((elapsedTime % (24 * 3600)) / 3600)
            local minutes = math.floor((elapsedTime % 3600) / 60)
            local seconds = math.floor(elapsedTime % 60)
            _G.stopwatchLabel.Text = string.format("%dd %dh %dm %ds - Farming", days, hours, minutes, seconds)
            _G.stopwatchLabel.TextColor3 = Color3.fromRGB(50, 255, 50)

            table.insert(_G.strengthHistory, {time = currentTime, value = currentStrength})
            table.insert(_G.durabilityHistory, {time = currentTime, value = currentDurability})

            while #_G.strengthHistory > 0 and currentTime - _G.strengthHistory[1].time > _G.calculationInterval do
                table.remove(_G.strengthHistory, 1)
            end
            while #_G.durabilityHistory > 0 and currentTime - _G.durabilityHistory[1].time > _G.calculationInterval do
                table.remove(_G.durabilityHistory, 1)
            end

            if currentTime - lastCalcTime >= _G.calculationInterval then
                lastCalcTime = currentTime

                if #_G.strengthHistory >= 2 then
                    local strengthDelta = _G.strengthHistory[#_G.strengthHistory].value - _G.strengthHistory[1].value
                    local strengthPerSecond = strengthDelta / _G.calculationInterval
                    _G.savedStrengthPerHour = strengthPerSecond * 3600
                    _G.savedStrengthPerDay = strengthPerSecond * 86400
                    _G.savedStrengthPerWeek = strengthPerSecond * 604800
                    _G.projectedStrengthLabel.Text = "Strength: " .. _G.formatNumber(_G.savedStrengthPerHour) .. "/Hour | " .. _G.formatNumber(_G.savedStrengthPerDay) .. "/Day | " .. _G.formatNumber(_G.savedStrengthPerWeek) .. "/Week"
                end

                if #_G.durabilityHistory >= 2 then
                    local durabilityDelta = _G.durabilityHistory[#_G.durabilityHistory].value - _G.durabilityHistory[1].value
                    local durabilityPerSecond = durabilityDelta / _G.calculationInterval
                    _G.savedDurabilityPerHour = durabilityPerSecond * 3600
                    _G.savedDurabilityPerDay = durabilityPerSecond * 86400
                    _G.savedDurabilityPerWeek = durabilityPerSecond * 604800
                    _G.projectedDurabilityLabel.Text = "Dura: " .. _G.formatNumber(_G.savedDurabilityPerHour) .. "/Hour | " .. _G.formatNumber(_G.savedDurabilityPerDay) .. "/Day | " .. _G.formatNumber(_G.savedDurabilityPerWeek) .. "/Week"
                end

                local totalElapsed = _G.pausedElapsedTime + (currentTime - _G.startTime)
                if totalElapsed > 0 then
                    local avgStrengthPerSecond = (currentStrength - _G.initialStrength) / totalElapsed
                    _G.savedAvgStrengthPerHour = avgStrengthPerSecond * 3600
                    _G.savedAvgStrengthPerDay = avgStrengthPerSecond * 86400
                    _G.savedAvgStrengthPerWeek = avgStrengthPerSecond * 604800
                    _G.averageStrengthLabel.Text = "Average: " .. _G.formatNumber(_G.savedAvgStrengthPerHour) .. "/Hour | " .. _G.formatNumber(_G.savedAvgStrengthPerDay) .. "/Day | " .. _G.formatNumber(_G.savedAvgStrengthPerWeek) .. "/Week"

                    local avgDurabilityPerSecond = (currentDurability - _G.initialDurability) / totalElapsed
                    _G.savedAvgDurabilityPerHour = avgDurabilityPerSecond * 3600
                    _G.savedAvgDurabilityPerDay = avgDurabilityPerSecond * 86400
                    _G.savedAvgDurabilityPerWeek = avgDurabilityPerSecond * 604800
                    _G.averageDurabilityLabel.Text = "Average: " .. _G.formatNumber(_G.savedAvgDurabilityPerHour) .. "/Hour | " .. _G.formatNumber(_G.savedAvgDurabilityPerDay) .. "/Day | " .. _G.formatNumber(_G.savedAvgDurabilityPerWeek) .. "/Week"
                end
            end
        else
            if _G.trackingStarted then
                _G.trackingStarted = false
                _G.pausedElapsedTime = _G.pausedElapsedTime + (currentTime - _G.startTime)
                local days = math.floor(_G.pausedElapsedTime / (24 * 3600))
                local hours = math.floor((_G.pausedElapsedTime % (24 * 3600)) / 3600)
                local minutes = math.floor((_G.pausedElapsedTime % 3600) / 60)
                local seconds = math.floor(_G.pausedElapsedTime % 60)
                
                if _G.pausedElapsedTime > 0 then
                    _G.stopwatchLabel.Text = string.format("%dd %dh %dm %ds - Farming Paused", days, hours, minutes, seconds)
                    _G.stopwatchLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                else
                    _G.stopwatchLabel.Text = "0d 0h 0m 0s - Fast Rep Inactive"
                    _G.stopwatchLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                end

                _G.strengthHistory = {}
                _G.durabilityHistory = {}
            end
        end

        task.wait(0.05)
    end
end)

_G.StrTab:AddLabel("")
_G.StrTab:AddLabel("⚡ Fast Farm:").TextSize = 17
_G.farmRunning = false
_G.repSpeed = 350
_G.pingControl = true

_G.networkStats = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]

function _G.getCurrentPing()
    return _G.networkStats:GetValue()
end

function _G.getAdaptiveSpeed(ping)
    if ping < 80 then
        return 500
    elseif ping < 150 then
        return 300
    elseif ping < 250 then
        return 100
    else
        return 50
    end
end

_G.StrTab:AddTextBox("Rep Speed:", function(inputText)
    local speedValue = tonumber(inputText)
    if speedValue then
        _G.repSpeed = math.clamp(math.floor(speedValue), 1, 1000)
    end
end)

_G.StrTab:AddSwitch("Controlled Speed", function(isEnabled)
    _G.pingControl = isEnabled
end):Set(true)

function _G.startAutoRep()
    local lastPingUpdate = time()
    local currentPing = _G.getCurrentPing()
    while _G.farmRunning do
        if time() - lastPingUpdate > 0.5 then
            currentPing = _G.getCurrentPing()
            lastPingUpdate = time()
        end
        local repsToFire = _G.pingControl and _G.getAdaptiveSpeed(currentPing) or _G.repSpeed
        local delayBetweenBatches = math.clamp(currentPing / 2500, 0.001, 0.1)
        for repCount = 1, math.min(repsToFire, _G.repSpeed) do
            _G.muscleEvent:FireServer("rep")
            if repCount % 500 == 0 then
                task.wait(0)
            end
        end
        task.wait(delayBetweenBatches)
    end
end

_G.StrTab:AddSwitch("Fast Rep", function(isEnabled)
    _G.farmRunning = isEnabled
    if _G.farmRunning then
        _G.runFastRep = true
        task.spawn(_G.startAutoRep)
    else 
        _G.runFastRep = false
    end
end)

_G.StrTab:AddButton("🌴 Jungle Squat", function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-8377.55, 48.71, 2864.90)
        task.wait(0.5)
        local machine = findMachine("Jungle Squat Rack") or findMachine("Squat Rack")
        if machine and machine:FindFirstChild("interactSeat") then
            local retry = 0
            repeat task.wait(0.2); pressE(); retry = retry + 1 until (player.Character and player.Character.Humanoid.Sit) or retry > 10
        end
    end
end)

_G.StrTab:AddButton("🏋️‍♂️ Jungle Lift", function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-8666, 34, 2070)
        task.wait(0.5)
        local machine = findMachine("Jungle Bar Lift")
        if machine and machine:FindFirstChild("interactSeat") then
            local retryCount = 0
            repeat
                task.wait(0.2)
                pressE()
                retryCount = retryCount + 1
            until (player.Character and player.Character.Humanoid.Sit) or retryCount > 10
        end
    end
end)

_G.StrTab:AddButton("🐱 Equip Swift Samurai", function()
    local petsFolder = player.petsFolder
    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.2)

    local petsToEquip = {}
    for _, pet in pairs(player.petsFolder.Unique:GetChildren()) do
        if pet.Name == "Swift Samurai" then
            table.insert(petsToEquip, pet)
        end
    end

    for i = 1, math.min(8, #petsToEquip) do
        rEvents.equipPetEvent:FireServer("equipPet", petsToEquip[i])
        task.wait(0.1)
    end
end)

local AutoFarm = window:AddTab("Farm")
AutoFarm:AddLabel("Tools Farm")

local repsPerTick = 1

AutoFarm:AddTextBox("🚀 Thread Speed", function(value)
    local num = tonumber(value)
    if num and num > 0 then 
        repsPerTick = math.floor(num)
    else
        repsPerTick = 1
    end
end, {placeholder = "Enter Amount (Default: 1)"})

_G.repToggle = false
AutoFarm:AddSwitch("💪 Auto Farm (Equip Any tool)", function(state)
    _G.repToggle = state
    task.spawn(function()
        while _G.repToggle do
            local event = game:GetService("Players").LocalPlayer:FindFirstChild("muscleEvent")
            if event then
                for i = 1, repsPerTick do
                    if not _G.repToggle then break end
                    event:FireServer("rep")
                end
            end
            task.wait(0.01)
        end
    end)
end)

local function manageTool(toolName)
    task.spawn(function()
        while _G[toolName.."On"] do
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                local tool = player.Backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)
                
                if tool then
                    if tool.Parent ~= character then
                        tool.Parent = character
                    end
                    
                    local event = player:FindFirstChild("muscleEvent")
                    if event then
                        for i = 1, repsPerTick do
                            if not _G[toolName.."On"] then break end
                            event:FireServer("rep")
                        end
                    else
                        tool:Activate()
                    end
                end
            end
            task.wait(0.01)
        end
    end)
end

AutoFarm:AddSwitch("🏋️ Weight", function(bool)
    _G.WeightOn = bool
    if bool then manageTool("Weight") end
end)

AutoFarm:AddSwitch("💪 Pushups", function(bool)
    _G.PushupsOn = bool
    if bool then manageTool("Pushups") end
end)

AutoFarm:AddSwitch("🤸 Handstands", function(bool)
    _G.HandstandsOn = bool
    if bool then manageTool("Handstands") end
end)

AutoFarm:AddSwitch("🧘 Situps", function(bool)
    _G.SitupsOn = bool
    if bool then manageTool("Situps") end
end)

AutoFarm:AddLabel("----------------------------")
AutoFarm:AddLabel("💨 Treadmill Farm")

local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local Locations = {
    {name = "🌿 Jungle Treadmill +8 xp", pos = Vector3.new(-8131.86, 25.77, 2818.17)},
    {name = "🔱 Legends Treadmill +7 xp", pos = Vector3.new(4365.82, 997.14, -3632.9)},
    {name = "✨ Mythical Treadmill +6 xp", pos = Vector3.new(2661.67, 19.41, 932.09)},
    {name = "🏠 Spawn Treadmill +5 xp", pos = Vector3.new(-230.43, 8.16, -102.18)},
    {name = "👟 Tiny Treadmill +1 xp", pos = Vector3.new(55.64, 5.16, 1947.60)}
}

local posLockConnection = nil

local function lockAndSimulate(targetCFrame)
    if posLockConnection then posLockConnection:Disconnect() end
    posLockConnection = RunService.Heartbeat:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = targetCFrame
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
        end
    end)
end

local function stopAll()
    if posLockConnection then
        posLockConnection:Disconnect()
        posLockConnection = nil
    end
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
end

for _, loc in ipairs(Locations) do
    AutoFarm:AddSwitch(loc.name, function(bool)
        if bool then
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(loc.pos + Vector3.new(0, 3, 0))
                task.wait(0.3)
                lockAndSimulate(hrp.CFrame)
            end
        else
            stopAll()
        end
    end)
end

AutoFarm:AddLabel("----------------------------")
AutoFarm:AddLabel("🌴 Jungle Gym Farm")

local VIM = game:GetService("VirtualInputManager")

local function pressEKey()
    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.01)
    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function startJungleFarm(toggleName, cframeValue, eventName)
    local active = false
    AutoFarm:AddSwitch(toggleName, function(bool)
        active = bool
        if bool then
            task.spawn(function()
                while active do
                    local char = game.Players.LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if root then
                        if (root.Position - cframeValue.p).Magnitude > 5 then
                            root.CFrame = cframeValue
                            task.wait(0.3)
                            pressEKey()
                        end
                        
                        game:GetService("Players").LocalPlayer.muscleEvent:FireServer(eventName)
                    end
                    task.wait(0.01)
                end
            end)
        end
    end)
end

startJungleFarm("🌴 Auto Jungle Lift", CFrame.new(-8652.85, 45.22, 2088.99), "rep")
startJungleFarm("🏋️ Auto Bench Press", CFrame.new(-8173.23, 83.82, 1907.40), "rep")
startJungleFarm("🦵 Auto Squat", CFrame.new(-8377.55, 48.71, 2864.90), "rep")
startJungleFarm("💢 Auto Boulder", CFrame.new(-8614.81, 51.90, 2677.37), "rep")

AutoFarm:AddLabel("----------------------------")
AutoFarm:AddLabel("⚡ OP Tools")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function manageToolCombo(toolName)
    task.spawn(function()
        while _G[toolName.."On"] do
            local character = LocalPlayer.Character
            local hum = character and character:FindFirstChildOfClass("Humanoid")
            
            if character and hum then
                local punch = LocalPlayer.Backpack:FindFirstChild("Punch") or character:FindFirstChild("Punch")
                local tool = LocalPlayer.Backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)

                if punch then
                    if punch.Parent ~= character then
                        hum:EquipTool(punch)
                    end
                    if punch:FindFirstChild("attackTime") then 
                        punch.attackTime.Value = 0 
                    end
                    punch:Activate()
                end

                if tool then
                    if tool.Parent ~= character then
                        hum:EquipTool(tool)
                    end
                    
                    local event = LocalPlayer:FindFirstChild("muscleEvent")
                    if event then 
                        event:FireServer("rep") 
                    end
                    tool:Activate()
                end
            end
            task.wait(0.01)
        end
    end)
end

AutoFarm:AddSwitch("🏋️ Weight + 🥊 Punch", function(bool)
    _G.WeightOn = bool
    if bool then manageToolCombo("Weight") end
end)

AutoFarm:AddSwitch("💪 Pushups + 🥊 Punch", function(bool)
    _G.PushupsOn = bool
    if bool then manageToolCombo("Pushups") end
end)

AutoFarm:AddSwitch("🤸 Handstand + 🥊 Punch", function(bool)
    _G.HandstandOn = bool
    if bool then manageToolCombo("Handstand") end
end)

AutoFarm:AddSwitch("🧘 Situps + 🥊 Punch", function(bool)
    _G.SitupsOn = bool
    if bool then manageToolCombo("Situps") end
end)

AutoFarm:AddLabel("----------------------------")
AutoFarm:AddLabel("💢 Brawl")

local autoBrawl = false
local godModeToggle = false
local autoWinBrawl = false
local parts = {}

local function manageParts(state)
    if state and #parts == 0 then
        local partSize = 2048
        local totalDistance = 50000
        local startPosition = Vector3.new(-2, -9.5, -2)
        local numberOfParts = math.ceil(totalDistance / partSize)
        for x = 0, numberOfParts - 1 do
            for z = 0, numberOfParts - 1 do
                local positions = {
                    startPosition + Vector3.new(x * partSize, 0, z * partSize),
                    startPosition + Vector3.new(-x * partSize, 0, z * partSize),
                    startPosition + Vector3.new(-x * partSize, 0, -z * partSize),
                    startPosition + Vector3.new(x * partSize, 0, -z * partSize)
                }
                for _, pos in ipairs(positions) do
                    local p = Instance.new("Part")
                    p.Size = Vector3.new(partSize, 1, partSize)
                    p.Position = pos
                    p.Anchored = true
                    p.Transparency = 1
                    p.CanCollide = true
                    p.Parent = workspace
                    table.insert(parts, p)
                end
            end
        end
    elseif not state then
        for _, p in ipairs(parts) do p.CanCollide = false end
    else
        for _, p in ipairs(parts) do p.CanCollide = true end
    end
end

AutoFarm:AddLabel("----------------------------")
AutoFarm:AddLabel("👊 Auto Brawl")

AutoFarm:AddSwitch("🏆 Auto Join Brawl", function(state)
    autoBrawl = state
    task.spawn(function()
        while autoBrawl do
            game:GetService("ReplicatedStorage").rEvents.brawlEvent:FireServer("joinBrawl")
            task.wait(5)
        end
    end)
end)

AutoFarm:AddSwitch("🛡️ God Mode", function(state)
    godModeToggle = state
    manageParts(state)
    if state then
        task.spawn(function()
            while godModeToggle do
                game:GetService("ReplicatedStorage").rEvents.brawlEvent:FireServer("joinBrawl")
                task.wait(0)
            end
        end)
    end
end)

AutoFarm:AddSwitch("⚔️ Auto Win Brawl", function(state)
    autoWinBrawl = state
    if state then
        task.spawn(function()
            while autoWinBrawl do
                local lp = game:GetService("Players").LocalPlayer
                local char = lp.Character
                if char then
                    local punch = lp.Backpack:FindFirstChild("Punch") or char:FindFirstChild("Punch")
                    if punch then
                        punch.Parent = char
                        if punch:FindFirstChild("attackTime") then
                            punch.attackTime.Value = 0
                        end
                        punch:Activate()
                    end
                    
                    local rHand = char:FindFirstChild("RightHand")
                    local lHand = char:FindFirstChild("LeftHand")
                    if rHand and lHand then
                        for _, target in ipairs(game:GetService("Players"):GetPlayers()) do
                            if target ~= lp and target.Character then
                                local root = target.Character:FindFirstChild("HumanoidRootPart")
                                if root then
                                    pcall(function()
                                        firetouchinterest(rHand, root, 1)
                                        firetouchinterest(lHand, root, 1)
                                        firetouchinterest(rHand, root, 0)
                                        firetouchinterest(lHand, root, 0)
                                    end)
                                end
                            end
                        end
                    end
                end
                task.wait()
            end
        end)
    end
end)

local rebirths = window:AddTab("Rebirths")

rebirths:AddTextBox("🔢 Rebirth Target", function(text)
    local newValue = tonumber(text)
    if newValue and newValue > 0 then
        targetRebirthValue = newValue
        updateStats() 
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Updated Goal",
            Text = "New goal: " .. tostring(targetRebirthValue) .. " rebirths",
            Duration = 0
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Size",
            Text = "Put a size larger than 0",
            Duration = 0
        })
    end
end)

local infiniteSwitch

local targetSwitch = rebirths:AddSwitch("🔄 Auto Rebirth Target", function(bool)
    _G.targetRebirthActive = bool
    
    if bool then
        if _G.infiniteRebirthActive and infiniteSwitch then
            infiniteSwitch:Set(false)
            _G.infiniteRebirthActive = false
        end
        
        spawn(function()
            while _G.targetRebirthActive and wait(0.1) do
                local currentRebirths = game.Players.LocalPlayer.leaderstats.Rebirths.Value
                
                if currentRebirths >= targetRebirthValue then
                    targetSwitch:Set(false)
                    _G.targetRebirthActive = false
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Goal Reached",
                        Text = "You Have Reached" .. tostring(targetRebirthValue) .. " renacimientos",
                        Duration = 5
                    })
                    
                    break
						end
						
                game:GetService("ReplicatedStorage").rEvents.rebirthRemote:InvokeServer("rebirthRequest")
            end
        end)
    end
end, "automatic rebirth until reaching the goal")

infiniteSwitch = rebirths:AddSwitch("♾️ Auto Rebirth (Infinitely)", function(bool)
    _G.infiniteRebirthActive = bool
    
    if bool then
        if _G.targetRebirthActive and targetSwitch then
            targetSwitch:Set(false)
            _G.targetRebirthActive = false
        end
        
        spawn(function()
            while _G.infiniteRebirthActive and wait(0.1) do
                game:GetService("ReplicatedStorage").rEvents.rebirthRemote:InvokeServer("rebirthRequest")
            end
        end)
    end
end, "rebirth infinitely")

local sizeSwitch = rebirths:AddSwitch("Auto Size 1📏", function(bool)
    _G.autoSizeActive = bool
    
    if bool then
        spawn(function()
            while _G.autoSizeActive and wait() do
                game:GetService("ReplicatedStorage").rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 1)
            end
        end)
    end
end, "Size 1")

local sizeSwitch = rebirths:AddSwitch("Auto Size 2📏", function(bool)
    _G.autoSizeActive = bool
    
    if bool then
        spawn(function()
            while _G.autoSizeActive and wait() do
                game:GetService("ReplicatedStorage").rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 2)
            end
        end)
    end
end, "Size 2")

local teleportSwitch = rebirths:AddSwitch("👑 Auto Teleport to Muscle King", function(bool)
    _G.teleportActive = bool
    
    if bool then
        spawn(function()
            while _G.teleportActive and wait() do
                if game.Players.LocalPlayer.Character then
                    game.Players.LocalPlayer.Character:MoveTo(Vector3.new(-8771, 85, -5830))
                end
            end
        end)
    end
end, "Tp to Mk")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rEvents = ReplicatedStorage:WaitForChild("rEvents")
local muscleEvent = rEvents:WaitForChild("muscleEvent")

local function useProteinEgg()
    local boost = player:FindFirstChild("boostTimersFolder") and player.boostTimersFolder:FindFirstChild("Protein Egg")
    if boost and boost:IsA("IntValue") then
        if boost.Value >= 5 then
            return
        end
    end
    
    local tool = player.Character:FindFirstChild("Protein Egg") or player.Backpack:FindFirstChild("Protein Egg")
    if tool then
        muscleEvent:FireServer("proteinEgg", tool)
    end
end

task.spawn(function()
    while true do
        if autoEat30Enabled then
            useProteinEgg()
            task.wait(1800)
        else
            task.wait(1)
        end
    end
end)

rebirths:AddSwitch("🥚 Auto Eat Egg 30 Min", function(state)
    autoEat30Enabled = state
    if state then
        useProteinEgg()
    end
end)

task.spawn(function()
    while true do
        if autoEat60Enabled then
            useProteinEgg()
            task.wait(3600)
        else
            task.wait(1)
        end
    end
end)

rebirths:AddSwitch("🥚 Auto Eat Egg 60 Min", function(state)
    autoEat60Enabled = state
    if state then
        useProteinEgg()
    end
end)

rebirths:AddSwitch("👁️‍🗨️ Hide All Frames", function(bool)
    local rSto = game:GetService("ReplicatedStorage")
    for _, obj in pairs(rSto:GetChildren()) do
        if obj.Name:match("Frame$") then
            obj.Visible = not bool
        end
    end
end)

local selectedUltimate = nil
local autoBuyActive = false
local ultimateRemote = game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("ultimatesRemote")

local upgradeDropdown = rebirths:AddDropdown("📦 Select Ultımate", function(choice)
    selectedUltimate = choice
end)

local items = {
    "RepSpeed", "PetSlot", "ItemCapacity", "DailySpin", 
    "ChestRewards", "QuestRewards", "MuscleMind", "JungleSwift", 
    "InfernalHealth", "GalaxyGains", "DemonDamage", "GoldenRebirth"
}

for _, itemName in ipairs(items) do
    upgradeDropdown:Add(itemName)
end

rebirths:AddSwitch("🔄 Auto Buy Selected", function(state)
    autoBuyActive = state
    if autoBuyActive then
        task.spawn(function()
            while autoBuyActive do
                if selectedUltimate then
                    pcall(function()
                        ultimateRemote:InvokeServer("upgradeUltimate", selectedUltimate)
                    end)
                end
                task.wait(0.5)
            end
        end)
    end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Kill = window:AddTab("Kill")

local playerWhitelist = {}
local targetPlayerNames = {}
local selectedFollowTarget = nil
_G.FollowToTarget = false
local autoGoodKarma = false
local autoBadKarma = false
local autoEquipPunch = false
local autoPunchNoAnim = false
local RemoveAnimActive = false

Kill:AddLabel("Misc")

local spyTargetDropdown = Kill:AddDropdown("👀 Select View Target", function(name)
    targetPlayerName = name
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        spyTargetDropdown:Add(player.Name)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        spyTargetDropdown:Add(player.Name)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player ~= LocalPlayer then
        spyTargetDropdown:Clear()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                spyTargetDropdown:Add(plr.Name)
            end
        end
    end
end)

Kill:AddSwitch("👀 View Player", function(bool)
    spying = bool
    if not spying then
        local cam = workspace.CurrentCamera
        cam.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") or LocalPlayer
        return
    end
    task.spawn(function()
        while spying do
            local target = Players:FindFirstChild(targetPlayerName)
            if target and target ~= LocalPlayer then
                local humanoid = target.Character and target.Character:FindFirstChild("Humanoid")
                if humanoid then
                    workspace.CurrentCamera.CameraSubject = humanoid
                end
            end
            task.wait(0.1)
        end
    end)
end)

local followDropdown = Kill:AddDropdown("👤 Select Follow Target", function(name)
    selectedFollowTarget = name
    _G.FollowToTarget = true
    
    task.spawn(function()
        while _G.FollowToTarget and selectedFollowTarget == name do
            local t = game.Players:FindFirstChild(selectedFollowTarget)
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and myHRP then
                myHRP.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2.5)
            end
            task.wait()
        end
    end)
end)

Kill:AddButton("⛔ Stop Follow", function()
    _G.FollowToTarget = false
    selectedFollowTarget = nil
end)

local function updateFollowDropdown(p)
    if p ~= LocalPlayer then
        followDropdown:Add(p.Name)
    end
end

for _, p in ipairs(game.Players:GetPlayers()) do updateFollowDropdown(p) end
game.Players.PlayerAdded:Connect(updateFollowDropdown)

Kill:AddLabel("----------------------------")
Kill:AddLabel("🥊 Combat Tweaks")

local blockedAnimations = {
    ["rbxassetid://3638729053"] = true,
    ["rbxassetid://3638767427"] = true,
}

local function setupAnimationBlocking()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return end

    local humanoid = char:FindFirstChild("Humanoid")

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation then
            local animId = track.Animation.AnimationId
            local animName = track.Name:lower()

            if blockedAnimations[animId] or animName:match("punch") or animName:match("attack") or animName:match("right") then
                track:Stop()
            end
        end
    end

    if not _G.AnimBlockConnection then
        _G.AnimBlockConnection = humanoid.AnimationPlayed:Connect(function(track)
            if track.Animation then
                local animId = track.Animation.AnimationId
                local animName = track.Name:lower()

                if blockedAnimations[animId] or animName:match("punch") or animName:match("attack") or animName:match("right") then
                    track:Stop()
                end
            end
        end)
    end
end

local function overrideToolActivation()
    local function processTool(tool)
        if tool and (tool.Name == "Punch" or tool.Name:match("Attack") or tool.Name:match("Right")) then
            if not tool:GetAttribute("ActivatedOverride") then
                tool:SetAttribute("ActivatedOverride", true)

                local connection = tool.Activated:Connect(function()
                    task.wait(0.05)

                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        for _, track in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
                            if track.Animation then
                                local animId = track.Animation.AnimationId
                                local animName = track.Name:lower()

                                if blockedAnimations[animId] or animName:match("punch") or animName:match("attack") or animName:match("right") then
                                    track:Stop()
                                end
                            end
                        end
                    end
                end)

                if not _G.ToolConnections then
                    _G.ToolConnections = {}
                end
                _G.ToolConnections[tool] = connection
            end
        end
    end

    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        processTool(tool)
    end

    local char = LocalPlayer.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                processTool(tool)
            end
        end
    end

    if not _G.BackpackAddedConnection then
        _G.BackpackAddedConnection = LocalPlayer.Backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.1)
                processTool(child)
            end
        end)
    end

    if not _G.CharacterToolAddedConnection and char then
        _G.CharacterToolAddedConnection = char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.1)
                processTool(child)
            end
        end)
    end
end

local function RecoveryPunch()
    if _G.AnimBlockConnection then _G.AnimBlockConnection:Disconnect() _G.AnimBlockConnection = nil end
    if _G.AnimMonitorConnection then _G.AnimMonitorConnection:Disconnect() _G.AnimMonitorConnection = nil end
    if _G.BackpackAddedConnection then _G.BackpackAddedConnection:Disconnect() _G.BackpackAddedConnection = nil end
    if _G.CharacterToolAddedConnection then _G.CharacterToolAddedConnection:Disconnect() _G.CharacterToolAddedConnection = nil end
    if _G.CharacterAddedConnection then _G.CharacterAddedConnection:Disconnect() _G.CharacterAddedConnection = nil end
    if _G.ToolConnections then
        for _, conn in pairs(_G.ToolConnections) do
            if conn then conn:Disconnect() end
        end
        _G.ToolConnections = nil
    end
end

Kill:AddSwitch("🚫 Remove Punch Anim", function(state)
    _G.RemoveAnimActive = state
    if state then
        setupAnimationBlocking()
        overrideToolActivation()

        if not _G.AnimMonitorConnection then
            _G.AnimMonitorConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if tick() % 0.5 < 0.01 then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        for _, track in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
                            if track.Animation then
                                local animId = track.Animation.AnimationId
                                local animName = track.Name:lower()

                                if blockedAnimations[animId] or animName:match("punch") or animName:match("attack") or animName:match("right") then
                                    track:Stop()
                                end
                            end
                        end
                    end
                end
            end)
        end

        if not _G.CharacterAddedConnection then
            _G.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                task.wait(1)
                if _G.RemoveAnimActive then
                    setupAnimationBlocking()
                    overrideToolActivation()

                    if _G.CharacterToolAddedConnection then _G.CharacterToolAddedConnection:Disconnect() end
                    _G.CharacterToolAddedConnection = newChar.ChildAdded:Connect(function(child)
                        if child:IsA("Tool") then
                            task.wait(0.1)
                            processTool(child)
                        end
                    end)
                end
            end)
        end
    else
        RecoveryPunch()
    end
end)

Kill:AddSwitch("Auto Equip Punch", function(state)
    autoEquipPunch = state
    task.spawn(function()
        while autoEquipPunch do
            local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
            if punch then
                punch.Parent = LocalPlayer.Character
            end
            task.wait(0.1)
        end
    end)
end)

Kill:AddSwitch("🥊 Auto Punch [No Animation]", function(state)
    autoPunchNoAnim = state
    task.spawn(function()
        while autoPunchNoAnim do
            local punch = LocalPlayer.Backpack:FindFirstChild("Punch") or LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
            if punch then
                if punch.Parent ~= LocalPlayer.Character then
                    punch.Parent = LocalPlayer.Character
                end
                LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
                LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
            else
                autoPunchNoAnim = false
            end
            task.wait(0.01)
        end
    end)
end)

Kill:AddSwitch("🧨 Auto Punch", function(state)
    _G.fastHitActive = state
    if state then
        task.spawn(function()
            while _G.fastHitActive do
                local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
                if punch then
                    punch.Parent = LocalPlayer.Character
                    if punch:FindFirstChild("attackTime") then
                        punch.attackTime.Value = 0
                    end
                end
                task.wait(0.1)
            end
        end)
        task.spawn(function()
            while _G.fastHitActive do
                local punch = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
                if punch then
                    punch:Activate()
                end
                task.wait(0.1)
            end
        end)
    else
        local punch = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
        if punch then
            punch.Parent = LocalPlayer.Backpack
        end
    end
end)

Kill:AddSwitch("⚡ Fast Punch", function(state)
    _G.autoPunchActive = state
    if state then
        task.spawn(function()
            while _G.autoPunchActive do
                local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
                if punch then
                    punch.Parent = LocalPlayer.Character
                    if punch:FindFirstChild("attackTime") then
                        punch.attackTime.Value = 0
                    end
                end
                task.wait(0.02)
            end
        end)
        task.spawn(function()
            while _G.autoPunchActive do
                local punch = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
                if punch then
                    punch:Activate()
                end
                task.wait(0.02)
            end
        end)
    else
        local punch = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
        if punch then
            punch.Parent = LocalPlayer.Backpack
        end
    end
end)

Kill:AddSwitch("💥 Fast Ground Slam", function(state)
    _G.autoGroundSlamActive = state
    if state then
        task.spawn(function()
            while _G.autoGroundSlamActive do
                local slam = LocalPlayer.Backpack:FindFirstChild("Ground Slam")
                if slam then
                    slam.Parent = LocalPlayer.Character
                    if slam:FindFirstChild("attackTime") then
                        slam.attackTime.Value = 0
                    end
                end
                task.wait(0.02)
            end
        end)
        task.spawn(function()
            while _G.autoGroundSlamActive do
                local slam = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Ground Slam")
                if slam then
                    slam:Activate()
                end
                task.wait(0.02)
            end
        end)
    else
        local slam = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Ground Slam")
        if slam then
            slam.Parent = LocalPlayer.Backpack
        end
    end
end)

Kill:AddSwitch("🦵 Fast Stomp", function(state)
    _G.autoStompActive = state
    if state then
        task.spawn(function()
            while _G.autoStompActive do
                local stomp = LocalPlayer.Backpack:FindFirstChild("Stomp")
                if stomp then
                    stomp.Parent = LocalPlayer.Character
                    if stomp:FindFirstChild("attackTime") then
                        stomp.attackTime.Value = 0
                    end
                end
                task.wait(0.2)
            end
        end)
        task.spawn(function()
            while _G.autoStompActive do
                local stomp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stomp")
                if stomp then
                    stomp:Activate()
                end
                task.wait(0.30)
            end
        end)
    else
        local stomp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Stomp")
        if stomp then
            stomp.Parent = LocalPlayer.Backpack
        end
    end
end)

Kill:AddLabel("--------------------")
Kill:AddLabel("✨ Whitelist")

local whitelistShow = Kill:AddLabel("Whitelisted: None")

local function updateWhitelistLabel()
    local str = ""
    for name, _ in pairs(playerWhitelist) do str = str .. name .. ", " end
    whitelistShow.Text = str ~= "" and "Whitelisted: " .. str:sub(1, #str - 2) or "Whitelisted: None"
end

local whitelistDropdown = Kill:AddDropdown("Whitelist Player", function(name)
    if name then playerWhitelist[name] = true updateWhitelistLabel() end
end)

for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
    if plr ~= game.Players.LocalPlayer then
        whitelistDropdown:Add(plr.Name)
    end
end

game:GetService("Players").PlayerAdded:Connect(function(plr)
    if plr ~= game.Players.LocalPlayer then
        whitelistDropdown:Add(plr.Name)
    end
end)

Kill:AddButton("🧹 Clear Whitelist", function()
    playerWhitelist = {} updateWhitelistLabel()
end)

Kill:AddSwitch("🛡️ Auto Whitelist Friends", function(state)
    _G.WhFriends = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and LocalPlayer:IsFriendsWith(p.UserId) then playerWhitelist[p.Name] = true end
        end
        updateWhitelistLabel()
    end
end)

Kill:AddSwitch("⚔️ Auto Kill All (Ignore Whitelist)", function(bool)
    _G.AutoKill = bool
    task.spawn(function()
        while _G.AutoKill do
            local char = LocalPlayer.Character
            local rHand = char and char:FindFirstChild("RightHand")
            if rHand then
                for _, target in ipairs(Players:GetPlayers()) do
                    if target ~= LocalPlayer and not playerWhitelist[target.Name] then
                        local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            pcall(function()
                                firetouchinterest(rHand, root, 1)
                                firetouchinterest(rHand, root, 0)
                            end)
                        end
                    end
                end
            end
            task.wait(0.01)
        end
    end)
end)

Kill:AddSwitch("😇 Auto Good Karma", function(bool)
    _G.GoodKarma = bool
    if bool then
        task.spawn(function()
            while _G.GoodKarma do
                local char = LocalPlayer.Character
                local rHand = char and char:FindFirstChild("RightHand")
                
                if rHand and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    for _, target in ipairs(Players:GetPlayers()) do
                        if target ~= LocalPlayer then
                            local evil = target:FindFirstChild("evilKarma")
                            local good = target:FindFirstChild("goodKarma")
                            
                            if evil and good and evil.Value > good.Value then
                                local tChar = target.Character
                                if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                                    local root = tChar:FindFirstChild("HumanoidRootPart")
                                    if root then
                                        firetouchinterest(rHand, root, 0)
                                        firetouchinterest(rHand, root, 1)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

Kill:AddSwitch("😈 Auto Bad Karma", function(bool)
    _G.BadKarma = bool
    if bool then
        task.spawn(function()
            while _G.BadKarma do
                local char = LocalPlayer.Character
                local rHand = char and char:FindFirstChild("RightHand")
                
                if rHand and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    for _, target in ipairs(Players:GetPlayers()) do
                        if target ~= LocalPlayer then
                            local evil = target:FindFirstChild("evilKarma")
                            local good = target:FindFirstChild("goodKarma")
                            
                            if evil and good and good.Value > evil.Value then
                                local tChar = target.Character
                                if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                                    local root = tChar:FindFirstChild("HumanoidRootPart")
                                    if root then
                                        firetouchinterest(rHand, root, 0)
                                        firetouchinterest(rHand, root, 1)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

Kill:AddLabel("----------------------------")
Kill:AddLabel("🎯 Target Kill")

local blacklistShow = Kill:AddLabel("Targets: None")

local function updateBlacklistLabel()
    local str = ""
    for _, name in ipairs(targetPlayerNames) do str = str .. name .. ", " end
    blacklistShow.Text = str ~= "" and "Targets: " .. str:sub(1, #str - 2) or "Targets: None"
end

local targetDropdown = Kill:AddDropdown("🎭 Select Target", function(name)
    if name and not table.find(targetPlayerNames, name) then 
        table.insert(targetPlayerNames, name) 
        updateBlacklistLabel()
    end
end)

Kill:AddButton("🚫 Clear Blacklist", function()
    targetPlayerNames = {} updateBlacklistLabel()
end)

Kill:AddSwitch("🎯 Start Kill Target", function(state)
    _G.KillTarget = state
    task.spawn(function()
        while _G.KillTarget do
            local char = LocalPlayer.Character
            local rHand = char and char:FindFirstChild("RightHand")
            if rHand then
                for _, name in ipairs(targetPlayerNames) do
                    local t = Players:FindFirstChild(name)
                    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            firetouchinterest(rHand, t.Character.HumanoidRootPart, 1)
                            firetouchinterest(rHand, t.Character.HumanoidRootPart, 0)
                        end)
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end)

local function updateAllDropdowns(p)
    if p ~= LocalPlayer then
        whitelistDropdown:Add(p.Name)
        targetDropdown:Add(p.Name)
    end
end

for _, p in ipairs(Players:GetPlayers()) do updateAllDropdowns(p) end
Players.PlayerAdded:Connect(updateAllDropdowns)

local LookDura = window:AddTab("Stats")
local SelectPlayerName = ""

local PlayerDrop = LookDura:AddDropdown("Select Player", function(Value)
    SelectPlayerName = Value:match("| (.+)")
    previousValues = {}
end)

local Playerslist = {}
for _, Plr in pairs(game:GetService("Players"):GetPlayers()) do
    local displayName = Plr.DisplayName .. " | " .. Plr.Name
    table.insert(Playerslist, displayName)
end
for _, AddPlr in ipairs(Playerslist) do
    PlayerDrop:Add(AddPlr)
end

local function FormatNumberWithCommas(number)
    local formatted = tostring(number):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return formatted:gsub("^,", "")
end

local function FormatAbbreviated(number)
    local abbreviations = {"", "K", "M", "B", "T", "Qa", "Qi"}
    local abbreviationIndex = 1
    while number >= 1000 and abbreviationIndex < #abbreviations do
        number = number / 1000
        abbreviationIndex = abbreviationIndex + 1
    end
    return string.format("%.2f", number) .. abbreviations[abbreviationIndex]
end

local function FormatDisplay(value)
    local normal = FormatNumberWithCommas(value)
    local abbreviated = FormatAbbreviated(value)
    return "[ " .. normal .. " | " .. abbreviated .. " ]"
end

local previousValues = {}

-- Folder 1: Main Stats
local mainFolder = LookDura:AddFolder("💪 Main Stats")
local Update = mainFolder:AddLabel("")
local Update2 = mainFolder:AddLabel("")
local Update4 = mainFolder:AddLabel("")
local Update3 = mainFolder:AddLabel("")

-- Folder 2: Other Stats
local otherFolder = LookDura:AddFolder("🌟 Other Stats")
local Update1 = otherFolder:AddLabel("")
local Update6 = otherFolder:AddLabel("")
local Update9 = otherFolder:AddLabel("")
local Update12 = otherFolder:AddLabel("")
local Update13 = otherFolder:AddLabel("")

task.spawn(function()
    while task.wait(0.1) do
        if SelectPlayerName ~= "" then
            local player = game.Players:FindFirstChild(SelectPlayerName)
            local localPlayer = game.Players.LocalPlayer
            if player and localPlayer then
                if player:FindFirstChild("Gems") then
                    Update1.Text = "💎 Gems: " .. FormatDisplay(player.Gems.Value)
                end
                if player:FindFirstChild("Agility") then
                    Update3.Text = "⚡ Agility: " .. FormatDisplay(player.Agility.Value)
                end
                if player:FindFirstChild("Durability") then
                    Update4.Text = "🛡️ Durability: " .. FormatDisplay(player.Durability.Value)
                end
                if player:FindFirstChild("muscleKingTime") then
                    Update6.Text = "👑 Muscle King Time: " .. FormatDisplay(player.muscleKingTime.Value)
                end
                if player:FindFirstChild("evilKarma") then
                    Update12.Text = "😈 Evil Karma: " .. FormatDisplay(player.evilKarma.Value)
                end
                if player:FindFirstChild("goodKarma") then
                    Update13.Text = "✨ Good Karma: " .. FormatDisplay(player.goodKarma.Value)
                end

                local leaderstats = player:FindFirstChild("leaderstats")
                if leaderstats then
                    if leaderstats:FindFirstChild("Strength") then
                        Update.Text = "💪 Strength: " .. FormatDisplay(leaderstats.Strength.Value)
                    end
                    if leaderstats:FindFirstChild("Rebirths") then
                        Update2.Text = "🔄 Rebirth: " .. FormatDisplay(leaderstats.Rebirths.Value)
                    end
                end

                if player:FindFirstChild("currentMap") then
                    Update9.Text = "📍 Map: " .. tostring(player.currentMap.Value)
                else
                    Update9.Text = "📍 Map: Unknown"
                end
            end
        end
    end
end)

local Rock = window:AddTab("Rock")

function gettool()
    for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.Name == "Punch" and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
        end
    end
    
    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
end

Rock:AddSwitch("💎 Tiny Rock 0", function(Value)
    selectrock = "Tiny Island Rock"
    getgenv().autoFarm = Value
    task.spawn(function()
        while getgenv().autoFarm do
            task.wait(0.01)
            if not getgenv().autoFarm then break end
            if game:GetService("Players").LocalPlayer.Durability.Value >= 0 then
                for i, v in pairs(game:GetService("Workspace").machinesFolder:GetDescendants()) do
                    if v.Name == "neededDurability" and v.Value == 0 and game.Players.LocalPlayer.Character:FindFirstChild("LeftHand") and game.Players.LocalPlayer.Character:FindFirstChild("RightHand") then
                        for _ = 1, 3 do
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 1)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 1)
                        end
                        gettool()
                    end
                end
            end
        end
    end)
end)

Rock:AddSwitch("🔥 Starter Rock 100", function(Value)
    selectrock = "Starter Island Rock"
    getgenv().autoFarm = Value
    task.spawn(function()
        while getgenv().autoFarm do
            task.wait(0.01)
            if not getgenv().autoFarm then break end
            if game:GetService("Players").LocalPlayer.Durability.Value >= 100 then
                for i, v in pairs(game:GetService("Workspace").machinesFolder:GetDescendants()) do
                    if v.Name == "neededDurability" and v.Value == 100 and game.Players.LocalPlayer.Character:FindFirstChild("LeftHand") and game.Players.LocalPlayer.Character:FindFirstChild("RightHand") then
                        for _ = 1, 3 do
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 1)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 1)
                        end
                        gettool()
                    end
                end
            end
        end
    end)
end)

Rock:AddSwitch("🏝️ Legend Beach Rock 5K", function(Value)
    selectrock = "Legend Beach Rock"
    getgenv().autoFarm = Value
    task.spawn(function()
        while getgenv().autoFarm do
            task.wait(0.01)
            if not getgenv().autoFarm then break end
            if game:GetService("Players").LocalPlayer.Durability.Value >= 5000 then
                for i, v in pairs(game:GetService("Workspace").machinesFolder:GetDescendants()) do
                    if v.Name == "neededDurability" and v.Value == 5000 and game.Players.LocalPlayer.Character:FindFirstChild("LeftHand") and game.Players.LocalPlayer.Character:FindFirstChild("RightHand") then
                        for _ = 1, 3 do
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 1)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 1)
                        end
                        gettool()
                    end
                end
            end
        end
    end)
end)

Rock:AddSwitch("❄️ Frozen Rock 150K", function(Value)
    selectrock = "Frost Gym Rock"
    getgenv().autoFarm = Value
    task.spawn(function()
        while getgenv().autoFarm do
            task.wait(0.01)
            if not getgenv().autoFarm then break end
            if game:GetService("Players").LocalPlayer.Durability.Value >= 150000 then
                for i, v in pairs(game:GetService("Workspace").machinesFolder:GetDescendants()) do
                    if v.Name == "neededDurability" and v.Value == 150000 and game.Players.LocalPlayer.Character:FindFirstChild("LeftHand") and game.Players.LocalPlayer.Character:FindFirstChild("RightHand") then
                        for _ = 1, 3 do
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 1)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 1)
                        end
                        gettool()
                    end
                end
            end
        end
    end)
end)

Rock:AddSwitch("✨ Mythical Rock 400K", function(Value)
    selectrock = "Mythical Gym Rock"
    getgenv().autoFarm = Value
    task.spawn(function()
        while getgenv().autoFarm do
            task.wait(0.01)
            if not getgenv().autoFarm then break end
            if game:GetService("Players").LocalPlayer.Durability.Value >= 400000 then
                for i, v in pairs(game:GetService("Workspace").machinesFolder:GetDescendants()) do
                    if v.Name == "neededDurability" and v.Value == 400000 and game.Players.LocalPlayer.Character:FindFirstChild("LeftHand") and game.Players.LocalPlayer.Character:FindFirstChild("RightHand") then
                        for _ = 1, 3 do
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 1)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 1)
                        end
                        gettool()
                    end
                end
            end
        end
    end)
end)

Rock:AddSwitch("🔥 Eternal Rock 750K", function(Value)
    selectrock = "Eternal Gym Rock"
    getgenv().autoFarm = Value
    task.spawn(function()
        while getgenv().autoFarm do
            task.wait(0.01)
            if not getgenv().autoFarm then break end
            if game:GetService("Players").LocalPlayer.Durability.Value >= 750000 then
                for i, v in pairs(game:GetService("Workspace").machinesFolder:GetDescendants()) do
                    if v.Name == "neededDurability" and v.Value == 750000 and game.Players.LocalPlayer.Character:FindFirstChild("LeftHand") and game.Players.LocalPlayer.Character:FindFirstChild("RightHand") then
                        for _ = 1, 3 do
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 1)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 1)
                        end
                        gettool()
                    end
                end
            end
        end
    end)
end)

Rock:AddSwitch("🏆 Legend Rock 1M", function(Value)
    selectrock = "Legend Gym Rock"
    getgenv().autoFarm = Value
    task.spawn(function()
        while getgenv().autoFarm do
            task.wait(0.01)
            if not getgenv().autoFarm then break end
            if game:GetService("Players").LocalPlayer.Durability.Value >= 1000000 then
                for i, v in pairs(game:GetService("Workspace").machinesFolder:GetDescendants()) do
                    if v.Name == "neededDurability" and v.Value == 1000000 and game.Players.LocalPlayer.Character:FindFirstChild("LeftHand") and game.Players.LocalPlayer.Character:FindFirstChild("RightHand") then
                        for _ = 1, 3 do
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 1)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 1)
                        end
                        gettool()
                    end
                end
            end
        end
    end)
end)

Rock:AddSwitch("👑 Muscle King Rock 5M", function(Value)
    selectrock = "Muscle King Gym Rock"
    getgenv().autoFarm = Value
    task.spawn(function()
        while getgenv().autoFarm do
            task.wait(0.01)
            if not getgenv().autoFarm then break end
            if game:GetService("Players").LocalPlayer.Durability.Value >= 5000000 then
                for i, v in pairs(game:GetService("Workspace").machinesFolder:GetDescendants()) do
                    if v.Name == "neededDurability" and v.Value == 5000000 and game.Players.LocalPlayer.Character:FindFirstChild("LeftHand") and game.Players.LocalPlayer.Character:FindFirstChild("RightHand") then
                        for _ = 1, 3 do
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 1)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 1)
                        end
                        gettool()
                    end
                end
            end
        end
    end)
end)

Rock:AddSwitch("🌴 Jungle Rock 10M", function(Value)
    selectrock = "Ancient Jungle Rock"
    getgenv().autoFarm = Value
    task.spawn(function()
        while getgenv().autoFarm do
            task.wait(0.01)
            if not getgenv().autoFarm then break end
            if game:GetService("Players").LocalPlayer.Durability.Value >= 10000000 then
                for i, v in pairs(game:GetService("Workspace").machinesFolder:GetDescendants()) do
                    if v.Name == "neededDurability" and v.Value == 10000000 and game.Players.LocalPlayer.Character:FindFirstChild("LeftHand") and game.Players.LocalPlayer.Character:FindFirstChild("RightHand") then
                        for _ = 1, 3 do
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.RightHand, 1)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 0)
                            firetouchinterest(v.Parent.Rock, game:GetService("Players").LocalPlayer.Character.LeftHand, 1)
                        end
                        gettool()
                    end
                end
            end
        end
    end)
end)

Rock:AddLabel("👊 Auto Rock V2 (Teleport)")

local FaceDirections = {
    North = Vector3.new(0, 0, -1),
    South = Vector3.new(0, 0, 1),
    East = Vector3.new(1, 0, 0),
    West = Vector3.new(-1, 0, 0),
}

local function LockPosition(CFramePosition)
    _G.lockRunning = true
    _G.LockedCFrame = CFramePosition
    
    if _G.lockConnection then
        _G.lockConnection:Disconnect()
    end
    
    _G.lockConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local Character = game.Players.LocalPlayer.Character
        if Character and _G.lockRunning then
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Character:FindFirstChild("Humanoid")
            if HumanoidRootPart and Humanoid then
                HumanoidRootPart.CFrame = _G.LockedCFrame
                HumanoidRootPart.Velocity = Vector3.zero
                HumanoidRootPart.RotVelocity = Vector3.zero
                Humanoid.PlatformStand = true
            end
        end
    end)
end

local function UnlockPosition()
    _G.lockRunning = false
    if _G.lockConnection then
        _G.lockConnection:Disconnect()
    end
    
    local Humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if Humanoid then
        Humanoid.PlatformStand = false
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
    task.defer(function()
        if _G.lockRunning and _G.LockedCFrame then
            Character:WaitForChild("HumanoidRootPart").CFrame = _G.LockedCFrame
            LockPosition(_G.LockedCFrame)
        end
    end)
end)

local RockConfigurations = {
    {name = "Jungle Rock", key = "Glitch_Jungle", dur = 10000000, pos = Vector3.new(-7706.23, 4.51, 2918.94), face = "East"},
    {name = "Muscle King Rock", key = "Glitch_MuscleKing", dur = 5000000, pos = Vector3.new(-9040.84, 6.9, -6057.31), face = "East"},
    {name = "Legend Rock", key = "Glitch_Legend", dur = 1000000, pos = Vector3.new(4141.13, 989.23, -4029.81), face = "North"},
    {name = "Eternal Rock", key = "Glitch_Eternal", dur = 750000, pos = Vector3.new(-7223.26, 5.07, -1259.91), face = "West"},
    {name = "Mythical Rock", key = "Glitch_Mythical", dur = 400000, pos = Vector3.new(2224.73, 5.03, 1251.95), face = "West"},
    {name = "Frost Rock", key = "Glitch_Frost", dur = 150000, pos = Vector3.new(-2590.58, 5.03, -241.71), face = "East"},
    {name = "Golden Rock", key = "Glitch_Golden", dur = 5000, pos = Vector3.new(342.33, 5.12, -590.91), face = "West"},
    {name = "Starter Island", key = "Glitch_Starter", dur = 100, pos = Vector3.new(182.07, 5.03, -151.99), face = "West"},
    {name = "Tiny Rock", key = "Glitch_Tiny", dur = 0, pos = Vector3.new(18.27, 5.23, 2093.81), face = "South"}
}

local selectedRockV2 = nil
local rockV2StartActive = false

local rockV2Dropdown = Rock:AddDropdown("🗿 Select Rock V2", function(selected)
    selectedRockV2 = selected
    print("Selected rock V2: " .. selected)
end)

for _, RockConfig in ipairs(RockConfigurations) do
    rockV2Dropdown:Add(RockConfig.name)
end

Rock:AddSwitch("👊 Start Rock V2 Farm", function(Value)
    rockV2StartActive = Value
    
    if Value then
        if selectedRockV2 == nil then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Error",
                Text = "Please select a rock first!",
                Duration = 3
            })
            return
        end
        
        for _, RockConfig in ipairs(RockConfigurations) do
            if RockConfig.name == selectedRockV2 then
                _G[RockConfig.key] = true
                task.spawn(function()
                    while _G[RockConfig.key] and rockV2StartActive do
                        local LocalPlayer = game.Players.LocalPlayer
                        if LocalPlayer:FindFirstChild("Durability") and LocalPlayer.Durability.Value >= RockConfig.dur then
                            local Direction = FaceDirections[RockConfig.face] or Vector3.new(0, 0, -1)
                            local TargetCFrame = CFrame.new(RockConfig.pos, RockConfig.pos + Direction)
                            local Character = LocalPlayer.Character
                            
                            if Character and Character:FindFirstChild("HumanoidRootPart") then
                                Character.HumanoidRootPart.CFrame = TargetCFrame
                                LockPosition(TargetCFrame)
                            end
                            
                            local PunchTool = LocalPlayer.Backpack:FindFirstChild("Punch") or 
                                             (Character and Character:FindFirstChild("Punch"))
                            
                            if PunchTool and Character and Character:FindFirstChild("Humanoid") then
                                if PunchTool.Parent ~= Character then
                                    Character.Humanoid:EquipTool(PunchTool)
                                end
                                
                                if PunchTool:FindFirstChild("attackTime") then
                                    PunchTool.attackTime.Value = 0.1
                                end
                                
                                LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
                                LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
                                PunchTool:Activate()
                            end
                        end
                        task.wait()
                    end
                    UnlockPosition()
                    _G[RockConfig.key] = false
                end)
            else
                _G[RockConfig.key] = false
            end
        end
    else
        for _, RockConfig in ipairs(RockConfigurations) do
            _G[RockConfig.key] = false
        end
        UnlockPosition()
        print("Rock V2 farm stopped")
    end
end)

local pets = window:AddTab("Pets")
pets:AddLabel("💰 Auto Buy")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rEvents = ReplicatedStorage:WaitForChild("rEvents")

local selectedPet = "Orange Hedgehog"
local autoHatchPet = false

local petDropdown = pets:AddDropdown("🐢 Select Pet", function(text)
    selectedPet = text:match("^(.-)%s*%(.-%)$") or text
end)

local petList = {
    "Orange Hedgehog (Basic)",
    "Silver Dog (Basic)",
    "Red Kitty (Basic)",
    "Blue Birdie (Basic)",
    "Blue Bunny (Basic)",
    "Core Pup (Basic)",
    "Green Butterfly (Rare)",
    "Yellow Butterfly (Rare)",
    "Magic Butterfly (Rare)",
    "Volt Talon (Rare)",
    "Red Dragon (Epic)",
    "Purple Dragon (Epic)",
    "Blue Firecaster (Epic)",
    "Red Firecaster (Epic)",
    "Green Firecaster (Epic)",
    "Reactor Bea (Epic)",
    "Golden Viking (Legendary)",
    "Gold Warrior (Legendary)",
    "Infernal Dragon (Legendary)",
    "Dark Golem (Legendary)",
    "Muscle Sensei (Legendary)",
    "Plasma Ravager (Legendary)",
    "Orange Pegasus (Unique)",
    "White Pegasus (Unique)",
    "Blue Pheonix (Unique)",
    "Golden Pheonix (Unique)",
    "White Pheonix (Unique)",
    "Crimson Falcon (Unique)",
    "Purple Falcon (Unique)",
    "Ultra Birdie (Unique)",
    "Dark Vampy (Unique)",
    "Frostwave Legends Penguin (Unique)",
    "Dark Legends Manticore (Unique)",
    "Darkstar Hunter (Unique)",
    "Lightning Strike Phantom (Unique)",
    "Cybernetic Showdown Dragon (Unique)",
    "Phantom Genesis Dragon (Unique)",
    "Eternal Strike Leviathan (Unique)",
    "Ultimate Supernova Pegasus (Unique)",
    "Titan Reactor (Unique)",
    "Neon Guardian (Unique)",
    "Apex Overlord (Unique)"
}

for _, petName in ipairs(petList) do
    petDropdown:Add(petName)
end

pets:AddSwitch("Auto Open Pet", function(bool)
    autoHatchPet = bool
    if bool then
        spawn(function()
            while autoHatchPet and selectedPet ~= "" do
                local petShopRemote = rEvents:FindFirstChild("cPetShopRemote") or ReplicatedStorage:FindFirstChild("cPetShopRemote")
                
                local runtimeFolder = ReplicatedStorage:FindFirstChild("shared") 
                    and ReplicatedStorage.shared:FindFirstChild("runtime") 
                    and ReplicatedStorage.shared.runtime:FindFirstChild("cPetShopFolder")
                
                local petToOpen = runtimeFolder and runtimeFolder:FindFirstChild(selectedPet)
                
                if petToOpen and petShopRemote then
                    pcall(function()
                        petShopRemote:InvokeServer(petToOpen)
                    end)
                end
                task.wait(0.1)
            end
        end)
    end
end)

pets:AddLabel("💫 Auto Buy Aura")

local selectedAura = "Blue Aura"
local autoHatchAura = false

local auraDropdown = pets:AddDropdown("💫 Select Aura", function(text)
    selectedAura = text:match("^(.-)%s*%(.-%)$") or text
end)

local auraList = {
    "Blue Aura (Basic)",
    "Green Aura (Basic)",
    "Yellow Aura (Basic)",
    "Purple Aura (Basic)",
    "Red Aura (Basic)",
    "Electro (Rare)",
    "Lightning (Rare)",
    "Dark Electro (Rare)",
    "Dark Lightning (Rare)",
    "Azure Tundra (Epic)",
    "Dark Storm (Epic)",
    "Inferno (Epic)",
    "Muscle King (Epic)",
    "Power Lightning (Epic)",
    "Purple Nova (Epic)",
    "Supernova (Legendary)",
    "Ultra Inferno (Legendary)",
    "Enchanted Mirage (Unique)",
    "Astral Electro (Unique)",
    "Eternal Megastrike (Unique)",
    "Grand Supernova (Unique)",
    "Entropic Blast (Unique)",
    "Ultra Mirage (Unique)",
    "Unstable Mirage (Unique)"
}

for _, auraName in ipairs(auraList) do
    auraDropdown:Add(auraName)
end

pets:AddSwitch("Auto Open Aura", function(bool)
    autoHatchAura = bool
    if bool then
        spawn(function()
            while autoHatchAura and selectedAura ~= "" do
                local petShopRemote = rEvents:FindFirstChild("cPetShopRemote") or ReplicatedStorage:FindFirstChild("cPetShopRemote")
                
                local runtimeFolder = ReplicatedStorage:FindFirstChild("shared") 
                    and ReplicatedStorage.shared:FindFirstChild("runtime") 
                    and ReplicatedStorage.shared.runtime:FindFirstChild("cPetShopFolder")
                
                local auraToOpen = runtimeFolder and runtimeFolder:FindFirstChild(selectedAura)
                
                if auraToOpen and petShopRemote then
                    pcall(function()
                        petShopRemote:InvokeServer(auraToOpen)
                    end)
                end
                task.wait(0.1)
            end
        end)
    end
end)

pets:AddLabel("----------------------------")
pets:AddLabel("✨ Auto Evolve Pet")

local pets = pets
local selectedEvolvePet = ""
local autoEvolvePet = false

local evolvePetDropdown = pets:AddDropdown("🐾 Select Pet to Evolve", function(text)
    selectedEvolvePet = text:match("^(.-)%s*%(.-%)$") or text
end)

local evolveList = {
    -- Basic
    "Orange Hedgehog (Basic)",
    "Silver Dog (Basic)",
    "Red Kitty (Basic)",
    "Blue Birdie (Basic)",
    "Blue Bunny (Basic)",
    "Core Pup (Basic)",
    "Blue Aura (Basic)",
    "Green Aura (Basic)",
    "Purple Aura (Basic)",
    "Red Aura (Basic)",
    "Yellow Aura (Basic)",

    -- Advanced
    "Dark Vampy (Advanced)",
    "Dark Golem (Advanced)",
    "Green Butterfly (Advanced)",
    "Yellow Butterfly (Advanced)",

    -- Rare
    "Crimson Falcon (Rare)",
    "Purple Dragon (Rare)",
    "Orange Pegasus (Rare)",
    "Purple Falcon (Rare)",
    "Red Dragon (Rare)",
    "White Pegasus (Rare)",
    "Frostwave Legends Penguin (Rare)",
    "Phantom Genesis Dragon (Rare)",
    "Eternal Strike Leviathan (Rare)",
    "Volt Talon (Rare)",
    "Magic Butterfly (Rare)",
    "Blue Firecaster (Rare)",
    "Red Firecaster (Rare)",
    "Green Firecaster (Rare)",
    "Ultra Inferno (Rare)",

    -- Epic
    "Blue Pheonix (Epic)",
    "Golden Pheonix (Epic)",
    "White Pheonix (Epic)",
    "Dark Legends Manticore (Epic)",
    "Ultimate Supernova Pegasus (Epic)",
    "Lightning Strike Phantom (Epic)",
    "Golden Viking (Epic)",
    "Reactor Bea (Epic)",
    "Gold Warrior (Epic)",
    "Azure Tundra (Epic)",
    "Grand Supernova (Epic)",

    -- Unique
    "Infernal Dragon (Unique)",
    "Ultra Birdie (Unique)",
    "Aether Spirit Bunny (Unique)",
    "Cybernetic Showdown Dragon (Unique)",
    "Darkstar Hunter (Unique)",
    "Muscle Sensei (Unique)",
    "Neon Guardian (Unique)",
    "Apex Overlord (Unique)",
    "Plasma Ravager (Unique)",
    "Titan Reactor (Unique)",
    "Muscle King (Unique)",
    "Entropic Blast (Unique)",
    "Eternal Megastrike (Unique)"
}

for _, item in ipairs(evolveList) do
    evolvePetDropdown:Add(item)
end

pets:AddSwitch("🎯 Auto Evolve Selected Pet", function(state)
    autoEvolvePet = state
    if state then
        if selectedEvolvePet == "" then
            return
        end
        local petName = selectedEvolvePet:match("^(.-)%s*%(")
        if not petName then
            petName = selectedEvolvePet
        end
        task.spawn(function()
            local maxAttempts = 1000
            while autoEvolvePet do
                pcall(function()
                    game:GetService("ReplicatedStorage").rEvents.petEvolveEvent:FireServer(
                        "evolvePet",
                        petName
                    )
                end)
                task.wait(0.5)
                if maxAttempts <= 0 then
                    autoEvolvePet = false
                    break
                end
                maxAttempts = maxAttempts - 1
            end
        end)
    end
end)

pets:AddButton("⚡ Quick Evolve (1x)", function()
    if selectedEvolvePet == "" then
        return
    end
    local petName = selectedEvolvePet:match("^(.-)%s*%(")
    if not petName then
        petName = selectedEvolvePet
    end
    pcall(function()
        game:GetService("ReplicatedStorage").rEvents.petEvolveEvent:FireServer(
            "evolvePet",
            petName
        )
    end)
end)

pets:AddButton("💥 Quick Evolve (10x)", function()
    if selectedEvolvePet == "" then
        return
    end
    local petName = selectedEvolvePet:match("^(.-)%s*%(")
    if not petName then
        petName = selectedEvolvePet
    end
    for i = 1, 10 do
        pcall(function()
            game:GetService("ReplicatedStorage").rEvents.petEvolveEvent:FireServer(
                "evolvePet",
                petName
            )
        end)
        task.wait(0.1)
    end
end)

pets:AddLabel("----------------------------")
pets:AddLabel("💎 Trade System")

local running = false
local selectedTarget = nil
local selectedPet = nil

local playerDropdown = pets:AddDropdown("👤 Choose Player", function(name)
    local username = name:match(" | (.+)") or name
    selectedTarget = game:GetService("Players"):FindFirstChild(username)
end)

local function updatePlayerList(p)
    if p ~= game:GetService("Players").LocalPlayer then
        playerDropdown:Add(p.DisplayName .. " | " .. p.Name)
    end
end

for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
    updatePlayerList(player)
end

game:GetService("Players").PlayerAdded:Connect(updatePlayerList)

local petDropdown = pets:AddDropdown("🐈 Choose Pet", function(text) 
    selectedPet = text:match("^(.-)%s*%(.-%)$") or text 
end)

local petList = {
    -- Basic
    "Orange Hedgehog (Basic)",
    "Silver Dog (Basic)",
    "Red Kitty (Basic)",
    "Blue Birdie (Basic)",
    "Blue Bunny (Basic)",
    "Core Pup (Basic)",
    "Blue Aura (Basic)",
    "Green Aura (Basic)",
    "Purple Aura (Basic)",
    "Red Aura (Basic)",
    "Yellow Aura (Basic)",

    -- Advanced
    "Dark Vampy (Advanced)",
    "Dark Golem (Advanced)",
    "Green Butterfly (Advanced)",
    "Yellow Butterfly (Advanced)",

    -- Rare
    "Crimson Falcon (Rare)",
    "Purple Dragon (Rare)",
    "Orange Pegasus (Rare)",
    "Purple Falcon (Rare)",
    "Red Dragon (Rare)",
    "White Pegasus (Rare)",
    "Frostwave Legends Penguin (Rare)",
    "Phantom Genesis Dragon (Rare)",
    "Eternal Strike Leviathan (Rare)",
    "Volt Talon (Rare)",
    "Magic Butterfly (Rare)",
    "Blue Firecaster (Rare)",
    "Red Firecaster (Rare)",
    "Green Firecaster (Rare)",
    "Ultra Inferno (Rare)",

    -- Epic
    "Blue Pheonix (Epic)",
    "Golden Pheonix (Epic)",
    "White Pheonix (Epic)",
    "Dark Legends Manticore (Epic)",
    "Ultimate Supernova Pegasus (Epic)",
    "Lightning Strike Phantom (Epic)",
    "Golden Viking (Epic)",
    "Reactor Bea (Epic)",
    "Gold Warrior (Epic)",
    "Azure Tundra (Epic)",
    "Grand Supernova (Epic)",

    -- Unique
    "Infernal Dragon (Unique)",
    "Ultra Birdie (Unique)",
    "Aether Spirit Bunny (Unique)",
    "Cybernetic Showdown Dragon (Unique)",
    "Darkstar Hunter (Unique)",
    "Muscle Sensei (Unique)",
    "Neon Guardian (Unique)",
    "Apex Overlord (Unique)",
    "Plasma Ravager (Unique)",
    "Titan Reactor (Unique)",
    "Muscle King (Unique)",
    "Entropic Blast (Unique)",
    "Eternal Megastrike (Unique)"
}

for _, name in ipairs(petList) do 
    petDropdown:Add(name) 
end

pets:AddSwitch("📫 Auto Trade", function(state)
    running = state
    if not state then return end

    task.spawn(function()
        while running do
            if selectedTarget and selectedPet then
                local tradingEvent = game:GetService("ReplicatedStorage").rEvents.tradingEvent
                local localPlayer = game:GetService("Players").LocalPlayer
                local pf = localPlayer:FindFirstChild("petsFolder")

                if pf then
                    local folders = {
                        pf:FindFirstChild("Basic"),
                        pf:FindFirstChild("Advanced"),
                        pf:FindFirstChild("Rare"),
                        pf:FindFirstChild("Epic"),
                        pf:FindFirstChild("Unique")
                    }

                    tradingEvent:FireServer("sendTradeRequest", selectedTarget)
                    task.wait(1.5) 

                    local offered = 0
                    
                    for _, folder in ipairs(folders) do
                        if folder and running and offered < 6 then
                            local petsToOffer = folder:GetChildren()
                            for i = 1, #petsToOffer do
                                local pet = petsToOffer[i]
                                if not running or offered >= 6 then break end

                                if pet.Name == selectedPet then
                                    tradingEvent:FireServer("offerItem", pet)
                                    offered = offered + 1
                                    task.wait(0.1) 
                                end
                            end
                        end
                    end

                    if running then
                        tradingEvent:FireServer("acceptTrade")
                    end
                end
            end
            task.wait(1) 
        end
    end)
end)

local GymTab = window:AddTab("Gym")

local VIM = game:GetService("VirtualInputManager")
local function pressEKey()
    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function createFarm(folder, toggleName, cframeValue, eventName)
    local active = false
    folder:AddSwitch(toggleName, function(bool)
        active = bool
        if bool then
            task.spawn(function()
                while active do
                    local char = game.Players.LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        if (root.Position - cframeValue.p).Magnitude > 5 then
                            root.CFrame = cframeValue
                            task.wait(0.3)
                            pressEKey()
                        end
                        local event = game:GetService("Players").LocalPlayer:FindFirstChild("muscleEvent")
                        if event then
                            event:FireServer(eventName)
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    end)
end

-- 1. JUNGLE GYM
local JungleFolder = GymTab:AddFolder(" 🌴 Jungle Gym")
createFarm(JungleFolder, "🏋️ Auto Jungle Lift", CFrame.new(-8652.85, 45.22, 2088.99), "rep")
createFarm(JungleFolder, "💪 Auto Bench Press", CFrame.new(-8173.23, 83.82, 1907.40), "rep")
createFarm(JungleFolder, "🦵 Auto Squat", CFrame.new(-8377.55, 48.71, 2864.90), "rep")
createFarm(JungleFolder, "Auto Boulder", CFrame.new(-8614.81, 51.90, 2677.37), "rep")

-- 2. MUSCLE KING
local MuscleKingFolder = GymTab:AddFolder(" 👑 Muscle King")
createFarm(MuscleKingFolder, "🏋️ Auto Lift", CFrame.new(-8774.03, 52.15, -5664.10), "rep")
createFarm(MuscleKingFolder, "💪 Auto Bench Press", CFrame.new(-8589.43, 58.00, -6044.57), "rep")
createFarm(MuscleKingFolder, "🦵 Auto Squat", CFrame.new(-8759.62, 46.50, -6041.16), "rep")
createFarm(MuscleKingFolder, "🗿 Auto Boulder", CFrame.new(-8942.97, 60.71, -5692.74), "rep")

-- 3. LEGENDS GYM
local LegendsFolder = GymTab:AddFolder(" 🌟 Legends Gym")
createFarm(LegendsFolder, "🏋️ Auto Lift", CFrame.new(4532.02, 1025.80, -4002.15), "rep")
createFarm(LegendsFolder, "💪 Auto Bench Press", CFrame.new(4109.20, 1035.67, -3802.88), "rep")
createFarm(LegendsFolder, "🦵 Auto Squat", CFrame.new(4438.74, 1021.38, -4058.46), "rep")
createFarm(LegendsFolder, "🗿 Auto Boulder", CFrame.new(4188.75, 1019.85, -3905.19), "rep")

-- 4. MYTHICAL GYM
local MythicalFolder = GymTab:AddFolder(" 🔮 Mythical Gym")
createFarm(MythicalFolder, "🏋️ Auto Lift", CFrame.new(2486.75, 31.91, 847.89), "rep")
createFarm(MythicalFolder, "💪 Auto Bench Press", CFrame.new(2370.74, 57.09, 1243.37), "rep")
createFarm(MythicalFolder, "🗿 Auto Boulder", CFrame.new(2667.31, 58.88, 1202.46), "rep")

-- 5. FROST GYM
local FrostFolder = GymTab:AddFolder(" ❄️ Frost Gym")
createFarm(FrostFolder, "🏋️ Auto Lift", CFrame.new(-2917.62, 42.60, -211.29), "rep")
createFarm(FrostFolder, "💪 Auto Bench Press", CFrame.new(-3022.97, 41.31, -197.51), "rep")
createFarm(FrostFolder, "🦵 Auto Squat", CFrame.new(-2720.66, 27.85, -590.72), "rep")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rEvents = ReplicatedStorage:WaitForChild("rEvents")
local muscleEvent = rEvents:WaitForChild("muscleEvent")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Misc = window:AddTab("Misc")

Misc:AddLabel(" Better Farming:").TextSize = 17
local running = false
local thread = nil
local sizeSwitch = settingsTab:AddSwitch("Set Size 1", function(bool)
    running = bool
    if running then
        thread = coroutine.create(function()
            while running do
                game:GetService("ReplicatedStorage").rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 1)
                wait(0.01)
            end
        end)
        coroutine.resume(thread)
    end
end)

Misc:AddButton("Anti Lag (Black Screen)", function()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local lighting = game:GetService("Lighting")
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            gui:Destroy()
        end
    end
    local function darkenSky()
        for _, v in pairs(lighting:GetChildren()) do
            if v:IsA("Sky") then
                v:Destroy()
            end
        end
        local darkSky = Instance.new("Sky")
        darkSky.Name = "DarkSky"
        darkSky.SkyboxBk = "rbxassetid://0"
        darkSky.SkyboxDn = "rbxassetid://0"
        darkSky.SkyboxFt = "rbxassetid://0"
        darkSky.SkyboxLf = "rbxassetid://0"
        darkSky.SkyboxRt = "rbxassetid://0"
        darkSky.SkyboxUp = "rbxassetid://0"
        darkSky.Parent = lighting
        lighting.Brightness = 0
        lighting.ClockTime = 0
        lighting.TimeOfDay = "00:00:00"
        lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        lighting.Ambient = Color3.new(0, 0, 0)
        lighting.FogColor = Color3.new(0, 0, 0)
        lighting.FogEnd = 100
        task.spawn(function()
            while true do
                wait(5)
                if not lighting:FindFirstChild("DarkSky") then
                    darkSky:Clone().Parent = lighting
                end
                lighting.Brightness = 0
                lighting.ClockTime = 0
                lighting.OutdoorAmbient = Color3.new(0, 0, 0)
                lighting.Ambient = Color3.new(0, 0, 0)
                lighting.FogColor = Color3.new(0, 0, 0)
                lighting.FogEnd = 100
            end
        end)
    end
    local function removeParticleEffects()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj:Destroy()
            end
        end
    end
    local function removeLightSources()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj:Destroy()
            end
        end
    end
    removeParticleEffects()
    removeLightSources()
    darkenSky()
end)
local PlayerData = {
    Backpack = player:WaitForChild("Backpack")
}
Misc:AddLabel(" QoL:").TextSize = 17
local ProteinEggLabel = settingsTab:AddLabel("Protein Eggs Owned: 0")
ProteinEggLabel.TextSize = 14
task.spawn(function()
    while true do
        local proteinEggCount = 0
        local tropicalShakeCount = 0
        if PlayerData.Backpack then
            for _, item in ipairs(PlayerData.Backpack:GetChildren()) do
                if item.Name == "Protein Egg" then
                    proteinEggCount = proteinEggCount + 1
                elseif item.Name == "Tropical Shake" then
                    tropicalShakeCount = tropicalShakeCount + 1
                end
            end
        end
        ProteinEggLabel.Text = "Protein Eggs: " .. proteinEggCount
        task.wait(7.5)
    end
end)
local ProteinEggBoostLabel = settingsTab:AddLabel("Protein Egg Boost: 00:00")
ProteinEggBoostLabel.TextSize = 14
local function formatTime(seconds)
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return string.format("%02d:%02d", m, s)
end
task.spawn(function()
    while true do
        local boostTimersFolder = game.Players.LocalPlayer:FindFirstChild("boostTimersFolder")
        if boostTimersFolder then
            local boost = boostTimersFolder:FindFirstChild("Protein Egg")
            if boost and boost:IsA("IntValue") then
                local seconds = boost.Value
                ProteinEggBoostLabel.Text = "Protein Egg Timer: " .. formatTime(seconds)
            else
                ProteinEggBoostLabel.Text = "Protein Egg Timer: 00:00"
            end
        else
            ProteinEggBoostLabel.Text = "Protein Egg Timer: 00:00"
        end
        task.wait(0.5)
    end
end)
local function useEggs()
    local boost = game.Players.LocalPlayer.boostTimersFolder:FindFirstChild("Protein Egg")
    if boost and boost:IsA("IntValue") then
        local seconds = boost.Value
        if seconds >= 5 then
            return
        end
    end
    local tool = player.Character:FindFirstChild("Protein Egg") or player.Backpack:FindFirstChild("Protein Egg")
    if tool then
        muscleEvent:FireServer("proteinEgg", tool)
    end
end
local running1 = false
task.spawn(function()
    while true do
        if running1 then
            useEggs()
            task.wait(1800)
        else
            task.wait(1)
        end
    end
end)
local autoEggSwitch = Misc:AddSwitch("Auto Egg", function(state)
    running1 = state
    if state then
        useEggs()
    end
end)

local statPetDropdown = Misc:AddDropdown("Pet Equip", function(text)
    local petsFolder = game.Players.LocalPlayer.petsFolder
    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                game:GetService("ReplicatedStorage").rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.2)
    local petName = text
    local petsToEquip = {}
    for _, pet in pairs(game.Players.LocalPlayer.petsFolder.Unique:GetChildren()) do
        if pet.Name == petName then
            table.insert(petsToEquip, pet)
        end
    end
    for i = 1, math.min(8, #petsToEquip) do
        game:GetService("ReplicatedStorage").rEvents.equipPetEvent:FireServer("equipPet", petsToEquip[i])
        task.wait(0.1)
    end
end)
statPetDropdown:Add("Swift Samurai")
statPetDropdown:Add("Tribal Overlord")

local function claimChests()
    local lp = game:GetService("Players").LocalPlayer
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        local oldCF = root.CFrame
        local chests = {
            Vector3.new(42.25, 1.5, 408.91),    
            Vector3.new(-138.43, 1.5, -276.86), 
            Vector3.new(-2569.81, 1.5, -554.07),
            Vector3.new(2206.88, 1.5, 910.50),  
            Vector3.new(-6713.64, 1.5, -1456.67),
            Vector3.new(4666.53, 995.0, -3692.08),
            Vector3.new(-7913.11, -1.5, 3019.15) 
        }
        
        for _, pos in ipairs(chests) do
            root.CFrame = CFrame.new(pos)
            task.wait(0.15) 
        end
        root.CFrame = oldCF
    end
end

Misc:AddButton("📦 Auto Claim Chest", function()
    claimChests()
end)

Misc:AddButton("🚀 FPS Booster", function()
    local lighting = game:GetService("Lighting")
    local terrain = game:GetService("Workspace"):FindFirstChildOfClass('Terrain')

    lighting.Brightness = 0.5
    lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 120)
    lighting.Ambient = Color3.fromRGB(120, 120, 120)
    lighting.ClockTime = 14

    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
    end
    
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        elseif v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Syniox Hub",
        Text = "FPS Boosted & Lighting Balanced!",
        Duration = 3
    })
end)

local afkActive = false

Misc:AddSwitch("⏳ Anti Afk", function(Value)
    afkActive = Value
    
    local Player = game:GetService("Players").LocalPlayer
    local PlayerGui = Player:FindFirstChildOfClass("PlayerGui")
    
    if Value then
        if PlayerGui:FindFirstChild("Syniox_GUI") then 
            PlayerGui.Syniox_GUI:Destroy() 
        end

        local TweenService = game:GetService("TweenService")
        local Stats = game:GetService("Stats")
        local RunService = game:GetService("RunService")

        local ScreenGui = Instance.new("ScreenGui", PlayerGui)
        ScreenGui.Name = "Syniox_GUI"

        local MainFrame = Instance.new("Frame", ScreenGui)
        MainFrame.Size = UDim2.new(0, 190, 0, 210)
        MainFrame.Position = UDim2.new(-0.3, 0, 0.4, 0)
        MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        MainFrame.Active = true
        MainFrame.Draggable = true
        Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
        local Stroke = Instance.new("UIStroke", MainFrame)
        Stroke.Color = Color3.fromRGB(160, 0, 0)
        Stroke.Thickness = 2

        local Title = Instance.new("TextLabel", MainFrame)
        Title.Size = UDim2.new(1, -40, 0, 40)
        Title.Position = UDim2.new(0, 15, 0, 0)
        Title.Text = "SYNIOX | AFK"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.BackgroundTransparency = 1

        local ToggleBtn = Instance.new("TextButton", MainFrame)
        ToggleBtn.Size = UDim2.new(0, 25, 0, 25)
        ToggleBtn.Position = UDim2.new(1, -35, 0, 7)
        ToggleBtn.Text = "-"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

        local StatContainer = Instance.new("Frame", MainFrame)
        StatContainer.Size = UDim2.new(1, -20, 0, 90)
        StatContainer.Position = UDim2.new(0, 10, 0, 40)
        StatContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Instance.new("UICorner", StatContainer).CornerRadius = UDim.new(0, 6)

        local function CreateTxt(text, pos)
            local lbl = Instance.new("TextLabel", StatContainer)
            lbl.Size = UDim2.new(1, 0, 0, 30)
            lbl.Position = pos
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.BackgroundTransparency = 1
            return lbl
        end

        local TxtTime = CreateTxt("  ⏳ 00:00:00", UDim2.new(0,0,0,0))
        local TxtFPS  = CreateTxt("  🚀 FPS: --", UDim2.new(0,0,0,30))
        local TxtMS   = CreateTxt("  📡 MS: --", UDim2.new(0,0,0,60))

        local BoostBtn = Instance.new("TextButton", MainFrame)
        BoostBtn.Size = UDim2.new(0, 170, 0, 40)
        BoostBtn.Position = UDim2.new(0.5, -85, 0, 150)
        BoostBtn.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
        BoostBtn.Text = "FPS BOOST"
        BoostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BoostBtn.Font = Enum.Font.GothamBold
        BoostBtn.TextSize = 14
        Instance.new("UICorner", BoostBtn).CornerRadius = UDim.new(0, 6)

        local isMinimized = false
        ToggleBtn.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            local targetSize = isMinimized and UDim2.new(0, 190, 0, 40) or UDim2.new(0, 190, 0, 210)
            
            TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize}):Play()
            
            StatContainer.Visible = not isMinimized
            BoostBtn.Visible = not isMinimized
            ToggleBtn.Text = isMinimized and "+" or "-"
        end)

        BoostBtn.MouseButton1Down:Connect(function()
            TweenService:Create(BoostBtn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 160, 0, 38)}):Play()
        end)

        BoostBtn.MouseButton1Up:Connect(function()
            TweenService:Create(BoostBtn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 170, 0, 40)}):Play()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") then v:Destroy() end
            end
        end)

        local VirtualUser = game:GetService("VirtualUser")
        local idledConn = Player.Idled:Connect(function() 
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new()) 
        end)

        local start = os.time()
        task.spawn(function()
            while afkActive do
                task.wait(0.5)
                if not isMinimized and MainFrame.Parent then
                    local d = os.time() - start
                    TxtTime.Text = string.format("  ⏳ %02d:%02d:%02d", math.floor(d/3600), math.floor((d%3600)/60), d%60)
                    TxtFPS.Text = "  🚀 FPS: " .. math.floor(1 / RunService.RenderStepped:Wait())
                    TxtMS.Text = "  📡 MS: " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end
            end
            if idledConn then idledConn:Disconnect() end
        end)

        TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.02, 0, 0.4, 0)}):Play()
    else
        if PlayerGui:FindFirstChild("Syniox_GUI") then
            PlayerGui.Syniox_GUI:Destroy()
        end
    end
end)

local switch = Misc:AddSwitch("🔒 Lock Position", function(Value)
    if Value then
        
        local currentPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        getgenv().posLock = game:GetService("RunService").Heartbeat:Connect(function()
            if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = currentPos
            end
        end)
    else
        
        if getgenv().posLock then
            getgenv().posLock:Disconnect()
            getgenv().posLock = nil
        end
    end
end)

Misc:AddSwitch("🎰 Auto Fortune Wheel", function(Value)
    _G.autoFortuneWheelActive = Value
    if Value then
        task.spawn(function()
            while _G.autoFortuneWheelActive do
                pcall(function()
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local wheelRemote = ReplicatedStorage.rEvents:FindFirstChild("openFortuneWheelRemote")
                    
                    local wheelChance = ReplicatedStorage:FindFirstChild("shared") 
                        and ReplicatedStorage.shared:FindFirstChild("catalogs") 
                        and ReplicatedStorage.shared.catalogs:FindFirstChild("fortuneWheelChances")
                        and ReplicatedStorage.shared.catalogs.fortuneWheelChances:FindFirstChild("Fortune Wheel")
                    
                    if wheelRemote and wheelChance then
                        wheelRemote:InvokeServer("openFortuneWheel", wheelChance)
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

local timeDropdown = Misc:AddDropdown("Change Time", function(selection)
    local lighting = game:GetService("Lighting")
    
    if selection == "Night" then
        lighting.ClockTime = 0
    elseif selection == "Day" then
        lighting.ClockTime = 12
    elseif selection == "Midnight" then
        lighting.ClockTime = 6
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Changed Time",
        Text = "the time has been changed: " .. selection,
        Duration = 0
    })
end)

timeDropdown:Add("Night")
timeDropdown:Add("Day")
timeDropdown:Add("Midnight")

Misc:AddButton("💎 Gamepass AutoLift", function()
    local gamepassFolder = game:GetService("ReplicatedStorage").gamepassIds
    local player = game:GetService("Players").LocalPlayer
    for _, gamepass in pairs(gamepassFolder:GetChildren()) do
        local value = Instance.new("IntValue")
        value.Name = gamepass.Name
        value.Value = gamepass.Value
        value.Parent = player.ownedGamepasses
    end
end, "🔓 Unlock AutoLift Pass")

local scriptFolder = Misc:AddFolder(" 📜 External Scripts")

scriptFolder:AddButton("⚡ Infinite Yield", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Syniox Hub",
        Text = "Infinite Yield Loaded!",
        Duration = 3
    })
end)

scriptFolder:AddButton("🕺 Emote Script", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))()
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Syniox Hub V2",
        Text = "Emote Script Activated!",
        Duration = 5
    })
end)

local parts = {}
local partSize = 2048
local totalDistance = 50000
local startPosition = Vector3.new(-2, -9.5, -2)
local numberOfParts = math.ceil(totalDistance / partSize)

local function createParts()
    for x = 0, numberOfParts - 1 do
        for z = 0, numberOfParts - 1 do
            local newPartSide = Instance.new("Part")
            newPartSide.Size = Vector3.new(partSize, 1, partSize)
            newPartSide.Position = startPosition + Vector3.new(x * partSize, 0, z * partSize)
            newPartSide.Anchored = true
            newPartSide.Transparency = 1
            newPartSide.CanCollide = true
            newPartSide.Name = "Part_Side_" .. x .. "_" .. z
            newPartSide.Parent = workspace
            table.insert(parts, newPartSide)
            
            local newPartLeftRight = Instance.new("Part")
            newPartLeftRight.Size = Vector3.new(partSize, 1, partSize)
            newPartLeftRight.Position = startPosition + Vector3.new(-x * partSize, 0, z * partSize)
            newPartLeftRight.Anchored = true
            newPartLeftRight.Transparency = 1
            newPartLeftRight.CanCollide = true
            newPartLeftRight.Name = "Part_LeftRight_" .. x .. "_" .. z
            newPartLeftRight.Parent = workspace
            table.insert(parts, newPartLeftRight)
            
            local newPartUpLeft = Instance.new("Part")
            newPartUpLeft.Size = Vector3.new(partSize, 1, partSize)
            newPartUpLeft.Position = startPosition + Vector3.new(-x * partSize, 0, -z * partSize)
            newPartUpLeft.Anchored = true
            newPartUpLeft.Transparency = 1
            newPartUpLeft.CanCollide = true
            newPartUpLeft.Name = "Part_UpLeft_" .. x .. "_" .. z
            newPartUpLeft.Parent = workspace
            table.insert(parts, newPartUpLeft)
            
            local newPartUpRight = Instance.new("Part")
            newPartUpRight.Size = Vector3.new(partSize, 1, partSize)
            newPartUpRight.Position = startPosition + Vector3.new(x * partSize, 0, -z * partSize)
            newPartUpRight.Anchored = true
            newPartUpRight.Transparency = 1
            newPartUpRight.CanCollide = true
            newPartUpRight.Name = "Part_UpRight_" .. x .. "_" .. z
            newPartUpRight.Parent = workspace
            table.insert(parts, newPartUpRight)
        end
    end
end

local function makePartsWalkthrough()
    for _, part in ipairs(parts) do
        if part and part.Parent then
            part.CanCollide = false
        end
    end
end

local function makePartsSolid()
    for _, part in ipairs(parts) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end
end

Misc:AddSwitch("🌊 Full Walk on Water", function(bool)
    if bool then
        createParts()
    else
        makePartsWalkthrough()
    end
end)

local autoEatBoostsEnabled = false

local boostsList = {
    "ULTRA Shake",
    "TOUGH Bar",
    "Protein Shake",
    "Energy Shake",
    "Protein Bar",
    "Energy Bar",
}

local function eatAllBoosts()
    local player = game.Players.LocalPlayer
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character or player.CharacterAdded:Wait()

    for _, boostName in ipairs(boostsList) do
        local boost = backpack:FindFirstChild(boostName)
        while boost do
            boost.Parent = character
            pcall(function()
                boost:Activate()
            end)
            task.wait(0)
            boost = backpack:FindFirstChild(boostName)
        end
    end
end

task.spawn(function()
    while true do
        if autoEatBoostsEnabled then
            eatAllBoosts()
            task.wait(2)
        else
            task.wait(1)
        end
    end
end)

Misc:AddSwitch("🍴 Auto Eat All (No Egg)", function(state)
    autoEatBoostsEnabled = state
end)

Misc:AddSwitch("⬆️ Infinite Jump", function(state)
    getgenv().InfiniteJump = state
    game:GetService("UserInputService").JumpRequest:connect(function()
        if getgenv().InfiniteJump then
            local Humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:ChangeState("Jumping")
            end
        end
    end)
end)

Misc:AddButton("🔄 Rejoin Game", function()
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local TextLabel = Instance.new("TextLabel")
    local YesButton = Instance.new("TextButton")
    local NoButton = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")

    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.Name = "RejoinConfirm"

    Frame.Name = "MainFrame"
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame.Position = UDim2.new(0.5, -125, 0.5, -75)
    Frame.Size = UDim2.new(0, 250, 0, 150)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true 
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    TextLabel.Parent = Frame
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0, 10, 0, 20)
    TextLabel.Size = UDim2.new(0, 230, 0, 50)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = "Are you sure you want to rejoin?"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 16
    TextLabel.TextWrapped = true

    YesButton.Name = "YesButton"
    YesButton.Parent = Frame
    YesButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    YesButton.Position = UDim2.new(0, 25, 0, 90)
    YesButton.Size = UDim2.new(0, 85, 0, 35)
    YesButton.Font = Enum.Font.GothamBold
    YesButton.Text = "YES"
    YesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesButton.TextSize = 14
    Instance.new("UICorner", YesButton).CornerRadius = UDim.new(0, 6)

    NoButton.Name = "NoButton"
    NoButton.Parent = Frame
    NoButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    NoButton.Position = UDim2.new(0, 140, 0, 90)
    NoButton.Size = UDim2.new(0, 85, 0, 35)
    NoButton.Font = Enum.Font.GothamBold
    NoButton.Text = "NO"
    NoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoButton.TextSize = 14
    Instance.new("UICorner", NoButton).CornerRadius = UDim.new(0, 6)

    YesButton.MouseButton1Click:Connect(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end)

    NoButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
end)

Misc:AddSwitch("🧱 Anti Knockback", function(Value)
    if Value then
        local playerName = game.Players.LocalPlayer.Name
        local rootPart = game.Workspace:FindFirstChild(playerName):FindFirstChild("HumanoidRootPart")
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.P = 1250
        bodyVelocity.Parent = rootPart
    else
        local playerName = game.Players.LocalPlayer.Name
        local rootPart = game.Workspace:FindFirstChild(playerName):FindFirstChild("HumanoidRootPart")
        local existingVelocity = rootPart:FindFirstChild("BodyVelocity")
        if existingVelocity and existingVelocity.MaxForce == Vector3.new(100000, 0, 100000) then
            existingVelocity:Destroy()
        end
    end
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local noclipEnabled = false
local noclipConnection = nil

local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if noclipEnabled and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

Misc:AddSwitch("👻 No Clip", function(bool)
    noclipEnabled = bool
    
    if noclipEnabled then
        startNoclip()
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

player.CharacterAdded:Connect(function()
    if noclipEnabled then
        task.wait(0.1)
        startNoclip()
    end
end)

local teleport = window:AddTab("Teleport")

teleport:AddButton("📍Spawn", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(2, 8, 115)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleported to Spawn",
        Duration = 0
    })
end)

teleport:AddButton("📍Secret Area", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(1947, 2, 6191)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleported to Secret Area",
        Duration = 0
    })
end)

teleport:AddButton("📍Tiny Island", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(-34, 7, 1903)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleported to Tiny Island",
        Duration = 0
    })
end)

teleport:AddButton("📍Frozen Island", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(- 2600.00244, 3.67686558, - 403.884369, 0.0873617008, 1.0482899e-09, 0.99617666, 3.07204253e-08, 1, - 3.7464023e-09, - 0.99617666, 3.09302628e-08, 0.0873617008)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleported to Frozen Island",
        Duration = 0
    })
end)

teleport:AddButton("📍Mythical Island", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(2255, 7, 1071)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleported to Mythical Island",
        Duration = 0
    })
end)

teleport:AddButton("📍Hell Island", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(-6768, 7, -1287)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleported to Hell Island",
        Duration = 0
    })
end)

teleport:AddButton("📍Legend Island", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(4604, 991, -3887)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleported to Legend Island",
        Duration = 0
    })
end)

teleport:AddButton("📍Muscle King Island", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(-8646, 17, -5738)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleported to Muscle King",
        Duration = 0
    })
end)

teleport:AddButton("📍Jungle Island", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(-8659, 6, 2384)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleported to Jungle Island",
        Duration = 0
    })
end)

teleport:AddButton("📍Brawl Lava", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(4471, 119, -8836)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleported to Brawl Lava",
        Duration = 0
    })
end)

teleport:AddButton("📍Brawl Desert", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(960, 17, -7398)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleported to Brawl Desert",
        Duration = 0
    })
end)

teleport:AddButton("📍Brawl Regular", function()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(-1849, 20, -6335)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleported to Brawl Regular",
        Duration = 0
    })
end)

local credits = window:AddTab("Credits")

local title = credits:AddLabel("✨ Syniox Hub V2")
title.TextColor3 = Color3.fromRGB(255, 215, 0)

local dev = credits:AddLabel("👤 Developer: Yusuf")
dev.TextColor3 = Color3.fromRGB(255, 50, 50)

credits:AddLabel("--------------------------")

local thanks = credits:AddLabel("🤝 Special Thanks to: Halis & Henne")
thanks.TextColor3 = Color3.fromRGB(0, 255, 255)

local support = credits:AddLabel("❤️ Thanks for the support!")
support.TextColor3 = Color3.fromRGB(255, 105, 180)

credits:AddLabel("--------------------------")

local useMsg = credits:AddLabel("🙏 Thank you for using Syniox Hub!")
useMsg.TextColor3 = Color3.fromRGB(255, 255, 255)

credits:AddLabel("👇 My Discord Server Link Here")

credits:AddButton("Discord Link", function()
    setclipboard("https://discord.gg/DbAU5Z6HPd")
end)

credits:AddLabel(" ")
credits:AddLabel("==================================")

local bigTitle = credits:AddLabel("🚀 SYNIOX HUB V3 🚀")

pcall(function()
    bigTitle.TextSize = 25
    bigTitle.Font = Enum.Font.GothamBold
end)

task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do
            bigTitle.TextColor3 = Color3.fromHSV(i, 1, 1)
            task.wait()
        end
    end
end)

credits:AddLabel("==================================")

