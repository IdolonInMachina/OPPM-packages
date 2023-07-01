const fs = require('filesystem');
const cfs = component.filesystem;
JSON = require('json');

function setup() {
    print('Station Control is running for the first time...');
    print('To install, please select a mode:')
    print('\t1. Main controller.')
    print('\t2. Linking node.')
    print('\t3. Station node.')
    const validOptions = [1,2,3]
    var selected = tonumber(io.read());
    while (selected === undefined || !validOptions.includes(selected)) {
        print('Invalid option. Please select a mode:\t')
        selected = tonumber(io.read());
    }
    print('Selected mode: ' + selected);
    const configFile = io.open('stationcontrol.cfg', 'w');
    configFile.write('stationcontrol.cfg', selected);
}

function main() {
    if (!fs.exists('stationcontrol.cfg')) {
        setup();
    } else {
        print('Station Control is already installed...')

    }
}

main();