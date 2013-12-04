class Service
    constructor: (@$log, @$http) ->
        @sock = SockJS('http://localhost:8080/chat')
        @sock.onopen = () =>
            console.log "HELLO"

        @sock.onmessage = (message) =>
            console.log message


    emit: (message) ->
        @sock.send angular.toJson({ test: message} )

angular.module('app').service 'chatSocketService', ['$log', '$http', Service]
