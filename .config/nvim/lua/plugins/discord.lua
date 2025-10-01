return {
  {
    'vyfor/cord.nvim',
    event = 'VeryLazy', -- Load the plugin when Neovim is nearly finished loading
    build = ':Cord update', -- Command to run after installation/updates to fetch the Rust binary
    config = function()
      require('cord').setup {
        -- Your configuration options go here.
        -- See the 'cord.nvim' documentation for all available options.
        -- A minimal example:
        -- presence_timeout = 10, -- Timeout in seconds before activity is cleared (default: 10)
        -- client_id = 'YOUR_DISCORD_APPLICATION_ID', -- Optional: Use your own custom Discord app ID
        -- For custom images based on file types, explore the 'assets' options
      }
    end,
  },
}
