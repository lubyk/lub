--[[--------------------
  # Lubyk base module

  Currently, this module contains a core functions (code loading, templates, 
  helpers).

--]]--------------------
local private = {}
local gsub  = string.gsub
local sub   = string.sub
local match = string.match
local len   = string.len

local CALL_TO_NEW = {__call = function(lib, ...) return lib.new(...) end}

local lib = {}
lub = lib

--[[------------------------------------------------------

  The module also contains utility functions related to path
  management, script introspection and some string/array methods.

--]]------------------------------------------------------

-- ## Dependencies
--
-- + lfs: luafilesystem
local lfs = require 'lfs'

-- Current version for 'lub' module. Minor version numbers are never released
-- and are used during development.
lib.VERSION = '1.0.0'

-- # Class management
--
-- Declare a new class with the following conventions:
--
-- * The `.type` field contains the full class name.
-- * The returned table is the metatable for all instances of this class and
--   contains the functions.
-- * Calling the table with `foo.Bar()` is an alias for a call to
--   `foo.Bar.new`.
--
-- Usage:
--
--   local lub = require 'lub'
--   local lib = lub.class 'lub.Doc'
--   -- ...
--   return lib
function lib.class(class_name, tbl)
  local lib = tbl or {}
  lib.type = class_name
  lib.__index = lib

  return setmetatable(lib, CALL_TO_NEW)
end

-- # Filesystem

-- Find the source of the current file or the file up x levels in the call
-- chain (-1 = up one level).
local function scriptSource(level)
  local level = level or 0
  return debug.getinfo(2 - level).source
end

-- Find the path of the current script or the script up x levels in the call
-- chain (-1 = up one level). The path is relative to the current directory.
--
--   -- get path of running script
--   local my_path = lub.scriptPath()
--   --> 'test/lk_test.lua'
-- 
-- If you need an absolute path, use #absolutizePath.
local function scriptPath(level)
  local level = level or 0
  return match(scriptSource(level - 1), '^@(.*)$')
end

-- Find the directory of the current script or the directory of the script up x
-- levels in the call chain (-1 = up one level). This is the same as #scriptPath
-- but it returns the parent directory.
local function scriptDir(level)
  local level = level or 0
  local file = scriptPath(level - 1)
  assert(file, "Cannot use scriptDir here because of a tail call optimization.\n"..debug.traceback())
  if match(file, '/') then
    local p = gsub(file, '/[^/]+$', '')
    return p
  else
    return '.'
  end
end

-- Return a path by resolving special initial characters:
--
-- + `/`   : absolute path, resolves '..' in path.
-- + `|`   : path relative to script directory, resolves '..' in path.
-- + `&`   : returns current script path.
--
-- For example:
--
--   print(lub.path '|')
--   --> current script directory
--
--   print(lub.path '|..')
--   --> parent of script directory
--
function lib.path(path, level)
  level = level or 2
  local chr = sub(path, 1, 1)
  if chr == '|' or chr == '&' then
    local src = debug.getinfo(level).source
    if src == '=(tail call)' then
      src = debug.getinfo(level + 1).source
    end
    local s = match(src, '^@(.*)$')
    if chr == '&' then
      return s
    end
    local b = lib.dir(s)
    if len(path) == 1 then return b end
    local r = sub(path, 2, -1)
    return lib.absolutizePath(b..'/'..r)
  else
    return lib.absolutizePath(path)
  end
end

-- Test for file/directory existence at `path`. If the element exists, returns
-- the file type such as *'directory'* or *'file'*. Returns nil if there is
-- nothing at the given path.
function lib.fileType(path)
  if not path then return nil end
  local attrs = lfs.attributes(path)
  return attrs and attrs.mode
end

-- Return true if the file or folder pointed by `path` exists.
-- function lib.exist(path)

-- nodoc
lib.exist = lib.fileType

-- Return the content of a file as a lua string (not suitable for very long
-- content where parsing the file chunks by chunks is better). The method
-- accepts either a single `path` argument or a `basepath` and relative `path`.
function lib.content(basepath, path)
  if path then
    path = string.format('%s/%s', basepath, path)
  else
    path = basepath
  end
  local f = assert(io.open(path, 'rb'))
  local s = f:read('*all')
  f:close()
  return s
end

-- Write `data` to `filepath`, creating path folders if necessary. If
-- `check_diff` is true, only write if the content has changed to avoid
-- changing stat information on the file.
function lib.writeall(filepath, data, check_diff)
  -- get base directory and build components if necessary
  lib.makePath(lib.dir(filepath))
  if check_diff and lib.exist(filepath) then
    if data == lib.content(filepath) then
      return true
    end
  end
  local f = assert(io.open(filepath, 'wb'))
  local s = f:write(data)
  f:close()
  return s
end

