local fs = require("filesystem");
local util = require("payo-lib/stringutil");

local function getParentDirectory(filePath)

  local pwd = os.getenv("PWD")

  if (not filePath) then
    return pwd
  end

  local si, ei = filePath:find("/[^/]+$")
  if (not si) then
    return pwd
  end

  return filePath:sub(1, si - 1)
end

local function hijackPath()
  local DELIM = ":";
  local PREF = getParentDirectory(os.getenv("_"));

  print("preferred path: " .. PATH);
    
  local pathText = os.getenv("PATH");
  if (not pathText) then
    io.stderr:write("unexpected failure. PATH has not been set\n");
    return 1;
  end

  local paths, indices = util.split(pathText, DELIM, true);

  -- now let's rebuild the path as we want it
  local path = PREF;
  table.remove(paths, indices[PREF]);
  indices[PREF] = nil;

  for i,p in ipairs(paths) do
    path = path .. DELIM .. p;
    print("adding [" .. p .. "] to path");
  end
    
  os.setenv("PATH", path);
end

hijackPath();
