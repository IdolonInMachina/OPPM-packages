local ____lualib = require("lualib_bundle")
local __TS__Iterator = ____lualib.__TS__Iterator
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
    modem:open(HANDSHAKE_PORT)
    modem:open(COMM_PORT)
    selectedModem = modem
    listen(
        nil,
        "modem_message",
        function(____, _, __, from, port, ___, message)
            print((((("DEBUG: Got a message from " .. tostring(from)) .. " on port ") .. tostring(port)) .. ": ") .. tostring(message))
            if port == HANDSHAKE_PORT and message == "stationcontrol:areyoumain" then
                if selectedModem ~= nil then
                    selectedModem:send(
                        from,
                        HANDSHAKE_PORT,
                        "stationcontrol:iammain:" .. tostring(COMM_PORT)
                    )
                end
            end
        end
    )
    return true
end
local function mainLoop(self)
    local running = true
    while running do
        local _, __, from, port, ___, message = table.unpack(pull(nil, "modem_message"))
        print((((("DB2: Got a message from " .. tostring(from)) .. " on port ") .. tostring(port)) .. ": ") .. tostring(message))
        if port == COMM_PORT then
            if message == "stationcontrol:shutdown" then
                running = false
            end
        end
    end
end
function ____exports.main(self)
    local success = startup(nil)
    if success then
        mainLoop(nil)
    end
    return success
end
return ____exports
