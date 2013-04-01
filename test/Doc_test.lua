--[[------------------------------------------------------

  lub.Doc test

--]]------------------------------------------------------
local lub    = require 'lub'
local should = lub.Test 'lub.Doc'

local tmp   = lub.path '|fixtures/tmp'
local tpath = lub.path '|fixtures/doc/foo/DocTest.lua'

function should.teardown()
--  lub.rmTree(tmp)
end

function should.autoLoad()
  assertTrue(lub.Doc)
end

function should.extractTitle()
  local doc = lub.Doc(tpath)
  assertEqual('DocTest', doc.name)
end

function should.extractSummary()
  local doc = lub.Doc(tpath)
  -- first paragraph in first group in first section.
  local summary = doc.sections[1][1][1]
  assertValueEqual({
    text  = 
    'This file is a simple test to describe the different documenting options available with lub.Doc. This first paragraph is output as "summary".',
    class = 'summary',
  }, summary)
end

function should.extractDescription()
  local doc = lub.Doc(tpath)
  -- first group of paragraphs
  local description = doc.sections[1][1]
  assertValueEqual({
    { class = 'summary',
      text = 'This file is a simple test to describe the different documenting options available with lub.Doc. This first paragraph is output as "summary".',
    },
    { text = 'The following paragraphs up to the end of the preamble comment block define the "description".'},

    { text = 'A second paragraph in the "description" with an auto link: doc.DocTest. And here is a custom link "lubyk":http://lubyk.org. And some formatting: *strong* _emphasis_.'},

    { text = 'Some lists:'},
    { text = 'baz', list = {
        { text = 'foo' },
        { text = 'bar' },
      },
    },
    { text = 'Finally, some inline math [math]\\infty[/math] with more text. And now some more math in its own paragraph:'},
    {
      math = 'inline',
      text = '\\frac{\\partial}{\\partial\\theta_j}J(\\theta) = \\frac{1}{m}\\sum_{i=1}^m(\\theta^{T}x^{(i)}-y^{(i)})x_j^{(i)}',
     },
    { text = 'And some more text after math. With an image (the path is relative to the output directory).'},
    { text = '![Dummy example image](img/box.jpg)'},
  }, description)
end

function should.convertToHtml()
  local doc = lub.Doc(tpath)
  assertMatch('<title>Documentation Tester</title>', doc:toHtml())
end

function should.extractParams()
  local doc = lub.Doc(tpath)
  local list = {}
  for _, def in ipairs(doc.params.zoom) do
    table.insert(list, def.tparam..' = '..def.params..' ('..def[1].text..')')
  end
  assertValueEqual({
    "cost1 = {default = 0.5, min = 0, max = 1, unit = 'CHF'} (This is a first attribute that is used for this or that.)",
    "cost2 = {default = 5,   min = 0, max = 10, unit = '$'} (A second attribute.)",
    "foo = 4 (An attribute in the foobar group.)",
    "bar = 'some text here' (Another attribute in the foobar group.)",
  }, list)
  assertEqual(doc.params.zoom[1], doc.params.zoom.cost1)
end

function should.makeDoc()
  lub.Doc.make {
    sources = {
      lub.path '|fixtures/doc',
    },
    target = tmp,
    format = 'html',
  }
end

function should.parseCode()
  local doc = lub.Doc(nil, {
    name = 'foo.Bam',
    code = [=[
--[[--
  # Title

  Summary
--]]--

p { -- doc

  -- Foo bar baz
  f = 5,
}

    ]=],
  })
  assertValueEqual({
    p = {
      f = {
        params = '5',
        tparam = 'f',
        {text = 'Foo bar baz'},
      },
      {
        params = '5',
        tparam = 'f',
        {text = 'Foo bar baz'},
      },
    },
  }, doc.params)
end

--=============================================== HTML generation
function should.insertHead()
  local doc  = lub.Doc(tpath, {
    head = '<foo>bar baz</foo>',
  })
  local html = doc:toHtml()
  assertMatch('<foo>bar baz</foo>', html)
end

should:test()

