local fs = require("filesystem");
local shell = require("shell");
local argutil = require("payo-lib/argutil");

local USAGE = 
[===[Usage: find [path] [--type [dfs]] [--[i]name EXPR]
  path:  if not specified, path is assumed to be current working directory
  type:  returns results of a given type, d:directory, f:file, and s:symlinks
  name:  specify the file name pattern. Use quote to include *. iname is 
         case insensitive
]===]

local packedArgs = table.pack(...);
local optionConfiguration = {{{},{" ", "type", "name", "iname"}}};

local args, options, reason = argutil.parse(packedArgs, optionConfiguration);

local function writeline(value)
  io.write(value);
  io.write('\n');
end

if (not args or not options) then
  writeline(USAGE);
  writeline(reason);
  return 1;
end

if (#args > 1) then
  writeline(USAGE)
  return 1;
end

local path = "."; -- no arg

if (#args == 1) then
  path = args[1];
end

local bDirs = true;
local bFiles = true;
local bSyms = true;

local fileNamePattern = "";
local bCaseSensitive = true;

if (options.iname and options.name) then
  io.stderr:write("find cannot define both iname and name");
  return 1;
end

for k,op in pairs(options) do
  if (type(k) == "string") then
    if (k == "type") then
      bDirs = false;
      bFiles = false;
      bSyms = false;
      if (op.value == "f") then
        bFiles = true;
      elseif (op.value == "d") then
        bDirs = true;
      elseif (op.value == "s") then
        bSyms = true;
      else
        writeline(USAGE);
        return 4;
      end
    elseif (k == "name" or k == "iname") then
      bCaseSensitive = k == "name";
      fileNamePattern = op.value;
    end
  else
    writeline(USAGE);
    return 2;
  end
end

if (not fs.isDirectory(path)) then
  writeline("path is not a directory or does not exist: " .. path);
  return 1;
end

local function isValidType(spath)
  if (not fs.exists(spath)) then
    return false;
  end
    
  if (#fileNamePattern > 0) then
    local segments = fs.segments(spath);
    local fileName = segments[#segments];
        
    -- fileName is false when there are no segments (i.e. / only)
    -- which matches nothing
    if (not fileName) then
      return false;
    end
        
    local caseFileName = fileName;
    local casePattern = fileNamePattern;
        
    if (not bCaseSensitive) then
      caseFileName = caseFileName:lower();
      casePattern = casePattern:lower();
    end
        
    -- prefix any * with . for gnu find glob matching
    casePattern = casePattern:gsub("%*", ".*");
        
    local s, e = caseFileName:find(casePattern);
    if (not s or not e) then
      return false;
    end
        
    if (s ~= 1 or e ~= #caseFileName) then
      return false;
    end
  end

  if (fs.isDirectory(spath)) then
    return bDirs;
  elseif (fs.isLink(spath)) then
    return bSyms;
  else
    return bFiles;
  end
end

local function visit(rpath)
  local spath = shell.resolve(rpath);

  if (isValidType(spath)) then
    writeline(argutil.removeTrailingSlash(rpath));
  end

  if (fs.isDirectory(spath)) then
    local list_result = fs.list(spath);
    for list_item in list_result do
      visit(argutil.addTrailingSlash(rpath) .. list_item);
    end
  end
end

visit(path);

return 0;