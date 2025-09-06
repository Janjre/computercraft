print("Computer manager")
require("sharedLibrary")
openAllModems()
myLabel = os.getComputerLabel()


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
        print("What command do you want to send? (start/reboot/stop/shell/send/exit)")
        command = read()
        local args = {}
        for word in string.gmatch(command, "%S+") do table.insert(args, word) end
        local cmd = args[1]

        if cmd == "start" and args[2] and args[3] then
            sendCommand({type="start", program=args[3], target_label=args[2]})
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
        end

        os.sleep(0.1)
    end
end