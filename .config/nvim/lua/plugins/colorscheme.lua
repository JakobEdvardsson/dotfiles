return {
  "navarasu/onedark.nvim",
  priority = 1000,
  config = function()
    local helper = vim.fn.expand("~/.config/theme-sync/bin/kde-theme-mode")

    local function detect_mode_from_kde()
      if vim.fn.executable(helper) == 1 then
        local out = vim.fn.systemlist(helper)
        if vim.v.shell_error == 0 and out[1] == "dark" then
          return "dark"
        end
      end
      return "light"
    end

    local function refresh_ui()
      local ok_hl, bl_hl = pcall(require, "bufferline.highlights")
      local ok_cfg, bl_cfg = pcall(require, "bufferline.config")
      if ok_hl and ok_cfg then
        pcall(bl_hl.reset_icon_hl_cache)
        pcall(function()
          bl_hl.set_all(bl_cfg.update_highlights())
        end)
      end

      local bufferline_refresh = rawget(_G, "nvim_bufferline")
      if type(bufferline_refresh) == "function" then
        pcall(bufferline_refresh)
      end

      local ok_lualine, lualine = pcall(require, "lualine")
      if ok_lualine then
        pcall(lualine.refresh, { scope = "all" })
      end
      pcall(vim.cmd, "redrawtabline")
    end

    local function apply_mode(mode)
      if mode ~= "dark" and mode ~= "light" then
        return
      end
      if vim.g._theme_mode_applied == mode then
        return
      end

      vim.o.background = mode
      require("onedark").setup({ style = mode })
      require("onedark").load()
      pcall(vim.api.nvim_exec_autocmds, "ColorScheme", { modeline = false })
      vim.schedule(refresh_ui)
      vim.g._theme_mode_applied = mode
    end

    local function sync_mode_from_background()
      local mode = vim.o.background
      if vim.env.ZELLIJ then
        mode = detect_mode_from_kde()
      end
      apply_mode(mode)
    end

    sync_mode_from_background()
    vim.api.nvim_create_user_command("ThemeSync", sync_mode_from_background, {})
    vim.api.nvim_create_user_command("KdeThemeSync", sync_mode_from_background, {})

    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "background",
      group = vim.api.nvim_create_augroup("theme_sync", { clear = true }),
      callback = sync_mode_from_background,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      group = "theme_sync",
      callback = function()
        pcall(vim.api.nvim_ui_send, "\27[?2031h")
      end,
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = "theme_sync",
      callback = function()
        pcall(vim.api.nvim_ui_send, "\27[?2031l")
      end,
    })

    if vim.env.ZELLIJ then
      vim.api.nvim_create_autocmd({ "FocusGained", "VimResume", "BufEnter" }, {
        group = "theme_sync",
        callback = sync_mode_from_background,
      })
    end
  end,
}
