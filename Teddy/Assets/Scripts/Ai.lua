--!SerializeField
local door : GameObject = nil
--!SerializeField
local UnlockedEnviroment : GameObject = nil
--!SerializeField
local PreviousEnv : GameObject = nil
--!SerializeField
local GamePlayInit : GameObject = nil
--!SerializeField
local GameWon : GameObject = nil
--!SerializeField
local GameLoose : GameObject = nil
function self:Start()
    
    print("hamza")
   
end

function activeDoor()
    door.gameObject.SetActive(door, false)
    UnlockedEnviroment.gameObject.SetActive(UnlockedEnviroment, true)
    PreviousEnv.gameObject.SetActive(PreviousEnv, true)
end


function GamePlayInit_Func()
    GamePlayInit.SetActive(GamePlayInit, true)
    print("timer print hua hy ")
    local newTimer = Timer.new(5, function() GamePlayInit.SetActive(GamePlayInit, false) end, false)
end

function Won_Func()
    GameWon.SetActive(GameWon, true)
    print("timer print hua hy ")
    local newTimer = Timer.new(3, function() GameWon.SetActive(GameWon, false) end, false)
end

function Loose_Func()
    GameLoose.SetActive(GameLoose, true)
    print("timer print hua hy ")
    local newTimer = Timer.new(3, function() GameLoose.SetActive(GameLoose, false) end, false)
end

