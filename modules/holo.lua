-- please note that the maximum number of voxels that can exist at the same time is 4096!
-- holoprojector api

--     type - holoprojector
--     reset() - resets projector settings such as scale/offset/rotation
--     clear() - removes all voxels from the projector's RAM
--     addVoxel(x, y, z, color, voxel_type, localScale:vec3):voxelID - adds a voxel to the projector's RAM, the voxel type is omitted 0, the position relative to the center of the holographic projector. localScale allows you to change the size of a voxel independently of other voxels, as well as do it in different axes. localScale acts as a multiplier for the regular scale. default localScale: vec3(1, 1, 1)
--     delVoxel(voxelID) - deletes a voxel with the specified voxelID
--     flush() - renders voxels added to RAM however it is not recommended to make more than 2048 voxels
--     setOffset(x, y, z) / getOffset:x,y,z - sets the offset relative to the center of the holographic projector
--     setRotation(x, y, z) / getRotation:x,y,z - sets the rotation of the entire figure relative to the center of the holographic projector
--     setScale(x, y, z) / getScale:x,y,z - sets the scale
--     voxel_type 0 - transparent
--     voxel_type 1 - glowing
--     voxel_type 2 - regular block

local VoxelType = {
    transparent = 0,
    glowing = 1,
    regular = 2
}

local HoloDisplay = {
    holo = {},

    last_update = 0,
    max_distance = 100,
    display = { width = 16, length = 16, height = 16 }
}

function HoloDisplay:defineCorners()
    local coords = {self.display.width, -self.display.width}

    self.holo.addVoxel(0, 0, 0, "ffffff", VoxelType.glowing)

    for _, c1 in pairs(coords) do
       for _, c2 in pairs(coords) do
          for _, c3 in pairs(coords) do
             self.holo.addVoxel(c1, c2, c3, "000000", VoxelType.regular)
          end
       end
    end 
end

function HoloDisplay:register()
    self.holo = getHoloprojectors()[1]
    self.holo.setScale(0.05, 0.05, 0.05)
    self.holo.setRotation(0, 0, 0)
    self.holo.setOffset(0, self.display.height + 4, 0)
end

function HoloDisplay:update(targets)
    if Radar == nil or Radar.last_change ~= self.last_update then return end

    self.holo.clear()
    self.holo.flush()

    -- Draw voxels
    HoloDisplay:defineCorners()
    HoloDisplay:drawTargets(targets)

    self.holo.flush()
end

function HoloDisplay:drawTargets(targets)
    for _, entity in pairs(targets) do
        local distance = entity.object.distance

        if distance < self.max_distance then
            HoloDisplay:displayTarget(entity, distance)
         end

    end
end

function HoloDisplay:displayTarget(entity, distance)
    local angle = entity.radar_angle

    local x = ((distance * math.sin(angle)))
    local y = ((distance * math.cos(angle)))
    local z = 0

    local color = "ff0000"
    if entity.object.type == "character" then
        color = "0000ff"
    end

    self.holo.addVoxel(x, z, y, color, VoxelType.glowing)
end