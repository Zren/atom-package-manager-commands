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


getProjectPackage = ->
  return false unless atom.project.path
  projectPath = atom.project.path.toLowerCase()
  packagePaths = _.pluck atom.packages.getLoadedPackages(), 'path'
  packagePath = _.find packagePaths, (packagePath) ->
    return packagePath if packagePath.toLowerCase() is projectPath
  return _.findWhere atom.packages.getLoadedPackages(), {path: packagePath}

PackageManagerCommands =
  enablePackage: (packageName) ->
    atom.packages.enablePackage(packageName)
    console.log '[PackageManager] ', packageName, ' enabled.'

  reloadPackage: (packageName) ->
    console.log '[PackageManager] ', 'Reloading ', packageName
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
    console.log '[PackageManager] ', packageName, ' reloaded.'

  disablePackage: (packageName) ->
    atom.packages.disablePackage(packageName)
    console.log '[PackageManager] ', packageName, ' disabled.'


module.exports =
  activate: (state) ->
    atom.workspaceView.command 'package-manager:enable-package', => @openEnablePackageMenu()
    atom.workspaceView.command 'package-manager:reload-package', => @openReloadPackageMenu()
    atom.workspaceView.command 'package-manager:disable-package', => @openDisablePackageMenu()

    if getProjectPackage()
      atom.workspaceView.command 'package-manager:reload-project-package', => @reloadProjectPackage()

  deactivate: ->

  reloadProjectPackage: ->
    pack = getProjectPackage()
    return unless pack
    PackageManagerCommands.reloadPackage(pack.name)

  openEnablePackageMenu: ->
    PackageListView ?= require './package-list-view'
    new PackageListView getDisabledPackages(), (packageName) ->
      PackageManagerCommands.enablePackage(packageName)

  openReloadPackageMenu: ->
    PackageListView ?= require './package-list-view'
    new PackageListView atom.packages.getLoadedPackages(), (packageName) ->
      PackageManagerCommands.reloadPackage(packageName)

  openDisablePackageMenu: ->
    PackageListView ?= require './package-list-view'
    new PackageListView getEnabledPackages(), (packageName) ->
      PackageManagerCommands.disablePackage(packageName)
