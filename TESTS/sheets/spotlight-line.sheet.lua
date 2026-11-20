-- Feature sheet: <leader>sW switches the spotlight under the cursor to whole-line rendering and back; on a word
-- without a spotlight it says so and changes nothing.
return {
  id = "spotlight.line",
  title = "<leader>sW toggles whole-line rendering",
  feature = "spotlight.line",
  sizes = { { rows = 24, cols = 80 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.boot()]] },
    { keys = "gg0\\sK" },
    { keys = "\\sW" },
    { expect = [[_G.item("foo").line == true]], note = "foo is rendered across its lines" },
    { keys = "\\sW" },
    { expect = [[not _G.item("foo").line]], note = "and back to the word only" },
    { lua = [[_G.forget()]] },
    { keys = "w\\sW", note = "on bar, which is no spotlight" },
    { expect = [[#_G.notes > 0 and _G.texts() == "foo"]], note = "a message, and nothing changes" },
  },
  judge = { "the whole line of each occurrence is colored, a little under the word's own color" },
}
