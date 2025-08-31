require("sharedLibrary")

openAllModems()

acceptableInputs = {
    "joystick_1_x" ,
    "joystick_1_y" ,
    "joystick_2_x" ,
    "joystick_2_y" ,
    "shoulder_left",
    "shoulder_right" ,
    "button_a",
    "button_b",
    "button_x",
    "button_y",
    "dpad_up",
    "dpad_down",
    "dpad_left",
    "dpad_right",
    "trigger_left",
    "trigger_right"
}

analogInputs = {
    "joystick_1_x" ,
    "joystick_1_y" ,
    "joystick_2_x" ,
    "joystick_2_y" 
}

registeredSides = {
    top = "",
    bottom = "",
    left = "",
    right = "",
    front = "",
    back = ""
}

sides = {
    "top",
    "bottom",
    "left",
    "right",
    "front",
    "back"
}

currentInputs = {}

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
    for side, value in ipairs(registeredSides) do
        if side ~= "" then
            if contains(analogInputs,side)  then
                redstoneInput = redstone.getAnalogInput(side)    
            else
                redstoneInput = redstone.getInput(side)
            end
            
            currentInputs[value] = redstoneInput
        end
    end
    rednet.broadcast({type="input_update", inputs=currentInputs})
    os.sleep(0.05)
end

setup()

while true do
    mainLoop()
end