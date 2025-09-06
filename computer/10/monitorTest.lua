local mon = peripheral.wrap("left")
mon.setTextScale(1)
mon.clear()

-- Redirect terminal output to the monitor
local old = term.redirect(mon)

-- Now *everything* goes to the monitor
paintutils.drawFilledBox(2, 2, 20, 6, colors.blue)
term.setCursorPos(4, 4)
term.setTextColor(colors.white)
print("Hello inside box!")

-- Restore terminal back to computer screen
term.redirect(old)
