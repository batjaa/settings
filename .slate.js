// Configs
S.cfga({
  'defaultToCurrentScreen': true,
  'secondsBetweenRepeat': 0.1,
  'checkDefaultsOnLoad': true,
  'focusCheckWidthMax': 3000,
  'orderScreensLeftToRight': true
});

// Monitors
var monitorLaptop = '1920x1200';
var monitorMain   = '2560x1440';

// Operations
var full = S.op("move", {
  x: 'screenOriginX',
  y: 'screenOriginY',
  width: 'screenSizeX',
  height: 'screenSizeY'
});
var leftHalf = full.dup({width: 'screenSizeX/2'});
var rightHalf = leftHalf.dup({x: 'screenOriginX+screenSizeX/2'});

var laptopFull = S.op('move', {
  'screen': monitorLaptop,
  'x': 'screenOriginX',
  'y': 'screenOriginY',
  'width': 'screenSizeX',
  'height': 'screenSizeY'
});
var laptopHalf = laptopFull.dup({'width': 'screenSizeX/2'})
var mainFull = S.op('move', {
  'screen': monitorMain,
  'x': 'screenOriginX',
  'y': 'screenOriginY',
  'width': 'screenSizeX',
  'height': 'screenSizeY'
});
var mainHalf = S.op('move', {
  'screen': monitorMain,
  'x': 'screenOriginX',
  'y': 'screenOriginY',
  'width': 'screenSizeX/2',
  'height': 'screenSizeY'
});
var mainThird = S.op('move', {
  'screen': monitorMain,
  'x': 'screenOriginX',
  'y': 'screenOriginY',
  'width': 'screenSizeX/3',
  'height': 'screenSizeY'
});
var mainFivth = S.op('move', {
  'screen': monitorMain,
  'x': 'screenOriginX',
  'y': 'screenOriginY',
  'width': 'screenSizeX/5',
  'height': 'screenSizeY'
});
var mainBig = S.op('move', {
  'screen': monitorMain,
  'x': 'screenOriginX',
  'y': 'screenOriginY',
  'width': 'screenSizeX*4/5 + 40',
  'height': 'screenSizeY',
});
var mainLeft = mainHalf.dup({});
var mainMid = mainFivth.dup({ 'x': 'screenOriginX+screenSizeX/5' });
var mainRight = mainHalf.dup({ 'x': 'screenOriginX+screenSizeX/2' });
var mainLeftTop = mainFivth.dup({ 'height': 'screenSizeY/2' });
var mainLeftBot = mainLeftTop.dup({ 'y': 'screenOriginY+screenSizeY/2' });
var mainMidTop = mainMid.dup({ 'height': 'screenSizeY/2' });
var mainMidBot = mainMidTop.dup({ 'y': 'screenOriginY+screenSizeY/2' });
var mainRightTop = mainLeftTop.dup({ 'x': 'screenOriginX+screenSizeX*4/5' });
var mainRightBot = mainRightTop.dup({ 'y': 'screenOriginY+screenSizeY/2' });

var brightness0 = S.op('shell', {
  command: '/usr/local/Cellar/brightness/1.2/bin/brightness 0',
});
var brightness4 = S.op('shell', {
  command: '/usr/local/Cellar/brightness/1.2/bin/brightness 0.4',
});
var brightness8 = S.op('shell', {
  command: '/usr/local/Cellar/brightness/1.2/bin/brightness 0.8',
});
var brightness10 = S.op('shell', {
  command: '/usr/local/Cellar/brightness/1.2/bin/brightness 1',
});

// common layout hashes
var laptopFullHash = {
  'operations': [laptopFull],
  'ignore-fail': true,
  'repeat': true
};
var laptopHalfHash = {
  'operations': [laptopHalf],
  'ignore-fail': true,
  'repeat': true
};
var mainFullHash = {
  'operations': [mainFull],
  'sort-title': true,
  'repeat': true
};
var mainBigHash = {
  'operations': [mainBig],
  'sort-title': true,
  'repeat': true
};
var mainHalfHash = {
  'operations': [mainHalf],
  'sort-title': true,
  'repeat': true
};
var genBrowserHash = function(regexRightTop, regexRightBot) {
  return {
    'operations': [function(windowObject) {
      var title = windowObject.title();
      if (title !== undefined) {
        if (title.match(regexRightTop)) {
          windowObject.doOperation(mainRightTop);
        } else if (title.match(regexRightBot)) {
          windowObject.doOperation(mainRightBot);
        } else {
          windowObject.doOperation(mainBig);
        }
      }
    }],
    'ignore-fail': true,
    'repeat': true
  };
}

