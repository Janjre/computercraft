-- local mon = peripheral.wrap("left")
-- mon.setTextScale(2)

-- while true do
--     mon.clear()
--     mon.setCursorPos(1, 1)
--     mon.write(textutils.formatTime(os.time(), true))
--     sleep(1)
-- end

require("sharedLibrary")

openAllModems()

currentInputs = {}
currentInputs["joystick_1_x+"] = 0
currentInputs["joystick_1_y+"] = 0
currentInputs["joystick_2_x+"] = 0
currentInputs["joystick_2_y+"] = 0
currentInputs["joystick_1_x-"] = 0
currentInputs["joystick_1_y-"] = 0
currentInputs["joystick_2_x-"] = 0
currentInputs["joystick_2_y-"] = 0
currentInputs["shoulder_left"] = false
currentInputs["shoulder_right"] = false
currentInputs["button_a"] = false
currentInputs["button_b"] = false
currentInputs["button_x"] = false
currentInputs["button_y"] = false
currentInputs["dpad_up"] = false
currentInputs["dpad_down"] = false
currentInputs["dpad_left"] = false
currentInputs["dpad_right"] = false
currentInputs["trigger_left"] = false
currentInputs["trigger_right"] = false

currentOutputs = {}
currentOutputs["propeller_left_front"] = 0
currentOutputs["propeller_left_rear"] = 0
currentOutputs["propeller_left_middle"] = 0
currentOutputs["propeller_right_front"] = 0
currentOutputs["propeller_right_rear"] = 0
currentOutputs["propeller_right_middle"] = 0
currentOutputs["propeller_side_direction"] = 0 -- false is left, true is right
currentOutputs["propeller_side_percent"] = 0
currentOutputs["gyroscope"] = 0
currentOutputs["back_left"] = 0
currentOutputs["back_right"] = 0


messageLog = {} -- stores last 100 messages

palette = {
    colors.white, colors.orange, colors.magenta, colors.lightBlue,
    colors.yellow, colors.lime, colors.pink, colors.gray,
    colors.lightGray, colors.cyan, colors.purple, colors.blue,
    colors.brown, colors.green, colors.red
    -- skip colors.black
}

function drawCharBox(mon, x1, y1, x2, y2, color)
    mon.setBackgroundColor(color)
    for y = y1, y2 do
        mon.setCursorPos(x1, y)
        mon.write(string.rep(" ", x2 - x1 + 1))
    end
    mon.setBackgroundColor(colors.black) -- reset
end

