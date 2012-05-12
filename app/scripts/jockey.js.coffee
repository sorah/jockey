jQuery ->
  searching = !!(location.pathname.match(/^\/search/))
  notification = false
  init_path = location.pathname
  query = null

  loading = (f) ->
    if f
      console.log("Loading")
      $("h1").text("Loading")
    else
      console.log("Loaded")
      $("h1").text("Jockey")

  set_hooks = ->
    unless searching
      $("#search_box").val('')

    $("a[data-pjax]").filter(-> !($(this).data('pjaxed'))).each ->
      $(this).data('pjaxed',true)
      $(this).pjax("#content")

    $("a.enque").click (e) ->
      e.preventDefault()
      link = this
      $.post '/api/enque', {id: $(this).data('song')}, ->
        $(link).text("✔").attr('href',null)
    loading(false)
  set_hooks()

  realtime = new EventSource("/api/realtime?html=1")

  $(realtime).bind 'playing', (e) ->
    json = JSON.parse(e.originalEvent.data)
    $("#playing").html json.html
    $("#playing a[data-pjax]").pjax()
    if notification
      n = window.webkitNotifications.createNotification(
        $("#playing .artwork img").attr('src'), $("#playing .song_name").text(), $("#playing .song_artist").text())
      f = -> n.cancel()
      n.ondisplay = -> setTimeout(f, 2000)
      n.show()

  $(realtime).bind 'upcoming', (e) ->
    json = JSON.parse(e.originalEvent.data)
    return if searching
    return unless location.pathname == "/"
    $("#content").html json.html
    set_hooks()

  $(realtime).bind 'history', (e) ->
    json = JSON.parse(e.originalEvent.data)
    return if searching
    return unless location.pathname == "/history"
    $("#content").html json.html
    set_hooks()

  if window.webkitNotifications
    $(".notification").show()

    notification_turn = (flag) ->
      if flag
        if window.webkitNotifications.checkPermission() == 0
          $(".notification img").attr('src','/images/notification_on.svg')
          window.localStorage.jockify = "true"
          notification = true
        else
          window.webkitNotifications.requestPermission ->
            notification_turn(true) if window.webkitNotifications.checkPermission() == 0
      else
        $(".notification img").attr('src','/images/notification_off.svg')
        window.localStorage.jockify = "false"
        notification = false

    if window.localStorage.jockify == "true"
      notification_turn(true)

    $(".notification img").click (e) ->
      e.preventDefault()
      notification_turn(!notification)

  do_search = ->
    if $("#search_box").val().length == 0 && searching
      searching = false
      history.back()
      return
    return if query == $("#search_box").val()
    query = $("#search_box").val()
    return if query.length < 2

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
    set_hooks()
  # FIXME: Error handling

  $(window).bind 'pjax:popstate', (e) ->
    path = e.state.url.replace(location.origin,'')
    searching = !!(location.pathname.match(/^\/search/))

    switch path
      when "/"
        $("#content").load '/?no_layout=1', set_hooks
        searching = false
      when "/history"
        $("#content").load '/history?no_layout=1', set_hooks
        searching = false


