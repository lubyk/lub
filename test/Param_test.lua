--[[------------------------------------------------------

  # lub.Param test

--]]------------------------------------------------------
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
  local bar = p:proxy(my_bar, {name = 'uniforms'})

  foo.speed = 0.4
  bar.length = 0.5
  p:savePreset()
  p:copyToPreset(2)
  foo.speed = 0.9
  p:savePreset()
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
  local bar = p:proxy(my_bar, {name = 'uniforms'})

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

  -- Copy to preset p2
  p:copyToPreset(2)

  foo.one = 2
  assertEqual(2, my_foo.one)

  -- Save preset (writes to file system)
  p:savePreset()

  -- Save 
  assertEqual([[
---
mappings: {}
preset: p2
presets:
  p1:
    main:
      one: 1
    uniforms:
      one: 10
  p2:
    main:
      one: 2
    uniforms:
      one: 10
]], p:dump())

  -- Load preset 1
  p:selectPreset(1)

  assertEqual(1, my_foo.one)

end

function should.loadFromFile()
  makePresetFile()
  local p = lub.Param() -- Loads content from preset file
  assertEqual('p2', p.preset)
  local my_foo = {}
  local foo = p:proxy(my_foo) -- detects existing 'main' values and sets them
  assertEqual(0.9, my_foo.speed)
end

function should.mapMidi()
  local p = lub.Param() -- Use default param file name = lub.path '|Param_test.yml'
  -- some table that we want to proxy
  local my_foo = {}
  -- Setup proxies
  local foo = p:proxy(my_foo, {name = 'bok'}) -- default = {name = 'main', min = 0, max = 1}

  local mcontrol = p:addController('mi', {min = 0, max = 127})

  foo.hello = 0.5
  mcontrol:learn()
  mcontrol(32, 12) -- Now key 32 is linked to 'hello' param and mappings are saved.
  
  assertEqual([[
mappings:
  mi:
    main
      hello: 32
  ]], p:dump())


  local p2 = lub.Param() -- Use default param file name = lub.path '|Param_test.yml'
  local my_foo2 = {}
  local foo2 = lub:proxy(my_foo2)
  local mcontrol2 = p:addController('mi', {min = 0, max = 127})
  local t
  function mcontrol2:changed(key, value)
    t = {key = key, value = value}
  end
  p2.hello = 0.9
  assertValueEqual({
    key   = 32,
    value = 0.9 * 127,
  }, t)

  mcontrol2(32, 60)
  assertEqual(60/127, my_foo2.hello)
end

should:test()
