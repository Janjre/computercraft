-- Remote management startup daemon

local cancelKey = keys.leftCtrl -- hold to cancel startup
local thisLabel = os.getComputerLabel() or "unnamed"

print("Press and hold CTRL to cancel startup...")

-- Cancel window
local timer = os.startTimer(1)
while true do
    local event, p1 = os.pullEvent()
    if event == "key" and p1 == cancelKey then
        print("Startup cancelled. Dropping to shell.")
        return
    elseif event == "timer" and p1 == timer then
        break
    end
end

-- Open all attached modems
for _, side in ipairs(rs.getSides()) do
    if peripheral.getType(side) == "modem" then
        rednet.open(side)
    end
end

print("[" .. thisLabel .. "] remote daemon active")

-- Helper to send replies
local function sendResponse(target, msg)
    rednet.send(target, msg)
end

-- Remote shell state
local remoteShellActive = false
local remotePartner = nil

while true do
    local senderId, message = rednet.receive()
    if type(message) == "table" then
        --------------------------------------------------
        -- START
        --------------------------------------------------
        if message.type == "start" and message.label == thisLabel then
            if message.program then
                local ok, err = pcall(function()
                    shell.run(message.program)
                end)
                if not ok then
                    sendResponse(senderId, {
                        type = "error",
                        label = thisLabel,
                        response_label = message.label,
                        output = tostring(err)
                    })
                end
            end

        --------------------------------------------------
        -- STOP
        --------------------------------------------------
        elseif message.type == "stop" and message.label == thisLabel then
            -- crude: reboot into idle state
            os.shutdown()

        --------------------------------------------------
        -- REBOOT
        --------------------------------------------------
        elseif message.type == "reboot" and message.label == thisLabel then
            os.reboot()


        --------------------------------------------------
        -- REMOTE SHELL
        --------------------------------------------------
        elseif message.type == "remote_shell" then
            if message.response_label == thisLabel then
                --------------------------------------------------
                -- INITIATE
                --------------------------------------------------
                if message.shell_type == "initiate" and message.label == thisLabel then
                    remoteShellActive = true
                    remotePartner = message.response_label
                    sendResponse(senderId, {
                        type = "remote_shell",
                        shell_type = "response",
                        label = thisLabel,
                        response_label = message.label,
                        output = "Began"
                    })
                --------------------------------------------------
                -- SEND INPUT
                --------------------------------------------------
                elseif message.shell_type == "send" and remoteShellActive then
                    local input = message.input or ""
                    -- run input safely
                    local ok, result = pcall(load(input))
                    local output = ok and tostring(result) or ("Error: " .. tostring(result))
                    sendResponse(senderId, {
                        type = "remote_shell",
                        shell_type = "response",
                        label = thisLabel,
                        response_label = message.label,
                        output = output
                    })
                end
            end
        end
    end
end
