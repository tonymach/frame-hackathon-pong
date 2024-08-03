-- Pong Lua
-- Initialize paddle and ball positions
local paddle1_y = 200
local paddle2_y = 200
local ball_x = 320
local ball_y = 200
local ball_dx = 10
local ball_dy = 10
-- Paddle dimensions
local paddle_width = 10
local paddle_height = 60
-- Score
local score1 = 0
local score2 = 0
-- Screen dimensions
local screen_width = 640
local screen_height = 400
-- Buffer to keep elements visible
local top_buffer = 10
local bottom_buffer = 30 -- Increased to account for potential hidden area
local side_buffer = 10

-- Helper function to keep a value within bounds
local function clamp(val, min, max)
    return math.max(min, math.min(val, max))
end

-- Enable auto exposure for the camera
frame.camera.auto(true, 'average')

-- Enable tap callback (optional, for demonstration)
frame.imu.tap_callback(function() print('Tap!') end)

while true do
    local imu_data = frame.imu.direction()
    local roll = imu_data['roll']

    -- Update left paddle position based on roll
    paddle1_y = paddle1_y + roll * 0.5
    -- Keep paddle on screen
    paddle1_y = clamp(paddle1_y, top_buffer, screen_height - bottom_buffer - paddle_height)

    -- Simple AI for right paddle: follow the ball
    if ball_y > paddle2_y + paddle_height/2 then
        paddle2_y = paddle2_y + 1.5
    elseif ball_y < paddle2_y + paddle_height/2 then
        paddle2_y = paddle2_y - 1.5
    end
    paddle2_y = clamp(paddle2_y, top_buffer, screen_height - bottom_buffer - paddle_height)

    -- Move ball
    ball_x = ball_x + ball_dx
    ball_y = ball_y + ball_dy

    -- Ball collision with top and bottom
    if ball_y <= top_buffer then
        ball_dy = math.abs(ball_dy)
        ball_y = top_buffer + 1
    elseif ball_y >= screen_height - bottom_buffer then
        ball_dy = -math.abs(ball_dy)
        ball_y = screen_height - bottom_buffer - 1
    end

    -- Ball collision with paddles
    if (ball_dx < 0 and ball_x <= paddle_width + side_buffer and ball_y >= paddle1_y and ball_y <= paddle1_y + paddle_height) or
       (ball_dx > 0 and ball_x >= screen_width - paddle_width - side_buffer and ball_y >= paddle2_y and ball_y <= paddle2_y + paddle_height) then
        ball_dx = -ball_dx
        -- Add some randomness to the ball's vertical direction
        ball_dy = ball_dy + (math.random() - 0.5) * 2
        -- Ensure ball_dy is not too close to zero
        if math.abs(ball_dy) < 2 then
            ball_dy = 2 * (ball_dy > 0 and 1 or -1)
        end
    end

    -- Score points and reset ball
    if ball_x <= side_buffer then
        score2 = score2 + 1
        ball_x, ball_y = screen_width/2, screen_height/2
        ball_dx = 10
        ball_dy = 10 * (math.random() > 0.5 and 1 or -1)
    elseif ball_x >= screen_width - side_buffer then
        score1 = score1 + 1
        ball_x, ball_y = screen_width/2, screen_height/2
        ball_dx = -10
        ball_dy = 10 * (math.random() > 0.5 and 1 or -1)
    end

    -- Draw paddles
    for i = 0, paddle_height - 1 do
        frame.display.text("|", side_buffer, math.floor(paddle1_y) + i, {color = 'WHITE'})
        frame.display.text("|", screen_width - side_buffer, math.floor(paddle2_y) + i, {color = 'WHITE'})
    end

    -- Draw ball
    frame.display.text("O", math.floor(ball_x), math.floor(ball_y), {color = 'YELLOW'})

    -- Draw scores
    frame.display.text(tostring(score1), screen_width/4, 20, {color = 'WHITE', scale = 2})
    frame.display.text(tostring(score2), 3*screen_width/4, 20, {color = 'WHITE', scale = 2})

    -- Draw bottom boundary line (for debugging)
    for i = 0, screen_width - 1 do
        frame.display.text("-", i, screen_height - bottom_buffer, {color = 'WHITE'})
    end

    frame.display.show()
    frame.sleep(0.005)
end