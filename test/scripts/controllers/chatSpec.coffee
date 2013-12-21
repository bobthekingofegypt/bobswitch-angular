describe "chat controller tests", ->
    $scope = null
    ctrl = null
    messageCallback = null
    socketService = null

    beforeEach module 'app'

    beforeEach ->
        socketService = {
            'on': ->
            'emit': ->
        }
        
        spyOn(socketService, 'on').andCallFake (key, callback) ->
            expect(key).toEqual("chat:message")
            messageCallback = callback

        inject ($rootScope, $controller) ->
            $scope = $rootScope.$new()

            ctrl = $controller('chatController', {
                $scope: $scope,
                socketService: socketService
            })

    it 'should have welcome message on scope', ->
        expect($scope.messages.length).toEqual(1)
    
    it 'should have added received message to array for display', ->
        messageCallback "a message"

        expect($scope.messages.length).toEqual(2)
        expect($scope.messages[1]).toEqual("a message")

    it 'should call socket service emit on send message', ->
        spyOn(socketService, 'emit').andCallThrough()

        ctrl.sendMessage "send this"

        expect(socketService.emit).toHaveBeenCalledWith("chat:message", "send this")


