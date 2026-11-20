-- Feature sheet: spotlights set in a file come back after the editor is quit and started again (`restart`: the
-- same sandbox, so the store under stdpath("cache") stays). The file lives under stdpath("data"), since the old
-- editor's temp directory goes away with it.
return {
  id = "spotlight.persist-restart",
  title = "Spotlights survive an editor restart",
  feature = "spotlight.persist-restart",
  sizes = { { rows = 24, cols = 80 } },
  steps = {
    {
      lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.boot(vim.fn.stdpath("data") .. "/sheet-project")]],
    },
    { keys = "gg0\\sKw\\sK" },
    { expect = [[_G.texts() == "bar,foo"]], note = "foo and bar are spotlighted" },
    { restart = true, note = "quit (VimLeavePre writes the pending save) and start again" },
    {
      lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.boot(vim.fn.stdpath("data") .. "/sheet-project")]],
      note = "set up again and open the same file",
    },
    { wait = [[_G.texts() == "bar,foo" and _G.matches() >= 2]], note = "both are back and drawn" },
  },
}
