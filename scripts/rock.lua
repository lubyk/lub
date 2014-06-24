#!/usr/bin/env lua
local lub = require 'lub'

local lib = lub

local def = {
  description = {
    summary = "Lubyk base module.",
    detailed = [[
      lub: helper code, class declaration.

      lub.Autoload: autoloading classes in modules.

      lub.Dir: a simple directory traversal class.

      lub.Template: a simple templating class that uses {{moustache}} like syntax.
    ]],
    homepage = "http://doc.lubyk.org/"..lib.type..".html",
    author   = "Gaspard Bucher",
    license  = "MIT",
  },

  pure_lua = true,
  -- includes  = {'include', 'src/bind'},
  -- libraries = {'stdc++'},
  -- platlibs = {
  --   linux   = {'stdc++', 'rt'},
  -- },
}

-- Platform specific sources or link libraries
-- def.platspec = def.platspec or lub.keys(def.platlibs)

--- End configuration

local tmp = lub.Template(lub.content(lub.path '|rockspec.in'))
lub.writeall(lib.type..'-'..lib.VERSION..'-1.rockspec', tmp:run {lib = lib, def = def, lub = lub})

tmp = lub.Template(lub.content(lub.path '|dist.info.in'))
lub.writeall('dist.info', tmp:run {lib = lib, def = def, lub = lub})

tmp = lub.Template(lub.content(lub.path '|CMakeLists.txt.in'))
lub.writeall('CMakeLists.txt', tmp:run {lib = lib, def = def, lub = lub})


