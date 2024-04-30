
--!SerializeField
local particles : ParticleSystem = nil
--!SerializeField
local indicator : GameObject = nil

local playerManagerScript = require("PlayerManager")

function self:Start()
    if(self.tag=="agent") then
        indicator.SetActive(indicator, true)
        
    end
end



function self:OnTriggerEnter(collider)
    print("agent trigger ho gya ")
    if(collider.tag == "agent") then
        print("agent trigger ho gya ")
        playerManagerScript.Loose_Func()
        Object.Destroy(self.gameObject)
        particles.Play(particles, true)
    end



end
