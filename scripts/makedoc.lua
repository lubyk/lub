local lut = require 'lut'
lut.Doc.make {
  sources = {
    'lub',
  },
  target = 'doc',
  format = 'html',
  header = [[<h1><a href='http://doc.lubyk.org'>Lubyk documentation</a></h1></a> ]],
  index  = [=[
--[[--
  # Lubyk documentation

  ## List of available modules
--]]--
]=]
}
