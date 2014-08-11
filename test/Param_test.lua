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
  local foo = p:proxy(my_foo) -- default = 'main' namespace
  -- Proxy in 'uniforms' namespace
  local bar = p:proxy(my_bar, {namespace = 'uniforms'})

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
preset: 1
presets: {}
]], p:dump())

  -- Current preset position
  assertEqual(1, p.preset)

  -- Save preset (= write to p memory and dump to file)
  p:savePreset()

  -- Copy to preset 2
  p:copyToPreset(2)

  foo.one = 2

  -- Save preset (writes to file system)
  assertFalse(lub.exist(fpath))
  p:savePreset()
  assertTrue(lub.exist(fpath))

  -- Load preset 1
  p:selectPreset(1)

  -- Save 
  assertEqual([[
presets:
  1:
    main:
      one: 1.0
    uniforms
      one: 10.0
  2:
    main
      one: 2.0
    uniforms
      one: 10.0
  ]], p:dump())

end

function should.mapMidi()
  local p = lub.Param() -- Use default param file name = lub.path '|Param_test.yml'
  -- some table that we want to proxy
  local my_foo = {}
  -- Setup proxies
  local foo = p:proxy(my_foo, {namespace = 'bok'}) -- default = {namespace = 'main', min = 0, max = 1}

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
