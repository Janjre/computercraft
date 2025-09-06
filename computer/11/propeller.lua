require("sharedLibrary")

openAllModems()



currentOutputs = {}
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

print("What channel is the propeller listening on?")
local propellerChannel = read()

print("What side is the propeller on? (top, bottom, left, right, front, back)")

side = read()

print("Invert signal on propeller? (y/n)")
local invertInput = read()
local invert = false
if invertInput == "y" then
    print("Inverting signal on propeller.")
    invert = true
else
    print("Not inverting signal on propeller.")
end
parallel.waitForAny(

    function() -- Receiving
        while true do
            local senderId, message = rednet.receive()
            -- print("Received message from " .. senderId)
            if type(message) == "table" then
                
                
                if message.type == "output_update" then
                    
                    currentOutputs[message.channel] = message.resistance
                    if message.channel == propellerChannel then
                        print("Propeller channel " .. propellerChannel .. " set to resistance: " .. tostring(message.resistance))
                    end
                elseif message.type == "debugging_interjection" then
                    print("Debugging interjection received: " .. message.content)
                end
            end
            
        end
    end,
    function ()
        while true do
            if invert == false then
                redstone.setAnalogOutput(side, clamp((100-(currentOutputs[propellerChannel] or 0))/6.666,0,15) or 0) 
            else
                redstone.setAnalogOutput(side, clamp(((currentOutputs[propellerChannel] or 0))/6.666,0,15) or 0) 
            end
                -- print("Set propeller channel " .. propellerChannel .. " to resistance: " .. tostring(currentOutputs[propellerChannel]) .. " which is redstone output: " .. tostring(clamp((100-(currentOutputs[propellerChannel] or 0))/6.666,0,15)))
            os.sleep(0.1)
        end
        
    end

)



