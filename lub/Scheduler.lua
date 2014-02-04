--[[------------------------------------------------------

  # Scheduler

--]]------------------------------------------------------
local lub     = require 'lub'
local lib     = lub.class 'lub.Scheduler'

local setmetatable, create,           resume,           status           =
      setmetatable, coroutine.create, coroutine.resume, coroutine.status
      
local insert,       elapsed      =
      table.insert, lub.elapsed
      

local operations = {}
local scheduleAt

-- Create a new Scheduler object.
function lib.new()
  local self = {
    -- Points to the next thread to run
    at_next  = nil,
    -- Counts number of filedescriptors watching
    fd_count = 0,
    -- Translates Poller ids to threads.
    idx_to_thread = {},
    -- Default pollser
    poller = lub.Poller(),
  }
  return setmetatable(self, lib)
end

-- Start running scheduler with a main function.
function lib:run(main)
  scheduleAt(self, lub.Thread.make(main))
  self.should_run = true
  self:loop()
end

local function runThread(self, thread)
  local ok, a, b, c = resume(thread.co)
  if ok then
    if a then
      local operation = operations[a]
      if operation then
        if operation(self, b, c) then
          -- resume running thread immediately
          return true
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

function lib:loop()
  local thread
  local idx_to_thread = self.idx_to_thread
  while self.should_run do
    -- Get next thread to run
    local thread = self.at_next

    -- Extract current elements from list so that newly added threads do not
    -- alter list (and we give fair chances for threads to run).

    local now  = elapsed()
    -- Last element to be run now
    local last = thread
    -- Element past now frame
    local past = thread
    while past and past.at < now do
      last = past
      past = last.at_next
    end
    -- New head
    self.at_next = past
    
    if past then
      -- Cut link
      last.at_next = nil
    end

    -- Run scheduled threads in 'thread' linked list.
    while thread and self.should_run do
      -- Run thread
      if runThread(self, thread) then
        -- run same thread again
      else
        thread = thread.at_next
      end
    end

    if not self.should_run then
      break
    end

    -- Get timeout value
    local timeout = -1

    now    = elapsed()
    thread = self.at_next
    if thread then
      if thread.at < now then
        timeout = 0
      else
        timeout = thread.at - now
      end
    end

    if self.fd_count == 0 and timeout == -1 then
      -- No more at events and no more fd
      self.should_run = false
      print('done')
      break
    end

    -- Poll
    print('poll', timeout)
    if not self.poller:poll(timeout) then
      -- interrupted
      self.should_run = false
      print('interrupted')
      break
    end

    -- First collect events so that running the threads (and
    -- possibly adding new file descriptors) does not alter
    -- the list.
    local events = self.poller:events()
    if events then
      -- Execute poll events.
      local i = 1
      local ev_idx = events[i]
      local thread = ev_idx and idx_to_thread[ev_idx]
      while thread and self.should_run do
        if runThread(self, thread) then
          -- run fd thread again
        else
          -- run next fd thread
          i = i + 1
          ev_idx = events[i]
          if ev_idx then
            thread = idx_to_thread[ev_idx]
            if not thread then
              error(string.format("Unknown thread idx '%i' in poller", ev_idx))
            end
          else
            thread = nil
          end
        end
      end
    end
  end -- while self.should_run
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
