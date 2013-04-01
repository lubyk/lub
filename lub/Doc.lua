--[[------------------------------------------------------

  # Documentation extractor

  lub.Doc parses lua comments and extracts the documentation from these comments.

  It parses indifferently multiline comments like this:
  
    --[%%[ 
    Some text in comments.

    Some more text.
    --]%%]

  and single line comments like this:
  
    -- Some text in comments.
    -- 
    -- Some more text.

  # Parsing modes

  By using the special comment `-- doc:[option]`, you can change how the parsing
  is done.

  ## Literate programming

  The parser can generate full script documentation with all lua code when set
  to "lit" (for literate). Turn this option off by setting "nolit".

    -- doc:lit
    -- This part is considered literate programming and all comments and lua
    -- code will be shown in the documentation.
    local x
    
    doSomething(x)

    -- doc:nolit
    -- End of literate part: only the library "lib" will be documented.

  ## Loose documentation

  By setting `-- doc:loose`, the parser will generate a single TODO about
  missing documentation and will not generate any more TODO entries for
  each undocummented function or parameter.
  
  Even if the function names look obvious while writing the code and
  documentation seems superfluous, users will usually appreciate some real
  phrases describing what the function does. Using "loose" is not a good
  idea but can make the documentation more readable if most of the functions
  are not documented.

  # Extraction

  ## Function extraction

  All functions and methods defined against `lib` are extracted even if they
  are not yet documented. Example:

    function lib:foo(a, b)
      -- Will generate a TODO with "MISSING DOCUMENTATION"
    end

    -- Documented function.
    function lib:bar()
    end

    -- Documented class function.
    function lib.boom()
    end
  
  If a function definition does not follow this convention, it can be
  documented with a commented version of the function definition:

    -- Special function declaration.
    -- function lib:bing(a, b, c)
    lib.bing = lub.Doc.bang

    -- Out of file function definition (in C++ for example).
    -- function lib:connect(server)

  To ignore functions, use `-- nodoc` as documentation:

    -- nodoc
    function lib:badOldLegacyFunction(x, y)
    end

  ## Table parameters

  All parameters defined against `lib` are documented unless `-- nodoc` is used.

    lib.foo = 4
    lib.bar = 5

    -- nodoc
    lib.old_foo = 4

  Since Lua is also used as a description language, it is often useful to
  document table keys. This is done by using `-- doc`. It is a good idea to
  create a new for each table in order to document the table itself.

  The parsed parameters for table 'key' is stored in `doc.params[key]` in
  parsing order. In the following example, this is `doc.params.ATTRIBS`.

    -- # Attributes (example)
    -- This is an example of attributes documentation.
    
    local ATTRIBS = { -- doc
      -- Documentation on first key.
      first_name = '',

      -- Documentation on second key.
      last_name = '',

      -- ## Sub-title
      -- Some text for this group of attributes.

      phone = {default = '', format = '000 000 00 00'},
    }

  Such a list will create the following documentation:

--]]

-- # Attributes (example)
-- This is an example of attributes documentation.

local ATTRIBS = { -- doc
  -- Documentation on first key.
  first_name = '',

  -- Documentation on second key.
  last_name = '',

  -- ## Sub-title
  -- Some text for this group of attributes.

  phone = {default = '', format = '000 000 00 00'},
}


