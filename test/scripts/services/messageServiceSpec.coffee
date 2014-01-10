describe "Message service spec", ->
    rootScope = messageService = scope = null

    beforeEach module 'app'

    beforeEach ->
        rootScope =
            $on: ->
            $broadcast: ->

        module ($provide) ->
            $provide.value('$rootScope', rootScope)
            null

        inject ($injector) ->
            messageService = $injector.get('messageService')

    it 'should set broadcast on listener', ->
        spyOn(rootScope, '$on').andCallThrough()

        callback = jasmine.createSpy "on bob event callback"
        messageService.subscribe "bob", callback

        expect(rootScope.$on).toHaveBeenCalled()
        expect(rootScope.$on.mostRecentCall.args[0]).toEqual("bob")
        expect(rootScope.$on.mostRecentCall.args[1]).toEqual(callback)

    it 'should set broadcast on listener for multiple subscribers', ->
        spyOn(rootScope, '$on').andCallThrough()
        callback = jasmine.createSpy "on bob event callback"
        callback2 = jasmine.createSpy "on bob event callback"

        messageService.subscribe "bob", callback
        messageService.subscribe "bob", callback2

        expect(rootScope.$on.calls.length).toEqual(2)

    it 'should call broadcast publish', ->
        spyOn(rootScope, '$on').andCallThrough()
        spyOn(rootScope, '$broadcast').andCallThrough()

        callback = jasmine.createSpy "on bob event callback"

        messageService.subscribe "bob", callback

        messageService.publish "bob", { param: "param" }

        expect(rootScope.$broadcast).toHaveBeenCalled()
