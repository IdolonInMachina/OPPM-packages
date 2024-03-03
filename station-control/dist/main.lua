local ____exports = {}
local component = require("component")
local ____json = require("json")
local encode = ____json.encode
local decode = ____json.decode
local controller = require("main-controller")
local relay = require("relay-node")
local station = require("station-node")
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
    local config = {
        mode = selected,
        station_name = "",
        num_trains = -1,
        main_station = false,
        node_map = {},
        station_map = {},
        general_info_screen = "",
        debug_screen = ""
    }
    if selected == 3 then
        print("Is this station a main hub that can spawn new trains? [ y / N ]: ")
        local input = io.read()
        while input ~= nil and not ({"y", "n"}):includes(string.lower(input)) do
            print("Invalid option. Please enter either y or n: ")
            input = io.read()
        end
        config.main_station = input == "y"
    end
    io.write(
        "/home/.config/stationcontrol.json",
        encode(nil, config)
    )
    return selected
end
local function main(self)
    local mode = -1
    if not cfs:exists("/home/.config") then
        print("Config directory doesn't exist. Creating it...")
        os.execute("mkdir -p /home/.config")
    else
        print("Config directory already exists. Checking for config file...")
    end
    if not cfs:exists("/home/.config/stationcontrol.json") then
        mode = setup(nil)
    else
        print("Station Control is already installed...")
        local jsonConfig = decode(
            nil,
            readFile(nil, "stationcontrol.json")
        )
        mode = jsonConfig.mode
    end
    repeat
        local ____switch12 = mode
        local ____cond12 = ____switch12 == 1
        if ____cond12 then
            print("Running as main station controller...")
            controller:main()
            break
        end
        ____cond12 = ____cond12 or ____switch12 == 2
        if ____cond12 then
            print("Running as linking node...")
            relay:main()
            break
        end
        ____cond12 = ____cond12 or ____switch12 == 3
        if ____cond12 then
            print("Running as station node...")
            station:main()
            break
        end
        do
            print("Invalid mode. Please reconfigure.")
            main(nil)
            return
        end
    until true
    print("Exiting...")
end
main(nil)
return ____exports
