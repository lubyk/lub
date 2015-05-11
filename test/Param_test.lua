--[[------------------------------------------------------

  # lub.Param test

--]]------------------------------------------------------
package.path = './?/init.lua;'..package.path
local lub    = require 'lub'
local lut    = require 'lut'
local should = lut.Test 'lub.Param'
local fpath  = lub.path '|Param_test.lua.yml'

function should.teardown()
  if lub.exist(fpath) then
    lub.rmFile(fpath)
  end
end

local function makePresetFile()
  local p = lub.Param()
  -- some table that we want to proxy
  local my_foo = {}
  -- another table to proxy
  local my_bar = {}

  -- Setup proxies
  local foo = p:proxy(my_foo)
  -- Proxy in 'uniforms' namespace
  local bar = p:proxy(my_bar, 'uniforms')

  foo.speed = 0.4
  bar.length = 0.5
  p:savePreset()
  p:copyToPreset(2)
  foo.speed = 0.9
  p:savePreset()

  -- save some mappings
  local mcontrol = p:addController('mi', {min = 0, max = 127})
  mcontrol:learn()
  foo.speed = 0.7
  mcontrol(32, 12) -- Now key 32 is linked to 'speed' param and mappings are saved.
  return p
end

function should.createParam()
  local p = lub.Param()
  assertMatch('Param_test.%lua%.yml', p.filepath)
end

function should.writeToProxyAndSave()
  local p = lub.Param() -- Use default param file name = lub.path '|Param_test.yml'
  -- some table that we want to proxy
  local my_foo = {}
  -- another table to proxy
  local my_bar = {}

  -- Setup proxies
  local foo = p:proxy(my_foo) -- default = 'main' name
  -- Proxy in 'uniforms' name
  local bar = p:proxy(my_bar, 'uniforms')

  -- Now we can write values inside 'foo' or 'bar' variables and these will be
  -- reflected inside 'p'.

  assertNil(foo.one)
  foo.one = 1
  assertEqual(1, my_foo.one)
  assertEqual(1, foo.one)
  bar.one = 10
  assertEqual(1, my_foo.one)
  assertEqual(1, foo.one)
  assertEqual(10, my_bar.one)
  assertEqual(10, bar.one)
end

function should.saveToFile()
  local p = lub.Param()
  local foo = p:proxy({})
  local bar = p:proxy({}, 'uniforms')

  foo.speed  = 0.3
  bar.length = 0.2

  -- Serialize without saving current preset
  assertEqual([[
---
mappings: {}
preset: p1
presets: {}
]], p:dump())

  -- Current preset position
  assertEqual('p1', p.preset)

  -- Save preset (= write to p memory and dump to file)
  assertFalse(lub.exist(fpath))
  p:savePreset()
  assertTrue(lub.exist(fpath))

  -- Save 
  assertEqual([[
---
mappings: {}
preset: p1
presets:
  p1:
    main:
      speed: 0.3
    uniforms:
      length: 0.2
]], lub.content(fpath))
end

function should.saveAllPresetsToFile()
  local p = lub.Param()
  local foo = p:proxy({})
  local bar = p:proxy({}, 'uniforms')

  foo.speed  = 0.3
  bar.length = 0.2

  p:savePreset()
  p:selectPreset(2)

  foo.speed = 0.4
  foo.hop   = 0.8
  p:savePreset()

  -- Save 
  assertEqual([[
---
mappings: {}
preset: p2
presets:
  p1:
    main:
      speed: 0.3
    uniforms:
      length: 0.2
  p2:
    main:
      hop: 0.8
      speed: 0.4
    uniforms:
      length: 0.2
]], lub.content(fpath))
end

function should.loadFromFile()
  makePresetFile()
  local p = lub.Param() -- Loads content from preset file
  assertEqual('p2', p.preset)
  local my_foo = {}
  local foo = p:proxy(my_foo) -- detects existing 'main' values and sets them
  assertEqual(0.9, my_foo.speed)
  p:selectPreset(1)
  assertEqual(0.4, my_foo.speed)
end

function should.mapController()
  local p = lub.Param()
  local my_foo = {}
  local foo = p:proxy(my_foo, 'bok')
  local mcontrol = p:addController('mi', {min = 0, max = 127})

  foo.accel = 0.3
  foo.speed = 0.4
  mcontrol:learn()
  foo.accel = 0.3
  foo.speed = 0.45 -- This one is changed
  mcontrol(32, 12) -- Now key 32 is linked to 'speed' param and mappings are saved.
  
  -- Note that we did not save preset
  assertEqual([[
---
mappings:
  bok:
    speed:
      mi: 32
preset: p1
presets: {}
]], p:dump())
  assertValueEqual({
    bok = {
      speed = {
        mi = 32,
      },
    },
  }, p.mappings)

  assertValueEqual({
    mi = {
      [32] = {
        proxy_name = 'bok',
        key = 'speed',
      },
    },
  }, p.rmappings)
end

function should.feedbackToController()
  makePresetFile()
  local p = lub.Param()
  local mcontrol = p:addController('mi', {min = 0, max = 127})
  local my_foo = {}
  local foo = p:proxy(my_foo)

  local t
  function mcontrol:changed(key, value)
    t = {key = key, value = value}
  end

  foo.speed = 0.8
  assertValueEqual({
    key   = 32,
    value = 0.8 * 127,
  }, t)

  mcontrol(32, 60)
  assertEqual(60/127, my_foo.speed)
end

function should.notFeedbackToChangingController()
  makePresetFile()
  local p = lub.Param()
  local mcontrol = p:addController('mi', {min = 0, max = 127})
  local my_foo = {}
  local foo = p:proxy(my_foo)

  local t
  function mcontrol:changed(key, value)
    t = {key = key, value = value}
  end

  mcontrol(32, 60)
  assertNil(t)
  assertEqual(60/127, my_foo.speed)
end

should:test()
