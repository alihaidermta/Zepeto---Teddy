--!SerializeField
local EnergyOrb : GameObject = nil
--!SerializeField
local LightningEffect : GameObject = nil
--!SerializeField
local Camera : GameObject = nil
--!SerializeField
local Panel_GameplayInit : GameObject = nil
--!SerializeField
local WonPanel : GameObject = nil
--!SerializeField
local LoosePanel : GameObject = nil

local character = client.localPlayer.character
addEnergyRequest = Event.new("AddEnergyRequest")
destroyPlayerRequest = Event.new("DestroyPlayerRequest")
destroyPlayerEvent = Event.new("DestroyPlayerEvent")

strikeKaijuReq = Event.new("StrikeKaijuReq")
strikeKaijuEvent = Event.new("StrikeKaijuEvent")

respawnRadius = 35 -- Max distance from the center to respawn after being destroyed
players = {}
playerPowers = {}
kingKaiju = nil






local function TrackPlayers(game, characterCallback)
    scene.PlayerJoined:Connect(function(scene, player)
        players[player] = {
            player = player,
            power = IntValue.new("power" .. tostring(player.id), 0)
           
        }
        print("player id " .. player.id)
       
        player.CharacterChanged:Connect(function(player, character) 
            local playerinfo = players[player]
            if (character == nil) then
                return
            end 
            
            if(player.id==1)then
                character.name="Agent"
                character.tag="agent"
                
            end

            if characterCallback then
                characterCallback(playerinfo)
            end
        end)
    end)

    game.PlayerDisconnected:Connect(function(player)
        players[player] = nil
        playerPowers[player] = nil
    end)
end

local function findMaxKey(tbl)
    local maxKey = nil
    local maxValue = -math.huge -- Start with negative infinity as initial maximum value

    for key, value in pairs(tbl) do
        if value > maxValue then
            maxValue = value
            maxKey = key
        elseif value == maxValue then
            maxValue = value
            maxKey = nil
        end
    end

    return maxKey
end
function GamePlayInit_Func()
    Panel_GameplayInit.SetActive(Panel_GameplayInit, true)
    print("timer print hua hy ")
    local newTimer = Timer.new(5, function() Panel_GameplayInit.SetActive(Panel_GameplayInit, false) end, false)
end

function Won_Func()
    WonPanel.SetActive(WonPanel, true)
    print("timer print hua hy ")
    local newTimer = Timer.new(3, function() WonPanel.SetActive(WonPanel, false) end, false)
end

function Loose_Func()
    LoosePanel.SetActive(LoosePanel, true)
    print("timer print hua hy ")
    local newTimer = Timer.new(3, function() LoosePanel.SetActive(LoosePanel, false) end, false)
