$ ->
  $("button").click ->
    message = $("textarea").val()
    $.post('/save', {message: message}).done( (data) ->
      if data then console.log true else console.log false
    )

  $.get('/save', (messages) ->
    _.each messages, (a) ->
      parsed_date = moment(a.created_at).format("MM/DD/YY HH:mm")
      $("#messages").prepend "<p>#{a.message} <small>#{parsed_date}</small></p>"
  )
