print("Computer manager")
require("sharedLibrary")
openAllModems()
myLabel = os.getComputerLabel()


labelToCommand = {}
labelToCommand["monitor"] = "monitor.lua"
labelToCommand["propeller_front_left"] = "propeller.lua propeller_front_left front left n"
labelToCommand["propeller_front_right"] = "propeller.lua propeller_front_right front right n"
labelToCommand["propeller_middle_left"] = "propeller.lua propeller_middle_left middle left n"
labelToCommand["propeller_middle_right"] = "propeller.lua propeller_middle_right middle right n"
labelToCommand["propeller_rear_left"] = "propeller.lua propeller_rear_left rear left n"
labelToCommand["propeller_rear_right"] = "propeller.lua propeller_rear_right rear right n"
labelToCommand["propeller_front"] = "propeller.lua propeller_front bottom n"
labelToCommand["propeller_back"] = "propeller.lua propeller_back bottom n"
labelToCommand["propeller_side"] = "propeller.lua propeller_side bottom n"
labelToCommand["input_buttons"] = "input_buttons.lua buttons"
labelToCommand["input_joystick_1"] = "input_joystick.lua joystick_1"
labelToCommand["input_joystick_2"] = "input_joystick.lua joystick_2"
labelToCommand["input_triggers"] = "input_triggers.lua triggers"
labelToCommand["input_dpad"] = "input_dpad.lua dpad"
labelToCommand["gyroscope"] = "propeller.lua gyroscope bottom n"
labelToCommand["thruster_back_left"] = "propeller.lua thruster_back_left left y"
labelToCommand["thruster_back_right"] = "propeller.lua thruster_back_right right y"

function sendCommand(msg)
    rednet.broadcast(msg)
end

function listener ()
    while true do
        local _, msg = rednet.receive()
        if type(msg) == "table" then
            if msg.target_label == myLabel then
                print("Message for me received.")
            
                if msg.type == "remote_shell" and msg.shell_type == "response" then
                    print("["..msg.label.." shell] "..msg.output)
                elseif msg.type == "pong" then
                    print("Pong response from "..msg.label) 
                end
            end
            
        end
    end
end

function commandLine()
    while true do
        print("What command do you want to send? (start/reboot/stop/shell/send/start_all)")
        command = read()
        local args = {}
        for word in string.gmatch(command, "%S+") do table.insert(args, word) end
        local cmd = args[1]

        if cmd == "start" and args[2] and args[3] then
            sendCommand({type="run", program=args[3], target_label=args[2]})
        elseif cmd == "reboot" and args[2] then
            sendCommand({type="reboot", target_label=args[2]})
        elseif cmd == "stop" and args[2] then
            sendCommand({type="stop", target_label=args[2]})
        elseif cmd == "shell" and args[2] and arg[3] then
            sendCommand({type="remote_shell", input=arg[3], target_label=args[2], response_label=myLabel})
        elseif cmd == "ping" and arg[2] then
            sendCommand({type="ping",  target_label=args[2], response_label=myLabel})
        elseif cmd == "ping_active" then
            sendCommand({type="ping_active", response_label=myLabel})
        elseif cmd == "boot_all" then
            for label, program in pairs(labelToCommand) do
                print("Starting "..label.." with program "..program)
                sendCommand({type="start", program=program, target_label=label,response_label=myLabel})
                os.sleep(0.5)
            end
        else
            print("Unknown command.")
        end

        os.sleep(0.1)
    end
end

parallel.waitForAll(listener, commandLine)