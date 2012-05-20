socket = io.connect location.href

socket.on 'connect', ->
  #socket.emit 'msg send', 'data'
  socket.on 'msg push', talk_log
  socket.on 'topic push', change_topic
  socket.on 'onlineCount push', (count) ->
    $('#local').text(count)

@set_topic = ->
  topic = $('#topic').attr('value')
  socket.emit 'topic send', {topic:topic}
# クライアント側から送信
@send_message = ->
  name = $('#name').attr('value')
  message = $('#message').attr('value')
  socket.emit('msg send', {name:name, message:message})

# TODO 変なjavascriptが実行されないように
talk_log = (data) ->
  $('#talk-log').append "<a>#{data.name}: #{data.message}</a><br>"

change_topic = (data) ->
  $('#topic').attr('value', data.topic)
