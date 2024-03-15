return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('neo-tree').setup {
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = {
            '.DS_Store',
          },
        },
      },
      -- nnoremap / :Neotree toggle current reveal_force_cwd<cr>
      -- nnoremap | :Neotree reveal<cr>
      -- nnoremap gd :Neotree float reveal_file=<cfile> reveal_force_cwd<cr>
      -- nnoremap <leader>b :Neotree toggle show buffers right<cr>
      -- nnoremap <leader>s :Neotree float git_status<cr>
    }
  end,
}
