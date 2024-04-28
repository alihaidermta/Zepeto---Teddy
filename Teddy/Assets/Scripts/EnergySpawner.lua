--!SerializeField
local energyOrb : GameObject = nil
--!SerializeField
local doorEnergy : GameObject = nil
--!SerializeField
local lightningPickup : GameObject = nil
--!SerializeField
local maxAmount : number = 10
--!SerializeField
local minAmount : number = 5
--!SerializeField
local spawnDistance : number = 15

--!SerializeField
local lightningChance : number = 10

activeOrbs = 0

function self:Start()
    for i = 1, 5 do

        local doorenergyobj = Object.Instantiate(doorEnergy)
        local doorenergyobjorbT = doorenergyobj.transform
        local newPosXdoor = math.random(-90,90)
        local newPosZdoor = math.random(-70,70)
        doorenergyobjorbT.position = Vector3.new(newPosXdoor, 1.2 , newPosZdoor)
    end
end
function self:Update()
    if(activeOrbs <= minAmount)then -- If the active orbs are less than the minimum amount, then spawn more
        amountToSpawn = maxAmount - activeOrbs
        for i = 1, amountToSpawn do

            local lightningRoll = math.random(1,100)
            if lightningRoll <= lightningChance then
                --Spawn Lightning Orb
                local newOrb = Object.Instantiate(lightningPickup)
                local orbT = newOrb.transform
                local newPosX = math.random(-spawnDistance,spawnDistance)
                local newPosZ = math.random(-spawnDistance,spawnDistance)
                orbT.position = Vector3.new(newPosX, 1.5, newPosZ)
                local orbScript = newOrb:GetComponent("EnergyOrbScript")
                orbScript.SpawnerScript = self.gameObject:GetComponent("EnergySpawner")
                orbScript.Energy = math.random(1,10)
                orbScript.UpdateSize()
            else
                -- Spawn Energy Orb
                local newOrb = Object.Instantiate(energyOrb)
                local orbT = newOrb.transform
                local newPosX = math.random(-spawnDistance,spawnDistance)
                local newPosZ = math.random(-spawnDistance,spawnDistance)
                orbT.position = Vector3.new(newPosX, 1.5, newPosZ)
                local orbScript = newOrb:GetComponent("EnergyOrbScript")
                orbScript.SpawnerScript = self.gameObject:GetComponent("EnergySpawner")
                orbScript.Energy = math.random(1,10)
                orbScript.UpdateSize()
            end
        end
    end 
end