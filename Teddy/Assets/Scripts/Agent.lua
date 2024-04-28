--!SerializeField
local particles : ParticleSystem = nil
function self:OnTriggerEnter(collider)
    print("agent trigger ho gya ")
    if(collider.tag == "agent") then
        print("agent trigger ho gya ")
        Object.Destroy(self.gameObject)
        particles.Play(particles, true)
    end



end
