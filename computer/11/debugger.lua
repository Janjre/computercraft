require("sharedLibrary")

openAllModems()






while true do
    
    local senderId, message = rednet.receive()
    print("Received message from " .. senderId)
    print(message)
    os.sleep(0.1)
end
    


