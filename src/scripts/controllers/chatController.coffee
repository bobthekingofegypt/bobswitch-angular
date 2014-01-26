class Controller
    constructor: (@$scope, @$log, @socketService) ->
        @$scope.messages = [{ text: 'Welcome to bobswitch' }]

        @socketService.on "chat:message", (data) =>
            if data.name == null
                data.name = "Guest"
            @$scope.messages.push data

        @sendMessage = (message) =>
            @socketService.emit "chat:message", message
            @$scope.message = ""



angular.module('app').controller 'chatController', [
    '$scope',
    '$log',
    'socketService',
    Controller
]
