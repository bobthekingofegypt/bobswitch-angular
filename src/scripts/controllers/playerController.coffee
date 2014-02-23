class Controller
    constructor: (@$log, @messageService, @socketService, @$cookies,
                        @$scope, $modal, @playersService) ->
        #lurker just means you haven't yet added a user name
        @$scope.lurker = true
        #input is used to store the name from the modal
        @$scope.input = {}

        @$scope.showJoin = true

        @$scope.players = []
        
        @messageService.subscribe "player-added", (name, parameters) =>
            @$log.info("Player added: " + name)
            @$scope.players = parameters.players

            @$scope.showJoin = @shouldShowJoin()

        @$scope.players = @playersService.players

        @$scope.open = =>
            @modalInstance = $modal.open({
                templateUrl: '/views/login-modal.html',
                scope: @$scope
            })

            @modalInstance.result.then =>
                #@$cookies.name = @$scope.input.name
                @playersService.setName @$scope.input.name
                @socketService.emit "account:login", @$scope.input.name

                @messageService.publish "signed-in"

                @$scope.shouldBeOpen = "false"
                @$scope.lurker = false
                @$scope.showJoin = @shouldShowJoin()
            , =>
                @$log.info('Modal dismissed at: ' + new Date())

            #used to force focus on user input when modal is presented
            @$scope.shouldBeOpen = "true"

        @$scope.ok = =>
            if @$scope.input.name and @$scope.input.name != ""
                @modalInstance.close()

        @$scope.cancel = =>
            @modalInstance.dismiss()

    shouldShowJoin: =>
        disconnected = false
        for player in @$scope.players
            if player.disconnected
                disconnected = true
                break

        if not @$scope.lurker
            return false
        else
            return disconnected ||
                (@$scope.players.length < 4 && @$scope.lurker)
        

angular.module('app').controller 'playerController', [
    '$log',
    'messageService',
    'socketService',
    '$cookies',
    '$scope',
    '$modal',
    'playersService',
    Controller
]
