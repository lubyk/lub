--[[------------------------------------------------------

  lub.Scheduler
  ------------


--]]------------------------------------------------------
local lub    = require 'lub'
local lut    = require 'lut'
local should = lut.Test('lub.Scheduler')

local Scheduler = lub.Scheduler

function should.create()
  local s = Scheduler()
  assertEqual('lub.Scheduler', s.type)
end

function should.runMainLoop()
  local x
  local s = Scheduler()
  s:run(function()
    x = 1
  end)
  assertEqual(1, x)
end

function should.restart()
  local x
  local s = Scheduler()
  s:run(function()
    x = 1
  end)

  s:run(function()
    x = 2
  end)
  assertEqual(2, x)
end

should:test()
