class Controller
    constructor: (@messageService, @$cookies, @$scope, @$log, @chatSocketService, $modal) ->
        #lurker just means you haven't yet added a user name
        @$scope.lurker = true
        @$scope.input = {}
        @$scope.messages = [{ text: 'Welcome to bobswitch' }]
        @$scope.players = []

        @messageService.subscribe "player-added", (name, parameters) =>
            @$scope.players = parameters.players

        @chatSocketService.on "chat:message", (data) =>
            @$scope.messages.push data

        @sendMessage = (message) =>
            @chatSocketService.emit "chat:message", message

        @$scope.open = =>
            @modalInstance = $modal.open({
                templateUrl: '/views/login-modal.html',
                scope: @$scope
            })

            @modalInstance.result.then =>
                @$cookies.name = $scope.input.name
                @chatSocketService.emit "account:login", @$scope.input.name

                @$scope.lurker = false
            , =>
                @$log.info('Modal dismissed at: ' + new Date())

        @$scope.ok = =>
            @modalInstance.close()

        @$scope.cancel = =>
            @modalInstance.dismiss()


angular.module('app').controller 'gitHubController', [
    'messageService',
    '$cookies',
    '$scope',
    '$log',
    'chatSocketService',
    '$modal',
    Controller
]
