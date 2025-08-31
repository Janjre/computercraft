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


parallel.waitForAny(

    function() -- Receiving
        while true do
            local senderId, message = rednet.receive()
            print("Received message from " .. senderId)
            if type(message) == "table" then
                
                if message.type == "input_update" then -- message.inputs only contains some of the inputs, not all of them at a time, they will all come in seperate messages
                    print("Recieved updated intputs from computer ID: " .. senderId .. "Inputs: " .. textutils.serialiseJSON(message.inputs))
                    for inputName, inputValue in pairs(message.inputs) do
                        if contains(acceptableInputs, inputName) then
                            currentInputs[inputName] = inputValue
                            print("Updated input: " .. inputName .. " to value: " .. tostring(inputValue))
                        else
                            print("Received invalid input name: " .. inputName)
                        end
                    end
                elseif message.type == "debugging_interjection" then
                    print("Debugging interjection received: " .. message.content)
                end
            end
            
        end
    end,

    function() -- Monitor display
        
        local mon = peripheral.wrap("left")
        mon.setTextScale(1)
        while true do
            print(currentInputs["button_a"])
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


            sleep(0.1)
            
        end
    end

)
