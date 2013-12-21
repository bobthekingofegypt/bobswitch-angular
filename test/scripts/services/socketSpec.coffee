describe "chatSocketService", ->
    mock = null
    service = null
    sockjsSpy = null

    beforeEach module 'app'

    beforeEach ->
        mock = {SockJS: ->}

        sockjsSpy = {}
        spyOn(mock, 'SockJS').andReturn(sockjsSpy)

        module ($provide) ->
            $provide.value('$window', mock)
            null

        inject (_socketService_) ->
            service = _socketService_
            service.block = false

    it 'should call callback on recieving a message', ->
        callback = jasmine.createSpy("on bob event callback")

        service.on("bob", callback)

        sockjsSpy.onmessage({
            "data" : '{
                "type": "event",
                "name": "bob",
                "message": "message goes here"
            }'
        })
        
        expect(callback).toHaveBeenCalled()
        
    it 'should call multiple callbacks when registered against a single event', ->
        callbackOne = jasmine.createSpy('on bob event callback one')
        callbackTwo = jasmine.createSpy('on bob event callback two')

        service.on("bob", callbackOne)
        service.on("bob", callbackTwo)

        sockjsSpy.onmessage({
            "data" : '{
                "type": "event",
                "name": "bob",
                "message": "message goes here"
            }'
        })

        expect(callbackOne).toHaveBeenCalled()
        expect(callbackTwo).toHaveBeenCalled()

    it 'should add multiple listeners to a single event', ->
        service.on("bob", ->)
        service.on("bob", ->)
        expect(service.listeners["bob"].length).toBe 2


    it 'should add a listener to event', ->
        service.on("bob", null)
        expect(service.listeners["bob"].length).toBe 1

    it 'should send json encoded object to socket', ->
        send = jasmine.createSpy()
        sockjsSpy.send = send

        service.emit "bob", "a message"

        expect(send).toHaveBeenCalledWith '{"type":"event","name":"bob","message":"a message"}'
         

