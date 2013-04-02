#!/usr/bin/env lua
lub = require 'lub'
local tmp = lub.Template(lub.content(lub.path '|lub.rockspec.in'))
lub.writeall('lub-'..lub.VERSION..'-1.rockspec', tmp:run())

tmp = lub.Template(lub.content(lub.path '|CMakeLists.txt.in'))
lub.writeall('CMakeLists.txt', tmp:run())

tmp = lub.Template(lub.content(lub.path '|dist.info.in'))
lub.writeall('dist.info', tmp:run())
