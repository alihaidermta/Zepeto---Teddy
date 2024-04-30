local door = require("Ai")
local playerManagerScript = require("PlayerManager")

function self:OnTriggerEnter(collider)
    print("door trigger")
    colliderCharacter = collider.gameObject:GetComponent(Character)
   
    player = colliderCharacter.player -- Player Info
    if(client.localPlayer == player)then
        door.activeDoor()
        playerManagerScript.Won_Func()
    end
end