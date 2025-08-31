require("sharedLibrary")

openAllModems()



registeredSides = {
    top = "",
    bottom = "",
    left = "",
    right = "",
    front = "",
    back = ""
}


currentInputs = {}
previousInputs = {}

function setup()
    --asks which sides are analog and should be linmked to which part of currentInputs
    for _, side in pairs(sides) do
        print("Is there an input device on the " .. side .. " side? (y/n)")
        local input = read()
        if input == "y" then
            print("Which input is it? (acceptable inputs are: ")
            for _, v in pairs(acceptableInputs) do
                print(v)
            end
            local inputType = read()
            local validInput = false
            for _, v in pairs(acceptableInputs) do
                if v == inputType then
                    validInput = true
                end
            end
            if validInput then
                registeredSides[side] = inputType
                print("Registered " .. inputType .. " on side " .. side)
            else
                print("Invalid input type. Skipping side " .. side)
            end
        else
            print("No input device on side " .. side .. ". Skipping.")
        end
    end

end

function mainLoop()
    for side, value in pairs(registeredSides) do
        if  value == "" then else
            print("Reaching input on side: " .. side)
            if contains(analogInputs,value)  then
                print("analog reading...")
                redstoneInput = redstone.getAnalogInput(side)    
                print("redstone input: " .. tostring(redstoneInput))
            else
                print("digital reading...")
                redstoneInput = redstone.getInput(side)
                print("redstone input: " .. tostring(redstoneInput))
            end
            
            currentInputs[value] = redstoneInput
        end
    end

    
    print("Current inputs: " .. textutils.serialiseJSON(currentInputs))
    previousInputs = currentInputs
    rednet.broadcast({type="input_update", inputs=currentInputs})
    
    
    os.sleep(0.1)
end

setup()

print("Complete setup. Starting main loop.")

while true do
    mainLoop()
end