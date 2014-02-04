--[[------------------------------------------------------

  lk.Timer
  --------

  The Timer contains a callback to execute a function at
  regular intervals. This timer does not drift (uses OS monotonic
  clock).

  Usage:

    local i = 0
    local tim = lub.Timer(0.5, function()
      print('Hello', lub.elapsed())
      i = i + 1
      if i == 10 then
        -- Use return value to set new interval. A
        -- return value of 0 stops the timer.
        return 0
      end
    end)

--]]------------------------------------------------------
local lub     = require 'lub'
local lib     = lub.class 'lub.Timer'
local assert, setmetatable, running,           yield,           floor,      elapsed   = 
      assert, setmetatable, coroutine.running, coroutine.yield, math.floor, lub.elapsed

function lib.new(interval, func)
  if not running() then
    error('Cannot create timer outside of running scheduler.')
  end
  local self = {
    interval = interval,
  }
  self.cb = function() self:run() end
  if func then
    self.tick = func
  end
  return setmetatable(self, lib)
end

-- The callback function. Note that first argument is the timer
-- itself.
function lib:tick() end

-- Start timer. The `ref` parameter is the start phase of the timer related
-- to lub.elapsed. This is used to keep multiple timers in sync.
function lib:start(ref)
  assert(self.interval > 0, 'Cannot run timer with negative or zero interval.')
  local ref = ref or self.ref
  local now = elapsed()
  if not ref then
    self.thread = lub.Thread(self.cb, now)
    self.ref = self.thread.at
  elseif ref > now then
    self.ref = ref
    self.thread = lub.Thread(self.cb, ref)
  else
    -- Compute next trigger from ref and interval
    local diff = now - ref
    local c = floor(diff / self.interval) + 1
    self.ref = now + self.interval * c
    self.thread = lub.Thread(self.cb, self.ref)
  end
end

function lib:run()
  if self.interval > 0 then
    while self.thread do
      local interval = self:tick()
      if interval then
        if interval <= 0 then
          self:setInterval(0)
          break
        else
          self.interval = interval
          yield('wait', interval)
        end
      else
        yield('wait', self.interval)
      end
    end
  end
end  

function lib:setInterval(interval)
  self.interval = interval

  if self.thread then
    -- Running timer: remove from scheduler.
    self:stop()
    if interval == 0 then
      -- Stop.
    else
      -- Add back and compute reference position for next trigger.
      self:start()
    end
  else
    -- Not running.
    self.interval = interval
  end
end

function lib:join()
  if self.thread then
    self.thread:join()
  end
end

function lib:stop()
  if self.thread then
    self.ref = self.thread.at
    self.thread:kill()
    self.thread = nil
  end
end


return lib
