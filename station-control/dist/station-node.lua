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
            if redstone.getInput(side) > 0 then
                if match == nil then
                    match = side
                    found = true
                else
                    print("Found multiple inputs. Please only connect one input to the network.")
                    return -1
                end
            end
        end
    end
    if match == nil then
        print("No inputs found. Please connect an input to the network and restart.")
        return -1
    end
    computer.beep("../")
    return match
end
local mappedInputs = {}
local function configureRedstoneInputs(self)
    if not component.isAvailable("redstone") then
        print("No redstone IO found. Please connect a Redstone IO block to the network and restart.")
        return false
    end
    local redstone = component.redstone
    local inputsNeeded = {"trainReady", "sendTrain", "requestTrain"}
    for ____, input in ipairs(inputsNeeded) do
        print("Please connect a redstone input to the side that should correspond to " .. input)
        mappedInputs[input] = getSideWithInput(nil, component.redstone)
        print((("Got input " .. input) .. " on side ") .. tostring(mappedInputs[input]))
    end
    computer.beep("//.")
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
main(nil)
return ____exports
