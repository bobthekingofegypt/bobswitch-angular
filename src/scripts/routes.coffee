class Config
    constructor: ($routeProvider) ->
        $routeProvider
        .otherwise
            redirectTo: '/'

angular.module('app').config ['$routeProvider', Config]
