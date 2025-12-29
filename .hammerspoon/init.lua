-- Hammerspoon Configuration
-- Compatible with macOS Sequoia/Tahoe
-- Keybindings designed to avoid conflicts with macOS defaults
-- Make sure to run .macos script to disable conflicting system shortcuts

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
Install=spoon.SpoonInstall
Install.use_syncinstall = true

-- Common modifiers
-- Using Ctrl+Alt+Cmd combination to avoid conflicts with most macOS shortcuts
hyper = { "cmd", "alt", "ctrl", "shift" }  -- Used for system options menu
super = { "cmd", "alt", "ctrl" }           -- Used for window management
ctrl = { "ctrl" }                          -- Used for grid
option = { "alt" }                         -- Used for app launching
optionShift = { "alt", "shift" }           -- Used for app launching

-- Performance settings
hs.window.animationDuration = 0;
hs.application.enableSpotlightForNameSearches(true)

-- Function to check if hotkey might conflict with system shortcuts
function checkHotkeyConflict(mods, key)
  local systemAssigned = hs.hotkey.systemAssigned(mods, key)
  if systemAssigned then
    hs.alert.show(string.format("Warning: %s + %s conflicts with system shortcut", 
      table.concat(mods, "+"), key))
  end
end

-- screens
local screens = hs.screen.allScreens()
local primary_screen, other_screen = screens[1], screens[2]

-- print table helper
function tprint(tbl, indent)
  if not indent then
    indent = 0
  end
  for k, v in pairs(tbl) do
    formatting = string.rep('  ', indent) .. k .. ': '
    if type(v) == 'table' then
      print(formatting)
      tprint(v, indent + 1)
    else
      print(formatting .. tostring(v))
    end
  end
end

-- helper function for getting an App's Bundle ID
function getAppId(app)
  return hs.application.infoForBundlePath(string.format('/Applications/%s.app', app))['CFBundleIdentifier']
end

-- Reload Hammerspoon Configuration
-- Using Ctrl+Alt+Cmd+R (safe, no known conflicts)
hs.hotkey.bind(super, "R", function()
  hs.alert.show("Reloading Hammerspoon...")
  hs.reload()
end)
hs.alert.show("Hammerspoon Config loaded")

-- Window Grid for manual positioning
-- Using Ctrl+Escape (safe, no known system conflicts)
-- This allows you to manually position windows on a grid
Install:andUse("WindowGrid",
  {
    config = { gridGeometries = { { "4x3" } } },
    hotkeys = {show_grid = {ctrl, "escape"}},
    start = true
  }
)

-- Window Management with ShiftIt
-- Using Ctrl+Alt+Cmd (super) modifier to avoid conflicts
-- macOS Mission Control shortcuts (disabled in .macos script):
--   Ctrl+Up: Mission Control
--   Ctrl+Down: Application Windows
--   Ctrl+Left/Right: Move between Spaces
-- Our shortcuts use Ctrl+Alt+Cmd which is rarely used by system
Install.repos.ShiftIt = {
  url = "https://github.com/peterklijn/hammerspoon-shiftit",
  desc = "ShiftIt spoon repository",
  branch = "master",
}
Install:andUse("ShiftIt",
  {
    repo = "ShiftIt",
    hotkeys = {
      left = {super, 'left' },       -- Move window to left half
      right = {super, 'right' },     -- Move window to right half
      up = {super, '5' },            -- Move window to top half
      down = {super, '6' },          -- Move window to bottom half
      upleft = {super, '1' },        -- Move window to top-left quarter
      upright = {super, '2' },       -- Move window to top-right quarter
      botleft = {super, '3' },       -- Move window to bottom-left quarter
      botright = {super, '4' },      -- Move window to bottom-right quarter
      maximum = {super, 'up' },      -- Maximize window
      toggleFullScreen = {super, 'f' },  -- Toggle fullscreen
      toggleZoom = {super, 'z' },    -- Zoom window
      center = {super, 'c' },        -- Center window
      nextScreen = {super, 'n' },    -- Move to next screen
      previousScreen = {super, 'p' }, -- Move to previous screen
      resizeOut = {super, '=' },     -- Increase window size
      resizeIn = {super, '-' }       -- Decrease window size
    }
  }
)

-- local fullApps = {
--   "Safari","Aurora","Nightly","Xcode","Qt Creator","Google Chrome","Papers 3.4.2", "ReadKit",
--   "Google Chrome Canary", "Eclipse", "Coda 2", "iTunes", "Emacs", "Firefox", "Sublime Text"
-- }
-- local layout2 = {
--   Airmail = {1, gomiddle},
--   Spotify = {1, gomiddle},
--   Calendar = {1, gomiddle},
--   Messenger = {1, gomiddle},
--   Messages = {1, gomiddle},
--   Dash = {1, gomiddle},
--   Spark = {1, gomiddle},
--   Tweetbot = {1, goleft},
--   ["iTerm2"] = {2, goright},
--   MacRanger = {2, goleft},
--   ["Path Finder"] = {2, goleft},
--   Mail = {2, goright},
-- }
-- fnutils.each(fullApps, function(app) layout2[app] = {1, gobig} end)
-- local layout2fn = applyLayout(layout2)

