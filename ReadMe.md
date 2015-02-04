Package Manager Commands
========================

Adds commands to enable/disable/reload a package from the command palette.

Commands
--------

* **Package Manager: Enabled Package**
  Lists all disabled packages to enable.  
  `package-manager:enable-package`
* **Package Manager: Disable Package**
  Lists all enabled packages to disable.  
  `package-manager:disable-package`
* **Package Manager: Reload Package**
  Lists all loaded packages to reload.  
  `package-manager:reload-package`
* **Package Manager: Package Settings**
  List all packages to open the settings page for that particular package.  
  `package-manager:package-settings`
* **Package Manager: Reload Project Package**
  Quick access to reload the current package being worked on. This command is only visible if the project root matches the package path.  
  `package-manager:reload-project-package`

How Does Reloading Work?
------------------------

* We first deactivate the package if it's activated.
* Then we unload it.
* We delete all modules in `require.cache` and `Module._cache` that start with the `package.path`.
* Load the package.
* Activate the package only if it was activated beforehand.

Tips
----

* Bind `Ctrl+R` to `package-manager:reload-project-package` by going to `File > Open Your Keymap` and pasting the following. It will overload the [symbols-view](https://github.com/atom/symbols-view/blob/master/keymaps/symbols-view.cson) keymappings.
  ```coffeescript
  '.platform-darwin .editor':
    'cmd-r': 'package-manager:reload-project-package'

  '.platform-win32 .editor':
    'ctrl-r': 'package-manager:reload-project-package'

  '.platform-linux .editor':
    'ctrl-r': 'package-manager:reload-project-package'

  '.platform-darwin':
    'cmd-R': 'package-manager:reload-project-package'

  '.platform-win32, .platform-linux':
    'ctrl-R': 'package-manager:reload-project-package'
  ```
