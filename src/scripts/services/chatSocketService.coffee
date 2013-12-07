class Service
    constructor: (@log, @$window) ->
        @listeners = {}

        @sock = new @$window.SockJS('http://localhost:8080/chat')
        @sock.onopen = () =>
            @log.info "Socket connection created"

        @sock.onmessage = (message) =>
            @onmessage message

    on: (event, callback) ->
        if !@listeners[event]
            @listeners[event] = []

        @listeners[event].push(callback)

    onmessage: (message) ->
        if message.type == "event"
            if @listeners[message.name]
                eventListeners = @listeners[message.name]

                listener() for listener in eventListeners

    emit: (event, message) ->
        @sock.send angular.toJson {
            'type': 'event',
            'name': event,
            'message': message
        }

angular.module('app').service 'chatSocketService', ['$log', '$window', Service]
