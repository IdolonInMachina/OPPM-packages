
const cfs = component.filesystem;

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
    const configFile = io.open('stationcontrol.cfg', 'w');
    io.write('stationcontrol.cfg', selected);
}

function main() {
    if (!cfs.exists('stationcontrol.cfg')) {
        setup();
    } else {
        print('Station Control is already installed...')
    }
}

main();