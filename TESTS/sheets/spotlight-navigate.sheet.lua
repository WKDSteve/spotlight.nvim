-- Feature sheet: with foo spotlighted (foo is at 1:0, 1:8 and 2:4), ]k and [k walk its occurrences, a count
-- walks further.
return {
  id = "spotlight.navigate",
  title = "]k and [k jump between the occurrences",
  feature = "spotlight.navigate",
  sizes = { { rows = 24, cols = 80 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.boot()]] },
    { keys = "gg0\\sK" },
    { expect = [[_G.texts() == "foo"]], note = "foo is spotlighted" },
    { keys = "]k" },
    { expect = [[_G.at() == "1:8"]], note = "]k: the second foo of the first line" },
    { keys = "]k" },
    { expect = [[_G.at() == "2:4"]], note = "]k again: the foo of the second line" },
    { keys = "[k" },
    { expect = [[_G.at() == "1:8"]], note = "[k goes back" },
    { keys = "gg02]k" },
    { expect = [[_G.at() == "2:4"]], note = "2]k skips one occurrence" },
  },
}
