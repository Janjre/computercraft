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
    rednet.broadcast({type="input_update", inputs=currentInputs, label = os.getComputerLabel()})
    
    
    os.sleep(0.1)
end

print("Would you like to load a saved configuration? (y/n)")
local loadConfig = read()

if loadConfig == "y" then
    print("What is the name of the configuration file? (default: inputConfig.txt)")
    local configName = read()
    if (string.sub(configName, -4) ~= ".txt") then
        configName = configName .. ".txt"
    end
    if fs.exists("input_configs/"..configName) then
        local file = fs.open("input_configs/"..configName, "r")
        local content = file.readAll()
        file.close()
        registeredSides = textutils.unserialiseJSON(content)
        print("Loaded configuration: " .. textutils.serialiseJSON(registeredSides))
    else
        print("No saved configuration found. Starting setup.")
        setup()
    end
else
    setup()
end


print("Would you like to save your input configuration? (y/n)")

local saveConfig = read()

if saveConfig == "y" then
    
    print("What would you like to name this configuration?")

    local configName = read()

    local file = fs.open("input_configs"..configName, "w")
    file.writeLine(textutils.serialiseJSON(registeredSides))
    file.close()
    print("Configuration saved to inputConfig.txt")
else
    print("Configuration not saved.")
end

print("Complete setup. Starting main loop.")

while true do
    mainLoop()
end