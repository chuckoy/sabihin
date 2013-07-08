$ ->
  client = new Faye.Client "http://sabihinmona.herokuapp.com/faye"

  $("button").click ->
    message = $("textarea").val()
    if message.length > 0
      $.post('/save', {message: message, channel: channel}).done( (data) ->
        if data 
          client.publish "/#{channel}", data
          $("textarea").val("")
      )
    false

  $.get("/save/#{channel}", (messages) ->
    _.each messages, (message) ->
      add_message(message)
  )

  client.subscribe "/#{channel}", (message) ->
    add_message(message)

add_message = (message) ->
  parsed_date = moment(message.created_at).format("MM/DD/YY HH:mm")
  $("#messages").prepend "<p>#{message.message} <small>#{parsed_date}</small></p>"

window.set_channel = (channel) ->
  window.channel = channel
