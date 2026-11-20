-- Feature sheet: :Spotlight yank copies the lines that hold a spotlight into the unnamed register, then p pastes
-- them.
return {
  id = "spotlight.yank",
  title = ":Spotlight yank copies the matching lines",
  feature = "spotlight.yank",
  sizes = { { rows = 24, cols = 80 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.boot()]] },
    { keys = "gg0\\sK" },
    { keys = ":Spotlight yank<CR>" },
    {
      expect = [[vim.fn.getreg('"') == "foo bar foo\nbaz foo bar\n" and vim.fn.getregtype('"') == "V"]],
      note = "the two lines with foo, linewise",
    },
    { keys = "Gp" },
    {
      expect = [[vim.api.nvim_buf_line_count(0) == 5 and vim.fn.getline(4) == "foo bar foo"]],
      note = "p pastes them under the last line",
    },
  },
}
