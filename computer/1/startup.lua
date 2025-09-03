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
            end
            
        end
    end
end