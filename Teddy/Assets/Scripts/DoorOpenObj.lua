local door = require("Ai")


function self:OnTriggerEnter(collider)
    print("door trigger")
    colliderCharacter = collider.gameObject:GetComponent(Character)
   
    player = colliderCharacter.player -- Player Info
    if(client.localPlayer == player)then
        door.activeDoor()
        
    end
end