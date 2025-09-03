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
currentInputs["trigger_left"] = 0
currentInputs["trigger_right"] = 0
currentInputs["shoulder_left"] = false
currentInputs["shoulder_right"] = false


currentOutputs = {}
currentOutputs["propeller_left_front"] = 0
currentOutputs["propeller_left_rear"] = 0
currentOutputs["propeller_left_middle"] = 0
currentOutputs["propeller_right_front"] = 0
currentOutputs["propeller_right_rear"] = 0
currentOutputs["propeller_right_middle"] = 0
currentOutputs["propeller_side_direction"] = 0 -- false is left, true is right
currentOutputs["propeller_side_percent"] = 0 -- this is a special one that just goes to the side propeller computer
currentOutputs["gyroscope"] = 0
currentOutputs["back_left"] = 0
currentOutputs["back_right"] = 0



parallel.waitForAny(

    function() -- Receiving
        while true do
            local senderId, message = rednet.receive()
            if type(message) == "table" then
                
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
                elseif message.type == "debugging_interjection" then
                    print("Debugging interjection received: " .. message.content)
                end
            end
            
        end
    end,
    function () -- processing and rebroadcasting 
        
        
        while true do -- 100 is full, 0 is off, will be converteds to redstone resistors at the end
            -- left joystick does pitch and roll
        
            local forwardness = currentInputs["joystick_1_y+"]
            local backwardness = -currentInputs["joystick_1_y-"]
            local pitchControl = forwardness + backwardness -- ranges between -15 and 15
            local frontBackDifference = pitchControl * 2.5 -- turn forwardness and backwardness into a single value
            local frontBacknessPercent = math.abs(frontBackDifference)
            local frontBackDirection = frontBackDifference < 0 and -1 or 1 -- -1 is forward, 1 is backward
            
            local rollLeftness = -currentInputs["joystick_1_x-"]
            local rollRightness = currentInputs["joystick_1_x+"]
            local rollControl = rollLeftness + rollRightness -- ranges between -15 and 15
            local leftRightDifference = rollControl * 2.5 -- turn rollLeftness and rollRightness into a single value
            local leftRightPercent = math.abs(leftRightDifference)
            local leftRightDirection = leftRightDifference < 0 and -1 or 1 -- -1 is left, 1 is right


            -- right joystick does yaw and altitude control

            local upness = currentInputs["joystick_2_y+"] 
            local downness = -currentInputs["joystick_2_y-"]
            local heightControl = upness + downness -- ranges between -15 and 15
            local stayingLevelpercent = 18
            local altitude = stayingLevelpercent + heightControl * 2.5 -- turn upness and downness into a single value


            -- yaw control this controls one propeller on the side
            local leftness = -currentInputs["joystick_2_x-"]
            if currentInputs["dpad_left"] then
                leftness = -15
            end
        
            local rightness = currentInputs["joystick_2_x+"]
            if currentInputs["dpad_right"] then
                rightness = 15
            end

            local yawControl = leftness + rightness -- ranges between -15 and 15
            local yawPercentControl = yawControl * 6.6 -- turn leftness and rightness into a single value between -37.5 and 37.5
            local sideProperllerPercent = math.abs(yawPercentControl)
            local sideProperllerDirection = yawPercentControl < 0 and -1 or 1 -- -1 is left, 1 is right

            -- gyroscope control
            local gyroInput = currentInputs["trigger_left"] 
            local defautlGyro = 10
            local gyroscope = defautlGyro + gyroInput * 6 -- turn gyro input into a value between 10 and 100
            if currentInputs["shoulder_left"] then
                gyroscope = 0
            end

            -- back thrusters control
            local ThrusterThrustyness = currentInputs["trigger_right"] or 0
            local steeringLeft = currentInputs["button_x"] or false
            local steeringRight = currentInputs["button_b"] or false
            local backLeft = ThrusterThrustyness * 6 -- turn back left input into a value between 0 and 100
            local backRight = ThrusterThrustyness * 6 -- turn back right input into a value between 0 and 100

            if steeringLeft then
                backLeft = math.min(100, backLeft + 30)
                backRight = math.max(0, backLeft - 30)
            end
            if steeringRight then
                backRight = math.min(100, backRight + 30)
                backLeft = math.max(0, backRight - 30)
            end

            
            currentOutputs["back_left"] = math.min(100, math.max(0, backLeft))
            currentOutputs["back_right"] = math.min(100, math.max(0, backRight))
            currentOutputs["gyroscope"] = math.min(100, math.max(0, gyroscope))

            --final combining of all the factors to get final propeller speeds
            currentOutputs["propeller_left_front"] = math.min(100, math.max(0, (altitude*1.7) - frontBacknessPercent * frontBackDirection + leftRightPercent * leftRightDirection))
            currentOutputs["propeller_left_middle"] = math.min(100, math.max(0, altitude + leftRightPercent * leftRightDirection))
            currentOutputs["propeller_left_rear"] = math.min(100, math.max(0, (altitude*0.7) + frontBacknessPercent * frontBackDirection + leftRightPercent * leftRightDirection))
            currentOutputs["propeller_right_front"] = math.min(100, math.max(0, (altitude*1.7) - frontBacknessPercent * frontBackDirection - leftRightPercent * leftRightDirection))
            currentOutputs["propeller_right_middle"] = math.min(100, math.max(0, altitude - leftRightPercent * leftRightDirection))
            currentOutputs["propeller_right_rear"] = math.min(100, math.max(0, (altitude*0.7) + frontBacknessPercent * frontBackDirection - leftRightPercent * leftRightDirection))

            --side propellerChannel
            currentOutputs["propeller_side_direction"] = tonumber(sideProperllerDirection) * 100
            currentOutputs["propeller_side_percent"] = math.min(100, math.max(0, sideProperllerPercent))

            



            for outputName, outputValue in pairs(currentOutputs) do
                rednet.broadcast({type="output_update", resistance=outputValue,channel = outputName, label = os.getComputerLabel()})
            end

            os.sleep(0.05)
        end
        
    end

)



