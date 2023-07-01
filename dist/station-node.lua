local ____lualib = require("lualib_bundle")
local __TS__Iterator = ____lualib.__TS__Iterator
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
        for ____, side in __TS__Iterator({
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
    return match
end
local function configureRedstoneInputs(self)
    if not component.isAvailable("redstone") then
        print("No redstone IO found. Please connect a Redstone IO block to the network and restart.")
        return false
    end
    local redstone = component.redstone
    local inputsNeeded = {"trainReady", "sendTrain", "requestTrain"}
    local mappedInputs = {}
    for ____, input in __TS__Iterator(inputsNeeded) do
        print("Please connect a redstone input to the side that should correspond to " .. tostring(input))
        mappedInputs[input] = getSideWithInput(nil, component.redstone)
        print((("Got input " .. tostring(input)) .. " on side ") .. tostring(mappedInputs[input]))
    end
    print("DEBUG:")
    for ____, ____value in __TS__Iterator(Object:entries(mappedInputs)) do
        local key = ____value[1]
        local value = ____value[2]
        print((tostring(key) .. ": ") .. tostring(value))
    end
end
return ____exports
