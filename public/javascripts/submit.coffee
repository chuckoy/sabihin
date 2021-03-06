offset = 0
$ ->
  client = new Faye.Client "http://sabihinmona.herokuapp.com/faye"

  submitMessage = ->
    message = $("textarea").val()
      if message.length > 0
        $(".pure-button").addClass("pure-button-disabled")
        $(".pure-button").text("Sending...")
        message = message.replace /\<3/g, '♥'
        $.post('/save', {message: message, channel: channel}).done( (data) ->
          if data
            client.publish "/#{channel}", data
            $("textarea").val("")
            $(".pure-button").removeClass("pure-button-disabled")
            $(".pure-button").text("Send")
        )
      false

  $("button").click -> submitMessage
  $("textarea").keydown (e) ->
    if e.ctrlKey && e.keyCode == 13
      submitMessage

  get_messages offset

  client.subscribe "/#{channel}", (message) ->
    add_message message, 'before'

  $(window).scroll ->
    if $(window).scrollTop() + $(window).height() == $(document).height()
      offset += 20
      get_messages offset

  $("#loader").hide()

add_message = (message, where) ->
  formatted_message = format_message message
  if where == 'before'
    $("#messages").prepend formatted_message
    offset += 20
  else
    $("#messages").append formatted_message

window.set_channel = (channel) ->
  window.channel = channel

get_messages = (offset) ->
  $("#loader").show()
  $.get("/save/#{channel}/#{offset}", (messages) ->
    _.each messages, (message) ->
      add_message message, 'after'
    $("#loader").hide()
  )

format_message = (message) ->
  parsed_date = moment(message.created_at).format("MM/DD/YY HH:mm")
  display = $("<p>").text(message.message)
  display.html(display.html().replace /(#[\w]+)/g, "<a class='hashtag'>$1</a>")
  display.linkify({target: "_blank"})
  display.append " <small>#{parsed_date}</small>"
  display.append " <span><a href='#' class='copy'>Copy</a></span>"