function wrapWrite(mon, text, maxLines, lineLength)
    local lines = {}
    for line in text:gmatch("([^\n]+)") do
        while #line > 0 do
            table.insert(lines, line:sub(1, lineLength-1)) -- assuming 40 character width
            line = line:sub(lineLength)
        end
    end
    for i = 1, math.min(#lines, maxLines) do
        mon.write(lines[i] .. "   ")
        if i < math.min(#lines, maxLines) then
            mon.setCursorPos(1, select(2, mon.getCursorPos()) + 1)
        end
    end
end

function valueToColor(value)
    value = math.max(0, math.min(100, value))  -- clamp
    local t = value / 100
    local index = math.floor(t * (#palette - 1)) + 1
    return palette[index]
end

variableView = true

parallel.waitForAny(

    function() -- Receiving
        while true do
            local senderId, message = rednet.receive()
            -- print("Received message from " .. senderId)
            if type(message) == "table" then
                messageLog[#messageLog + 1] = {time=os.time(), sender=senderId, content=message, type = message.type}
                if #messageLog > 1000 then
                    table.remove(messageLog, 1)
                end
                if message.type == "input_update" then -- message.inputs only contains some of the inputs, not all of them at a time, they will all come in seperate messages
                    -- print("Recieved updated intputs from computer ID: " .. senderId .. "Inputs: " .. textutils.serialiseJSON(message.inputs))
                    for inputName, inputValue in pairs(message.inputs) do
                        if contains(acceptableInputs, inputName) then
                            currentInputs[inputName] = inputValue
                            -- print("Updated input: " .. inputName .. " to value: " .. tostring(inputValue))
                        else
                            -- print("Received invalid input name: " .. inputName)
                        end
                    end
                elseif message.type == "output_update" then
                    
                    currentOutputs[message.channel] = message.resistance
                    
                elseif message.type == "debugging_interjection" then
                    -- print("Debugging interjection received: " .. message.content)
                end
            end
            
        end
    end,

    function() -- Monitor display
        
        local mon = peripheral.wrap("left")
        mon.setTextScale(1)

        -- local old = term.redirect(mon)


        

        for i, col in ipairs(palette) do
            -- t goes from 0 (white) to 1 (red) across 16 slots
            local t = (i - 1) / (#palette - 1)
            local r = 1.0
            local g = 1.0 - t
            local b = 1.0 - t
            mon.setPaletteColor(col, r, g, b)
        end

        

        while true do
            if variableView then
                mon.clear()
                mon.setCursorPos(1, 1)
                mon.write(textutils.formatTime(os.time(), true))
                mon.setCursorPos(1, 3)
                
                mon.write("Inputs:")
                local line = 4
                for inputName, inputValue in pairs(currentInputs) do
                    mon.setCursorPos(1, line)
                    mon.write(inputName .. ": " .. tostring(inputValue) .. "   ")
                    line = line + 1
                end
                

                local pos = ship.getWorldspacePosition()
                startWriting = 3

                i = {}
                
                i[#i+1] = "Ship stats: "
                i[#i+1] = "Mass: " .. tostring(ship.getMass()) .. "kg"
                i[#i+1] = "X: " .. tostring(pos.x) .. "   "
                i[#i+1] = "Y: " .. tostring(pos.y) .. "   "
                i[#i+1] = "Z: " .. tostring(pos.z) .. "   "
                
                -- local yaw = ship.getYaw()
                -- local pitch = ship.getPitch()
                -- local roll = ship.getRoll()
                -- i[#i+1] = "Yaw: " .. tostring(yaw) .. "   "
                -- i[#i+1] = "Pitch: " .. tostring(pitch) .. "   "
                -- i[#i+1] = "Roll: " .. tostring(roll) .. "   "
                local velocity = ship.getVelocity()
                i[#i+1] = "Velocity X: " .. tostring(velocity.x) .. "   "
                i[#i+1] = "Velocity Y: " .. tostring(velocity.y) .. "   "
                i[#i+1] = "Velocity Z: " .. tostring(velocity.z) .. "   "
                -- turn velocities into speed
                local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z)
                i[#i+1] = "Speed: " .. tostring(speed) .. "   "

                --write i starting at startWriting

                for index, lineContent in pairs(i) do
                    mon.setCursorPos(25, startWriting + index - 1)
                    mon.write(lineContent .. "   ")
                end

                --draw outputs
                for i,v in pairs(currentOutputs) do
                    if v == nil then
                        currentOutputs[i] = 0
                    end
                end
                drawCharBox(mon, 30, 15, 30, 15, valueToColor(currentOutputs["propeller_left_front"])) -- front left
                drawCharBox(mon, 30, 17, 30, 17, valueToColor(currentOutputs["propeller_left_middle"])) -- middle left
                drawCharBox(mon, 30, 19, 30, 19, valueToColor(currentOutputs["propeller_left_rear"])) -- rear left
                drawCharBox(mon, 32, 15, 32, 15, valueToColor(currentOutputs["propeller_right_front"])) -- front right
                drawCharBox(mon, 32, 17, 32, 17, valueToColor(currentOutputs["propeller_right_middle"])) -- middle right
                drawCharBox(mon, 32, 19, 32, 19, valueToColor(currentOutputs["propeller_right_rear"])) -- rear right
                -- drawCharBox(mon, 40, 16, 40, 16, valueToColor(currentOutputs["propeller_side_percent"])) -- side propeller
                drawCharBox(mon,28,17,28,17,valueToColor(currentOutputs["propeller_side_percent"]))
                drawCharBox(mon,27,17,27,17,valueToColor(currentOutputs["propeller_side_direction"]))

                mon.setCursorPos(25,21)
                mon.write("Gyroscope: " .. tostring(currentOutputs["gyroscope"]) .. "   ")

                drawCharBox(mon,30,23,30,23,valueToColor(currentOutputs["back_left"]))
                drawCharBox(mon,32,23,32,23,valueToColor(currentOutputs["back_right"]))



                
            else -- show broadcasted messages as they come in
                mon.clear()
                mon.setCursorPos(1, 1)
                mon.write(textutils.formatTime(os.time(), true))
                mon.setCursorPos(1, 3)
                mon.write("Messages:")
                local line = 4
                for i = math.max(1, #messageLog - 20), #messageLog do
                    local msg = messageLog[i]
                    if msg then
                        if msg.type == filterType then -- give 2 lines per message and wrap text
                            mon.setCursorPos(1, line)
                            wrapWrite(mon,"Content: " .. textutils.serialiseJSON(msg.content) .. "   ",3, 50)
                            line = line + 4
                        elseif filterType == "all" then
                            mon.setCursorPos(1, line)
                            wrapWrite(mon,"Type: " .. msg.type .. "Content: "  .. textutils.serialiseJSON(msg.content) .. "   ",3, 50)
                            line = line + 4
                        end
                    end
                end
            end
            sleep(0.1)
            
        end
        
    end,
    function ()
        while true do
            local event, key = os.pullEvent("key")

            if key == keys.q then
                print("Pressed Q, swapping view mode")
                variableView = not variableView
            elseif key == keys.m then
                filterType = "input_update"
            elseif key == keys.n then
                filterType = "output_update"
            elseif key == keys.b then
                filterType = "all"
            end
            os.sleep(0.1)
        end
    end

)
