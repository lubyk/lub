local lub = require 'lub'
lub.Doc.make {
  sources = {
    'lub',
  },
  head   = '<meta name="google-site-verification" content="p1ZrKNheIo5xMhrMOo9MxKaY2hL9LlyuPYyRnEl2QuM" />',
  target = 'doc',
  format = 'html',
  header = [[ <a href='http://lubyk.org'><img alt='lubyk logo' src='img/lubyk.png'/></a> <h1><a href='http://doc.lubyk.org'>Lubyk documentation</a></h1></a> ]],
  index  = [=[
--[[--
  # Lubyk documentation

  ## List of available modules in lubyk
--]]--
]=]
}
