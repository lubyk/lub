--[[------------------------------------------------------

  # lub.Template test

--]]------------------------------------------------------
package.path = './?/init.lua;'..package.path
local lub    = require 'lub'
local lut    = require 'lut'
local should = lut.Test 'lub.Template'

--=============================================== TESTS
function should.autoload()
  assertType('table', lub.Template)
end

function should.transformToLua()
  local code = lub.Template [=[
// [[xx]] force use of = sign
{% for h in self:headers() do %}
#include "{{h.path}}"
{% end %}
]=]
  assertMatch('_out_.%[=%[.#include ".', code.lua)
end

function should.executeTemplate()
  local code = lub.Template [[
{% for _,l in ipairs(list) do %}
#include "{{l}}"
{% end %}
]]
  local res = code:run {list = {'foo/bar.h','baz.h','dingo.h'}}
  assertEqual([[
#include "foo/bar.h"
#include "baz.h"
#include "dingo.h"
]], res)
end

function should.properlyHandleEnlines()
  local code = lub.Template [[
Hello my name is {{foo}}
and I live here.
]]
  local res = code:run {foo = 'FOO'}
  assertEqual([[
Hello my name is FOO
and I live here.
]], res)
end

function should.properyHandleSingleBraces()
  local code = lub.Template [[
static int {{name}}(lua_State *L) {
  {{body}}
}
]]
  local res = code:run {name = 'hello', body = 'return 0;'}
  assertEqual([[
static int hello(lua_State *L) {
  return 0;
}
]], res)
end

function should.indent()
  local code = lub.Template [[
static int {{name}}(lua_State *L) {
  {| body |}
}
]]
  local res = code:run {name = 'hello', body = '// blah blah\nreturn 0;'}
  assertEqual([[
static int hello(lua_State *L) {
  // blah blah
  return 0;
}
]], res)
end

should:test()

