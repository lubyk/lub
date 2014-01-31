--[[------------------------------------------------------

  lub.Finalizer test
  -----------------

  ...

--]]------------------------------------------------------
local lub    = require 'lub'
local lut    = require 'lut'
-- Cannot test coverage since lub.Finalizer returns a function.
local should = lut.Test('lub.Finalizer', {coverage = false})

function should.autoload()
  assertType('function', lub.Finalizer)
end

function should.triggerOnGc()
  local continue = false
  local fin = lub.Finalizer(function()
    continue = true
  end)
  -- We make sure that we can set different finalizers at the same time.
  local fin2 = lub.Finalizer(function()
    continue2 = true
  end)
  assertFalse(continue)
  assertFalse(continue2)
  collectgarbage('collect')
  assertFalse(continue)
  assertFalse(continue2)
  fin = nil
  collectgarbage('collect')
  assertTrue(continue)
  assertFalse(continue2)
  fin2 = nil
  collectgarbage('collect')
  assertTrue(continue)
  assertTrue(continue2)
end

should:test()
