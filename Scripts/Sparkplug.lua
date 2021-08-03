Sparkplug = class()
Sparkplug.maxParentCount = 1
Sparkplug.maxChildCount = 0
Sparkplug.connectionInput = sm.interactable.connectionType.logic

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

function Sparkplug.server_onFixedUpdate(self, deltaTime)
    local inputs = self.interactable:getParents()
    if #inputs == 1 then
        local active = inputs[1]:isActive()
        if active then
            sm.physics.explode(sm.shape.getWorldPosition(self.shape), 0, 1, 1, 1)
        end
    end
end