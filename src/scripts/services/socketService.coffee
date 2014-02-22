class Service
    constructor: (@$rootScope, @$log, @$window, @$routeParams, @messageService) ->
        @listeners = {}
        @block = true
        @queue = []

        host = "http://"+window.location.hostname
        @sock = new @$window.SockJS(''+host+':4500/bobswitch')
        @sock.onopen = () =>
            @$log.info "Socket connection created"
            @block = false
            @processQueue()
        
        @sock.onclose = =>
            @messageService.publish "connection-lost", { }

        @sock.onmessage = (message) =>
            @onmessage message

    processQueue: ->
        @emit e.event, e.message for e in @queue
        @queue = []

    on: (event, callback) ->
        if !@listeners[event]
            @listeners[event] = []

        @listeners[event].push(callback)

    onmessage: (message) ->
        console.log message
        data = angular.fromJson message.data
        if data.type == "event"
            if @listeners[data.name]
                eventListeners = @listeners[data.name]

                for listener in eventListeners
                    @$rootScope.$apply ->
                        listener.apply(@sock, [data.message])

    emit: (event, message) ->
        if @block
            @queue.push { event: event, message: message }
        else
            @sock.send angular.toJson {
                'type': 'event',
                'name': event,
                'room': @$routeParams.roomId,
                'message': message
            }

angular.module('app').service 'socketService', ['$rootScope', '$log', '$window', '$routeParams', 'messageService', Service]