-- Quick App Launcher
-- Using Option (Alt) + Number for quick app access
-- Potential conflicts (disabled in .macos):
--   Option+Cmd+D: Show/Hide Dock
-- Note: Option+numbers are generally safe from system conflicts
Install:andUse("AppLauncher",
  {
    config = { modifiers = option },
    hotkeys = {
      ["escape"] = "Spotify",      -- Option+Esc: Spotify
      ["1"] = "Finder",             -- Option+1: Finder
      ["2"] = "iTerm",              -- Option+2: iTerm
      ["3"] = "Google Chrome",      -- Option+3: Chrome
      ["4"] = "Sublime Text",       -- Option+4: Sublime Text (or "Cursor")
      ["5"] = "Slack",              -- Option+5: Slack
      ["6"] = "TablePlus",          -- Option+6: Database tool (if installed)
    }
  }
)
Install:andUse("AppLauncher",
  {
    config = { modifiers = optionShift },
    hotkeys = {
      ["2"] = "TradingView",
      ["3"] = "Discord",
    }
  }
)

-- System Options Menu (Hyper+O = Cmd+Alt+Ctrl+Shift+O)
-- Using Hyper key to avoid any potential conflicts
-- This is a safe combination as it requires all 4 modifiers
hs.hotkey.bind(hyper, 'o', nil, function()
  local actions = {
    ['Lock Screen'] = function()
      hs.caffeinate.lockScreen()
    end,
    ['Sleep'] = function()
      hs.caffeinate.systemSleep()
    end,
    ['Show Current App'] = function()
      local app = hs.application.frontmostApplication()
      hs.alert.show(string.format("%s\nBundle ID: %s", 
        app:name(), app:bundleID()), nil, hs.screen.primaryScreen())
    end,
    ['Show Displays'] = function()
      local screens = hs.screen.allScreens()
      for i, screen in ipairs(screens) do
        print(string.format("Display %d: %s (%dx%d)", 
          i, screen:name(), screen:frame().w, screen:frame().h))
      end
      hs.alert.show(string.format("%d display(s) connected", #screens))
    end,
    ['Check Hotkey Conflicts'] = function()
      -- Check common Hammerspoon hotkeys for conflicts
      local hotkeys = {
        {super, "left", "Window Left"},
        {super, "right", "Window Right"},
        {option, "1", "Launch Finder"},
        {ctrl, "escape", "Show Grid"},
      }
      for _, hk in ipairs(hotkeys) do
        local result = hs.hotkey.systemAssigned(hk[1], hk[2])
        if result then
          print(string.format("⚠️  %s (%s+%s) conflicts with system", 
            hk[3], table.concat(hk[1], "+"), hk[2]))
        else
          print(string.format("✓ %s (%s+%s) is safe", 
            hk[3], table.concat(hk[1], "+"), hk[2]))
        end
      end
      hs.alert.show("Conflict check complete (see console)")
    end,
    ['Reload Hammerspoon'] = function()
      hs.reload()
    end,
  }

  local options = {}
  for key, _ in pairs(actions) do
    options[#options + 1] = { text = key }
  end

  local chooser = hs.chooser.new(function(choice)
    actions[choice.text]()
  end)
  chooser:choices(options)
  chooser:show()
end)

-- Caffeine replacement - Keep Mac awake while working
-- Useful during stock trading or long dev sessions
local caffeine = hs.menubar.new()
local function setCaffeineDisplay(state)
  if state then
    caffeine:setTitle("☕")
    caffeine:setTooltip("Awake - Click to sleep")
  else
    caffeine:setTitle("💤")
    caffeine:setTooltip("Sleepy - Click to stay awake")
  end
end

local function caffeineClicked()
  setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
  caffeine:setClickCallback(caffeineClicked)
  setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

-- Auto-reload config when files change
function reloadConfig(files)
  local doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end
local myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config loaded - auto-reload enabled")

-- Quick system info display (useful for monitoring during heavy dev/trading)
-- Press Cmd+Alt+Ctrl+I to see system stats
hs.hotkey.bind(super, "i", function()
  local battery = hs.battery.percentage()
  local powerSource = hs.battery.powerSource()
  local cpuUsage = hs.host.cpuUsage()
  
  local info = string.format(
    "Battery: %d%% (%s)\nCPU Usage: %f%%",
    battery,
    powerSource,
    cpuUsage.overall.active
  )
  
  hs.alert.show(info, 5)
end)
