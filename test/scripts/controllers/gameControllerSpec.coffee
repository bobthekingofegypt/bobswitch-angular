describe "game controller tests", ->
    scope = controller = socketMock = playerService = null
    callbacks = {}

    beforeEach module 'app'

    beforeEach ->
        messageMock =
            subscribe: ->

        socketMock =
            on: ->
            emit: ->

        playerService =
            getName: ->

        spyOn(messageMock, 'subscribe').andCallFake (key, callback) ->
            callbacks[key] = callback

        inject ($rootScope, $controller) ->
            scope = $rootScope.$new()

            controller = $controller 'gameController', {
                $scope: scope
                messageService: messageMock
                socketService: socketMock
                playersService: playerService
            }

    it 'should set ready to true when player logs in', ->
        expect(scope.showReadyButton).toBe(false)

        callbacks["signed-in"]()

        expect(scope.showReadyButton).toBe(true)

    it 'should set ready to false once player selects ready', ->
        spyOn(socketMock, 'emit').andCallThrough()
        scope.showReadyButton = true

        controller.ready()

        expect(scope.showReadyButton).toBe(false)
        expect(socketMock.emit).toHaveBeenCalledWith "game:player:ready", ""

    it 'should add 2 players to players array', ->
        spyOn(playerService, 'getName').andCallFake ->
            return "john"

        controller.start {
            number_of_players: 2
            hand: [
                { suit: 0, rank: 1 }
                { suit: 3, rank: 11 }
                { suit: 1, rank: 1 }
            ]
            players: [ "bob", "john" ]
            top_card: { suit: 2, rank: 1 }
        }

        expect(scope.players[0].name).toBe("john")
        expect(scope.players[1].name).toBeNull()
        expect(scope.players[2].name).toBe("bob")
        expect(scope.players[3].name).toBeNull()

        expect(scope.players[0].count).toBe(3)
        expect(scope.players[1].count).toBe(0)
        expect(scope.players[2].count).toBe(3)
        expect(scope.players[3].count).toBe(0)

        expect(scope.players[0].cards.length).toBe(3)
        expect(scope.players[0].cards[0]).toBe("AH")
        expect(scope.players[0].cards[1]).toBe("JS")

    it 'should add 3 players to players array', ->
        spyOn(playerService, 'getName').andCallFake ->
            return "john"

        controller.start {
            number_of_players: 3
            hand: [
                { suit: 0, rank: 1 }
                { suit: 3, rank: 11 }
                { suit: 1, rank: 1 }
            ]
            players: [ "bob", "scott", "john" ]
            top_card: { suit: 2, rank: 1 }
            starting_player: 2
        }

        expect(scope.players[0].name).toBe("john")
        expect(scope.players[1].name).toBe("bob")
        expect(scope.players[2].name).toBe("scott")
        expect(scope.players[3].name).toBeNull()

        expect(scope.players[0].count).toBe(3)
        expect(scope.players[1].count).toBe(3)
        expect(scope.players[2].count).toBe(3)
        expect(scope.players[3].count).toBe(0)

        expect(scope.players[0].cards.length).toBe(3)

        expect(scope.players[0].active).toBe(true)
        expect(scope.players[1].active).toBe(false)
        expect(scope.players[2].active).toBe(false)

    it 'should add 4 players to players array', ->
        spyOn(playerService, 'getName').andCallFake ->
            return "john"

        controller.start {
            number_of_players: 4
            hand: [
                { suit: 0, rank: 1 }
                { suit: 3, rank: 11 }
                { suit: 1, rank: 1 }
            ]
            players: [ "bob", "scott", "john", "fred" ]
            top_card: { suit: 2, rank: 1 }
            starting_player: 0
        }

        expect(scope.players[0].name).toBe("john")
        expect(scope.players[1].name).toBe("fred")
        expect(scope.players[2].name).toBe("bob")
        expect(scope.players[3].name).toBe("scott")

        expect(scope.players[0].count).toBe(3)
        expect(scope.players[1].count).toBe(3)
        expect(scope.players[2].count).toBe(3)
        expect(scope.players[3].count).toBe(3)

        expect(scope.players[0].cards.length).toBe(3)

        expect(scope.players[0].active).toBe(false)
        expect(scope.players[1].active).toBe(false)
        expect(scope.players[2].active).toBe(true)
        expect(scope.players[3].active).toBe(false)

    it 'should return array of size give to range', ->
        expect(scope.range(3).length).toBe(3)
        expect(scope.range(0).length).toBe(0)
