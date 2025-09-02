function openAllModems()
    local sides = {"top", "bottom", "left", "right", "front", "back"}
    for _, side in ipairs(sides) do
        if peripheral.getType(side) == "modem" then
            if not rednet.isOpen(side) then
                rednet.open(side)
                print("Opened modem on side: " .. side)
            end
        end
    end
end

function contains(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true
        end
    end
    return false
end

function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end


acceptableInputs = {
    "joystick_1_x+" ,
    "joystick_1_y+" ,
    "joystick_2_x+" ,
    "joystick_2_y+" ,
    "joystick_1_x-" ,
    "joystick_1_y-" ,
    "joystick_2_x-" ,
    "joystick_2_y-" ,
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
    "joystick_1_x+" ,
    "joystick_1_y+" ,
    "joystick_2_x+" ,
    "joystick_2_y+",
    "joystick_1_x-" ,
    "joystick_1_y-" ,
    "joystick_2_x-" ,
    "joystick_2_y-"
}


sides = {
    "top",
    "bottom",
    "left",
    "right",
    "front",
    "back"
}
