Sparkplug = class()
Sparkplug.maxParentCount = 1
Sparkplug.maxChildCount = 0
Sparkplug.connectionInput = sm.interactable.connectionType.logic

local DEFAULT_MAGNITUDE = 0

-- ============================================================
-- Server
-- ============================================================

function Sparkplug.server_onCreate(self)
    local saved = self.storage:load()
    self.sv = { magnitude = (saved and saved.magnitude) or DEFAULT_MAGNITUDE }
end

function Sparkplug.server_requestMagnitude(self, _)
    self.network:sendToClients("cl_setMagnitude", self.sv.magnitude)
end

function Sparkplug.server_onFixedUpdate(self, deltaTime)
    if self.shape:getBody():isOnLift() then return end
    local inputs = self.interactable:getParents()
    if #inputs == 1 then
        local active = inputs[1]:isActive()
        if active and self.sv.magnitude > 0 then
            sm.physics.explode(sm.shape.getWorldPosition(self.shape), 0, 1, 1, self.sv.magnitude)
        end
    end
end

function Sparkplug.server_setMagnitude(self, magnitude)
    self.sv.magnitude = magnitude
    self.storage:save({ magnitude = magnitude })
    self.network:sendToClients("cl_setMagnitude", magnitude)
end

-- ============================================================
-- Client
-- ============================================================

function Sparkplug.client_onCreate(self)
    self.cl = { magnitude = DEFAULT_MAGNITUDE }
end

function Sparkplug.cl_setMagnitude(self, magnitude)
    self.cl.magnitude = magnitude
    if self.cl.gui then
        self.cl.gui:setSliderData("Setting", 10, magnitude)
    end
end

function Sparkplug.client_onInteract(self, character, state)
    if state then
        self.network:sendToServer("server_requestMagnitude")
        self.cl.gui = sm.gui.createEngineGui()
        self.cl.gui:setText("Name", "Sparkplug")
        self.cl.gui:setText("SubTitle", "Spark Power")
        self.cl.gui:setText("Interaction", "Drag to adjust spark power")
        self.cl.gui:setIconImage("Icon", self.shape:getShapeUuid())
        self.cl.gui:setVisible("Upgrade", false)
        self.cl.gui:setOnCloseCallback("cl_onGuiClosed")
        self.cl.gui:setSliderCallback("Setting", "cl_onSliderChanged")
        self.cl.gui:setSliderData("Setting", 10, self.cl.magnitude)
        self.cl.gui:open()
    end
end

function Sparkplug.cl_onSliderChanged(self, _, sliderPos)
    self.cl.magnitude = sliderPos
    self.network:sendToServer("server_setMagnitude", sliderPos)
end

function Sparkplug.cl_onGuiClosed(self)
    self.cl.gui:destroy()
    self.cl.gui = nil
end