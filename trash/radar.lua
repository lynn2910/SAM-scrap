--[[

    Documentation: https://github.com/igorkll/SComputers_docs/blob/main/SComputers/Components/gps.md

]]

utils = require("utils")
gps = getComponents("gps")[1]


local Radar = {
	radar = {},
    -- The angle in degrees, from 0° to 360°, and loop back when overflowing
    angle = 0,
    -- The FOV of the camera on the vertical and horizontal axis, in radians
    fov = { h = math.rad(10), v = math.pi },
    rotation_speed = 360 / (40 * 2),

    temp_targets = {},
    -- number of targets in a single rotation
    total_targets = {},

    targets_hangles = {},
    targets_vhangles = {},
}

function Radar:getTargets()
	return self.temp_targets;
end

function Radar:register()
	self.radar = getComponent("radar")
	self:update({ rotate = false, update_system = true })

    print("Radar initiated")

    -- print("a")
    -- print(gps)
    -- local gpsdata = gps.getSelfGpsData()
    -- print("b")

    -- print("------------------------------------------------")
    -- print("position-self", utils.roundTo(gpsdata.position.x, 1), utils.roundTo(gpsdata.position.y, 1), utils.roundTo(gpsdata.position.z, 1))
    -- print("rotation-self", utils.roundTo(gpsdata.rotation.x, 1), utils.roundTo(gpsdata.rotation.y, 1), utils.roundTo(gpsdata.rotation.z, 1), utils.roundTo(gpsdata.rotation.w, 1))
    -- print("rotation-euler-self", utils.roundTo(gpsdata.rotationEuler.x, 1), utils.roundTo(gpsdata.rotationEuler.y, 1), utils.roundTo(gpsdata.rotationEuler.z, 1))
    -- for i, v in ipairs(gps.getTagsGpsData(0)) do
    --     print("position-tag:" .. tostring(i), utils.roundTo(v.position.x, 1), utils.roundTo(v.position.y, 1), utils.roundTo(v.position.z, 1))
    --     print("rotation-tag:" .. tostring(i), utils.roundTo(v.rotation.x, 1), utils.roundTo(v.rotation.y, 1), utils.roundTo(v.rotation.z, 1), utils.roundTo(v.rotation.w, 1))
    --     print("rotation-euler-tag:" .. tostring(i), utils.roundTo(gpsdata.rotationEuler.x, 1), utils.roundTo(gpsdata.rotationEuler.y, 1), utils.roundTo(gpsdata.rotationEuler.z, 1))
    -- end
end

function Radar:update(opt)
    self.temp_targets = self.radar.getTargets()
    
    for _, target in pairs(self.temp_targets) do
        if self.total_targets[target[1]] == nil then
            self.total_targets[target[1]] = true
        end
    end


    Radar:registerTargetsPositions()

    -- Update the andle and loop back when overflowing
    if opt ~= nil then
        if opt.update_system then
    	    if self.radar.getHFov() ~= self.fov.h then self.radar.setHFov(self.fov.h) end
            if self.radar.getVFov() ~= self.fov.v then self.radar.setVFov(self.fov.v) end
        end

        if opt.rotate then
            self.angle = self.angle + self.rotation_speed
			if self.angle > 360 then
                self.angle = self.angle - 360
                -- TODO need to clear the targets_hangles
                self.targets_hangles = {}
                self.targets_vhangles = {}
                self.total_targets = {}
             end
            
	        self.radar.setAngle(math.rad(self.angle))
		end
    end
end

function Radar:registerTargetsPositions()
    for _, target in pairs(self:getTargets()) do
        local id = target[1]
        -- if the target isn't registered, we'll clear it
        if self.targets_hangles[id] == nil then
            self.targets_hangles[id] = {}
        end

        -- insert the hangle
        table.insert(self.targets_hangles[id], math.deg(target[2]))

        if self.targets_vhangles[id] == nil then
            self.targets_vhangles[id] = {}
        end

        -- insert the hangle
        table.insert(self.targets_vhangles[id], math.deg(target[3]))
    end
end

function Radar:getTargetHAngles(id)
    return self.targets_hangles[id] or {}
end

function Radar:getTargetVAngles(id)
    return self.targets_vhangles[id] or {}
end

function Radar:getCycleTargetsCount()
    local i = 0

    for _, _ in pairs(self.total_targets) do
        i = i + 1
    end

    return i
end