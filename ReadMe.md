Package Manager Commands
========================

Adds commands to enable/disable/reload a package from the command palette.

Commands
--------

* **Package Manager: Enabled Package** `package-manager:enable-package` Lists all disabled packages to enable.
* **Package Manager: Disable Package** `package-manager:disable-package` Lists all enabled packages to disable.
* **Package Manager: Reload Package** `package-manager:reload-package` Lists all loaded packages to reload.
* **Package Manager: Reload Project Package** `package-manager:reload-project-package` Quick access to reload the current package being worked on. This command is only visible if the project root matches the package path.

How Does Reloading Work?
------------------------

* We first deactivate the package if it's activated.
* Then we unload it.
* We delete all modules in `require.cache` and `Module._cache` that start with the `package.path`.
* Load the package.
* Activate the package only if it was activated beforehand.
