class Controller
    constructor: (@$scope, @$log, @playersService, @$modal, @$routeParams, @socketService, @messageService) ->
        console.log @$routeParams
        @$scope.showReadyButton = false
        @$scope.showGame = false

        @$scope.winner = ""

        @$scope.topCard = "back"
        @$scope.players = new Array(4)
        for player, i in @$scope.players
            @$scope.players[i] = {
                name: null
                count: 0
                cards: []
                active: false
            }

        @messageService.subscribe "signed-in", @signedIn
        @messageService.subscribe "connection-lost", @connectionLost

        @socketService.on "game:state:start", @start
        @socketService.on "game:state:watch", @watch
        @socketService.on "game:player:response", @processResponse
        @socketService.on "game:state:update", @start
        
        #really shouldn't have these here but its easier for now
        @$scope.range = (n) ->
            if n
                return new Array(n)
            return new Array()

        @$scope.cardWidth = (a) ->
            return 92 + (a.length * 18)

    signedIn: (name, parameters) =>
        if not @$scope.showGame
            @$scope.showReadyButton = true

    ready: ->
        @$scope.showReadyButton = false
        @$scope.showFinishButton = false

        @socketService.emit "game:player:ready", ""

    pick: ->
        @socketService.emit "game:player:move", {
            type: "pick"
        }

    connectionLost: =>
        @modalInstance = @$modal.open {
            templateUrl: '/views/connection-lost.html'
            scope: @$scope
            backdrop: 'static'
            keyboard: false
        }


    selectedCard: (index) =>
        if !@$scope.players[0].active
            return

        card = @$scope.players[0].cards[index]

        if card.raw.rank == 1
            @openAceModal index
        else
            @sendPlayerMove index

    openAceModal: (index) =>
        if !@$scope.players[0].active
            return

        @modalInstance = @$modal.open {
            templateUrl: '/views/ace-modal.html',
            scope: @$scope,
            backdrop: 'static'
        }

        @$scope.suitSelected = (suit) =>
            @modalInstance.close()

            @socketService.emit "game:player:move", {
                type: "play"
                card: @$scope.players[0].cards[index].raw
                suit: suit
            }

    sendPlayerMove: (index) ->
        @socketService.emit "game:player:move", {
            type: "play"
            card: @$scope.players[0].cards[index].raw
        }

    wait: ->
        @socketService.emit "game:player:move", {
            type: "wait"
        }
    
    processResponse: (message) =>
        console.log message

    watch: (message) =>
        @$scope.showReadyButton = false
        @$scope.showFinishButton = false

        if message.state == "finished"
            @$scope.showReadyButton = true
            @$scope.showGame = false
        else
            @$scope.showGame = true

        numberOfPlayers = message.number_of_players

        playerNames = message.players.slice()

        for player, i in @$scope.players
            @$scope.players[i] = {
                name: null
                count: 0
                active: false
            }

        cards = []
        for card in [0..playerNames[0].count-1]
            cards.push {
                name: "back"
            }

        @$scope.players[0] = {
            name: playerNames[0].name,
            count: playerNames[0].count,
            active: false
            cards: cards
            wait: false
        }

        startingName = message.players[message.starting_player-1].name
        @configureOtherPlayers numberOfPlayers, playerNames

        topCard = message.top_card
        @$scope.topCard = @cardName(topCard.suit, topCard.rank)

        p.active = true for p in @$scope.players when p.name == startingName

    configureOtherPlayers: (numberOfPlayers, playerNames) =>
        if numberOfPlayers == 2
            @$scope.players[2] = {
                name: playerNames[1].name,
                count: playerNames[1].count,
                active: false
            }
        else if numberOfPlayers == 3
            @$scope.players[1] = {
                name: playerNames[1].name,
                count: playerNames[1].count,
                active: false
            }
            @$scope.players[2] = {
                name: playerNames[2].name,
                count: playerNames[2].count,
                active: false
            }
        else
            @$scope.players[1] = {
                name: playerNames[1].name,
                count: playerNames[1].count,
                active: false
            }
            @$scope.players[2] = {
                name: playerNames[2].name,
                count: playerNames[2].count,
                active: false
            }
            @$scope.players[3] = {
                name: playerNames[3].name,
                count: playerNames[3].count,
                active: false
            }



    start: (message) =>
        @$scope.showReadyButton = false
        @$scope.showFinishButton = false

        if message.state == "finished"
            @$scope.showGame = false
            @$scope.showFinishButton = true

            for player in message.players
                if player.count == 0
                    @$scope.winner = player.name
        else
            @$scope.showGame = true

        numberOfPlayers = message.number_of_players

        cards = []
        for card in message.hand
            cards.push {
                raw: card
                name: @cardName card.suit, card.rank
            }

        playerNames = message.players.slice()
        while (playerNames[0].name != @playersService.getName())
            first = playerNames[0]
            playerNames.splice(0,1)
            playerNames.push(first)

        for player, i in @$scope.players
            @$scope.players[i] = {
                name: null
                count: 0
                active: false
            }

        @$scope.players[0] = {
            name: @playersService.getName(),
            count: message.hand.length,
            cards: cards
            active: false
            wait: false
        }

        startingName = message.players[message.starting_player-1].name

        if message.state == "wait"
            containsEight = false
            for card in message.hand
                containsEight = true if card.rank == 8
                break
            @$scope.players[0].wait = startingName == @playersService.getName() and !containsEight
        else if message.state == "pick"
            @$scope.players[0].pick = startingName == @playersService.getName()

        @configureOtherPlayers numberOfPlayers, playerNames

        topCard = message.top_card
        @$scope.topCard = @cardName(topCard.suit, topCard.rank)

        p.active = true for p in @$scope.players when p.name == startingName

    cardName: (suit, rank) ->
        suitName = null
        switch suit
            when 0 then suitName = "H"
            when 1 then suitName = "C"
            when 2 then suitName = "D"
            when 3 then suitName = "S"
        
        rankName = null
        switch rank
            when 1 then rankName = "A"
            when 11 then rankName = "J"
            when 12 then rankName = "Q"
            when 13 then rankName = "K"
            else rankName = rank

        card = rankName + suitName
        if card == "AD"
            return "AceDiamonds"

        return rankName + suitName


angular.module('app').controller 'gameController', [
    '$scope',
    '$log',
    'playersService',
    '$modal',
    '$routeParams',
    'socketService',
    'messageService',
    Controller
]
