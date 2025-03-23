function love.load()
    camera = require('libraries/camera')
    cam = camera()
    
    anim8 = require('libraries/anim8')

    love.graphics.setDefaultFilter("nearest", "nearest")

    player = {}
    player.x = 300
    player.y = 200
    player.speed = 500

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
end

function love.update(dt)
    local moving = false

    if love.keyboard.isDown("w") then
        player.spriteSheet = player.spriteWalk
        player.anim = player.animation.walk.up
        player.lastDirection = "up"
        moving = true
    elseif love.keyboard.isDown("a") then
        player.spriteSheet = player.spriteWalk
        player.anim = player.animation.walk.left
        player.lastDirection = "left"
        moving = true
    elseif love.keyboard.isDown("s") then
        player.spriteSheet = player.spriteWalk
        player.anim = player.animation.walk.down
        player.lastDirection = "down"
        moving = true
    elseif love.keyboard.isDown("d") then
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
end

function love.draw()
    cam:attach()
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 3, nil, 24, 30)
    cam:detach()
end

