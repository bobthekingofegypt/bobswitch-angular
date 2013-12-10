class Controller
    constructor: (@playersService, @messageService, @$cookies, @$scope, @$log, @gitHubService, @chatSocketService, $modal) ->
        @$scope.lurker = true
        @$scope.input = {}
        @$scope.messages = [{ text: 'Welcome to bobswitch' }]
        @$scope.players = []

        @messageService.subscribe "player-added", (name, parameters) =>
            @$scope.players = parameters.players

        @messageService.subscribe "players-updated", (name, parameters) =>
            @$scope.players = parameters.players

        @chatSocketService.on "players:listing", (message) =>
            console.log(message)
            

        @chatSocketService.emit "account:listing", ""

        @chatSocketService.on "chat:message", (data) =>
            @$scope.messages.push data
            #@$scope.messages.push { name: "Bob", text: message }

        @search = (searchTerm) =>
            @chatSocketService.emit "chat:message", searchTerm

        @$scope.open = =>
            @modalInstance = $modal.open({
                templateUrl: '/views/login-modal.html',
                scope: @$scope
            })

            @modalInstance.result.then =>
                @$cookies.name = $scope.input.name
                @chatSocketService.emit "account:login", @$scope.input.name
                #@playersService.addPlayer $scope.input.name

                #@chatSocketService.emit "account:listing", ""

                @$scope.lurker = false
            , =>
                @$log.info('Modal dismissed at: ' + new Date())

        @$scope.ok = =>
            @modalInstance.close()

        @$scope.cancel = =>
            @modalInstance.dismiss()


angular.module('app').controller 'gitHubController', ['playersService', 'messageService', '$cookies', '$scope', '$log', 'gitHubService', 'chatSocketService', '$modal', Controller]
