--kafka shirogane
function love.load(arg)
    --main_height = 1000
    --main_width = 1720
    game_state = "title"
    score = 0
    bird_origin = {bird_x = 0, bird_y = 0, bird_w = 1720, bird_h = 1000, prev = nil}
    games = nil

    function debugging()
        if #games == 2 then
            love.graphics.setColor(1, 1, 1, 1)
            --love.graphics.print("self.bird_y:".. tostring(games[2].bird_y).. "|<|self.prev.bird_y:".. tostring(games[2].prev.bird_y), 5, 5, 0, 1.5, 1.5)

            love.graphics.print("self.bird_x:".. tostring(games[2].bird_x).. "|<|pipe.pipe_current_x + pipe.pipe_max_width:".. tostring(games[2].pipes[1].pipe_current_x + games[2].pipes[1].pipe_max_width), 5, 5, 0, 1.5, 1.5)

            love.graphics.print("self.bird_x + self.bird_w:".. tostring(games[2].bird_x + games[2].bird_w).. "|>|pipe.pipe_current_x:".. tostring(games[2].pipes[1].pipe_current_x), 5, 25, 0, 1.5, 1.5)

            love.graphics.print("self.bird_y:".. tostring(games[2].bird_y).. "|<|pipe.pipe_h:".. tostring(games[2].pipes[1].pipe_h), 5, 45, 0, 1.5, 1.5)

            love.graphics.print("self.bird_y + self.bird_h:".. tostring(games[2].bird_y + games[2].bird_h).. "|>|pipe.pipe_h + pipe.pipe_space:".. tostring(games[2].pipes[1].pipe_h + games[2].pipes[1].pipe_space), 5, 65, 0, 1.5, 1.5)

        end
    end

    function print_score()
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Score:".. tostring(score), 5, 5, 0, 3, 3)
    end

    function title()
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Meta-Bird", 500, 200, 0, 4, 4)
        love.graphics.print("Press Enter to play", 500, 300, 0, 4, 4)
        love.graphics.print("'Z' for big bird", 500, 400, 0, 4, 4)
        love.graphics.print("'X' for middle bird", 500, 500, 0, 4, 4)
        love.graphics.print("'C' for small bird", 500, 600, 0, 4, 4)
    end


    function get_game(_dv, _jump, _bird_w, _bird_h, _key, _pipe_w, _pipe_spd, _color_pipe, _color_bird, _color_bg, _origin, _pipe_amt)
        local g = {
            prev = _origin, -- access pointer to that table!
            --game_w = _origin.bird_w,
            --game_h = _origin.bird_h,
            key = _key,
            bird_x = (_origin.bird_w/13),
            bird_y = (_origin.bird_h/6),
            bird_v = 0,
            bird_dv = _dv,
            bird_jump = -(_jump),
            bird_w = _bird_w,
            bird_h = _bird_h,
            pipe_w = _pipe_w,
            pipe_spd = _pipe_spd,
            pipe_amt = _pipe_amt,
            pipes = {},
            color_pipe = _color_pipe,
            color_bird = _color_bird,
            color_bg = _color_bg,
            update = function (self, dt)
                if #self.pipes == 0 then
                    table.insert(self.pipes, self:new_pipe())
                elseif #self.pipes == 1 and self.pipe_amt == 2 and self.pipes[1].pipe_current_x < self.prev.bird_x + (self.prev.bird_w/3) then
                    table.insert(self.pipes, self:new_pipe())
                end

                for i, pipe in ipairs(self.pipes) do
                    self:move_pipe(dt, pipe)
                    if pipe.pipe_current_x < self.bird_x + self.bird_w and pipe.pipe_not_passed then
                        score = score + 1
                        pipe.pipe_not_passed = false
                    end

                    if pipe.pipe_current_x < self.prev.bird_x - pipe.pipe_max_width then
                        table.remove(self.pipes, i)
                    end
                end

                if not self:is_hit() then
                    self.bird_v = self.bird_v + (self.bird_dv * dt)
                    self.bird_y = self.bird_y + (self.bird_v * dt)
                else
                    game_state = "title"
                    games = nil
                end

            end,
            draw = function (self)
                if self.key ~= "c" then
                    love.graphics.setColor(self.color_bg)
                    love.graphics.rectangle('fill', self.prev.bird_x, self.prev.bird_y, self.prev.bird_w, self.prev.bird_h)
                    love.graphics.setColor(self.color_bird)
                    love.graphics.rectangle('fill', self.prev.bird_x + self.bird_x, self.prev.bird_y + self.bird_y, self.bird_w, self.bird_h)
                    for i, pipe in ipairs(self.pipes) do
                        love.graphics.setColor(self.color_pipe)
                        love.graphics.rectangle('fill', pipe.pipe_current_x, self.prev.bird_y, self.pipe_w, pipe.pipe_h)
                        love.graphics.rectangle('fill', pipe.pipe_current_x, self.prev.bird_y + pipe.pipe_h + pipe.pipe_space, self.pipe_w, pipe.pipe_max_height - (pipe.pipe_h + pipe.pipe_space))
                    end
                else
                    love.graphics.setColor(self.color_bg)
                    love.graphics.rectangle('fill', self.prev.bird_x + (games[2].prev.bird_x), self.prev.bird_y + (games[2].prev.bird_y), self.prev.bird_w, self.prev.bird_h)
                    love.graphics.setColor(self.color_bird)
                    love.graphics.rectangle('fill', self.prev.bird_x + self.bird_x + (games[2].prev.bird_x), self.prev.bird_y + self.bird_y + (games[2].prev.bird_y), self.bird_w, self.bird_h)
                    for i, pipe in ipairs(self.pipes) do
                        love.graphics.setColor(self.color_pipe)
                        love.graphics.rectangle('fill', pipe.pipe_current_x + games[2].prev.bird_x, self.prev.bird_y + games[2].prev.bird_y, self.pipe_w, pipe.pipe_h)
                        love.graphics.rectangle('fill', pipe.pipe_current_x + games[2].prev.bird_x, self.prev.bird_y + pipe.pipe_h + pipe.pipe_space + games[2].prev.bird_y, self.pipe_w, pipe.pipe_max_height - (pipe.pipe_h + pipe.pipe_space))
                    end
                end
            end,
            is_hit = function (self)
                local hit = false
                --check top/bot
                if ((self.bird_y < 0) or (self.bird_y + self.bird_h > self.prev.bird_h)) then
                    hit = true
                end
                -- check for all pipes
                for i, pipe in ipairs(self.pipes) do
                    if self.bird_x + self.prev.bird_x < (pipe.pipe_current_x + pipe.pipe_max_width) and -- Left edge of bird is to the left of the right edge of pipe
                    (self.bird_x + self.prev.bird_x + self.bird_w) > pipe.pipe_current_x and ( -- Right edge of bird is to the right of the left edge of pipe
                        self.bird_y < (pipe.pipe_h) or -- Top edge of bird is above the bottom edge of first pipe segment
                        (self.bird_y + self.bird_h) > (pipe.pipe_h + pipe.pipe_space) -- Bottom edge of bird is below the top edge of second pipe segment
                    ) then
                        hit = true
                    end
                end
                return hit
            end,
            key_press = function (self, _key)
                if self.key == _key then
                    self.bird_v = self.bird_jump
                end
            end,
            new_pipe = function (self)
                local _pipe_space
                if self.pipe_amt == 1 then
                     _pipe_space = self.bird_h*3
                else
                    _pipe_space = self.bird_h*2.4
                end
                local p = {
                    pipe_space = _pipe_space,
                    pipe_max_width = self.pipe_w,
                    pipe_max_height = self.prev.bird_h,
                    pipe_current_width = 0,
                    pipe_current_x = self.prev.bird_x + self.prev.bird_w - self.pipe_w, -- will change
                    --pipe_current_y = self.y_origin, realized this won't work because the bird will change Y position so much use y_origin
                    pipe_spd = self.pipe_spd,
                    pipe_not_passed = true,
                    pipe_h = love.math.random( 0, self.prev.bird_h - _pipe_space)
                    --pipe_h = self.prev.bird_y + 1 -- max value? What was I thinking?
                    --pipe_h = self.prev.bird_h - self.bird_h*2.5 -- max height
                    --pipe_h = 0 -- min height...
                }

                return p
            end,
            move_pipe = function (self, dt, pipe)
                pipe.pipe_current_x = pipe.pipe_current_x - pipe.pipe_spd * dt
            end

        }
        return g
    end
    --get_game(_dv, _jump, _bird_w, _bird_h, _key, _pipe_w, _pipe_spd, _color_pipe, _color_bird, _color_bg, _origin, _pipe_amt)
    function game_init()
        games = {}
        c_bg = {.14, .36, .46}
        c_bird = {.87, .84, .27}
        c_pipe = {.56, .27, .97}
        table.insert(games, get_game(700,500,400,250,"z",250,450,c_pipe,c_bird,c_bg,bird_origin,2))

        c_bg = {.37, .82, .28}
        c_bird = {.56, .27, .97}
        c_pipe = {201/255, 52/255, 235/255}
        table.insert(games, get_game(500,150,75,50,"x",40,180,c_pipe,c_bird,c_bg,games[1],2))

        c_bg = {1, 1, 1}
        c_bird = {0, 0, 0}
        c_pipe = {1, 0, 0}
        table.insert(games, get_game(250,80,15,10,"c",10,70,c_pipe,c_bird,c_bg,games[2],1))
    end

end


function love.update(dt)
    if game_state == "game" then
        for i, v in ipairs(games) do
            v:update(dt)
        end
    else

    end
end

function love.draw()
    if game_state == "game" then
        for i, v in ipairs(games) do
            v:draw()
        end
        print_score()
        --debugging()
    else
        title()
    end
end


function love.keypressed(key)
    if game_state == "game" then
        for i, v in ipairs(games) do
            v:key_press(key)
        end
    else
        if key == "return" then
            game_init()
            game_state = "game"
        end
    end
end
