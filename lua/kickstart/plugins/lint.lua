return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
      }

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      local disabled_ft = { markdown = true }

      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if not disabled_ft[vim.bo.filetype] and vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })

      vim.api.nvim_create_user_command('LintToggle', function()
        local ft = vim.bo.filetype
        if ft == '' then
          vim.notify('No filetype on current buffer', vim.log.levels.WARN)
          return
        end
        if disabled_ft[ft] then
          disabled_ft[ft] = nil
          lint.try_lint()
          vim.notify('Linting enabled for ' .. ft, vim.log.levels.INFO)
        else
          disabled_ft[ft] = true
          vim.diagnostic.reset(nil, 0)
          vim.notify('Linting disabled for ' .. ft, vim.log.levels.INFO)
        end
      end, { desc = 'Toggle nvim-lint for current filetype' })

      vim.keymap.set('n', '<leader>tL', '<cmd>LintToggle<cr>', { desc = '[T]oggle [L]int' })
    end,
  },
}
