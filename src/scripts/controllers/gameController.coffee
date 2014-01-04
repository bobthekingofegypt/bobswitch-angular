class Controller
    constructor: (@$scope, @$log, @socketService, @messageService) ->
        @$scope.showReadyButton = false
        @$scope.showGame = false

        @messageService.subscribe "signed-in", @signedIn

        @socketService.on "game_state_start", @test
        
    signedIn: (name, parameters) =>
        @$scope.showReadyButton = true

    ready: ->
        @$scope.showReadyButton = false

        #@messageService.publish "player-updated", {name:"bob"}
        @socketService.emit "game:player:ready", ""

    test: (event, message) =>
        console.log message


angular.module('app').controller 'gameController', [
    '$scope',
    '$log',
    'socketService',
    'messageService',
    Controller
]
