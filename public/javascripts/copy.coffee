$ ->
  $("#messages").on('click', 'a.copy', ->
    text = $(this).parent().parent().html()
    formatted_text = format_text text
    $("textarea").append(formatted_text)
    false
  )


format_text = (text) ->
  text = text.replace(/<(?:.|\n)*?>/gm, '');
  text = text.substring(0, text.length - 5)
  text = "\"#{text}\" "
