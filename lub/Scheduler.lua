--[[------------------------------------------------------

  # Scheduler

--]]------------------------------------------------------
local lub     = require 'lub'
local lib     = lub.class 'lub.Scheduler'

local setmetatable, create,           resume,           status           =
      setmetatable, coroutine.create, coroutine.resume, coroutine.status
      

local operations = {}
local scheduleAt

-- Create a new Scheduler object.
function lib.new()
  local self = {
    -- Points to the next thread to run
    at_next = nil,
  }
  return setmetatable(self, lib)
end

-- Start running scheduler with a main function.
function lib:run(main)
  scheduleAt(self, lub.Thread.make(main))
  self:loop()
end

function lib:loop()
  local force_next
  local thread
  while true do
    -- Get next thread to run
    -- FIXME use collect to give fair time to threads
    if force_next then
      thread = force_next
      force_next = nil
    else
      thread = self.at_next
      if not thread then
        -- Nothing more to run.
        return
      end
      self.at_next = thread.at_next
    end
    
    -- Run thread
    local ok, a, b, c = resume(thread.co)
    if ok then
      if a then
        local operation = operations[a]
        if operation then
          if operation(self, b, c) then
            -- resume running thread immediately
            force_next = thread
          end
        else
          error('Invalid operation', a)
        end
      elseif status(thread.co) == 'dead' then
        -- Coroutine function finished
        -- Cleanup
        thread.co = nil
      end
    else
      -- Error
      if thread.error then
        -- Thread has an error handler, call it
        thread.error(a, debug.traceback(thread.co))
      else
        -- print('UNPROTECTED ERROR', a, thread.co, debug.traceback(thread.co))
        error(a)
      end
      
    end
  end
end

-- Add a thread and schedule at thread.at
-- The 'thread' object is actually `wrap`
function scheduleAt(self, thread)
  local at = thread.at

  local prev = self
  local ne   = prev.at_next
  while true do
    if not ne or at < ne.at then
      prev.at_next   = thread
      thread.at_next = ne
      break
    else
      prev = ne
    end
    ne = prev.at_next
  end
  if self.at_next.at ~= pat then
    -- FIXME: give some time to GUI ?
    -- self.poller:resumeAt(self.at_next.at)
  end

  -- Return true to resume running thread immediately
  return true
end

operations.create = scheduleAt

return lib
