--[[------------------------------------------------------

  # Parameter save and restore

  This class acts as a proxy around lua tables allowing
  paramter save and recall.

--]]------------------------------------------------------
local lub  = require 'lub'
local yaml = require 'yaml'
-- We keep table keys sorted to improve settings file stability (useful with
-- versioning systems).
yaml.configure {
  sort_table_keys = true,
}

local lib = lub.class('lub.Param')

-- Metatable for proxies.
local ProxyMt = {}

local private = {}

-- ## Dependencies
--
-- * yaml

-- # Class functions

-- Create a new parameter helper saving content to `filepath`. If the file path
-- is not provided, the default is to use the current script name with ".yml"
-- extension. For example "foo.lua" parameters would be saved to "foo.lua.yml".
function lib.new(filepath)
  local self = {
    preset   = 1,
    presets  = {},
    filepath = filepath or lub.path('&', 3)..'.yml',
    proxies  = {},
    mappings = {},
  }
  setmetatable(self, lib)
  private.loadpath(self, self.filepath)
  return self
end

-- # Methods

-- Create a proxy table to write to instead of the original. Writing to the
-- proxy stores the parameter value and write the value into the original table.
-- Since a single Param object can store values from different tables, the
-- proxy_name string is used to separate values during save/restore. Default
-- value for `proxy_name` is 'main'.
function lib:proxy(original_table, proxy_name)
  local proxy_name = proxy_name or 'main'
  local proxy = setmetatable({
    __param     = self,
    __storage   = {},
    __original  = original_table,
    __name      = proxy_name,
  }, ProxyMt)
  self.proxies[proxy_name] = proxy
  return proxy
end

-- nodoc
function lib:setValue(proxy, key, value)
  print(proxy.__name, key, value)
  -- Cache value so that we can write preset to file.
  rawset(proxy.__storage, key, value)
  proxy.__original[key] = value
end

-- Serialize all preset values to yaml.
function lib:dump()
  return yaml.dump({
    preset   = self.preset,
    presets  = self.presets,
    mappings = self.mappings,
  })
end

-- Save current table values in current preset.
function lib:savePreset()
  local preset = self.presets[tostring(self.preset)]
  if not preset then
    preset = {}
    self.presets[tostring(self.preset)] = preset
  end
  for proxy_name, proxy in pairs(self.proxies) do
    local tbl = preset[proxy_name]
    if not tbl then
      tbl = {}
      preset[proxy_name] = tbl
    end
    for k, value in pairs(proxy.__storage) do
      preset[k] = value
    end
  end

  -- Write to file
  private.save(self)
end

function lib:selectPreset(preset_name)
  local preset_data = self.presets[tostring(preset_name)]
  if preset_data then
    -- Change values defined in preset_data
    for proxy_name, proxy_data in pairs(preset_data) do
      local proxy = self.proxies[proxy_name]
      for key, value in pairs(proxy_data) do
        self:setValue(proxy, key, value)
      end
    end

  else
    -- New preset with same values as current values
  end
  self.preset = preset_name
end



--- Proxy metatable
function ProxyMt.__index(proxy, key)
  return proxy.__original[key]
end

function ProxyMt.__newindex(proxy, key, value)
  proxy.__param:setValue(proxy, key, value)
end

  
-- Load presets and mappings from files system
function private:loadpath(filepath)
  if lub.exist(filepath) then
    local data = yaml.loadpath(filepath)
    self.presets  = data.presets or {}
    self.mappings = data.mappings or {}
    if data.preset then
      self:selectPreset(data.preset)
    end
  end
end

function private:save()
  lub.writeall(self.filepath, self:dump())
end

return lib
