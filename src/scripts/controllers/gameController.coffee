class Controller
    constructor: (@$scope, @$log, @playersService, @socketService, @messageService) ->
        @$scope.showReadyButton = false
        @$scope.showGame = false

        @$scope.topCard = undefined
        @$scope.players = new Array(4)

        @messageService.subscribe "signed-in", @signedIn

        @socketService.on "game:state:start", @start
        
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

    selectedCard: (index) ->
        console.log "card - " + index
        @$scope.players[0].cards.splice(index, 1)
    
    start: (message) =>
        @$scope.showGame = true

        numberOfPlayers = message.number_of_players

        cards = []
        for card in message.hand
            cards.push(@cardName(card.suit, card.rank))

        playerNames = message.players.slice()
        while (playerNames[0] != @playersService.getName())
            first = playerNames[0]
            playerNames.splice(0,1)
            playerNames.push(first)

        for player, i in @$scope.players
            $log.debug("i", i)
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
        }

        if numberOfPlayers == 2
            @$scope.players[2] = {
                name: playerNames[1],
                count: message.hand.length
                active: false
            }
        else if numberOfPlayers == 3
            @$scope.players[1] = {
                name: playerNames[1],
                count: message.hand.length
                active: false
            }
            @$scope.players[2] = {
                name: playerNames[2],
                count: message.hand.length
                active: false
            }
        else
            @$scope.players[1] = {
                name: playerNames[1],
                count: message.hand.length
                active: false
            }
            @$scope.players[2] = {
                name: playerNames[2],
                count: message.hand.length
                active: false
            }
            @$scope.players[3] = {
                name: playerNames[3],
                count: message.hand.length
                active: false
            }

        topCard = message.top_card
        @$scope.topCard = @cardName(topCard.suit, topCard.rank)

        startingName = message.players[message.starting_player]
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
    'socketService',
    'messageService',
    Controller
]
