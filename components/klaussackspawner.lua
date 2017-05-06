--------------------------------------------------------------------------
--[[ KlausSackSpawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "KlausSackSpawner should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _spawners = {}
local _sack = nil
local _respawntask = nil
local _spawnedthiswinter = false

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function IsValidSpawner(x, y, z)
    x, y, z = TheWorld.Map:GetTileCenterPoint(x, 0, z)
    for _x = -1, 1 do
        for _z = -1, 1 do
            if not TheWorld.Map:IsPassableAtPoint(x + (_x * TILE_SCALE), 0, z + (_z * TILE_SCALE)) then
                return false
            end
        end
    end
    return true
end

local function SpawnKlausSack()
    local numstructsatspawn = {}

    _spawners = shuffleArray(_spawners)

    local x, y, z
    for i, v in ipairs(_spawners) do
        x, y, z = v.Transform:GetWorldPosition()
        if IsValidSpawner(x, y, z) and not IsAnyPlayerInRange(x, y, z, 35) then
            local structs = TheSim:FindEntities(x, y, z, 5, { "structure" })
            if #structs == 0 then
                break
            end
            numstructsatspawn[v] = #structs
        end
        x = nil
    end

    if x == nil then
        local best_count = 200
        for spawner, structs in pairs(numstructsatspawn) do
            if structs < best_count then
                best_count = structs
                x, y, z = spawner.Transform:GetWorldPosition()
            end
        end
    end

    if x == nil and #_spawners > 0 then
        local spawner = _spawners[math.random(#_spawners)]
        x, y, z = spawner.Transform:GetWorldPosition()
    end

    if x ~= nil then
        x, y, z = TheWorld.Map:GetTileCenterPoint(x, y, z)
        local sack = SpawnPrefab("klaus_sack")
        local structs = TheSim:FindEntities(x, y, z, 2, { "structure" })
        for i, v in ipairs(structs) do
            if v.components.workable ~= nil then
                v.components.workable:Destroy(sack)
            else
                v:Remove()
            end
        end
        sack.Transform:SetPosition(x, y, z)
    end
end

local function StopRespawnTimer()
    if _respawntask ~= nil then
        _respawntask:Cancel()
        _respawntask = nil
    end
end

local function OnRespawnTimer()
    _respawntask = nil
    if _sack == nil then
        SpawnKlausSack()
    end
end

local function StartRespawnTimer(t)
    if _sack == nil or not _sack:IsValid() then
        StopRespawnTimer()
        _respawntask = inst:DoTaskInTime(t, OnRespawnTimer)
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnRemoveSpawner(spawner)
    for i, v in ipairs(_spawners) do
        if v == spawner then
            table.remove(_spawners, i)
            return
        end
    end
end

local function OnRegisterSackSpawningPt(inst, spawner)
    for i, v in ipairs(_spawners) do
        if v == spawner then
            return
        end
    end

    table.insert(_spawners, spawner)
    inst:ListenForEvent("onremove", OnRemoveSpawner, spawner)
end

local function OnRemoveSack(sack)
    _sack = nil

    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        StartRespawnTimer(TUNING.KLAUSSACK_EVENT_RESPAWN_TIME)
    end
end

local function RegisterKlausSack(inst, sack)
    if _sack == nil or not _sack:IsValid() then
        _sack = sack
        inst:ListenForEvent("onremove", OnRemoveSack, sack)
    end
end

local function RestoreKlausSackKey(inst, key)
    if _sack ~= nil and _sack:IsValid() and _sack.OnDropKey ~= nil then
        _sack.OnDropKey(nil, key)
    end
end

local function QueueSack()
    if _respawntask == nil and TheWorld.state.iswinter and not _spawnedthiswinter and (_sack == nil or not _sack:IsValid()) then
        StartRespawnTimer(TUNING.KLAUSSACK_SPAWN_DELAY + math.random()*TUNING.KLAUSSACK_SPAWN_DELAY_VARIANCE)
    end

    _spawnedthiswinter = TheWorld.state.iswinter
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
inst:ListenForEvent("ms_registerdeerspawningground", OnRegisterSackSpawningPt)
inst:ListenForEvent("ms_registerklaussack", RegisterKlausSack)
inst:ListenForEvent("ms_restoreklaussackkey", RestoreKlausSackKey)
inst:WatchWorldState("iswinter", QueueSack)

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
    if IsSpecialEventActive( SPECIAL_EVENTS.WINTERS_FEAST ) then
        if _sack == nil and _respawntask == nil then
            OnRespawnTimer() -- spawns on day 1 for winters feast event
        end
    else
        QueueSack()
    end
end

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:LongUpdate(dt)
    if _respawntask ~= nil then
        local t = GetTaskRemaining(_respawntask)
        if t > dt then
            StartRespawnTimer(t - dt)
        else
            StopRespawnTimer()
            OnRespawnTimer()
        end
    end
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {}
    if _respawntask ~= nil then
        data.timetorespawn = math.ceil(GetTaskRemaining(_respawntask))
    end
    return data
end

function self:OnLoad(data)
    if data ~= nil and data.timetorespawn ~= nil then
        StartRespawnTimer(data.timetorespawn)
    end

    _spawnedthiswinter = TheWorld.state.iswinter
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local s = ""
    if _sack ~= nil and _sack:IsValid() then
        s = "Klaus Sack is in the world."
    elseif _respawntask ~= nil then
        s = string.format("Spawning in %.2f (%.2f days)", GetTaskRemaining(_respawntask), GetTaskRemaining(_respawntask) / TUNING.TOTAL_DAY_TIME)
    else
        s = "Waiting for winter."
    end
    return s
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)