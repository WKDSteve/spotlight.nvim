-- Feature sheet: <leader>sq fills the quickfix list with the lines that hold a spotlight, each line once even
-- when several spotlights are on it.
return {
  id = "spotlight.quickfix",
  title = "<leader>sq: the matching lines in the quickfix list",
  feature = "spotlight.quickfix",
  sizes = { { rows = 24, cols = 80 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.boot()]] },
    { keys = "gg0\\sK" },
    { keys = "\\sq" },
    {
      expect = [[#vim.fn.getqflist() == 2 and vim.fn.getqflist()[1].lnum == 1 and vim.fn.getqflist()[2].lnum == 2]],
      note = "foo: lines 1 and 2",
    },
    { keys = ":cclose<CR>gg0w\\sK" },
    { keys = "\\sq" },
    { expect = [[#vim.fn.getqflist() == 3]], note = "foo and bar: lines 1, 2 and 3, each once" },
  },
}
