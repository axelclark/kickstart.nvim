return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
    keys = {
      { '<leader>ti', '<cmd>IBLToggle<cr>', desc = 'Toggle indent guides' },
    },
  },
}
