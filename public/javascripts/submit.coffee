$ ->
  client = new Faye.Client "http://sabihinmona.herokuapp.com/faye"

  $("button").click ->
    message = $("textarea").val()
    if message.length > 0
      $.post('/save', {message: message}).done( (data) ->
        if data 
          client.publish('/faye', data);
          $("textarea").val("")
      )
    false

  $.get('/save', (messages) ->
    _.each messages, (message) ->
      add_message(message)
  )

  client.subscribe '/faye', (message) ->
    add_message(message)

add_message = (message) ->
  parsed_date = moment(message.created_at).format("MM/DD/YY HH:mm")
  $("#messages").prepend "<p>#{message.message} <small>#{parsed_date}</small></p>"
