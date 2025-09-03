require("./../sharedLibrary")

openAllModems()

local myLabel = os.getComputerLabel() or "controller"


print("Flight Control CLI")
print("Type 'help' for commands")

-- Send helper
function sendCommand(msg)
    rednet.broadcast(msg)
end

-- Async listener (runs in parallel)
function listener()
    while true do
        local _, msg = rednet.receive()
        if type(msg) == "table" then
            if msg.type == "remote_shell" and msg.shell_type == "response" then
                print("["..msg.label.." shell] "..msg.output)
            elseif msg.type == "update_ack" then
                print("["..msg.label.."] "..msg.output)
            elseif msg.type == "error" then
                print("["..msg.label.." ERROR] "..msg.output)
            else
                -- generic catch-all
                print("["..(msg.label or "unknown").."] "..(msg.output or textutils.serialize(msg)))
            end
        end
    end
end

function cli()
    while true do
        io.write("> ")
        local input = read()
        local args = {}
        for word in string.gmatch(input, "%S+") do table.insert(args, word) end

        local cmd = args[1]

        if cmd == "start" and args[2] and args[3] then
            sendCommand({type="start", program=args[3], label=args[2]})

        elseif cmd == "reboot" and args[2] then
            sendCommand({type="reboot", label=args[2]})

        elseif cmd == "stop" and args[2] then
            sendCommand({type="stop", label=args[2]})
        elseif cmd == "shell" and args[2] then
            sendCommand({type="remote_shell", shell_type="initiate", label=args[2], response_label=myLabel})
            print("Remote shell initiated with " .. args[2] .. ". Type 'exit' to quit.")
        elseif cmd == "send" and args[2] and args[3] then
            local target = args[2]
            local code = table.concat(args, " ", 3)
            sendCommand({type="remote_shell", shell_type="send", label=myLabel, response_label=target, input=code})
        elseif cmd == "exit" then
            print("Exiting CLI...")
            return

        elseif cmd ~= "" then
            print("Unknown command. Type 'help'")
        end
    end
end

parallel.waitForAny(listener, cli)