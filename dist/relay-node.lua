--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local component = require("component")
local ____event = require("event")
local pull = ____event.pull
local function startup()
    if component.isAvailable("tunnel") then
        local ____component_0 = component
        local tunnel = ____component_0.tunnel
    else
        print("Linked card not found. Please install a linked card and restart.")
        return false
    end
    local selectedModem = nil
    local numModems = 0
    for address, name in component.list() do
        if name == "modem" then
            numModems = numModems + 1
            local modem = component.proxy(address)
            modem:open(1458)
            modem:broadcast(1458, "stationcontrol:areyoumain")
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
    local _, __, from, port, ___, message = pull("modem_message")
    print((((("Got a message from " .. from) .. " on port ") .. tostring(port)) .. ": ") .. tostring(message))
    local mainController = nil
    if port == 1458 and message == "stationcontrol:iammain" then
        mainController = from
    end
    return true
end
local function main(self)
    local success = startup()
    return success
end
main(nil)
return ____exports
