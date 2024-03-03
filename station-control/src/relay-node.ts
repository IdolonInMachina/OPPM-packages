import * as component from "component";
import { pull, listen } from "event";
import { encode, decode } from "json";

const cfs = component.filesystem;

const mainprog = require('main');

// The relay node should be a server in the same server rack as the main controller.
// It acts as a bridge between the main controller and any other computer in the train network, such as individual station controllers.

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

function setup() {
    print(`What component of the rail network does this relay node link to?`);
    print(`(1) Station Controller`);
    const validOptions = [1];
    let selected = tonumber(io.read());
    while (selected === undefined || !validOptions.includes(selected)) {
        print('Invalid option. Please select a mode:\t')
        selected = tonumber(io.read());
    }
    const config = {
        'link-type': selected,
    }
    io.write('/home/.config/relay-node.json', encode(config));
    return config
}

function station_link(config: any) {

}

function station_link_setup(config: any) {
    const tunnel:any = component.tunnel;
    tunnel.send("stationcontrol:requestrelayping")
    const result = pull(2, "modem_message");

}


export function main() {
    let jsonConfig: any
    if (!cfs.exists('/home/.config/relay-node.json')) {
        jsonConfig = setup();
    } else {
        jsonConfig = decode(mainprog.readFile('relay-node.json')!);
    }
    let success = startup();
    if (success) {
        switch (jsonConfig['link-type']) {
            case 1:
                print('Running as relay node to a station controller...');
                station_link_setup(jsonConfig)
                station_link(jsonConfig);
                break;
            default:
                print('Invalid mode. Please reconfigure.')
                return main();
        }
    }
}
