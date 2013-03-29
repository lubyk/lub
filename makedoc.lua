package.path = package.path .. ';./?/init.lua'
require 'lub'
lub.Doc.make {
  sources = {
    'lub',
    -- {'modules/four/doc/examples', prepend='tutorial/four'},
  },
  copy   = {
  --  'doc',
  },
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

-- TODO: use commit and stamp information arg[1], arg[2] in footer.
