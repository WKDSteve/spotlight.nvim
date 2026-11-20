-- Feature sheet: <leader>sK on a word, `.` on the next one, <leader>sK again to take one off, a visual selection,
-- then <leader>sC. The leader is the default backslash.
return {
  id = "spotlight.toggle",
  title = "<leader>sK toggles every occurrence, . repeats it, <leader>sC clears",
  feature = "spotlight.toggle",
  sizes = { { rows = 24, cols = 80 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.boot()]] },
    { keys = "gg0" },
    { keys = "\\sK", note = "the cursor is on foo" },
    {
      expect = [[_G.texts() == "foo" and _G.matches() >= 1]],
      note = "foo is spotlighted and drawn in this window",
    },
    { keys = "w." },
    { expect = [[_G.texts() == "bar,foo"]], note = ". repeats the toggle on the word now under the cursor" },
    { keys = "\\sK" },
    { expect = [[_G.texts() == "foo"]], note = "the same key on bar takes it off again" },
    { keys = "3G0v2e\\sK" },
    {
      expect = [[_G.texts() == "bar only,foo" and vim.fn.mode() == "n"]],
      note = "a visual selection is spotlighted as it is, and visual mode is left",
    },
    { keys = "\\sC" },
    { expect = [[_G.texts() == "" and _G.matches() == 0]], note = "<leader>sC clears every spotlight" },
  },
  judge = { "each spotlight has its own color, the whole occurrence is colored, nothing else" },
}