-- Build necessary folders to create a given `path`.
function lib.makePath(path)
  local fullpath = lib.absolutizePath(path)
  private.makePathPart(fullpath, fullpath)
end

-- Move a file or directory from `path` to `new_path`. This is like "os.rename"
-- but it also builds necessary path components in new_path.
function lib.move(path, new_path)
  lib.makePath(lib.dir(new_path))
  return os.rename(path, new_path)
end

-- Copy a file from `path` to `new_path`. Builds necessary path components
-- in new_path.
function lib.copy(path, new_path)
  lib.makePath(lib.dir(new_path))
  return os.execute(string.format('cp %s %s', lib.shellQuote(path), lib.shellQuote(new_path)))
end

-- Delete the file located at `path`. Does nothing if the element at `path` does
-- not exist (already removed).
function lib.rmFile(path)
  local typ = lib.fileType(path)
  if not typ then return end
  assert(typ == 'file', string.format("Cannot remove '%s': it is a %s.", path, typ))
  os.remove(path)
end

-- Remove the directory at `path`. If `recursive` is true, remove recursively.
-- *This is a dangerous method* if the source path is not ensured to be exempt
-- of mistakes.
function lib.rmTree(path, recursive)
  local fullpath = lib.absolutizePath(path)
  if not lib.exist(fullpath) then
    return true
  end
  if fullpath ~= '/' and fullpath ~= '' then
    -- bug paranoia
    if not recursive then
      return lfs.rmdir(fullpath)
    else
      local code = string.format('rm -r %s', lib.shellQuote(fullpath))
      if os.execute(code) == 0 then
        return true
      else
        return false
      end
    end
  end
end

-- Return the parent folder and filename from a `filepath`. Usage:
--
--   local base, file = lub.dir(filepath)
-- 
-- This can also be used on urls.
function lib.dir(filepath)
  local base, file = match(filepath, '(.*)/(.*)$')
  if not base then
    return '.', filepath
  elseif base == '' then
    -- '/' == root ?
    return '/', file
  else
    return base, file
  end
end

-- nodoc
function lib.pathDir(...)
  return lib.deprecation('lub', 'pathDir', 'dir', ...)
end

