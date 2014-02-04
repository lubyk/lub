package = "lub"
version = "1.0.4-1"
source = {
  url = 'https://github.com/lubyk/lub/archive/REL-1.0.4.tar.gz',
  dir = 'lub-REL-1.0.4',
}
description = {
  summary = "Lubyk base module.",
  detailed = [[
    lub: helper code, class declaration.

    lub.Autoload: autoloading classes in modules.

    lub.Dir: a simple directory traversal class.

    lub.Template: a simple templating class that uses  like syntax.
  ]],
  homepage = "http://doc.lubyk.org/lub.html",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1, < 5.3",
  "luafilesystem >= 1.6.0",
}
build = {
  type = 'builtin',
  modules = {
    -- Plain Lua files
    ['lub'            ] = 'lub/init.lua',
    ['lub.Autoload'   ] = 'lub/Autoload.lua',
    ['lub.Dir'        ] = 'lub/Dir.lua',
    ['lub.Finalizer'  ] = 'lub/Finalizer.lua',
    ['lub.Scheduler'  ] = 'lub/Scheduler.lua',
    ['lub.Template'   ] = 'lub/Template.lua',
    ['lub.Thread'     ] = 'lub/Thread.lua',
    -- C++ modules
    ['lub.core'       ] = {
      sources = {
        'src/lub.cpp',
        'src/poller.cpp',
        'src/bind/dub/dub.cpp',
        'src/bind/lub_core.cpp',
        'src/bind/lub_Finalizer.cpp',
        'src/bind/lub_Poller.cpp',
      },
      incdirs = {'include', 'src/bind', 'src/vendor'},
      libraries = {'stdc++'},
    },
  },
  platforms = {
    linux = {
      modules = {
        ['lub.core'] = {
          librairies = { 'stdc++', 'rt' },
        },
      },
    },
  },
}

