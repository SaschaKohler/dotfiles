return {

  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      dashboard = {
        enabled = false,
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
    },
  },
  { "nvimdev/dashboard-nvim", enabled = false },
  "folke/snacks.nvim",
  opts = {

    explorer = { enabled = false },
  },
}
