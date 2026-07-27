return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        which_key = true,
        mason = true,
        noice = true,
        notify = true,
        telescope = { enabled = true },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },
}
