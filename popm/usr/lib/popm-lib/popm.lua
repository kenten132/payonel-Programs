local config = require("payo-lib/config");

local lib = {};

function lib.read(url)
  if (type(url) ~= type("")) then
    return nil, "expecting url as string"
  end

  -- component.isAvailable('internet')

  local internet = require("internet");
  local wget = loadfile("/bin/wget.lua");

  -- wget can download to a file
  -- internet can download in memory using internet.request(url), returns an iteration function of strings

  -- -f force (overwrite local file)
  -- -q quiet
  -- -Q quiet quiet (no stderr)

  local tmp = "/tmp/popm-buffer"
  wget("", url, tmp)

  return config.load(tmp);
end

return lib;