--[[

  # Preamble

  You must start your file with a preample containing a title for the class
  or module and some description.

    --[%%[---------------------------------------
      
      # Full title for the file/class
    
      This first paragraph is the summary.
    
      Some more description.
    
    --]%%]---------------------------------------

  # Math

  The `[math]` tag can be used to generate mathematics from latex code. When
  outputing *html*, the page uses [MathJax](http://www.mathjax.org) when outputing html.
  Here is an example of mathematics inline and as standalone paragraph:

    -- Some documentation with inline
    -- [math]\gamma[/math] math. And now a
    -- standalone math paragraph:
    --
    -- [math]\frac{\partial}{\partial\theta_j}J(\theta) = \frac{1}{m}\sum_{i=1}^m(\theta^{T}x^{(i)}-y^{(i)})x_j^{(i)}[/math]

  The result for the code above is:

  Some documentation with inline [math]\gamma[/math] math. And now a
  standalone math paragraph:
  
  [math]\frac{\partial}{\partial\theta_j}J(\theta) = \frac{1}{m}\sum_{i=1}^m(\theta^{T}x^{(i)}-y^{(i)})x_j^{(i)}[/math]

  If you *hover* with the mouse over the formula, it zooms.
  
  # Lua code
  
  You can insert code snippets by indenting the code with two spaces. Here is
  an example of some normal text and some Lua and C++ code.

    --[%%[
    Some Lua code:

      local foo = {}
      -- print something
      print 'Hello'
    
    And a cpp example:

      #cpp
      float x = 1.0;
      printf("Result = %.2f\n", x);
    --]%%]

  This results in:

  Some Lua code:

    local foo = {}
    -- print something
    print 'Hello'
  
  And a cpp example:

    #cpp
    float x = 1.0;
    printf("Result = %.2f\n", x);

  As you can see, you have to declare other languages with `#name` if the code
  is not Lua.

  # Styles

  You can enhance your comments with links, bold, italics and images.

  Some links are automatically created when the parser sees `module.Class` like
  this: lub.Doc. A custom link is made with `[link title](http://example.com)`.

  Bold is done by using stars: `some text with *bold* emphasis`. Italics are
  inserted with underscores: `some text _with italic_ emphasis`.

  You can add images with `![alt text](/path/to/image.jpg)`.

  Inline code is inserted with backticks:
  
    -- This is `inline code`.

  # Lists

  There are two kinds of lists available. The first one is simply a bullet list:

    #txt
    * First element
    * Second element with more text
      that wraps around
    * Third

  Which renders as:

  * First element
  * Second element with more text
    that wraps around
  * Third

  The second style is for definitions:

    #txt
    + some key:       is used to do something.
    + other long key: is used with a very long definition that
                      wraps around and even more text that goes
                      beyond.
    + `last key`:     is a code key.

  Renders as:

  + some key:       is used to do something.
  + other long key: is used with a very long definition that
                    wraps around and even more text that goes
                    beyond.
  + `last key`:     is a code key.

  # Special paragraphs

  You can create special paragraphs by starting them with one of the special
  keywords in upercase:  `TODO, FIXME, WARN, NOTE`.

    TODO This is a todo definition

    FIXME This is a fixme

    NOTE This paragraph is a note.

    WARN This is a warning.


  These end up like this (todo and fixme are repeated at the end of
  the file, but not for this example).

  TODO - This is a todo definition

  FIXME - This is a fixme

  NOTE This paragraph is a note.

  WARN This is a warning.

--]]------------------------------------------------------
local lib     = class 'lub.Doc'
local private = {}
local parser  = {}
local CODE = '§§'
local ALLOWED_OPTIONS = {lit = true, loose = true}
local DEFAULT_HEADER = [[ ]]
local DEFAULT_FOOTER = [[ made with <a href='http://doc.lubyk.org/lub.Doc.html'>lub.Doc</a> ]]
local gsub  = string.gsub
local match = string.match

-- Dependencies
local lub = require 'lub'


-- # Class functions

-- Parse the content of a file given by `path` and return an lub.Doc object 
-- containing the documentation of the class.
--
-- Usage example:
--
--   require 'lubyk'
--   local doc = lub.Doc('path/to/File.lua', {target = 'doc'})
--   lub.writeall('doc/File.html', doc:toHtml())
--
-- When documenting multiple files it is better to use #make.
--
-- Possible keys in `def` (all are optional if `path` is given):
--
-- + code       : If `path` is nil, parse the given code.
-- + name       : Used when no `path` is provided.
-- + navigation : Navigation menu on the right.
-- + children   : List of classes (in main content part).
-- + head       : HTML content to insert in `<head>` tag.
-- + css        : Path to a CSS file to use instead of `css/docs.css`.
-- + header     : HTML code to display in header.
-- + footer     : HTML code to display in footer.
-- + target     : Target directory (only used when using PNG image generation
--                for math code.
function lib.new(path, def)
  def = def or {}
  local self = {
    path   = path,
    name   = def.name,
    target = def.target,
    header = def.header or DEFAULT_HEADER,
    footer = def.footer or DEFAULT_FOOTER,
    navigation = def.navigation or {},
    children   = def.children or {},
    sections = {},
    -- List of documented parameters.
    params   = {},
    opts     = def.opts or def,
  }
  
  if def.navigation then
    self.module   = self.navigation.__fullname
    self.name     = self.children.__name
    if def.toplevel then
      self.toplevel = true
      self.fullname = self.name
      self.navigation = self.children
    else
      if self.navigation.__fullname then
        self.fullname = self.navigation.__fullname .. '.' .. self.name
      else
        self.fullname = self.name
      end
    end
  elseif path then
    self.module, self.name, self.fullname = private.getName(path)
  else
    assert(self.name)
  end

  setmetatable(self, lib)
  if path then
    private.parseFile(self, path)
  elseif def.code then
    private.parseCode(self, def.code)
  else
    -- make dummy doc
    private.newSection(self, 0, self.name)
    table.insert(self.group, {text = '', class = 'summary'})
  end

  if self.children and #self.children > 0 then
    local children = self.children
    local section = self.section
    for _, name in ipairs(children) do
      local child = children[name]

      local group = {
        -- Use 'class' key for children elements.
        class = child.__fullname,
        name  = child.__name,
        child.__summary,
        child.__img,
      }

      if child.__fixme then
        for _, p in ipairs(child.__fixme[1]) do
          table.insert(group, p)
        end
      end

      if child.__todo then
        for _, p in ipairs(child.__todo[1]) do
          table.insert(group, p)
        end
      end

      table.insert(section, group)
    end
  end

  if self.todo then
    table.insert(self.sections, self.todo)
  end

  if self.fixme then
    table.insert(self.sections, self.fixme)
  end

  return self
end


-- Generate the documentation for multiple files.
--
-- The `sources` parameter lists paths to Lua files or directories to parse and
-- document.
--
-- + target:  parameter is the path to the directory where all the
--            output files will be written.
-- + format:  is the type of output desired. Only 'html' format is supported
--            for now.
-- + sources: lists path to glob for lua files. A source can also be a table
--            with a `prepend` key used to change the location of the files
--            in the documentation.
-- + copy:    lists the path to glob for static content to copy in `target`.
-- + header:  html code that will be inserted in every html page as header.
-- + footer:  html code that will be inserted in every html page as footer.
--
-- Usage:
--
--   require 'lubyk'
--   lub.Doc.make {
--     sources = {
--       'lib/doc/DocTest.lua',
--       'lib/doc/Other.lua',
--       {'doc', prepend = 'tutorial/foo'},
--     },
--     target = 'doc',
--     format = 'html',
--     header = [[
--       <a href='http://lubyk.org'>
--         <img alt='lubyk logo' src='img/logo.png'/>
--         <h1>Lubyk documentation</h1>
--       </a>
--     ]],
--     footer = [[ made with <a href='lub.Doc.html'>lub.Doc</a> ]],
--   }
function lib.make(def)
  local format = def.format or 'html'
  local output = assert(private.output[format])
  local mod_output = assert(private.mod_output[format])
  -- Prepare output
  lub.makePath(def.target)

  -- Copy base assets
  private.copyAssets[def.format](def.target)
  if def.copy then
    private.copyFiles(def.copy, def.target)
  end


  -- Parse all files and create a tree from the directories and
  -- files to parse.
  -- { name = 'xxxx', sub, { name = 'xxx', subsub }}.
  local tree = {is_root = true}
  private.parseSources(tree, def.sources)

  private.makeDoc(tree, def)
end

-- # Methods

-- Render the documentation as html. If a `template` is provided, it is used
-- instead of the default one. This is mainly used for testing since you usually
-- want to have some navigation menus which are extracted by creating the
-- documentation in batch mode with #make.
function lib:toHtml(template)
  return private.output.html(self, template)
end

function private.parseSources(tree, sources)
  local prepend = sources.prepend
  for _, mpath in ipairs(sources) do
    if type(mpath) == 'table' then
      private.parseSources(tree, mpath)
    else
      local mpath = lub.absolutizePath(mpath)
      if lub.fileType(mpath) == 'directory' then
        for path in lub.Dir(mpath):glob '%.lua' do
          private.insertInTree(tree, path, mpath, prepend)
        end
      else
        private.insertInTree(tree, mpath, lub.pathDir(mpath), prepend)
      end
    end
  end
end

function private.insertInTree(tree, fullpath, base, prepend)
  -- Remove base from path
  local path = string.sub(fullpath, string.len(base) + 2, -1)
  if prepend then
    path = prepend .. '/' .. path
  end
  if not match(path, '/') and not match(base, '/lib$') then
    -- base is too close to file, we need to have at least one
    -- folder level to get module name. If we are scanning "lib", consider
    -- files inside to be module definitions.
    local o = base
    base = lub.pathDir(base)
    return private.insertInTree(tree, fullpath, base)
  end
  local curr = tree
  local list = lub.split(path, '/')
  local last = #list
  for i, part in ipairs(list) do
    -- transform foo/init.lua into foo.lua
    local is_init

    if i == last then
      is_init = part == 'init.lua'
      -- Remove extension
      part = match(part, '(.*)%.lua$')
    end

    if is_init then
      curr.__file = fullpath
    else
      if not curr[part] then
        local fullname
        if curr.__fullname then
          fullname = curr.__fullname .. '.' .. part
        else
          fullname = part
        end
        curr[part] = { __name = part, __fullname = fullname}
        lub.insertSorted(curr, part)
      end
      curr = curr[part]

      if i == last then
        curr.__file = fullpath
      end
    end
  end
end

function private.makeDoc(tree, def)
  for _, elem_name in ipairs(tree) do
    local elem = tree[elem_name]
    -- Depth first so that we collect all titles and summary first.
    private.makeDoc(elem, def)
    local children, navigation
    if tree.is_root then
      children   = elem
      navigation = elem
    else
      children   = elem
      navigation = tree
    end

    local doc = lib.new(elem.__file, {
      -- Parent & siblings navigation (right menu)
      navigation = tree,
      -- Children navigation (listed in main div)
      children   = elem,
      target     = def.target,
      header     = def.header,
      footer     = def.footer or DEFAULT_FOOTER,
      toplevel   = tree.is_root,
      opts       = def,
    })
    elem.__title   = doc.sections[1].title
    elem.__summary = doc.sections[1][1][1]
    local img = doc.sections[1][1][2]
    if img and match(img.text or '', '^!%[') then
      elem.__img = img
    end
    elem.__todo    = doc.todo
    elem.__fixme   = doc.fixme
    local trg = def.target .. '/' .. doc.fullname .. '.' .. def.format
    lub.writeall(trg, private.output[def.format](doc, def.template))
  end

  if tree.is_root then
    tree.__name = 'index'
    -- Create index.html file
    local doc = lib.new(nil, {
      code = def.index or [=[ 
--[[----------
  # Table of contents

--]]----------
]=],
      -- Parent & siblings navigation (right menu)
      navigation = tree,
      -- Children navigation (listed in main div)
      children   = tree,
      target     = def.target,
      header     = def.header,
      footer     = def.footer or DEFAULT_FOOTER,
      toplevel   = false,
      opts       = def,
    })
    local trg = def.target .. '/index.' .. def.format
    lub.writeall(trg, private.output[def.format](doc, def.template))
  end

end


function private.getName(path)
  local name, module, fullname
  name = assert(match(path, '([^/]+)%.lua$'), "Invalid path '"..path.."'.")
  module = match(path, '([^/]+)/[^/]+$')
  if module then
    fullname = module .. '.' .. name
  else
    fullname = name
  end
  
  return module, name, fullname
end

function private:parseFile(path)
  local file = assert(io.open(path, "r"))
  local it = file:lines()
  private.doParse(self, function()
    return it()
  end)
  io.close(file)
end

function private:parseCode(code)
  local lines = lub.split(code, '\n')
  local it = ipairs(lines)
  local i = 0
  private.doParse(self, function()
    local _, l = it(lines, i)
    i = i + 1
    return l
  end)
end

function private:doParse(iterator)
  local state = parser.start
  local line_i = 0
  -- This is true on entering a state.
  local entering = true
  for line in iterator do
    local replay = true
    line_i = line_i + 1
    while replay do
      -- if self.name == 'Doc' then
      --   print(string.format("%3i %-14s %s", line_i, state.name or 'SUB', line))
      -- end
      replay = false
      for i=1,#state do
        local matcher = state[i]
        if not matcher.on_enter or entering then
          local m = {match(line, matcher.match)}
          if m[1] then
            local move = matcher.move
            if matcher.output then
              matcher.output(self, line_i, unpack(m))
              if self.force_move then
                -- We need this to avoid calling move and (enter/exit) just to
                -- test if we need to move.
                move = self.force_move
                self.force_move = nil
              end
            end
            local state_exit = state.exit
            if type(move) == 'function' then
              if state_exit  then state_exit(self) end
              state, replay = move(self)
              if not state then
                local def = debug.getinfo(move)
                error("Error in state definition ".. match(def.source, '^@(.+)$') .. ':' .. def.linedefined)
              end
              entering = true
              if state.enter then state.enter(self) end
            elseif not move then
              -- do not change state
              entering = false
            else
              if state_exit  then state_exit(self) end
              state = move
              entering = true
              if state.enter then state.enter(self) end
            end
            break
          end
        end
      end
    end
  end

  if state.exit then
    state.exit(self)
  end

  if state.eof then
    state.eof(self, line_i)
  end
  -- Clean draft content
  self.para  = nil
  self.scrap = nil
end

--=============================================== Helpers
local USED_TYPES = {
  TODO  = true,
  FIXME = true,
  WARN  = true,
  NOTE  = true,
}

function private:addTodo(i, text)
  private.todoFixme(self, i, '', 'TODO', text)
  private.flushPara(self)
end

function private:todoFixme(i, all, typ, text)
  if not USED_TYPES[typ] then
    return private.addToPara(self, i, all)
  end
  local group = self.in_func or self.group

  local no_list, txt = match(text, '^(-) *(.*)$')
  if no_list then
    text = txt
  end

  typ = string.lower(typ)
  table.insert(group, self.para)
  self.para = {
    span = typ,
    text = text,
  }
  -- If TODO/FIXME message starts with '-', do not show in lists.
  if no_list then return end

  local list = self[typ]
  if not list then
    -- Section for todo or fixme
    list = {
      name  = string.upper(typ),
      title = string.upper(typ),
      -- A single group with all fixmes and todos.
      {},
    }
    self[typ] = list
  end
  table.insert(list[1], {
    span  = typ,
    text  = text,
    -- This is to find function reference when the todo is shown
    -- outside the function documentation.
    group = group,
    file  = self.fullname,
    section_name = self.section.name,
  })
end

function private:newFunction(i, typ, fun, params)
  local i = #self.group
  if self.group[i] and self.group[i].text == 'nodoc' then
    -- ignore last para
    table.remove(self.group)
    self.para = nil
    return
  end

  -- Store last group as function definition
  if typ == ':' then
    self.group.fun = fun
  elseif typ == '.' then
    self.group.class_fun = fun
  else
    self.group.global_fun = fun
  end
  self.group.params = params
  private.useGroup(self)
  self.in_func = self.group
end

function private:newParam(i, key, params, typ)
  typ = typ or 'param'
  local i = #self.group
  if self.group[i] and self.group[i].text == 'nodoc' then
    -- ignore last para
    table.remove(self.group)
    self.para = nil
    return
  end

  -- Store last group as param definition
  self.group[typ] = key
  self.group.params = params

  if typ == 'tparam' then
    -- This is to have creation order
    table.insert(self.curr_param, self.group)
    self.curr_param[key] = self.group
  else
    table.insert(self.params, self.group)
    self.params[key] = self.group
  end

  private.useGroup(self)
  self.group = {}
end

function private:newTitle(i, title, typ)
  typ = typ or 'title'
  private.flushPara(self)
  table.insert(self.group, {
    heading = typ, text = title
  })
  private.useGroup(self)
end

function private:useGroup()
  local s = self.section
  if s[#s] ~= self.group then
    table.insert(s, self.group)
  end
end

function private:addToPara(i, d)
  if not self.para then
    self.para = { class = self.next_para_class}
    self.next_para_class = nil
  end
  local para = self.para
  if para.text then
    --para.text = para.text .. '\n' .. d or ''
    para.text = para.text .. ' ' .. d or ''
  else
    para.text = d or ''
  end
end

-- Add with newline.
function private:addToParaN(i, d)
  if not self.para then
    self.para = { class = self.next_para_class}
    self.next_para_class = nil
  end
  local para = self.para
  if para.text then
    para.text = para.text .. '\n' .. d or ''
  else
    para.text = d or ''
  end
end

function private:addToList(i, tag, text, definition)
  local key
  if definition then
    key  = text
    text = definition
  end
  local para = self.para
  if not para then
    self.para = {list = {}, text = text, key = key}
  elseif not para.list then
    -- Save previous paragraph.
    private.flushPara(self)
    -- Start new list
    self.para = {list = {}, text = text, key = key}
  else
    -- Move previous element in list
    table.insert(para.list, {text = para.text, key = para.key})
    -- Prepare next.
    para.text = text
    para.key  = key
  end
end

function private:newSection(i, title)
  private.flushPara(self)
  self.group = {}
  self.section = {self.group}
  table.insert(self.sections, self.section)
  self.section.title = title
  local name = title
  if #self.sections == 1 then
    name = self.name
  else
    name = gsub(title, ' ', '-')
  end
  self.section.name = name
end

function private:flushPara()
  if self.para then
    table.insert(self.group, self.para)
  end
  self.para = nil
end

--=============================================== Doc parser

-- A parser state is defined with:
-- {MATCH_KEY, SUB-STATES, match = function}
-- list of matches, actions
parser.start = {
  -- matchers
  { match  = '^%-%-%[%[',
    move   = {
      -- h2: new section
      { match  = '^ *# (.+)$',
        output = function(self, i, d)
          private.newSection(self, i, d)
          self.next_para_class = 'summary'
        end,
        move   = function() return parser.mgroup end,
      },
      -- h3: new title
      { match  = '^ *## (.+)$',
        output = private.newTitle,
        move   = function() return parser.mgroup end,
      },
      { match  = '^%-%-%]',
        output = function(self, i)
          print(string.format("Missing '# title' in preamble from '%s'.", self.fullname))
          -- make dummy doc
          private.newSection(self, i, self.fullname)
          table.insert(self.group, {text = '', class = 'summary'})
        end,
        move   = function() return parser.mgroup end,
      },
    }
  },

  eof = function(self, i)
    print(string.format("Reaching end of document without finding preamble documentation in '%s'.", self.fullname))
    -- make dummy doc
    private.newSection(self, i, self.fullname)
    table.insert(self.group, {text = '', class = 'summary'})
  end,
}

-- Multi-line documentation
parser.mgroup = {
  -- End of multi-line comment
  { match  = '^%-%-%]',
    output = private.flushPara,
    move   = function(self) return self.back or parser.end_comment end,
  },
  -- h2: new section
  { match = '^ *# (.+)$',
    output = private.newSection,
  },
  -- h3: new title
  { match = '^ *## (.+)$',
    output = private.newTitle,
  },
  -- out of file function
  { match  = '^ *function lib([:%.])([^%(]+)(.*)$',
    output = private.newFunction,
  },
  -- todo, fixme, warn
  { match = '^ *(([A-Z][A-Z][A-Z][A-Z]+):? ?(.*))$',
    output = private.todoFixme,
  },
  -- math section
  { match = '^ *%[math%]',
    move  = function() return parser.mmath, true end,
  },
  -- list
  { match = '^ *(%*+) +(.+)$',
    output = private.addToList,
  },
  -- definition list
  { match = '^ *(%+) +(.-): *(.+)$',
    output = private.addToList,
  },
  -- end of paragraph
  { match = '^ *$', 
    output = private.flushPara,
    move = {
      -- code
      { match = '^   ',
        output = private.flushPara,
        move  = function() return parser.mcode, true end,
      },
      { match = '',
        move  = function() return parser.mgroup, true end,
      },
    },
  },
  -- normal paragraph
  { match = '^ *(.+)$',
    output = private.addToPara,
  },
}

parser.mcode = {
  -- first line
  { match  = '^    (.*)$',
    output = function(self, i, d)
      local lang = match(d, '#([^ ]+)')
      if lang then
        d = nil
      else
        lang = 'lua'
      end
      lang = string.lower(lang)
      self.para = {code = lang, text = d}
    end,
    move = {
      -- code
      { match  = '^    (.*)$',
        output = private.addToParaN,
      },
      -- empty line
      { match  = '^ *$', 
        output = function(self, i)
          private.addToParaN(self, i, '')
        end,
      },
      -- end of code
      { match  = '', 
        output = function(self, i, d)
          private.flushPara(self)
        end,
        move = function() return parser.mgroup, true end,
      },
    },
  },
}

parser.code = {
  -- first line
  { match  = '^ *%-%-   (.*)$',
    output = function(self, i, d)
      local lang = match(d, '#([^ ]+.+)')
      if lang then
        d = nil
      else
        lang = 'lua'
      end
      lang = string.lower(lang)
      self.para = {code = lang, text = d}
    end,
    move = {
      -- code
      { match  = '^ *%-%-   (.*)$',
        output = private.addToParaN,
      },
      -- empty line
      { match  = '^ *%-%- *$', 
        output = function(self, i)
          private.addToParaN(self, i, '')
        end,
      },
      -- end of code
      { match  = '', 
        output = function(self, i, d)
          private.flushPara(self)
        end,
        move = function() return parser.group, true end,
      },
    },
  },
}

parser.mmath = {
  -- Inline
  { match  = '^ *%[math%](.*)%[/math%]', 
    output = function(self, i, d)
      private.flushPara(self)
      self.para = {math = 'inline', text = d}
      private.flushPara(self)
    end,
    move = function() return parser.mgroup end,
  },
  { match  = '^ *%[math%](.*)',
    output = function(self, i, d)
      private.flushPara(self)
      self.para = {math = 'block', text = d}
    end,
  },
  -- End of math
  { match  = '^(.*)%[/math%]', 
    output = function(self, i, d)
      private.addToPara(self, i, d)
      private.flushPara(self)
    end,
    move = function() return parser.mgroup end,
  },
  { match  = '^(.*)$',
    output = private.addToPara,
  },
}

parser.math = {
  -- One liner
  { match  = '^ *%-%- *%[math%](.*)%[/math%]', 
    output = function(self, i, d)
      private.flushPara(self)
      self.para = {math = true, text = d}
      private.flushPara(self)
    end,
    move = function() return parser.group end,
  },
  { match  = '^ *%-%- *%[math%](.*)',
    output = function(self, i, d)
      private.flushPara(self)
      self.para = {math = true, text = d}
    end,
  },
  -- End of math
  { match  = '^ *%-%- (.*)%[/math%]', 
    output = function(self, i, d)
      private.addToPara(self, i, d)
      private.flushPara(self)
    end,
    move = function() return parser.group end,
  },
  { match  = '^ *%-%- (.*)$',
    output = private.addToPara,
  },
}

parser.group = {
  -- code
  { match = '^ *%-%-   ',
    on_enter = true, -- only match right after entering.
    output   = private.flushPara,
    move     = function() return parser.code, true end,
  },
  -- end of comment
  { match  = '^ *[^%- ]',
    output = private.flushPara,
    move   = function(self) return self.back or parser.end_comment, true end
  },
  { match  = '^ *$',
    output = private.flushPara,
    move   = function(self)
      if self.back then
        return self.back, true
      else
        return parser.lua
      end
    end,
  },
  -- new section
  { match  = '^ *%-%- *# (.+)$',
    output = private.newSection,
  },
  -- new title
  { match  = '^ *%-%- *## (.+)$',
    output = private.newTitle,
  },
  -- out of file function definition
  { match  = '^ *%-%- *function lib([:%.])([^%(]+)(.*)$',
    output = private.newFunction,
  },
  -- math section
  { match = '^ *%-%- *%[math%]',
    move  = function() return parser.math, true end,
  },
  -- todo, fixme, warn
  { match = '^ *%-%- *(([A-Z][A-Z][A-Z][A-Z]+):? ?(.*))$',
    output = private.todoFixme,
  },
  -- list
  { match = '^ *%-%- *(%*+) +(.+)$',
    output = private.addToList,
  },
  -- definition list
  { match = '^ *%-%- *(%+) +(.-): *(.+)$',
    output = private.addToList,
  },
  -- end of paragraph
  { match = '^ *%-%- *$', 
    output = private.flushPara,
    move = {
      -- code
      { match = '^ *%-%-   ',
        output = private.flushPara,
        move  = function() return parser.code, true end,
      },
      { match = '',
        move  = function() return parser.group, true end,
      },
    },
  },
  -- normal paragraph
  { match = '^ *%-%- *(.+)$',
    output = private.addToPara,
  },
  eof = private.flushPara,
}

-- This is called just after the comment block ends.
parser.end_comment = {
  -- lib function
  { match  = '^function lib([:%.])([^%(]+) *(%(.-%))',
    output = private.newFunction,
    move   = function() return parser.lua end,
  },
  -- lib param
  { match  = 'lib%.([a-zA-Z_0-9]+) *= *(.+)$',
    output = function(self, i, key, def)
      local def2 = match(def, '^(.-) *%-%- *doc *$')
      if def2 then
        -- Special case where a lib attribute itself is documented
        self.curr_param = {}
        self.params[key] = self.curr_param
        private.newTitle(self, i, '.'..key .. ' = ')
        self.force_move = parser.params
      else
        if self.group[1] and self.group[1].heading then
          -- Group is not for us
          self.group = {}
          if not self.loose then
            private.addTodo(self, i, 'MISSING DOCUMENTATION')
          end
          private.newParam(self, i, key, def)
        else
          private.newParam(self, i, key, def)
        end
      end
    end
  },
  -- global function
  { match  = '^function ([^:%.%(]+) *(%(.-%))',
    output = function(self, i, name, params)
      private.newFunction(self, i, '', name, params)
    end
  },
  -- Match anything moves to raw code
  { match = '',
    move = function(self) return parser.lua, true end,
  }
}

parser.lua = {
  enter = function(self)
    if self.lit then
      -- Make sure we use previous comment.
      private.useGroup(self)
      self.group = {}
      self.para = {code = 'lua'}
    end
  end,
  exit = function(self)
    if self.lit then
      if lub.strip(self.para.text or '') == '' then
        -- Do not insert code for blank lines.
        self.para = nil
      else
        private.flushPara(self)
        private.useGroup(self)
      end
    end
  end,
  -- Undocummented function
  { match  = '^(function lib([:%.])([^%(]+) *(%(.-%)).*)$',
    output = function(self, i, all, typ, fun, params)
      if self.lit then
        private.addToParaN(self, i, all)
      else
        self.group = {}
        if not self.loose then
          private.addTodo(self, i, 'MISSING DOCUMENTATION')
        end
        private.newFunction(self, i, typ, fun, params)
      end
    end,
  },
  -- Undocummented param
  { match  = '^(lib%.([a-zA-Z_0-9]+) *= *(.+))$',
    output = function(self, i, all, key, def)
      if self.lit then
        private.addToParaN(self, i, all)
      else
        self.group = {}
        -- document all params
        -- match(def, '^({) *$') or
        local def2 = match(def, '^(.-) *%-%- *doc *$')
        if def2 then
          -- Special case where a lib attribute itself is documented
          self.curr_param = {}
          self.params[key] = self.curr_param
          private.newTitle(self, i, '.'..key .. ' = {')
          self.force_move = parser.params
        else
          if not self.loose then
            private.addTodo(self, i, 'MISSING DOCUMENTATION')
          end
          private.newParam(self, i, key, def)
        end
      end
    end,
  },
  -- end of function
  { match  = '^(end.*)$',
    output = function(self, i, d)
      self.in_func = nil
      if self.lit then private.addToParaN(self, i, d) end
    end,
  },
  -- move out of literate programming
  { match  = '^%-%- doc:no(.+)$',
    output = function(self, i, d)
      assert(ALLOWED_OPTIONS[d], string.format("Invalid option '%s' in '%s'.", d, self.name))
      self[d] = false
    end,
  },
  -- enter literate programming
  { match  = '^%-%- doc:(.+)$',
    output = function(self, i, d)
      assert(ALLOWED_OPTIONS[d], string.format("Invalid option '%s' in '%s'.", d, self.name))
      if d == 'loose' then
        private.addTodo(self, i, 'INCOMPLETE DOCUMENTATION')
      end
      self[d] = true
    end,
  },
  -- params
  { match  = '^ *(.-) *{ %-%- *doc *$',
    output = function(self, i, key)
      self.curr_param = {}
      self.params[key] = self.curr_param
      -- remove 'local' prefix
      local k = match(key, '^local *(.+)$')
      key = k or key
      private.newTitle(self, i, key .. ' {')
    end,
    move = function() return parser.params end,
  },
  -- todo, fixme, warn
  { match = '^ *(%-%- *([A-Z][A-Z][A-Z][A-Z]+):? ?(.*))$',
    output = private.todoFixme,
  },
  { match  = '^ *%-%- +(.+)$',
    move = function(self)
      -- Temporary group (not inserted in section).
      self.group = {}
                           -- replay last line
      return parser.group, true
    end,
  },
  { match  = '^%-%-%[%[',
    output = function(self)
      -- Temporary group (not inserted in section).
      self.group = {}
    end,
    move = function() return parser.mgroup end,
  },
  { match = '^(.*)$',
    output = function(self, ...)
      if self.lit then
        private.addToParaN(self, ...)
      end
    end,
  },
}

parser.params = {
  { match  = '^ *%-%- *## *(.*)$',
    output = function(self, i, d)
      private.newTitle(self, i, d, 'param')
      private.useGroup(self)
    end,
  },
  { match  = '^ *%-%- +(.+)$',
    output = function(self, i, d)
      -- Temporary group (not inserted in section).
      self.group = {}
    end,
    move = function(self)
      self.back = parser.params
      -- replay last line
      return parser.group, true
    end,
  },
  { match  = '^%-%-%[%[ *(.*)$',
    output = function(self, i, d)
      private.addToPara(self, i, d)
      -- Temporary group (not inserted in section).
      self.group = {}
    end,
    move = function(self)
      self.back = parser.params
      return parser.mgroup
    end,
  },
  -- param definition
  { match  = '^ *([a-zA-Z0-9_]+) *= *(.*), *$',
    output = function(self, i, key, d)
      private.newParam(self, i, key, d, 'tparam')
    end,
  },
  -- end of params definition
  { match = '^}',
    output = function(self, i)
      private.newTitle(self, i, '}', 'end')
      private.useGroup(self)
    end,
    move = function(self)
      self.back = nil
      return parser.lua
    end
  },
  { match = '',
    output = function(self)
      private.flushPara(self)
      self.group = {}
    end,
  },
}


-- debugging
for k, v in pairs(parser) do
  v.name = k
end

--=============================================== 

-- Output individual class definitions
private.output = {}
-- Output module with class summary
private.mod_output = {}

private.copyAssets = {}

function private.getTemplate(format)
  local filename = 'template.'..format
  return lub.content(lub.scriptDir()..'/doc/'..filename)
end

--=============================================== HTML TEMPLATE
function private.output:html(template)
  local tmplt = lub.Template(template or private.getTemplate('html'))
  return tmplt:run {self = self, private = private}
end

function private.mod_output.html(module, def, modules)
  local tmplt = lub.Template(def.template or private.getTemplate('html'))
  -- Create a pseudo class with classes as methods and class summary
  -- as method documentation.
  local self = {
    name = module.name,
    title = module.name,
    fullname = module.name,
    sections = {},
    navigation = modules,
    header = def.header,
    footer = def.footer or DEFAULT_FOOTER,
  }
  local section = {name = modules.name, title = module.name}
  table.insert(self.sections, section)
  for _, class in ipairs(module) do
    local def = module[class]
    -- A group = class doc
    table.insert(section, {
      class = def.fullname,
      name  = def.name,
      { text = def.summary },
    })
  end
  setmetatable(self, lib)
  return tmplt:run {self = self, private = private}
end

function private.copyFiles(list, target)
  for _, mpath in ipairs(list) do
    local len = string.len(mpath)
    for src in lub.Dir(mpath):glob() do
      local path = string.sub(src, len + 2)
      local trg  = target .. '/' .. path
      lub.copy(src, trg)
    end
  end
end

function private.copyAssets.html(target)
  local src_base = lub.scriptDir()
  for _, path in ipairs {
    'css/bootstrap.css',
    'css/docs.css',
    'img/glyphicons-halflings-white.png', 
    'img/glyphicons-halflings.png',
    'js/bootstrap.min.js',
  } do
    local src = src_base .. '/doc/' .. path
    local trg = target .. '/' .. path
    lub.writeall(trg, lub.content(src))
  end
end

local function escapeHtml(text)
  return gsub(
    gsub(text,
      '<', '&lt;'
    ),
      '>', '&gt;'
    )
end

function private:paraToHtml(para)
  local text = para.text or ''
  if para.class then
    return "<p class='"..para.class.."'>"..private.textToHtml(self, text).."</p>"
  elseif para.heading then
    return "<h4 class='sub-"..para.heading.."'>"..private.textToHtml(self, text).."</h4>"
  elseif para.math then
    return "<p>"..private.mathjaxTag(self, para).."</p>"
  elseif para.code then
    local tag
    local k =
    match(para.code or '', '^txt( .+)?$')
    if match(para.code, '^txt') then
      tag = "<pre class='"..para.code.."'>"
    else
      tag = "<pre class='prettyprint lang-"..para.code.."'>"
    end
    return tag .. 
      private.autoLink(gsub(escapeHtml(text), '%%%%', ''), nil)..
      "</pre>"
  elseif para.span then
    return private.spanToHtml(self, para)
  elseif para.list then
    -- render list
    return private.listToHtml(self, para)
  else
    return "<p>"..private.textToHtml(self, text).."</p>"
  end
end

function private:spanToHtml(para)
  local ref = ''
  local ref_name
  if para.group then
    if self.fullname ~= para.file then
      ref = para.file .. '.html'
    end
    if para.group.fun then
      if ref then
        ref = ref .. '#' .. para.group.fun
      else
        ref = '#' .. para.group.fun
      end
      ref_name = '#' .. para.group.fun
    elseif para.section_name then
      if ref then
        ref = ref .. '#' .. para.section_name
      else
        ref = '#' .. para.section_name
      end
      ref_name = para.section_name
    end
    ref = "<span class='ref'><a href='"..ref.."'>"..ref_name.."</a></span>"
  end
  return "<p class='"..para.span.."'>" ..
         ref ..
         "<span>"..string.upper(para.span).."</span> "..
         private.textToHtml(self, para.text)..
         "</p>"
end

function private.autoLink(p, codes)
  -- method link lub.Doc#make or lub.Doc.make
  if codes then
    -- para auto-link
    p = gsub(p, ' ([a-z]+%.[A-Z]+[a-z][a-zA-Z]+)([#%.])([a-zA-Z_]+)', function(class, typ, fun)
      table.insert(codes, string.format(" <a href='%s.html#%s'>%s%s%s</a>", class, fun, class, typ, fun))
      return CODE..#codes
    end)
  else
    -- code auto-link
    p = gsub(p, '([a-z]+%.[A-Z]+[a-z][a-zA-Z]+)([#%.])([a-zA-Z_]+)', function(class, typ, fun)
      return string.format("<a href='%s.html#%s'>%s%s%s</a>", class, fun, class, typ, fun)
    end)
  end
  -- auto-link lub.Doc
  p = gsub(p, ' ([a-z]+%.[A-Z]+[a-z0-9][a-zA-Z]*)([%. %(])', " <a href='%1.html'>%1</a>%2")
  return p
end

function private:textToHtml(text)
  -- filter content
  local p = escapeHtml(text or '')
  -- We could replace textToHtml with a walking parser to avoid double parsing.
  
  -- code
  local codes = {}
  p = gsub(p, '%[math%](.-)%[/math%]', function(latex)
    table.insert(codes, private.mathjaxTag(self, {math = 'inline', text = latex}))
    return CODE..#codes
  end)

  p = gsub(p, '`(.-)`', function(code)
    table.insert(codes, '<code>'..code..'</code>')
    return CODE..#codes
  end)
  p = private.autoLink(p, codes)
  -- section link #Make or method link #foo
  p = gsub(p, ' #([A-Za-z]+[A-Za-z_]+)', function(name)
    table.insert(codes, string.format(" <a href='#%s'>%s</a>", name, name))
    return CODE..#codes
  end)

  p = gsub(p, '^#([A-Za-z]+[A-Za-z_]+)', function(name)
    table.insert(codes, string.format(" <a href='#%s'>%s</a>", name, name))
    return CODE..#codes
  end)

  -- strong
  p = gsub(p, '%*([^\n]-)%*', '<strong>%1</strong>')
  -- em
  p = gsub(p, ' _(.-)_ ', ' <em>%1</em> ')
  p = gsub(p, '^_(.-)_', '<em>%1</em>')
  p = gsub(p, '_(.-)_$', '<em>%1</em>')
  -- ![Dummy example image](img/box.jpg)
  p = gsub(p, '!%[(.-)%]%((.-)%)', "<img alt='%1' src='%2'/>")
  -- link [some text](http://example.com)
  p = gsub(p, '%[([^%]]+)%]%(([^%)]+)%)', function(text, href)
    return "<a href='"..href.."'>"..text.."</a>"
  end)

  if #codes > 0 then
    p = gsub(p, CODE..'([0-9]+)', function(id)
      return codes[tonumber(id)]
    end)
  end
  return p
end

function private:listToHtml(para)
  if para.text then
    -- Flush last list element.
    table.insert(para.list, {text = para.text, key = para.key})
    para.text = nil
    para.key  = nil
  end

  if para.list[1].key then
    -- definition list
    local out = "<table class='definition'>\n"
    for _, line in ipairs(para.list) do
      out = out .. "  <tr><td class='key'>"..
            private.textToHtml(self, line.key) .."</td><td>" ..
            private.textToHtml(self, line.text).."</td></tr>\n"
    end
    return out .. '\n</table>'
  else
    -- bullet list
    local out = '<ul>\n'
    for _, line in ipairs(para.list) do
      out = out .. '<li>' .. private.textToHtml(self, line.text) .. '</li>\n'
    end
    return out .. '</ul>'
  end
end

local function osTry(cmd)
  local ret = os.execute(cmd)
  if ret ~= 0 then
    printf("Could not execute '%s'.", cmd)
  end
  return ret
end

function private:mathjaxTag(para)
  if para.math == 'inline' then
    return '\\('..para.text..'\\)'
  else
    return '$$'..para.text..'$$'
  end
end

function private:latexImageTag(para)
  local target = self.target
  local latex = para.text
  local mock = '[latex]'..latex..'[/latex]'
  -- Cannot process latex if we do not have an output target
  if not target then return mock end

  local pre, post = '', ''
  local type = match(latex, '^ *\\begin\\{(.-)}')
  if not type or
    (type ~= 'align' and
    type ~= 'equation' and
    type ~= 'itemize') then
    pre = '\\['
    post = '\\]'
  end

  if self.latex_img_i then
    self.latex_img_i = self.latex_img_i + 1
  else
    self.latex_img_i = 1
  end
  local img_name = self.fullname .. '.' .. self.latex_img_i .. '.png'
  local img_id   = 'latex'..self.latex_img_i

  local template = lub.Template(private.LATEX_IMG_TEMPLATE)
  local content = template:run { pre = pre, latex = latex, post = post }
  -- Create tmp file
  -- write content
  -- create image
  -- copy image to target/latex/doc.DocTest.1.png
  -- return image tag
  local tempf = 'tmpf' .. math.random(10000000, 99999999)

  lub.makePath(tempf)
  lub.makePath(target .. '/latex')
  lub.writeall(tempf .. '/base.tex', content)
  if osTry(string.format('cd %s && latex -interaction=batchmode "base.tex" &> /dev/null', tempf)) ~= 0 then
    lub.rmTree(tempf, true)
    return mock
  end
  if osTry(string.format('cd %s && dvips base.dvi -E -o base.ps &> /dev/null', tempf)) ~= 0 then
    lub.rmTree(tempf, true)
    return mock
  end
  if osTry(string.format('cd %s && convert -density 150 base.ps -matte -fuzz 10%% -transparent "#ffffff" base.png', tempf, target, img_name)) ~= 0 then
    lub.rmTree(tempf, true)
    return mock
  end
  if osTry(string.format('mv %s/base.png %s/latex/%s', tempf, target, img_name)) ~= 0 then
    lub.rmTree(tempf, true)
    return mock
  end
  lub.rmTree(tempf, true)
  return string.format("<code id='c%s' class='prettyprint lang-tex' style='display:none'>%s</code><img class='latex' id='%s' onclick='$(\"#c%s\").toggle()' src='latex/%s'/>", img_id, latex, img_id, img_id, img_name)
end

private.LATEX_IMG_TEMPLATE = [=[
\documentclass[10pt]{article}
\usepackage[utf8]{inputenc}
\usepackage{amssymb}

\usepackage{amsmath}
\usepackage{amsfonts}
% \usepackage{ulem}     % strikethrough (\sout{...})
\usepackage{hyperref} % links


% shortcuts
\DeclareMathOperator*{\argmin}{arg\,min}
\newcommand{\ve}[1]{\boldsymbol{#1}}
\newcommand{\ma}[1]{\boldsymbol{#1}}
\newenvironment{m}{\begin{bmatrix}}{\end{bmatrix}}

\pagestyle{empty}
\begin{document}
{{pre}}
{{latex}}
{{post}}
\end{document}
}
]=]
  
return lib
