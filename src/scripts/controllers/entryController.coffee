class Controller
    constructor: (@$scope, @$location, @$log, @socketService) ->
        
    joinroom: =>
        @$location.path('room/'+@$scope.room)



angular.module('app').controller 'entryController', [
    '$scope',
    '$location',
    '$log',
    'socketService',
    Controller
]
