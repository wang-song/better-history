class BH.Views.SearchResultsView extends Backbone.View
  template: BH.Templates['search_results']

  events:
    'click .delete_visit': 'deleteClicked'

  render: ->
    collectionToTemplate = @model.toTemplate()

    highlightedVisits = for visit in collectionToTemplate.visits
      @markMatches(visit)

    collectionToTemplate.visits = highlightedVisits
    properties = _.extend @getI18nValues(), collectionToTemplate
    @$el.html(@renderTemplate(properties))
    @assignTabIndices('.visit a:first-child')
    @

  markMatches: (visit) ->
    regExp = titleMatch = locationMatch = timeMatch = null

    for term in @model.get('query').split(' ')
      regExp = new RegExp(term, "i")
      visit.title = @_wrapMatchInProperty(regExp, visit.title)
      visit.location = @_wrapMatchInProperty(regExp, visit.location)
      visit.time = @_wrapMatchInProperty(regExp, visit.time)
    visit

  _wrapMatchInProperty: (regExp, property, match) ->
    match = property.match(regExp)
    if match then property.replace(regExp, '<span class="match">' + match + '</span>') else property


  deleteClicked: (ev) ->
    ev.preventDefault()
    model = @_getModelFromElement($(ev.target))
    model.destroy
      success: => @_getElementFromModel(model).remove()

  _getModelFromElement: (element) ->
    @collection.get($(element).prev().data('id'))

  _getElementFromModel: (model) ->
    $("[data-id='#{model.id}']").parents('li')

  getI18nValues: ->
    @i18nFetcher.get ['no_visits_found']
