-- Feature sheet: <leader>sL opens the list of spotlights (the chooser is a recorder, see _helpers.lua) and
-- choosing one jumps to it.
return {
  id = "spotlight.list",
  title = "<leader>sL lists the spotlights, choosing one jumps to it",
  feature = "spotlight.list",
  sizes = { { rows = 24, cols = 80 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.boot()]] },
    { keys = "gg0\\sKw\\sK" },
    { expect = [[_G.texts() == "bar,foo"]], note = "foo and bar are spotlighted" },
    { keys = "3G0\\sL", note = "on the last line, which has no foo" },
    {
      expect = [[_G.chooser and _G.chooser.title:find("select to jump", 1, true) ~= nil]],
      note = "the chooser opens in jump mode",
    },
    {
      expect = [[_G.rows():find("foo", 1, true) ~= nil and _G.rows():find("bar", 1, true) ~= nil]],
      note = "one row per spotlight",
    },
    {
      lua = [[for _, e in ipairs(_G.chooser.items) do if e.value.text == "foo" then _G.chooser.on_select(e) end end]],
      note = "choosing foo",
    },
    {
      expect = [[vim.api.nvim_get_current_line():sub(vim.fn.col("."), vim.fn.col(".") + 2) == "foo"]],
      note = "the cursor is on an occurrence of foo",
    },
  },
  manual = { "the real chooser (ui.nvim): the float, the swatches and the keys inside it" },
}