-- Return an absolute path from a `path` and optional `basepath`. If basepath is
-- not provided, the method uses the current directory. This method
-- resolves `/../` and `/./` in paths and returns a clean path. Can also be
-- used with urls.
--
-- For example:
--
--   local abs_path = lub.absolutizePath('foo/bar/../baz', '/home')
--   --> '/home/foo/baz'
function lib.absolutizePath(path, basepath)
  if not match(path, '^/') then
    path = string.format('%s/%s', basepath or lfs.currentdir(), path)
  end
  -- resolve '/./' and '/../'
  local parts = lib.split(path, '/')
  local path = {}
  for i, part in ipairs(parts) do
    if part == '.' then
      -- ignore
    elseif part == '..' then
      -- move back
      -- 1 = '', 2 = 'xxx', 3 = '..' ==> 1 = ''
      if i > 2 then
        table.remove(path, #path)
      end
    else
      table.insert(path, part)
    end
  end
  return lib.join(path, '/')
end

-- Transform an absolute path or url to a relative path with given base. For 
-- example:
--
--   local rel = lub.absToRel('/home/foo/bar', '/home/foo/baz')
--   --> '/home/foo/bar'
--   local rel = lub.absToRel('/home/foo/bar', '/home/foo')
--   --> 'bar'
function lib.absToRel(abs_string, base)
  local l = string.len(base)
  local s = string.sub(abs_string, 1, l)
  if s == base then
    if base == abs_string then
      return abs_string
    else
      return string.sub(abs_string, l+2, -1)
    end
  else
    return abs_string
  end
end

-- # Strings, Arrays

-- Removes white spaces at the beginning and end of the string `str`.
function lib.strip(str)
  return match(str, '^[ \t\n\r]*(.-)[ \t\n\r]*$')
end

-- Split a string `str` into elements separated by the pattern `pat`. The
-- function returns a table.
--
--   local t = lub.split('foo/bar/baz', '/')
--   --> {'foo', 'bar', 'baz'}
function lib.split(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  if not pat then
    local i = 1
    while true do
      local s = string.sub(str, i, i)
      if s == '' then
        break
      else
        table.insert(t, s)
      end
      i = i + 1
    end
  else
    local fpat = '(.-)' .. pat
    local last_end = 1
    local s, e, cap = string.find(str,fpat, 1)
    while s do
      table.insert(t,cap)
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
    end
  end
  return t
end

-- Join elements of a table `list` with separator `sep`. Returns a string.
--
--   local x = lub.join({'foo', 'bar', 'baz'}, '.')
--   --> 'foo.bar.baz'
function lib.join(list, sep)
  local res = nil
  for _, part in ipairs(list) do
    if not res then
      res = part
    else
      res = res .. sep .. part
    end
  end
  return res or ''
end

-- Insert `elem` into a `list`, keeping entries in "list" sorted. If elem is not
-- a string, the `elem[key]` is used to get a string for sorting.
function lib.insertSorted(list, elem, key)
  local pos = -1
  for i, n in ipairs(list) do
    local a, b = n, elem
    if key then
      a = a[key]
      b = b[key]
    end
    if a > b then
      pos = i
      break
    end
  end
  if pos == -1 then
    table.insert(list, elem)
  else
    table.insert(list, pos, elem)
  end
end

-- Merge values in `table` inside `source`. All keys are considered (array and
-- hash).
function lib.merge(source, table)
  for k, v in pairs(table) do
    source[k] = v
  end
end

local function deepMerge(base, key, value)
  local base_v = base[key]
  if type(value) == 'table' then
    if not base_v then
      base[key] = value
      return true
    else
      -- merge
      local changed = false
      for k, v in pairs(value) do
        changed = deepMerge(base_v, k, v) or changed
      end
      return changed
    end
  elseif base_v == value then
    -- nothing changed
    return false
  else
    base[key] = value
    return true
  end
end
-- nodoc
lib.deepMerge = deepMerge

-- Deep merge `value` into `base` at `key`. Returns true if *base* has been
-- changed. For example:
--
--   local base = {a = { b = 4, c = 5 }}
--   lub.deepMerge(base, 'a', { c = 5 })
--   --> false (nothing changed)
--
--   lub.deepMerge(base, 'a', { c = 6 })
--   --> true, base = {a = { b = 4, c = 6 }}
-- function lib.deepMerge(base, key, value)
-- # Debugging

local orig_req = require
-- Print calls to `require`. This can be used to list all code dependencies.
-- Usage:
--
--   lub.traceRequire(true)
--   -- From now on, all require statements are printed.
-- 
-- If you simply want to make sure no require is not called to autoload code
-- after some point, you should use [Autoload.strict](Autoload.html#strict).
function lib.traceRequire(enable)
  if enable then
    require = function(path)
      print("require '"..path.."'")
      return orig_req(path)
    end
  else
    require = orig_req
  end
end

-- Print a log message with the current file name and line. This is better then
-- using "print" because it gives us some information on the context of the 
-- print statement.
--
--   lub.log('foo')
--   --> lub/util.lua:426:  foo
function lib.log(...)
  local trace = lib.split(debug.traceback(), '\n\t')
  local part = trace[3]
  if part:match('%(tail call%)') then
    part = trace[4]
  end
  local file, line = match(part, '^([^:]+):([^:]+):')
  if file and line then
    print(string.format('%s:%i:', file, line), ...)
  else
    print(part, ...)
  end
end


-- # Miscellanous

-- Declare a method as being deprecated. This should be used when method names
-- are changed to avoid breaking code without warnings. The syntax is:
--
--   function lib.badName(...)
--     return lib.deprecation('lub', 'badName', 'betterName', ...)
--   end
-- 
-- When someone uses the "badName" method, a deprecation warning is printed:
--
--   [DEPRECATION] {traceback}
--       'lub.badName' is deprecated. Please use 'lub.betterName' instead.
function lib.deprecation(lib_name, old, new, ...)
  local trace = lib.split(debug.traceback(), '\n\t')[4]
  local arg = ...
  if arg then
    print(string.format("[DEPRECATION] %s\n\t'%s.%s' is deprecated. Please use '%s.%s' instead.", trace, lib_name, old, lib_name, new))
    return package.loaded[lib_name][new](...)
  else
    print(string.format("[DEPRECATION] %s\n\t'%s.%s' is deprecated and will be removed. Please use '%s' instead.", trace, lib_name, old, new))
  end
end

-- Quote string `str` so that it can be inserted in a shell command. Example:
--
--   os.execute(string.format('latex %s', lub.shellQuote(filepath)))
function lib.shellQuote(str)
  str = gsub(str, '\\', '\\\\')
  return '"' .. gsub(str, '"', '\\"') .. '"'
end

function private.makePathPart(path, fullpath)
  local file_type = lib.fileType(path)
  if file_type == 'file' then
    error(string.format("Could not build path '%s' ('%s' is a file).", fullpath, path))
  elseif file_type == 'directory' then
    return -- done
  else
    local base = lib.dir(path)
    private.makePathPart(base, fullpath)
    -- base should exist or an error has been raised
    lfs.mkdir(path)
    -- done
  end
end

-- We only enable autoload once all is loaded so that the 'Autoload' class finds
-- 'lub' library.
package.loaded.lub = lib

-- nodoc
lib.Autoload = require 'lub.Autoload'

lib.Autoload('lub', lib)


-- # Classes
--
-- WARN: We are currently migrating content from [lk](lk.html) module. Not all
-- classes have been migrated and documented.

return lib
