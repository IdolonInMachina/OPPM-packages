import { front, back, left, right, top, bottom } from "sides";
import * as component from "component";
import { encode, decode } from "json";
import { pull, listen } from "event";

const cfs = component.filesystem;

const mainprog = require('main');

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
        return null;
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

    return mappedInputs;
}

function startup(config: any) {
    
}

function setup() {
    if (!component.isAvailable("tunnel")) {
        print("Linked card not found. Please install a linked card and restart.");
        return null; 
    }
    const tunnel: any = component.tunnel;
    print(`Please enter (only) the name of this station: e.g. <Name> Station.`)
    const stationName = io.read()
    const outputs = configureRedstoneInputs();
    // Request new stationId
    tunnel.send("stationcontrol:requeststationid", stationName);
    tunnel.send("stationcontrol:requestlinelist")
    // Wait for response
    const [_, __, from, port, ___, message] = pull("modem_message");
    if (from == tunnel.address) {
        print(`Received response: ${message}`);
    }

}
    

export function main() {
    let jsonConfig: any
    if (!cfs.exists('/home/.config/station-node.json')) {
        jsonConfig = setup();
    } else {
        jsonConfig = decode(mainprog.readFile('station-node.json')!);
    }
    startup(jsonConfig);
}
