class Service
    constructor: (@$rootScope, @$log, @$window) ->
        @listeners = {}

        @sock = new @$window.SockJS('http://localhost:8080/bobswitch')
        @sock.onopen = () =>
            @$log.info "Socket connection created"

        @sock.onmessage = (message) =>
            console.log("WTF")
            @onmessage message

    on: (event, callback) ->
        if !@listeners[event]
            @listeners[event] = []

        @listeners[event].push(callback)

    onmessage: (message) ->
        data = angular.fromJson message.data
        if data.type == "event"
            if @listeners[data.name]
                eventListeners = @listeners[data.name]

                for listener in eventListeners
                    @$rootScope.$apply ->
                        listener.apply(@sock, [data.message])

    emit: (event, message) ->
        @sock.send angular.toJson {
            'type': 'event',
            'name': event,
            'message': message
        }

angular.module('app').service 'chatSocketService', ['$rootScope', '$log', '$window', Service]
