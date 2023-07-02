import * as component from "component";
import { pull, listen } from "event";

function startup(this: void) {
    if (component.isAvailable("tunnel")) {
        const { tunnel } = component;
    } else {
        print("Linked card not found. Please install a linked card and restart.");
        return false; 
    }
    let selectedModem = undefined;
    let numModems = 0;
    // Lets ask all computers in the network if they are a main controller.
    for (const [address, name] of component.list()) {
        if (name === "modem") {
            numModems += 1;
        }
    }
    if (!component.isAvailable("modem")) {
        print("No network card found. Please install a network card and restart.");
        return false;
    } else if (numModems != 1) {
        print("There is an incorrect number of network cards found. Please install a single network card, and restart.")
        return false;
    }
    const modem  = component.modem;
    modem.open(1458);
    modem.broadcast(1458, "stationcontrol:areyoumain");
    const [_, __, from, port, ___, message] = pull("modem_message");
    print(`Got a message from ${from} on port ${port}: ${message}`);
    let mainController = undefined;
    if (port == 1458 && message === "stationcontrol:iammain") {
        // We got a response from the main controller. Lets remember it's address.
        mainController = from;
    }
    return true;
}

function main() {
    let success = startup();
    return success;
}
