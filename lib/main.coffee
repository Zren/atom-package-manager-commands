_ = require atom.packages.resourcePath + '/node_modules/underscore-plus'

PackageListView = null
Module = null

getDisabledPackageNames = ->
  return atom.config.get('core.disabledPackages')

getDisabledPackages = ->
  return _.map getDisabledPackageNames(), (packageName) ->
    return { name: packageName }

getEnabledPackages = ->
  disabledPackageNames = getDisabledPackageNames()
  return _.filter atom.packages.getLoadedPackages(), (pack) ->
    return not _.contains(disabledPackageNames, pack.name)

isDisabledPackage = (packageName) ->
  return _.contains(getDisabledPackageNames(), packageName)

clearModuleCache = (modulePath) ->
  Module ?= module.constructor

  _.each require.cache, (module, path) ->
    if path.startsWith(modulePath)
      if delete require.cache[path]
        console.log 'Deleted require.cache["' + path + '"]'
  _.each Module._cache, (module, path) ->
    if path.startsWith(modulePath)
      if delete Module._cache[path]
        console.log 'Deleted Module._cache["' + path + '"]'

PackageManagerCommands =
  reloadPackage: (packageName) ->

    pack = atom.packages.getLoadedPackage(packageName)
    packagePath = pack.path
    packageActive = atom.packages.isPackageActive(packageName)
    if packageActive
      atom.packages.deactivatePackage packageName
    atom.packages.unloadPackage packageName
    clearModuleCache packagePath
    atom.packages.loadPackage packageName
    if packageActive
      atom.packages.activatePackage packageName

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'package-manager:enable-package', => @openEnablePackageMenu()
    atom.workspaceView.command 'package-manager:reload-package', => @openReloadPackageMenu()
    atom.workspaceView.command 'package-manager:disable-package', => @openDisablePackageMenu()

  deactivate: ->

  openEnablePackageMenu: =>
    PackageListView ?= require './package-list-view'
    new PackageListView getDisabledPackages(), (packageName) ->
      atom.packages.enablePackage(packageName)
      console.log '[PackageManager] ', packageName, ' enabled.'

  openReloadPackageMenu: =>
    PackageListView ?= require './package-list-view'
    new PackageListView atom.packages.getLoadedPackages(), (packageName) ->
      console.log '[PackageManager] ', 'Reloading ', packageName
      PackageManagerCommands.reloadPackage(packageName)
      console.log '[PackageManager] ', packageName, ' reloaded.'

  openDisablePackageMenu: =>
    PackageListView ?= require './package-list-view'
    new PackageListView getEnabledPackages(), (packageName) ->
      atom.packages.disablePackage(packageName)
      console.log '[PackageManager] ', packageName, ' disabled.'
