SelectListView = require atom.packages.resourcePath + '/src/select-list-view'
_ = require atom.packages.resourcePath + '/node_modules/underscore-plus'

module.exports =
class PackageListView extends SelectListView
  initialize: (@packageList, @confirmedCallback) ->
    super
    @addClass('package-list overlay from-top')
    @toggle()

  toggle: ->
    if @hasParent()
      @cancel()
    else
      @attach()

  getFilterKey: ->
    'name'

  attach: ->
    @storeFocusedElement()

    items = []
    for pack in @packageList
      items.push({name: pack.name, description: pack.metadata?.description})
    items = _.sortBy(items, 'name')
    @setItems(items)

    atom.workspaceView.append(this)
    @focusFilterEditor()

  viewForItem: ({name, description}) ->
    "<li>#{name}</li>"

  confirmed: ({name}) ->
    @cancel()
    @confirmedCallback(name)
