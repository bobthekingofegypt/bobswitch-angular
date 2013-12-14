class Service
    constructor: (@$log, @messageService, @socketService) ->
        @players = []

        @socketService.on "players:listing", (names) =>
            @addPlayer name for name in names

        @socketService.on "players:added", (message) =>
            @addPlayer message

        @socketService.emit "account:listing", ""


    addPlayer: (name) ->
        @players.push {
            name: name
            played: 0
            won: 0
        }

        @messageService.publish "player-added", { players: @players }


angular.module('app').service 'playersService', ['$log', 'messageService', 'chatSocketService', Service]

