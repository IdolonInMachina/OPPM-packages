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
local mappedInputs = {}
local function checkIfSideTaken(self, side)
    for ____, ____value in ipairs(__TS__ObjectEntries(mappedInputs)) do
        local key = ____value[1]
        local value = ____value[2]
        if value == side then
            print((("Side " .. tostring(side)) .. " is already taken by ") .. key)
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
                if redstone.getInput(side) > 0 then
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
        os.sleep(0.1)
    end
    if match == nil then
        print("No inputs found. Please connect an input to the network and restart.")
        return -1
    end
    if computer ~= nil then
        computer.beep("./")
    end
    return match
end
local function configureRedstoneInputs(self)
    if not component.isAvailable("redstone") then
        print("No redstone IO found. Please connect a Redstone IO block to the network and restart.")
        return false
    end
    local redstone = component.redstone
    local inputsNeeded = {"trainReady", "sendTrain", "requestTrain"}
    for ____, input in ipairs(inputsNeeded) do
        if computer ~= nil then
            computer.beep(".")
        end
        print("Please connect a redstone input to the side that should correspond to " .. input)
        mappedInputs[input] = getSideWithInput(nil, component.redstone)
        print((("Got input " .. input) .. " on side ") .. tostring(mappedInputs[input]))
        os.sleep(2)
    end
    if computer ~= nil then
        computer.beep("//")
    end
    print("DEBUG:")
    for ____, ____value in ipairs(__TS__ObjectEntries(mappedInputs)) do
        local key = ____value[1]
        local value = ____value[2]
        print((key .. ": ") .. tostring(value))
    end
    return true
end
local function startup(self)
    configureRedstoneInputs(nil)
end
local function main(self)
    startup(nil)
end
return ____exports
