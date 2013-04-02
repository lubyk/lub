--[[------------------------------------------------------

  lk.Dir test
  --------

  ...

--]]------------------------------------------------------
require 'lut'

local should = lut.Test 'lub.Dir'

function should.listFilesMatchingPattern()
  local dir = lub.Dir(lub.path '|')
  local pattern = '%.lua$'
  for file in dir:glob(pattern) do
    assertMatch(pattern, file)
  end
end

function should.listFiles()
  local base = lub.path '|'
  local list = {}
  for file in lub.Dir(base):list() do
    local p = string.gsub(file, '^'..base..'/', '')
    lub.insertSorted(list, p)
  end

  assertValueEqual({
    'Dir_test.lua',
    'Template_test.lua',
    'all.lua',
    'fixtures',
    'lub_test.lua',
  }, list)
end

function should.respondToContain()
  local dir = lub.Dir(lub.path '|')
  assertTrue(dir:contains('all.lua'))
end

should:test()
