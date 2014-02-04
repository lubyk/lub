--[[------------------------------------------------------

  lub.Thread
  ----------


--]]------------------------------------------------------
local lub    = require 'lub'
local lut    = require 'lut'
local should = lut.Test 'lub.Thread'

local Scheduler = lub.Scheduler
local Thread    = lub.Thread
local sleep     = lub.sleep

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

local elapsed = lub.elapsed

function should.sleep()
  local s = Scheduler()
  local t = {}
  s:run(function()
    Thread(function() 
      table.insert(t, 2)
      sleep(0.01) --> runs main thread again
      table.insert(t, 4)
      sleep(0.01)
      table.insert(t, 6)
    end)
    table.insert(t, 1)
    sleep(0.01) --> runs thread
    table.insert(t, 3)
    sleep(0.01) --> runs thread
    table.insert(t, 5)
  end)

  assertValueEqual({
    1, 2, 3, 4, 5, 6
  }, t)
end

function should.kill()
  local s = Scheduler()
  local t = {}
  local a, b
  s:run(function()
    a = Thread(function() 
      table.insert(t, 'a')
    end)

    b = Thread(function() 
      table.insert(t, 'b')
    end)

    a:kill()
  end)

  assertValueEqual({
    'b'
  }, t)
end

should:test()

