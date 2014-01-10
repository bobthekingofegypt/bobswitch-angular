describe 'focus spec', ->
    beforeEach module 'app'

    scope = element = compile = timeout =  null

    beforeEach inject ($compile, $rootScope, $timeout) ->
        scope = $rootScope.$new()
        compile = $compile
        timeout = $timeout
        element = angular.element '<input focus-me="{{ shouldBeOpen }}" />'

        angular.element(document.body).append(element)

    it 'should add focus to element', ->
        scope.shouldBeOpen = true
        e = compile(element) scope

        scope.$digest()
        timeout.flush()

        expect(document.activeElement).toBe(e[0])
    
    it 'should not have added focus to element', ->
        scope.shouldBeOpen = false
        e = compile(element) scope

        scope.$digest()
        timeout.flush()

        expect(document.activeElement).not.toBe(e[0])
