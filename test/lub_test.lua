--[[------------------------------------------------------

  # lub test

--]]------------------------------------------------------
local lub    = require 'lub'
local lut    = require 'lut'
local should = lut.Test 'lub'

function should.readAll()
  local p = lub.path '|fixtures/io.txt'
  assertEqual('Hello Lubyk!\n', lub.content(p))
end

function should.absolutizePath()
  assertEqual(lfs.currentdir() .. '/foo/bar', lub.absolutizePath('foo/bar'))
  assertEqual('/foo/bar', lub.absolutizePath('/foo/bar'))
  -- assertEqual('/One/two/foo/bar', lub.absolutizePath('foo/bar', '/One/two'))
  -- assertEqual('/foo/bar', lub.absolutizePath('/foo/bar', '/One/two'))
end

function should.merge()
  local base = {a = { b = {x=1}}, c = {d = 4}}
  lub.merge(base, {
    a = 'hello',
    d = 'boom',
  })
  assertValueEqual({a = 'hello', c = {d = 4}, d = 'boom'}, base)
end

function should.deepMerge()
  local base = {a = { b = {x=1}, c = {d = 4}}}
  local a2   = { b = {x=3}, c = {e = 5}, g = 2}
  assertFalse(lub.deepMerge(base, 'a', {c = {d = 4}}))
  assertTrue(lub.deepMerge(base, 'a', a2))
  assertValueEqual({a = { b = {x=3}, c = {d = 4, e = 5}, g = 2}}, base)
end

function should.makePath()
  local path = lub.path('|fixtures/tmp/foo/bar/baz')
  lub.rmTree(lub.path('|fixtures/tmp'), true)
  assertPass(function()
    lub.makePath(path)
  end)
  assertEqual('directory', lub.fileType(lub.path('|fixtures/tmp/foo')))
  assertEqual('directory', lub.fileType(lub.path('|fixtures/tmp/foo/bar')))
  assertEqual('directory', lub.fileType(lub.path('|fixtures/tmp/foo/bar/baz')))
  lub.rmTree(lub.path('|fixtures/tmp'), true)
end

function should.notRmTreeRecursive()
  local path = lub.path('|fixtures/tmp/fo"o/bar/baz')
  assertPass(function()
    lub.makePath(path)
  end)
  assertEqual('directory', lub.fileType(lub.path('|fixtures/tmp/fo"o')))
  assertEqual('directory', lub.fileType(lub.path('|fixtures/tmp/fo"o/bar')))
  assertEqual('directory', lub.fileType(lub.path('|fixtures/tmp/fo"o/bar/baz')))
  assertFalse(lub.rmTree(lub.path('|fixtures/tmp/fo"o')))
  assertTrue(lub.exist(lub.path('|fixtures/tmp/fo"o')))
  lub.rmTree(lub.path('|fixtures/tmp'), true)
end

function should.rmTree()
  local path = lub.path('|fixtures/tmp/fo"o/bar/baz')
  assertPass(function()
    lub.makePath(path)
  end)
  assertEqual('directory', lub.fileType(lub.path('|fixtures/tmp/fo"o')))
  assertEqual('directory', lub.fileType(lub.path('|fixtures/tmp/fo"o/bar')))
  assertEqual('directory', lub.fileType(lub.path('|fixtures/tmp/fo"o/bar/baz')))
  lub.rmTree(lub.path('|fixtures/tmp/fo"o'), true)
  assertFalse(lub.exist(lub.path('|fixtures/tmp/fo"o')))
end

function should.move()
  local path  = lub.path('|fixtures/tmp.txt')
  lub.writeall(path, 'Hello')
  local path2 = lub.path('|fixtures/tmp2.txt')
  assertTrue(lub.exist(path))
  assertFalse(lub.exist(path2))

  lub.move(path, path2)
  assertTrue(lub.exist(path2))
  assertFalse(lub.exist(path))

  -- cleanup
  lub.rmFile(path)
  lub.rmFile(path2)
end

function should.copy()
  local path  = lub.path('|fixtures/tmp.txt')
  lub.writeall(path, 'Hello')
  local path2 = lub.path('|fixtures/tmp2.txt')
  assertTrue(lub.exist(path))
  assertFalse(lub.exist(path2))

  lub.copy(path, path2)
  assertTrue(lub.exist(path2))
  assertTrue(lub.exist(path))

  -- cleanup
  lub.rmFile(path)
  lub.rmFile(path2)
end