// Laptop connected but mirroring layout
var externalMonitorOnly = S.lay('externalMonitorOnly', {
  'Slack': mainHalfHash,
  'iTerm2': mainBigHash,
  'Google Chrome': genBrowserHash(/^Developer\sTools\s-\s.+$/, /YouTube/),
  'Spotify': mainHalfHash,
  'Sublime Text': mainBigHash,
  'PhpStorm': mainBigHash,
});

// 1 monitor layout
var laptopLayout = S.lay('laptopLayout', {
  'Slack': laptopHalfHash,
  'iTerm2': laptopFullHash,
  'Google Chrome': laptopFullHash,
  'Spotify': laptopHalfHash,
  'Sublime Text': laptopFullHash,
  'PhpStorm': laptopFullHash,
});

// Layout Operations
// var twoMonitor = S.op('layout', { 'name': twoButOneMonitorLayout });
var externalMonitor = S.op('layout', { 'name': externalMonitorOnly });
var oneMonitor = S.op('layout', { 'name': laptopLayout });

function mirroringSetup() {
  externalMonitor.run();
  brightness0.run();
}

function laptopSetup() {
  oneMonitor.run();
  brightness8.run();
}

// Defaults
// S.def(2, twoButOneMonitorLayout);
S.def(['2560x1440'], mirroringSetup);
S.def(['1920x1200'], laptopSetup);

var universalLayout = function() {
  // Should probably make sure the resolutions match but w/e
  S.log('SCREEN COUNT: ' + S.screenCount());
  if (S.screenCount() === 2) {
    twoMonitor.run();
  } else if (S.screenCount() === 1) {
    if (slate.screenForRef(0).rect().width >= 2560) {
      mirroringSetup();
    } else {
      laptopSetup();
    }
  }
};

