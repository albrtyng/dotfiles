-- Keymaps are automatically loaded on the VeryLazy event
-- Add any additional keymaps here

vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<Cmd>w<CR>")

-- Toggle terminal with Ctrl+`
vim.keymap.set({ "n", "t" }, "<C-`>", function()
  Snacks.terminal.toggle(nil, {
    win = {
      position = "float",
      width = 0.80,
      height = 0.80,
      border = "rounded",
    },
  })
end, { desc = "Toggle Terminal" })
