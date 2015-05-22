{SelectListView} = require atom.packages.resourcePath + '/node_modules/atom-space-pen-views'
_ = require atom.packages.resourcePath + '/node_modules/underscore-plus'

module.exports =
class PackageListView extends SelectListView
  initialize: (@packageList, @confirmedCallback) ->
    super
    @addClass('package-list overlay from-top')
    @show()

  toggle: ->
    if @panel?.isVisible()
      @cancel()
    else
      @show()

  getFilterKey: ->
    'name'

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()

    items = []
    for pack in @packageList
      items.push({name: pack.name, description: pack.metadata?.description})
    items = _.sortBy(items, 'name')
    @setItems(items)

    @focusFilterEditor()

  viewForItem: ({name, description}) ->
    "<li>#{name}</li>"

  confirmed: ({name}) ->
    @cancel()
    @confirmedCallback(name)

  cancelled: ->
    @panel.destroy()
