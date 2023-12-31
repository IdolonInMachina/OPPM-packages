import { front, back, left, right, top, bottom } from "sides";
import * as component from "component";

interface MappedInputs {
    [key: string]: number;
}
const mappedInputs: MappedInputs = {}

function checkIfSideTaken(side: number) {
    for (const [key, value] of Object.entries(mappedInputs)) {
        if (value === side) {
            print(`Side ${side} is already taken by ${key}`)
            return true;
        }
    }
    return false;
}

function getSideWithInput(redstone: OC.Components.Redstone): number {
    let found = false
    let match: number | undefined = undefined;
    while (!found) {
        for (const side of [bottom, top, back, front, left, right]) {
            if (redstone.getInput(side) > 0) {
                if (checkIfSideTaken(side)) continue;
                if (match === undefined) {
                    match = side;
                    found = true;
                } else {
                    print("Found multiple inputs. Please only connect one input to the network.")
                    return -1;
                }
            }
        }
        os.sleep(0.1);
    }
    if (match === undefined) {
        print("No inputs found. Please connect an input to the network and restart.")
        return -1;
    }
    computer?.beep('./');
    return match;
}


function configureRedstoneInputs() {
    if (!component.isAvailable("redstone")) {
        print("No redstone IO found. Please connect a Redstone IO block to the network and restart.")
        return false;
    }
    const redstone = component.redstone;
    const inputsNeeded: string[] = ["trainReady","sendTrain","requestTrain"];
    for (const input of inputsNeeded) {
        computer?.beep('.');
        print(`Please connect a redstone input to the side that should correspond to ${input}`)
        mappedInputs[input] = getSideWithInput(component.redstone);
        print(`Got input ${input} on side ${mappedInputs[input]}`)
        os.sleep(2);
    }
    computer?.beep('//')

    print("DEBUG:")
    for (const [key, value] of Object.entries(mappedInputs)) {
        print(`${key}: ${value}`)
    }

    return true;
}

function startup() {
    configureRedstoneInputs();
}

export function main() {
    startup();
}
