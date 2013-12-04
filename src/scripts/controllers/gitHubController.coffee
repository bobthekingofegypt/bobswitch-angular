class Controller
    constructor: (@$log, @gitHubService, @chatSocketService) ->
        @search = (searchTerm) =>
            @chatSocketService.emit "HELP"
            @gitHubService.get(searchTerm).then (results) =>
                @repos = results

angular.module('app').controller 'gitHubController', ['$log', 'gitHubService', 'chatSocketService', Controller]
