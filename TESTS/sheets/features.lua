-- TESTS/sheets/features.lua -- the catalog of what spotlight.nvim does, one entry per functionality as a user
-- meets it (testing.nvim docs/SHEETS.md, "Feature sheets and the catalog"). Every entry has a feature sheet
-- next to this file (`feature = "<id>"`).
--
-- Performance (`testing perf`, testing.nvim docs/PERF.md): the plugin starts no process. `testing perf scan`
-- finds no start site in lua/ (2026-11-20), and none of the functionalities below reaches one through lib.nvim
-- either: the persistence store is a file under stdpath("cache") and `:Spotlight yank` writes only the unnamed
-- register, which does not reach the clipboard provider even with 'clipboard' set to "unnamedplus" (checked
-- 2026-11-20). The sheets are the realistic run of each functionality all the same.
return {
  {
    id = "spotlight.toggle",
    title = "<leader>sK spotlights every occurrence of the word or selection, . repeats it, <leader>sC clears all",
    surface = { "binding:<leader>sK", "binding:<leader>sK@x", "binding:<leader>sC" },
  },
  {
    id = "spotlight.toggle-here",
    title = "<leader>sk spotlights only the one occurrence (or selection) under the cursor",
    surface = { "binding:<leader>sk", "binding:<leader>sk@x", "command:Spotlight here" },
  },
  {
    id = "spotlight.navigate",
    title = "]k and [k jump to the next and previous occurrence, a count jumps further",
    surface = { "binding:]k", "binding:[k", "command:Spotlight next", "command:Spotlight prev" },
  },
  {
    id = "spotlight.list",
    title = "<leader>sL lists the spotlights in a chooser; choosing one jumps to it",
    surface = { "binding:<leader>sL", "command:Spotlight list" },
  },
  {
    id = "spotlight.quickfix",
    title = "<leader>sq puts every line that holds a spotlight into the quickfix list, each line once",
    surface = { "binding:<leader>sq", "command:Spotlight qf" },
  },
  {
    id = "spotlight.line",
    title = "<leader>sW renders the spotlight under the cursor across its whole lines and back",
    surface = { "binding:<leader>sW", "command:Spotlight line" },
  },
  {
    id = "spotlight.yank",
    title = ":Spotlight yank copies every line that holds a spotlight into the unnamed register",
    surface = { "command:Spotlight yank" },
  },
  {
    id = "spotlight.map",
    title = ":Spotlight map puts a sign on every line that holds a spotlight, :Spotlight map clear removes them",
    surface = { "command:Spotlight map", "command:Spotlight map clear" },
  },
  {
    id = "spotlight.lock",
    title = ":Spotlight lock pins a spotlight to its color, a second call frees it",
    surface = { "command:Spotlight lock" },
  },
  {
    id = "spotlight.state",
    title = ":Spotlight sets, persist and winopt: saved sets, the per-file persistence switch, off per window",
    surface = {
      "command:Spotlight sets save",
      "command:Spotlight sets list",
      "command:Spotlight sets switch",
      "command:Spotlight sets delete",
      "command:Spotlight persist",
      "command:Spotlight winopt",
    },
  },
  {
    id = "spotlight.persist-restart",
    title = "The spotlights of a file come back after the editor is quit and started again",
    surface = { "command:Spotlight persist" },
  },
}
