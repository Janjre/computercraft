print("Running startup script")

require("sharedLibrary")

openAllModems()




function listener ()
    while true do
        local _, msg = rednet.receive()
        if type(msg) == "table" then
            if msg.target_label == os.getComputerLabel() then
                print("Message for me received.")
                if msg.type == "run" then
                    print("Running program: " .. msg.program)
                    shell.run(msg.program)
                end
                if msg.type == "reboot" then
                    print("Rebooting...")
                    os.reboot()
                end
                if msg.type == "stop" then
                    print("Stopping all programs...")
                    os.shutdown()
                end
                if msg.type == "ping" then
                    print("Ping received. Sending pong.")
                    rednet.broadcast({type="pong", response_label = os.getComputerLabel(), target_label = msg.response_label})
                end
                if msg.type == "remote_shell" then
                    if shell.run(msg.input) then
                        rednet.broadcast({type="remote_shell", shell_type="response", output="Command executed successfully.", response_label=os.getComputerLabel(), target_label=msg.response_label})
                    else
                        rednet.send({type="remote_shell", shell_type="response", output="Error executing command.", response_label=os.getComputerLabel(), target_label=msg.response_label})
                    end
                end
                
            end
            if msg.type == "ping_active" then
                print("Ping active received. Sending pong.")
                rednet.broadcast({type="pong", response_label = os.getComputerLabel(), target_label = msg.response_label})
            end
            
        end
        os.sleep(0.1)
    end
end

listener()