// Batch bind everything. Less typing.
S.bnda({
  // Layout Bindings
  'padEnter:ctrl': universalLayout,

  'esc:alt':     S.op('focus', { 'app': 'Spotify' }),
  '1:alt':       S.op('focus', { 'app': 'Finder' }),
  '2:alt':       S.op('focus', { 'app': 'iTerm2' }),
  '3:alt':       S.op('focus', { 'app': 'Google Chrome' }),
  '4:alt':       S.op('focus', { 'app': 'Sublime Text' }),
  '4:alt;shift': S.op('focus', { 'app': 'PhpStorm' }),
  '5:alt':       S.op('focus', { 'app': 'Slack' }),

  // Basic Location Bindings
  // 'pad0:ctrl': lapChat,
  // '[:ctrl': lapChat,
  // 'pad.:ctrl': lapMain,
  // ']:ctrl': lapMain,
  'pad1:ctrl': mainLeftBot,
  'pad2:ctrl': mainMidBot,
  'pad3:ctrl': mainRightBot,
  'pad4:ctrl': mainLeft,
  'pad5:ctrl': mainBig,
  'pad6:ctrl': mainRight,
  'pad7:ctrl': mainLeftTop,
  'pad8:ctrl': mainMidTop,
  'pad9:ctrl': mainRightTop,
  // 'pad=:ctrl': tboltFull,

  // Resize Bindings
  // NOTE: some of these may *not* work if you have not removed the expose/spaces/mission control bindings
  'right:ctrl;alt': rightHalf,
  'left:ctrl;alt': leftHalf,
  'up:ctrl;alt': full,
  // 'down:ctrl;alt': S.op('resize', { 'width': '+0', 'height': '+10%' }),
  'right:ctrl;alt;shift': S.op('resize', { 'width': '+10%' }),
  'left:ctrl;alt;shift': S.op('resize', { 'width': '-10%' }),
  // 'up:alt': S.op('resize', { 'width': '+0', 'height': '+10%', 'anchor': 'bottom-right' }),
  // 'down:alt': S.op('resize', { 'width': '+0', 'height': '-10%', 'anchor': 'bottom-right' }),

  // Push Bindings
  // NOTE: some of these may *not* work if you have not removed the expose/spaces/mission control bindings
  // 'right:ctrl;shift': S.op('push', { 'direction': 'right', 'style': 'bar-resize:screenSizeX/2' }),
  // 'left:ctrl;shift': S.op('push', { 'direction': 'left', 'style': 'bar-resize:screenSizeX/2' }),
  // 'up:ctrl;shift': S.op('push', { 'direction': 'up', 'style': 'bar-resize:screenSizeY/2' }),
  // 'down:ctrl;shift': S.op('push', { 'direction': 'down', 'style': 'bar-resize:screenSizeY/2' }),

  // Nudge Bindings
  // NOTE: some of these may *not* work if you have not removed the expose/spaces/mission control bindings
  // 'right:ctrl;alt': S.op('nudge', { 'x': '+10%', 'y': '+0' }),
  // 'left:ctrl;alt': S.op('nudge', { 'x': '-10%', 'y': '+0' }),
  // 'up:ctrl;alt': S.op('nudge', { 'x': '+0', 'y': '-10%' }),
  // 'down:ctrl;alt': S.op('nudge', { 'x': '+0', 'y': '+10%' }),

  // Throw Bindings
  // NOTE: some of these may *not* work if you have not removed the expose/spaces/mission control bindings
  // 'pad1:ctrl;alt': S.op('throw', { 'screen': '2', 'width': 'screenSizeX', 'height': 'screenSizeY' }),
  // 'pad2:ctrl;alt': S.op('throw', { 'screen': '1', 'width': 'screenSizeX', 'height': 'screenSizeY' }),
  // 'pad3:ctrl;alt': S.op('throw', { 'screen': '0', 'width': 'screenSizeX', 'height': 'screenSizeY' }),
  // 'right:ctrl;alt;cmd': S.op('throw', { 'screen': 'right', 'width': 'screenSizeX', 'height': 'screenSizeY' }),
  // 'left:ctrl;alt;cmd': S.op('throw', { 'screen': 'left', 'width': 'screenSizeX', 'height': 'screenSizeY' }),
  // 'up:ctrl;alt;cmd': S.op('throw', { 'screen': 'up', 'width': 'screenSizeX', 'height': 'screenSizeY' }),
  // 'down:ctrl;alt;cmd': S.op('throw', { 'screen': 'down', 'width': 'screenSizeX', 'height': 'screenSizeY' }),

  // Focus Bindings
  // NOTE: some of these may *not* work if you have not removed the expose/spaces/mission control bindings
  // 'l:cmd': S.op('focus', { 'direction': 'right' }),
  // 'h:cmd': S.op('focus', { 'direction': 'left' }),
  // 'k:cmd': S.op('focus', { 'direction': 'up' }),
  // 'j:cmd': S.op('focus', { 'direction': 'down' }),
  // 'k:cmd;alt': S.op('focus', { 'direction': 'behind' }),
  // 'j:cmd;alt': S.op('focus', { 'direction': 'behind' }),
  // 'right:cmd': S.op('focus', { 'direction': 'right' }),
  // 'left:cmd': S.op('focus', { 'direction': 'left' }),
  // 'up:cmd': S.op('focus', { 'direction': 'up' }),
  // 'down:cmd': S.op('focus', { 'direction': 'down' }),
  // 'up:cmd;alt': S.op('focus', { 'direction': 'behind' }),
  // 'down:cmd;alt': S.op('focus', { 'direction': 'behind' }),

  // Window Hints
  'esc:cmd': S.op('hint'),

  // Switch currently doesn't work well so I'm commenting it out until I fix it.
  //'tab:cmd': S.op('switch'),

  'r:cmd;alt': S.op('relaunch'),

  // Grid
  'esc:ctrl': function() {
    var gridOption = { grids: {} };
    gridOption.grids[monitorMain] = { width: 5, height: 4 };

    S.op('grid', gridOption).run();
  },
});

// Log that we're done configuring
S.log('[SLATE] -------------- Finished Loading Config --------------');