hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
Install=spoon.SpoonInstall
Install.use_syncinstall = true

-- Common

hyper = { "cmd", "alt", "ctrl", "shift" }
ctrl = { "ctrl" }
option = { "alt" }
hs.window.animationDuration = 0;
hs.application.enableSpotlightForNameSearches(true)

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

-- Reload
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")

-- Cofigure grid
Install:andUse("WindowGrid",
  {
    config = { gridGeometries = { { "4x3" } } },
    hotkeys = {show_grid = {ctrl, "escape"}},
    start = true
  }
)

Install.repos.ShiftIt = {
  url = "https://github.com/peterklijn/hammerspoon-shiftit",
  desc = "ShiftIt spoon repository",
  branch = "master",
}
Install:andUse("ShiftIt",
  {
    repo = "ShiftIt",
    hotkeys = {
      left = {{ 'ctrl', 'alt', 'cmd' }, 'left' },
      right = {{ 'ctrl', 'alt', 'cmd' }, 'right' },
      up = {{ 'ctrl', 'alt', 'cmd' }, '5' },
      down = {{ 'ctrl', 'alt', 'cmd' }, '6' },
      upleft = {{ 'ctrl', 'alt', 'cmd' }, '1' },
      upright = {{ 'ctrl', 'alt', 'cmd' }, '2' },
      botleft = {{ 'ctrl', 'alt', 'cmd' }, '3' },
      botright = {{ 'ctrl', 'alt', 'cmd' }, '4' },
      maximum = {{ 'ctrl', 'alt', 'cmd' }, 'up' },
      toggleFullScreen = {{ 'ctrl', 'alt', 'cmd' }, 'f' },
      toggleZoom = {{ 'ctrl', 'alt', 'cmd' }, 'z' },
      center = {{ 'ctrl', 'alt', 'cmd' }, 'c' },
      nextScreen = {{ 'ctrl', 'alt', 'cmd' }, 'n' },
      previousScreen = {{ 'ctrl', 'alt', 'cmd' }, 'p' },
      resizeOut = {{ 'ctrl', 'alt', 'cmd' }, '=' },
      resizeIn = {{ 'ctrl', 'alt', 'cmd' }, '-' }
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

-- launch and focus applications
Install:andUse("AppLauncher",
  {
    config = { modifiers = option },
    hotkeys = {
      ["escape"] = "Spotify",
      ["1"] = "Finder",
      ["2"] = "iTerm",
      ["3"] = "Google Chrome",
      ["4"] = "Sublime Text",
      ["5"] = "Slack",
    }
  }
)

-- Random hammerspoon/system options to view
hs.hotkey.bind(hyper, 'o', nil, function()
  local actions = {
    lock = function()
      hs.osascript.applescriptFromFile 'lockScreen.applescript'
    end,
    sleep = function()
      os.execute 'pmset sleepnow'
    end,
    ['Show current app name'] = function()
      hs.alert.show(hs.application.frontmostApplication():name(), nil, hs.screen.primaryScreen())
    end,
    ['mouse buttons'] = function()
      tprint(hs.mouse.getButtons())
    end,
    ['px to em'] = function(s)
      tprint(s)
      hs.alert.show 'testing'
    end,
    ['Show current applications'] = function()
      tprint(hs.application.runningApplications())
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
