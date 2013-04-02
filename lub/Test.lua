--[[------------------------------------------------------
  # Test Suite

  The test suite is used to declare tests and group them
  by class or module.

--]]------------------------------------------------------
local debug   = require 'debug'
local lub     = require 'lub'
local lib     = lub.class 'lub.Test'
local private = {}

-- Currently running test.
local current = nil

-- Create a new test suite. It is good practice to use 'should' as
-- local name for this suite since it makes tests more readable. The
-- `name` should be the exact name of the class or module being tested
-- in case the coverage option is activated in test (it is *on* by default).
--
-- Full test file example:
--
--   require 'lub'
--   local should = lub.Test 'animal.Dog'
--
--   function should.bark()
--     local medor = animal.Dog('Medor')
--     assertEqual('Wouaf!', medor:bark())
--   end
--
--   -- Test files must end with this line
--   should:test()
-- 
-- The optional `options` table can contain the following keys to alter testing
-- behavior:
--
-- + `coverage` : if set to false, untested functions will not be reported. If
--                `lub.Test.mock` contains a string, this will be used as the
--                body of missing tests and outputed.
-- + `metatable`: the metatable for the class being tested if it cannot be 
--                found in global namespace.
-- 
-- In a test file, you can ignore coverage warning for deprecated functions by
-- setting `should.ignore.[func_name] = true`.
function lib.new(name, options)
  options = options or {}
  local self = {
    -- We store everything in _info to make sure __newindex is called to add
    -- new tests.
    _info = {
      name = name,
      tests = {},
      errors = {},
      user_suite = options.user_suite,
    },
    -- This is used to ignore coverage errors for deprecated functions.
    ignore = {},
  }
  -- This is to get setup/teardown functions.
  self._info.self = self

  if options.coverage == false then
    self._info.coverage = false
  else
    self._info.coverage = true
  end
  setmetatable(self, lib)
  table.insert(lib.suites, self)
  -- default setup and teardown functions
  return self
end

-- Return tests to only run in single mode (not in batch) because they require
-- user interaction. Usage:
--
--   local should   = lub.Test 'lub.Dir'
--   local withUser = should:testWithUser()
--
--   function withUser.should.displayTable()
--   end
--
function lib:testWithUser()
  local obj = lib.new(self._info.name .. '[ux]', {
    user_suite = true,
    coverage   = false,
  })
  -- this is to enable syntax like: withUser.should.receiveClick()
  obj.should = obj
  return obj
end

-- # Global settings

-- nodoc
lib.suites = {}
-- nodoc
lib.file_count = 0

-- Default timeout value for #timeout function.
lib.TIMEOUT = 5

-- To only test a single method.
lib.only = false
-- Set to `true` to enable verbose mode (display each test title).
lib.verbose = false
-- Abort batch mode (can be set in a test).
lib.abort = false
-- Untested functions are listed. If mock contains a string, it is used as
-- body to generate mockups of untested functions.
lib.mock = false


-- # Setup, teardown
--
-- If you need to run some code before or after every test, you can define
-- the `setup` (executed before each test) and/or `teardown` (executed after
-- each test independantly of success or failure) functions:
--
--   local should = lub.Test 'lub.Dir'
--   
--   function should.teardown()
--     -- cleanup
--   end

-- Dummy setup function (does nothing).
function lib.setup() end

-- Dummy teardown function (does nothing).
function lib.teardown() end

-- # Declare tests

-- Tests are declared by adding functions to the test suite. Note that these
-- functions do not have access to 'self'.
--
-- Example test declaration:
--
--   functions should.beHappy()
--     assertTrue(true)
--   end
function lib:__newindex(key, value)
  rawset(self, key, value)
  if type(value) == 'function' then
    if key ~= 'setup' and
       key ~= 'teardown' and
       key ~= 'should' then
      table.insert(self._info.tests, {key, value})
    end
  end
end

-- # Run tests
--
-- Use `should:test()` to run the tests in all suites at once. You can append this
-- call at the end of the file to run the test when running the file:
--
--   function should.testLast()
--   end
--
--   -- Run all tests now.
--   should:test()

-- nodoc
function lib:test(batch)
  private.parseArgs()
  lib.total_exec  = 0
  lib.total_count = 0
  lib.total_asrt  = 0
  lib.total_fail  = 0

  private.runSuite(self)
  private.reportSuite(self)
  private.report()
end

-- # Batch testing

