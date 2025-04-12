return {
  -- AI-powered coding, seamlessly in Neovim
  'olimorris/codecompanion.nvim',
  config = function()
    local fmt = string.format

    local constants = {
      LLM_ROLE = 'llm',
      USER_ROLE = 'user',
      SYSTEM_ROLE = 'system',
    }
    require('codecompanion').setup {
      adapters = {
        xai = function()
          return require('codecompanion.adapters').extend('xai', {
            schema = {
              model = {
                default = 'grok-3-latest',
              },
            },
          })
        end,
      },
      strategies = {
        inline = {
          adapter = 'xai',
        },
        cmd = {
          adapter = 'xai',
        },
        chat = {
          adapter = 'xai',
          slash_commands = {
            ['file'] = {
              -- Location to the slash command in CodeCompanion
              callback = 'strategies.chat.slash_commands.file',
              description = 'Select a file using Telescope',
              opts = {
                provider = 'telescope',
                contains_code = true,
              },
            },
          },
        },
      },
      display = {
        action_palette = {
          provider = 'telescope',
          opts = {
            show_default_actions = true,
            show_default_prompt_library = true,
          },
        },
        diff = {
          provider = 'mini_diff',
        },
      },
      prompt_library = {
        ['TDD Elixir workflow'] = {
          strategy = 'workflow',
          description = 'Use a TDD workflow to repeatedly edit then test code',
          prompts = {
            {
              {
                name = 'Setup Test',
                role = constants.USER_ROLE,
                opts = { auto_submit = false },
                content = function()
                  -- Enable turbo mode!!!
                  vim.g.codecompanion_auto_tool_mode = true

                  return [[### Instructions

Your instructions here

### Steps to Follow

You are required to write code following the instructions provided above and test the correctness by running the designated test suite. Follow these steps exactly:

1. Use the @cmd_runner tool to run the test suite with `mix test` (do this before you have updated the code).
2. Update the code in #buffer{watch} using the @editor tool based on the test failure message
3. Make sure you trigger both tools in the same response

Notes
1. You should normally only run the test for the test file in the buffer `mix test test/some/particular/file_test.exs`
2. Make the smallest change possible to resolve the test failure message.  Do not try to one shot the solution.
3. Do not leave a new line at the end of the file

We'll repeat this cycle until the tests pass. Ensure no deviations from these steps.]]
                end,
              },
            },
            {
              {
                name = 'Repeat On Failure',
                role = constants.USER_ROLE,
                opts = { auto_submit = true },
                -- Scope this prompt to the cmd_runner tool
                condition = function()
                  return vim.g.codecompanion_current_tool == 'cmd_runner'
                end,
                -- Repeat until the tests pass, as indicated by the testing flag
                -- which the cmd_runner tool sets on the chat buffer
                repeat_until = function(chat)
                  return chat.tool_flags.testing == true
                end,
                content = 'The tests have failed. Can you edit the buffer using the test failure message making the smallest change possible and run the test suite again?',
              },
            },
          },
        },
      },
    }
    vim.keymap.set({ 'n', 'v' }, '<Leader>la', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true, desc = 'Open CodeCompanion Action Palette' })
    vim.keymap.set({ 'n', 'v' }, '<Leader>ll', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true, desc = 'Toggle CodeCompanion Chat' })
    vim.keymap.set('v', 'ga', '<cmd>CodeCompanionChat Add<cr>', { noremap = true, silent = true, desc = 'Add selection to CodeCompanion Chat' })

    -- Expand 'cc' into 'CodeCompanion' in the command line
    vim.cmd [[cab cc CodeCompanion]]
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
}
