local ____lualib = require("lualib_bundle")
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
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
    while selected == nil or not __TS__ArrayIncludes(validOptions, selected) do
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
        while input ~= nil and not __TS__ArrayIncludes(
            {"y", "n"},
            string.lower(input)
        ) do
            print("Invalid option. Please enter either y or n: ")
            input = io.read()
        end
        config.main_station = input == "y"
    end
    io.write(
        "stationcontrol.json",
        encode(config)
    )
    return selected
end
local function main(self)
    local mode = -1
    if not cfs.exists("stationcontrol.json") then
        mode = setup(nil)
    else
        print("Station Control is already installed...")
        local jsonConfig = decode(readFile(nil, "stationcontrol.json"))
        mode = jsonConfig.mode
    end
    repeat
        local ____switch10 = mode
        local ____cond10 = ____switch10 == 1
        if ____cond10 then
            print("Running as main station controller...")
            controller:main()
            break
        end
        ____cond10 = ____cond10 or ____switch10 == 2
        if ____cond10 then
            print("Running as linking node...")
            relay:main()
            break
        end
        ____cond10 = ____cond10 or ____switch10 == 3
        if ____cond10 then
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