-- Test all files in `list_or_path` matching `pattern`. Typical usage is to
-- create an `all.lua` file in the tests folder with:
--
--   local lub = require 'lub'
--   lub.Test.files(lub.path '|')
--
-- This will run tests for all files matching the default pattern `%_test.lua$`.
-- If the optional `reject` pattern is provided, paths matching this pattern
-- will be, well, rejected. See [lub.path](lub.html#path) for details on the
-- pipe syntax.
function lib.files(list_or_path, pattern, reject)
  private.parseArgs()
  pattern = pattern or '%_test.lua$'
  local sources = type(list_or_path) == 'table' and list_or_path or {list_or_path}

  -- First disable should:test()
  local test = lib.test
  lib.test = function() end

  local list = {}
  for _, path in ipairs(sources) do
    for file in lub.Dir(path):glob(pattern) do
      if reject and string.match(file, reject) then
        -- skip
      else
        table.insert(list, file)
      end
    end
  end

  for _, file in ipairs(list) do
    lib.file_count = lib.file_count + 1
    dofile(file)
  end

  -- Run all tests.
  private.testAll()
end
------------------------------------ ASSERTIONS ---------------------------

-- # Assertions

local function formatArg(arg)
  local argtype = type(arg)
  if argtype == "string" then
    return "'"..arg.."'"
  elseif argtype == "number" or argtype == "boolean" or argtype == "nil" then
    return tostring(arg)
  else
    return tostring(arg)
  end
end

local function assert(ok, msg, up_count)
  up_count = up_count or 2
  current.assert_count = current.assert_count + 1
  if not ok then
    error(msg, up_count + 1)
  end
end

-- Force a test to fail with a given `msg`.
function fail(msg)
  assert(false, msg)
end

-- Assert that `val` is false.
function assertFalse(val)
  assert(not val, string.format('Should fail but passed.'))
end

-- Assert that `ok` is true. If `msg` exists, it is used in case of failure
-- in place of the default fail message.
function assertTrue(ok, msg)
  assert(ok, msg or string.format('True expected but was false.'))
end

-- Assert that `value` is equal to `expected`. If `expected` is a number,
-- the `resolution` parameter can be used to cope with numerical errors.
-- The actual test for numbers is:
--
--   local ok = (value >= expected - resolution) and (value <= expected + resolution)
-- 
-- For other types, this tests raw equality (same object). To compare table
-- contents, use #assertValueEqual.
function assertEqual(expected, value, resolution, up_count)
  up_count = up_count or 1
  if resolution and type(expected) == 'number' then
    local ok = (value >= expected - resolution) and (value <= expected + resolution)
    assert(ok, string.format('Expected %s but found %s (resolution: %f).', formatArg(expected), formatArg(value), resolution), up_count + 1)
  else
    assert(value == expected, string.format('Expected %s but found %s.', formatArg(expected), formatArg(value)), up_count + 1)
  end
end

-- For tables, recursively test that all keys contain the same values.
function assertValueEqual(expected, value, resolution, up_count)
  up_count = up_count or 1
  if type(expected) == 'table' then
    assertTableEqual(expected, value, resolution, up_count + 1)
  else
    assertEqual(expected, value, resolution, up_count + 1)
  end
end

-- This is like #assertValueEqual but does not check for table type.
function assertTableEqual(expected, value, resolution, up_count)
  up_count = up_count or 1
  assertEqual('table', type(value), resolution, up_count + 1)
  for k, v in pairs(expected) do
    assertValueEqual(v, value[k], resolution, up_count + 1)
  end
  for k, v in pairs(value) do
    if expected[k] == nil then
      assert(false, string.format("Expected no '%s' key but found %s.", k, formatArg(v)), up_count + 1)
    end
    assertValueEqual(v, value[k], resolution, up_count + 1)
  end
  assertEqual(#expected, #value, up_count + 1)
end

-- Asserts that `value` is not equal to `unexpected`.
function assertNotEqual(unexpected, value)
  assert(value ~= unexpected, string.format('Should not equal %s.', formatArg(unexpected)))
end

-- Assert that `value` matches `pattern` using `string.match`.
function assertMatch(pattern, value)
  assert(type(value) == 'string', string.format('Should be a string but was a %s.', type(value)))
  assert(string.find(value, pattern), string.format('Expected to match %s but was %s.', formatArg(pattern), formatArg(value)))
end

-- Assert that `value` does not match `pattern`. If `msg` is provided, use this
-- in case of failure.
function assertNotMatch(pattern, value, msg)
  assert(type(value) == 'string', string.format('Should be a string but was a %s.', type(value)))
  assert(not string.find(value, pattern), string.format('Expected to not match %s but was %s.', formatArg(pattern), formatArg(value)))
end

-- Assert that calling `func` generates an error message that matches `pattern`.
function assertError(pattern, func)
  local ok, err = pcall(func)
  assert(not ok, string.format('Should raise an error but none found.'))
  assert(string.find(err, pattern), string.format('Error expected to match %s but was %s.', formatArg(pattern), formatArg(err)))
end

-- Assert that calling `func` passes without errors. The optional `teardown` 
-- function can be used to cleanup after the function call whether it passes
-- or fails.
function assertPass(func, teardown)
  local ok, err = pcall(func)
  if teardown then
    teardown()
  end
  if ok then
    assert(true)
  else
    assert(false, err)
  end
end

-- Assert that `value` is less then `expected`.
function assertLessThen(expected, value)
  assert(value < expected, string.format('Should be less then %f but was %f.', expected, value))
end

-- Assert that the Lua type of `value` is `expected` ('number', 'table',
-- 'function', etc).
function assertType(expected, value)
  assert(type(value) == expected, string.format('Should be a %s but was %s.', expected, type(value)))
end

-- Assert that `value` is nil.
function assertNil(value)
  assert(type(value) == 'nil', string.format('Should be a Nil but was %s.', type(value)))
end

-- Assert that `value` is in the range defined by [`t1`, `t2`[.
function assertInRange(t1, t2, value)
  assert(value >= t1 and value < t2, string.format('Should be in [%f, %f[ but was %f.', t1, t2, value))
end

-- Execute `func` every 0.3 s for `timeout` seconds or until the callback
-- function returns true. The callback is passed the elapsed time as parameter.
-- If no `timeout` value is passed, the default #TIMEOUT is used (5 seconds).
-- 
-- If the timeout is reached, an error with `msg` (or a default text) is displayed.
--
--   function should.browseNetwork()
--     local found_remote = false
--     -- ...
--     assertPassWithTimeout(function()
--       return found_remote
--     end, 'Could not find remote device')
--   end
function assertPassWithTimeout(func, msg, timeout)
  local ok = false
  -- if not self._suite._info.user_suite then
  --   printf("Using timeout without user in %s (%s).", self._suite._info.name, self._name)
  -- end
  if not func then
    msg  = func
    func = timeout
    timeout = self.TIMEOUT
  end
  local start = elapsed()
  while true do
    local el = elapsed()
    ok = func(el)
    if ok or elapsed() > start + timeout then break end
    sleep(0.3)
  end
  assert(ok, msg or 'Did not pass before timeout.')
end

--=============================================== PRIVATE

function private:runSuite()
  if self._info.coverage then
    -- Make sure all functions are called at least once.
    local meta = self._info.metatable
    if not meta then
      local parent
      parent, meta = _G, _G
      for _, part in ipairs(lub.split(self._info.name, '%.')) do
        parent = meta
        meta   = meta[part]
        if not meta then break end
      end
    end
    if not meta then
      -- try in package.loaded
      local parent
      parent, meta = package.loaded, package.loaded
      for _, part in ipairs(lub.split(self._info.name, '%.')) do
        parent = meta
        meta   = meta[part]
        if not meta then break end
      end
    end
    _G.assert(meta, string.format("Testing coverage but '%s' metatable not found.", self._info.name))

    local coverage = {}
    self._info.coverage_ = coverage
    for k, v in pairs(meta) do
      if type(v) == 'function' then
        coverage[k] = v
        -- Dummy function to catch first call without using debug hook.
        meta[k] = function(...)
          coverage[k] = true
          meta[k] = v
          return v(...)
        end
      end
    end

    function self.testAllFunctions()
      local all_ok = true
      local not_tested = {}
      for k, info in pairs(coverage) do
        if info ~= true and not self.ignore[k] then
          if lib.mock then
            k = string.upper(string.sub(k, 1, 1))..string.sub(k, 2, -1)
            lub.insertSorted(not_tested, {
              text = 'function should.respondTo'..k..'()\n'..lib.mock..'end',
              line = tonumber(debug.getinfo(info).linedefined),
            }, 'line')
          else
            lub.insertSorted(not_tested, "'"..k.."'")
          end
          all_ok = false
        end
      end
      local list
      if lib.mock then
        list = '\n\n'
        for _, info in ipairs(not_tested) do
          list = list .. '\n\n' .. info.text .. ' --' .. info.line
        end
      else
        list = lub.join(not_tested, ', ')
      end
      assertTrue(all_ok, string.format("Missing tests for %s", list))
    end
  end

  local exec_count = 0
  local fail_count = 0
  local skip_count = 0
  local errors = self._info.errors
  local test_var
  local test_func
  local function pass_args() return test_func(test_var) end
  current = self._info
  current.assert_count = 0
  -- list of objects protected from gc
  current.gc_protect = {}
  local gc_protect = current.gc_protect
  -- run all tests in the current file
  local skip = current.user_suite and lib.file_count > 1
  for i,e in pairs(current.tests) do
    local name, func = unpack(e)
    -- Testing scratchpad (used for GC protection).
    test_var = {}
    test_var._name  = name
    test_var._suite = self
    gc_protect[name] = test_var
    test_func = func
    if skip or (lib.only and lib.only ~= name) then
      -- skip user tests
      skip_count = skip_count + 1
    else
      exec_count = exec_count + 1
      current.self.setup(gc_protect[name])

      if lib.verbose then
        printf("%-12s Run %s", '['..current.name..']', name)
      end
      -- Enable sched:pcall when we need yield in testing. For now,
      -- turn this off.
      local ok, err = pcall(pass_args)
      if lib.verbose then
        printf("%s %s", ok and 'OK' or 'FAIL', err or '')
      end
      collectgarbage('collect')
      if not ok then
        fail_count = fail_count + 1
        -- Get line and message for assertPass, assertError
        table.insert(errors, {i, name, err})
      end

      current.self.teardown(gc_protect[name])

      if lib.abort then
        break
      end
    end
  end

  current.exec_count = exec_count
  current.total_count = #current.tests
  current.fail_count = fail_count
  current.skip_count = skip_count
end

function private:reportSuite()
  local ok_message, skip_message = '', ''
  if self._info.fail_count == 0 then
    ok_message = 'OK'
  else
    ok_message = string.format('%i Failure(s)', self._info.fail_count)
  end
  local exec_count = self._info.exec_count
  if self._info.skip_count > 0 then
    if exec_count == 0 then
      ok_message = '-- skip'
    else
      skip_message = string.format(' : skipped %i', self._info.skip_count)
    end
  end
  print(string.format('==== %-28s (%2i test%s%s): %s', self._info.name, exec_count, exec_count > 1 and 's' or ' ', skip_message, ok_message))
  lib.total_exec = lib.total_exec + self._info.exec_count
  lib.total_count = lib.total_count + self._info.total_count
  lib.total_asrt = lib.total_asrt + self._info.assert_count
  if self._info.fail_count > 0 then
    for _, e in ipairs(self._info.errors) do
      local i, name, err = unpack(e)
      lib.total_fail = lib.total_fail + 1
      local hname = string.gsub(name, '([A-Z])', function(x) return ' '..string.lower(x) end)
      print(string.format('  %i. Should %s\n     %s\n', i, hname, string.gsub(err, '\n', '\n     ')))
    end
  end
end


function private.parseArgs()
  for _, val in pairs(arg) do
    if val == '--verbose' then
      lib.verbose = true
    else
      local key,value = string.match(val, '%-%-(.-)=(.*)')
      if key == 'only' then
        lib.only = value
      end
    end
  end
end

function private.testAll()
  lib.total_exec = 0
  lib.total_count = 0
  lib.total_asrt = 0
  lib.total_fail = 0
  for i, suite in ipairs(lib.suites) do
    private.runSuite(suite)
    private.reportSuite(suite)
    if lib.abort then
      break
    end
  end
  private.report()
end

-- Report summary for all tests.
function private.report()
  print('\n')
  if lib.only then
    print('Only testing \''..lib.only..'\'.')
  end

  if lib.total_exec == 0 then
    print(string.format('No tests defined. Test files must end with "_test.lua"'))
  elseif lib.abort then
    print(string.format('Abort after %i / %i tests', lib.total_exec, lib.total_count))
  elseif lib.total_fail == 0 then
    if lib.total_exec == 1 then
      print(string.format('Success! %i test passes (%i assertions).', lib.total_exec, lib.total_asrt))
    else
      print(string.format('Success! %i tests pass (%i assertions).', lib.total_exec, lib.total_asrt))
    end
  elseif lib.total_exec == 1 then
    if lib.total_fail == 1 then
      print(string.format('Fail... %i failure / %i test', lib.total_fail, lib.total_exec))
    else
      print(string.format('Fail... %i failures / %i test', lib.total_fail, lib.total_exec))
    end
  else
    if lib.total_fail == 1 then
      print(string.format('Fail... %i failure / %i tests', lib.total_fail, lib.total_exec))
    else
      print(string.format('Fail... %i failures / %i tests', lib.total_fail, lib.total_exec))
    end
  end
  print('')
end

return lib
