import * as component from "component";
import { pull, listen } from "event";

const HANDSHAKE_PORT = 1458;
const COMM_PORT = 1459;

let selectedModem: any = undefined;

type modemProxy = {
    open: (this: void, port: number) => boolean;
}

function startup() {
    // Open port 1458 to listen to broadcast requests from relay nodes
    // and port 1459 to communicate with network nodes
    
    let numModems = 0;
    for (const [address, name] of component.list()) {
        if (name === "modem") {
            numModems += 1
            print(address);
            const modem: modemProxy = component.proxy(address);
            print(modem);
            modem.open(HANDSHAKE_PORT);
            modem.open(COMM_PORT);
            selectedModem = modem;
        }
    }

    if (selectedModem === undefined) {
        print("No network card found. Please install a network card and restart.");
        return false;
    } else if (numModems != 1) {
        print("There is an incorrect number of network cards found. Please install a single network card, and restart.")
        return false;
    }

    // Set up listeners for incoming handshakes
    listen("modem_message", (_, __, from, port, ___, message) => {
        print(`Got a message from ${from} on port ${port}: ${message}`);
        if (port == HANDSHAKE_PORT && message === "stationcontrol:areyoumain") {
            selectedModem.send(from, HANDSHAKE_PORT, "stationcontrol:iammain:" + tostring(COMM_PORT));
        }
    });
    return true;
}

function mainLoop() {
    let running = true;
    while (running) {
        const [_, __, from, port, ___, message] = pull("modem_message");
        print(`Got a message from ${from} on port ${port}: ${message}`);
        if (port == COMM_PORT) {
            if (message === "stationcontrol:shutdown") {
                running = false;
            }
        }
    }
}

function main() {
    const success = startup();
    if (success) {
        mainLoop();
    }
    return success
}

main();