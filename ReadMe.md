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
