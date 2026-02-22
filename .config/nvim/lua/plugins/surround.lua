return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {
      keymaps = {
        visual = "gS",
        visual_line = "gZ",
      },
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
