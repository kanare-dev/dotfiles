return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false, -- nvim-treesitter (rewrite) does not support lazy-loading
    config = function()
      -- Default values are fine; install_dir can be customized later if needed.
      require("nvim-treesitter").setup({})
    end,
  },
}

