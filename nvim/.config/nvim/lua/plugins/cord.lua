return {
  "vyfor/cord.nvim",
  event = "VeryLazy", -- Load after Neovim startup
  build = ":Cord update", -- Fetch the Rust binary for Discord IPC
  config = function()
    require("cord").setup({
      -- Optional: Customize settings (defaults work for basic presence)
      idle = {
        enable = true,
        timeout = 5000, -- Show idle after 5s
        text = "Idling in Neovim 💤",
      },
      text = {
        workspace = false, -- Hide workspace name
      },
    })
  end,
}
