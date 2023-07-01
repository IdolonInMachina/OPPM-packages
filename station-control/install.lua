local fs = require("filesystem")
-- Create folder if it doesn't exist
os.execute("mkdir -p /usr/lib/station-control")

-- Remove any old lua files in the directory
os.execute("rm -f /usr/lib/station-control/*.lua")

-- Download new files
function deleteFileIfExists(filePath)
  if fs.exists(filePath) then
      fs.remove(filePath)
  end
end

deleteFileIfExists("/usr/bin/station-control.lua")
os.execute("wget https://raw.githubusercontent.com/IdolonInMachina/OPPM-packages/master/station-control/dist/main.lua -O /usr/bin/station-control.lua")

os.execute("wget https://raw.githubusercontent.com/IdolonInMachina/OPPM-packages/master/station-control/dist/main-controller.lua -O /usr/lib/station-control/main-controller.lua")
os.execute("wget https://raw.githubusercontent.com/IdolonInMachina/OPPM-packages/master/station-control/dist/relay-node.lua -O /usr/lib/station-control/relay-node.lua")
os.execute("wget https://raw.githubusercontent.com/IdolonInMachina/OPPM-packages/master/station-control/dist/station-node.lua -O /usr/lib/station-control/station-node.lua")

-- Download  library files
os.execute("wget https://raw.githubusercontent.com/IdolonInMachina/OPPM-packages/master/station-control/dist/lualib_bundle.lua -O /usr/lib/station-control/lualib_bundle.lua")
os.execute("wget https://raw.githubusercontent.com/IdolonInMachina/OPPM-packages/master/station-control/src/json.lua -O /usr/lib/station-control/json.lua")

-- Link library files to /lib
local sourceDir = "/usr/lib/station-control/"
local targetDir = "/usr/lib/"

-- Get a list of files in the source directory
local files = fs.list(sourceDir)

-- Create symlinks for each Lua file
for file in files do
    if file:match("%.lua$") then
        local sourcePath = sourceDir .. file
        local targetPath = targetDir .. file
        -- Create the symlink
        os.execute(string.format("ln %s %s", sourcePath, targetPath))
    end
end


local file_path = "/home/autorun.lua"
local line_to_append = "/usr/bin/station-control.lua"

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