end
--[[

    Client

--]]
function self:ClientAwake()

    function OnCharacterInstantiate(playerinfo)
        local player = playerinfo.player
        local character = player.character
        print("Client awake")
       
        --The function to run everytime someones power level changes to sync up scores and scales
        playerinfo.power.Changed:Connect(function(powerLevel, oldVal)
            local newScale = 1 + (powerLevel * .01) -- Scale is always 1 + the power level factored by .01
            print(tostring(player.name .. " has a power: " .. powerLevel))
            character.renderScale = Vector3.new(newScale, newScale, newScale)
            
            --Play the glowUp particle for the player getting energy
            character.gameObject:GetComponentInChildren(ParticleSystem).transform.localScale = Vector3.new(newScale, newScale, newScale) --adjust the scale of the particle effect to match the character scale
            character.gameObject:GetComponentInChildren(ParticleSystem):Play()

            --Check for King Kaiju, the p[layewr with the most power
            playerPowers[player] = powerLevel
            kingKaiju = findMaxKey(playerPowers)
            if(kingKaiju)then
                for player, power in pairs(playerPowers) do
                    if(player.character.gameObject.transform:GetChild(2):GetChild(0))then
                        player.character.gameObject.transform:GetChild(2):GetChild(0).gameObject:SetActive(false)
                    end
                end
                if(kingKaiju.character.gameObject.transform:GetChild(2):GetChild(0))then
                    kingKaiju.character.gameObject.transform:GetChild(2):GetChild(0).gameObject:SetActive(true)
                end
            end

        end)
    end

    -- Spawn an Energy Group with timed Orbs for everyone independantly when someone is destroyed
    function spawnEnergyGroup(amount, radius, playerPos)
        
        print("GROUP: " .. tostring(amount))
        for i = 1, amount do
            local newOrb = Object.Instantiate(EnergyOrb)
            local orbT = newOrb.transform
            local newPosX, newPosZ = playerPos.x + math.random(-radius,radius), playerPos.z + math.random(-radius,radius)
            orbT.position = Vector3.new(newPosX, 0, newPosZ)
    
            local orbScript = newOrb:GetComponent("EnergyOrbScript")
            orbScript.SpawnerScript = self.gameObject:GetComponent("EnergySpawner")
            orbScript.Energy = 1
            orbScript.UpdateSize()
        end
    end

    
    --AddEnergy() adds energy to which ever client calls the function
    function AddEnergy(amount)
        addEnergyRequest:FireServer(amount)
    end

    function StrikeKaiju(energy)
        if kingKaiju then
            -- Damage the King Kaiju
            strikeKaijuReq:FireServer(energy, kingKaiju)
        end
    end

    strikeKaijuEvent:Connect(function(kaiju)
        local newLightningEffect = Object.Instantiate(LightningEffect)
        local lightingT = newLightningEffect.transform
        lightingT.position = kaiju.character.transform.localPosition
        lightingT.parent = kaiju.character.transform
    end)

    TrackPlayers(client, OnCharacterInstantiate)
end

function self:ClientStart() --Moved the Destroy functions to Start since we need to use GetComponent on an outside object to reset the camera

    local CamScript = Camera:GetComponent("CameraController")
    print("Client start")
    GamePlayInit_Func()
    --DestroyPlayer() destroy and respawn a player after they are beaten in a collision
    function DestroyPlayer(victim) -- We dont want destroy the one who calls it because that will be the winner of the collision, so we need to pass a paramater
        destroyPlayerRequest:FireServer(victim) -- Pass a paramater through the event
    end

    --Locally Destroy a player now that the server has sent the Event
    destroyPlayerEvent:Connect(function(victim, pos, tempPower)
        --Spawn a group of Orbs before moving the player
        local energyToSpawn = math.floor(tempPower/2) -- The amount of orbs to spawn when the player dies
        local groupPosition = victim.character.transform.position
        local groupRadius = energyToSpawn * .2
        spawnEnergyGroup(energyToSpawn, groupRadius, groupPosition)
       

        -- Dont actually Destroy the character, just disable, respawn, and reenable them with a reset power level
        victim.character.gameObject:SetActive(false)
        victim.character.transform.position = pos
        victim.character.gameObject:SetActive(true)

        --Play the glowUp particle for the player getting destroyed
        victim.character.gameObject:GetComponentInChildren(ParticleSystem):Play()

        --Center the Camera on the player after Respawn
        if(victim == client.localPlayer)then
            CamScript.CenterOn(pos)
        end 
    end)
end


--[[

    Server

--]]
function self:ServerAwake()
    TrackPlayers(server)
    print("server start")
    
    addEnergyRequest:Connect(function(player, amount) -- Here the player is just the client that sent the request to the server, so when AddEnergy() is called it gives energy to whoever calls it
        local playerInfo = players[player]
        local playerPower = playerInfo.power.value
        local playerPower = playerPower + amount
        playerInfo.power.value = playerPower
    end)

    strikeKaijuReq:Connect(function(player, energy, kaiju)
        local playerInfo = players[kaiju]
        local playerPower = playerInfo.power.value
        local playerPower = playerPower - energy*5
        if playerPower <= 0 then
            playerPower = 0
        end
        
        playerInfo.power.value = playerPower
        strikeKaijuEvent:FireAllClients(kaiju)
        
    end)

     -- The first paramater in the request is the player requesting it, the second is the custom paramater we included 
    destroyPlayerRequest:Connect(function(player, victim) -- Connect to a Destroy player request from a client, then send the event to all clients
        -- We need to randomize therespawn position or else someone could just sit in the middle and pin people
        local x, y, z = math.random(-respawnRadius,respawnRadius),0,math.random(-respawnRadius,respawnRadius)
        local pos = Vector3.new(x,y,z)
        victim.character.transform.position = pos

        local playerInfo = players[victim]
        local playerPower = 0
        local tempPower = playerInfo.power.value -- Storing the power of the victim before setting it to zero so we can pass it down to the energy group spawner
        playerInfo.power.value = playerPower

        destroyPlayerEvent:FireAllClients(victim, pos, tempPower)
    end)
end