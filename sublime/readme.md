Sublime 3 configurations
========================

### Settings

```json
// The number of spaces a tab is considered equal to
"tab_size": 2,
// Set to true to insert spaces when tab is pressed
"translate_tabs_to_spaces": true,
```

### Install [Package Controller](https://packagecontrol.io/installation)

1. Open console (View > Show Console)
2. Copy and run the following code (Python snippet)

   ```
   import urllib.request,os,hashlib; h = 'eb2297e1a458f27d836c04bb0cbaf282' + 'd0e7a3098092775ccb37ca9d6b2e4b7d'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
   ```

### Install the following plugins in no particular order

* [Trailing Spaces](https://github.com/SublimeText/TrailingSpaces)

### Set up default snippets

* Copy [default.sublime-snippet](https://github.com/batjaa/settings/blob/master/sublime/default.sublime-snippet) into `Packages->User`
  *Hint: Preferences -> Browser Packages*
