describe "player controller tests", ->
    $scope = null
    messageCallback = null
    controller = null
    socketService = null
    cookies = null

    modal = null
    modalResult = null

    beforeEach module 'app'

    beforeEach ->
        messageService = {
            'subscribe': ->
        }

        modalResult = {
            result: {
                then: ->
            }
            close: ->
            dismiss: ->
        }

        modal = {
            open: ->
                return modalResult
        }

        cookies = {}

        socketService = { emit: -> }

        spyOn(messageService, 'subscribe').andCallFake (key, callback) ->
            expect(key).toEqual("player-added")
            messageCallback = callback

        inject ($rootScope, $controller) ->
            $scope = $rootScope.$new()

            controller = $controller('playerController', {
                $scope: $scope,
                messageService: messageService,
                $modal: modal,
                $cookies: cookies,
                socketService: socketService
            })

    it 'should have no players on startup', ->
        expect($scope.players.length).toEqual(0)

    it 'should start as a lurker', ->
        expect($scope.lurker).toEqual(true)
    
    it 'should have added received player to player list', ->
        players = ["bob"]
        messageCallback "bob", { players: players }

        expect($scope.players.length).toEqual(1)
        expect($scope.players).toBe(players)

    it 'should open modal when scope open called', ->
        spyOn(modal, "open").andCallThrough()

        $scope.open()

        expect(modal.open).toHaveBeenCalled()
        expect($scope.shouldBeOpen).toEqual("true")

    it 'should store the user name and fire login event if modal dismissed', ->
        $scope.input = { 'name': 'bob' }

        spyOn(socketService, "emit").andCallThrough()
        spyOn(modal, "open").andCallThrough()
        spyOn(modalResult.result, "then").andCallFake (callback) ->
            callback()

        $scope.open()

        expect(modal.open).toHaveBeenCalled()
        expect($scope.lurker).toEqual(false)
        expect(cookies.name).toEqual('bob')
        expect(socketService.emit).toHaveBeenCalledWith("account:login", "bob")
