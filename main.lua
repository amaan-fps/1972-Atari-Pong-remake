push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

gameWidth, gameHeight = 320, 240

P1SCORE = 0
P2SCORE = 0
winner = 0

paddle_speed = 200

function love.load()
    love.window.setTitle("Retro Pong")
    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    math.randomseed(os.time())

    pixelfont = love.graphics.newFont("pixelfont.ttf", 18)
    scorefont = love.graphics.newFont("font.ttf", 18)
    fpsfont = love.graphics.newFont("font.ttf", 10)

    push:setupScreen(gameWidth, gameHeight, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    player1 = Paddle(10, 21, 7, 31)
    player2 = Paddle(gameWidth - 17, gameHeight - 50, 7, 31)
    ball = Ball(gameWidth/2 - 2, gameHeight / 2 - 2, 6, 6)
    serving_player = math.random(2)

    gamestate = "start"
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)

    if gamestate == "serve" then
        ball.dy = math.random(-50, 50)
        if serving_player == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    end
    if gamestate == "play" then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = ball.x + 6

            if ball.dy < 0 then
                ball.dy = -math.random(20, 50)
            else
                ball.dy = math.random(20, 50)
            end
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = ball.x - 5

            if ball.dy < 0 then
                ball.dy = -math.random(20, 50)
            else
                ball.dy = math.random(20, 50)
            end
        end

        if ball.y <= 0 then
            ball.y = 1
            ball.dy = -ball.dy
        end

        if ball.y >= gameHeight - 6 then
            ball.y = gameHeight - 7
            ball.dy = -ball.dy
        end

        if ball.x <= 0 then
            P1SCORE = P1SCORE + 1
            serving_player = 1
            gamestate = "serve"
            ball:reset()
        elseif ball.x >= gameWidth then
            P2SCORE = P2SCORE + 1
            serving_player = 2
            gamestate = "serve"
            ball:reset()
        end

        if P1SCORE == 10 then
            P1SCORE = 0
            P2SCORE = 0
            gamestate = "done"
        elseif P2SCORE == 10 then
            winner = 1
            P1SCORE = 0
            P2SCORE = 0
            gamestate = "done"
        end
    end

    if love.keyboard.isDown("w") then
        player1.dy = -paddle_speed
    elseif love.keyboard.isDown("s") then
        player1.dy = paddle_speed
    else
        player1.dy = 0
    end

    if love.keyboard.isDown("up") then
        player2.dy = -paddle_speed
    elseif love.keyboard.isDown("down") then
        player2.dy = paddle_speed
    else
        player2.dy = 0
    end

    player1:update(dt)
    player2:update(dt)

    if gamestate == "play" then
        ball:update(dt)
    end
end

function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()
    end

    if key == 'return' then
        if gamestate == "start" then
            gamestate = "serve"
        elseif gamestate == "serve" then
            gamestate = "play"
        elseif gamestate == "done" then
            gamestate = "start"
        end
    end
end

function love.draw()
    push:start()
    
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    
    if gamestate == "start" then
        love.graphics.setFont(pixelfont)
        love.graphics.printf("RETRO PONG", 0, gameHeight-30, gameWidth, "center")
        love.graphics.setFont(fpsfont)
        love.graphics.printf("Press Enter to start!", 0, 100, gameWidth, "center")
    elseif gamestate == "done" then
        love.graphics.setFont(pixelfont)
        
        if winner == 1 then
            love.graphics.print("P1 Wins!", gameWidth/2-20, 40)
        else
            love.graphics.print("P2 Wins!", gameWidth/2-20, 40)
        end
    else
        player1:render()
        player2:render()
        ball:render() 

        love.graphics.setFont(scorefont)
        love.graphics.print(tostring(P1SCORE), gameWidth/2-20, 20)
        love.graphics.print(tostring(P2SCORE), gameWidth/2+10, 20)

        displayFPS()
    end

    push:finish()
end

function displayFPS()

    love.graphics.setFont(fpsfont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('Fps: ' .. tostring(love.timer.getFPS()), 10, 10)
end