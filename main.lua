local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()

local obj

function love.load()
    wf = require('libraries/windfield')
    world = wf.newWorld()
    world:addCollisionClass('Solid')
    world:addCollisionClass('Ghost', {ignores = {'Solid'}})

    camera = require('libraries/camera')
    cam = camera()
    --cam:zoom(3)
    
    anim8 = require('libraries/anim8')

    sti = require('libraries/sti')
    gamemap = sti('sprites/maps/tileset.lua')

    love.graphics.setDefaultFilter("nearest", "nearest")

    player = {}
    player.x = 300
    player.y = 200
    player.speed = 100

    player.spriteIdle = love.graphics.newImage('sprites/idle.png')
    player.gridIdle = anim8.newGrid(48, 64, player.spriteIdle:getWidth(), player.spriteIdle:getHeight())

    player.spriteWalk = love.graphics.newImage('sprites/walk.png')
    player.gridWalk = anim8.newGrid(48, 64, player.spriteWalk:getWidth(), player.spriteWalk:getHeight())

    player.idleFace = 1
    player.lastDirection = "down"

    player.animation = {}
    player.animation.idle = {
        up = anim8.newAnimation(player.gridIdle('1-8', 4), 0.1),
        left = anim8.newAnimation(player.gridIdle('1-8', 2), 0.1),
        down = anim8.newAnimation(player.gridIdle('1-8', 1), 0.1),
        right = anim8.newAnimation(player.gridIdle('1-8', 6), 0.1)
    }
    player.animation.walk = {
        up = anim8.newAnimation(player.gridWalk('1-8', 4), 0.1),
        left = anim8.newAnimation(player.gridWalk('1-8', 2), 0.1),
        down = anim8.newAnimation(player.gridWalk('1-8', 1), 0.1),
        right = anim8.newAnimation(player.gridWalk('1-8', 6), 0.1)
    }

    player.spriteSheet = player.spriteIdle
    player.anim = player.animation.idle

    player.collision = world:newBSGRectangleCollider(40, 375, 10, 20, 3)
    player.collision:setFixedRotation(true)
    player.collision:setCollisionClass('Solid')

    local obj = gamemap.layers['NextZone'].objects[1]
    local nextZone = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
    nextZone:setType('static')
    nextZone:setCollisionClass('Ghost')

    Blocks = {}
    if gamemap.layers['Block'] then
        for i, obj in pairs(gamemap.layers['Block'].objects) do
            local block = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            block:setType('static')
            block:setCollisionClass('Solid')
            table.insert(Blocks, block)
        end
    end
end

function love.update(dt)
    local moving = false
    local velX = 0
    local velY = 0

    if love.keyboard.isDown("w") then
        velY = player.speed * -1
        player.spriteSheet = player.spriteWalk
        player.anim = player.animation.walk.up
        player.lastDirection = "up"
        moving = true
    elseif love.keyboard.isDown("a") then
        velX = player.speed * -1
        player.spriteSheet = player.spriteWalk
        player.anim = player.animation.walk.left
        player.lastDirection = "left"
        moving = true
    elseif love.keyboard.isDown("s") then
        velY = player.speed
        player.spriteSheet = player.spriteWalk
        player.anim = player.animation.walk.down
        player.lastDirection = "down"
        moving = true
    elseif love.keyboard.isDown("d") then
        velX = player.speed
        player.spriteSheet = player.spriteWalk
        player.anim = player.animation.walk.right
        player.lastDirection = "right"
        moving = true
    end

    if not moving then
        player.spriteSheet = player.spriteIdle
        player.anim = player.animation.idle[player.lastDirection]
    end
    if player.collision:enter('nextZone') then
        love.graphics.print('Next Level', player.x, player.y)
    end

    player.anim:update(dt)
    cam:lookAt(player.x, player.y)


    player.collision:setLinearVelocity(velX, velY)
    world:update(dt)
    player.x = player.collision:getX()
    player.y = player.collision:getY()
    local mapW = gamemap.width * gamemap.tilewidth
    local mapH = gamemap.height * gamemap.tileheight

    local minX = mapW - (screenWidth * 0.99)
    local maxX = mapW - (screenWidth * -0.15)

    local minY = mapH - (screenHeight * -0.22)
    local maxY = mapH - (screenHeight * -1.165)
    
    if cam.x < minX then
        cam.x = minX
    end

    if cam.x > maxX then
        cam.x = maxX
    end

    if cam.y < minY then
        cam.y = minY
    end

    if cam.y > maxY then
        cam.y = maxY
    end
end

function love.draw()
    cam:attach()
    gamemap:drawLayer(gamemap.layers['BaseRoad'])
    gamemap:drawLayer(gamemap.layers['Base'])
    gamemap:drawLayer(gamemap.layers['Details'])
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 1, nil, 25, 32)
    gamemap:drawLayer(gamemap.layers['Props'])
    --world:draw()
    cam:detach()
end

