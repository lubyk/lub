--[[------------------------------------------------------

  # default Poller

  Normally, end users do not interact directly with the poller.
  It is used internally by lub.Scheduler to wait on file
  descriptors or sleep.

-- # Poller API
-- TODO  
--

--]]------------------------------------------------------
local lub   = require 'lub'
local core  = require 'lub.core'
local lib   = core.Poller

print('LOADING POLLER')

-- Create a new poller. Optional `reserve` argument is used to reserve slots
-- in memory for items to poll on (default = 8).
-- function lib.new(reserve)

-- Polls for new events with a maximal waiting time of `timeout`. Returns `true`
-- on success and `false` on interruption.
-- function lib.poll(timeout)

-- Return a table with all event idx or nil. Used after a call to #poll.
-- function lib.events()

return lib
