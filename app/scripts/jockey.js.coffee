jQuery ->
  searching = !!(location.pathname.match(/^\/search/))
  init_path = location.pathname
  query = null

  loading = (f) ->
    if f
      console.log("Loading")
      $("h1").text("Loading")
    else
      console.log("Loaded")
      $("h1").text("Jockey")

  enque_hook = ->
    $("a[data-pjax]").filter(-> !($(this).data('pjaxed'))).each ->
      $(this).data('pjaxed',true)
      $(this).pjax("#content")

    $("a.enque").click (e) ->
      e.preventDefault()
      link = this
      $.post '/api/enque', {id: $(this).data('song')}, ->
        $(link).text("✔").attr('href',null)
  enque_hook()

  realtime = new EventSource("/api/realtime?html=1")

  $(realtime).bind 'playing', (e) ->
    json = JSON.parse(e.originalEvent.data)
    $("#playing").html json.html
    $("#playing a[data-pjax]").pjax()

  $(realtime).bind 'upcoming', (e) ->
    json = JSON.parse(e.originalEvent.data)
    return if searching
    return unless location.pathname == "/"
    $("#content").html json.html
    enque_hook()

  $(realtime).bind 'history', (e) ->
    json = JSON.parse(e.originalEvent.data)
    return if searching
    return unless location.pathname == "/history"
    $("#content").html json.html
    enque_hook()

  do_search = ->
    if $("#search_box").val().length == 0 && searching
      searching = false
      history.back()
      return
    return if query == $("#search_box").val()
    query = $("#search_box").val()
    return if query.length < 3

    $.pjax({
      url: "/search?q=#{encodeURIComponent(query)}",
      container: '#content',
      timeout: 60000,
      push: !searching,
      replace: searching,
      success: ->
        searching = true
    })

  $("#search_form").submit (e) ->
    e.preventDefault()
    $("#search_box").blur()

  search_timer = null
  $("#search_box").keyup (e) ->
    unless e.keycode == 13
      clearTimeout search_timer if search_timer
      search_timer = setTimeout(do_search, 500)

  $(document).bind 'pjax:start', -> loading(true)
  $(document).bind 'pjax:success', ->
    searching = !!(location.pathname.match(/^\/search/))
    loading(false)
    enque_hook()
  # FIXME: Error handling


  $(window).bind 'pjax:popstate', (e) ->
    path = e.state.url.replace(location.origin,'')
    switch path
      when "/"
        $("#search_box").val('')
        $("#content").load '/?no_layout=1', enque_hook
        searching = false
      when "/history"
        $("#search_box").val('')
        $("#content").load '/history?no_layout=1', enque_hook
        searching = false

