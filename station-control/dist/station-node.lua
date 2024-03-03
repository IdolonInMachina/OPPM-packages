local ____lualib = require("lualib_bundle")
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local ____exports = {}
local ____sides = require("sides")
local front = ____sides.front
local back = ____sides.back
local left = ____sides.left
local right = ____sides.right
local top = ____sides.top
local bottom = ____sides.bottom
local component = require("component")
local ____json = require("json")
local decode = ____json.decode
local ____event = require("event")
local pull = ____event.pull
local cfs = component.filesystem
local mainprog = require("main")
local mappedInputs = {}
local function checkIfSideTaken(self, side)
    for ____, ____value in ipairs(__TS__ObjectEntries(mappedInputs)) do
        local key = ____value[1]
        local value = ____value[2]
        if value == side then
            print((("Side " .. tostring(side)) .. " is already taken by ") .. tostring(key))
            return true
        end
    end
    return false
end
local function getSideWithInput(self, redstone)
    local found = false
    local match = nil
    while not found do
        for ____, side in ipairs({
            bottom,
            top,
            back,
            front,
            left,
            right
        }) do
            do
                if redstone:getInput(side) > 0 then
                    if checkIfSideTaken(nil, side) then
                        goto __continue8
                    end
                    if match == nil then
                        match = side
                        found = true
                    else
                        print("Found multiple inputs. Please only connect one input to the network.")
                        return -1
                    end
                end
            end
            ::__continue8::
        end
        os:sleep(0.1)
    end
    if match == nil then
        print("No inputs found. Please connect an input to the network and restart.")
        return -1
    end
    if computer ~= nil then
        computer:beep("./")
    end
    return match
end
local function configureRedstoneInputs(self)
    if not component:isAvailable("redstone") then
        print("No redstone IO found. Please connect a Redstone IO block to the network and restart.")
        return nil
    end
    local redstone = component.redstone
    local inputsNeeded = {"trainReady", "sendTrain", "requestTrain"}
    for ____, input in ipairs(inputsNeeded) do
        if computer ~= nil then
            computer:beep(".")
        end
        print("Please connect a redstone input to the side that should correspond to " .. input)
        mappedInputs[input] = getSideWithInput(nil, component.redstone)
        print((("Got input " .. input) .. " on side ") .. tostring(mappedInputs[input]))
        os:sleep(2)
    end
    if computer ~= nil then
        computer:beep("//")
    end
    print("DEBUG:")
    for ____, ____value in ipairs(__TS__ObjectEntries(mappedInputs)) do
        local key = ____value[1]
        local value = ____value[2]
        print((tostring(key) .. ": ") .. tostring(value))
    end
    return mappedInputs
end
local function startup(self, config)
end
local function setup(self)
    if not component:isAvailable("tunnel") then
        print("Linked card not found. Please install a linked card and restart.")
        return nil
    end
    local tunnel = component.tunnel
    print("Please enter (only) the name of this station: e.g. <Name> Station.")
    local stationName = io.read()
    local outputs = configureRedstoneInputs(nil)
    tunnel:send("stationcontrol:requeststationid", stationName)
    tunnel:send("stationcontrol:requestlinelist")
    local _, __, from, port, ___, message = table.unpack(pull(nil, "modem_message"))
    if from == tunnel.address then
        print("Received response: " .. tostring(message))
    end
end
function ____exports.main(self)
    local jsonConfig
    if not cfs:exists("/home/.config/station-node.json") then
        jsonConfig = setup(nil)
    else
        jsonConfig = decode(
            nil,
            mainprog:readFile("station-node.json")
        )
    end
    startup(nil, jsonConfig)
end
return ____exports
