$ ->
  client = new Faye.Client "http://sabihinmona.herokuapp.com/faye"
  offset = 0

  $("button").click ->
    message = $("textarea").val()
    if message.length > 0
      $.post('/save', {message: message, channel: channel}).done( (data) ->
        if data 
          client.publish "/#{channel}", data
          $("textarea").val("")
      )
    false

  get_messages offset

  client.subscribe "/#{channel}", (message) ->
    add_message message, 'before'

  $(window).scroll ->
    if $(window).scrollTop() + $(window).height() == $(document).height()
      offset += 10 
      get_messages offset

add_message = (message, where) ->
  parsed_date = moment(message.created_at).format("MM/DD/YY HH:mm")
  if where == 'before'
    $("#messages").prepend "<p>#{message.message} <small>#{parsed_date}</small></p>"
  else
    $("#messages").append "<p>#{message.message} <small>#{parsed_date}</small></p>"

window.set_channel = (channel) ->
  window.channel = channel

get_messages = (offset) ->
  $.get("/save/#{channel}/#{offset}", (messages) ->
    _.each messages, (message) ->
      add_message message, 'after'
  )
