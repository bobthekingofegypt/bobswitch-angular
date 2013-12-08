class Controller
    constructor: ($rootScope, @$cookies, @$scope, @$log, @gitHubService, @chatSocketService, $modal) ->
        @$scope.lurker = true
        @$scope.input = {}
        @$scope.messages = ['Welcome to bobswitch']

        @chatSocketService.on "chat:message", (message) =>
            @$scope.messages.push message

        @search = (searchTerm) =>
            @chatSocketService.emit "chat:message", searchTerm

        @$scope.open = =>
            console.log "HELLO"
            @modalInstance = $modal.open({
                templateUrl: '/views/login-modal.html',
                scope: @$scope,
                resolve: {
                    items: => return ["test", "test2"]
                }
            })

            @modalInstance.result.then( =>
                @$cookies.name = $scope.input.name
                @chatSocketService.emit "account:login", @$scope.input.name
                @$scope.lurker = false
                console.log "wooo " + @$scope.input.name
            , =>
                @$log.info('Modal dismissed at: ' + new Date())
            )

        @$scope.ok = =>
            @modalInstance.close()

        @$scope.cancel = =>
            @modalInstance.dismiss()


angular.module('app').controller 'gitHubController', ['$rootScope', '$cookies', '$scope', '$log', 'gitHubService', 'chatSocketService', '$modal', Controller]
