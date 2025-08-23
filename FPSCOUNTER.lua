function love.load()
    -- Set window dimensions
    love.window.setMode(800, 600)
    love.window.setTitle("FPS and MS Counter")
    
    -- Colors
    background = {0.1, 0.1, 0.1}
    textColor = {0.5, 1, 0.5}
    shadowColor = {0, 0.2, 0}
    
    -- Font
    font = love.graphics.newFont(20)
    
    -- Initialize counters
    fps = 0
    frameTime = 0
    frameTimes = {}
    frameTimeSum = 0
    frameTimeCount = 0
end

function love.update(dt)
    -- Calculate FPS
    fps = love.timer.getFPS()
    
    -- Calculate frame time in milliseconds
    local currentFrameTime = dt * 1000
    
    -- Store frame times for averaging
    table.insert(frameTimes, currentFrameTime)
    frameTimeSum = frameTimeSum + currentFrameTime
    frameTimeCount = frameTimeCount + 1
    
    -- Keep only the last 60 frame times for a smoother average
    if #frameTimes > 60 then
        local oldTime = table.remove(frameTimes, 1)
        frameTimeSum = frameTimeSum - oldTime
        frameTimeCount = frameTimeCount - 1
    end
    
    -- Calculate average frame time
    if frameTimeCount > 0 then
        frameTime = frameTimeSum / frameTimeCount
    end
end

function love.draw()
    -- Clear screen with background color
    love.graphics.clear(background[1], background[2], background[3])
    
    -- Draw some content to make the FPS counter meaningful
    drawDemoContent()
    
    -- Set the font
    love.graphics.setFont(font)
    
    -- Prepare the text
    local fpsText = string.format("FPS: %d", fps)
    local msText = string.format("MS: %.2f", frameTime)
    local combinedText = fpsText .. " | " .. msText
    
    -- Calculate text position (top center)
    local textWidth = font:getWidth(combinedText)
    local x = (love.graphics.getWidth() - textWidth) / 2
    local y = 10
    
    -- Draw text shadow
    love.graphics.setColor(shadowColor[1], shadowColor[2], shadowColor[3], 1)
    love.graphics.print(combinedText, x + 1, y + 1)
    
    -- Draw actual text
    love.graphics.setColor(textColor[1], textColor[2], textColor[3], 1)
    love.graphics.print(combinedText, x, y)
end

function drawDemoContent()
    -- Draw some moving shapes to make the FPS counter meaningful
    local time = love.timer.getTime()
    
    -- Draw rotating rectangles
    for i = 1, 5 do
        local x = love.graphics.getWidth() / 2
        local y = love.graphics.getHeight() / 2
        local size = 50 + i * 20
        local rotation = time * 0.5 + i * 0.5
        
        love.graphics.push()
        love.graphics.translate(x, y)
        love.graphics.rotate(rotation)
        love.graphics.setColor(0.2 + i * 0.1, 0.4, 0.6, 0.7)
        love.graphics.rectangle("fill", -size/2, -size/2, size, size)
        love.graphics.pop()
    end
    
    -- Draw some bouncing circles
    for i = 1, 3 do
        local x = love.graphics.getWidth() / 2 + math.sin(time * 0.8 + i) * 150
        local y = love.graphics.getHeight() / 2 + math.cos(time * 0.6 + i) * 100
        local radius = 20 + i * 10
        
        love.graphics.setColor(0.8, 0.3, 0.2, 0.8)
        love.graphics.circle("fill", x, y, radius)
    end
end

function love.keypressed(key)
    -- Exit on escape key
    if key == "escape" then
        love.event.quit()
    end
end
