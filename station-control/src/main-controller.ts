import * as component from "component";
import { pull, listen } from "event";

const HANDSHAKE_PORT = 1458;
const COMM_PORT = 1459;

let selectedModem: OC.Components.Modem | undefined = undefined;

function startup() {
    // Open port 1458 to listen to broadcast requests from relay nodes
    // and port 1459 to communicate with network nodes
    
    let numModems = 0;
    for (const [address, name] of component.list()) {
        if (name === "modem") {
            numModems += 1
        }
    }

    if (!component.isAvailable("modem")) {
        print("No network card found. Please install a network card and restart.");
        return false;
    } else if (numModems != 1) {
        print("There is an incorrect number of network cards found. Please install a single network card, and restart.")
        return false;
    }
    const modem = component.modem;
    modem.open(HANDSHAKE_PORT);
    modem.open(COMM_PORT);
    selectedModem = modem;
    
    // Set up listeners for incoming handshakes
    listen("modem_message", (_, __, from, port, ___, message) => {
        print(`DEBUG: Got a message from ${from} on port ${port}: ${message}`);
        if (port == HANDSHAKE_PORT && message === "stationcontrol:areyoumain") {
            selectedModem?.send(from, HANDSHAKE_PORT, "stationcontrol:iammain:" + tostring(COMM_PORT));
        }
    });
    return true;
}

function mainLoop() {
    let running = true;
    while (running) {
        const [_, __, from, port, ___, message] = pull("modem_message");
        print(`DB2: Got a message from ${from} on port ${port}: ${message}`);
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
