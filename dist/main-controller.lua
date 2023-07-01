--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local component = require("component")
local ____event = require("event")
local pull = ____event.pull
local listen = ____event.listen
local HANDSHAKE_PORT = 1458
local COMM_PORT = 1459
local selectedModem = nil
local function startup(self)
    local numModems = 0
    for address, name in component.list() do
        if name == "modem" then
            numModems = numModems + 1
            print(address)
            local modem = component.proxy(address)
            print(modem)
            modem.open(HANDSHAKE_PORT)
            modem.open(COMM_PORT)
            selectedModem = modem
        end
    end
    if selectedModem == nil then
        print("No network card found. Please install a network card and restart.")
        return false
    elseif numModems ~= 1 then
        print("There is an incorrect number of network cards found. Please install a single network card, and restart.")
        return false
    end
    listen(
        "modem_message",
        function(_, __, from, port, ___, message)
            print((((("Got a message from " .. from) .. " on port ") .. tostring(port)) .. ": ") .. tostring(message))
            if port == HANDSHAKE_PORT and message == "stationcontrol:areyoumain" then
                selectedModem:send(
                    from,
                    HANDSHAKE_PORT,
                    "stationcontrol:iammain:" .. tostring(COMM_PORT)
                )
            end
        end
    )
    return true
end
local function mainLoop(self)
    local running = true
    while running do
        local _, __, from, port, ___, message = pull("modem_message")
        print((((("Got a message from " .. from) .. " on port ") .. tostring(port)) .. ": ") .. tostring(message))
        if port == COMM_PORT then
            if message == "stationcontrol:shutdown" then
                running = false
            end
        end
    end
end
local function main(self)
    local success = startup(nil)
    if success then
        mainLoop(nil)
    end
    return success
end
main(nil)
return ____exports
