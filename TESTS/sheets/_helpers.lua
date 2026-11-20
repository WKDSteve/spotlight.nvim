-- TESTS/sheets/_helpers.lua -- what every spotlight test sheet needs in its child editor. Not a sheet
-- (`testing.sheet` only reads *.sheet.lua); a sheet's first step runs it with `dofile`, the child's cwd is
-- the project root. The directory is in the spec's @cache-inputs, so a change here re-runs the sheets.
--
-- The plugin runs for real on a small file in a temp directory. ui.nvim is not on the runtimepath (the
-- health spec depends on that), so `ui.kit.select`, which `:Spotlight list` opens, is a recorder: the
-- option table it was handed is what counts (`_G.chooser`).

vim.o.swapfile = false
vim.opt.shortmess:append("I")

_G.notes = {}
vim.notify = function(msg)
  _G.notes[#_G.notes + 1] = tostring(msg)
end

---Whether a notification so far holds `text` (plain).
---@param text string
---@return boolean
function _G.noted(text)
  for _, n in ipairs(_G.notes) do
    if n:find(text, 1, true) then
      return true
    end
  end
  return false
end

---Forget the notifications and the recorded chooser call.
function _G.forget()
  _G.notes = {}
  _G.chooser = nil
end

---The texts of the active spotlights, sorted and joined with a comma.
---@return string
function _G.texts()
  local out = {}
  for _, item in ipairs(require("spotlight.core.registry").all()) do
    out[#out + 1] = item.text
  end
  table.sort(out)
  return table.concat(out, ",")
end

---How many Spotlight matches the current window carries.
---@return integer
function _G.matches()
  local n = 0
  for _, m in ipairs(vim.fn.getmatches()) do
    if m.group:find("^Spotlight") then
      n = n + 1
    end
  end
  return n
end

---The rows (first line of each entry) the chooser recorder was handed, joined with "|".
---@return string
function _G.rows()
  local out = {}
  for _, e in ipairs(_G.chooser and _G.chooser.items or {}) do
    out[#out + 1] = e.lines[1]
  end
  return table.concat(out, "|")
end

---The spotlight whose text is `text`, or nil.
---@param text string
---@return table|nil
function _G.item(text)
  for _, item in ipairs(require("spotlight.core.registry").all()) do
    if item.text == text then
      return item
    end
  end
  return nil
end

---How many spotlights there are.
---@return integer
function _G.count()
  return #require("spotlight.core.registry").all()
end

---The cursor as "row:col" (1-based row, 0-based byte column).
---@return string
function _G.at()
  local pos = vim.api.nvim_win_get_cursor(0)
  return pos[1] .. ":" .. pos[2]
end

---Open a small file as the current buffer, set the plugin up and stub the chooser.
---@param dir string|nil where the file lives; default a fresh temp directory. A directory that must outlive
---the editor (a `restart` step deletes the old editor's temp directory) is passed here; an existing file
---there is kept as it is.
function _G.boot(dir)
  package.loaded["ui.kit.select"] = {
    open = function(opts)
      _G.chooser = opts
    end,
  }
  _G.dir = dir or vim.fn.tempname()
  vim.fn.mkdir(_G.dir, "p")
  _G.file = _G.dir .. "/a.txt"
  if vim.fn.filereadable(_G.file) == 0 then
    vim.fn.writefile({ "foo bar foo", "baz foo bar", "bar only" }, _G.file)
  end
  require("spotlight").setup()
  vim.cmd("edit " .. vim.fn.fnameescape(_G.file))
  _G.forget()
end
