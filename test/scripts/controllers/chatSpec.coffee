describe "chat controller tests", ->
    $scope = null
    ctrl = null

    beforeEach module 'app'

    beforeEach ->

        inject (_chatSocketService_, $rootScope, $controller) ->
            service = _chatSocketService_

            $scope = $rootScope.$new()

            ctrl = $controller('gitHubController', {
                $scope: $scope,
            })

    it 'should have welcome message on scope', ->
        expect($scope.messages.length).toEqual(1)
