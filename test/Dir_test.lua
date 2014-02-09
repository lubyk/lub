--[[------------------------------------------------------

  # lub.Dir test

--]]------------------------------------------------------
local lub    = require 'lub'
local lut    = require 'lut'
local should = lut.Test 'lub.Dir'

function should.listFilesMatchingPattern()
  local dir = lub.Dir(lub.path '|')
  local pattern = '%.lua$'
  for file in dir:glob(pattern) do
    assertMatch(pattern, file)
  end
end

function should.limitGlobDepth()
  local dir  = lub.Dir(lub.path '|')
  local list = {}
  local pattern = '.*'
  for file in dir:glob(pattern, 0) do
    lub.insertSorted(list, file)
  end
  assertValueEqual({
    'test/Dir_test.lua',
    'test/Template_test.lua',
    'test/all.lua',
    'test/lub_test.lua',
    -- should not enter fixtures
    -- 'test/fixtures/io.txt',
  }, list)
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
