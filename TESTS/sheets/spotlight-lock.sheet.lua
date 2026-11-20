-- Feature sheet: :Spotlight lock <text> pins a spotlight to its palette slot, a second call frees it.
return {
  id = "spotlight.lock",
  title = ":Spotlight lock pins a color",
  feature = "spotlight.lock",
  sizes = { { rows = 24, cols = 80 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.boot()]] },
    { keys = "gg0\\sK" },
    { lua = [[_G.slot = _G.item("foo").slot]] },
    { keys = ":Spotlight lock foo<CR>" },
    { expect = [[_G.item("foo").locked == true and _G.item("foo").slot == _G.slot]], note = "locked, same color" },
    { keys = ":Spotlight lock foo<CR>" },
    { expect = [[not _G.item("foo").locked]], note = "the second call frees it" },
  },
}
