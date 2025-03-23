local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()

function love.load()
    wf = require('libraries/windfield')
    world = wf.newWorld()

    camera = require('libraries/camera')
    cam = camera()
    
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

    player.collision = world:newBSGRectangleCollider(40, 350, 10, 40, 3)
    player.collision:setFixedRotation(true)
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

    player.anim:update(dt)
    cam:lookAt(player.x, player.y)

    player.collision:setLinearVelocity(velX, velY)
    world:update(dt)
    player.x = player.collision:getX()
    player.y = player.collision:getY()
    local mapW = gamemap.width * gamemap.tilewidth
    local mapH = gamemap.height * gamemap.tileheight

    local minX = mapW - (screenWidth * 0.66)
    local maxX = mapW - (screenWidth * 0.18)

    local minY = mapH - (screenHeight * -0.56)
    local maxY = mapH - (screenHeight * -0.83)
    
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

    --cam.y = player.y + 150
end

function love.draw()
    cam:attach()
    gamemap:drawLayer(gamemap.layers['BaseRoad'])
    gamemap:drawLayer(gamemap.layers['Base'])
    gamemap:drawLayer(gamemap.layers['Details'])
    gamemap:drawLayer(gamemap.layers['Props'])
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 1.5, nil, 25, 32)
    --world:draw()
    cam:detach()
end

