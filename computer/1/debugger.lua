require("sharedLibrary")

openAllModems()

local mon = peripheral.wrap("top")  

mon.setTextScale(0.5)




parallel.waitForAny(

    function() -- Receiving

        print("What channel do you want to debug")
        local lookingFor = read()

        
        while true do
            
            local senderId, message = rednet.receive()
            if type(message) == "table" then
                lookingFor = read()
                if message.type == "input_update" then -- message.inputs only contains some of the inputs, not all of them at a time, they will all come in seperate messages
    
                    for inputName, inputValue in pairs(message.inputs) do
                        if inputName == lookingFor then
                            print("Input: " .. inputName .. " Value: " .. tostring(inputValue) .. " From computer ID: " .. senderId)
                        end
                    end
                elseif message.type == "debugging_interjection" then
                    print("Debugging interjection received: " .. message.content)
                end
            end
            os.sleep(0.1)
        end
    end

)



