-- Game states
local STATE_MENU = 1
local STATE_PLAYING = 2
local STATE_PAUSED = 3
local STATE_GAME_OVER = 4
local current_state = STATE_MENU

-- Initialize paddle and ball positions
local paddle1_y = 200
local paddle2_y = 200
local ball_x = 320
local ball_y = 200
local ball_dx = 5
local ball_dy = 5

-- Paddle dimensions
local paddle_width = 10
local paddle_height = 60

-- Score
local score1 = 0
local score2 = 0
local winning_score = 11

-- Screen dimensions
local screen_width = 640
local screen_height = 400

-- Buffer to keep elements visible
local top_buffer = 10
local bottom_buffer = 30
local side_buffer = 10

-- Frame counter for menu animation
local frame_counter = 0

-- Helper function to keep a value within bounds
local function clamp(val, min, max)
    return math.max(min, math.min(val, max))
end

-- Function to reset the game
local function reset_game()
    paddle1_y = screen_height / 2 - paddle_height / 2
    paddle2_y = screen_height / 2 - paddle_height / 2
    ball_x = screen_width / 2
    ball_y = screen_height / 2
    ball_dx = 5 * (math.random() > 0.5 and 1 or -1)
    ball_dy = 5 * (math.random() > 0.5 and 1 or -1)
    score1 = 0
    score2 = 0
end

-- Function to start a new round
local function new_round()
    ball_x = screen_width / 2
    ball_y = screen_height / 2
    ball_dx = 5 * (math.random() > 0.5 and 1 or -1)
    ball_dy = 5 * (math.random() > 0.5 and 1 or -1)
end

-- Enable auto exposure for the camera
frame.camera.auto(true, 'average')

-- Enable tap callback for game control
frame.imu.tap_callback(function()
    if current_state == STATE_MENU then
        reset_game()
        current_state = STATE_PLAYING
    elseif current_state == STATE_PLAYING then
        current_state = STATE_PAUSED
    elseif current_state == STATE_PAUSED then
        current_state = STATE_PLAYING
    elseif current_state == STATE_GAME_OVER then
        reset_game()
        current_state = STATE_PLAYING
    end
end)

-- Function to draw the menu
local function draw_menu()
    frame.display.text("PONG", screen_width/2 - 20, screen_height/4, {color = 'WHITE', scale = 2})
    frame.display.text("Tilt to move paddle", screen_width/2 - 60, screen_height/2 - 40, {color = 'WHITE'})
    frame.display.text("First to 11 wins", screen_width/2 - 50, screen_height/2, {color = 'WHITE'})
    frame.display.text("Tap to Start", screen_width/2 - 40, screen_height/2 + 40, {color = 'WHITE'})
    frame.display.text("Tap to Pause", screen_width/2 - 45, screen_height/2 + 80, {color = 'WHITE'})
end

while true do
    frame_counter = frame_counter + 1
    
    if current_state == STATE_PLAYING then
        local imu_data = frame.imu.direction()
        local roll = imu_data['roll']
        
        -- Update left paddle position based on roll
        paddle1_y = paddle1_y + roll * 3  -- Increased sensitivity for better control
        paddle1_y = clamp(paddle1_y, top_buffer, screen_height - bottom_buffer - paddle_height)
        
        -- Improved AI for right paddle
        local paddle2_target = ball_y - paddle_height / 2
        paddle2_y = paddle2_y + (paddle2_target - paddle2_y) * 0.15  -- Smoother AI movement
        paddle2_y = clamp(paddle2_y, top_buffer, screen_height - bottom_buffer - paddle_height)
        
        -- Move ball
        ball_x = ball_x + ball_dx
        ball_y = ball_y + ball_dy
        
        -- Ball collision with top and bottom
        if ball_y <= top_buffer or ball_y >= screen_height - bottom_buffer then
            ball_dy = -ball_dy
            ball_y = clamp(ball_y, top_buffer, screen_height - bottom_buffer)
        end
        
        -- Ball collision with paddles
        if (ball_dx < 0 and ball_x <= paddle_width + side_buffer and ball_y >= paddle1_y and ball_y <= paddle1_y + paddle_height) or
           (ball_dx > 0 and ball_x >= screen_width - paddle_width - side_buffer and ball_y >= paddle2_y and ball_y <= paddle2_y + paddle_height) then
            ball_dx = -ball_dx * 1.05  -- Slight speed increase on paddle hit
            ball_dy = ball_dy + (math.random() - 0.5) * 2  -- Add some randomness to vertical direction
            if math.abs(ball_dy) < 2 then
                ball_dy = 2 * (ball_dy > 0 and 1 or -1)
            end
        end
        
        -- Score points and reset ball
        if ball_x <= side_buffer then
            score2 = score2 + 1
            new_round()
        elseif ball_x >= screen_width - side_buffer then
            score1 = score1 + 1
            new_round()
        end
        
        -- Check for game over
        if score1 >= winning_score or score2 >= winning_score then
            current_state = STATE_GAME_OVER
        end
    end
    
    
    if current_state == STATE_MENU then
        if frame_counter % 30 == 0 then  -- Update menu every 30 frames (about 0.5 seconds)
            draw_menu()
        end
    elseif current_state == STATE_PLAYING or current_state == STATE_PAUSED then
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
        
        -- Draw center line
        for i = top_buffer, screen_height - bottom_buffer, 10 do
            frame.display.text("|", screen_width/2, i, {color = 'WHITE'})
        end
        
        -- Draw pause overlay
        if current_state == STATE_PAUSED then
            frame.display.text("PAUSED", screen_width/2 - 30, screen_height/2 - 20, {color = 'WHITE', scale = 2})
            frame.display.text("Tap to Resume", screen_width/2 - 50, screen_height/2 + 20, {color = 'WHITE'})
        end
    elseif current_state == STATE_GAME_OVER then
        local winner = score1 > score2 and "Player 1" or "Player 2"
        frame.display.text("Game Over", screen_width/2 - 40, screen_height/3, {color = 'WHITE', scale = 2})
        frame.display.text(winner .. " wins!", screen_width/2 - 40, screen_height/2 - 20, {color = 'WHITE'})
        frame.display.text(score1 .. " - " .. score2, screen_width/2 - 20, screen_height/2 + 20, {color = 'WHITE', scale = 1.5})
        frame.display.text("Tap to Restart", screen_width/2 - 50, 2*screen_height/3, {color = 'WHITE'})
    end
    
    frame.display.show()
    frame.sleep(0.016)  -- Aim for approximately 60 FPS
end