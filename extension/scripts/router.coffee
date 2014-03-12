class BH.Router extends Backbone.Router
  routes:
    '': 'reset'
    'tags': 'tags'
    'tags/:id': 'tag'
    'weeks/:id': 'week'
    'days/:id': 'day'
    'calendar': 'calendar'
    'settings': 'settings'
    'search/*query(/p:page)': 'search'
    'search': 'search'
    'today': 'today'

  initialize: (options) ->
    settings = options.settings
    tracker = options.tracker
    @state = options.state

    @app = new BH.Views.AppView
      el: $('.app')
      collection: new BH.Collections.Weeks()
      settings: settings
      state: @state
    @app.render()

    @on 'route', (route) =>
      tracker.pageView(Backbone.history.getFragment())
      window.scroll 0, 0
      if settings.get('openLocation') == 'last_visit'
        @state.set route: location.hash

    @reset if location.hash == ''

  reset: ->
    @navigate @state.get('route'), trigger: true

  tags: ->
    view = @app.loadTags()
    view.select()
    delay ->
      view.collection.fetch()

  tag: (id) ->
    view = @app.loadTag(id)
    view.select()
    delay ->
      view.model.fetch()

  calendar: ->
    view = @app.loadCalendar()
    view.select()

  week: (id) ->
    view = @app.loadWeek(id)
    view.select()
    delay ->
      new BH.Lib.WeekHistory(new Date(id)).fetch (history) ->
        view.collection.reset(history)

  day: (id) ->
    view = @app.loadDay id
    view.select()
    delay ->
      new BH.Lib.DayHistory(new Date(id)).fetch (history) ->
        view.collection.reset history

  today: ->
    id = moment(new Date()).id()
    view = @app.loadDay id
    view.select()
    delay ->
      new BH.Lib.DayHistory(new Date(id)).fetch (history) ->
        view.collection.reset history

  settings: ->
    view = @app.loadSettings()
    view.select()

  search: (query = '', page) ->
    # Load a fresh search view when the query is empty to
    # ensure a new WeekHistory instance is created because
    # this usually means a search has been canceled
    view = @app.loadSearch(expired: true if query == '' || page)
    view.page.set(page: parseInt(page, 10), {silent: true}) if page?
    view.model.set query: decodeURIComponent(query)
    view.select()
    delay ->
      if query != ''
        new BH.Lib.SearchHistory(query).fetch (history, cacheDatetime = null) ->
          view.collection.reset history
          if cacheDatetime?
            view.model.set cacheDatetime: cacheDatetime
          else
            view.model.unset 'cacheDatetime'

delay = (callback) ->
  setTimeout (-> callback()), 250
