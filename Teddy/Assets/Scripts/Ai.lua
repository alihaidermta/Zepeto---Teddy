--!SerializeField
local door : GameObject = nil
--!SerializeField
local UnlockedEnviroment : GameObject = nil
--!SerializeField
local PreviousEnv : GameObject = nil

function self:Start()
    
    print("hamza")
    
end

function activeDoor()
    door.gameObject.SetActive(door, false)
    UnlockedEnviroment.gameObject.SetActive(UnlockedEnviroment, true)
    PreviousEnv.gameObject.SetActive(PreviousEnv, true)
end

