class Config
    constructor: ($routeProvider) ->
        $routeProvider.
        when('/room/:roomId', {
            templateUrl: '/views/site.html',
        }).
        when('/', {
            templateUrl: '/views/entry.html',
        }).
        otherwise
            redirectTo: '/'

angular.module('app').config ['$routeProvider', Config]
