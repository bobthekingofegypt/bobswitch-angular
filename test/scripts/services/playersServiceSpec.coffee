describe "Players service spec", ->
    mockSocket = scope = playersService = mockMessage = null
    callbacks = {}

    beforeEach module 'app'

    beforeEach ->
        mockMessage =
            publish: ->
        mockSocket =
            on: ->
            emit: ->

        spyOn(mockSocket, 'on').andCallFake (key, callback) ->
            callbacks[key] = callback

        module ($provide) ->
            $provide.value('socketService', mockSocket)
            $provide.value('messageService', mockMessage)
            null

        inject ($injector) ->
            playersService = $injector.get("playersService")

    it 'should reset ready flags on game start', ->
        playersService.players = [
            { ready: true }
            { ready: true }
            { ready: true }
        ]

        message = {
            players: {}
        }

        callbacks["game:state:start"](message)

        expect(_.every playersService.players, (item) ->
            item.ready == false
        ).toBe(true)

    it 'should add player to list and notify all listeners', ->
        spyOn(mockMessage, 'publish').andCallThrough()
        callbacks["players:added"]("bob")

        expect(playersService.players.length).toBe(1)

        expect(mockMessage.publish).toHaveBeenCalled()
        expect(mockMessage.publish.mostRecentCall.args[0]).toEqual("player-added")

    it 'should remove player from list and notify all listeners', ->

        playersService.players = [
            { name: "bob" },
            { name: "fred" }
        ]

        spyOn(mockMessage, 'publish').andCallThrough()
        callbacks["players:removed"]("bob")

        expect(playersService.players.length).toBe(1)

        expect(mockMessage.publish).toHaveBeenCalled()
        expect(mockMessage.publish.mostRecentCall.args[0]).toEqual("player-added")

    it 'should set players name when setName called', ->
        playersService.setName("bob")

        expect(playersService.getName()).toEqual("bob")

    it 'should add all players from listing', ->
        spyOn(mockMessage, 'publish').andCallThrough()

        players = [
            {
                name: "bob"
                ready: true
            }
            {
                name: "John"
                ready: false
            }
        ]

        callbacks["players:listing"](players)

        expect(mockMessage.publish.calls.length).toEqual(2)
        expect(playersService.players.length).toEqual(2)
        expect(playersService.players[1].ready).toBe(false)

    it 'should set player to ready when socket message recieved', ->
        playersService.players = [
            {
                name: "bob"
                ready: true
            }
            {
                name: "John"
                ready: false
            }
        ]

        expect(playersService.players[1].ready).toBe(false)
        callbacks["game:player:ready"]("John")
        expect(playersService.players[1].ready).toBe(true)



