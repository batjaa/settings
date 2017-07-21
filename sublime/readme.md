Sublime 3 configurations
========================

### Install [Package Controller](https://packagecontrol.io/installation)

1. Open console (View > Show Console)
2. Copy and run the following code (Python snippet)

   ```
   import urllib.request,os,hashlib; h = 'eb2297e1a458f27d836c04bb0cbaf282' + 'd0e7a3098092775ccb37ca9d6b2e4b7d'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try Mnual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
   ```

### Install the following plugins in no particular order

* [Trailing Spaces](https://github.com/SublimeText/TrailingSpaces)
* [JSHint](https://packagecontrol.io/packages/SublimeLinter-jshint)
  * (Sublime Linter)[http://sublimelinter.readthedocs.org/en/latest/installation.html] is required
* [JSCS](https://packagecontrol.io/packages/SublimeLinter-jscs)
* [AutoFileName](https://packagecontrol.io/packages/AutoFileName)
* [Afterglow](https://github.com/YabataDesign/afterglow-theme)
* Git
* GitGutter
* Alignment
* DocBlockr
* Sidebarenhancements
* [URLEncode](https://packagecontrol.io/packages/URLEncode)
* [SublimeLinter](http://sublimelinter.readthedocs.org/en/latest/installation.html)

### Set up default snippets

* Copy [default.sublime-snippet](https://github.com/batjaa/settings/blob/master/sublime/default.sublime-snippet) into `Packages->User`
  *Hint: Preferences -> Browser Packages*

### Settings

User settings

```json
// The number of spaces a tab is considered equal to
"tab_size": 2,
// Set to true to insert spaces when tab is pressed
"translate_tabs_to_spaces": true,
"theme": "Afterglow-orange.sublime-theme",
"color_scheme": "Packages/Theme - Afterglow/Afterglow.tmTheme"
"status_bar_brighter": true,
"show_full_path": true,
"tabs_small": true,
```

User key binding

```json
[
  { "keys": ["super+option+w"], "command": "close_workspace" },
  { "keys": ["super+shift+w"], "command": "close_all" }
]
```

### Quartzy

#### Packages

* [MavensMate](https://github.com/joeferraro/MavensMate-SublimeText)
* [PHP Companion](https://github.com/erichard/SublimePHPCompanion)
* [All AutoComplete](https://github.com/alienhard/SublimeAllAutocomplete)
* [SublimeLinter PHP](https://packagecontrol.io/packages/SublimeLinter-php)

#### Key bindings

```json
[
  // Override MavensMate defaults
  { "keys": ["super+shift+space"], "command": "expand_selection", "args": {"to": "scope"} },
  { "keys": ["super+shift+b"], "command": "expand_selection", "args": {"to": "brackets"} },
  { "keys": ["super+shift+d"], "command": "duplicate_line" },
  { "keys": ["super+k", "super+t"], "command": "title_case" },
  { "keys": ["control+shift+k"], "command": "run_macro_file", "args": {"file": "res://Packages/Default/Delete Line.sublime-macro"} },
  { "keys": ["ctrl+shift+r"], "command": "refresh_active_file" }, // Mavensmate Plugin Required
  { "keys": ["ctrl+shift+c"], "command": "clean_project" }, // Mavensmate Plugin Required
  { "keys": ["ctrl+shift+t"], "command": "run_apex_unit_tests" }, // Mavensmate Plugin Required
  { "keys": ["alt+up"], "command": "scroll_lines", "args": {"amount": 1.0} },
  { "keys": ["alt+down"], "command": "scroll_lines", "args": {"amount": -1.0} },

  // PHP Companion key bindings
  { "keys": ["f9"], "command": "expand_fqcn" },
  { "keys": ["shift+f9"], "command": "expand_fqcn", "args": {"leading_separator": true} },
  { "keys": ["f10"], "command": "find_use" },
  { "keys": ["f8"], "command": "import_namespace" },
  { "keys": ["shift+f12"], "command": "goto_definition_scope" },
]
```
