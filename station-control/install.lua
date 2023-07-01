
-- Create folder if it doesn't exist
os.execute("mkdir -p /usr/bin/station-control")

-- Remove any old lua files in the directory
os.execute("rm -f /usr/bin/station-control/*.lua")

-- Download new files
os.execute("wget https://raw.githubusercontent.com/IdolonInMachina/OPPM-packages/master/station-control/dist/main-controller.lua -O /usr/bin/station-control/main-controller.lua")
os.execute("wget https://raw.githubusercontent.com/IdolonInMachina/OPPM-packages/master/station-control/dist/main.lua -O /usr/bin/station-control/main.lua")
os.execute("wget https://raw.githubusercontent.com/IdolonInMachina/OPPM-packages/master/station-control/dist/relay-node.lua -O /usr/bin/station-control/relay-node.lua")
os.execute("wget https://raw.githubusercontent.com/IdolonInMachina/OPPM-packages/master/station-control/dist/station-node.lua -O /usr/bin/station-control/station-node.lua")

-- Download  library files
os.execute("wget https://raw.githubusercontent.com/IdolonInMachina/OPPM-packages/master/station-control/dist/lualib_bundle.lua -O /usr/bin/station-control/lualib_bundle.lua")
os.execute("wget https://raw.githubusercontent.com/IdolonInMachina/OPPM-packages/master/station-control/src/json.lua -O /usr/bin/station-control/json.lua")

-- Copy library files to /lib
os.execute("cp /usr/bin/station-control/lualib_bundle.lua /lib/lualib_bundle.lua")
os.execute("cp /usr/bin/station-control/json.lua /lib/json.lua")


local file_path = "/home/autorun.lua"
local line_to_append = "/usr/bin/station-control/main.lua"

-- Check if the file exists
local file = io.open(file_path, "r")
if file then
  -- File exists, check if the line is already present
  local file_content = file:read("*all")
  if not file_content:find(line_to_append, 1, true) then
    -- Line not present, append it to the file
    file:close()
    file = io.open(file_path, "a")
    file:write("\n" .. line_to_append .. "\n")
    file:close()
    print("Station control has been set to run on startup.")
  else
    -- Line already present, no need to append
    file:close()
    print("Station-control already runs on startup.")
  end
else
  -- File doesn't exist, create it and write the line
  file = io.open(file_path, "w")
  file:write(line_to_append .. "\n")
  file:close()
  print("Created autorun.lua, running station-control on startup.")
end
