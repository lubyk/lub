--
-- Update build files for this project
--
package.path = './?/init.lua;'..package.path
local lut = require 'lut'
local lib = require 'lub'

lut.Builder(lib):make()
