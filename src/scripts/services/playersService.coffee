class Service
    constructor: (@$log, @messageService, @socketService) ->
        @players = []
        @name = ""

        @socketService.on "game:state:start", @resetReadyFlags
        @socketService.on "game:state:update", @resetReadyFlags
        @socketService.on "game:state:watch", @resetReadyFlags

        @socketService.on "players:listing", (players) =>
            for player in players
                @addPlayer player.name, player.ready, player.disconnected

        @socketService.on "players:added", (message) =>
            @addPlayer message, false, false

        @socketService.on "players:removed", (message) =>
            @removePlayer message, false

        @socketService.on "players:disconnected", (message) =>
            @disconnectedPlayer(message)

        @socketService.on "players:reconnected", (message) =>
            @reconnectedPlayer(message)

        @socketService.emit "account:listing", ""

        @socketService.on "game:player:ready", (name) =>
            for player in @players when player.name == name
                player.ready = true

    resetReadyFlags: (message) =>
        for player in message.players
            for local_player in @players
                if local_player.name == player.name
                    local_player.played = player.played
                    local_player.won = player.won
        

        for player in @players
            player.ready = false

    setName: (name) ->
        @name = name

    getName: ->
        return @name

    reconnectedPlayer: (name) ->
        for player, i in @players
            if player.name == name
                ready = false
                player.disconnected = false
                break

    disconnectedPlayer: (name) ->
        for player, i in @players
            if player.name == name
                ready = false
                player.disconnected = true
                break

    removePlayer: (name) ->
        for player, i in @players
            if player.name == name
                @players.splice(i, 1)
                break

        @messageService.publish "player-added", { players: @players }

    addPlayer: (name, ready, disconnected) ->
        @players.push {
            name: name
            played: 0
            won: 0
            ready: ready
            disconnected: disconnected
        }

        @messageService.publish "player-added", { players: @players }


angular.module('app').service 'playersService', ['$log', 'messageService', 'socketService', Service]

