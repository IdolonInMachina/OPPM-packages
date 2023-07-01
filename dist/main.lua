--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local json = require("json")
local cfs = component.filesystem
local function readFile(self, filename)
    local f = (io.open(filename, "rb"))
    local content = f:read("*a")
    f:close()
    return content
end
local function setup(self)
    print("Station Control is running for the first time...")
    print("To install, please select a mode:")
    print("\t1. Main controller.")
    print("\t2. Linking node.")
    print("\t3. Station node.")
    local validOptions = {1, 2, 3}
    local selected = tonumber(io.read())
    while selected == nil or not validOptions:includes(selected) do
        print("Invalid option. Please select a mode:\t")
        selected = tonumber(io.read())
    end
    print("Selected mode: " .. tostring(selected))
    local jsonConfig = json.decode(readFile(nil, "stationcontrol.json"))
    io.write("stationcontrol.cfg", selected)
end
local function main(self)
    if not cfs.exists("stationcontrol.cfg") then
        setup(nil)
    else
        print("Station Control is already installed...")
    end
end
main(nil)
return ____exports
