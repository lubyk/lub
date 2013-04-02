#!/usr/bin/env lua
lub = require 'lub'
local tmp = lub.Template(lub.content(lub.path '|lub.rockspec.in'))
lub.writeall('lub-'..lub.VERSION..'-1.rockspec', tmp:run())

