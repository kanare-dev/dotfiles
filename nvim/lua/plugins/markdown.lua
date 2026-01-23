return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "markdown.mdx" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
  {
    "gaoDean/autolist.nvim",
    ft = { "markdown", "markdown.mdx" },
    config = function()
      require("autolist").setup()

      local opts = { buffer = true, silent = true }
      vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", opts)
      vim.keymap.set("i", "<Tab>", "<cmd>AutolistTab<cr>", opts)
      vim.keymap.set("i", "<S-Tab>", "<cmd>AutolistShiftTab<cr>", opts)
      vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>", opts)
      vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>", opts)
    end,
  },
}

