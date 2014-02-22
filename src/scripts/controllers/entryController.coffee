class Controller
    constructor: (@$scope, @$location, @$log, @socketService) ->
        
    joinroom: =>
        console.log("BANANA")
        console.log(@$scope.room)
        @$location.path('room/'+@$scope.room)



angular.module('app').controller 'entryController', [
    '$scope',
    '$location',
    '$log',
    'socketService',
    Controller
]
