class Controller
    constructor: ($rootScope, @$scope, @$log, @gitHubService, @chatSocketService) ->
        @$scope.messages = ['BOBBY']

        @chatSocketService.on "chat:message", (message) =>
            @$scope.messages.push message

        @search = (searchTerm) =>
            @chatSocketService.emit "chat:message", searchTerm



angular.module('app').controller 'gitHubController', ['$rootScope', '$scope', '$log', 'gitHubService', 'chatSocketService', Controller]
