-- Feature sheet: <leader>sk marks only the occurrence under the cursor; the second foo of the line is its own
-- spotlight, the same key takes it off again, and a visual selection is marked only where it is.
return {
  id = "spotlight.toggle-here",
  title = "<leader>sk toggles only this occurrence",
  feature = "spotlight.toggle-here",
  sizes = { { rows = 24, cols = 80 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.boot()]] },
    { keys = "gg0\\sk", note = "on the first foo" },
    {
      expect = [[_G.count() == 1 and _G.item("foo").scope == "buffer" and _G.matches() >= 1]],
      note = "one spotlight, scoped to this occurrence",
    },
    { keys = "2w\\sk", note = "on the second foo of the line" },
    { expect = [[_G.count() == 2]], note = "the second occurrence is a spotlight of its own" },
    { keys = "\\sk" },
    { expect = [[_G.count() == 1]], note = "the same key on it takes only that one off" },
    { keys = "2G0viw\\sk", note = "select baz" },
    {
      expect = [[_G.count() == 2 and _G.item("baz").scope == "buffer" and vim.fn.mode() == "n"]],
      note = "the selection is marked only where it is",
    },
  },
  judge = { "only the marked occurrence is colored, the other foo of the line is not" },
}
