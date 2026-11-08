-- Live check: `:Spotlight sets`, `persist`, `winopt` and `list` in a real editor (task
-- spotlight.nvim/testblatt-bindings-checkliste; the :Spotlight section of BINDINGS-RUNTIME-CHECKLIST.md).
-- The rest of the commands and every key are covered by the specs (commands_spec, keymaps_press_spec, ...).
-- Automated: sets save/list/switch/delete, persist status/on/off/default, winopt status/off/on/toggle (the
-- window really loses its matches), list with its filter and its remove mode (the chooser is a recorder).
-- Not here: how the swatches and the chooser float look.
return {
  id = "spotlight.commands",
  title = ":Spotlight sets, persist, winopt and list",
  task = "spotlight.nvim/testblatt-bindings-checkliste",
  sizes = { { rows = 30, cols = 100 } },
  steps = {
    { lua = [[dofile(vim.fn.getcwd() .. "/TESTS/sheets/_helpers.lua"); _G.boot()]] },
    { keys = ":Spotlight add foo<CR>" },
    { keys = ":Spotlight add bar<CR>" },
    {
      expect = [[_G.texts() == "bar,foo" and _G.matches() >= 2]],
      note = "two spotlights, both drawn in this window",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight sets list<CR>" },
    { expect = [[_G.noted("no saved sets")]], note = "no set saved yet" },
    { keys = ":Spotlight sets save one<CR>" },
    { expect = [[_G.noted("saved set 'one' (2 spotlights)")]], note = "sets save" },
    { keys = ":Spotlight clear<CR>" },
    { keys = ":Spotlight add baz<CR>" },
    { keys = ":Spotlight sets save two<CR>" },
    { expect = [[_G.noted("saved set 'two' (1 spotlight)")]], note = "a second set, one spotlight" },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight sets list<CR>" },
    {
      expect = [[_G.noted("one (2 spotlights)") and _G.noted("two (1 spotlight)")]],
      note = "sets list names both with their counts",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight sets switch one<CR>" },
    {
      expect = [[_G.texts() == "bar,foo" and _G.noted("switched to set 'one' (2 spotlights)")]],
      note = "sets switch drops baz and restores foo and bar",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight sets switch nope<CR>" },
    {
      expect = [[_G.noted("nope") and _G.texts() == "bar,foo"]],
      note = "an unknown set is refused and changes nothing",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight sets delete two<CR>" },
    {
      expect = [[_G.noted("deleted set: two") and _G.texts() == "bar,foo"]],
      note = "sets delete leaves the active spotlights alone",
    },
    { keys = ":Spotlight sets delete two<CR>" },
    { expect = [[_G.noted("no such set: two")]], note = "and a second delete finds nothing" },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight sets list<CR>" },
    {
      expect = [[_G.noted("one (2 spotlights)") and not _G.noted("two (")]],
      note = "only set one is left",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight persist<CR>" },
    {
      expect = [[_G.noted("a.txt") and _G.noted("following the global default")]],
      note = "persist status names the file and that no override is set",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight persist off<CR>" },
    {
      expect = [[_G.noted("not persisted (explicit override")]],
      note = "persist off is an explicit override",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight persist on<CR>" },
    {
      expect = [[_G.noted(": persisted (explicit override")]],
      note = "persist on overrides the other way",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight persist default<CR>" },
    {
      expect = [[_G.noted("following the global default")]],
      note = "persist default drops the override",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight winopt status<CR>" },
    { expect = [[_G.noted("spotlighting is on in this window")]], note = "winopt status: on" },
    { keys = ":Spotlight winopt off<CR>" },
    {
      expect = [[_G.noted("spotlighting disabled in this window") and _G.matches() == 0]],
      note = "winopt off strips the matches from this window at once",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight winopt status<CR>" },
    { expect = [[_G.noted("spotlighting is off in this window")]], note = "winopt status: off" },
    { keys = ":Spotlight winopt on<CR>" },
    {
      expect = [[_G.matches() >= 2]],
      note = "winopt on draws them again",
    },
    { keys = ":Spotlight winopt<CR>" },
    { expect = [[_G.matches() == 0]], note = "a bare winopt toggles: off" },
    { keys = ":Spotlight winopt<CR>" },
    { expect = [[_G.matches() >= 2]], note = "and on again" },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight list<CR>" },
    {
      expect = [[_G.chooser and _G.chooser.title:find("select to jump", 1, true) ~= nil]],
      note = "list hands the chooser its jump-mode title",
    },
    {
      expect = [[_G.rows():find("foo", 1, true) ~= nil and _G.rows():find("bar", 1, true) ~= nil]],
      note = "and one row per spotlight",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight list jump foo<CR>" },
    {
      expect = [[_G.rows():find("foo", 1, true) ~= nil and _G.rows():find("bar", 1, true) == nil]],
      note = "the filter narrows the rows",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight list jump zzz<CR>" },
    {
      expect = [[_G.noted('no spotlight matching "zzz"') and _G.chooser == nil]],
      note = "a filter without a hit opens nothing",
    },
    { lua = [[_G.forget()]] },
    { keys = ":Spotlight list remove<CR>" },
    {
      expect = [[_G.chooser.title:find("select to remove", 1, true) ~= nil]],
      note = "list remove is the same list in remove mode",
    },
    {
      lua = [[for _, e in ipairs(_G.chooser.items) do if e.value.text == "foo" then _G.chooser.on_select(e) end end]],
      note = "choosing foo",
    },
    { expect = [[_G.texts() == "bar"]], note = "removes that spotlight" },
  },
  judge = { "the swatches in the list are the colors of the highlights in the text" },
  manual = {
    "`:Spotlight list` in the real chooser (ui.nvim): the float, the swatches and the keys inside it",
    "persistence across an editor restart (`:Spotlight persist on`, quit, reopen the file)",
  },
}
