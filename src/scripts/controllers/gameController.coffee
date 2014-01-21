class Controller
    constructor: (@$scope, @$log, @playersService, @$modal, @socketService, @messageService) ->
        @$scope.showReadyButton = false
        @$scope.showGame = false

        @$scope.topCard = undefined
        @$scope.players = new Array(4)

        @messageService.subscribe "signed-in", @signedIn

        @socketService.on "game:state:start", @start
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
        @$scope.showReadyButton = true

    ready: ->
        @$scope.showReadyButton = false

        @socketService.emit "game:player:ready", ""

    pick: ->
        @socketService.emit "game:player:move", {
            type: "pick"
        }


    selectedCard: (index) =>
        card = @$scope.players[0].cards[index]

        if card.raw.rank == 1
            @openAceModal index
        else
            @sendPlayerMove index

    openAceModal: (index) =>
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
            @$scope.players[0].cards.splice(index, 1)


    sendPlayerMove: (index) ->
        @socketService.emit "game:player:move", {
            type: "play"
            card: @$scope.players[0].cards[index].raw
        }
        @$scope.players[0].cards.splice(index, 1)

    wait: ->
        @socketService.emit "game:player:move", {
            type: "wait"
        }
    
    processResponse: (message) =>
        console.log message


    start: (message) =>
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
        console.log @$scope.players

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

        console.log(playerNames)
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

        return rankName + suitName


angular.module('app').controller 'gameController', [
    '$scope',
    '$log',
    'playersService',
    '$modal',
    'socketService',
    'messageService',
    Controller
]
