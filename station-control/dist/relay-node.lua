local ____lualib = require("lualib_bundle")
local __TS__Iterator = ____lualib.__TS__Iterator
local ____exports = {}
local component = require("component")
local ____event = require("event")
local pull = ____event.pull
local ____json = require("json")
local encode = ____json.encode
local decode = ____json.decode
local cfs = component.filesystem
local mainprog = require("main")
local function startup()
    if component:isAvailable("tunnel") then
        local ____component_0 = component
        local tunnel = ____component_0.tunnel
    else
        print("Linked card not found. Please install a linked card and restart.")
        return false
    end
    local selectedModem = nil
    local numModems = 0
    for ____, ____value in __TS__Iterator(component:list()) do
        local address = ____value[1]
        local name = ____value[2]
        if name == "modem" then
            numModems = numModems + 1
        end
    end
    if not component:isAvailable("modem") then
        print("No network card found. Please install a network card and restart.")
        return false
    elseif numModems ~= 1 then
        print("There is an incorrect number of network cards found. Please install a single network card, and restart.")
        return false
    end
    local modem = component.modem
    modem:open(1458)
    modem:broadcast(1458, "stationcontrol:areyoumain")
    local _, __, from, port, ___, message = table.unpack(pull(nil, "modem_message"))
    print((((("Got a message from " .. tostring(from)) .. " on port ") .. tostring(port)) .. ": ") .. tostring(message))
    local mainController = nil
    if port == 1458 and message == "stationcontrol:iammain" then
        mainController = from
    end
    return true
end
local function setup(self)
    print("What component of the rail network does this relay node link to?")
    print("(1) Station Controller")
    local validOptions = {1}
    local selected = tonumber(io.read())
    while selected == nil or not validOptions:includes(selected) do
        print("Invalid option. Please select a mode:\t")
        selected = tonumber(io.read())
    end
    local config = {["link-type"] = selected}
    io.write(
        "/home/.config/relay-node.json",
        encode(nil, config)
    )
    return config
end
local function station_link(self, config)
end
local function station_link_setup(self, config)
    local tunnel = component.tunnel
    tunnel:send("stationcontrol:requestrelayping")
    local result = pull(nil, 2, "modem_message")
end
function ____exports.main(self)
    local jsonConfig
    if not cfs:exists("/home/.config/relay-node.json") then
        jsonConfig = setup(nil)
    else
        jsonConfig = decode(
            nil,
            mainprog:readFile("relay-node.json")
        )
    end
    local success = startup()
    if success then
        repeat
            local ____switch19 = jsonConfig["link-type"]
            local ____cond19 = ____switch19 == 1
            if ____cond19 then
                print("Running as relay node to a station controller...")
                station_link_setup(nil, jsonConfig)
                station_link(nil, jsonConfig)
                break
            end
            do
                print("Invalid mode. Please reconfigure.")
                return ____exports.main(nil)
            end
        until true
    end
end
return ____exports
