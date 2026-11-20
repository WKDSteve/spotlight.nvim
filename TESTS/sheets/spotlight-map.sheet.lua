-- Feature sheet: :Spotlight map puts a sign on every line that holds a spotlight, :Spotlight map clear takes
-- them away.
return {
  id = "spotlight.map",
  title = ":Spotlight map and map clear",
  feature = "spotlight.map",
  sizes = { { rows = 24, cols = 80 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.boot()]] },
    {
      lua = [[_G.marks = function()
        return #vim.api.nvim_buf_get_extmarks(0, require("spotlight.map").namespace(), 0, -1, {})
      end]],
    },
    { keys = "gg0\\sK" },
    { keys = ":Spotlight map<CR>" },
    { expect = [[_G.marks() == 2]], note = "a sign on line 1 and line 2" },
    { keys = ":Spotlight map clear<CR>" },
    { expect = [[_G.marks() == 0]], note = "map clear removes them" },
  },
  judge = { "the signs sit in the sign column, in the colors of their spotlights" },
}