function should.writeall()
  local foo = lub.path('|fixtures/tmp/foo')
  lub.rmTree(foo, true)
  local tmp_path = foo .. '/bar/lub_test_writeall.txt'
  os.remove(tmp_path)
  lub.writeall(tmp_path, 'This is the message')
  assertEqual('This is the message', lub.content(tmp_path))
  lub.rmTree(foo, true)
end

function should.split()
  local list = lub.split('cat,dog,mouse', ',')
  assertEqual('cat'  , list[1])
  assertEqual('dog'  , list[2])
  assertEqual('mouse', list[3])
  assertEqual(3, #list)
end

function should.splitChars()
  local list = lub.split('cat')
  assertEqual('c', list[1])
  assertEqual('a', list[2])
  assertEqual('t', list[3])
  assertEqual(3, #list)
end

function should.strip()
  assertEqual('hop hop', lub.strip(' \t\nhop hop '))
  assertEqual('hop hop', lub.strip('hop hop '))
  assertEqual('hop hop', lub.strip('  hop hop'))
  assertEqual('hop hop', lub.strip('hop hop'))
end

function should.absToRel()
  assertEqual('play/in/trigger', lub.absToRel('/foo/play/in/trigger', '/foo'))
  assertEqual('/foo/bar', lub.absToRel('/foo/bar', '/foo/bar'))
  assertEqual('/foo/baz/boom', lub.absToRel('/foo/baz/boom', '/foo/bar'))
end

function should.returnEmptyOnSpitStartingWithSep()
  local list = lub.split('/my/home', '/')
  assertEqual(''    , list[1])
  assertEqual('my'  , list[2])
  assertEqual('home', list[3])
  assertEqual(3, #list)
end

function should.provideDir()
  assertMatch('test$', lub.path '|')
end

function should.provideFile()
  assertMatch('test/lub_test.lua$', lub.path '&')
end

function should.testFileExistence()
  assertEqual('file', lub.fileType(lub.path('|fixtures/io.txt')))
  assertEqual(nil, lub.fileType(lub.path('|docbad')))
  assertEqual('directory', lub.fileType(lub.path '|'))
  assertEqual(nil, lub.fileType(nil))
end

function should.shellQuote()
  assertEqual('"foo"', lub.shellQuote('foo'))
  -- foo 25"  --> "foo 25\""
  assertEqual('"foo 25\\\""', lub.shellQuote('foo 25"'))
  -- foo 25\" --> "foo 25\\\""
  assertEqual('"foo 25\\\\\\\""', lub.shellQuote('foo 25\\"'))
end

function should.log()
  local o_print = print
  local out
  function print(...)
    out = {...}
  end

  assertPass(function()
    lub.log('Hello')
  end, function()
    print = o_print
  end)

  assertMatch('test/lub_test.lua:[0-9]+', out[1])
  assertMatch('Hello', out[2])
end

function should.log()
  local o_print = print
  local out
  function print(...)
    out = {...}
  end

  assertPass(function()
    lub.log('Hello')
  end, function()
    print = o_print
  end)

  assertMatch('test/lub_test.lua:179', out[1])
  assertMatch('Hello', out[2])
end

function should.declareClass()
  local c = lub.class 'foo.Bar'
  assertEqual('foo.Bar', c.type)
  local out
  function c.new(...)
    out = {...}
  end
  c('hey')
  assertValueEqual({'hey'}, out)
end

function should.useDeprecation()
  local o_print = print
  local out, bar
  function print(...)
    out = {...}
  end

  function lub.foo(...)
    return lub.deprecation('lub', 'foo', 'bar', ...)
  end

  function lub.bar(...)
    bar = {...}
  end

  assertPass(function()
    lub.foo('Hello')
  end, function()
    print = o_print
  end)
  lub.foo = nil
  lub.bar = nil

  assertMatch("[DEPRECATION]", out[1])
  assertMatch("'lub.foo' is deprecated. Please use 'lub.bar' instead.", out[1])
  assertValueEqual({'Hello'}, bar)
end

function should.traceRequire()
  -- just to make coverage testing happy.
  assertPass(function()
    lub.traceRequire(false)
  end)
end

function should.insertSorted()
  local list = {}
  lub.insertSorted(list, 'c')
  lub.insertSorted(list, 'a')
  lub.insertSorted(list, 'b')
  assertValueEqual({'a','b','c'}, list)
end

function should.returnParentDirectory()
  local parent, child = lub.dir('/a/b/c')
  assertEqual('/a/b', parent)
  assertEqual('c', child)
end

-- Disable coverage testing for deprecated pathDir.
should.ignore.pathDir = true


should:test()
