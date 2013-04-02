package = "Lub"
version = "1.0-1"
source = {
   url = "http://lubyk.org/archive/REL-1.0.tar.gz",
   dir = 'lub-REL-1.0',
}
description = {
   summary = "Lubyk base module (doc generator, template, testing)",
   detailed = [[
      lub.Doc: a powerful documentation generator for Lua code with support for
      litterate programming, cross-reference linking, images, latex math, etc.
      
      lub.Dir: a simple directory traversal class.

      lub.Template: a simple templating class.
   ]],
   --   lub.Test: A simple yet powerful unit testing framework.
   homepage = "http://lubyk.org",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1",
   "luafilesystem >= 1.5.0",
}
build = {
  type = 'builtin',
  modules = {
    ['lub.Autoload'] = 'lub/Autoload.lua',
    ['lub.Dir'] = 'lub/Dir.lua',
    ['lub.Doc'] = 'lub/Doc.lua',
    ['lub'         ] = 'lub/init.lua',
    ['lub.Template'] = 'lub/Template.lua',
    ['lub.Test'] = 'lub/Test.lua',
  },
  install = {
    lua = {
      ['lub.doc.template'] = 'lub/doc/template.html',
      ['lub.doc.css.bootstrap_min_css'] = 'lub/doc/css/bootstrap.min.css',
      ['lub.doc.css.docs_css'] = 'lub/doc/css/docs.css',
      ['lub.doc.img.glyphicons-halflings-white_png'] = 'lub/doc/img/glyphicons-halflings-white.png',
      ['lub.doc.img.glyphicons-halflings_png'] = 'lub/doc/img/glyphicons-halflings.png',
      ['lub.doc.js.bootstrap_min_js'] = 'lub/doc/js/bootstrap.min.js',
    },
  }
}
