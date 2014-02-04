--[[------------------------------------------------------

  lub.Thread
  ----------


--]]------------------------------------------------------
local lub    = require 'lub'
local lut    = require 'lut'
local should = lut.Test('lub.Thread', {coverage = false})

local Scheduler = lub.Scheduler
local Thread    = lub.Thread

function should.notCreateOutOfScheduler()
  assertError('Cannot create thread outside of running scheduler', function()
    local t = Thread(function()
    end)
  end)
end

function should.createInScheduler()
  local s = Scheduler()
  local t
  s:run(function()
    t = Thread(function()
    end)
  end)
  assertEqual('lub.Thread', t.type)
end

function should.notCreateWithoutFunction()
  local s = Scheduler()
  s:run(function()
    assertError('Cannot create thread without function.', function()
      local t = Thread()
    end)
  end)
end

function should.runThreadsInOrder()
  local s = Scheduler()
  local t = 1
  s:run(function()
    Thread(function()
      t = t * 10
    end)

    Thread(function()
      t = t + 1
    end)
  end)
  assertEqual(11, t)
end

function should.gcOldThreads()
  local s = Scheduler()
  local t = 0
  s:run(function()
    Thread(function() end).fin = lub.Finalizer(function()
      t = t + 1
    end)
  end)
  collectgarbage('collect')
  assertEqual(1, t)
end

function should.sleep()
  local s = Scheduler()
  local t = 0
  s:run(function()
    Thread(function() 
      t = t * 10
      sleep(0.01) --> runs main thread again
      t = t * 2
      sleep(0.01)
    end)
    t = t + 1
    sleep(0.01) --> runs thread
    assertEqual(10, t)
    t = t + 1
    sleep(0.01) --> runs thread
    assertEqual(22, t)
  end)
end


should:test()

