class Service
    constructor: (@$log, @messageService, @socketService) ->
        @players = []

        @socketService.on "players:listing", (players) =>
            for player in players
                @addPlayer player.name, player.ready

        @socketService.on "players:added", (message) =>
            @addPlayer message, false

        @socketService.emit "account:listing", ""

        @socketService.on "game:player:ready", (name) =>
            for player in @players when player.name == name
                player.ready = true

    addPlayer: (name, ready) ->
        @players.push {
            name: name
            played: 0
            won: 0
            ready: ready
        }

        @messageService.publish "player-added", { players: @players }


angular.module('app').service 'playersService', ['$log', 'messageService', 'socketService', Service]

