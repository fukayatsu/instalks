express = require 'express'
stylus = require 'stylus'
socketio = require 'socket.io'
uuid = require 'node-uuid'
redis = require 'redis'

routes = require './routes'

app =  express.createServer()
io = socketio.listen(app)
rc = redis.createClient()

app.configure ->
  app.use express.logger {format: ':method :url :status :response-time ms'}
  app.use require("connect-assets")()
  app.set 'view engine', 'jade'
  app.use express.static(__dirname + '/public')

# Routes
app.get '/', routes.index
app.get '/r/start', (req, resp) ->
  room_path = '/r/' + uuid.v4()
  io.of(room_path).on 'connection', create_socket
  resp.redirect room_path
app.get '/r/:id', (req, resp) ->
  resp.render 'room'

# チャットページ
create_socket = (socket) ->
  room = socket.namespace.name

  rc.sadd "global:roomSet", room

  rc.incr "global:onlineCount"

  rc.incr "rid:#{room}:onlineCount", (err, count) ->
    socket.emit 'onlineCount push', count
    socket.broadcast.emit 'onlineCount push', count

  socket.on 'msg send', (data) ->
    rc.lpush "rid:#{room}:massageList", JSON.stringify data
    socket.emit 'msg push', data
    socket.broadcast.emit 'msg push', data

  socket.on 'topic send', (data) ->
    rc.set "rid:#{room}:topic", data.topic
    socket.broadcast.emit 'topic push', data

  socket.on 'disconnect', ->
    rc.decr "global:onlineCount"

    rc.decr "rid:#{room}:onlineCount", (err, count) ->
      #socket.emit 'onlineCount push', count
      socket.broadcast.emit 'onlineCount push', count

port = process.env.PORT or 3000
app.listen port, -> console.log "Listening on port " + port
