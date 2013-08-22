$ ->
  $("#messages").on('click', 'a.copy', ->
    text = $(this).parent().parent().text()
    formatted_text = format_text text
    $("textarea").val($("textarea").val() + " " + formatted_text)
    false
  )


format_text = (text) ->
  text = text.replace /<(?:.|\n)*?>/gm, ''
  text = text.substring 0, text.length - 5
  text = "\"#{text}\" "
