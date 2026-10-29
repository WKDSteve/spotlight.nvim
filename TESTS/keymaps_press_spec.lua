-- TESTS/keymaps_press_spec.lua
-- Every preset keymap, actually *pressed*. `keymaps_spec.lua` reads the
-- declaration and `commands_spec.lua` checks that each lhs is registered; neither
-- would notice a key that is bound to the wrong action, or to an rhs that does
-- nothing. Here each default key is fed through `nvim_feedkeys` (remapping on,
-- "x" = execute the typeahead now) and the effect is read back through the
-- registry, the quickfix list, the cursor or the chooser double.
--
-- The keys are typed exactly as a user types them: `<leader>` is resolved
-- against `mapleader` (a space here), never against the mapping table, so a
-- missing or misrouted mapping falls through to Vim's own meaning of the keys
-- and the assertion after it fails.

local t = require("harness")

local M = {}

local SELECT = "ui.kit.select"

---@internal
--- Press `keys` with remapping on and run the typeahead to completion.
---@param keys string # `<leader>` and `<Esc>`-style notation allowed.
---@return nil
local function press(keys)
  keys = keys:gsub("<leader>", vim.g.mapleader)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "mx", false)
end

---@internal
--- The texts of the active spotlights, keyed for lookup.
---@return table<string, table> by_text
local function by_text()
  local out = {}
  for _, item in ipairs(require("spotlight.core.registry").all()) do
    out[item.text] = item
  end
  return out
end

---@internal
--- A fresh fixture buffer and an empty registry, so that a key which is not
--- mapped -- and therefore runs Vim's own `s`, `k`, ... on the buffer -- cannot
--- leave a mangled buffer behind for the next section.
---@return nil
local function fresh()
  require("spotlight.core.registry").clear()
  t.fixture({ "aaa bbb ccc", "xxx aaa yyy", "zzz", "aaa end" })
end

function M.run()
  vim.g.mapleader = " "

  local api = require("spotlight")
  local registry = require("spotlight.core.registry")

  api.setup()
  fresh()

  -- ---------- <leader>sk (n): this occurrence only ----------
  t.ok("sk/n: cursor on the first aaa", t.cursor_on(1, "aaa"))
  press("<leader>sk")
  t.eq("sk/n: one spotlight added", registry.count(), 1)
  t.eq("sk/n: it is the token under the cursor", registry.all()[1] and registry.all()[1].text, "aaa")
  t.eq("sk/n: pinned to this occurrence (buffer scope)", registry.all()[1] and registry.all()[1].scope, "buffer")
  press("<leader>sk")
  t.eq("sk/n: pressed again on the same spot, it is removed", registry.count(), 0)

  -- ---------- <leader>sk (x): this selection only ----------
  fresh()
  t.ok("sk/x: cursor on bbb", t.cursor_on(1, "bbb"))
  press("viw<leader>sk")
  t.eq("sk/x: one spotlight added", registry.count(), 1)
  t.eq("sk/x: the selection's text", registry.all()[1] and registry.all()[1].text, "bbb")
  t.eq("sk/x: pinned to this occurrence (buffer scope)", registry.all()[1] and registry.all()[1].scope, "buffer")
  t.eq("sk/x: Visual mode was left", vim.api.nvim_get_mode().mode, "n")

  -- ---------- <leader>sK (n): every occurrence ----------
  fresh()
  t.ok("sK/n: cursor on the first aaa", t.cursor_on(1, "aaa"))
  press("<leader>sK")
  t.eq("sK/n: one spotlight added", registry.count(), 1)
  t.eq("sK/n: it is the token under the cursor", registry.all()[1] and registry.all()[1].text, "aaa")
  t.neq("sK/n: not pinned to one occurrence", registry.all()[1] and registry.all()[1].scope, "buffer")
  press("<leader>sK")
  t.eq("sK/n: pressed again, it is removed", registry.count(), 0)

  -- ---------- <leader>sK (x): every occurrence of the selection ----------
  fresh()
  t.ok("sK/x: cursor on ccc", t.cursor_on(1, "ccc"))
  press("viw<leader>sK")
  t.eq("sK/x: one spotlight added", registry.count(), 1)
  t.eq("sK/x: the selection's text", registry.all()[1] and registry.all()[1].text, "ccc")
  t.neq("sK/x: not pinned to one occurrence", registry.all()[1] and registry.all()[1].scope, "buffer")
  t.eq("sK/x: Visual mode was left", vim.api.nvim_get_mode().mode, "n")

  -- ---------- <leader>sW: whole-line rendering ----------
  fresh()
  api.add("aaa")
  t.ok("sW: cursor on a spotlighted aaa", t.cursor_on(2, "aaa"))
  t.eq("sW: line mode starts off", by_text().aaa and by_text().aaa.line or false, false)
  press("<leader>sW")
  t.eq("sW: pressed once, line mode is on", by_text().aaa and by_text().aaa.line, true)
  press("<leader>sW")
  t.eq("sW: pressed again, it is off", by_text().aaa and by_text().aaa.line or false, false)

  -- ---------- ]k / [k: navigation, with a count ----------
  fresh()
  api.add("aaa")
  -- "aaa" sits on lines 1, 2 and 4; start on line 3 (no match).
  vim.api.nvim_win_set_cursor(0, { 3, 0 })
  press("]k")
  t.eq("]k: jumps forward to the next occurrence", vim.api.nvim_win_get_cursor(0)[1], 4)
  vim.api.nvim_win_set_cursor(0, { 3, 0 })
  press("[k")
  t.eq("[k: jumps back to the previous occurrence", vim.api.nvim_win_get_cursor(0)[1], 2)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  press("2]k")
  t.eq("2]k: the count is honoured (two occurrences forward)", vim.api.nvim_win_get_cursor(0)[1], 4)
  -- Start on the no-match line 3, not mid-line on line 4: from (4,4) the `z` flag of the backward
  -- search skips the occurrence at (4,0) (see the vault task spotlight.nvim/back-jump-mid-line).
  vim.api.nvim_win_set_cursor(0, { 3, 0 })
  press("2[k")
  t.eq("2[k: the count is honoured (two occurrences back)", vim.api.nvim_win_get_cursor(0)[1], 1)

  -- ---------- <leader>sq: matching lines to quickfix ----------
  fresh()
  api.add("aaa")
  vim.fn.setqflist({}, "r")
  press("<leader>sq")
  t.eq("sq: every line holding aaa is in the quickfix list", #vim.fn.getqflist(), 3)
  vim.fn.setqflist({}, "r")
  vim.cmd("cclose")

  -- ---------- <leader>sL: the list ----------
  fresh()
  api.add("aaa")
  local opened = nil
  t.with_modules({
    [SELECT] = {
      open = function(opts)
        opened = opts
      end,
    },
  }, function()
    press("<leader>sL")
  end)
  t.eq("sL: the chooser was opened", type(opened), "table")
  t.eq("sL: with one row per spotlight", opened and opened.items and #opened.items, 1)

  -- ---------- <leader>sC: clear ----------
  fresh()
  api.add("aaa")
  api.add("bbb")
  t.eq("sC: two spotlights before", registry.count(), 2)
  press("<leader>sC")
  t.eq("sC: none after", registry.count(), 0)
  t.eq("sC: and no match is left in the window", #vim.fn.getmatches(), 0)

  registry.clear()
end

return M
