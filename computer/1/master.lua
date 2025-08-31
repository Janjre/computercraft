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
    end

)



