return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    init = function()
      vim.g.nvim_surround_no_visual_mappings = true
    end,
    opts = {},
    keys = {
      { "gS", "<Plug>(nvim-surround-visual)", mode = "x", desc = "Surround visual" },
      { "gZ", "<Plug>(nvim-surround-visual-line)", mode = "x", desc = "Surround visual line" },
    },
  },
  -- Remove flash's `s` from operator-pending mode so cs/ds (surround) work
  {
    "folke/flash.nvim",
    keys = {
      { "s", mode = { "n", "x" }, function() require("flash").jump() end, desc = "Flash" },
    },
  },
}
