Sparkplug = class()
Sparkplug.maxParentCount = 1
Sparkplug.maxChildCount = 0
Sparkplug.connectionInput = sm.interactable.connectionType.logic

function Sparkplug.server_onFixedUpdate(self, deltaTime)
    if self.shape:getBody():isOnLift() then return end
    local inputs = self.interactable:getParents()
    if #inputs == 1 then
        local active = inputs[1]:isActive()
        if active then
            sm.physics.explode(sm.shape.getWorldPosition(self.shape), 0, 1, 1, 1)
        end
    end
end