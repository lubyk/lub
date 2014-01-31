--[[------------------------------------------------------

  # Finalizer

  This object executes the provided method when it is
  garbage collected.
  
  WARN Avoid using this as much as possible. Only use *if you have no other way
  to do what you need*. It is very easy to create complicated bugs when doing
  too much work in the finalize function.

  As a rule of thumb:

  * Only call and use objects that would not die in the same garbage collection cycle.
  * Never call C functions (would crash).

  Usage example:
  
    local fin = lub.Finalizer(function(self)
      print(self.name .. ' is dying')
    end)

    fin.name = 'Old self'

    fin = nil

    garbagecollect('collect')

    --> "Old self is dying"

--]]------------------------------------------------------
local core  = require 'lub.core'
local lib   = core.Finalizer
local new   = core.Finalizer.new

local function dummy() end

-- Create a new finalizer object with the callback provided by `finalize`
-- function. The callback can be changed later by assigning a new function to
-- `self.finalize`. Created objects act like tables and all kinds of data can be
-- linked to them. Please read warning about what can and cannot be done inside
-- the finalize function.
--
-- Note that 'new' is not really available for optimization reasons. Use `lub.Finalize()` directly.
function lib.new(func)
  local self = new()
  self.finalize = func or dummy
  return self
end

-- Method called on object garbage collection.
function lib:finalize()
end

-- For performance reason, we do not use __call.
return lib.new
