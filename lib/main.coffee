_ = require atom.packages.resourcePath + '/node_modules/underscore-plus'

PackageListView = null

configGet = (key) ->
  return atom.config.get 'package-manager-commands.' + key

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
  Module = module.constructor

  _.each require.cache, (module, path) ->
    if path.startsWith(modulePath)
      if delete require.cache[path]
        console.log 'Deleted require.cache["' + path + '"]' if configGet('logging') and configGet('logReloadedFiles')
  _.each Module._cache, (module, path) ->
    if path.startsWith(modulePath)
      if delete Module._cache[path]
        console.log 'Deleted Module._cache["' + path + '"]' if configGet('logging') and configGet('logReloadedFiles')


getProjectPackage = ->
  return false unless atom.project.getDirectories().length > 0
  projectPath = atom.project.getDirectories()[0].getPath().toLowerCase()
  for pack in atom.packages.getLoadedPackages()
    if pack.path.toLowerCase() is projectPath
      return pack

PackageManagerCommands =
  enablePackage: (packageName) ->
    atom.packages.enablePackage(packageName)
    console.log '[PackageManager] ', packageName, ' enabled.' if configGet('logging')

  reloadPackage: (packageName) ->
    console.log '[PackageManager] ', 'Reloading ', packageName if configGet('logging')
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
    console.log '[PackageManager] ', packageName, ' reloaded.' if configGet('logging')

  disablePackage: (packageName) ->
    atom.packages.disablePackage(packageName)
    console.log '[PackageManager] ', packageName, ' disabled.' if configGet('logging')

  packageSettings: (packageName) ->
    atom.workspace.open("atom://config").then ->
      settingsViewEl = document.querySelector(".settings-view")
      unless settingsViewEl
        console.error '[PackageManager] Could not find settings view.'
        return
      settingsViewEl.spacePenView.showPanel(packageName, {back: "Packages"})


module.exports =
  config:
    logReloadedFiles:
      type: 'boolean'
      default: false
    logging:
      type: 'boolean'
      default: false

  commandListenerDisposables: []

  activate: (state) ->
    if getProjectPackage()
      disposable = atom.commands.add 'atom-workspace', 'package-manager:reload-project-package', => @reloadProjectPackage()
      @commandListenerDisposables.push disposable

    disposable = atom.commands.add 'atom-workspace', 'package-manager:enable-package', => @openEnablePackageMenu()
    @commandListenerDisposables.push disposable

    disposable = atom.commands.add 'atom-workspace', 'package-manager:disable-package', => @openDisablePackageMenu()
    @commandListenerDisposables.push disposable

    disposable = atom.commands.add 'atom-workspace', 'package-manager:reload-package', => @openReloadPackageMenu()
    @commandListenerDisposables.push disposable

    disposable = atom.commands.add 'atom-workspace', 'package-manager:package-settings', => @openPackageSettingsMenu()
    @commandListenerDisposables.push disposable


  deactivate: ->
    for disposable in @commandListenerDisposables
      disposable.dispose()
    @commandListenerDisposables = []

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

  openPackageSettingsMenu: ->
    PackageListView ?= require './package-list-view'
    allPackages = (name: n for n in atom.packages.getAvailablePackageNames())
    new PackageListView allPackages, (packageName) ->
      PackageManagerCommands.packageSettings(packageName)
