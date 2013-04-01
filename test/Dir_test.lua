--[[------------------------------------------------------

  lk.Dir test
  --------

  ...

--]]------------------------------------------------------
local lub = require 'lub'

local should = lub.Test 'lub.Dir'

function should.listFilesMatchingPattern()
  local dir = lub.Dir('modules/lubyk')
  local pattern = '%.lua$'
  for file in dir:glob(pattern) do
    assertMatch(pattern, file)
  end
end

should:test()
