//import * as json from "json";
import { encode, decode } from "json";

const controller = require('main-controller');
const relay = require('relay-node');
const station = require('station-node');

const cfs = component.filesystem;

function readFile(filename: string) {
    const f = io.open(filename, 'rb')[0]!;
    const content = f.read('*a');
    f.close();
    return content;
}

function setup() {
    print('Station Control is running for the first time...');
    print('To install, please select a mode:')
    print('\t1. Main controller.')
    print('\t2. Linking node.')
    print('\t3. Station node.')
    const validOptions = [1,2,3]
    let selected = tonumber(io.read());
    while (selected === undefined || !validOptions.includes(selected)) {
        print('Invalid option. Please select a mode:\t')
        selected = tonumber(io.read());
    }
    print('Selected mode: ' + selected);
    let config = {
        'mode': selected,
        'station_name': '',
        'num_trains': -1,
        'node_map': {

        },
        'station_map': {

        },
        'general_info_screen': '',
        'debug_screen': ''
    }
    io.write('stationcontrol.json', encode(config));
    return selected;
}

function main() {
    let mode = -1;
    if (!cfs.exists('stationcontrol.cfg')) {
        mode = setup();
    } else {
        print('Station Control is already installed...')
        const jsonConfig: any = decode(readFile('stationcontrol.json')!);
        mode = jsonConfig['mode'];
    }
    switch (mode) {
        case 1:
            print('Running as main station controller...')
            controller.main();
            break;
        case 2:
            print('Running as linking node...')
            relay.main();
            break;
        case 3:
            print('Running as station node...')
            station.main();
            break;
        default:
            print('Invalid mode. Please reconfigure.')
            main();
            return;
    }
    print('Exiting...')
}

main();