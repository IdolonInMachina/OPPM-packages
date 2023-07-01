local ____lualib = require("lualib_bundle")
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
cfs = component.filesystem
function setup(self)
    print("Station Control is running for the first time...")
    print("To install, please select a mode:")
    print("\t1. Main controller.")
    print("\t2. Linking node.")
    print("\t3. Station node.")
    local validOptions = {1, 2, 3}
    local selected = tonumber(io.read())
    while selected == nil or not __TS__ArrayIncludes(validOptions, selected) do
        print("Invalid option. Please select a mode:\t")
        selected = tonumber(io.read())
    end
    print("Selected mode: " .. tostring(selected))
    local configFile = {io.open("stationcontrol.cfg", "w")}
    io.write("stationcontrol.cfg", selected)
end
function main(self)
    if not cfs.exists("stationcontrol.cfg") then
        setup(nil)
    else
        print("Station Control is already installed...")
    end
end
main(nil)
